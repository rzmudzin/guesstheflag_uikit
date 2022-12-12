#!/bin/bash

set -eo pipefail
while getopts b:s:c:i:e:p:k:a:d flag
do
    case "${flag}" in
        b) buildNumber=${OPTARG};;
        s) scheme=${OPTARG};;
        c) config=${OPTARG};;
        i) archivePath=${OPTARG};;
        e) exportPath=${OPTARG};;
        p) configPath=${OPTARG};;
        k) keyPath=${OPTARG};;
        a) authKeyID=${OPTARG};;
        d) authIssuerID=${OPTARG};;
    esac
done
echo "new build number: $buildNumber";
echo "scheme: $scheme";
echo "config: $config";
echo "archive: $archivePath";
echo "export path: $exportPath";
echo "config path: $configPath";
echo "key path: $keyPath";
echo "auth key: $authKeyID";
echo "auth issuer id: $authIssuerID";


if [ ${buildNumber} ] ; then
    if grep -q "BUILD_NUMBER" $configPath
    then
        sed -i '' "s/BUILD_NUMBER = .*/BUILD_NUMBER = $buildNumber/g" $configPath
    else
        echo "BUILD_NUMBER = $buildNumber" >> $configPath
    fi
fi

/usr/bin/xcodebuild -project ~/projects/actions-runner/_work/ios/ios/Marriott/Marriott.xcodeproj \
            -scheme "$scheme" \
            -configuration $config \
            -archivePath $archivePath \
            clean archive

/usr/bin/xcodebuild -exportArchive \
            -exportOptionsPlist ~/projects/actions-runner/_work/ios/ios/.github/ProductionExportOptions.plist \
            -exportPath $exportPath \
            -archivePath $archivePath \
            -authenticationKeyPath $keyPath \
            -authenticationKeyID $authKeyID \
            -authenticationKeyIssuerID $authIssuerID \
            -allowProvisioningUpdates
