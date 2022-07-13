#!/bin/bash

# Get and append the docker host IP to the .env file if it isn't there already.
set -euo pipefail
grep -q DOCKER_HOST_IP .env \
  || ruby /usr/bin/resolve_docker_host.rb

# This is to fix a Rails-specific issue that prevents the server from restarting when a certain server.pid file pre-exists.
set -e
rm -f /myapp/tmp/pids/server.pid
exec "$@"
