# People dev Makefile
# `make help` to get the list of available rules
SHELL=/bin/bash
-include .env
KEYBASE ?= /keybase
KBPATH ?= $(KEYBASE)/team/epfl_people.prod
SECFILE ?= $(KBPATH)/secrets.sh

-include $(SECFILE)

COMPOSE_FILE ?= docker-compose.yml
SSH_AUTH_SOCK_FILE ?= $(SSH_AUTH_SOCK)
SSH_AUTH_SOCK_DIR = $(dir $(SSH_AUTH_SOCK_FILE))

ELE_SRCDIR ?= ./vendor/elements
ELE_DSTDIR = ./app/assets/stylesheets/elements
ELE_FILES = $(addprefix $(ELE_DSTDIR)/,elements.css vendors.css bootstrap-variables.scss)


# REBUNDLE ?= $(shell if [ -f Gemfile.lock.docker ] ; then echo "no" ; else echo "yes" ; fi)

# NOCIMAGE ?= nicolaka/netshoot
NOCIMAGE ?= jonlabelle/network-tools
# Figure out the ip address of the host machine so that we can use "public"
# dns names served by traefik from within the containers when the name is
# resolved as 127.0.0.1 like for all Giovanni's domains with glob ssl certs.
DOCKER_IP ?= $(shell docker run -it --rm $(NOCIMAGE) dig +short host.docker.internal)

DUMPDIR ?= tmp/dbdumps

KCDUMPFILE ?= $(DUMPDIR)/keycloak.sql

export

SQL = docker compose exec -T mariadb mariadb -u root --password=mariadb
SQLDUMP = docker compose exec -T mariadb mariadb-dump --password=mariadb

RAKE = docker compose exec webapp bin/rails

## ---------------------------------------------------------- Run/stop local app
.PHONY: css dev up reload kc down fulldown traefik tunnel_up tunnel_down

## start the dev env with sass builder and app server (try to emulate ./bin/dev)
dev: up
	./bin/dev -f Procfile.docker
	make down

css:
	bin/rails dartsass:watch
## start the dev tunnel and start all the servers
up: traefik tunnel_up dcup

## restart the webapp container
reload: envcheck
	docker compose stop webapp
	KILLPID=1 docker compose up -d

## restart puma withoud taking down the running container (in case of changes in gem's code within the container)
pumareload:
	docker compose exec webapp kill -SIGUSR2 1

## reload nginx configuration of the legacy server proxy
legacyreload:
	docker compose exec legacy nginx -s reload

## stop the basic servers (all except test)
down: tunnel_down
	docker compose down

## stop everything including keycloak and the test server
fulldown:
	docker compose --profile test down
	docker compose --profile kc   down
	docker compose down

traefik:
	@if [ -n "$(TRAEFIK_PATH)" ] ; then cd "$(TRAEFIK_PATH)" && make up ; fi

tunnel_up:
	./bin/tunneld.sh -m local start

tunnel_down:
	./bin/tunneld.sh -m local stop

dcup: envcheck $(ELE_FILES)
	docker compose up --no-recreate -d

## -------------------------------------------------- Interaction with local app
.PHONY: logs ps top console shell dbconsole debug redis dbstatus flush

## tail -f the logs
logs:
	docker compose logs -f

llogs:
	docker compose logs --since 10s -f

# ## show TUI for reading structured logs (not very usefull IMHO but nice)
# slogs:
# 	docker compose exec -it webapp bundle exec log_bench log/structured.log
slogs:
	docker compose exec -it webapp tail -f log/structured.log

## show the status of running containers
ps:
	docker compose ps

## show memory and cpu usage off all containers
top:
	docker stats

## start a rails console on the webapp container
console: dcup
	docker compose exec webapp ./bin/rails console

## start a shell on the webapp container
shell: dcup
	docker compose exec webapp /bin/bash

## start an sql console con the database container
dbconsole: dcup
	docker compose exec mariadb mariadb -u root --password=mariadb
	# docker compose exec webapp ./bin/rails dbconsole

## attach the console of the rails app for debugging
debug:
	docker-compose attach webapp

## start console for interacting with redis db
redis:
	docker compose exec cache valkey-cli

## toggle Rails caching in dev (will persist reloads as it is just a file in tmp)
devcache:
	$(RAKE) dev:cache

