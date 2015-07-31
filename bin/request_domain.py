#!/usr/bin/python
"""An example demonstrating the client-side usage
of the cretificate request API endpoint.
"""

import requests, sys, json

otp = sys.argv[1]

domain_req_url = 'https://spire.cloudfleet.io/api/v1/blimp/domain'
domain_txt_path = '/opt/cloudfleet/data/config/domain.txt'

print('retrieving domain for blimp: ' + domain_req_url)

r = requests.get(domain_req_url, headers={'X-AUTH-OTP': otp})

if r.status_code == 200:
    print('Success: %s' % r.text)
    result_dict = r.json()

    if "domain" in result_dict:
        with open(domain_txt_path, 'w') as domain_txt_file:
            domain_txt_file.write(result_dict['domain'])
        quit(0)
    else:
        quit(1)
else:
    print('Error: %s' % r.text)
    quit(1)
