#!/bin/bash
set -x
set -e
ldir=/rails/log
bdir=/rails/storage/logs_next/
now=$(date +%F.%s)
e=${1:-production}

die() {
  echo "$1" >&2
  exit 1
}

[ -d $bdir ] || die "logs backup dir $bdir not present"

# compress and backup all the log files
cat $(ls -1rt $ldir/$e_*.log) | gzip > ${bdir}/${e}_${now}.log.gz

# The old files are removed
find $ldir -name "${e}_*.log" -cmin -180 -exec rm {} +

# truncate current (actually recent) ones
for f in $(ls -1rt $ldir/$e_*.log); do
  : > $f
done