## start a shell within a container including all usefull network tools
noc:
	docker compose --profile noc run --rm noc

## show mariadb/INNODB status
dbstatus:
	echo $$(echo "SHOW ENGINE INNODB STATUS" | $(SQL))

## show code stats and versions
about:
	./bin/rails about && ./bin/rails stats

## flush cache from redis db
flush:
	docker compose exec cache redis-cli FLUSHALL

## ------------------------------------------------------------- Container image
.PHONY: build rebuild

## build the web app docker image
build: envcheck $(ELE_FILES) VERSION gems
	docker compose build

## build image discarding all cached layers
rebuild: envcheck VERSION
	rm -f Gemfile.lock
	docker compose build --no-cache
	docker run --rm people2023-webapp /bin/cat /rails/Gemfile.lock > Gemfile.lock

envcheck: .env .git/hooks/pre-commit


GDIR=vendor/gems
GEMS=opdo-rails openai-ruby
gems: $(GDIR) $(addprefix $(GDIR)/,$(GEMS))

$(GDIR):
	mkdir -p $(GDIR)

$(GDIR)/opdo-rails:
	cd $(GDIR) && git clone https://github.com/epfl-si/opdo-rails.git

$(GDIR)/openai-ruby:
	cd $(GDIR) && git clone https://github.com/openai/openai-ruby.git

## ----------------------------------------- Source code and dev env maintenance
.PHONY: erd codecheck cop docop dodocop minor patch

## generate an entity relation diagram with mermaid_erd
erd:
	docker compose exec webapp ./bin/rails mermaid_erd


## check the code with linter and run all automated tests (TODO)
codecheck: cop
	# TODO: automated tests too...
	# bundle-audit returns 1 if there are vulnerabilities => prevents build
	# nicer gui available at https://audit.fastruby.io
	#	bundle exec bundle-audit check --update
	#	bundle exec brakeman

## run rubocop linter to check code copliance with style and syntax rules
cop:
	./bin/rubocop

## run rubocop linter in autocorrect mode
docop:
	# ./bin/bundle exec rubocop --autocorrect
	./bin/rubocop --autocorrect

## run rubocop linter in autocorrect-all mode
dodocop:
	./bin/rubocop --autocorrect-all

VERSION:
	git tag -l --sort=creatordate | tail -n 1 | sed 's/\n//' > $@

## add git tag using value stored in VERSION file
tag: VERSION
	b=$$(git tag -l --sort=creatordate | tail -n 1); a=$$(cat VERSION); [ "$$a" == "$$b" ] || git tag -a $$a

## increase minor version
minor: VERSION
	./bin/rails version:minor
	@echo "remember to 'make tag' to store it into git once you have the commit"

## increase patch version
patch: VERSION
	./bin/rails version:patch
	@echo "remember to 'make tag' to store it into git once you have the commit"

.git/hooks/pre-commit:
	if [ ! -L .git/hooks ] ; then mv .git/hooks .git/hooks.trashme && ln -s ../.git_hooks .git/hooks ; fi

.env:
	@echo ".env file not present. Please copy .env.sample and edit to fit your setup"
	exit 1

.PHONY: elements elements_build

## Rebuild EPFL elements and copy here
elements: elements_build
	rsync -av $(ELE_SRCDIR)/dist/ public/elements/

elements_build: $(ELE_SRCDIR)
	cd $(ELE_SRCDIR) && NODE_VERSION=18 $(HOME)/.nvm/nvm-exec yarn install && NODE_VERSION=18 $(HOME)/.nvm/nvm-exec yarn dist

$(ELE_SRCDIR):
	cd $(dir $(ELE_SRCDIR)) && git clone git@github.com:epfl-si/elements.git

$(ELE_DSTDIR)/bootstrap-variables.scss: $(ELE_SRCDIR)/assets/config/bootstrap-variables.scss
	grep -E -v "^@include" $< > $@
# 	grep -E -v "^@include" $< | \
# 	gsed 's/theme-color(/map.get($$theme-colors, /g' | \
# 	gsed '/^@use /a @use "sass:map";' > $@

$(ELE_DSTDIR)/%.css: $(ELE_SRCDIR)/dist/css/%.css
	cp $< $@

# $(ELE_SRCDIR)/dist/css/*.css: elements_build

## --------------------------------------------------------------------- Testing
.PHONY: test testup test-system

