# TODO multistage build
FROM ruby:3.1-bullseye
ARG RAILS_ENV=production
ENV RAILS_ENV $RAILS_ENV

ARG APP_HOME=/srv/app
ARG LIB_HOME=/srv/lib
ENV APP_HOME $APP_HOME
ENV LIB_HOME $LIB_HOME

ENV BUNDLE_PATH $LIB_HOME/bundle
ENV MODULES_PATH $LIB_HOME/node_modules
ENV OFFLINE_CACHEDIR $LIB_HOME/filecache

RUN mkdir -p $APP_HOME
RUN mkdir -p $BUNDLE_PATH
RUN mkdir -p $MODULES_PATH
RUN mkdir -p $OFFLINE_CACHEDIR

WORKDIR $APP_HOME

# RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
# RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -

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


RUN apt-get update && apt-get install -y \
	build-essential \
	mariadb-client \
	# nodejs \
	# yarnpkg \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

# RUN ln -s /usr/bin/yarnpkg /usr/bin/yarn
# RUN npm install --global yarn

# RUN echo "${ORACLE_HOME}" > /etc/ld.so.conf.d/oracle.conf ; /sbin/ldconfig
RUN gem install bundler -v '~> 2.4'

WORKDIR $APP_HOME

# ADD package.json* $APP_HOME
# RUN npm add @babel/runtime
# RUN npm add @babel/runtime-corejs2
# RUN NODE_PATH=/usr/lib/nodejs:/usr/share/nodejs yarn cache clean && yarn
# RUN npm install --loglevel verbose

# RUN yarn cache clean && yarn install --verbose --modules-folder $MODULES_PATH

ADD Gemfile* $APP_HOME/
ADD bin/bundle $APP_HOME/bin/bundle
RUN ./bin/bundle
RUN if [ "$RAILS_ENV" == "development" ] ; then RAILS_ENV='test' ./bin/bundle ; fi
# RUN if [ "$RAILS_ENV" == "development" ] ; then yarn install --verbose --modules-folder $MODULES_PATH ; fi

ADD . $APP_HOME/

# Entrypoint prepares the database.
# ENTRYPOINT ["$APP_HOME/bin/docker-entrypoint"]
ENTRYPOINT ["/bin/bash", "$APP_HOME/bin/docker-entrypoint"]
EXPOSE 3000

# CMD [./bin/dev"]
CMD ["./bin/rails", "server"]
