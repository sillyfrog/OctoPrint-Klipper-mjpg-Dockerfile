# OctoPrint-Klipper-mjpg-Dockerfile
A Dockerfile for running OctoPrint Klipper and mjpg in a single container.

My initial goal was to run these across different containers, but I couldn't get the Docker permissions to play nicely.

This is very much written for what I needed, so you'll likely need to hack this up for your setup. I've been using it for a little while now and it's going well.

Also included are some udev rules for reference that I use. These will need to be updated with your API key etc, however it makes connecting/disconnecting (power on/off) of the printer much less painful.

## Running the container

Once the container is built (the usual `docker build . -t okmd`), I use the following command to run it (again, you will need to customise for your setup, I have 3 cameras also connected):

```
docker kill octoprint2
docker rm octoprint2
docker run --name octoprint2 -d -v /etc/localtime:/etc/localtime:ro -v /home/user/Documents/octoprint-config:/home/octoprint/.octoprint \
    --device /dev/ttyUSB0:/dev/ttyUSB0 \
    --device /dev/video0:/dev/video0 \
    --device /dev/video1:/dev/video1 \
    --device /dev/video2:/dev/video2 \
    -p 5000:5000 -p 8080:8080 -p 8081:8081 -p 8082:8082\
    -e "MJPG=input_uvc.so -r HD -d /dev/video2" \
    -e "MJPG1=input_uvc.so -r HD -d /dev/video0" -e "MJPG_PORT1=8081" \
    -e "MJPG2=input_uvc.so -r HD -d /dev/video1" -e "MJPG_PORT2=8082" \
    okmd
```

Your Klipper `printer.cfg` should be kept in the OctoPrint config directory (this is where it looks for it at startup).

If you have any questions, feel free to log an issue on this project, and I'll see if I can help.

## No MJPG

Also included is a cut down Dockerfile with no `mjpg` or OctoPrint plugins included.

This can be built with:
```
docker build . --file Dockerfile.KlipperOctoprint -t ko
```

And run with something like:
```
docker run -d -v /etc/localtime:/etc/localtime:ro -v /home/user/Documents/octoprint-config:/home/octoprint/.octoprint \
    --device /dev/ttyUSB0:/dev/ttyUSB0 \
    -p 5000:5000 \
    ko
```

This is basically untested, but maybe a good start for someone who wants a simpler based container.
