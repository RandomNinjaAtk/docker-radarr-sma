#!/usr/bin/with-contenv bash

# Remove exisitng
if [ -d "/usr/local/sma/config" ]; then
	rm -rf /usr/local/sma/config/* && \
	sleep 0.1
fi

# create config directory
if [ ! -d "/config/sma" ]; then
	mkdir -p "/config/sma" && \
	chmod 0777 -R "/config/sma"
fi

# import new config, if does not exist
if [ ! -f "/config/sma/autoProcess.ini" ]; then
	cp "/usr/local/sma/setup/autoProcess.ini.sample" "/config/sma/autoProcess.ini" && \
	bash "/scripts/update.bash"
fi

# create sma log file
touch "/config/sma/sma.log" && \

# link sma config/log file
ln -s "/config/sma/sma.log" "/usr/local/sma/config/sma.log" && \
ln -s "/config/sma/autoProcess.ini" "/usr/local/sma/config/autoProcess.ini" && \

# set permissions
chmod 0666 "/config/sma"/*
chmod 0777 -R "/usr/local/sma"
chmod 0777 -R "/scripts"

exit $?
