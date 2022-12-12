# appdome-api-python
Python library for interacting with https://fusion.appdome.com/ tasks API

Each API endpoint has its own file and main for a single API call.

appdome_api.py contains the whole flow of a task from upload to download.

All APIs are documented in https://apis.appdome.com/docs

The following environment variables can be defined in order to save passing them on each call:

* APPDOME_API_KEY
* APPDOME_TEAM_ID
* APPDOME_IOS_FS_ID
* APPDOME_ANDROID_FS_ID


### Android Example (assuming the above environment variables are set):

python3 appdome_api.py --app `<apk/aab file>` --sign_on_appdome --keystore `<keystore file>` --keystore_pass `<keystore password>`
 --keystore_alias `<key alias>` --key_pass `<key password>` --output `<output apk/aab>` --certificate_output `<output certificate pdf>`

### iOS Example (assuming the above environment variables are set):

python3 appdome_api.py --app `<ipa file>` --sign_on_appdome --keystore `<p12 file>` --keystore_pass `<p12 password>`
--provisioning_profiles `<provisioning profile file>` `<another provisioning profile file if needed>` --entitlements `<entitlements file>` `<another entitlements file if needed>` --output `<output ipa>` --certificate_output `<output certificate pdf>`

### Integration Example With GitHub Actions:
[GitHub Actions Example](github_actions_appdome_workfolw_example.yml) 
