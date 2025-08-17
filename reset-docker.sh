#!/usr/bin/env bash

docker-compose down
rm -rf tmp && mkdir tmp
docker-compose up -d
docker exec -it mcp-container bash