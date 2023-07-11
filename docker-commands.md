```
docker ps
```

lists active docker containers. Use 
* `-a` show all containers (active or inactive). 
* `-n5` show last 5 containers (active or inactive)

```
docker images
```
lists the docker images downloaded on the machine

```
docker run -p 5000:8000 --name myContainerName --restart=always imageId
```
runs a docker image. The imageId could be something like 9c7a54a9a43c or a public image like hello-world, node, or ubuntu
* `-p 5000:8000` maps the host's port 5000 to the container's port 8000. Can be done multiple times
* `-d` run in background
* `--name myContainerName` specifies the container's name. Otherwise it gets ab auto-generated name
* `--restart=always` starts when docker daemon starts 
* `-it` interactive and Allocate a pseudo-TTY


```
docker build -t myImageName path/to/DockerFile
```
creates a new image based on a docker file


```
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /docker/data/portainer:/data portainer/portainer-ce:latest
```
installs portainer


```
docker compose up -d
```
runs all containers specified in docker-compose. But requires the plugin which I struggle to install

```
docker run -d \
  --name homeassistant \
  --privileged \
  --restart=unless-stopped \
  -e TZ=America/Chicago \
  -v /dockerconfig/homeassistant:/config \
  --network=host \
  homeassistant/home-assistant:latest
```
installs home assistant

```
version: '3'
services:
  homeassistant:
    container_name: home-assistant
    image: homeassistant/home-assistant:latest
    volumes:
      - /dockerconfig/homeassistant:/config
      - /etc/localtime:/etc/localtime:ro
    restart: always
    privileged: true
    network_mode: host
    environment:
      - TZ=America/Chicago
  mosquitto:
    image: eclipse-mosquitto
    container_name: mosquitto
    volumes:
      - /dockerconfig/mosquitto:/mosquitto
    ports:
      - 1883:1883
      - 9001:9001
  frigate:
    container_name: frigate
    privileged: true # this may not be necessary for all setups
    restart: always
    image: ghcr.io/blakeblackshear/frigate:stable
    shm_size: "64mb" # update for your cameras based on calculation above
    devices:
      - /dev/apex_0:/dev/apex_0
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /docker/config/frigate/config.yml:/config/config.yml
      - /docker/data:/media/frigate
      - type: tmpfs # Optional: 1GB of memory, reduces SSD/SD Card wear
        target: /tmp/cache
        tmpfs:
          size: 1000000000
    ports:
      - "5000:5000"
      - "8554:8554" # RTSP feeds
      - "8555:8555/tcp" # WebRTC over tcp
      - "8555:8555/udp" # WebRTC over udp
    environment:
      FRIGATE_RTSP_PASSWORD: "password"
```
my docker-compose for my portainer stack