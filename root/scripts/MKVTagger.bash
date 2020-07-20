#!/usr/bin/env bash
apikey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"
RadarrUrl="http://127.0.0.1:7878"
scriptpath="/config/scripts"
sleep 5
exec &>> "$scriptpath/MKVTagger.log"

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
radarrmoviefilename="$(echo "${radarrmoviedata}" | jq -r ".movieFile.relativePath")"
radarrmovieostudio="$(echo "${radarrmoviedata}" | jq -r ".studio")"
radarrtrailerid="$(echo "${radarrmoviedata}" | jq -r ".youTubeTrailerId")"
youtubeurl="https://www.youtube.com/watch?v=$radarrtrailerid"
if [ ! -d "$radarrmoviepath" ]; then
    echo "Processing :: $radarrmovietitle :: ERROR: Movie Path does not exist ($radarrmovietitle), Skipping..."
    exit 0
fi
if [ ${radarrmoviefilename: -4} == ".mkv" ]; then
	echo "Processing :: $radarrmovietitle :: $radarrmoviefilename"
	mv "$radarrmoviepath/$radarrmoviefilename" "$radarrmoviepath/temp.mkv"
	if [ -f "/config/MediaCover/$radarrid/poster.jpg" ]; then
		cp "/config/MediaCover/$radarrid/poster.jpg" "$radarrmoviepath/cover.jpg"
		ffmpeg -y \
			-i "$radarrmoviepath/temp.mkv" \
			-c:v copy \
			-c:a copy \
			-c:s copy \
			-metadata TITLE="${radarrmovietitle}" \
			-metadata DATE_RELEASE="$radarrmovieyear" \
			-metadata DATE="$radarrmovieyear" \
			-metadata YEAR="$radarrmovieyear" \
			-metadata GENRE="$radarrmoviegenre" \
			-metadata COPYRIGHT="$radarrmovieostudio" \
			-metadata COMMENT="$radarrmovieoverview" \
			-metadata DIRECTOR="$radarrmoviedirector" \
			-attach "$radarrmoviepath/cover.jpg" -metadata:s:t mimetype=image/jpeg \
		"$radarrmoviepath/$radarrmoviefilename" &> /dev/null
	else
		ffmpeg -y \
			-i "$radarrmoviepath/temp.mkv" \
			-c:v copy \
			-c:a copy \
			-c:s copy \
			-metadata TITLE="${radarrmovietitle}" \
			-metadata DATE_RELEASE="$radarrmovieyear" \
			-metadata DATE="$radarrmovieyear" \
			-metadata YEAR="$radarrmovieyear" \
			-metadata GENRE="$radarrmoviegenre" \
			-metadata COPYRIGHT="$radarrmovieostudio" \
			-metadata COMMENT="$radarrmovieoverview" \
			-metadata DIRECTOR="$radarrmoviedirector" \
		"$radarrmoviepath/$radarrmoviefilename" &> /dev/null
	fi
	if [ -f "$radarrmoviepath/$radarrmoviefilename" ]; then
		if [ -f "$radarrmoviepath/temp.mkv" ]; then
			rm "$radarrmoviepath/temp.mkv"
		fi
		if [ -f "$radarrmoviepath/cover.jpg" ]; then
			rm "$radarrmoviepath/cover.jpg"
		fi
		echo "Processing :: $radarrmovietitle :: Updating File Statistics"
		mkvpropedit "$radarrmoviepath/$radarrmoviefilename" --add-track-statistics-tags &> /dev/null
		echo "Processing :: $radarrmovietitle :: Complete!"
	else
		echo "Processing :: $radarrmovietitle :: Failed!"
		mv "$radarrmoviepath/temp.mkv" "$radarrmoviepath/$radarrmoviefilename"
	fi
fi
exit 0
