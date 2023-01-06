#!/bin/bash

python3 hostmap_to_caddy_json.py > ./caddy-ingress.json
docker exec caddy caddy reload --config /etc/caddy/caddy-ingress.json