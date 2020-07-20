#!/usr/bin/env bash
apikey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"
RadarrUrl="http://127.0.0.1:7878"
python="python3"
videoformat="--format bestvideo[vcodec*=avc1]+bestaudio[ext=m4a]"
YoutubeDL="/usr/local/bin/youtube-dl"
subtitlelanguage="en"
scriptpath="/config/scripts"
sleep 5
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
if [ -f "$radarrmoviepath/$radarrmoviefolder-trailer.mkv" ]; then
    echo "$radarrmovietitle :: Trailer already Downloaded..."
    exit 0
fi
echo "Processing :: $radarrmovietitle :: DOWNLOAD :: Sending to youtube-dl"
echo "========================START YOUTUBE-DL========================"
$python $YoutubeDL ${cookies} -o "$radarrmoviepath/$radarrmoviefolder-trailer" ${videoformat} --write-sub --sub-lang $subtitlelanguage --embed-subs --merge-output-format mkv --no-mtime --geo-bypass "$youtubeurl"
echo "========================STOP YOUTUBE-DL========================="
if [ -f "$radarrmoviepath/$radarrmoviefolder-trailer.mkv" ]; then   
	echo "Processing :: $radarrmovietitle :: TRAILER DOWNLOAD :: Complete!"
	echo "Processing :: $radarrmovietitle :: TRAILER :: Extracting thumbnail with ffmpeg..."
	echo "========================START FFMPEG========================"
	ffmpeg -y \
		-i "$radarrmoviepath/$radarrmoviefolder-trailer.mkv" \
		-vframes 1 -an -s 640x360 -ss 30 \
		"$radarrmoviepath/cover.jpg"
	echo "========================STOP FFMPEG========================="
	echo "Processing :: $radarrmovietitle :: TRAILER :: Embedding metadata with ffmpeg..."
	echo "========================START FFMPEG========================"
	mv "$radarrmoviepath/$radarrmoviefolder-trailer.mkv" "$radarrmoviepath/temp.mkv"
	ffmpeg -y \
		-i "$radarrmoviepath/temp.mkv" \
		-c copy \
		-metadata TITLE="${radarrmovietitle}" \
		-metadata DATE_RELEASE="$radarrmovieyear" \
		-metadata DATE="$radarrmovieyear" \
		-metadata YEAR="$radarrmovieyear" \
		-metadata GENRE="$radarrmoviegenre" \
		-metadata COPYRIGHT="$radarrmovieostudio" \
		-attach "$radarrmoviepath/cover.jpg" -metadata:s:t mimetype=image/jpeg \
		"$radarrmoviepath/$radarrmoviefolder-trailer.mkv"
	echo "========================STOP FFMPEG========================="
	if [ -f "$radarrmoviepath/$radarrmoviefolder-trailer.mkv" ]; then   
		echo "Processing :: $radarrmovietitle :: TRAILER :: Metadata Embedding Complete!"
		if [ -f "$radarrmoviepath/temp.mkv" ]; then   
			rm "$radarrmoviepath/temp.mkv"
		fi
	else
		echo "Processing :: $radarrmovietitle :: TRAILER :: ERROR: Metadata Embedding Failed!"
		mv "$radarrmoviepath/temp.mkv" "$radarrmoviepath/$radarrmoviefolder-trailer.mkv"
	fi
	if [ -f "$radarrmoviepath/cover.jpg" ]; then 
		rm "$radarrmoviepath/cover.jpg"
	fi
	echo "Processing :: $radarrmovietitle :: Updating File Statistics via mkvtoolnix (mkvpropedit)..."
	echo "========================START MKVPROPEDIT========================"
	mkvpropedit "$radarrmoviepath/$radarrmoviefolder-trailer.mkv" --add-track-statistics-tags
	echo "========================STOP MKVPROPEDIT========================="
	if [ -f "$radarrmoviepath/$radarrmoviefolder-trailer.mp4" ]; then
		rm "$radarrmoviepath/$radarrmoviefolder-trailer.mp4"
	fi
	echo "Processing :: $radarrmovietitle :: Complete!"
else
	echo "Processing :: $radarrmovietitle :: TRAILER DOWNLOAD :: ERROR :: Skipping..."
fi

exit 0
