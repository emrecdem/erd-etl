import argparse
import hashlib
from argparse import FileType


def parse_arguments():
    parser = argparse.ArgumentParser(
        description='Calculate sha256 of binary file')

    parser.add_argument('input_file', help='Input csv', type=FileType('rb'))

    args = parser.parse_args()
    return args.input_file


def calculate_sha256():
    chunkSize = 1 * 1024 * 1024  # 1 MB
    input_file = parse_arguments()

    m = hashlib.sha256()
    m.update(input_file.read(chunkSize))
    sha256 = m.hexdigest()

    print({'sha256': sha256})


if __name__ == "__main__":
    calculate_sha256()
