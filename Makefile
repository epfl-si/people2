# People dev Makefile
# `make help` to get the list of available rules
SHELL=/bin/bash
-include .env
KBPATH ?= /keybase/team/epfl_people.prod
-include $(KBPATH)/$(SECRETS)

COMPOSE_FILE ?= docker-compose.yml
SSH_AUTH_SOCK_FILE ?= $(SSH_AUTH_SOCK)
SSH_AUTH_SOCK_DIR = $(dir $(SSH_AUTH_SOCK_FILE))

ELE_SRCDIR ?= ../elements
ELE_DSTDIR = ./app/assets/stylesheets/elements
ELE_FILES = $(addprefix $(ELE_DSTDIR)/,elements.css vendors.css bootstrap-variables.scss)


REBUNDLE ?= $(shell if [ -f Gemfile.lock.docker ] ; then echo "no" ; else echo "yes" ; fi)

# NOCIMAGE ?= nicolaka/netshoot
NOCIMAGE ?= jonlabelle/network-tools
# Figure out the ip address of the host machine so that we can use "public" 
# dns names served by traefik from within the containers when the name is
# resolved as 127.0.0.1 like for all Giovanni's domains with glob ssl certs. 
DOCKER_IP ?= $(shell docker run -it --rm $(NOCIMAGE) dig +short host.docker.internal)

KCDUMPFILE ?= tmp/dbdumps/keycloak.sql

export

SQL=docker compose exec -T mariadb mariadb -u root --password=mariadb
SQLDUMP=docker compose exec -T mariadb mariadb-dump --password=mariadb

# ----------------------------------------------------------- Run/stop local app
.PHONY: css dev up reload kc down fulldown tunnel_up tunnel_down

## start the dev env with sass builder and app server (try to emulate ./bin/dev)
dev: up
	./bin/dev -f Procfile.docker
	make down

css: 
	bin/rails dartsass:watch
## start the dev tunnel and start all the servers
up: tunnel_up dcup

## restart the webapp container
reload: envcheck
	docker compose stop webapp
	KILLPID=1 docker compose up -d

## stop the basic servers (all except test)
down: tunnel_down
	docker compose down

## stop everything including keycloak and the test server
fulldown:
	docker compose --profile test down
	docker compose --profile kc   down
	docker compose down

tunnel_up:
	./bin/tunneld.sh -m local start

tunnel_down:
	./bin/tunneld.sh -m local stop

dcup: envcheck Gemfile.lock $(ELE_FILES)
	docker compose up --no-recreate -d

Gemfile.lock: Gemfile.lock.docker
	cp $< $@

# --------------------------------------------------- Interaction with local app
.PHONY: logs ps top console shell dbconsole debug redis dbstatus

## tail -f the logs
logs:
	docker compose logs -f

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
	docker compose exec webapp bin/rails dev:cache

## start a shell within a container including all usefull network tools
noc:
	docker compose --profile noc run --rm noc 

## show mariadb/INNODB status
dbstatus:
	echo $$(echo "SHOW ENGINE INNODB STATUS" | $(SQL))

## show code stats and versions
about:
	./bin/rails about && ./bin/rails stats

# -------------------------------------------------------------- Container image
.PHONY: build rebuild

## build the web app and atela container
build: envcheck $(ELE_FILES) #codecheck
	if [ "$(REBUNDLE)" == "yes" ] ; then rm -f Gemfile.lock ; else cp Gemfile.lock.docker Gemfile.lock ; fi
	docker compose build
	if [ "$(REBUNDLE)" == "yes" ] ; then docker compose run webapp cat /rails/Gemfile.lock > Gemfile.lock.docker ; fi

## build image discarding all cached layers
rebuild: envcheck
	docker compose build --no-cache



envcheck: .env .git/hooks/pre-commit

# ------------------------------------------ Source code and dev env maintenance
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
	bundle exec rubocop --extra-details 2>/dev/null

## run rubocop linter in autocorrect mode
docop:
	./bin/bundle exec rubocop --autocorrect

## run rubocop linter in autocorrect-all mode
dodocop:
	./bin/bundle exec rubocop --autocorrect-all

## increase minor version
minor:
	./bin/rails version:minor

## increase patch version
patch:
	./bin/rails version:patch



.git/hooks/pre-commit:
	if [ ! -l .git/hooks ] ; then mv .git/hooks .git/hooks.trashme && ln -s ../.git_hooks .git/hooks ; fi

