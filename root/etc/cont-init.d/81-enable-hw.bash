#!/usr/bin/with-contenv bash

## hardware support ##
FILES=$(find /dev/dri -type c -print 2>/dev/null)
for i in $FILES
do
  VIDEO_GID=$(stat -c '%g' "$i")
  if id -G abc | grep -qw "$VIDEO_GID"; then
    touch /groupadd
  else
    if [ ! "${VIDEO_GID}" == '0' ]; then
      VIDEO_NAME=$(getent group "${VIDEO_GID}" | awk -F: '{print $1}')
      if [ -z "${VIDEO_NAME}" ]; then
        VIDEO_NAME="video$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c8)"
        groupadd "$VIDEO_NAME"
        groupmod -g "$VIDEO_GID" "$VIDEO_NAME"
      fi
      usermod -a -G "$VIDEO_NAME" abc
      touch /groupadd
    fi
  fi
done
if [ -n "${FILES}" ] && [ ! -f "/groupadd" ]; then
  usermod -a -G root abc
fi
exit 0
