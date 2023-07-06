# coding=utf-8
import requests
import sys
from functools import reduce


def process(history_server, application_id):
    job = requests.get('{}/api/v1/applications/{}'.format(history_server, application_id)).json()
    stages = requests.get('{}/api/v1/applications/{}/1/stages'.format(history_server, application_id)).json()
    duration = round(job['attempts'][0]['duration'] / 1000, 2)
    fetch_times = round(reduce(lambda x, y: x + y, [stage['shuffleFetchWaitTime'] for stage in stages]) / 1000, 2)
    write_times = round(reduce(lambda x, y: x + y, [stage['shuffleWriteTime'] / 1e6 for stage in stages]) / 1000, 2)
    print(duration, fetch_times, write_times)


def main():
    history_server = sys.argv[1]
    application_id = sys.argv[2]
    process(history_server, application_id)


if __name__ == '__main__':
    main()
