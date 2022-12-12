#!/bin/bash

# Checks the expiration status of given certificate files and emits
# github workflow error or warning annotations if there is a problem.

#TOOLS_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && cd ../../Tools && pwd)

#default to 45 days out
CHECK_SECONDS=3888000

FORMAT=pem
EXPIRED_LEVEL=error

if [ "$1" == "-f" ] ; then
   FORMAT="$2"
   shift
   shift
fi

if [ "$1" == "-s" ] ; then
   CHECK_SECONDS="$2"
   shift
   shift
fi

if [ "$1" == "-w" ] ; then
   EXPIRED_LEVEL=warning
   shift
fi

while [ -f "$1" ] ; do

   CERT="$1"
   CERT_FNAME=`basename "$CERT"`
   CERT_NAME=`openssl x509 -noout -subject -inform "${FORMAT}" -in "${CERT}" 2>&1`
   EXPIRED_NOW=`openssl x509 -noout -checkend 0 -inform "${FORMAT}" -in "${CERT}" &>/dev/null ; echo "$?"`
   EXPIRES_SOON=`openssl x509 -noout -checkend ${CHECK_SECONDS} -inform "${FORMAT}" -in "${CERT}" &>/dev/null ; echo "$?"`
   EXPIRES=`openssl x509 -noout  -enddate -inform "${FORMAT}" -in "${CERT}" 2>&1 | sed 's/notAfter=//g'`

   if [[ "${CERT_NAME}" == *"unable to load"* ]] ; then
       echo "Not a ${FORMAT} certificate file: $CERT";
   elif [[ "${EXPIRED_NOW}" != "0" ]] ; then
       echo "::${EXPIRED_LEVEL} file=${CERT}::${CERT_FNAME} (${CERT_NAME}) has expired (${EXPIRES})"
   elif [[ "${EXPIRES_SOON}" != "0" ]] ; then
       echo "::warning file=${CERT}::${CERT_FNAME} (${CERT_NAME}) will expire in less than $((CHECK_SECONDS/60/60/24)) days, on ${EXPIRES}"
   fi

   shift
done
