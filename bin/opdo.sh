#!/bin/bash
# set -x
. ./.env
. ${SECFILE}

URL=${SPYWARE_URL:-https://itsaudit0025.xaas.epfl.ch:9200}
AUTH="-H 'Aauthorization: ApiKey ${SPYWARE_KEY}'"

json='{"timestamp": "2025-09-30T08:51:42.682Z","handler_id": "121769","handled_id": "182447","crudt": "create","source": "192.168.129.1","payload": "XXX"}'

curl -k -X POST \
    -H "Authorization: ApiKey ${SPYWARE_KEY}" \
    -H 'accept: application/json'  -H 'Content-Type: application/json' \
    -d "'$json'" \
    $URL/opdo-test
