#!/bin/bash
# Examples of queries to api.epfl.ch that can be useful
# ./bin/api_epfl.sh > api_examples.txt

. .env
. ${KBPATH:-/keybase/team/epfl_people.prod}/${SECRETS:-secrets_prod.sh}
BASE=${API_BASEURL:-https://api.epfl.ch/v1}



apiget() {
  curl --basic --user "people:${EPFLAPI_PASSWORD}" \
       -X GET "$1" 2>/dev/null
}

if [[ "$1" == ${BASE}* ]] ; then
  url="$1"
else
  url="${BASE}/$1"
fi
echo "url=$url"
if [ -n "$2" ] ; then
  apiget "$url" | jq -r "$2"
else
  apiget "$url"
fi
