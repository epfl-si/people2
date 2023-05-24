#!/bin/bash
set -e
. .env

PIDFILE=tunnel.pid
MODE=${TUNNELMODE:-local}

if [ "$1" == "-m" ] ; then
  MODE=$2
  shift 2
fi

case $MODE in
  tunneltest)
    # 'present' mode is for running the original application
    # directly connecting to the original test databases
    TUN1=0.0.0.0:50024:agatst02.epfl.ch:50024
    TUN2=0.0.0.0:3306:test-cadidb.epfl.ch:3306
    SSHCMD="ssh -T -N -L $TUN2 dinfo@test-dinfo1.epfl.ch"
    ;;
  staging)
    # 'present' mode is for running the original application
    # directly connecting to the original test databases
    TUN1=0.0.0.0:50024:agatst02.epfl.ch:50024
    TUN2=0.0.0.0:3306:db-cadi-staging.epfl.ch:3306
    SSHCMD="kubectl port-forward pods/mongo-75f59d57f4-4nd6q 28015:27017
kubectl ssh -T -N -L $TUN2 dinfo@test-dinfo1.epfl.ch"
    ;;
  tunnelprod|localcv)
    # 'past' mode is for running the original application
    # directly connecting to the original production databases
    TUN1=0.0.0.0:50315:agaprd01.epfl.ch:50315
    TUN2=0.0.0.0:3306:cadidb.epfl.ch:3306
    SSHCMD="ssh -T -N -L $TUN1 -L $TUN2 dinfo@dinfo1.epfl.ch"
    ;;
  local)
    # 'past' mode is for running the original application
    # directly connecting to the original production databases
    TUN1=0.0.0.0:50315:agaprd01.epfl.ch:50315
    SSHCMD="ssh -T -N -L $TUN1 dinfo@dinfo1.epfl.ch"
    ;;
  views)
    # 'future' mode is using the read-only view that is only
    # available on the production server. 
    TUN1=0.0.0.0:50315:agaprd01.epfl.ch:50315
    TUN2=0.0.0.0:3306:cadidb.epfl.ch:3306
    # Unfortunatelly we would need a third tunnel but thru a different machine (root@10.95.80.132)
    # TUN3=0.0.0.0:33006:mysql-scx.epfl.ch:33006
    SSHCMD="ssh -T -N -L $TUN1 -L $TUN2 dinfo@dinfo1.epfl.ch"
    ;;
  tunnelkube)
    # 'future' mode is using the read-only view that is only
    # available on the production server. 
    TUN1=0.0.0.0:50315:agaprd01.epfl.ch:50315
    TUN2=0.0.0.0:3306:cadidb.epfl.ch:3306
    SSHCMD="ssh -T -N -L $TUN1 -L $TUN2 root@10.95.80.132"
    ;;
  *)
    echo "Invalid mode '$MODE'. Please use either 'present' or 'future'" >&2
    exit
    ;;
esac

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

