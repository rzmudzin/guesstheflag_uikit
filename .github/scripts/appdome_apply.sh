#!/bin/bash

GH_SCRIPTS_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
TOOLS_DIR="${GH_SCRIPTS_DIR}/../../Tools"

trim()
{
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

usage() 
{
    if [ -n "$1" ]; then
        echo "Error: $1"
    fi
    echo "Usage: $0 -f <ipaFile> -S <signing_identity> -o <outputIPAFile> -P <profile entry> [-P <another profile> ...] [-t <teamID> ] [-s <fusion_set_id> ] [-R <appdome_receipt_pdf_file>] [-J <appdome_receipt_json_file>]"
    exit 11
}

set -eo pipefail
profileList=()
profileFileList=()
entitlementsFiles=()
method=enterprise
destination=
ipaFile=
keystoreP12File=
p12Password=
outputIPAFile=
certificateOutput=/dev/null
fusionSet="${APPDOME_IOS_FS_ID}"
sign_local=0

while getopts f:s:k:p:S:P:E:o:R:J:B:l flag
do
    case "${flag}" in
        f) ipaFile="${OPTARG}";;
        t) export APPDOME_TEAM_ID="${OPTARG}";;
        s) export APPDOME_IOS_FS_ID="${OPTARG}";;
        S) signingIdentity="${OPTARG}";;
        P) profileList+=("${OPTARG}");;
        E) entitlementsFiles+=("${OPTARG}");;
        o) outputIPAFile="${OPTARG}";;
        R) receiptPDF="${OPTARG}";;
        J) receiptJSON="${OPTARG}";;
        B) binaryEntitlementsExtraction="${OPTARG}";;
        l) sign_local=1;;
        *) usage
    esac
done

if [ -z "${ipaFile}" ] ; then
   usage "Need -f input IPA file"
fi
if [ -z "${APPDOME_TEAM_ID}" ] ; then
   usage "Need -t argument or APPDOME_TEAM_ID env variable set"
fi
if [ -z "${APPDOME_IOS_FS_ID}" ] ; then
   usage "Need -s argument or APPDOME_IOS_FS_ID env variable set for fusion set"
fi
if [ -z "${APPDOME_API_KEY}" ] ; then
   usage "Need APPDOME_API_KEY env variable set"