.env:
	@echo ".env file not present. Please copy .env.sample and edit to fit your setup"
	exit 1

$(ELE_DSTDIR)/bootstrap-variables.scss: $(ELE_SRCDIR)/assets/config/bootstrap-variables.scss
	grep -E -v "^@include" $< > $@
# 	grep -E -v "^@include" $< | \
# 	gsed 's/theme-color(/map.get($$theme-colors, /g' | \
# 	gsed '/^@use /a @use "sass:map";' > $@

$(ELE_DSTDIR)/%.css: $(ELE_SRCDIR)/dist/css/%.css
	cp $< $@

$(ELE_SRCDIR)/dist/css/*.css:
	cd $(ELEMENTS_DIR) && yarn build	

# ---------------------------------------------------------------------- Testing
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

# test-models:
# 	docker compose exec webapp ./bin/rails test:models

test-models:
	./bin/rails test:models

# -------------------------------------------------- Cache and off-line webmocks

## flush cache from redis db
flush:
	docker compose exec cache redis-cli FLUSHALL 

## copy webmocks from keybase. This will enable the off-line use (set ENABLE_WEBMOCK=true in .env)
webmocks:
	rsync -av --delete $(KBPATH)/webmocks/ test/fixtures/webmocks/

## generate and restore webmocks (can only be used from computer with access to remote servers)
refresh_webmocks:
	@ENABLE_WEBMOCK=false WEBMOCKS=$(KBPATH)/webmocks URLS=$(KBPATH)/webmock_urls.txt APIPASS=$(EPFLAPI_PASSWORD) RAILS_ENV=development ./bin/rails data:webmocks
	rsync -av --delete $(KBPATH)/webmocks/ test/fixtures/webmocks/

# ------------------------------------------------ migration data/db maintenance
.PHONY: migrate seed reseed nukedb restore_webmocks webmocks

## run rails migration
migrate: dcup
	docker compose exec webapp ./bin/rails db:migrate

## run rails migration and seed with initial data
seed: migrate webmocks
	docker compose exec webapp bin/rails db:seed
	make courses

## reload the list of all courses from ISA
courses: dcup
	docker compose exec webapp bin/rails data:courses


## restart with a fresh new dev database for the webapp
reseed:
	make nukedb
	sleep 2
	make seed

## delete the people database
nukedb:
	echo "DROP DATABASE people" | $(SQL)
	echo "CREATE DATABASE people;" | $(SQL)

## dump keycloak database for restoring later. CAUTION: if KCDUMPFILE is set it will be overwritten.
kcdump:
	$(SQLDUMP) keycloak > $(KCDUMPFILE)

## restore keycloak database from dump. Set KCDUMPFILE en var for custom (saved) dumpfile path.
kcrestore: $(KCDUMPFILE)
	cat $< | $(SQL)

## delete keycloak database and recreate it
rekc:
	docker compose --profile kc stop keycloak
	echo "DROP DATABASE IF EXISTS keycloak;" | $(SQL)
	echo "CREATE DATABASE keycloak;" | $(SQL)
	# cat keycloak/initdb.d/keycloak-database-and-user.sql | $(SQL)
	echo "GRANT ALL PRIVILEGES ON keycloak.* TO 'keycloak'@'%';" | $(SQL)
	@echo "Keycloak db reset."

# ---------------------------------------------------------- Legacy DB from prod
# since we moved this to the external script we keep them just as a reminder

.PHONY: restore restore_cv restore_cadi restore_dinfo restore_accred restore_bottin

## restore the legacy databases (copy from the on-line DB server to local ones) 
restore:
	./bin/restoredb.sh all

restore_accred:
	./bin/restoredb.sh accred

restore_bottin:
	./bin/restoredb.sh bottin	

restore_cadi:
	./bin/restoredb.sh cadi

restore_cv:
	./bin/restoredb.sh cv

restore_dinfo:
	./bin/restoredb.sh dinfo


# ------------------------------------------------------------------------------
.PHONY: clean
clean:
	rm -f api_examples.txt
	rm -rf test/fixtures/webmocks
	rm -f $(ELE_FILES)

# ------------------------------------------------------------------------------
.PHONY: help
help:
	@cat Makefile | gawk 'BEGIN{print "Available rules:";} /^# ---+ /{gsub(/ -+/,"", $$0); printf("\n%s:\n", $$0);} /^##/{gsub("^##", "", $$0); i=$$0; getline; gsub(/:.*$$/, "", $$0); printf("%-16s  %s\n", $$0, i);}'
