#!/usr/bin/with-contenv bash

# create config directory
if [ ! -d "/config/sma" ]; then
	mkdir -p "/config/sma" && \
	chmod 0777 -R "/config/sma"
fi

# import new config, if does not exist
if [ ! -f "/config/sma/autoProcess.ini" ]; then
	cp "/usr/local/sma/config/autoProcess.ini.sample" "/config/sma/autoProcess.ini"
fi

# link config file for use
if [ ! -f "/usr/local/sma/config/autoProcess.ini" ]; then
	ln -s "/config/sma/autoProcess.ini" "/usr/local/sma/config/autoProcess.ini"
fi

# remove sickbeard_mp4_automator log if exists
if [ -f "/var/log/sickbeard_mp4_automator/index.log" ]; then
	rm "/var/log/sickbeard_mp4_automator/index.log"
fi

# remove sickbeard_mp4_automator log from sma config folder if exists
if [ -f "/config/sma/index.log" ]; then
	rm "/config/sma/index.log"
fi

# create sma log file
touch "/config/sma/index.log" && \

# link sma log file
ln -s "/config/sma/index.log" "/var/log/sickbeard_mp4_automator/index.log" && \

# set permissions
chmod 0666 "/config/sma"/*

exit 0
