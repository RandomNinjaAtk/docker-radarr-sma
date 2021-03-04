#!/usr/bin/env bash
exec &>> "/config/scripts/sma.log"
if [ $radarr_eventtype == "Test" ]; then
	echo "Tested"
	exit 0	
fi

extension="${radarr_moviefile_path##*.}"

if [ "$extension" == "mp4" ]; then
	echo "================================================================================================================"
	echo "Processing Event: $radarr_eventtype"
	echo "Title: $radarr_movie_title ($radarr_movie_year)"
	echo "TMDB: $radarr_movie_tmdbid"
	echo "File: $radarr_moviefile_path"
	echo "Sending to SMA..."
	echo "================================================================================================================"

	if [ ! -f "$radarr_moviefile_path" ]; then
		echo "file not found sleeping..."
		sleep 2
	fi
	
	if [ -f /usr/local/sma/config/sma.log ]; then
		rm /usr/local/sma/config/sma.log
	fi
	
	if [ -f "/config/scripts/sma.ini" ]; then
		smaconfig="/config/scripts/sma.ini"
	else
		echo "error, no config found"
		exit 0
	fi
	# Manual run of Sickbeard MP4 Automator
	python3 /usr/local/sma/manual.py --config "$smaconfig" -i "$radarr_moviefile_path" -a -tmdb $radarr_movie_tmdbid
	echo "================================================================================================================"
	echo "DONE"
	echo "================================================================================================================"
fi

exit $?