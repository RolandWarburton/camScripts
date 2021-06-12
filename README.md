# Security Camera Scripts

A collection of random scripts i wrote to record and save footage with.

## Motion Project

Record only when motion is detected in full quality.

[Motion Project](https://github.com/Motion-Project/motion) is a program that monitors the video signal from one or more cameras and is able to detect if a significant part of the picture has changed. Or in other words, it can detect motion.

To start motion...

* Configure the `target_dir` in motion.conf
* Configure the `netcam_url` in motion.conf
* set `webcontrol_parms 0` to disable the web control server
* set `stream_localhost on` to restrict access the the stream if you wish

```none
motion -c ./motion.conf
```

## 24/7 Recording

Record in sub quality all the time for archiving.

Install `recordBatch.service` to `/etc/systemd/system/` and then run `sudo systemctl daemon-reload` and `sudo systemctl start recordBatch.service`.

the service file calls and monitors `recordBatch.sh` in the camScripts directory so **make sure to change the path in the .service file**.

When you want to add move cameras, just duplicate the `recordBatch.service` and `recordBatch.sh` scripts and change the variables in them to create another camera.

## Archiving 24/7 recordings

By default `recordBatch.sh` will record in 15 min chunks. `compress.sh` will use ffmpeg to squash these into bigger chunks for storage.

By default there are commands provided for compress.sh to move 4x15 min blocks into 1 hour blocks, and then move 12x1 hour blocks into 1 day blocks in `run15min.sh` and `runHourly.sh` respectively.

```shell
# 4 x 15min -> 1 hour
./compress.sh -c cam01 -t 15min/cam01 -d hourly/cam01 -b 4

# 12 x 1hour -> 1 day
./compress.sh -c cam01 -t hourly/cam01 -d daily/cam01 -b 2
```

The compress.sh script will create the appropriate directories for the destination mp4 based on the `-d` flag relative to the working directory (where you are, not where the script is).

## Rebooting failed cameras

Ive noticed a but with my camera (reolink) where it doesn't tear down the stream fast enough when disconnecting and reconnecting to it with clients like MPV or openRTSP. I included an small debugging script in `./rebootCamera` that logs in through a HTTP POST and sends a request to restart the camera.

## Ensuring camera uptime

In the future i would like to create a watchdog script that automatically looks for a recording file, or checks the number of 15min recording blocks inside the 15min directory, and sends a restart signal to the camera, waits 1min, and then restarts the systemd unit as well to try and re-establish a link and continue recording. But i haven't done this yet.

## Disclaimer

Also yes i am 100% aware admin:password is not secure, this setup isn't what im using in real life (obviously). Make sure when you set up your camera you use a secure password, and read the motion docs along with the dot points above to secure the camera on the LAN, and make sure you are not allowing outside traffic to access your cameras streams through an open port 8080.
