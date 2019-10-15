#!/bin/bash
zip -9 -r  stdm_${TRAVIS_BRANCH}.zip stdm
curl --ftp-create-dirs --fail -T stdm_${TRAVIS_BRANCH}.zip -u $FTP_USER:$FTP_PASSWORD -vv ftp://$FTP_ADDRESS:$FTP_PORT/plugin/stable/
exit 0