## run automated tests
test:
	docker compose exec -e RAILS_ENV=test webapp ./bin/rails test

## prepare and run the test server
testup:
	docker compose --profile test up --no-recreate -d
	# TODO: find a way to fix this by selecting the good deps (stopped working
	# after an upgrade don't know if due to ruby or packages version.
	docker compose exec webapp sed -i '0,/end/{s/initialize(\*)/initialize(*args)/}' /usr/local/bundle/gems/capybara-3.39.0/lib/capybara/selenium/logger_suppressor.rb
	docker compose exec webapp sed -i '0,/end/{s/super/super args/}' /usr/local/bundle/gems/capybara-3.39.0/lib/capybara/selenium/logger_suppressor.rb

# testprepare:
# 	docker compose exec webapp ./bin/rails db:test:prepare
# 	docker compose exec -e RAILS_ENV=test webapp ./bin/rails db:migrate

test-system: testup
	docker compose exec webapp ./bin/rails test:system

test-models:
	docker compose exec webapp ./bin/rails test:models

## ---------------------------------------------- Off-line webmocks (deprecated)
.PHONY: webmocks refresh_webmocks

## copy webmocks from keybase. This will enable the off-line use (set ENABLE_WEBMOCK=true in .env)
webmocks:
	rsync -av --delete $(KBPATH)/webmocks/ test/fixtures/webmocks/

## generate and restore webmocks (can only be used from computer with access to remote servers)
refresh_webmocks:
	@ENABLE_WEBMOCK=false WEBMOCKS=$(KBPATH)/webmocks URLS=$(KBPATH)/webmock_urls.txt APIPASS=$(EPFLAPI_PASSWORD) RAILS_ENV=development ./bin/rails data:webmocks
	rsync -av --delete $(KBPATH)/webmocks/ test/fixtures/webmocks/

## ------------------------------------- DB and data initialization / management
.PHONY: fastreseed courses migrate nukedb nukestorage reseed reseed_translations scipers seed structs


## reload the list of all courses from ISA
courses: dcup
	$(RAKE) data:refresh_courses

## restart with a fresh new dev database for the webapp (faster version: does not refresh work db)
fastreseed:
	echo "DROP DATABASE IF EXISTS people" | $(SQL)
	echo "CREATE DATABASE people;" | $(SQL)
	sleep 2
	$(RAKE) db:migrate
	$(RAKE) db:seed
	make struct

## run rails migration
migrate: dcup
	docker compose exec webapp ./bin/rails db:migrate

# drop all databases (except legacy)
nukedb:
	echo "DROP DATABASE IF EXISTS people" | $(SQL)
	echo "CREATE DATABASE people;" | $(SQL)
	echo "DROP DATABASE IF EXISTS people_work" | $(SQL)
	echo "CREATE DATABASE people_work;" | $(SQL)
	# rm -f db/people_schema.rb
	# rm -f db/work_schema.rb

# remove local storage for file attachments
nukestorage:
	docker compose exec webapp /bin/bash -c "rm -rf storage/[0-9a-zA-Z][0-9a-zA-Z]"

## restart with a fresh new dev database for the webapp (slow version)
reseed: nukedb nukestorage
	rm -f tmp/ldap_scipers_emails.txt
	rm -f tmp/courses.json
	sleep 2
	make seed

## reload UI translations from the source code for /admin/translations UI
locales:
	docker compose exec webapp ./bin/rails admin:reseed_translations

## seed the data for Work::Sciper (more legacy related but might be used in the future too)
scipers: dcup
	$(RAKE) legacy:reload_scipers

## run rails migration and seed with initial data (does not include legacy-migration-related tasks)
seed: migrate structs scipers courses
	$(RAKE) db:seed

# retrive struct files from keybase
structs:
	rsync -av $(KBPATH)/structs/ tmp/structs/
	$(RAKE) legacy:struct

# ## load changed schema and seed
# reschema:
# 	$(RAKE) db:schema:load
# 	$(RAKE) db:seed
# 	make courses

## -------------------------------------------- legacy importation related tasks
.PHONY: legacy

## Remove files used to speed-up the legacy task to force
clean_legacy:
	rm -f $(DUMPDIR)/cv_dump.sql.gz
	rm -f $(DUMPDIR)/work_texts.sql.gz

