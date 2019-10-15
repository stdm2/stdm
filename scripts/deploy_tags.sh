#!/bin/bash
zip -9 -r stdm_${TRAVIS_TAG}.zip stdm
curl --ftp-create-dirs --fail -T stdm_*.zip -u $FTP_USER:$FTP_PASSWORD -vv ftp://$FTP_ADDRESS:$FTP_PORT/plugin/dev/
exit 0