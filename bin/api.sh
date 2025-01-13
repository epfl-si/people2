#!/bin/bash
# Examples of queries to api.epfl.ch that can be useful
# ./bin/api_epfl.sh > api_examples.txt
# ./bin/api.sh -r ".firstname" persons/121769   

. .env
. ${KBPATH:-/keybase/team/epfl_people.prod}/${SECRETS:-secrets_prod.sh}
BASE=${API_BASEURL:-https://api.epfl.ch/v1}

apiget() {
  url="$1"
  echo curl --basic --user "people:${EPFLAPI_PASSWORD}" \
    -X GET "$url" >&2
  curl --basic --user "people:${EPFLAPI_PASSWORD}" \
    -X GET "$url" 2>/dev/null
}

apiput() {
  echo "apiput"
  url="$1"
  data="$2"
  # echo curl --basic --user "people:${EPFLAPI_PASSWORD}" \
  #   -H 'Content-Type: application/json' \
  #   -d "'$data'" \
  #   -X PUT "$url"
  curl --basic --user "people:${EPFLAPI_PASSWORD}" \
    -H 'Content-Type: application/json' \
    -d "'$data'" \
    -X PUT "$url" 2>/dev/null
}

jqr=""
data=""
while [ $# -gt 0 ] ; do
case $1 in
-r) 
  jqr="$2"
  shift 2
  ;;
-d) 
  data="$2"
  shift 2
  ;;
*)
  url="$1"
  shift 1
  ;;
esac
done

if [[ "$url" != ${BASE}* ]] ; then
  url="${BASE}/$url"
fi

if [ -n "$data" ] ; then
  if [ -n "$jqr" ] ; then
    apiput "$url" "$data"  | jq -r "$jqr"
  else
    apiput "$url" "$data"
  fi
else
  if [ -n "$jqr" ] ; then
    apiget "$url" "$data"  | jq -r "$jqr"
  else
    apiget "$url" "$data"
  fi
fi
