import argparse
import logging

from utils import (cleaned_fd_list, add_provisioning_profiles_entitlements, run_task_action, add_google_play_signing_fingerprint,
                   ANDROID_SIGNING_FINGERPRINT_KEY, validate_response, add_common_args, init_common_args, init_overrides)

AUTO_DEV_SIGN_ACTION = 'sign_script'


def auto_dev_sign_android(api_key, team_id, task_id, signing_fingerprint, is_google_play_signing=False, sign_overrides=None):
    overrides = {}
    if is_google_play_signing:
        add_google_play_signing_fingerprint(signing_fingerprint, overrides)
    else:
        overrides[ANDROID_SIGNING_FINGERPRINT_KEY] = signing_fingerprint

    if sign_overrides:
        overrides.update(sign_overrides)

    return run_task_action(api_key, team_id, AUTO_DEV_SIGN_ACTION, task_id, overrides, None)


def auto_dev_sign_ios(api_key, team_id, task_id, provisioning_profiles_paths, entitlements_paths=None, sign_overrides=None):
    overrides = {}
    files_list = []
    with cleaned_fd_list() as open_fd:
        add_provisioning_profiles_entitlements(provisioning_profiles_paths, entitlements_paths, files_list, overrides, open_fd)
        if sign_overrides:
            overrides.update(sign_overrides)
        return run_task_action(api_key, team_id, AUTO_DEV_SIGN_ACTION, task_id, overrides, files_list)


def parse_arguments():
    parser = argparse.ArgumentParser(description='Initialize Auto-DEV private signing on Appdome')
    add_common_args(parser, add_task_id=True)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('-pr', '--provisioning_profiles', nargs='+', metavar='provisioning_profile_file', help='Path to iOS provisioning profiles files to use. Can be multiple profiles')
    group.add_argument('-cf', '--signing_fingerprint', metavar='signing_fingerprint', help='SHA-1 or SHA-256 final Android signing certificate fingerprint.')
    parser.add_argument('-entt', '--entitlements', nargs='+', metavar='entitlements_plist_path', help='Path to iOS entitlements plist to use. Can be multiple entitlements files')
    parser.add_argument('-gp', '--google_play_signing', action='store_true', help='This Android application will be distributed via the Google Play App Signing program.')
    parser.add_argument('-sv', '--sign_overrides', metavar='overrides_json_file', help='Path to json file with sign overrides')
    return parser.parse_args()


def main():
    args = parse_arguments()
    init_common_args(args)

    overrides = init_overrides(args.sign_overrides)

    if args.signing_fingerprint:
        r = auto_dev_sign_android(args.api_key, args.team_id, args.task_id, args.signing_fingerprint, args.google_play_signing, overrides)
    else:
        r = auto_dev_sign_ios(args.api_key, args.team_id, args.task_id, args.provisioning_profiles, args.entitlements, overrides)

    validate_response(r)
    logging.info(f"Auto-DEV private signing for Build id: {r.json()['task_id']} started")


if __name__ == '__main__':
    main()
