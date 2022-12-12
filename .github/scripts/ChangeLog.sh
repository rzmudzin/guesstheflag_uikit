#!/bin/bash

CHANGES=`git log --pretty=format:"- %an: %s" -n 10  | grep -v 'jenkins:'`

#AppCenter limits release notes to 5000 bytes, but keep a safety margin
MS_CHANGE_LIMIT=4950
echo ${#CHANGES}
echo "${CHANGES::MS_CHANGE_LIMIT}" > "~/projects/actions-runner/_work/ios/changes.txt"