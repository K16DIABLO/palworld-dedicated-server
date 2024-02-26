#!/bin/bash

PALSERVER_LOC=${HOME}/Steam/steamapps/common/PalServer
trap ctrl_c INT
function ctrl_c() {
	echo "**You are killing Palworld Server**"
	rcon -a localhost:25575 -p ${ADMIN_PASSWD} save
	rcon -a localhost:25575 -p ${ADMIN_PASSWD} doexit 
	wait
	echo "**Copying Palworld SavedFile**"
  if [ ! -d "${HOME}/Palworld_SaveFiles" ]; then 
    mkdir -p "${HOME}/Palworld_SaveFiles"
  fi
	cp -r ${PALSERVER_LOC}/Pal/Saved ${HOME}/Palworld_SaveFiles/Saved_$(date +%Y%m%d%H%M)
	echo "**Done**"
	exit
}

if [ ! -d "${HOME}/Steam/steamapps/common/PalServer/Pal/Saved" ]; then
  echo "Execute server to generate configuration files"
  echo "PalServer.sh will be killed after 5sec..."
  ./PalServer.sh &
  sleep 5s
  pkill -9 PalServer.sh
  wait
  cp ${PALSERVER_LOC}/DefaultPalWorldSettings.ini ${PALSERVER_LOC}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
  sed -i 's/RCONEnabled=False/RCONEnabled=True/' ${PALSERVER_LOC}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
  echo "Please re-run this script"
  exit
fi

MEM_THRESHOLD=90.0
echo "Enter Admin password: "
read ADMIN_PASSWD
echo "Enter Server password: "
read SERVER_PASSWD
sed -i "s/AdminPassword=\"\"/AdminPassword=\"${ADMIN_PASSWD}\"/" ${PALSERVER_LOC}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
sed -i "s/ServerPassword=\"\"/ServerPassword=\"${SERVER_PASSWD}\"/" ${PALSERVER_LOC}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini

while :
do
	./PalServer.sh -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS &
	sleep 10s
	while :
	do
    if ! pgrep -x "PalServer.sh" > /dev/null
    then
      exit
    fi
		memory_usage=`free -m | awk 'NR==2{print $3*100/$2 }'`
		printf "\r[%d] Memory Utilization = %.2f%%" $(date +%Y%m%d%H%M) $memory_usage
		if [ `echo "${memory_usage} > ${MEM_THRESHOLD}" | bc` -eq 1 ] ; then
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} "broadcast Server_will_restart_after_1min"
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} "broadcast Current_status_will_be_save_automatically"
			sleep 30s
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} "broadcast Server_will_restart_after_30sec"
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} "broadcast Current_status_will_be_save_automatically"
			sleep 20s
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} "broadcast Server_will_restart_after_10sec"
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} "broadcast Current_status_will_be_save_automatically"
			sleep 10s
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} "broadcast Server_restarting...Goodbye!"
			sleep 5s
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} save
			rcon -a localhost:25575 -p ${ADMIN_PASSWD} doexit 
			wait
			echo "**Copying Palworld SavedFile**"
      if [ ! -d "${HOME}/Palworld_SaveFiles" ]; then 
        mkdir -p "${HOME}/Palworld_SaveFiles"
      fi
			cp -r ${PALSERVER_LOC}/Pal/Saved ${HOME}/Palworld_SaveFiles/Saved_$(date +%Y%m%d%H%M)
			echo "**Done**"
			break
		else
			sleep 10s
		fi
	done
done
