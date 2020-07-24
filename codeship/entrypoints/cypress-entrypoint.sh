#!/bin/bash
set -e

until $(curl --output /dev/null --silent --head --fail http://react:3000); do
  >&2 echo 'Waiting for react'
  sleep 5
done

yarn test:cypress:acceptance
