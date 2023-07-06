# coding=utf-8
import time
import requests
import sys
from functools import reduce


def retry(url):
    count = 10
    while count > 0:
        resp = requests.get(url)
        if resp.status_code == 404:
            time.sleep(3)
            count = count - 1
        else:
            return resp.json()


def process(history_server, application_id):
    stages = retry('{}/api/v1/applications/{}/1/stages'.format(history_server, application_id))
    job = retry('{}/api/v1/applications/{}'.format(history_server, application_id))
    duration = round(job['attempts'][0]['duration'] / 1000, 2)
    fetch_times = round(reduce(lambda x, y: x + y, [stage['shuffleFetchWaitTime'] for stage in stages]) / 1000, 2)
    write_times = round(reduce(lambda x, y: x + y, [stage['shuffleWriteTime'] / 1e6 for stage in stages]) / 1000, 2)
    # compatible with python2 and python3
    print(duration)
    print(fetch_times)
    print(write_times)


def main():
    history_server = sys.argv[1]
    application_id = sys.argv[2]
    process(history_server, application_id)


if __name__ == '__main__':
    main()
