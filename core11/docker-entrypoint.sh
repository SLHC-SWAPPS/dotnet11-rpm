#!/bin/bash
set -e

if [ "true" == "$DOCKERIZE" ]
then
  exec dockerize $DOCKERIZE_OPTS echo ""
fi

echo "Loading certificates..."
EXEC="/usr/local/bin/load-certificates.sh"
if ! $EXEC;
then
  echo "load of certificate(s) failed...continuing with startup..."
fi

exec "$@"
