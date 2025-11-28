#!/bin/bash
set -x
set -e
inst=$(hostname | sed -E 's/app-([a-z]+)-([a-z]+)-.*$/\1_\2/')
ldir=/rails/log
bdir=/rails/storage/logs/${inst}/
now=$(date +%F.%s)
e=${1:-production}

die() {
  echo "$1" >&2
  exit 1
}

[ -d $bdir ] || die "logs backup dir $bdir not present"

rotated_files=$(ls -1rt $ldir/$e_*.log.[0-9])
cat $rotated_files | gzip > ${bdir}/${e}_${now}.log.gz
rm $rotated_files
