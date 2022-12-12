import argparse
import logging

from utils import (validate_response, add_common_args, init_common_args, validate_output_path, task_output_command)


def download_certified_secure(api_key, team_id, task_id):
    return task_output_command(api_key, team_id, task_id, 'certificate')


def parse_arguments():
    parser = argparse.ArgumentParser(description='Download Certified Secure pdf file')
    add_common_args(parser, add_task_id=True)
    parser.add_argument('-co', '--certificate_output', required=True, metavar='certificate_output_file', help='Output file for Certified Secure pdf')
    return parser.parse_args()


def main():
    args = parse_arguments()
    init_common_args(args)
    validate_output_path(args.certificate_output)
    r = download_certified_secure(args.api_key, args.team_id, args.task_id)
    validate_response(r)
    with open(args.certificate_output, 'wb') as f:
        f.write(r.content)
    logging.info(f"Downloaded file to {args.certificate_output}")


if __name__ == '__main__':
    main()
