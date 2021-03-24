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

WriteNFO () {
	radarrmoviedata="$(curl -s --header "X-Api-Key:"${RadarrAPIkey} --request GET  "$RadarrUrl/api/movie/$radarrid")"
	radarrmoviecredit="$(curl -s --header "X-Api-Key:"${RadarrAPIkey} --request GET  "$RadarrUrl/api/v3/credit?movieId=$radarrid")"
	radarrmovietitle="$(echo "${radarrmoviedata}" | jq -r ".title")"
	radarrmoviepath="$(echo "${radarrmoviedata}" | jq -r ".path")"
	nfo="$radarrmoviepath/movie.nfo"
	poster="$radarrmoviepath/poster.jpg"
	fanart="$radarrmoviepath/fanart.jpg"
	log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle"
	if [ -f "$nfo" ]; then
		if find "$nfo" -name "movie.nfo" -type f -mtime +30 | read; then
			log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle :: NFO detected, removing..."
			rm "$nfo"
		else
			log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle :: Detected NFO doesn't require update..." 
			return
		fi
	fi
	radarrmovieimbdid="$(echo "${radarrmoviedata}" | jq -r ".imdbId")"
	radarrmovietmdbid="$(echo "${radarrmoviedata}" | jq -r ".tmdbId")"
	themoviedbmoviedata=$(curl -s "https://api.themoviedb.org/3/movie/${radarrmovietmdbid}?api_key=${themoviedbapikey}")
	themoviedbmoviesetnull=$(echo "$themoviedbmoviedata" | jq -r ".belongs_to_collection")	
	themoviedbmoviesetids=$(echo "$themoviedbmoviedata" | jq -r ".belongs_to_collection.id")
	tmbdtagline=$(echo "$themoviedbmoviedata" | jq -r ".tagline")	
	radarrmoviesorttitle="$(echo "${radarrmoviedata}" | jq -r ".sortTitle")"
	radarrmovieruntime="$(echo "${radarrmoviedata}" | jq -r ".runtime")"
	radarrmovieyear="$(echo "${radarrmoviedata}" | jq -r ".year")"
	radarrmoviedatecinemas="$(echo "${radarrmoviedata}" | jq -r ".inCinemas")"
	radarrmoviepath="$(echo "${radarrmoviedata}" | jq -r ".path")"
	radarrmoviegenres=($(echo "${radarrmoviedata}" | jq -r ".genres | .[]"))
	radarrmoviecertification="$(echo "${radarrmoviedata}" | jq -r ".certification")"
	radarrmovieoverview="$(echo "${radarrmoviedata}" | jq -r ".overview")"
	radarrmoviefilename="$(echo "${radarrmoviedata}" | jq -r ".movieFile.relativePath")"
	radarrmovieostudio="$(echo "${radarrmoviedata}" | jq -r ".studio")"
	radarrmoviecast=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.type==\"cast\") | .id"))
	OLDIFS="$IFS"
	IFS=$'\n'
	radarrmoviegenres=($(echo "${radarrmoviedata}" | jq -r ".genres | .[] | ."))
	radarrmoviedirectors=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.job==\"Director\") | .personName" | sort -u))
	radarrmoviewriters=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.department==\"Writing\") | .personName" | sort -u))
	IFS="$OLDIFS"
	radarrmovielocalposter="MediaCover/${radarrid}/poster.jpg"
	radarrmovielocalfanart="MediaCover/${radarrid}/fanart.jpg"
	radarrmovieposter=$(echo "${radarrmoviedata}" | jq -r ".images[] | select(.coverType==\"poster\") | .remoteUrl")
	radarrmoviefanart=$(echo "${radarrmoviedata}" | jq -r ".images[] | select(.coverType==\"fanart\") | .remoteUrl")
	
	if [ -f "$nfo" ]; then
		log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle :: NFO detected, removing..."
		rm "$nfo"
	fi
	log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle :: Writing NFO..."
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
	
	if  [ $themoviedbmoviesetids != null ]; then
		tmdbsetid="${themoviedbmoviesetids}"
		tmdbcollectiondata=$(curl -s "https://api.themoviedb.org/3/collection/${tmdbsetid}?api_key=${themoviedbapikey}")
		tmdb_collection_name=$(echo "$tmdbcollectiondata" | jq -r ".name")
		tmdb_collection_overview=$(echo "$tmdbcollectiondata" | jq -r ".overview")
		echo "	<set>" >> "$nfo"
		echo "	    <name>$tmdb_collection_name</name>" >> "$nfo"
		echo "	    <overview>$tmdb_collection_overview</overview>" >> "$nfo"
		echo "	</set>" >> "$nfo"
	fi
	
	if  [ "$tmbdtagline" != "null" ]; then
		echo "	<tag>$tmbdtagline</tag>" >> "$nfo"
	fi
	
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
	echo "</movie>" >> "$nfo"
	tidy -w 2000 -i -m -xml "$nfo" &>/dev/null
	if [ -f "$nfo" ]; then
		log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle :: Writing Complete"
	fi
}

radarrid="$radarr_movie_id"
WriteNFO

exit 0
