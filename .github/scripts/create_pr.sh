#!/bin/bash

# Script to generate a PR with local changes after a github job

WORKSPACE="${GITHUB_WORKSPACE}"
BRANCH_NAME=
COMMIT_SUBPATHS=()
COMMIT_MESSAGE="Updates to ${COMMIT_SUBPATH}"
PR_TITLE=

BASE_BRANCH=`git rev-parse --abbrev-ref HEAD`

while getopts w:b:B:p:t:m: flag
do
    case "${flag}" in
        w) WORKSPACE="${OPTARG}";;
        b) BRANCH_NAME="${OPTARG}";;
        B) BASE_BRANCH="${OPTARG}";;
        p) COMMIT_SUBPATHS+=("${OPTARG}");;
        m) COMMIT_MESSAGE="${OPTARG}";;
        t) PR_TITLE="${OPTARG}";;
    esac
done


#Set up a branch to publish, unless we are already on that branch
if [ "${BRANCH_NAME}" != "${BASE_BRANCH}" ] ; then
    git checkout -b $BRANCH_NAME
fi

HAD_CHANGES=false

for COMMIT_SUBPATH in "${COMMIT_SUBPATHS[@]}" ; do
    FULLPATH="${WORKSPACE}/${COMMIT_SUBPATH}"
    if ! git diff -s --exit-code "${FULLPATH}" ; then
        git add "$FULLPATH"
        HAD_CHANGES=true
    fi
done

if [ "${HAD_CHANGES}" == "false" ] ; then
    echo "no changes on $COMMIT_SUBPATHS"
    exit 0
fi

git -c user.name=GitHub -c user.email=noreply@git.marriott.com commit -m "${COMMIT_MESSAGE}"
git push origin $BRANCH_NAME

#Create the pull request, unless we are updating the branch
if [ "${BRANCH_NAME}" != "${BASE_BRANCH}" ] ; then
    "${GITHUB_WORKSPACE}"/Tools/hub -c hub.host=git.marriott.com pull-request -m "${PR_TITLE}" -b "${BASE_BRANCH}" -h $BRANCH_NAME
fi
