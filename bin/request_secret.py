#!/usr/bin/python

import requests, sys, json

domain = sys.argv[1]
key_path = sys.argv[2]
cert_path = sys.argv[3]
blimp_vars_path = sys.argv[4]


secret_req_url = 'https://spire.cloudfleet.io/api/v1/blimp/%s/secret' % domain


r = requests.get(secret_req_url, cert=(cert_path, key_path))

if r.status_code == 200:
    print('Success: %s' % r.text)
    secret = r.json()['secret']
    blimp_vars_string = "CLOUDFLEET_DOMAIN=%s\nCLOUDFLEET_SECRET=%s\n" % (domain, secret)

    with open(blimp_vars_path, 'w') as blimp_vars_file:
        blimp_vars_file.write(blimp_vars_string)

    quit(0)
else:
    print('Error: %s' % r.text)
    quit(1)