## run tasks to setup importation from legacy data
legacy: restore db_restore_text
	$(RAKE) legacy:reload_scipers
	$(RAKE) legacy:load_texts
	$(RAKE) legacy:txt_lang_detect
	make db_backup_text
	$(RAKE) legacy:refresh_adoptions
	$(RAKE) legacy:import

## compute some stats for NM about profiles and languages in the legacy database
legacy_stats:
	docker compose exec webapp ./bin/rails legacy:editing_stats | egrep "^(###|---)" | sed 's/^###//' > LATEST_LEGACY_STATS.txt

## -------------------------------------------------------------------- Keycloak

## delete keycloak database and recreate it
rekc:
	docker compose stop keycloak
	echo "DROP DATABASE IF EXISTS keycloak;" | $(SQL)
	echo "CREATE DATABASE keycloak;" | $(SQL)
	# cat keycloak/initdb.d/keycloak-database-and-user.sql | $(SQL)
	echo "GRANT ALL PRIVILEGES ON keycloak.* TO 'keycloak'@'%';" | $(SQL)
	@echo "Keycloak db reset."

kconfig: up
	@/bin/bash -c 'while curl -I https://keycloak.dev.jkldsa.com/admin/master/console 2>/dev/null | grep -q "HTTP/2 502" ; do echo "waiting for kc to be alive (interrupt if it continues for more than ~40 secs)"; sleep 5; done'
	cd ops && ./possible.sh --dev -t keycloak.config

## ------------------------------------------------------- backup/restore dev db

## backup dev databases for a faster reseed
db_backup: db_backup_people db_backup_work

## restore dev databases for a faster reseed
db_restore: db_restore_people db_restore_work

db_backup_people:
	$(SQLDUMP) people | gzip > $(DUMPDIR)/people.sql.gz

db_backup_work:
	$(SQLDUMP) people_work | gzip > $(DUMPDIR)/work.sql.gz

db_restore_people:
	zcat $(DUMPDIR)/people.sql.gz | $(SQL) people

db_restore_work:
	zcat $(DUMPDIR)/work.sql.gz | $(SQL) people_work

db_backup_text:
	$(SQLDUMP) people_work texts | gzip > $(DUMPDIR)/work_texts.sql.gz

db_restore_text:
	b="$(DUMPDIR)/work_texts.sql.gz"
	if [ -f "$$b" ] ; then zcat "$$b" | $(SQL) people_work ; fi

## --------------------------------------------------------- Legacy DB from prod
# since we moved this to the external script we keep them just as a reminder

.PHONY: restore restore_cv restore_cadi restore_dinfo restore_accred restore_bottin

## restore the legacy databases (copy from the on-line DB server to local ones)
restore:
	./bin/restoredb.sh all

## force restore the legacy database forcing refetch of dumps from prod server
force_restore:
	./bin/restoredb.sh all --force

## restore the legacy `accred` database only
restore_accred:
	./bin/restoredb.sh accred

## restore the legacy `bottin` database only
restore_bottin:
	./bin/restoredb.sh bottin

## restore the legacy `cadi` database only
restore_cadi:
	./bin/restoredb.sh cadi

## restore the legacy `cv` database only
restore_cv:
	./bin/restoredb.sh cv

## restore the legacy `dinfo` database only
restore_dinfo:
	./bin/restoredb.sh dinfo

## -------------------------------------------------- Test (dev-like) deployment
.PHONY: nata_patch nata_reinit_legacy nata_reseed nata_update


## redeploy app on the test server for Natalie (docker image will be rebuilt if there is a new tag)
nata_update:
	cd ops && ./possible.sh --test -t people.src && ./possible.sh --test -t people.run && ./possible.sh --test -t people.admin.migrate

## patch the source code of the app mounted on the test server for Natalie (same image mounts new code)
nata_patch:
	cd ops && ./possible.sh --test -t people.src.patch

## reinitialize the test server with data from development workstations
nata_reinit: dcup
	ssh peonext 'rm -rf data/people/storage/*'
	docker compose exec webapp tar cvf - storage | ssh peonext "tar -xvf - -C data/people"
	$(SQLDUMP) people | ssh peonext "./bin/peopledb"
	$(SQLDUMP) people_work | ssh peonext "./bin/workdb"
	make nata_patch

