
VERBOSE_FLAG=

while getopts f:k:i:v flag
do
    case "${flag}" in
        f) IPA_FILE="${OPTARG}";;
        k) API_KEY_ID="${OPTARG}";;
        i) API_ISSUER="${OPTARG}";;
        v) VERBOSE_FLAG=--verbose
    esac
done

if [ -z "${IPA_FILE}" ] || [ -z "${API_KEY_ID}" ] || [ -z "${API_ISSUER}" ] ; then
   echo "Usage: $0 -f <ipa_file> -k <api_key> -i <api_issuer> (API_KEY_CONTENT env also required)"
   exit 22
fi

if [ -z "${API_KEY_CONTENT}" ] ; then
    echo "Need API_KEY_CONTENT set in the environment"
    exit 44
fi

umask 077
TMP_DIR=$(mktemp -d -t ci-X)
echo "${API_KEY_CONTENT}" > "$TMP_DIR"/AuthKey_${API_KEY_ID}.p8

# set the directory that altool will use for the lookup
export API_PRIVATE_KEYS_DIR="${TMP_DIR}"

# Don't exit immediately on error, so we delete the tmp dir first
EXIT_CODE=0
xcrun altool --upload-app -f "${IPA_FILE}" --type iOS --show-progress ${VERBOSE_FLAG} --apiKey "${API_KEY_ID}" --apiIssuer "${API_ISSUER}" || EXIT_CODE=$?

/bin/rm -r "${TMP_DIR}"

exit $EXIT_CODE
