#!/bin/bash

# Script to generate build notes (using git commit changes), and fail build if none

FORCE_BUILD=false
RECENT_COUNT=0
PREPEND_LINES=()

BRANCHNAME=`git rev-parse --abbrev-ref HEAD`
PREPEND_LINES+=("Branch: ${BRANCHNAME}")

while getopts c:f:C:o: flag
do
    case "${flag}" in
        c) GIT_PREVIOUS_SUCCESSFUL_COMMIT="${OPTARG}";;
        f) FORCE_BUILD="${OPTARG}";;
        C) if [ -n "${OPTARG}" ] ; then PREPEND_LINES+=("${OPTARG}"); fi;;
        o) OUTPUT=${OPTARG};;
    esac
done

# If no output file name just use default
if [ -z "$OUTPUT" ] ; then
   OUTPUT="change_log.txt"
fi

# If we are not on the same branch as the specified commit, switch to using the last N commits on this branch
# Otherwise, the commit list can be very messy and confusing.
if [ -n "$GIT_PREVIOUS_SUCCESSFUL_COMMIT" ] && ! git merge-base --is-ancestor "$GIT_PREVIOUS_SUCCESSFUL_COMMIT" HEAD ; then
   GIT_PREVIOUS_SUCCESSFUL_COMMIT=
fi

if [ -z "$GIT_PREVIOUS_SUCCESSFUL_COMMIT" -a $RECENT_COUNT -eq 0 ] ; then
   RECENT_COUNT=10
fi

if [ $RECENT_COUNT -gt 0 ] ; then
    CHANGES=`git log --pretty=format:"- %an: %s" -n $RECENT_COUNT`
else
    CHANGES=`git log --pretty=format:"- %an: %s" $GIT_PREVIOUS_SUCCESSFUL_COMMIT..HEAD`
fi

# If no commit messages at all, then fail the build, unless it's the first build
# or -force was passed.
if [ ${#CHANGES} -lt 5 ] ; then
    if [ "$FORCE_BUILD" == "true" ] ; then
        CHANGES="- Forcing build"
    elif [ -z "$GIT_PREVIOUS_SUCCESSFUL_COMMIT" ] ; then
        CHANGES="- Initial build"
    else
        exit 11  # Fail the build
    fi
fi

# Add in the PREPEND_LINES at the top.
# Iterate reverse order here, since we prepend each one, which will put back in original order
for ((i=${#PREPEND_LINES[@]}-1; i>=0; i--)); do
    line="${PREPEND_LINES[$i]}"
    CHANGES="- ${line}"$'\n'"${CHANGES}"
done


echo "${CHANGES}"

#AppCenter limits release notes to 5000 bytes
MS_CHANGE_LIMIT=4980
echo "${CHANGES::MS_CHANGE_LIMIT}" > $OUTPUT
