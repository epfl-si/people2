	-include .env
KBPATH = /keybase/team/epfl_people.prod
COMPOSE ?= docker-compose.yml
SSH_AUTH_SOCK_FILE ?= $(SSH_AUTH_SOCK)
SSH_AUTH_SOCK_DIR = $(dir $(SSH_AUTH_SOCK_FILE))

export

# ---------------------------------------------------------------- run local app
.PHONY: build codecheck up kup dcup down fulldown logs ps console dbconsole shell 

build: codecheck
	docker-compose -f $(COMPOSE) build

codecheck:
	# TODO: add linters and automated tests too...
	# bundle-audit returns 1 if there are vulnerabilities => prevents build
	# nicer gui available at https://audit.fastruby.io
	# 	bundle exec bundle-audit check --update
	# 	bundle exec brakeman

kup:
	KILLPID=1 docker-compose -f $(COMPOSE) up -d

up:
	docker compose -f $(COMPOSE) up -d

dcup:
	docker-compose -f $(COMPOSE) up --no-recreate -d 

kc:
	docker-compose --profile kc -f $(COMPOSE) up -d keycloak

# atela:
# 	docker-compose --profile atela -f $(COMPOSE) up -d atela

fulldown:
	docker-compose --profile test -f $(COMPOSE) down
	docker-compose --profile kc   -f $(COMPOSE) down
	docker-compose -f $(COMPOSE) down
down: 
	docker-compose -f $(COMPOSE) down

reload:
	docker-compose -f $(COMPOSE) stop webapp
	docker compose -f $(COMPOSE) up -d	

logs:
	docker-compose -f $(COMPOSE) logs -f

ps:
	docker-compose -f $(COMPOSE) ps

console: dcup
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails console

shell: dcup
	docker-compose -f $(COMPOSE) exec webapp /bin/bash

dbconsole: dcup
	docker-compose -f $(COMPOSE) exec mariadb mysql -u root --password=mariadb 

.PHONY: migrate
migrate: dcup
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails db:migrate

.PHONY: test testup test-system
testup:
	docker-compose --profile test -f $(COMPOSE) up --no-recreate -d

test: test-system

test-system: testup
	docker-compose -f $(COMPOSE) exec webapp ./bin/rails test:system

cacheon:
	docker-compose -f $(COMPOSE) exec webapp touch tmp/caching-dev.txt

cacheoff:
	docker-compose -f $(COMPOSE) exec webapp rm -f tmp/caching-dev.txt	

# setup_kc: dcup
# 	sleep 10
# 	docker-compose -f $(COMPOSE) stop keycloak
# 	sleep 2
# 	echo "DROP DATABASE IF EXISTS keycloak;" | $(MYSQL)
# 	sleep 2
# 	echo "CREATE DATABASE keycloak;" | $(MYSQL)
# 	make up

# -------------------------------------------------- restore legacy DB from prod
# since we moved this to the external script we keep them just as a reminder

.PHONY: restore restore_legacy restore_cv restore_cadi restore_dinfo restore_accred restore_bottin

restore: restore_legacy

restore_legacy:
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

