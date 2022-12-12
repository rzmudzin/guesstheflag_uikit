#!/bin/bash

set -eo pipefail
while getopts a:b:s:c:i:e:p: flag
do
    case "${flag}" in
        a) appCenterAppID=${OPTARG};;
        b) buildNumber=${OPTARG};;
        s) scheme=${OPTARG};;
        c) config=${OPTARG};;
        i) archivePath=${OPTARG};;
        e) exportPath=${OPTARG};;
        p) configPath=${OPTARG};;
    esac
done
echo "AppCenter App ID: $appCenterAppID";
echo "new build number: $buildNumber";
echo "scheme: $scheme";
echo "config: $config";
echo "archive: $archivePath";
echo "export path: $exportPath";
echo "config path: $configPath";

if [ ${buildNumber} ] ; then
    if grep -q "BUILD_NUMBER" $configPath
    then
        sed -i '' "s/BUILD_NUMBER = .*/BUILD_NUMBER = $buildNumber/g" $configPath
    else
        echo "BUILD_NUMBER = $buildNumber" >> $configPath
    fi
fi

if [ ${appCenterAppID} ] ; then
    if grep -q "APPCENTER_APP_ID" $configPath
    then
        sed -i '' "s/APPCENTER_APP_ID = .*/APPCENTER_APP_ID = $appCenterAppID/g" $configPath
    else
        echo "APPCENTER_APP_ID = $appCenterAppID" >> $configPath
    fi
fi

/usr/bin/xcodebuild -project ~/projects/actions-runner/_work/ios/ios/Marriott/Marriott.xcodeproj \
            -scheme "$scheme" \
            -configuration $config \
            -archivePath $archivePath \
            clean archive

if [ ${exportPath} ] ; then
/usr/bin/xcodebuild -exportArchive \
            -exportPath $exportPath \
            -archivePath $archivePath \
            -exportOptionsPlist ~/projects/actions-runner/_work/ios/ios/.github/EnterpriseExportOptions.plist
fi
