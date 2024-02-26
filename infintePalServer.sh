#!/bin/bash

if [ `echo "$# != 2"` ]; then
  echo "Usage: ./InifitePalServer.sh <server_password>"
fi
PASSWD=$1

trap ctrl_c INT
function ctrl_c() {
	echo "**You are killing Palworld Server**"
	rcon -a localhost:25575 -p ${PASSWD} save
	rcon -a localhost:25575 -p ${PASSWD} doexit 
	wait
	echo "**Copying Palworld SavedFile**"
	cp -r ./Pal/Saved ${HOME}/Palworld_SaveFiles/Saved_$(date +%Y%m%d%H%M)
	echo "**Done**"
	exit
}

MEM_THRESHOLD=90.0

while :
do
	./PalServer.sh -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS &
	sleep 5s
	while :
	do
		memory_usage=`free -m | awk 'NR==2{print $3*100/$2 }'`
		printf "[%d] Memory Utilization = %.2f%%\r" $(date +%Y%m%d%H%M) $memory_usage
		if [ `echo "${memory_usage} > ${MEM_THRESHOLD}" | bc` -eq 1 ] ; then
			rcon -a localhost:25575 -p ${PASSWD} "broadcast Server_will_restart_after_1min"
			rcon -a localhost:25575 -p ${PASSWD} "broadcast Current_status_will_be_save_automatically"
			sleep 30s
			rcon -a localhost:25575 -p ${PASSWD} "broadcast Server_will_restart_after_30sec"
			rcon -a localhost:25575 -p ${PASSWD} "broadcast Current_status_will_be_save_automatically"
			sleep 20s
			rcon -H localhost:25575 -p ${PASSWD} "broadcast Server_will_restart_after_10sec"
			rcon -H localhost:25575 -p ${PASSWD} "broadcast Current_status_will_be_save_automatically"
			sleep 10s
			rcon -H localhost:25575 -p ${PASSWD} "broadcast Server_restarting...Goodbye!"
			sleep 5s
			rcon -H localhost:25575 -p ${PASSWD} save
			rcon -H localhost:25575 -p ${PASSWD} doexit 
			wait
			echo "**Copying Palworld SavedFile**"
			cp -r ./Pal/Saved ${HOME}/Palworld_SaveFiles/Saved_$(date +%Y%m%d%H%M)
			echo "**Done**"
			break
		else
			sleep 5m
		fi
	done
done
