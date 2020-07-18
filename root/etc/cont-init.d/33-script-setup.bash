#!/usr/bin/with-contenv bash

# Create Scripts Directory
if [ ! -d "/config/scripts" ]; then
	mkdir "/config/scripts"
fi

# Remove existing script
if [ -f "/config/scripts/DownloadTrailer.bash" ]; then
	rm "/config/scripts/DownloadTrailer.bash"
fi

# import script
if [ ! -f "/config/scripts/DownloadTrailer.bash" ]; then
	cp "/scripts/DownloadTrailer.bash" "/config/scripts/DownloadTrailer.bash"
fi

# set permissions
chmod 0777 -R "/config/scripts"

exit $?
