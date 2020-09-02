#!/bin/sh
set -e

while [ "0" == "$(grep "RPC server listening" $1|wc -c)" ];
  do sleep 1
done

shift
exec "$@"
