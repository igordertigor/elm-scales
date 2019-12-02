module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Major { key = C, sign = Unsigned, mode = 1 }
    , Random.generate NextScale randomScale
    )


type Msg
    = NextScale Scale
    | RandomScale
    | SelectHarmony String


type Harmony
    = Major


fromString : String -> Harmony
fromString s =
    case s of
        "Major" ->
            Major

        _ ->
            Major


type alias Scale =
    { key : Key
    , sign : Sign
    , mode : Int
    }


type alias Model =
    { harmony : Harmony
    , scale : Scale
    }


type Key
    = C
    | D
    | E
    | F
    | G
    | A
    | B


type Sign
    = Flat
    | Sharp
    | Unsigned


randomScale : Random.Generator Scale
randomScale =
    Random.map3 Scale randomKey randomSign randomMode


randomKey : Random.Generator Key
randomKey =
    Random.uniform C [ D, E, F, G, A, B ]


randomSign : Random.Generator Sign
randomSign =
    Random.uniform Unsigned [ Sharp, Flat ]


randomMode : Random.Generator Int
randomMode =
    Random.int 1 7


update msg model =
    case msg of
        RandomScale ->
            ( model
            , Random.generate NextScale randomScale
            )

        NextScale scale ->
            ( { model | scale = scale }
            , Cmd.none
            )

        SelectHarmony harmony ->
            ( { model | harmony = fromString harmony }
            , Random.generate NextScale randomScale
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ select
            [ onInput SelectHarmony ]
            [ viewOption Major
            ]
        , button [ onClick RandomScale ] [ text "Next Scale" ]
        , div [] [ text (scale2String model.harmony model.scale) ]
        ]


viewOption : Harmony -> Html Msg
viewOption harmony =
    option
        [ value <| harmony2String harmony ]
        [ text <| harmony2String harmony ]


harmony2String : Harmony -> String
harmony2String harmony =
    case harmony of
        Major ->
            "Major"


mode2String : Harmony -> Int -> String
mode2String harmony mode =
    case harmony of
        Major ->
            getFromList [ "", "-7", "sus ♭9", "♯4", "7", "♭6", "∅" ] mode ""


scale2String : Harmony -> Scale -> String
scale2String harmony scale =
    key2String scale ++ " " ++ mode2String harmony scale.mode


key2String : Scale -> String
key2String scale =
    baseKey2String scale.key ++ sign2String scale.sign


baseKey2String : Key -> String
baseKey2String key =
    case key of
        C ->
            "C"

        D ->
            "D"

        E ->
            "E"

        F ->
            "F"

        G ->
            "G"

        A ->
            "A"

        B ->
            "B"


sign2String : Sign -> String
sign2String sign =
    case sign of
        Unsigned ->
            ""

        Flat ->
            "♭"

        Sharp ->
            "♯"


getFromList : List String -> Int -> String -> String
getFromList l idx default =
    let
        val =
            List.head (List.drop idx l)
    in
    case val of
        Just s ->
            s

        Nothing ->
            default
