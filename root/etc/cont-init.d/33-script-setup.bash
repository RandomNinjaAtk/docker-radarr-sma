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

# Remove existing script
if [ -f "/config/scripts/SMA.bash" ]; then
	rm "/config/scripts/SMA.bash"
fi

# import script
if [ ! -f "/config/scripts/SMA.bash" ]; then
	cp "/scripts/SMA.bash" "/config/scripts/SMA.bash"
fi

# Remove existing script
if [ -f "/config/scripts/MKVTagger.bash" ]; then
	rm "/config/scripts/MKVTagger.bash"
fi

# import script
if [ ! -f "/config/scripts/MKVTagger.bash" ]; then
	cp "/scripts/MKVTagger.bash" "/config/scripts/MKVTagger.bash"
fi

# Remove existing script
if [ -f "/config/scripts/MetadataWriter.bash" ]; then
	rm "/config/scripts/MetadataWriter.bash"
fi

# import script
if [ ! -f "/config/scripts/MetadataWriter.bash" ]; then
	cp "/scripts/MetadataWriter.bash" "/config/scripts/MetadataWriter.bash"
fi

# Remove existing script
if [ -f "/config/scripts/Mass-MetadataWriter.bash" ]; then
	rm "/config/scripts/Mass-MetadataWriter.bash"
fi

# import script
if [ ! -f "/config/scripts/Mass-MetadataWriter.bash" ]; then
	cp "/scripts/Mass-MetadataWriter.bash" "/config/scripts/Mass-MetadataWriter.bash"
fi

# set permissions
chmod 0777 -R "/config/scripts"

exit $?
