#!/bin/bash

# Startup the Palworld dedicated server
PALSERVER_LOC=${HOME}/Steam/steamapps/common/PalServer
cp ${PALSERVER_LOC}/DefaultPalWorldSettings.ini ${PALSERVER_LOC}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
sed -i 's/RCONEnabled=False/RCONEnabled=True/' ${PALSERVER_LOC}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini

echo "Enter server password: "
read pal_passwd


