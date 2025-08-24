#!/bin/bash
# set -x
# Wrapper script for http queries to the new Oasis server
# that is going to replace ISA

. ./.env
. ${SECFILE}
BASE=${OASIS_BASEURL:-https://oasis-t.epfl.ch:8484}

apiget() {
  url="$1"
  curl    -X GET -H "Authorization: Bearer ${OASIS_BEARER}" -H "accept: application/json" $url 2>/dev/null
  # curl -I -X GET -H "Authorization: Bearer ${OASIS_BEARER}" -H 'accept: application/json' $url
}

jqr=""
data=""
while [ $# -gt 0 ] ; do
case $1 in
-r)
  jqr="$2"
  shift 2
  ;;
-v)
  verbose=1
  echo "Using base $BASE"
  shift 1
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

if [ -n "$jqr" ] ; then
  apiget "$url" "$data"  | jq -r "$jqr"
else
  apiget "$url" "$data"
fi
