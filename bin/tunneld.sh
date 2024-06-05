#!/bin/bash
set -e
. .env

PIDFILE=tunnel.pid

if [ "$1" == "-m" ] ; then
  TUNNEL_MODE=$2
  shift 2
fi

SSHCMD=$(dirname $0)/tunnel.sh

start() {
  if [[ "$WITH_TUNNEL" == y* ]] ; then
    if [ "$(status)" != "running" ] ; then
      $SSHCMD &
      NPID=$!
      if [ "$(status)" == "running" ] ; then
        echo "Started DB tunnel with PID=$NPID"
        echo "$NPID" > $PIDFILE
      else
        echo "Could not start DB tunnel" >&2
        exit 1
      fi
    fi
  else
    echo "Not starting DB tunnel. If you want it, please define env WITH_TUNNEL=yes" >&2
  fi
}

stop() {
  if [ "$(status)" == "running" ] ; then
    OPID=$(cat $PIDFILE)
    echo "Trying to kill tunnel process with pid '$OPID'"
    if kill $OPID ; then
      rm -f $PIDFILE 
    else
      echo "Could not kill DB tunnel running with pid $OPID"
    fi
  fi
}

# return tunnel status and perform housekeeping
status() {
  if ps ax | grep "$SSHCMD" | grep -q -v grep ; then
    ret="running"
    TPID=$(ps ax | awk "/awk/{next;}/$SSHCMD/{print \$1;}")
    if [ -f $PIDFILE ] ; then
      OPID=$(cat $PIDFILE)
      if [ "$OPID" != "$TPID" ] ; then
        echo "DB tunnel pid file is present but wrong: true/saved pid=$TPID/$OPID. Fixing." >&2
        echo "$TPID" > $PIDFILE
      fi
    else
      echo "DB tunnel pid file not present. Creating it." >&2
      echo "$TPID" > $PIDFILE
    fi
  else
    ret="stopped"
    [ -f $PIDFILE ] && rm -f $PIDFILE
  fi
  echo "$ret"
}

case $1 in
start)
  start
  ;;
stop)
  stop
  ;;
status)
  echo "DB tunnel is $(status)"
  ;;
*)
  echo "Invalid command $1" >&2
  exit 1
esac
