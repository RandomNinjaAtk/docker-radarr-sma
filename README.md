# [RandomNinjaAtk/radarr-sma](https://github.com/RandomNinjaAtk/docker-radarr-sma)


This containers base image is provided by: [mdhiggins/radarr-sma](https://github.com/mdhiggins/radarr-sma)


## Supported Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |

## Version Tags

| Tag | Description |
| :----: | --- |
| latest | Radarr Stable releases - latest ffmpeg snapshot |
| preview | Radarr Preview releases - latest ffmpeg snapshot |

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

## Application Setup

Access the webui at `<your-ip>:7878`, for more information check out [Radarr](https://radarr.video/).

# Sonarr Configuration

### Enable completed download handling
* Settings -> Download Client -> Completed Download Handling -> Enable: Yes

### Add Custom Script
* Settings -> Connect -> + Add -> custom Script

| Parameter | Value |
| --- | --- |
| On Grab | No |
| On Import | Yes |
| On Upgrade | Yes |
| On Rename | No |
| On Health Issue | No |
| Tags | leave blank |
| Path | `/usr/local/sma/postRadarr.sh` |

# SMA Information:

### Config Location
Located at `/config/sma/autoProcess.ini` inside the container

### Log Information
Located at `/config/sma/index.log` inside the container
