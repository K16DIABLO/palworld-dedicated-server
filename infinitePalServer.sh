#!/bin/bash

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

if [ ! -d "${HOME}/Steam/steamapps/common/PalServer/Pal/Saved" ]; then
  echo "Execute server to generate configuration files"
  echo "PalServer.sh will be killed after 15sec..."
  ./PalServer.sh &
  sleep 15s
  rcon -a localhost:25575 -p ${PASSWD} doexit
  wait
  echo "Enter server password: "
  read pal_passwd
fi

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
			rcon -a localhost:25575 -p ${PASSWD} "broadcast Server_will_restart_after_10sec"
			rcon -a localhost:25575 -p ${PASSWD} "broadcast Current_status_will_be_save_automatically"
			sleep 10s
			rcon -a localhost:25575 -p ${PASSWD} "broadcast Server_restarting...Goodbye!"
			sleep 5s
			rcon -a localhost:25575 -p ${PASSWD} save
			rcon -a localhost:25575 -p ${PASSWD} doexit 
			wait
			echo "**Copying Palworld SavedFile**"
			cp -r ./Pal/Saved ${HOME}/Palworld_SaveFiles/Saved_$(date +%Y%m%d%H%M)
			echo "**Done**"
			break
		else
			sleep 10s
		fi
	done
done
