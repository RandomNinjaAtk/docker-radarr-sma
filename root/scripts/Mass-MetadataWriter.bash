#!/usr/bin/env bash
RadarrAPIkey="$(grep "<ApiKey>" /config/config.xml | sed "s/\  <ApiKey>//;s/<\/ApiKey>//")"
RadarrUrl="http://127.0.0.1:7878"
themoviedbapikey="3b7751e3179f796565d88fdb2fcdf426"

log () {
	m_time=`date "+%F %T"`
	echo $m_time" ":: $1
}

radarrmovielist=$(curl -s --header "X-Api-Key:"${RadarrAPIkey} --request GET  "$RadarrUrl/api/movie")
radarrmovietotal=$(echo "${radarrmovielist}"  | jq -r '.[] | select(.hasFile==true) | .id' | wc -l)
radarrmovieids=($(echo "${radarrmovielist}" | jq -r '.[] | select(.hasFile==true) | .id'))

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
	themoviedbmoviekeywords=$(curl -s "https://api.themoviedb.org/3/movie/${radarrmovietmdbid}/keywords?api_key=${themoviedbapikey}")
	themoviedbmoviesetnull=$(echo "$themoviedbmoviedata" | jq -r ".belongs_to_collection")
	themoviedbmoviesetids=$(echo "$themoviedbmoviedata" | jq -r ".belongs_to_collection.id")
	themoviedbmovieoriginaltitle=$(echo "$themoviedbmoviedata" | jq -r ".original_title")
	tmbdtagline=$(echo "$themoviedbmoviedata" | jq -r ".tagline")
	tmdb_vote_average=$(echo "$themoviedbmoviedata" | jq -r ".vote_average")
	tmdb_vote_count=$(echo "$themoviedbmoviedata" | jq -r ".vote_count")
	tmdb_poster_path=$(echo "$themoviedbmoviedata" | jq -r ".poster_path")
	tmdb_backdrop_path=$(echo "$themoviedbmoviedata" | jq -r ".backdrop_path")
	radarrmoviesorttitle="$(echo "${radarrmoviedata}" | jq -r ".sortTitle")"
	radarrmovieruntime="$(echo "${radarrmoviedata}" | jq -r ".runtime")"
	radarrmovieyear="$(echo "${radarrmoviedata}" | jq -r ".year")"
	radarrmoviedatecinemas="$(echo "${radarrmoviedata}" | jq -r ".inCinemas")"
	radarrmoviepath="$(echo "${radarrmoviedata}" | jq -r ".path")"
	radarrmoviegenres=($(echo "${radarrmoviedata}" | jq -r ".genres | .[]"))
	radarrmoviecertification="$(echo "${radarrmoviedata}" | jq -r ".certification")"
	radarrmovieoverview="$(echo "${radarrmoviedata}" | jq -r ".overview")"
	radarrmoviefilename="$(echo "${radarrmoviedata}" | jq -r ".movieFile.relativePath")"
	radarr_youTubeTrailerId="$(echo "${radarrmoviedata}" | jq -r ".youTubeTrailerId")"
	radarrmoviecast=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.type==\"cast\") | .id"))
	OLDIFS="$IFS"
	IFS=$'\n'
	radarrmoviestudios=($(echo "${themoviedbmoviedata}" | jq -r ".production_companies[].name"))
	radarrmoviecountries=($(echo "${themoviedbmoviedata}" | jq -r ".production_countries[].name"))
	tmdb_keywords_names=($(echo "$themoviedbmoviekeywords" | jq -r ".keywords[].name"))
	radarrmoviegenres=($(echo "${themoviedbmoviedata}" | jq -r ".genres[].name"))
	radarrmoviedirectors=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.job==\"Director\") | .personName" | sort -u))
	radarrmoviewriters=($(echo "${radarrmoviecredit}" | jq -r ".[] | select(.department==\"Writing\") | .personName" | sort -u))
	IFS="$OLDIFS"

	if [ -f "$nfo" ]; then
		log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle :: NFO detected, removing..."
		rm "$nfo"
	fi
	log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle :: Writing NFO..."
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>" >> "$nfo"
	echo "<movie>" >> "$nfo"
	echo "	<title>$radarrmovietitle</title>" >> "$nfo"
	echo "	<originaltitle>$themoviedbmovieoriginaltitle</originaltitle>" >> "$nfo"
	echo "	<sorttitle>$radarrmoviesorttitle</sorttitle>" >> "$nfo"
	echo "	<ratings>" >> "$nfo"
	echo "	    <rating name=\"themoviedb\" max=\"10\" default=\"true\">" >> "$nfo"
	echo "	    	<value>$tmdb_vote_average</value>" >> "$nfo"
	echo "	    	<votes>$tmdb_vote_count</votes>" >> "$nfo"
	echo "		</rating>" >> "$nfo"
	echo "	</ratings>" >> "$nfo"
	echo "	<outline>$radarrmovieoverview</outline>" >> "$nfo"
	echo "	<plot>$radarrmovieoverview</plot>" >> "$nfo"
	if  [ "$tmbdtagline" != "null" ]; then
		echo "	<tagline>$tmbdtagline</tagline>" >> "$nfo"
	fi
	echo "	<runtime>$radarrmovieruntime</runtime>" >> "$nfo"
	if  [ $radarrmoviecertification == null ]; then
		echo "	<mpaa>NR</mpaa>" >> "$nfo"
	else
		echo "	<mpaa>$radarrmoviecertification</mpaa>" >> "$nfo"
	fi
	echo "	<playcount/>" >> "$nfo"
	echo "	<lastplayed/>" >> "$nfo"
	echo "	<id>$radarrmovieimbdid</id>" >> "$nfo"
	echo "	<tmdbid>$radarrmovietmdbid</tmdbid>" >> "$nfo"
	if  [ $themoviedbmoviesetids != null ]; then
		echo "	<tmdbCollectionId>$themoviedbmoviesetids</tmdbCollectionId>" >> "$nfo"
	fi
	echo "	<uniqueid type=\"imdb\" default=\"true\">$radarrmovieimbdid</uniqueid>" >> "$nfo"
	echo "	<uniqueid type=\"tmdb\" default=\"false\">$radarrmovietmdbid</uniqueid>" >> "$nfo"
	if [ "$tmdb_poster_path" != "null" ]; then
		echo "	<thumb aspect=\"poster\">https://image.tmdb.org/t/p/original$tmdb_poster_path</thumb>" >> "$nfo"
	else
		echo "	<thumb/>" >> "$nfo"
	fi
	echo "	<fanart>" >> "$nfo"
	if [ "$tmdb_backdrop_path" != "null" ]; then
		echo "	    <thumb>https://image.tmdb.org/t/p/original$tmdb_backdrop_path</thumb>" >> "$nfo"
	else
		echo "	    <thumb/>" >> "$nfo"
	fi
	echo "	</fanart>" >> "$nfo"
	for genre in ${!radarrmoviegenres[@]}; do
		moviegenre="${radarrmoviegenres[$genre]}"
		echo "	<genre>$moviegenre</genre>" >> "$nfo"
	done
	if [ ! -z "$radarrmoviecountries" ]; then
		for country in ${!radarrmoviecountries[@]}; do
			name="${radarrmoviecountries[$country]}"
			echo "	<country>$name</country>" >> "$nfo"
		done
	else
		echo "	<country/>" >> "$nfo"
	fi
	# if  [ $themoviedbmoviesetids != null ]; then
	#	tmdbsetid="${themoviedbmoviesetids}"
	#	tmdbcollectiondata=$(curl -s "https://api.themoviedb.org/3/collection/${tmdbsetid}?api_key=${themoviedbapikey}")
	#	tmdb_collection_name=$(echo "$tmdbcollectiondata" | jq -r ".name")
	#	tmdb_collection_overview=$(echo "$tmdbcollectiondata" | jq -r ".overview")
	#	tmdb_collection_poster_path=$(echo "$tmdbcollectiondata" | jq -r ".poster_path")
	#	tmdb_collection_backdrop_path=$(echo "$tmdbcollectiondata" | jq -r ".backdrop_path")
	#	echo "	<set>" >> "$nfo"
	#	echo "	    <name>$tmdb_collection_name</name>" >> "$nfo"
	#	echo "	    <overview>$tmdb_collection_overview</overview>" >> "$nfo"
	#	echo "	</set>" >> "$nfo"
	# fi
	if [ ! -z "$tmdb_keywords_names" ]; then
		for keyword in ${!tmdb_keywords_names[@]}; do
			name="${tmdb_keywords_names[$keyword]}"
			echo "	<tag>$name</tag>" >> "$nfo"
		done
	else
		echo "	<tag/>" >> "$nfo"
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
	if [ ! -z "$radarrmoviestudios" ]; then
		for studio in ${!radarrmoviestudios[@]}; do
			name="${radarrmoviestudios[$studio]}"
			echo "	<studio>$name</studio>" >> "$nfo"
		done
	else
		echo "	<studio/>" >> "$nfo"
	fi
	if [ ! -z "$radarr_youTubeTrailerId" ]; then
		echo "	<trailer>https://www.youtube.com/watch?v=${radarr_youTubeTrailerId}</trailer>" >> "$nfo"
	else
		echo "	<trailer/>" >> "$nfo"
	fi
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
		if [ ! -z "$thumb" ]; then
			echo "		<thumb>$thumb</thumb>" >> "$nfo"
		else
			echo "		<thumb/>" >> "$nfo"
		fi
		echo "		<profile>https://www.themoviedb.org/person/$tmdbid</profile>" >> "$nfo"
		echo "		<tmdbid>$tmdbid</tmdbid>" >> "$nfo"
		echo "	</actor>" >> "$nfo"
	done
	echo "</movie>" >> "$nfo"
	tidy -w 2000 -i -m -xml "$nfo" &>/dev/null
	if [ -f "$nfo" ]; then
		log "Processing $mainprocessid of $radarrmovietotal :: $radarrmovietitle :: Writing Complete"
	fi
}

log "############## NFO Writer"
for id in ${!radarrmovieids[@]}; do
	mainprocessid=$(( $id + 1 ))
	radarrid="${radarrmovieids[$id]}"
	WriteNFO
done

exit 0
