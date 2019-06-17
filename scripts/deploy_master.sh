#!/bin/bash
zip -9 -r  stdm_${TRAVIS_BRANCH}.zip stdm
curl --ftp-create-dirs -T stdm_*.zip -u $FTP_USER:$FTP_PASSWORD ftp://$FTP_ADDRESS/plugin/stable/
