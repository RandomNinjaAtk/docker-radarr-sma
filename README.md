# [RandomNinjaAtk/radarr-sma](https://github.com/RandomNinjaAtk/docker-radarr-sma)

[Radarr](https://github.com/Radarr/Radarr) - A fork of Sonarr to work with movies à la Couchpotato.


[![radarr](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/radarr.png)](https://github.com/Radarr/Radarr)

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
| latest-vaapi | Radarr Stable releases - latest ffmpeg snapshot with vaapi HW acceleration |
| latest-nvidia | Radarr Stable releases - latest ffmpeg snapshot with nvidia HW acceleration |
| preview | Radarr Aphrodite (V3) releases - latest ffmpeg snapshot |
| preview-vaapi | Radarr Aphrodite (V3) releases - latest ffmpeg snapshot with vaapi HW acceleration |
| preview-nvidia | Radarr Aphrodite (V3) releases - latest ffmpeg snapshot with nvidia HW acceleration |

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 7878` | The port for the Radarr webinterface |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London, this is required for Radarr |
| `-e UMASK_SET=022` | control permissions of files and directories created by Radarr |
| `-v /config` | Database and Radarr configs |
| `-v /storage` | Location of Movie Library and Download managers output directory |

## Application Setup

Access the webui at `<your-ip>:7878`, for more information check out [Radarr](https://radarr.video/).

# Radarr Configuration

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
