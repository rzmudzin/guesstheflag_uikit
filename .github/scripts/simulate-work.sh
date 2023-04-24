#!/bin/bash

SLEEP_TIME=15
max=3
counter=0
while true;
do
    echo "Looping..."
    if [[ $counter -le $max ]];
    then
        echo "$counter Events"
    else
        echo "Loop exiting after $counter events"
        break
    fi
    echo "Sleeping for $SLEEP_TIME seconds"
    sleep $SLEEP_TIME

  : $((counter++))
done
