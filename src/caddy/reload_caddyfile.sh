#!/bin/bash
docker exec -w /etc/caddy caddy caddy reload
docker exec -w /etc/caddy caddy caddy fmt