#!/bin/bash
. ./.env
# set -x

confirm() {
  read -p "$* (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  else
    echo "Good choice!"
    exit 1
  fi
}

die() {
  echo "Error: $*" >&2
  exit 1
}

[ "$(whoami)" != "cangiani" ] && die "Only Giovanni is allowed to commit suicide!"

which -s mariadb || die "mariadb not found"
which -s mariadb-dump || die "mariadb-dump not found"

OCNAMESPACE=svc0033p-people
OCPOD_APP=$(oc get pods -n $OCNAMESPACE -l role=app --no-headers -o name --field-selector=status.phase==Running | tail -n 1)
[ -n "$OCPOD_APP" ] || die "Could not find the application pod. You might need to run login to openshit first."

SECRETS=${KBPATH:-/keybase/team/epfl_people.prod}/ops/secrets.yml
[ -f "$SECRETS" ] || die "Could not find secrets file. Please make sure keybase is running"

OCMAINDBNAME=$(cat $SECRETS | ./bin/yq -r '.production.db.main_adm.dbname')
OCMAINDBHOST=$(cat $SECRETS | ./bin/yq -r '.production.db.main_adm.server')
OCMAINDBUSER=$(cat $SECRETS | ./bin/yq -r '.production.db.main_adm.username')
OCMAINDBPASS=$(cat $SECRETS | ./bin/yq -r '.production.db.main_adm.password')

confirm "This is irreversible. Are you sure ?"
confirm "This is irreversible. Are you really really sure ?"

now=$(date +%F-%s)

bkp=./tmp/dbdumps/$now.sql.gz
echo "Hope you know what you're doing! We are dumping it in anycase as $bkp"

mariadb-dump -h $OCMAINDBHOST -u $OCMAINDBUSER --password=$OCMAINDBPASS $OCMAINDBNAME | gzip > $bkp
[ "$?" -ne 0 ] && die "Failed to dump database. Stopping here."

maria(){
  # oc rsh -T -n $OCNAMESPACE $OCPOD_APP mariadb -h $OCMAINDBHOST -u $OCMAINDBUSER --password=$OCMAINDBPASS $OCMAINDBNAME
  mariadb -h $OCMAINDBHOST -u $OCMAINDBUSER --password=$OCMAINDBPASS $OCMAINDBNAME
}

tables=$(echo "show tables;" | maria | tail -n +2 | paste -sd "," -)
while [ -n "$tables" ] ; do
  # echo "tables: $tables"
  echo "DROP TABLE IF EXISTS $tables ;" | maria
  sleep 2
  tables=$(echo "show tables;" | maria | tail -n +2 | paste -sd "," -)
done

echo "All tables dropped. Deleting storage"
oc rsh -n $OCNAMESPACE $OCPOD_APP mkdir -p /trash/storage_deleted_$now
oc rsh -n $OCNAMESPACE $OCPOD_APP mv "/rails/storage/*" /trash/storage_deleted_$now/

echo "Migrating and seeding"
oc rsh -n $OCNAMESPACE $OCPOD_APP ./bin/rails db:migrate
oc rsh -n $OCNAMESPACE $OCPOD_APP ./bin/rails db:seed

echo "All done! Mo' so' cazzi tua!"
