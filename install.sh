#!/bin/bash

# Update
sudo apt -y update
sudo apt -y install software-properties-common git make vim wget tmux

# To install StreamCMD
sudo add-apt-repository -y multiverse; sudo dpkg --add-architecture i386; sudo apt update
sudo apt -y install steamcmd # Press Enter and Agree (2)

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
cd ${HOME}/Steam/steamapps/common/PalServer
cp ./DefaultPalWorldSettings.ini ./Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
sed -i 's/RCONEnabled=False/RCONEnabled=True/' ./Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
