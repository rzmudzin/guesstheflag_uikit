#!/bin/bash

GH_SCRIPTS_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

while getopts a:t:f: flag
do
    case "${flag}" in
        a) app="${OPTARG}";;
        t) token="${OPTARG}";;
        f) filePath="${OPTARG}";;
    esac
done
echo "app: $app";
echo "file: $filePath";
echo "token: $token";

# Don't abort build if the upload fails
set -e

"${GH_SCRIPTS_DIR}/../../Marriott/Marriott/Third-Party/Embrace/upload" -app "$app" -token "$token" "$filePath"
