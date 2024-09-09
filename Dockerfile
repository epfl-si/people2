# FROM node:20 AS elements
# RUN git clone https://github.com/epfl-si/elements.git
# WORKDIR /elements
# # Strip includes from bootstrap-variables.scss. We are only interested in the base vars, not functions.
# RUN yarn
# RUN rm -f bootstrap-variables.scss && yarn dist
# RUN grep -E -v "^@include" assets/config/bootstrap-variables.scss > bootstrap-variables.scss



FROM registry.docker.com/library/ruby:3.2.3-bullseye

ARG RAILS_ENV=development
ARG LIB_HOME=/srv/lib

ENV RAILS_ENV="$RAILS_ENV" \
	LIB_HOME="$LIB_HOME" \
	OFFLINE_CACHEDIR="$LIB_HOME/filecache" \
	BUNDLE_PATH="/usr/local/bundle"

RUN mkdir -p /srv/app $OFFLINE_CACHEDIR

# Throw-away build stage to reduce size of final image
# FROM base as build

# Install packages needed to build gems

# --------------------------------------------------------------------------
# Oracle shit copied from 
# https://github.com/chumaky/docker-images/blob/master/postgres_oracle.docker
# Oracle connector is needed for ISA courses and for changing usual name
# ARG ORACLE_CLIENT_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip
# ARG ORACLE_SQLPLUS_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-sqlplus-linuxx64.zip
# ARG ORACLE_SDK_URL=https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip
# ENV ORACLE_HOME=/usr/lib/oracle/client
# WORKDIR /tmp
# RUN apt-get update; \
#     apt-get install -y --no-install-recommends ca-certificates wget unzip; \
#     # instant client
#     wget -O instant_client.zip ${ORACLE_CLIENT_URL}; \
#     unzip instant_client.zip; \
#     # sqlplus
#     wget -O sqlplus.zip ${ORACLE_SQLPLUS_URL}; \
#     unzip sqlplus.zip; \
#     # sdk
#     wget -O sdk.zip ${ORACLE_SDK_URL}; \
#     unzip sdk.zip; \
#     # install
#     mkdir -p ${ORACLE_HOME}; \
#     mv instantclient*/* ${ORACLE_HOME}; \
#     rm -r instantclient*; \
#     rm instant_client.zip sqlplus.zip sdk.zip; \
#     # required runtime libs: libaio
#     apt-get install -y --no-install-recommends libaio1; \
#     apt-get purge -y --auto-remove
# --------------------------------------------------------------------------
RUN apt-get update && apt-get install --no-install-recommends -y \
	build-essential \
	git \
	mariadb-client \
	curl \
	libvips \
	pkg-config \
	&& rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
WORKDIR /rails
# Note that Gemfile.lock does not need to exist
COPY Gemfile ./
COPY Gemfile.lock.docker ./Gemfile.lock
RUN gem update --system 3.5.11 && bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Dev only
RUN gem install foreman

WORKDIR /srv/app
COPY . .


COPY --from=elements /elements/dist/css/elements.css /elements/dist/css/elements.css /elements/bootstrap-variables.scss /srv/app/app/assets/stylesheets/elements/

RUN ./bin/rails dartsass:build

# Precompile bootsnap code for faster boot times
# RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Entrypoint prepares the database.
ENTRYPOINT ["/bin/bash", "/srv/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/dev"]
