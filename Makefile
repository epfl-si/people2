-include .env
KBPATH ?= /keybase/team/epfl_people.prod
-include $(KBPATH)/$(SECRETS)

COMPOSE_FILE ?= docker-compose.yml
SSH_AUTH_SOCK_FILE ?= $(SSH_AUTH_SOCK)
SSH_AUTH_SOCK_DIR = $(dir $(SSH_AUTH_SOCK_FILE))

# Figure out the ip address of the host machine so that we can use "public" 
# dns names served by traefik from within the containers when the name is
# resolved as 127.0.0.1 like for all Giovanni's domains with glob ssl certs. 
DOCKER_IP ?= $(shell docker run -it --rm nicolaka/netshoot dig +short host.docker.internal)

export

# ---------------------------------------------------------------- run local app
.PHONY: build codecheck up kup dcup down fulldown logs ps top console dbconsole shell

## build the web app and atela container
build: envcheck #codecheck
	docker compose build

rebuild: envcheck
	docker compose build --no-cache

kup: envcheck
	KILLPID=1 docker compose up -d

## start the dev tunnel and start all the servers
up: tunnel_up dcup

dcup: envcheck
	docker compose up --no-recreate -d 

kc: envcheck
	docker compose --profile kc up -d keycloak

# atela:
# 	docker compose --profile atela up -d atela

## stop everything including keycloak and the test server
fulldown:
	docker compose --profile test down
	docker compose --profile kc   down
	docker compose down

## stop the basic servers (all except keycloak and test)
down: tunnel_down
	docker compose down

## restart the webapp container
reload: envcheck
	docker compose stop webapp
	KILLPID=1 docker compose up -d

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

## attach the console of the rails app for debugging
.PHONY: debug
debug:
	docker-compose attach webapp

dconfig:
	docker compose config

## generate an entity relation diagram with mermaid_erd
erd:
	docker compose exec webapp ./bin/rails mermaid_erd

## check the dev environment
envcheck: .env .git/hooks/pre-commit

## check the code with linter and run all automated tests (TODO)
codecheck: cop
	# TODO: automated tests too...
	# bundle-audit returns 1 if there are vulnerabilities => prevents build
	# nicer gui available at https://audit.fastruby.io
	#	bundle exec bundle-audit check --update
	#	bundle exec brakeman

.git/hooks/pre-commit:
	if [ ! -l .git/hooks ] ; then mv .git/hooks .git/hooks.trashme && ln -s ../.git_hooks .git/hooks ; fi

.env:
	@echo ".env file not present. Please copy .env.sample and edit to fit your setup"
	exit 1

# enable/disable web console
.PHONY: coff con
con:
	docker compose exec webapp touch tmp/console-dev.txt
coff:
	docker compose exec webapp rm -f tmp/console-dev.txt


.PHONY: redis
## run valkey-cli 
redis:
	docker compose exec cache valkey-cli

# ---------------------------------------------------------------------- testing
.PHONY: test testup test-system
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

## run automated tests
test:
	docker compose exec -e RAILS_ENV=test webapp ./bin/rails test

## run rubocop linter to check code copliance with style and syntax rules
cop:
	bundle exec rubocop --extra-details # 2>/dev/null

## run rubocop linter in autocorrect mode
docop:
	bundle exec rubocop --autocorrect

## run rubocop linter in autocorrect-all mode
dodocop:
	bundle exec rubocop --autocorrect-all

# ------------------------------------------------------------------------ cache
## toggle dev cache
devcache:
	docker compose exec webapp bin/rails dev:cache

## flush cache from redis db
flush:
	docker compose exec cache redis-cli FLUSHALL 
# ------------------------------------------------------------------- ssh tunnel
.PHONY: tunnel_up tunnel_down

tunnel_up:
	./bin/tunnel.sh -m local start

tunnel_down:
	./bin/tunnel.sh -m local stop

# setup_kc: dcup
# 	sleep 10
# 	docker compose stop keycloak
# 	sleep 2
# 	echo "DROP DATABASE IF EXISTS keycloak;" | $(MYSQL)
# 	sleep 2
# 	echo "CREATE DATABASE keycloak;" | $(MYSQL)
# 	make up

# -------------------------------------------------------------------- migration
.PHONY: migrate seed

## run rails migration
migrate: dcup
	docker compose exec webapp ./bin/rails db:migrate

## run rails migration and seed with initial data
seed: migrate
	docker compose exec webapp bin/rails db:seed
	make courses

## prefetch dev data from api.epfl.ch for the fake (local) api server 
fakeapi: dcup
	docker compose exec webapp bin/rails devel:fakeapi

## reload the list of all courses from ISA
courses: dcup
	docker compose exec webapp bin/rails data:courses

# --------------------------------------------------- destroy and reload mock db
.PHONY: reseed

SQL=docker-compose exec -T mariadb mariadb -u root --password=mariadb
## restart with a fresh new dev database for the webapp
reseed:
	make nukedb
	sleep 2
	make seed

## delete the people database
nukedb:
	echo "DROP DATABASE people" | $(SQL)
	echo "CREATE DATABASE people;" | $(SQL)

# -------------------------------------------------- restore legacy DB from prod
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


# ------------------------------------------------------------------------------
.PHONY: help
# see <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation
## Print this help 
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST} | awk -F --- -v n=$$(tput cols) -v i=20 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'
