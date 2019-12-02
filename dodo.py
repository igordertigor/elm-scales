import re
import subprocess


COPY_FILES = ['index.html', 'scales.css']
ELM_COMPILE = [('scales.elm', 'scales.js')]
SRC_FOLDER = 'src'
BLD_FOLDER = 'build'


def build_targets():
    return (
        [BLD_FOLDER + '/' + fname for fname in COPY_FILES] +
        [BLD_FOLDER + '/' + fname for _, fname in ELM_COMPILE]
    )


def build_sources():
    return (
        copy_sources() +
        [SRC_FOLDER + '/' + fname for fname, _ in ELM_COMPILE]
    )


def copy_sources():
    return [SRC_FOLDER + '/' + fname for fname in COPY_FILES]


def task_build():
    return {
        'targets': build_targets(),
        'file_dep': build_sources(),
        'actions': (
            ['mkdir -p {}'.format(BLD_FOLDER),
             'cp {} {}'
             .format(' '.join(copy_sources()),
                     BLD_FOLDER)] +
            ['elm make {}/{} --output {}/{}'
             .format(SRC_FOLDER, src, BLD_FOLDER, trg)
             for src, trg in ELM_COMPILE]
        )
    }


def get_ftp_user():
    lpass = subprocess.check_output(
        'lpass show 3566222442604292113',
        shell=True).decode()
    m = re.search(r'User:\s(.*)$', lpass, re.MULTILINE)
    return m.group(1)


def task_upload():
    return {
        'file_dep': build_targets(),
        'actions': [
            'sftp -b upload.sftp {}@ftp.ingofruend.net'
            .format(get_ftp_user())
        ],
    }
