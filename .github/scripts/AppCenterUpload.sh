#!/bin/bash

while getopts a:g:f:t:r:d: flag
do
    case "${flag}" in
        g) group="${OPTARG}";;
        a) app="${OPTARG}";;
        f) file="${OPTARG}";;
        t) token="${OPTARG}";;
        r) releaseNotes="${OPTARG}";;
        d) dysmsPath="${OPTARG}";;
    esac
done
echo "group: $group";
echo "app: $app";
echo "file: $file";
echo "token: $token";
echo "release notes: $releaseNotes";
echo "dsyms path: $dysmsPath";
#cat "$releaseNotes";

# abort if the first command failed
set -e

appcenter distribute release --app "$app" --file "$file" --release-notes-file "$releaseNotes" --token "$token" --group "$group";


if [ -d "${dysmsPath}" ] ; then
    echo "$dysmsPath/dSYMs"
    FILES="$dysmsPath/dSYMs/*"

    for f in $FILES;
    do
        space=' '
        underscore='_'
        
if [[ "$f" == *"$space"* ]]; then
        newFileName=$(echo $f | sed "s/$space/$underscore/")
        mv "$f" "$newFileName"
else
        newFileName=$(echo $f)
fi
        echo "Uploading symbols: $newFileName"
        appcenter crashes upload-symbols --symbol "$newFileName" --token "$token" --app "$app";

    done
fi
