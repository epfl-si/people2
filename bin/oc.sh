#!/bin/bash

# default cluster/namespace
CLUSTER_URL="https://api.ocpitsp0001.xaas.epfl.ch:6443"
OCNAMESPACE=svc0033p-people

die() {
  echo "Error: $*" >&2
  exit 1
}

oc4 () {
  echo "CLUSTER_URL: $CLUSTER_URL"
  echo "OCNAMESPACE: $OCNAMESPACE"
  if ! oc whoami > /dev/null 2>&1 || ! oc whoami --show-server | grep -q "$CLUSTER_URL"; then
      echo "Logging into OpenShift cluster at $CLUSTER_URL..."
      oc login "$CLUSTER_URL" --web;
  fi
}

ocpod_app () {
  oc get pods -n $OCNAMESPACE -l role=app --no-headers -o name --field-selector=status.phase==Running | tail -n 1
}

shell () {
  oc rsh -n $OCNAMESPACE $(ocpod_app) /bin/bash
}

console () {
echo "CLUSTER_URL: $CLUSTER_URL"
echo "OCNAMESPACE: $OCNAMESPACE"
  # echo "in console: OCNAMESPACE=$OCNAMESPACE    pod=$(ocpod_app)"
  return
  oc rsh -n $OCNAMESPACE $(ocpod_app) ./bin/rails console
}

logs () {
  oc logs -f -n $OCNAMESPACE -l role=app
}

cmd=""
while [ $# -gt 0 ] ; do
case $1 in
--test)
  CLUSTER_URL="https://api.ocpitst0001.xaas.epfl.ch:6443"
  OCNAMESPACE=svc0033t-people
  shift 1
  ;;
--prod)
  # prod is the default: non need to set anything
  shift 1
  ;;
*)
  cmd="$1"
  shift 1
  ;;
esac
done

[ -n "$cmd" ] || die "please provide one of the following commands as cmdline arg: console logs shell"

oc4
$cmd
