#!/bin/sh

echo "Running as: $(whoami)"

echo
echo "Environment:"
env

echo
echo "Arguments:"
while [ $# -gt 0 ]; do
  echo "$1"
  shift
done
