#!/bin/bash
ldir=/rails/log
bdir=/rails/storage/logs/
now=date +%F.%s
e=${1:-production}

die() {
  echo "$1" >&2
  exit 1
}

[ -d $bdir ] || die "logs backup dir $bdir not present"
cd $ldir || die "could not change to log dir $ldir"

# all log files
al=$(ls -1rt $e_*.log)
# last (current) log file
cl=$(ls -1rt $e_*.log | tail -n 1)

# compress and backup all old files and the current one
cat $al | gzip > ${bdir}/${e}_${now}.log.gz

# truncate the current log file
: > $cl
