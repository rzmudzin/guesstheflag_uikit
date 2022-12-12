#!/bin/bash

# Script to unlock a keychain and add it to the search list, for use in builds

KEYCHAIN_PATH=
KEYCHAIN_PASSWORD=

while getopts k:p: flag
do
    case "${flag}" in
        k) KEYCHAIN_PATH="${OPTARG}";;
        p) KEYCHAIN_PASSWORD="${OPTARG}";;
    esac
done

if [ -z "$KEYCHAIN_PATH" ] || [ -z "$KEYCHAIN_PASSWORD" ] ; then
   echo "Usage: $0 -k <keychain_path> -p <keychain_password>"
   exit 2
fi

CURRENT_PATH=`/usr/bin/security list-keychains`

# Need to parse out the quotes that list-keychains gives us, to set them back
CURRENT_PATH_LIST=()
while IFS=\n read -r line; do
   CURRENT_PATH_LIST+=("$line")
done < <(/usr/bin/security list-keychains | sed 's/^ *\"//g' | sed 's/\" *$//g')

if [[ "$CURRENT_PATH" != *"${KEYCHAIN_PATH}"* ]] ; then
   /usr/bin/security list-keychains -s "${KEYCHAIN_PATH}" "${CURRENT_PATH_LIST[@]}"
   #/usr/bin/security default-keychain -d user -s "${KEYCHAIN_PATH}"
fi

/usr/bin/security unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}"
# Show info after unlocking, if not OS X may prompt for password, per Xcode plugin
/usr/bin/security show-keychain-info "${KEYCHAIN_PATH}"
/usr/bin/security list-keychains
