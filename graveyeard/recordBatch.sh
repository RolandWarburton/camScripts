#!/bin/bash

# Save 15 min chunks (900s) from the camera
# Make sure to change the variables below to work with your camera

USERNAME="admin"
PASSWORD="password"
ADDRESS="192.168.0.135:554"
SCHEME="h264Preview_01_sub"

# rtsp://admin:password@192.168.0.135:554//h264Preview_01_sub
STREAM_URL="rtsp://$USERNAME:$PASSWORD@$ADDRESS//$SCHEME"

# the name of this camera
# used to create sub directories for writing footage to
CAM_NAME="cam01"

mkdir -p ./15min/$CAM_NAME
mkdir -p ./hourly/$CAM_NAME
mkdir -p ./daily/$CAM_NAME
mkdir logs 2> /dev/null

# move to the 15 min directory
cd 15min/$CAM_NAME

# # test if there is a pid file
# if [ test -f "./pid" ] && [ [ -n "$(ps -p $(cat ./pid) -o pid=)" ] ]; then
# 	# read the pid from the file and check if its running
# 	if ; then
# 		# if its running then try and kill it
# 		echo "pid exists. killing it"
# 		if kill -HUP $(cat ./pid); then
# 			rm ./pid
# 		else
# 			echo "failed to kill process $(cat ./pid)"
# 			exit 1
# 		fi
# 	fi
# fi


# PID logic here

# pid=$(cat ./pid)

# # if the pid isnt running then remove the pid file
# if [ -n "$(ps -p $pid -o pid=)" ]; then
# 	rm ./pid
# fi

# # test if there is a pid file
# # and read the pid from the file and check if its running (-n = string length is not zero)
# if [ -f $(realpath $pid) ] && [ -n "$(ps -p $pid -o pid=)" ]; then
# 	# if its running then try and kill it
# 	echo "pid exists. killing it"
# 	if kill -HUP $pid; then
# 		echo "killed process $pid successful"
# 		rm ./pid
# 	else
# 		echo "failed to kill process $pid"
# 		exit 1
# 	fi
# fi





# record 15 min chunks
# openRTSP -n -c -D 5 -4 -w 640 -h 480 -f 15 -F $CAM_NAME -P 900 -u admin password $STREAM_URL 2> >(tee -a streamlog.txt) 2> >(grep -P "kill -HUP \d+" > kill)
# openRTSP -n -c -D 5 -4 -w 640 -h 480 -f 15 -F $CAM_NAME -P 900 -u admin password $STREAM_URL 2> >(tee -a stderr.log >&2) 2> >(grep --color "kill" >&1)
# openRTSP -n -c -D 5 -4 -w 640 -h 480 -f 15 -F $CAM_NAME -P 900 -u admin password $STREAM_URL > >(tee stderr.log >&2) > >(echo $! > pid)
# openRTSP -n -c -D 5 -4 -w 640 -h 480 -f 15 -F $CAM_NAME -P 900 -u admin password $STREAM_URL & echo $! > pid

# log to a logfile with process substitution https://www.youtube.com/watch?v=dR0X0-B9ObA
# and echo the PID into a file to later use
# Keep in mind that this detaches itself because of the "& echo"
# openRTSP -n -c -D 5 -4 -w 640 -h 480 -f 15 -F $CAM_NAME -P 60 -u admin password $STREAM_URL 2> >(tee -a $CAM_NAME.log >&2)
openRTSP -n -c -D 5 -4 -w 640 -h 480 -f 15 -F $CAM_NAME -P 60 -u admin password $STREAM_URL

# openRTSP -n -c -D 5 -4 -w 640 -h 480 -f 15 -F $CAM_NAME -P 900 -u admin password $STREAM_URL & echo !$ > pid

# learn about the redirect
# also FYI for some reason openRTSP outputs all its stdout on stderr streams for some reason
# because openRTSP outputs all its text to stderr on 2> we need to use >&2 to output the text BACk to stderr once we are done with it
# https://stackoverflow.com/questions/692000/how-do-i-write-stderr-to-a-file-while-using-tee-with-a-pipe

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

