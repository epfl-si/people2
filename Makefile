-include .env
KBPATH ?= /keybase/team/epfl_people.prod
-include $(KBPATH)/$(SECRETS)

COMPOSE ?= docker-compose.yml
SSH_AUTH_SOCK_FILE ?= $(SSH_AUTH_SOCK)
SSH_AUTH_SOCK_DIR = $(dir $(SSH_AUTH_SOCK_FILE))

export

# ---------------------------------------------------------------- run local app
.PHONY: build codecheck up kup dcup down fulldown logs ps console dbconsole shell 

## build the web app and atela container
build: envcheck codecheck
	docker-compose -f $(COMPOSE) build

kup: envcheck
	KILLPID=1 docker-compose -f $(COMPOSE) up -d

## start the dev tunnel and start all the servers
up: tunnel_up dcup

dcup: envcheck
	docker-compose -f $(COMPOSE) up --no-recreate -d 

kc: envcheck
	docker-compose --profile kc -f $(COMPOSE) up -d keycloak

# atela:
# 	docker-compose --profile atela -f $(COMPOSE) up -d atela

## stop everything including keycloak and the test server
fulldown:
	docker-compose --profile test -f $(COMPOSE) down
	docker-compose --profile kc   -f $(COMPOSE) down
	docker-compose -f $(COMPOSE) down

## stop the basic servers (all except keycloak and test)
down: tunnel_down
	docker-compose -f $(COMPOSE) down

## restart the webapp container
reload: envcheck
	docker-compose -f $(COMPOSE) stop webapp
	KILLPID=1 docker-compose -f $(COMPOSE) up -d

## tail -f the logs
logs:
	docker-compose -f $(COMPOSE) logs -f

## show the status of running containers
ps:
	docker-compose -f $(COMPOSE) ps

## start a rails console on the webapp container
console: dcup
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails console

## start a shell on the webapp container
shell: dcup
	docker-compose -f $(COMPOSE) exec webapp /bin/bash

## start an sql console con the database container
dbconsole: dcup
	docker-compose -f $(COMPOSE) exec mariadb mysql -u root --password=mariadb 

dconfig:
	docker-compose -f $(COMPOSE) config

## generate an entity relation diagram with mermaid_erd
erd:
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails mermaid_erd

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

# ---------------------------------------------------------------------- testing
.PHONY: test testup test-system
## prepare and run the test server 
testup:
	docker-compose --profile test -f $(COMPOSE) up --no-recreate -d
	# TODO: find a way to fix this by selecting the good deps (stopped working 
	# after an upgrade don't know if due to ruby or packages version.
	docker-compose -f $(COMPOSE) exec webapp sed -i '0,/end/{s/initialize(\*)/initialize(*args)/}' /usr/local/bundle/gems/capybara-3.39.0/lib/capybara/selenium/logger_suppressor.rb
	docker-compose -f $(COMPOSE) exec webapp sed -i '0,/end/{s/super/super args/}' /usr/local/bundle/gems/capybara-3.39.0/lib/capybara/selenium/logger_suppressor.rb

# testprepare:
# 	docker-compose -f $(COMPOSE) exec webapp ./bin/rails db:test:prepare
# 	docker-compose -f $(COMPOSE) exec -e RAILS_ENV=test webapp ./bin/rails db:migrate

test-system: testup
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails test:system

## run automated tests
test:
	docker-compose -f $(COMPOSE) exec -e RAILS_ENV=test webapp ./bin/rails test

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
	docker-compose -f $(COMPOSE) exec webapp bin/rails dev:cache

## flush cache from redis db
flush:
	docker-compose -f $(COMPOSE) exec cache redis-cli FLUSHALL 
# ------------------------------------------------------------------- ssh tunnel
.PHONY: tunnel_up tunnel_down

tunnel_up:
	./bin/tunnel.sh -m local start

tunnel_down:
	./bin/tunnel.sh -m local stop

# setup_kc: dcup
# 	sleep 10
# 	docker-compose -f $(COMPOSE) stop keycloak
# 	sleep 2
# 	echo "DROP DATABASE IF EXISTS keycloak;" | $(MYSQL)
# 	sleep 2
# 	echo "CREATE DATABASE keycloak;" | $(MYSQL)
# 	make up

# -------------------------------------------------------------------- migration
.PHONY: migrate seed

## run rails migration
migrate: dcup
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails db:migrate

## run rails migration and seed with initial data
seed: migrate
	docker-compose -f $(COMPOSE) exec webapp bin/rails db:seed

## prefetch dev data from api.epfl.ch for the fake (local) api server 
fakeapi: dcup
	docker-compose -f $(COMPOSE) exec webapp bin/rails devel:fakeapi

# --------------------------------------------------- destroy and reload mock db
.PHONY: reseed

SQL=docker-compose -f $(COMPOSE) exec -T mariadb mysql -u root --password=mariadb
## restart with a fresh new dev database for the webapp
reseed:
	echo "DROP DATABASE people" | $(SQL)
	sleep 2
	echo "CREATE DATABASE people;" | $(SQL)
	sleep 2
	make seed

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
.PHONY: help
# see <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation
## Print this help 
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST} | awk -F --- -v n=$$(tput cols) -v i=20 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'
