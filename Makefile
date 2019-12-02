scales.js: src/scales.elm
	elm make src/scales.elm --output scales.js

upload: scales.js index.html scales.css
	sftp -B upload.sftp 368370-ftp@ftp.ingofruend.net
