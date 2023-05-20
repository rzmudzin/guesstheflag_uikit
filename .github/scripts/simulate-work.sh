#!/bin/bash

forceFail=$1
SLEEP_TIME=10
max=9
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
if [[ $forceFail != "0" ]]; then
    exit 11
fi
