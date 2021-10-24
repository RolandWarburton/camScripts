#!/bin/bash

# make sure to link the script first!
#     cd camScripts/compress && npm link && which compress
# then paste the result of above into the script below

SCRIPT_LOCATION="/home/borg/.nvm/versions/node/v16.12.0/bin/compress"

# compress 15 min blocks to hours
$SCRIPT_LOCATION -c cam01 -t 15min -d hourly -b 4 -w /mnt/borg/security-recordings

# compress hourly blocks to daily blocks
$SCRIPT_LOCATION -c cam01 -t hourly -d daily -b 12 -w /mnt/borg/security-recordings
