#!/bin/bash
set -e
# set -x
. .env
COMPOSE="${COMPOSE:-docker-compose.yml}"
DATASRC="${DATASRC:-peo1}"

DUMPDIR="${DUMPDIR:-tmp/dbdumps}"

ACCRED_TABLES="accreds accreds_properties classes deputations guests positions properties properties_units properties_status properties_classes rights rights_classes rights_persons rights_roles rights_statuses rights_units roles_persons statuses"
BOTTIN_TABLES="annuaire_adrspost annuaire_persons annuaire_persphones annuaire_persrooms annuaire_phones rooms"
CADI_TABLES="DBClients Manco WSAppsCallers WSAppsHosts WSClients WSServices batch_executions batch_params champs config datafields datatypes dbs delegates eventstypes filters operations pendingnotifications providers resources resources_types subscriptions tbls"
DINFO_TABLES="SwitchAAIUsers accounts accred adrspost allunits annu annu_new delegues emails externalids fonds groups isa_codes locaux Personnel sciper unites_reorg21 unites unites1 isa_etu"
CV_TABLES="" 

dbs=$(mktemp "/tmp/XXXXX")
trap "rm -f $dbs" EXIT

die() {
	echo "$*" >&2
	exit 1
}

fixdb() {
	sed 's/0000-00-00 00:00:00/NULL/g' | sed -E "s/(datetime|timestamp) NOT NULL DEFAULT 'NULL'/\1 NOT NULL/g" | sed -E "s/DEFAULT *'NULL'/DEFAULT NULL/g"
}

db_secret() {
	db=$1
	col=$2	
	[ -s $dbs ] || scp $DATASRC:/opt/dinfo/etc/dbs.conf $dbs
	s=$(gawk -v db="$db" -v col="$col"  '($1 == db){printf("%s", $col);}' $dbs)
	echo "db_secret: db=$db  col=$col  -> $s" >&2
	echo $s
}

exec_mysql() {
	db=$1
	docker-compose -f $COMPOSE exec -T mariadb mysql -u root --password=mariadb -D $db
}


restore() {
	db=$1
	case $db in 
	accred)
		tables="$ACCRED_TABLES"; ;;
	cadi)
		tables="$CADI_TABLES"; ;;
	dinfo)
		tables="$DINFO_TABLES"; ;;
	bottin)
		tables="$BOTTIN_TABLES"; ;;
	*)
		tables=""; ;;
	esac

	h="$(db_secret $db 3)"
	u="$(db_secret $db 4)"
	p="$(db_secret $db 5)"

	[ -d $DUMPDIR ] || mkdir -p $DUMPDIR

	dumpfile=$DUMPDIR/${db}_dump.sql.gz

	# dump="mysqldump -h $h -u $u -p'$p' $db $tables | gzip"
	# ssh -C $DATASRC "mysqldump -h $h -u $u -p'$p' $db $tables | gzip"
	if [ ! -f $dumpfile ] ; then
		ssh -C $DATASRC "mysqldump -h $h -u $u -p'$p' $db $tables | gzip" > $dumpfile
	fi
	gunzip -c  $dumpfile | fixdb | exec_mysql $db

	# add missing indexes
	if [ "$db" == "cv" ] ; then
		index="sciper"
		for t in awards boxes edu parcours publications research_ids ; do 
			ic=$(echo "SELECT COUNT(1) IndexIsThere FROM INFORMATION_SCHEMA.STATISTICS WHERE table_schema='cv' AND table_name='$t' AND index_name='$index';"  |exec_mysql $db | tail -n 1)
			if [ "$ic" == "0" ] ; then
				echo "Table $db.$t: index for sciper needs to be added"
				echo "ALTER TABLE $t ADD INDEX ($index);" | exec_mysql $db
			else
				echo "Table $db.$t: index for sciper alreaty present"
			fi
		done
	fi
}

# ------------------------------------------------------------------------------

db=$1

if [ "$db" == "all" ] ; then
	for db in accred bottin cadi cv dinfo ; do
		restore $db
	done
else
	restore $db
fi
