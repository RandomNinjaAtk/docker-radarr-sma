#!/usr/bin/env bash
apikey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"
RadarrUrl="http://127.0.0.1:7878"

log () {
    m_time=`date "+%F %T"`
    echo $m_time" "$1
}

if [ $radarr_eventtype == "Test" ]; then
	log "Tested"
	exit 0	
fi

radarrid="$radarr_movie_id"
radarrmoviedata="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$RadarrUrl/api/movie/$radarrid")"
radarrmoviecredit="$(curl -s --header "X-Api-Key:"${apikey} --request GET  "$RadarrUrl/api/v3/credit?movieId=$radarrid")"
radarrmovietitle="$(echo "${radarrmoviedata}" | jq -r ".title")"
radarrmoviepath="$(echo "${radarrmoviedata}" | jq -r ".path")"
nfo="$radarrmoviepath/movie.nfo"
poster="$radarrmoviepath/poster.jpg"
fanart="$radarrmoviepath/fanart.jpg"
log "Processing :: $radarrmovietitle"
if [ -f "$nfo" ]; then
	if cat "$nfo" | grep "NFOWriter" | read; then
		log "Processing :: $radarrmovietitle :: NFO is compliant..."
		exit 0
	fi
	log "Processing :: $radarrmovietitle :: NFO detected, removing..."
	rm "$nfo"
fi
	
radarrmoviesorttitle="$(echo "${radarrmoviedata}" | jq -r ".sortTitle")"
radarrmovieruntime="$(echo "${radarrmoviedata}" | jq -r ".runtime")"
radarrmovieyear="$(echo "${radarrmoviedata}" | jq -r ".year")"
radarrmoviedatecinemas="$(echo "${radarrmoviedata}" | jq -r ".inCinemas")"
radarrmoviepath="$(echo "${radarrmoviedata}" | jq -r ".path")"
radarrmoviecertification="$(echo "${radarrmoviedata}" | jq -r ".certification")"
radarrmovieoverview="$(echo "${radarrmoviedata}" | jq -r ".overview")"
radarrmoviefilename="$(echo "${radarrmoviedata}" | jq -r ".movieFile.relativePath")"
radarrmovieostudio="$(echo "${radarrmoviedata}" | jq -r ".studio")"
OLDIFS="$IFS"
IFS=$'\n'
radarrmoviegenres=($(echo "${radarrmoviedata}" | jq -r ".genres | .[] | ."))
radarrmoviedirectors=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.job==\"Director\") | .personName" | sort -u))
radarrmoviewriters=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.department==\"Writing\") | .personName" | sort -u))
IFS="$OLDIFS"
radarrmoviecast=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.type==\"cast\") | .id"))
radarrmovielocalposter="MediaCover/${radarrid}/poster.jpg"
radarrmovielocalfanart="MediaCover/${radarrid}/fanart.jpg"
radarrmovieposter=$(echo "${radarrmoviedata}" | jq -r ".images[] | select(.coverType==\"poster\") | .remoteUrl")
radarrmoviefanart=$(echo "${radarrmoviedata}" | jq -r ".images[] | select(.coverType==\"fanart\") | .remoteUrl")
radarrmovieimbdid="$(echo "${radarrmoviedata}" | jq -r ".imdbId")"
radarrmovietmdbid="$(echo "${radarrmoviedata}" | jq -r ".tmdbId")"
if [ -f "$nfo" ]; then
	log "Processing :: $radarrmovietitle :: NFO detected, removing..."
	rm "$nfo"
fi
log "Processing :: $radarrmovietitle :: Writing NFO..."
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" >> "$nfo"
echo "<movie>" >> "$nfo"
echo "	<title>$radarrmovietitle</title>" >> "$nfo"
echo "	<sorttitle>$radarrmoviesorttitle</sorttitle>" >> "$nfo"
echo "	<outline>$radarrmovieoverview</outline>" >> "$nfo"
echo "	<plot>$radarrmovieoverview</plot>" >> "$nfo"
echo "	<runtime>$radarrmovieruntime</runtime>" >> "$nfo"
if  [ $radarrmoviecertification == null ]; then
	echo "	<mpaa>NR</mpaa>" >> "$nfo"
