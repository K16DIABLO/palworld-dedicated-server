#!/bin/bash

SUDO=`which sudo`

# Update
${SUDO} apt -y update
${SUDO} apt -y install software-properties-common git make vim wget tmux

# To install StreamCMD
${SUDO} add-apt-repository -y multiverse; ${SUDO} dpkg --add-architecture i386; ${SUDO} apt -y update
${SUDO} apt -y install steamcmd # Press Enter and Agree (2)
${SUDO} ln -s `whereis steamcmd` /usr/bin

# Download the Palworld dedicated server
steamcmd +login anonymous +app_update 2394010 validate +quit

# Optional bug fix "steamclient.so"
if [ ! -d "${HOME}/.steam/sdk64" ]; then
  mkdir -p ~/.steam/sdk64/
fi
if [ ! -f "${HOME}/.steam/sdk64/steamclient.so" ]; then
  steamcmd +login anonymous +app_update 1007 +quit
  cp ~/Steam/steamapps/common/Steamworks\ SDK\ Redist/linux64/steamclient.so ~/.steam/sdk64/
fi

# Startup the Palworld dedicated server
PALSERVER_LOC=${HOME}/Steam/steamapps/common/PalServer
cp ./infinitePalServer.sh ${PALSERVER_LOC}
