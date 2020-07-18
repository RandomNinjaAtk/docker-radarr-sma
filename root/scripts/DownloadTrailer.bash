#!/usr/bin/env bash
apikey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"
RadarrUrl="http://127.0.0.1:7878"
python="python3"
videoformat="--format bestvideo[vcodec*=avc1]+bestaudio[ext=m4a]"
YoutubeDL="/usr/local/bin/youtube-dl"
subtitlelanguage="en"
scriptpath="/config/scripts"

exec &>> "$scriptpath/DownloadTrailer.log"

if [ -f "$scriptpath/cookies.txt" ]; then
	cookies="--cookies $scriptpath/cookies.txt"
else
	cookies=""
fi
radarrid="$radarr_movie_id"
radarrmoviedata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$RadarrUrl/api/movie/$radarrid")"
radarrmoviecredit="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$RadarrUrl/api/v3/credit?movieId=$radarrid")"
radarrmoviedirector="$(echo "${radarrmoviecredit}" | jq -r ".[] | select(.job==\"Director\") | .personName"  | head -n 1)"
radarrmovietitle="$(echo "${radarrmoviedata}" | jq -r ".title")"
radarrmovieyear="$(echo "${radarrmoviedata}" | jq -r ".year")"
radarrmoviepath="$(echo "${radarrmoviedata}" | jq -r ".path")"
radarrmoviegenre="$(echo "${radarrmoviedata}" | jq -r ".genres | .[]" | head -n 1)"
radarrmoviefolder="$(basename "${radarrmoviepath}")"
radarrmoviecertification="$(echo "${radarrmoviedata}" | jq -r ".certification")"
radarrmovieoverview="$(echo "${radarrmoviedata}" | jq -r ".overview")"
radarrmovieostudio="$(echo "${radarrmoviedata}" | jq -r ".studio")"
radarrtrailerid="$(echo "${radarrmoviedata}" | jq -r ".youTubeTrailerId")"
youtubeurl="https://www.youtube.com/watch?v=$radarrtrailerid"
if [ ! -d "$radarrmoviepath" ]; then
    echo "Processing :: $radarrmovietitle :: ERROR: Movie Path does not exist ($radarrmovietitle), Skipping..."
    exit 0
fi
if [ -z "$radarrtrailerid" ]; then
    echo "Processing :: $radarrmovietitle :: ERROR: No Trailer ID Found ($radarrmovietitle), Skipping..."
    exit 0
fi
echo "Processing :: $radarrmovietitle"
if [ -f "$radarrmoviepath/$radarrmoviefolder-trailer.mp4" ]; then
    echo "$radarrmovietitle :: Trailer already Downloaded..."
    exit 0
fi
$python $YoutubeDL ${cookies} -o "$radarrmoviepath/$radarrmoviefolder-trailer" ${videoformat} --write-sub --sub-lang $subtitlelanguage --embed-subs --merge-output-format mp4 --no-mtime --geo-bypass "$youtubeurl" &> /dev/null
if [ -f "$radarrmoviepath/$radarrmoviefolder-trailer.mp4" ]; then   
    echo "Processing :: $radarrmovietitle :: DOWNLOAD :: Complete!"
    ffmpeg -y \
		-i "$radarrmoviepath/$radarrmoviefolder-trailer.mp4" \
		-vframes 1 -an -s 640x360 -ss 30 \
		"$radarrmoviepath/$radarrmoviefolder-trailer.jpg" &> /dev/null
	mv "$radarrmoviepath/$radarrmoviefolder-trailer.mp4" "$radarrmoviepath/temp.mp4"
	ffmpeg -y \
		-i "$radarrmoviepath/temp.mp4" \
		-i "$radarrmoviepath/$radarrmoviefolder-trailer.jpg" \
		-map 0 -map 1 -c copy -c:v:1 jpg -disposition:v:1 attached_pic \
		-c:v copy \
		-c:a copy \
		-c:s copy \
		-metadata title="${radarrmovietitle}" \
		-metadata date="$radarrmovieyear" \
		-metadata genre="$radarrmoviegenre" \
		-movflags +faststart \
		"$radarrmoviepath/$radarrmoviefolder-trailer.mp4" &> /dev/null
	rm "$radarrmoviepath/temp.mp4"
	if [ -f "$radarrmoviepath/$radarrmoviefolder-trailer.jpg" ]; then 
       	rm "$radarrmoviepath/$radarrmoviefolder-trailer.jpg"
	fi
fi
echo "Processing :: $radarrmovietitle :: Complete!"
exit 0
