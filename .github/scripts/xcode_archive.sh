#!/bin/bash

GH_SCRIPTS_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
TOOLS_DIR="${GH_SCRIPTS_DIR}/../../Tools"
PLBUDDY=/usr/libexec/PlistBuddy

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

set -eo pipefail
profileList=()
method=enterprise
destination=
uploadSymbols=false

while getopts a:b:s:S:c:i:e:C:n:P:m:D:y flag
do
    case "${flag}" in
        a) appCenterAppID=${OPTARG};;
        b) buildNumber=${OPTARG};;
        s) scheme=${OPTARG};;
        S) signingIdentity="${OPTARG}";;
        c) config=${OPTARG};;
        C) configPath="${OPTARG}";;
        i) archivePath="${OPTARG}";;
        e) exportPath="${OPTARG}";;
        n) productName="${OPTARG}";;
        P) profileList+=("${OPTARG}");;
        m) method=${OPTARG};;
        d) destination=${OPTARG};;
        D) dsapHost=${OPTARG};;
        y) uploadSymbols=true;;
        *) exit 12
    esac
done

echo "AppCenter App ID: $appCenterAppID";
echo "new build number: $buildNumber";
echo "scheme: $scheme";
echo "config: $config";
echo "archive: $archivePath";
echo "export path: $exportPath";
echo "config path: $configPath";
echo "method: $method";
echo "product name: $productName";
echo "DSAP host override: $dsapHost"
echo "signing: $signingIdentity";
echo "profiles: ${profileList[@]}";