nata_reinit_legacy: dcup
	$(SQLDUMP) cv | ssh peonext "./bin/legacydb"

## Download the interface translations and update the corresponding source files
nata_trans:
	curl -o /tmp/aaa.zip -H "Authorization: Basic $$(echo -n $(TRANS_USER):$(TRANS_PASS) | base64)" "https://$(TRANS_HOST)/admin/translations/export.zip"
	tar xvf /tmp/aaa.zip -C config
	rm /tmp/aaa.zip

# ## reseed the database on the test server for Natalie
# nata_reseed: test_patch
# 	cd ops && ./possible.sh --test -t people.db.reseed


## ---------------------------------------------------- Prod openshit deployment
APP_NAME ?= people
QUAY_REPO=quay-its.epfl.ch/svc0033

# Chemin vers le Dockerfile
DOCKERFILE=../../../Dockerfile

TAG=$(QUAY_REPO)/$(APP_NAME):$(shell cat VERSION)-prod
LPTAG=$(QUAY_REPO)/peolegacy:$(shell cat legacy/VERSION)

ciccio:
	echo lptag = $(AAA)

## Build docker image for the legacy proxy
lega_build: legacy/VERSION
	docker compose build --no-cache legacy
	docker build -t $(LPTAG) -f legacy/Dockerfile legacy

legacy/VERSION: legacy/nginx.conf
	awk '/^# VERSION/{print $$3};' $< > $@

## Build docker image for production
prod_build: envcheck $(ELE_FILES) VERSION gems
	docker build -t $(TAG) -f Dockerfile.prod .

## Push production docker image to internal quay registry
prod_push: prod_build lega_build
	docker push $(TAG)
	docker push $(LPTAG)

## Redeploy app to prod cluter
prod_deploy:
	cd ops && ./possible.sh --prod -t config.env -t run.app

## Redeploy app to prod cluter with next config (names changed in test)
next_deploy:
	cd ops && ./possible.sh --next -t run.app

## Build, tag and deploy app to production
prod: prod_push prod_deploy

## Build, tag and deploy app to production with next config (names changed in test)
next: prod_push next_deploy

## Open a shell on running production application pod
prod_shell:
	./bin/oc.sh --prod shell

## Open a rails console on running production application pod
prod_console:
	./bin/oc.sh --prod console

## Print logs from production application containers
prod_logs:
	./bin/oc.sh --prod logs

## Open a shell on running staging application pod
next_shell:
	./bin/oc.sh --prod --next shell

## Open a rails console on running staging application pod
next_console:
	./bin/oc.sh --prod --next console

## Print logs from staging application containers
next_logs:
	./bin/oc.sh --prod --next logs


OCMAINDBNAME=$(shell cat $(KBPATH)/ops/secrets.yml | ./bin/yq -r '.production.db.main_adm.dbname')
OCMAINDBHOST=$(shell cat $(KBPATH)/ops/secrets.yml | ./bin/yq -r '.production.db.main_adm.server')
OCMAINDBUSER=$(shell cat $(KBPATH)/ops/secrets.yml | ./bin/yq -r '.production.db.main_adm.username')
OCMAINDBPASS=$(shell cat $(KBPATH)/ops/secrets.yml | ./bin/yq -r '.production.db.main_adm.password')
## Open sql shell on main application database
prod_db:
	./bin/oc.sh --prod mariadb -h $(OCMAINDBHOST) -u $(OCMAINDBUSER) --password=$(OCMAINDBPASS) $(OCMAINDBNAME)

# ------------------------------------------------------------------------------
.PHONY: clean
clean:
	rm -f api_examples.txt
	rm -rf test/fixtures/webmocks
	rm -f $(ELE_FILES)
	docker rmi $(TAG) || true

# ------------------------------------------------------------------------------
.PHONY: help
help:
	@cat Makefile | gawk '                      \
		BEGIN{                                    \
			print "Available rules:";               \
		}                                         \
		/^## ---+ /{                              \
			gsub(/^## -+ /,"", $$0);                \
			printf("\n\033[1m%s\033[0m\n", $$0);    \
			next;                                   \
		}                                         \
		/^##/{                                    \
			gsub("^##", "", $$0);                   \
			i=$$0;                                  \
			getline;                                \
			gsub(/:.*$$/, "", $$0);                 \
			printf("%-16s  %s\n", $$0, i);          \
		}'
