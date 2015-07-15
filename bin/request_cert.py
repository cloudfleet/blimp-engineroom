#!/usr/bin/python
"""An example demonstrating the client-side usage
of the cretificate request API endpoint.
"""

import requests, sys

url = 'https://spire.cloudfleet.io/dashboard/blimp/api/request_cert_json'
domain = sys.argv[1]
secret = sys.argv[2]
file_path = sys.argv[3]
print('requesting: ' + url)
with open(file_path, 'rb') as cert_req_file:
    cert_req = cert_req_file.read()
r = requests.post(url, {'domain': domain, 'secret': secret, 'cert_req': cert_req})

#if r.status_code < 400: # how it should be
if r.json()["success"]:
    print('Success: %s' % r.text)
    quit(0)
else:
    print('Error: %s' % r.text)
    quit(1)
