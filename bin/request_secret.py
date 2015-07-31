#!/usr/bin/python

import requests, sys, json
from Crypto.Signature import PKCS1_PSS
from Crypto.PublicKey import RSA
from Crypto.Hash import SHA256

domain = sys.argv[1]
key_path = sys.argv[2]
blimp_vars_path = sys.arv[3]


secret_req_url = 'https://spire.cloudfleet.io/api/v1/blimp/%s/secret' % domain

print('getting secret')

with open(key_path, 'rb') as key_file:
    key = key_file.read()

rsa_key = RSA.importKey(key)

signer = PKCS1_PSS.new(rsa_key)

hash = SHA256.new()
hash.update(domain)

signature = base64.b64encode(signer.sign(hash))

r = requests.get(secret_req_url, headers={"X_AUTH_DOMAIN":signature})

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