fi
if [ ${#profileList[@]} -eq 0 ] ; then
   usage "Need at least one -P argument for provisioning profiles"
fi
if [ -z "${signingIdentity}" ] ; then
   usage "Need -S signing identity"
fi
if [ -z "${outputIPAFile}" ] ; then
   usage "Need -o output IPA file"
fi

echo "IPA: ${ipaFile}"
echo "Team: ${APPDOME_TEAM_ID}"
echo "Fusion set: ${APPDOME_IOS_FS_ID}"
echo "signing: $signingIdentity";
echo "profiles: ${profileList[@]}";

TMP_DIR=$(mktemp -d -t ci-X)


EXTRA_ARGS=()
if [ -n "${receiptPDF}" ] ; then
    EXTRA_ARGS+=("--certificate_output")
    EXTRA_ARGS+=("${receiptPDF}")
fi
if [ -n "${receiptPDF}" ] ; then
    EXTRA_ARGS+=("--certificate_json")
    EXTRA_ARGS+=("${receiptJSON}")
fi

# Appdome sometimes needs a list of entitlements files given to them; it may well become non-optional
# in the future.  We only have the one main entitlements file checked in; the build process creates
# the others (and adds entries to the main one during the build).  Easiest to look through the built app
# and find the binaries next to the embedded.mobileprovision files, and extract the entitlements from them.
# Remember the one for the main app, which we may need for the resign_app script.

if [ -n "${binaryEntitlementsExtraction}" ] ; then
    echo "Checking ${binaryEntitlementsExtraction} for entitlements"
    while IFS= read -r -d '' line; do
        wrapper_path=`dirname "$line"`
        wrapper_name=`basename -- "${wrapper_path}"`
        echo "Getting entitlements from ${wrapper_path}"
        tmp_name="${TMP_DIR}/${wrapper_name}.xml"
        codesign -d --xml --entitlements - "${wrapper_path}" | tr -d '\0' > "${tmp_name}"
        echo "Adding ${tmp_name}"
        entitlementsFiles+=("${tmp_name}")
        if [ "${wrapper_path}" == "${binaryEntitlementsExtraction}" ] ; then
            main_app_entitlements="${tmp_name}"
        fi
    done < <(find "${binaryEntitlementsExtraction}" -name 'embedded.mobileprovision' -print0)
fi

echo "entitlements: ${entitlementsFiles[@]}";


if [ ${#entitlementsFiles[@]} -gt 0 ] ; then
    EXTRA_ARGS+=("--entitlements")
    for file in "${entitlementsFiles[@]}" ; do
        #appdome fails if the entitlements extensions are not .plist, .txt, or .xml
        filebase="$(basename -- $file)"
        full_temp_file="${TMP_DIR}/${filebase}.plist"
        cp -p "${file}" "${full_temp_file}"
        EXTRA_ARGS+=("${full_temp_file}")
    done
fi

#echo "args: ${EXTRA_ARGS[@]}"

# Using the same profile arguments as xcode_archive.sh so we don't have to repeat configs in workflows
teamName=
for profileSpec in "${profileList[@]}" ; do

    IFS=';' read -ra profileItems <<< "$profileSpec"

    profileConfigKey=`trim "${profileItems[0]}"`
    bundleId=`trim "${profileItems[1]}"`
    profilePath=`trim "${profileItems[2]}"`
    #profileUUID=`"${TOOLS_DIR}/get_provision_profile_val.sh" UUID "${profilePath}"`

    echo "bundleId: $bundleId"
    echo "path: $profilePath"

    profileFileList+=("${profilePath}")
done

# Appdome has options to sign on their side, meaning we have to provide them with the private key and
# password over the wire, which we don't want to do.  Another option is -private_signing, where you have
# to sign yourselves after download.  The third option is -auto_dev_private_signing, where the downloaded
# file is actually a shell script you execute to produce the end IPA file.  We had initial problems with
# auto-dev in the TestFlight build, so I wrote the -private_signing path too, but ideally we don't need
# that.  Unless we get nervous running someone else's script that we don't control inside our own company.
#
# However, the resign_app.sh script expects the entitlements to still be in the binaries, and it looks
# like the main app has those stripped out after a --private_signing step.  So, we remember the
# main_app_entitlements file we find, and pass that down to the script so it can use it.  We will
# likely just keep with auto_dev_private_signing, but local signing at least remains an option.

if [ $sign_local -eq 1 ]; then

    DOWNLOAD_IPA="${TMP_DIR}/appdome.ipa"

    python3 "${GH_SCRIPTS_DIR}/appdome-api-python/appdome_api.py" --app "${ipaFile}" --private_signing --output "${DOWNLOAD_IPA}" "${EXTRA_ARGS[@]}" --provisioning_profiles "${profileFileList[@]}" 

    echo "Download complete; re-signing binary"
    bash "${TOOLS_DIR}/resign_app.sh" -I "${DOWNLOAD_IPA}" -E "${main_app_entitlements}" -s "${signingIdentity}" -o "${outputIPAFile}"

else

    SIGNING_SCRIPT="${TMP_DIR}/appdome_sign.sh"

    python3 "${GH_SCRIPTS_DIR}/appdome-api-python/appdome_api.py" --app "${ipaFile}" --auto_dev_private_signing --output "${SIGNING_SCRIPT}" "${EXTRA_ARGS[@]}" --provisioning_profiles "${profileFileList[@]}" 

    echo "Download complete; re-signing binary"
    bash "${SIGNING_SCRIPT}" --signer "${signingIdentity}" --output "${outputIPAFile}"
fi

# Appdome is currently removing symbols from the .ipa files (more likely, just not including them
# when creating their new one).  These are the Symbols and BCSymbolMaps directories at the top
# level of the .ipa.   If they exist in the initial ipa, and missing from the result, then
# restore them.
# The trailing slashes on directories seems to be necessary for unzip -Z to work.

filesToCheck=("Symbols/" "BCSymbolMaps/" "SwiftSupport/")

for f in "${filesToCheck[@]}" ; do
    existsOld=`unzip -Z1 "${ipaFile}" "$f" &>/dev/null ; echo "$?"`
    existsNew=`unzip -Z1 "${outputIPAFile}" "$f" &>/dev/null ; echo "$?"`
    if [[ "$existsOld" == "0" ]] && [[ "$existsNew" != "0" ]] ; then
        echo "Restoring $f to Appdome's .ipa file"
        (cd "${TMP_DIR}"; unzip -q "${ipaFile}" "$f*" ; zip -ru "${outputIPAFile}" "$f" ; /bin/rm -r "$f")
    fi
done


rm -r "${TMP_DIR}"
