#!/usr/bin/env bash

# Save 15 min chunks (900s) from the camera
# Make sure to change the variables below to work with your camera

USERNAME="admin"
PASSWORD="password"
ADDRESS="192.168.0.135:554"
SCHEME="h264Preview_01_sub"

# h264Preview_01_sub
WIDTH=640
HEIGHT=480
FPS=15

# h264Preview_01_main
# WIDTH=
# HEIGHT=
# FPS=

# rtsp://admin:password@192.168.0.135:554//h264Preview_01_sub
STREAM_URL="rtsp://$USERNAME:$PASSWORD@$ADDRESS/$SCHEME"

# the name of this camera
# used to create sub directories for writing footage to
CAM_NAME="cam01"

mkdir -p ./15min/$CAM_NAME
mkdir -p ./hourly/$CAM_NAME
mkdir -p ./daily/$CAM_NAME
mkdir logs 2> /dev/null

# move to the 15 min directory
cd 15min/$CAM_NAME


openRTSP \
-n \
-c \
-D 25 \
-4 \
-w $WIDTH \
-h $HEIGHT \
-f $FPS \
-F $CAM_NAME \
-P 900 \
-u $USERNAME $PASSWORD \
$STREAM_URL

# http://www.live555.com/openRTSP/
# -n								be notified when RTP data packets start arriving
# -c								play continuously
# -D <maximum-inter-packet-gap>		specify a maximum period of inactivity to wait before exiting
# -4								output a '.mp4'-format file (to 'stdout', unless the "-P <interval-in-seconds>" option is also given)
# -w <width>						width
# -h <height>						height
# -f <number>						fps
# -F <fileName-prefix>				specify a prefix for each output file name
# -P <interval-in-seconds>			write new output files every <interval-in-seconds> seconds
# -u <username> <password>			specify a user name and password for digest authentication