else
	echo "	<mpaa>$radarrmoviecertification</mpaa>" >> "$nfo"
fi
echo "	<uniqueid type=\"tmdb\" default=\"true\">$radarrmovietmdbid</uniqueid>" >> "$nfo"
echo "	<uniqueid type=\"imdb\" >$radarrmovieimbdid</uniqueid>" >> "$nfo"
if [ -f "/config/${radarrmovielocalposter}" ]; then
	if [ ! -f "$poster" ]; then
		cp "/config/${radarrmovielocalposter}" "$poster"
	fi
fi
if [ -f "/config/${radarrmovielocalfanart}" ]; then
	if [ ! -f "$fanart" ]; then
		cp "/config/${radarrmovielocalfanart}" "$fanart"
	fi
fi
if [ -f "$poster" ]; then
	echo "	<thumb aspect=\"poster\">poster.jpg</thumb>" >> "$nfo"
else
	echo "	<thumb aspect=\"poster\">$radarrmovieposter</thumb>" >> "$nfo"
fi
echo "	<fanart>" >> "$nfo"
if [ -f "$fanart" ]; then
	echo "	    <thumb>fanart.jpg</thumb>" >> "$nfo"
else
	echo "	    <thumb>$radarrmoviefanart</thumb>" >> "$nfo"
fi
echo "	</fanart>" >> "$nfo"
for genre in ${!radarrmoviegenres[@]}; do
	moviegenre="${radarrmoviegenres[$genre]}"
	echo "	<genre>$moviegenre</genre>" >> "$nfo"
done
for writer in ${!radarrmoviewriters[@]}; do
	name="${radarrmoviewriters[$writer]}"
	echo "	<credits>$name</credits>" >> "$nfo"
done
for director in ${!radarrmoviedirectors[@]}; do
	name="${radarrmoviedirectors[$director]}"
	echo "	<director>$name</director>" >> "$nfo"
done
if  [ $radarrmoviedatecinemas != null ]; then
	echo "	<premiered>${radarrmoviedatecinemas:0:10}</premiered>" >> "$nfo"
fi
echo "	<year>$radarrmovieyear</year>" >> "$nfo"
echo "	<studio>$radarrmovieostudio</studio>" >> "$nfo"
for id in ${!radarrmoviecast[@]}; do
	currentprocessid=$(( $id + 1 ))
	castid="${radarrmoviecast[$id]}"
	name=$(echo "${radarrmoviecredit}" | jq -r ".[] | select(.id==$castid) | .personName")
	order=$(echo "${radarrmoviecredit}" | jq -r ".[] | select(.id==$castid) | .order")
	character=$(echo "${radarrmoviecredit}" | jq -r ".[] | select(.id==$castid) | .character")
	tmdbid=$(echo "${radarrmoviecredit}" | jq -r ".[] | select(.id==$castid) | .personTmdbId")
	thumb=$(echo "${radarrmoviecredit}" | jq -r ".[] | select(.id==$castid) | .images[].url")
	echo "	<actor>" >> "$nfo"
	echo "		<name>$name</name>" >> "$nfo"
	echo "		<role>$character</role>" >> "$nfo"
	echo "		<order>$order</order>" >> "$nfo"
	echo "		<thumb>$thumb</thumb>" >> "$nfo"
	echo "		<tmdbid>$tmdbid</tmdbid>" >> "$nfo"
	echo "	</actor>" >> "$nfo"
done
echo "	<comment>NFOWriter</comment>" >> "$nfo"
echo "</movie>" >> "$nfo"
tidy -w 2000 -i -m -xml "$nfo" &>/dev/null
if [ -f "$nfo" ]; then
	log "Processing :: $radarrmovietitle :: Writing Complete"
fi

exit 0
