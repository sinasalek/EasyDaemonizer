#!/bin/bash

# Name EasyDeamonizer
# Source : 
# Atuhor : Sina Salek
# Website : http://sina.salek.ws

# --(Begin)-- Configuration
# Make this script executable by chmod a=r+w+x
# The EasyDeamonizer to run by cron every minute in case it halted
# Optional
APP_NAME="My App"
# Name or part of the name of process when it runs. should be unique
PROCESS_NAME="mailSender:send"
# The command used for running the app via shell
COMMAND="php -q myapp.php"
# Automatically terminates the app when the average load reaches the defined threshhold
MAX_VALID_CPU_LOAD=100
# Add a delay before restarting the app after crash
RESTART_DELAY=10
# Log deamonizer activities including restarting or termination
LOGFILE=EasyDeamonizerLog.txt
RETAIN_NUM_LINES=1000
# --(End)-- Configuration

# Begin - Log
function logsetup {
    TMP=$(tail -n $RETAIN_NUM_LINES $LOGFILE 2>/dev/null) && echo "${TMP}" > $LOGFILE
    #exec > >(tee -a $LOGFILE)
    #exec 2>&1
}

function log {
    DATE='date +%Y/%m/%d:%H:%M:%S'
    echo `$DATE`": $1" >> $LOGFILE
}

logsetup
#log "Daemon started2"
# End - Log

# Begin - Make sure that it's not already running
PIDS=`pgrep -f $PROCESS_NAME`
CURRENT_PID=`echo $$`
ALREADY_RUNNING=0
for PID in $PIDS
do
        if [[ "$PID" != "$CURRENT_PID" ]]
        then
                ALREADY_RUNNING=1
        fi
done

if [ $ALREADY_RUNNING -eq 1 ]
then
        #echo "Already running, abort ($PIDS)"
        exit;
fi
# End - Make sure that it's not already running

log "Daemon started"

PID=""
PIDS=`pgrep -f $PROCESS_NAME`
for PID in $PIDS
do
        kill $PID
        log "It is already running by other means $PID, killing it";
done

PID=""

while sleep 2; do
  VAR="---"
  if [ -z "$PID" ]
        then
                VAR="---"
        else
          if ps -p $PID > /dev/null
          then
            VAR=""
          fi
        fi
  if [ -z "$VAR" ]
        then
                CPU_LOAD=`ps aux|awk  '{print $2,$3,$4}'|grep $PID|awk '{print $2}'`
                CPU_LOAD=$( printf "%.0f" $CPU_LOAD )
                echo "Current process is $PID And CPU load is $CPU_LOAD"
                if [ $CPU_LOAD -gt $MAX_VALID_CPU_LOAD ]
                then
                        kill $PID
                        log "KILL $PID due to high cpu load"

                fi
        else

                $COMMAND &
                PID=$!
                log "Daemon started : $PID"
                sleep $RESTART_DELAY
        fi
done

# Calculate average cpu usage
# ps aux|awk  '{print $2,$3,$4}'|grep 23275|awk '{print $3}'
# Calculate current cpu load of a single process
# top -b -d 1 -p 23275 n 1 | awk 'FNR == 8 {print $9}'
