#!/bin/bash

set -e

until $(curl --output /dev/null --silent --head --fail http://api:4000); do
  >&2 echo 'Waiting for rails'
  sleep 5
done

>&2 echo "Rails is up - executing command"

yarn start
