#!/bin/bash
# Examples of queries to api.epfl.ch that can be useful
# ./bin/api_epfl.sh > api_examples.txt

. .env
. ${KBPATH:-/keybase/team/epfl_people.prod}/${SECRETS:-secrets_prod.sh}
BASE="https://api.epfl.ch/v1"

apiget() {
  if [ -n "$2" ] ; then
    curl --basic --user "people:${EPFLAPI_PASSWORD}" \
         -X GET "$1" 2>/dev/null | jq -r "$2"
  else
    curl --basic --user "people:${EPFLAPI_PASSWORD}" -X GET "$1"
  fi
}

if [[ "$1" == ${BASE}* ]] ; then
  apiget "$1" "$2"
else
  apiget "${BASE}/$1" "$2"
fi
