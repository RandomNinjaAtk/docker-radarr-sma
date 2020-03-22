# [RandomNinjaAtk/radarr-sma](https://github.com/RandomNinjaAtk/docker-radarr-sma)

[Radarr](https://github.com/Radarr/Radarr) - A fork of Sonarr to work with movies à la Couchpotato.


[![radarr](https://raw.githubusercontent.com/RandomNinjaAtk/unraid-templates/master/randomninjaatk/img/radarr.png)](https://github.com/Radarr/Radarr)

This containers base image is provided by: [mdhiggins/radarr-sma](https://github.com/mdhiggins/radarr-sma)


## Supported Architectures

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |

## Version Tags

| Tag | Description |
| :----: | --- |
| latest | Radarr Stable releases - latest ffmpeg (vaapi) |
| latest-nvidia | Radarr Stable releases - latest ffmpeg (nvidia) |
| preview | Radarr Aphrodite (V3) releases - latest ffmpeg (vaapi) |
| preview-nvidia | Radarr Aphrodite (V3) releases - latest ffmpeg (nvidia) |

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
| `-e UPDATE_SMA="FALSE"` | TRUE = enabled :: Update SMA on container startup |
| `-e CONVERTER_THREADS="0"` | FFMpeg threads, corresponds to threads parameter |
| `-e CONVERTER_OUTPUT_FORMAT="mkv"` | Wrapped format corresponding to -f in FFmpeg |
| `-e CONVERTER_OUTPUT_EXTENSION="mkv"` | File extension for created media |
| `-e CONVERTER_SORT_STREAMS="True"` | Sort streams by language preferences and channels |
| `-e CONVERTER_PROCESS_SAME_EXTENSIONS="False"` | Run files with the same input and output extensions through the conversion process. Tagging is not effected. If after options are generated all streams are copy conversion will be skipped. Use with caution alongside universal audio and audio copy-original as tracks will keep replicating |
| `-e CONVERTER_FORCE_CONVERT="False"` | Force conversion regardless of streams being in appropriate format |
| `-e CONVERTER_PREOPTS=""` | Additional comma separated FFmpeg options placed before main commands |
| `-e CONVERTER_POSTOPTS=""` | Additional comma separated FFmpeg options placed after main commands |
| `-e PERMISSIONS_CHMOD="0666"` | Base 8 chmod value |
| `-e METADATA_RELOCATE_MOV="FALSE"` | Relocate MOOV atom using QTFastStart. MP4 only |
| `-e METADATA_TAG="False"` | Tag files with metadata from TMDB. MP4 only |
| `-e METADATA_TAG_LANGUAGE="eng"` | Tag language |
| `-e METADATA_DOWNLOAD_ARTWORK="thumb"` | Download artwork and embed in media. poster, thumb, True, False are valid options |
| `-e METADATA_PRESERVE_SOURCE_DISPOSITION="False"` | Maintain disposition elements from source file, set False to have the script set defaults based on sorting and preferences |
| `-e VIDEO_CODEC="h264, x264"` | Approved video codecs. Codecs not on this list are converted to the first codec on the list |
| `-e VIDEO_BITRATE="0"` | Maximum bitrate for video in Kb. Values above this range will be down sampled. 0 for no limit |
| `-e VIDEO_CRF="-1"` | CRF value, -1 to disable |
| `-e VIDEO_CRF_PROFILES=""` | See script website: https://github.com/mdhiggins/sickbeard_mp4_automator/wiki/AutoProcess-Settings |
| `-e VIDEO_MAX_WIDTH="0"` | Maximum video width, videos larger will be down sized |
| `-e VIDEO_PROFILE=""` | Video profile |
| `-e VIDEO_MAX_LEVEL="4.1"` | Maximum video level, videos above will be down sampled. Format example is 4.1 |
| `-e VIDEO_PIX_FMT=""` | Supported pix-fmt list. Formats not on this list are be converted to the first format on the list |
| `-e AUDIO_CODEC="libfdk_aac, aac, mp3, opus"` | Approved audio codecs. Codecs not on this list are converted to the first codec on the list |
| `-e AUDIO_LANGUAGES="eng"` | Approved audio stream languages. Languages not on this list will not be used. Leave blank to approve all languages |
| `-e AUDIO_DEFAULT_LANGUAGE="eng"` | If audio stream language is undefined, assumed this language |
| `-e AUDIO_FIRST_STREAM_OF_LANGUAGE="False"` | Only include the first occurrence of an audio stream of language |
| `-e AUDIO_CHANNEL_BITRATE="64"` | Bitrate of audio stream per channel. Multiple by number of channels to get stream bitrate. Use 0 to attempt to guess based on source bitrate |
| `-e AUDIO_MAX_BITRATE="0"` | Maximum audio stream bitrate regardless of channels. 0 for no limit |
| `-e AUDIO_MAX_CHANNELS="0"` | Maximum number of audio channels per stream. Streams with more channels will be down sampled |
| `-e AUDIO_PREFER_MORE_CHANNELS="True"` | When sorting source audio streams, prefer higher channel counts |
| `-e AUDIO_DEFAULT_MORE_CHANNELS="True"` | When setting default audio stream, prefer higher channel counts |
| `-e AUDIO_FILTER=""` | FFmpeg audio filter. Setting this will not allow copying audio streams |
| `-e AUDIO_SAMPLE_RATES=""` | Approved audio sample rates, rates not on the approved list will be converted to the first rate on the list |
| `-e AUDIO_COPY_ORIGINAL="True"` | Always include a copy of the original audio stream |
| `-e AUDIO_AAC_ADTSTOASC="False"` |  |
| `-e AUDIO_IGNORE_TREHD="mp4, m4v"` | Ignore trueHD audio streams for specific extensions (Not supported in MP4 containers). Leave blank to disable |
| `-e UAUDIO_CODEC=""libfdk_aac, aac, mp3"` | Approved audio codecs. Codecs not on this list are converted to the first codec on the list |
| `-e UAUDIO_CHANNEL_BITRATE="80"` |  Bitrate of universal audio stream per channel. Multiple by number of channels to get stream bitrate. Use 0 to attempt to guess based on source bitrate |
| `-e UAUDIO_FIRST_STREAM_ONLY="True"` | Only create a universal audio stream for the first audio stream encountered |
| `-e UAUDIO_MOVE_AFTER="True"` | Move universal audio stream after the source stream |
| `-e UAUDIO_FILTER=""` | FFmpeg audio filter. Setting this will not allow copying audio streams |
| `-e SUBTITLE_CODEC="srt"` | Approved subtitle codecs. Codecs not on this list are converted to the first codec on the list |
| `-e SUBTITLE_CODEC_IMAGE_BASED=""` | Approved image-based subtitle codecs. Codecs not on this list are converted to the first codec on the list |
| `-e SUBTITLE_LANGUAGES="eng"` | Approved subtitle stream languages. Languages not on this list will not be used. Leave blank to approve all languages |
| `-e SUBTITLE_DEFAULT_LANGUAGE="eng"` | If subtitle stream language is undefined, assumed this language |
| `-e SUBTITLE_FIRST_STREAM_OF_LANGUAGE="False"` | Only include the first occurrence of a subtitle stream of language |
| `-e SUBTITLE_ENCODING=""` | Subtitle encoding format |
| `-e SUBTITLE_BURN_SUBTITLES="False"` | Burns subtitles onto video stream. Valid parameters are true / any, false, default, forced, default, forced. If a valid subtitle for burning is found this will force the video stream to be encoded (cannot copy). Internal subtitles are prioritized over external subtitles. This feature does not support image based subtitle formats |
| `-e SUBTITLE_DOWNLOAD_SUBS="False"` | Attempt to download subtitles of your specified languages automatically using subliminal |
| `-e SUBTITLE_DOWNLOAD_HEARING_IMPAIRED_SUBS="False"` | Download hearing impaired subtitles using subliminal |
| `-e SUBTITLE_DOWNLOAD_PROVIDERS=""` | Subliminal providers, leave blank to use default providers |
| `-e SUBTITLE_EMBED_SUBS="True"` | Embeds text based subtitles in the output video. External subtitles in the same directory will embedded. If false subtitles will be extracted |
| `-e SUBTITLE_EMBED_IMAGE_SUBS="False"` | Embed image based subtitles in the output video. Ensure you are using a container that supports image based subtitles |
| `-e SUBTITLE_EMBED_ONLY_INTERNAL_SUBS="False"` | Limit embedding subtitles to only subs embedded in the source file |
| `-e SUBTITLE_IGNORE_EMBEDDED_SUBS="True"` | Ignore sub streams included in source file, external sources will still be processed |
| `-e SUBTITLE_ATTACHMENT_CODEC=""` | Approved codecs for attachments. Useful for fonts included with source file |
| `-e PLEX_HOST="localhost"` | Host |
| `-e PLEX_PORT="32400"` | Port |
| `-e PLEX_REFRESH="False"` | Refresh |
| `-e PLEX_TOKEN=""` | Plex Home Token |

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
| Path | `/scripts/postRadarr.sh` |

# SMA Information:

### Log Information
Located at `/config/sma/sma.log` inside the container

### Hardware Acceleration

1. Set "SMA: Video: codec" to: `h264vaapi` or `h265vaapi`
1. Make sure you have passed the correct device to the container, or these will not work...
