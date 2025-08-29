# Developing

In the current state of the application, development is meant to be done running
the application in docker container. It is not the fastest (specially under MacOS),
and sometimes most convinient choice in development but it simplyfies working
with the various side services like keycloak, mariadb, redis etc.

## Pre-requisites

You need the following installed on your system to run this application in development mode:

- Ruby "3.3.8". We suggest to use [rbenv](https://github.com/rbenv/rbenv) for managing (`rbenv install 3.3.8`) the various ruby versions — 💡 Use [this PPA](https://launchpad.net/~instructure/+archive/ubuntu/ruby) to install it on older versions of Ubuntu Linux. Note that on debian-like distros, it is suggested to install rbenv with git.
- Docker with the so-called [compose version 2](https://docs.docker.com/compose/)
  - there is a [switch](https://github.com/docker/compose/issues/1123#issuecomment-1129313318) to flip in Docker Desktop for Mac for this.
  - The project assumes a working `docker compose` command. The old (Python-based) `docker-compose` might still work.
- Common [dev traefik configuration](https://github.com/multiscan/dev_traefik). See instructions therein.
- A secrets file defining the following environment variables (see `.env.sample` for more details):
  `ATELA_KEY`, `CAMIPRO_PHOTO_KEY`, `DEV_ENTRA_TENANT_ID`, `DEV_ENTRA_CLIENT_ID`,
  `DEV_ENTRA_SECRET`, `EPFLAPI_PASSWORD`, `OPENAI_API_KEY`, `ORACOURS_PWD`,
  `TRANS_USER`, `TRANS_PASS`
- If you kept the `USE_LOCAL_ELEMENTS` variable to true, you will also need
  - a directory where epfl elements will (or is already) cloned (`ELE_SRCDIR`);
  - [NVM](https://github.com/nvm-sh/nvm) and node version 18.x.x (`nvm install 18`) and `yarn` needed for building EPFL elements.

## Configuration and Secrets

The application secrets are supposed to be accessible as env. variables set by
`$SECFILE`, a bash script that is normally located in the project's
keybase directory `$KBPATH=/keybase/team/epfl_people.prod`. Off-course this is
just a path and could be anything else.

Few other variables needed for the development environment are set in the local
`.env`. Copy and modify the provided `.env.sample` file before starting anything.
Most of the default values should be ok. Therefore, there should be not much do
modify.

In order to run `./bin/rails` commands directly from the console instead of docker,
secrets must be loaded into env variables. I suggest to add the following to
your rc file and then execute `devenv` within the project folder.

```bash
alias devenv='set -a ; . ./.env; if [ -n "$SECFILE" ] ; then . $SECFILE ; fi ; set +a'
```

The mostly used commands are wrapped as rules in the makefile which instanciates
all the required env variables. See `make help` for a full listing of the
available shortcuts.

## Database initialization

For the application to run we need to initialize several databases because
it still includes the code for migrating from the legacy application which
requires various databases to work.
 1. restore the relevant parts of the legacy databases: `make restore`. For this
    to work you need to have access to the legacy production server or to a
    server that is allowed to access the various `dinfo` databases.
    Setup a `peo11` endpoint in your `~/.ssh/config` file for the import script
    to ssh into and dump the databases.
    Ideally, we should prepare a set of fake data instead but it is quite
    cumbersome.
 1. migrate and seed the local application database: `make seed`
 1. only if you need to work on the admin interface for translation: `make locales`
 1. if for some reason you prefer to use the locak keycloak server: `make rekc`
 1. if you are working on the migration from the legacy application
    (`ENABLE_ADOPTION` set to true), then you need to prepare the data with
    `make legacy` which will pre-load all text entries from the legacy user
    profiles and try to guess their languages using AI (see the
    [LEGACY_MIGRATION](LEGACY_MIGRATION.md) file for more details)

## Debugging

The way of debugging is through the `debug` gem. If you have the inner strength
to scrut its inscrutable [documentation](https://github.com/ruby/debug), then more
power to you.
1. Put `debugger` in your source code where you want the debugger to break
2. run `make debug` which will attach your terminal to the rails console where
   the debugger will be visible.

It would be nice to findout how to make the following work with rails running
on the container instead of locally as `/bin/dev` but I never found the energies
and the motivation (for me the cli is more than enough):

1. Create a `.rdbgrc` file in your home directory¹ that contains a single line: <pre>open chrome</pre>
2. Put `debugger` in your source code where you want the debugger to break
3. Run or re-run the development server as usual (i.e. `./bin/dev`)

💡 The hot-reload feature doesn't work in Chrome (yet), which will continue to display the old source code. You will need to stop and restart the server (which brings Chrome down and back up again as well) to fix that.

¹ What about Windows®, you ask?... Are you sure you are a real developer?

## Application overview
This is the public directory of people working and studying at the
[EPFL](https://www.epfl.ch). It is a complete rewrite of a legacy application
written in perl that have loyally and solidly served the EPFL for many years.

The application collects personal data from various internal sources and display
it in customizable profile pages. The data is also served to other services
within the school. Notably, it provides people listings to the the several
instances of wordpress that make up the official EPFL website.

The two main external data sources are the following web services:
 - `api.epfl.ch` for all official informations (name, status, positions);
 - `isa.epfl.ch` for academic information regardin teachers: courses, PhD students etc.

The information taken from the official sources, is integrated with information
optionally provided by the people and kept on the internal database.

The current implementation tries to closely mimic its legacy ancestor. In particular,
we keept the idea of a profile page composed of several content **blocks**
(all instances of the classes derived from the base `Box` model) but we
tried to implement it in a way that will allow new powerfull blocks to be added
in the future.
For the moment, we have just two types of blocks: `RichTextBox` that are
just a title with a free content in html format, and `IndexBox` that are
containers of lists of records of the same model. We have models for listing the
person's studies, work experiences, awards, selected publications, and links to
various research or social network websites (`Education`, `Experience`, `Award`,
`Publication`, `Social` models respectively).

Boxes are grouped by `Section` displayed in diffent zones of the public profile
page. Every instance of a `Box` is generated using the metadata of a `ModelBox`
that determines in which section the box will go and other things like if the
user can modify its title. A minimal administrative interface is provided for
managing the sections and the model boxes so that very little is hardcoded.

The public profile view is completely static and loaded at once for improving
indexing by search engines.

### Content localisation
A record can have fields that are language independent (e.g. year, person names),
and fields that require translation. In order to avoid extra model relationships,
we opted for storing everything in the same record where all the translations
for all the fields have a dedicated column in the DB. This off-course have the cost
of multiplying the number of columns and probably space required. There is a plan
to merge all the translations for a field in a single serialized column which
would enable supporting an arbitrary number of langues. This requires some work
but not too much because all localisation-related code is isolated in one module.

A clever (IMHO) interface were developed for multilingual editing where the user
could edit all the languages at the same time in a single form without the visual
overload of haveing one field per language. Unfortunately, it have been discarded
in favor of the current implementation which is less efficient (the form must
be saved once foreach language) but apparently easier to understand.


## Framework Picks

### Rails

See [this comic](http://www.sandraandwoo.com/2013/02/07/0453-cassandra/) to find out why using one of these newfangled NoSQL data stores might not be the best idea for a business-oriented application.

When it comes to modeling (as in the M of MVC) data into a relational database, Rails' ORM is tough to beat. For instance, Red Hat has an entire section of its business strategy which consists of writing and selling Rails front-ends to neckbeard-oriented systems — to wit: OKD for Kubernetes; Foreman for that whole IPMI / PXE / DHCP / TFTP / DNS hairball; and many more. Only occasionally will they use Django instead (e.g. Ansible Tower, possibly because Ansible itself is written in Python).

### EPFL Elements
The standard layout of EPFL. References:
 * [repository](https://github.com/epfl-si/elements)
 * [documentation](https://epfl-si.github.io/elements/#/)
 * [styleguide](https://github.com/epfl-si/epfl-theme-elements)

This is meant to be served redy to use from an internal server. On the other
hand, we need few files from its source for being able to produce a custom
css stylesheet. Therefore, the project will be cloned in a user-defined directory.

### Keycloak
The starter-kit app comes bundled with [Keycloak](https://www.keycloak.org/)-in-a-container, configured “as-code” (see [keycloak/README.md](keycloak/README.md) for details). While Java is admittedly a debatable choice (even moreso for production), Keycloak is an OpenID implementation that comes complete with a GUI that will let you set up test users, groups and roles as you please. This provides a so-called **hermetic** developer experience: you can hack while riding the bus, and worry about integration with your “real” corporate OIDC impementation (or SAML, bridged with e.g. [SATOSA](https://github.com/IdentityPython/SATOSA)) at deployment time.

Now the default is to use the new EntraID authentication system even for
development as it is pubblicly available and does not restrict clients based
on their IPs. Therefore, we might get rid of the keycloack part.

### ~~Oracle connector~~
No longer relevant as we got rid of all dependencies on external oracle DBs but
we keep this for future memory just in case we need to revamp it.
Oracle connector is quite cumbersome to install because it needs official binaries
from oracle. For linux, see the `Dockerfile`. For osx, use brew to install the
oracle client as explained [here](https://github.com/kubo/ruby-oci8/blob/master/docs/install-on-osx.md):

```
brew tap InstantClientTap/instantclient
brew install instantclient-basic
brew install instantclient-sdk
brew install instantclient-sqlplus
gem install ruby-oci8
```


### Relevant ENV variables for configuration
TODO: This part is very updated.

Common variables:
 - `RAILS_ENV`: standard
 - `REDIS_CACHE`: the url of the redis server for storing cache (RoR defaults to local memory storage)
 - `CAMIPRO_PHOTO_HOST`: the server for camipro profile photos
 - `ENABLE_API_CACHE`: enable caching of call to external api servers (api, atela, etc.)

Common secrets:
 - `CAMIPRO_PHOTO_KEY`: secret key for accessing the camipro photos server
 - `ORACOURS_PWD`: ${ORACOURS_PWD} password for the orable database containing the ISA courses
 - `ATELA_KEY`: ${ATELA_KEY} secret key for accessing `atela.epfl.ch`
 - `EPFLAPI_PASSWORD`: ${EPFLAPI_PASSWORD} password for `api.epfl.ch`

Development only variables:
 - `RAILS_DEVELOPMENT_HOSTS`: normally only localhost is considered a dev host. Using traefik we need to add the hosts that are actually used for Rails not to complain about security.

#### Getting rid of docker compose whining noise about unset variables
The `docker-compose.yml` file includes several environment variables without
default value. This triggers a series of warning messages like the following
every time you run `docker compose` on the command line and not through `make`

```
WARN[0000] The "EPFLAPI_PASSWORD" variable is not set. Defaulting to a blank string.
WARN[0000] The "DEV_ENTRA_TENANT_ID" variable is not set. Defaulting to a blank string.
WARN[0000] The "DEV_ENTRA_CLIENT_ID" variable is not set. Defaulting to a blank string.
... etc
```

To get rid of them, just source the `.env` and secrets file (see the alias above).

## Troubleshooting
##### Authentication fails in dev
If you get the following error message in the app console: `ERROR -- omniauth: (oidc) Authentication failure! Not Found: OpenIDConnect::Discovery::DiscoveryFailed, Not Found`
then you probably nuked the keycloak server and forgot to provision it with
authentication data. In this case, `make kconfig` should do the job.


## Opinions

### GraphQL and OpenID _only_, or: Web 1.0 CRUD (and REST) Considered Obsolete

In the out-of-the-box configuration for this demo app, _only_ the `/graphql` URL is protected by OpenID access control. We posit that this is, in fact, a reasonable approach to security; and that you might want to consider designing your app so that there is no need for additional protection.

GraphQL provides for all your data access and mutation needs. It is pretty straightforward to enforce the security policy (for both access control and auditing) by checking for a so-called OpenID “claim” that is mapped to a role directly from within the relevant GraphQL controllers. The rest of your app should not disclose information (except information intended for public use) at any other endpoint; nor should it permit any mutation except, over GraphQL. In other words, you should refrain from using “traditional” Rails controllers and Web templates (either Web 1.0-style with `application/x-www-form-urlencoded` POSTs; or “modern” REST-style APIs with other HTTP verbs), except to serve “traditional” Web content (using HTTP GET) to unauthenticated users (such as search engines). Examples of concerns that you will be able to disregard entirely are [XSRF tokens](https://guides.rubyonrails.org/action_controller_overview.html#request-forgery-protection) (and the secret management headaches they entail when [deploying a load-balanced Rails app](https://www.jetbrains.com/help/ruby/capistrano.html#credentials)), [ad-hoc signaling and UX](https://www.rubyguides.com/2019/11/rails-flash-messages/), and more.

### Web 1.0 CRUD and REST still viable when leveraging all the work behind RoR

In my opinion (giova), the development overhead introduced by the so called web 2.0 is justified only in two cases:
 1. when the volumes are huge (e.g. facebook) and it it is less expensive to delegate as much computation as possible to the client;
 2. when one tries to emulate a desktop application that requires a lot of reactivity and real time rendering of the UI (e.g. google docs);

Our tiny application people.epfl.ch serves at most few requests per second and is a read-only application for most of the data. The user editable part is quite limited and simple. Therefore, it does not match any of the above use cases. The amount of nice features provided natively by RoR that would have to be discarded for embracing the web 2.0 is not justified at all.

## Migration

### Profile pictures

Current application offers two options for the profile picture:
 1. use remote camipro image (actually locally cached version of it);
 2. use one of the locally uploaded images;

The GUI for selecting the image must be composed of three parts:
 1. toggle if picture should be visible or not;
 2. toggle if camipro picture is to be used (currently camipro photo is used if common.photo_ext is not 1);
 3. list selector for the uploaded images (currently this is decided by common.photo_ts)

### Multilanguage support
Current version only support two languages: french and english. We start by doing the same with the idea of adding more languages in the future. The problem is how to make the UI usable.

For two languages we decided to have each field repeated (e.g. instead of `title`, we have `title_en`, and `title_fr`) and statically visible in editing forms. Forms grow fat but the user gets immediate feedback about missing translations. This approach could be extended to 3, possibly 4 languages but for sure not more than 4.
More details in `Docs/multilanguage.md`.

In any case, a backoffice translation service should be deployed with a validation/scoring system similar to the one we did for jilion.

### Useful links
 * EPFL api doc for [person](https://api-test.epfl.ch/docs/persons-api/index.html), [accred](https://api-test.epfl.ch/docs/accred-api/index.html)

### Useful reads
 * [rails guides](https://guides.rubyonrails.org/) of course!
 * [rails design patterns](https://rubyhero.dev/rails-design-patterns-the-big-picture)
 * [Arel doc](https://www.rubydoc.info/gems/arel#description) and examples of usage: [one](https://dev.to/ashawareb/arel-and-ruby-on-rails-58m3), [two](https://www.cloudbees.com/blog/creating-advanced-active-record-db-queries-arel)
 * Logging [best practices](https://stackify.com/rails-logger-and-rails-logging-best-practices/)
