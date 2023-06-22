# o3de-docker

Docker image containing O3DE simulations for Husarion robots. 

## Building

```
docker build -t o3de-husarion .
```

## Running

```
xhost +local:docker

docker run -d \
--name=o3de_rosbot_xl \
--runtime=nvidia \
-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
-e DISPLAY=${DISPLAY} \
-e NVIDIA_VISIBLE_DEVICES=all \
-e NVIDIA_DRIVER_CAPABILITIES=all \
o3de-husarion /data/workspace/ROSbotXLDemo/build/linux/bin/profile/Editor
```

## Docker image

There is also a ready to use [Husarion O3DE Docker image on DockerHub](https://hub.docker.com/r/husarion/o3de/tags)

## Demo

In the [demo](demo/) directory you can find an example application - mapping with Slam Toolbox. 
