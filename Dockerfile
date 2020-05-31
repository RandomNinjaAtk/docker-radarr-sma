FROM linuxserver/radarr:latest
LABEL maintainer="RandomNinjaAtk"

ENV SMA_PATH /usr/local/sma
ENV UPDATE_SMA FALSE
ENV SMA_APP Radarr

RUN \
	echo "************ install dependencies ************" && \
	echo "************ add repos for updated ffmpeg ************" && \
	apt-get update -qq && \
	apt-get install -y software-properties-common && \
	apt-get update -qq && \
	add-apt-repository ppa:savoury1/graphics -y && \
	add-apt-repository ppa:savoury1/multimedia -y && \
	add-apt-repository ppa:savoury1/ffmpeg4 -y && \
	echo "************ install packages ************" && \
	apt-get update -qq && \
	apt-get install -qq -y \
		git \
		wget \
		python3 \
		python3-pip \
		ffmpeg \
		cron && \
	apt-get purge --auto-remove -y && \
	apt-get clean && \
	echo "************ setup SMA ************" && \
	echo "************ setup directory ************" && \
	mkdir -p ${SMA_PATH} && \
	echo "************ download repo ************" && \
	git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git ${SMA_PATH} && \
	mkdir -p ${SMA_PATH}/config && \
	echo "************ create logging file ************" && \
	mkdir -p ${SMA_PATH}/config && \
	touch ${SMA_PATH}/config/sma.log && \
	chgrp users ${SMA_PATH}/config/sma.log && \
	chmod g+w ${SMA_PATH}/config/sma.log && \
	echo "************ install pip dependencies ************" && \
	python3 -m pip install --user --upgrade pip && \	
	pip3 install -r ${SMA_PATH}/setup/requirements.txt && \
	echo "************ setup cron ************" && \
	service cron start && \
	echo "* * * * *   root   bash /scripts/update.bash" >> "/etc/crontab"
	
WORKDIR /

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 7878
VOLUME /config
