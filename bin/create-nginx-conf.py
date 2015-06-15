#!/usr/local/bin/python

from jinja2 import Environment, FileSystemLoader, StrictUndefined
import os

jinja = Environment(loader=FileSystemLoader(os.path.dirname(os.path.realpath(__file__)) + "/../templates"), undefined=StrictUndefined)
template = jinja.get_template("cloudfleet.conf")

data = {}

with open("/opt/cloudfleet/data/config/apps.yml", "r") as fh:
  data.update(yaml.safe_load(fh))

with open("/opt/cloudfleet/data/shared/users/users.json", "r") as fh:
  data.update(yaml.safe_load(fh))

with open("/opt/cloudfleet/data/config/cache/nginx/cloudfleet.conf", "w") as fh:
  fh.write(template.render(data))
