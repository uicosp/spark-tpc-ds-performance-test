# coding=utf-8
import time
import requests
import sys
from functools import reduce


def retry(url, fn=None):
    count = 10
    while count > 0:
        resp = requests.get(url)
        if resp.status_code == 404:
            time.sleep(3)
            count = count - 1
        elif fn is not None:
            data = resp.json()
            if fn(data):
                return data
            else:
                time.sleep(3)
                count = count - 1
        else:
            return resp.json()


def process(history_server, rm_http_address, application_id):
    job = retry('{}/api/v1/applications/{}'.format(history_server, application_id),
                lambda data: data['attempts'][0]['completed'] is True)
    attempt_id = job['attempts'][0]['attemptId']
    stages = retry('{}/api/v1/applications/{}/{}/stages'.format(history_server, application_id, attempt_id))
    duration = round(job['attempts'][0]['duration'] / 1000, 2)
    fetch_times = round(reduce(lambda x, y: x + y, [stage['shuffleFetchWaitTime'] for stage in stages]) / 1000, 2)
    write_times = round(reduce(lambda x, y: x + y, [stage['shuffleWriteTime'] / 1e6 for stage in stages]) / 1000, 2)
    read_gb = round(reduce(lambda x, y: x + y, [stage['shuffleReadBytes'] for stage in stages]) / (1024 * 1024 * 1024), 2)
    write_gb = round(reduce(lambda x, y: x + y, [stage['shuffleWriteBytes'] for stage in stages]) / (1024 * 1024 * 1024), 2)

    # yarn resource manager
    app = requests.get('{}/ws/v1/cluster/apps/{}'.format(rm_http_address, application_id)).json()
    memory_seconds = app['app']['memorySeconds']
    vcore_seconds = app['app']['vcoreSeconds']

    # compatible with python2 and python3
    print(duration)
    print(fetch_times)
    print(write_times)
    print(read_gb)
    print(write_gb)
    print(memory_seconds)
    print(vcore_seconds)


def main():
    history_server = sys.argv[1]
    rm_http_address = sys.argv[2]
    application_id = sys.argv[3]
    process(history_server, rm_http_address, application_id)


if __name__ == '__main__':
    main()
