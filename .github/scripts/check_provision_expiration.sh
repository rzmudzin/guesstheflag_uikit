#!/bin/bash

# Checks the expiration status of given .mobileprovision files and emits
# github workflow error or warning annotations if there is a problem.

TOOLS_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../../Tools && pwd)
TODAY=`TZ=UTC date +"%Y-%m-%dT%H:%M:%SZ"`
MONTH_AGO=`TZ=UTC date -v-1m +"%Y-%m-%dT%H:%M:%SZ"`

while [ -f "$1" ] ; do

   PROFILE="$1"
   PROFILE_FNAME=`basename "$PROFILE"`
   PROFILE_NAME=`"${TOOLS_DIR}/get_provision_profile_val.sh" Name "$PROFILE"`
   EXPIRES=`"${TOOLS_DIR}/get_provision_profile_val.sh" -t date ExpirationDate "$PROFILE"`

   if [ -z "${EXPIRES}" ] ; then
       echo "Not a provision file: $PROFILE";
   elif [[ "${TODAY}" > "${EXPIRES}" ]] ; then
       echo "::error file=${PROFILE}::${PROFILE_FNAME} (${PROFILE_NAME}) has expired (${EXPIRES})"
   elif [[ "${MONTH_AGO}" > "${EXPIRES}" ]] ; then
       echo "::warning file=${PROFILE}::${PROFILE_FNAME} (${PROFILE_NAME}) will expire in less than a month, on ${EXPIRES}"
   fi

   shift
done
