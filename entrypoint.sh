#!/bin/sh
set -e

# default is to call clamd withoud args or with the provided args
if [ "$(echo $1|cut -b 1)" = "-" ]; then
  set -- dcrd "$@"
fi

exec "$@"
