#!/bin/bash
set -e
. .env

if [ "$1" == "-m" ] ; then
  TUNNEL_MODE=$2
  shift 2
fi

case $TUNNEL_MODE in
  prod)
    # 'past' mode is for running the original application
    # directly connecting to the original production databases
    TUN1=0.0.0.0:50315:agaprd01.epfl.ch:50315
    SSHCMD="ssh -T -N -L $TUN1 dinfo@dinfo11.epfl.ch"
    ;;
  test)
    # 'past' mode is for running the original application
    # directly connecting to the original production databases
    TUN1=0.0.0.0:50024:agatst02.epfl.ch:50024
    SSHCMD="ssh -T -N -L $TUN1 dinfo@test-dinfo1.epfl.ch"
    ;;
  *)
    echo "Invalid mode '$TUNNEL_MODE'. Please use either 'present' or 'future'" >&2
    exit
    ;;
esac
[[ "$WITH_TUNNEL" == y* ]] || exit
$SSHCMD
