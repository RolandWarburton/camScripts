# Cam2IP

Converts a webcam into an IP camera that can be monitored via a browser.

## Deploying

### Step 1

Create a volume to store data from ffmpeg.

```none
docker volume create cam2ip
```

### Step 2

Change the URL in `server/index.html` to const `http://<your-ip-or-domain>:8000/live/output.m3u8`.

Then inspect the docker-compose file and change the mapped device from `/dev/video0` on the host to whichever camera device you are using.

```yaml
devices:
    - "/dev/<your-device>:/dev/video0"
```

### Step 3

Then run the usual docker commands.

```none
docker-compose up --build -d
```

Now browser to [http://your-ip-or-domain:8000](http://your-ip-or-domain:8000) and you should see the live stream.

Note that there is a ~20s delay caused by the nature of this streaming technique. As far as i know there is no way to overcome this.
