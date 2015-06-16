#!/usr/bin/python
"""An example demonstrating the client-side usage
of the cretificate request API endpoint.
"""

import requests, sys

url = 'https://spire.cloudfleet.io/dashboard/blimp/api/request_cert'
domain = sys.argv[1]
secret = sys.argv[2]
file_path = sys.argv[3]
print('requesting: ' + url)
files = {'signature': open(file_path, 'rb')}
r = requests.post(url, {'domain': domain, 'secret': secret}, files=files)

if r.status_code < 400:
    quit(0)
else:
    quit(1)
