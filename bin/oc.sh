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
  oc -n $OCNAMESPACE get pods -l role=app --no-headers -o name --field-selector=status.phase==Running | tail -n 1
}

logs () {
  oc -n $OCNAMESPACE logs -f -l role=app
}

cmd=""
fun=""
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
shell)
  cmd=/bin/bash
  shift 1
  ;;
console)
  cmd="./bin/rails console"
  shift 1
  ;;
logs)
  fun=logs
  shift 1
  ;;
*)
  cmd="$cmd $1"
  shift 1
  ;;
esac
done

oc4

if [ -n "$fun" ] ; then
  $fun
else
  if [ -n "$cmd" ] ; then
    oc -n $OCNAMESPACE rsh $(ocpod_app) $cmd
  else
    die "please provide a command to be executed one the application pod or one of the following function names as cmdline arg: console logs shell"
  fi
fi
