#!/bin/bash
# Examples of queries to api.epfl.ch that can be useful
# ./bin/api_epfl.sh > api_examples.txt
# ./bin/api.sh -r ".firstname" persons/121769

set -x

. ./.env
. ${SECFILE}
BASE=${EPFLAPI_BACKEND_URL:-https://api.epfl.ch/v1}

ENCPAS=$(echo -n "people:${EPFLAPI_PASSWORD}" | base64)
# AUTH="--basic --user people:${EPFLAPI_PASSWORD}"

curl --request PATCH \
 --url https://api.epfl.ch/v1/persons/121769 \
 --header "authorization: Basic $ENCPAS" \
 --header 'content-type: application/json' \
 --data '{"genderusual":"M"}'
exit

# curl -X 'GET' \
#   'https://api-test.epfl.ch/v1/persons/121769' \
#    -H "authorization: Basic ${ENCPAS}" \
#    -H 'accept: application/json'
# exit

# curl -X 'PATCH' \
#    'https://api.epfl.ch/v1/persons/121769' \
#    -H "authorization: Basic ${ENCPAS}" \
#    -H 'accept: application/json' \
#    -H 'Content-Type: application/json' \
#    -d '{
#     "firstnameusual":"Giovanni",
#     "lastnameusual": "Cangiani",
#     "genderusual": "M"
#    }'

curl -X PATCH ${BASE}/persons/121769 \
     -H 'accept: application/json' \
     -H 'Content-Type: application/json' \
     -d '{"genderusual":"X"}' \
     --header "authorization: Basic $ENCPAS"
     # -d '{"firstnameusual":"Giovanni","lastnameusual":"Cangiani","genderusual":"M"}' \


# curl -X 'PUT' \
#    'https://api.epfl.ch/v1/persons/121769' \
#    -H "authorization: Basic ${ENCPAS}" \
#    -H 'accept: application/json' \
#    -H 'Content-Type: application/json' \
#    -d '{
#     "firstname":"Giovanni Carlo",
#     "lastname":"Cangiani",
#     "birthdate":"1969-08-20T00:00:00",
#     "gender":"M",
#     "firstnameusual":"Giovanni",
#     "lastnameusual":"Cangiani",
#     "genderusual ":"M"
#    }'
