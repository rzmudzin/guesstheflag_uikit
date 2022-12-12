import argparse
import logging
from time import sleep

import requests

from utils import (SERVER_API_V1_URL, request_headers, JSON_CONTENT_TYPE, validate_response, add_common_args,
                   debug_log_request, log_and_exit, init_common_args, build_url)

VALIDATION = 'validation'


def validation_upload(api_key, file_path):
    url = build_url(SERVER_API_V1_URL, VALIDATION, 'upload')
    headers = request_headers(api_key)
    with open(file_path, 'rb') as f:
        files = {'file': (file_path, f)}
        debug_log_request(url, headers=headers, files=files)
        return requests.post(url, headers=headers, files=files)


def validation_status(api_key, validation_id):
    url = build_url(SERVER_API_V1_URL, VALIDATION, validation_id, 'status')
    headers = request_headers(api_key, JSON_CONTENT_TYPE)
    return requests.get(url, headers=headers)


def wait_for_validation_result(api_key, validation_id, timeout_sec=3600):
    sleep_time = 10
    accumulated_sleep = 0
    status_response = {}
    while accumulated_sleep <= timeout_sec:
        status_response = validation_status(api_key, validation_id)
        validate_response(status_response)
        status_response_json = status_response.json()
        validation_state = status_response_json.get('validation_state', '')
        if validation_state == 'pending' or validation_state == 'active':
            logging.debug(f'Validation not complete. Sleeping for {sleep_time} seconds')
            print('.', end='', flush=True)
            sleep(sleep_time)
        else:
            print('', flush=True)
            break

    if accumulated_sleep > timeout_sec:
        log_and_exit(f"\nValidation did not complete in the specified timeout of: {timeout_sec} seconds")

    return status_response


def validate_app(api_key, file_path):
    upload_response = validation_upload(api_key, file_path)
    logging.info("Upload app for validation done. Waiting for validation result")
    validate_response(upload_response)
    upload_response_json = upload_response.json()
    validation_id = upload_response_json.get('id')
    if not validation_id:
        log_and_exit('Error in upload validation response: ' + upload_response.text)

    return wait_for_validation_result(api_key, validation_id)


def parse_arguments():
    parser = argparse.ArgumentParser(description='Validate App after local signing')
    add_common_args(parser, add_team_id=False)
    parser.add_argument('-vl', '--validate_app', required=True, help='Path of app to validate')
    return parser.parse_args()


def main():
    args = parse_arguments()
    init_common_args(args)

    r = validate_app(args.api_key, args.validate_app)
    validate_response(r)
    logging.info(f"Validation done. Output: {r.json()}")


if __name__ == '__main__':
    main()
