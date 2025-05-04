#!/bin/bash
# Examples of queries to api.epfl.ch that can be useful
# ./bin/api_epfl.sh > api_examples.txt
# ./bin/api.sh -r ".firstname" persons/121769   

set -x

. ./.env
. ${KBPATH:-/keybase/team/epfl_people.prod}/${SECRETS:-secrets_prod.sh}
BASE=${API_BASEURL:-https://api.epfl.ch/v1}

ENCPAS=$(echo -n "people:${EPFLAPI_PASSWORD}" | base64)
AUTH="--basic --user people:${EPFLAPI_PASSWORD}"
curl -X 'PUT' \
   'https://api-test.epfl.ch/v1/persons/121769' \
   -H "authorization: Basic ${ENCPAS}" \
   -H 'accept: application/json' \
   -H 'Content-Type: application/json' \
   -d '{
   "firstnameusual": "Giovanni",
   "genderusual": "M",
   "lastnameusual": "Cangiani",
   }'
