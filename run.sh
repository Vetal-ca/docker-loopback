#!/usr/bin/env sh

set -o errexit
set -o nounset

usage ()
{
    echo "Usage: ${0##*/} loopback_subnet [name]"
    exit 1
}


if [ -z "${1}" ]; then
  usage
else
  loopback_subnet="${1}"
fi

if [ -z "${2:-}" ]; then
  interface_name="lo:0"
else
  interface_name="${2}"
fi

echo "Creating loopback interface ${interface_name}, ${loopback_subnet}"

if ! ip addr add "${loopback_subnet}" dev lo label "${interface_name}"; then
  echo "Unable to create the interface"
  exit 1
fi

tail -fn0 "$0" & PID=$!
trap "kill ${PID}" INT TERM

wait

echo "Shutting down, removing interface ${interface_name}"
ip addr del "${loopback_subnet}" dev "${interface_name}"
