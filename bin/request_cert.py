#!/usr/bin/python
"""An example demonstrating the client-side usage
of the cretificate request API endpoint.
"""

import requests, sys, json

domain = sys.argv[1]
otp = sys.argv[2]
cert_path = sys.argv[3]


cert_req_url = 'https://spire.cloudfleet.io/api/v1/blimp/%s/certificate/request' % domain


print('posting cert request to: ' + cert_req_url)

with open(cert_path, 'rb') as cert_req_file:
    cert_req = cert_req_file.read()
r = requests.post(cert_req_url, json={'OTP': otp, 'cert_req': cert_req})

if r.status_code == 200:
    print('Success: %s' % r.text)
    quit(0)
else:
    print('Error: %s' % r.text)
    quit(1)
