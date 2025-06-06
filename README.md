# Developing

## Pre-requisites

You need the following installed on your system to run this application in development mode:

- Ruby "3.2.3". We suggest to use [rbenv](https://github.com/rbenv/rbenv) for managing (`rbenv install 3.2.3`) the various ruby versions — 💡 Use [this PPA](https://launchpad.net/~instructure/+archive/ubuntu/ruby) to install it on older versions of Ubuntu Linux;
- [NVM](https://github.com/nvm-sh/nvm) and node version 18.x.x (`nvm install 18`);
- Docker with the so-called [compose version 2](https://docs.docker.com/compose/)
  - there is a [switch](https://github.com/docker/compose/issues/1123#issuecomment-1129313318) to flip in Docker Desktop for Mac for this.
  - The project assumes a working `docker compose` command. The old (Python-based) `docker-compose` might still work.

## Development Rig

1. Run <pre>docker compose up</pre>💡 If you get an error about `'name' does not match any of the regexes: '^x-'`, or `(root) Additional property name is not allowed`, see previous paragraph.
2. In another terminal, run <pre>./bin/dev</pre>

`./bin/dev` starts up all the development things, with hot-rebuild everywhere: server-side with Puma and turbo-rails, as well as client-side with esbuild.

## Configuration and Secrets

In development mode, you may create a `.env` file to configure rendezvous points and secrets. Copy and modify the provided `.env.sample` file.

In order to run `./bin/rails` commands directly from the console instead of docker,
secrets must be loaded into env variables with the following command:

```bash
. ./.env ; cat .env $KBPATH/$SECRETS | awk '/^[A-Z]/{print "export ", $0;}' | source /dev/stdin 
```

## GraphiQL console

Navigate to https://localhost:3000/graphiql to see the GraphiQL console (not just GraphQL — emphasis on the “i”). Its is provided by the [`graphiql-rails` gem](https://rubygems.org/gems/graphql-rails); its purpose is to let you try out GraphQL queries and mutations (no “i” here) while you develop your app.

💡 This console will only give you an error, until you click on the Login button to authenticate against the locally-running Keycloak (while in development mode); you can then run your GraphQL query again by clicking ▶. That feature doubles as the demo app for [the `@epfl-si/react-appauth` npm package](https://www.npmjs.com/package/@epfl-si/react-appauth), with which the Login button is built (and then injected into the “pristine” GraphiQL UI using some mild React-DOM trickery).

## Debugging

The new (Rails 7) way of debugging is through the `debug` gem. If you have the inner strength to scrut its inscrutable [documentation](https://github.com/ruby/debug), then more power to you. Otherwise:

1. Create a `.rdbgrc` file in your home directory¹ that contains a single line: <pre>open chrome</pre>
2. Put `debugger` in your source code where you want the debugger to break
3. Run or re-run the development server as usual (i.e. `./bin/dev`)

💡 The hot-reload feature doesn't work in Chrome (yet), which will continue to display the old source code. You will need to stop and restart the server (which brings Chrome down and back up again as well) to fix that.

¹ What about Windows®, you ask?... Are you sure you are a real developer?

## Cleaning Up

To revert the development rig to its pristine state (wiping out `node_modules`, compiled JavaScript and caches):

```
./bin/rake devel:clean
```

To purge the development database as well:

```
./bin/rake devel:realclean
```

Should you wish to also purge the Keycloak state in MariaDB, say

```
docker compose down
docker volume rm hellorails_mariadb
```

💡 When you restart Keycloak with `docker compose up`, you must restart the Rails server (`./bin/dev`) as well, otherwise it will try and fail to validate the OpenID-Connect tokens using the old public key it obtained from the former incarnation of Keycloak.

# Starter Kit

**This is not a real app.** If you clone and copy this repository into your project, consider

- Truncating the Git history, keeping only the parent of the oldest commit whose message starts with `[helloworld]`,
- Searching-n'replacing `HelloRails` (of which there is only a handful) in the source code,
- Searching-n'replacing `hellorails` in the various `README.md` files and the development support configuration-as-code (i.e. [`docker-compose.yml`](./docker-compose.yml)),
- Removing this whole here chapter in `README.md` (after reading it perhaps - It's up to you).

## Framework Picks

### Rails

See [this comic](http://www.sandraandwoo.com/2013/02/07/0453-cassandra/) to find out why using one of these newfangled NoSQL data stores might not be the best idea for a business-oriented application.

When it comes to modeling (as in the M of MVC) data into a relational database, Rails' ORM is tough to beat. For instance, Red Hat has an entire section of its business strategy which consists of writing and selling Rails front-ends to neckbeard-oriented systems — to wit: OKD for Kubernetes; Foreman for that whole IPMI / PXE / DHCP / TFTP / DNS hairball; and many more. Only occasionally will they use Django instead (e.g. Ansible Tower, possibly because Ansible itself is written in Python).

### React (and TypeScript)

We get it, you love Ruby and you hate JavaScript (otherwise, maybe you should have a look at [Meteor](https://www.meteor.com/) paired with some kind of TypeScript-friendly ORM like [Prisma](https://github.com/prisma/prisma)?). This is 2022 and it has probably become tough to argue with your boss that your project doesn't need JavaScript; a better strategy might be to suggest a modern, not-too-controversial framework with a gentle learning curve and plenty of help available online. React and TypeScript seem like as good choices as any. With some luck, TypeScript's learning path might bring you to venture past the old trope, “strong typing is for weak minds” and onto the enlightened path beyond.

React being what it is though, JSX and all, it demands some kind of build process. This starter kit uses [esbuild](https://esbuild.github.io/) which is a fast and modern replacement for Webpack. The `jsbundling-rails` gem integrates esbuild into the run-time part of Rails' asset pipeline in a way that is easy to reason about (with cache keys in URLs and all).

### EPFL Elements
The standard layout of EPFL. References:
 * [repository](https://github.com/epfl-si/elements)
 * [documentation](https://epfl-si.github.io/elements/#/)
 * [styleguide](https://github.com/epfl-si/epfl-theme-elements)

### Oracle connector
is quite cumbersome to install because it needs official binaries from oracle. For linux, see the `Dockerfile`. For osx, use brew to install the oracle client as explained [here](https://github.com/kubo/ruby-oci8/blob/master/docs/install-on-osx.md):

```
brew tap InstantClientTap/instantclient
brew install instantclient-basic
brew install instantclient-sdk
brew install instantclient-sqlplus
gem install ruby-oci8
```

### OpenID Connect

It has become fashionable to split Web apps between front-end and back-end, if only to provide division of labor for those who hate JavaScript (see above). Security can become a problem at the interface between both.

With OpenID Connect, which is kind of a successor-in-interest to the best parts of OAuth, we picked a modern and scalable system that supports even the most demanding requirements, such as

- **extensible access control policies** from plain old ad-hoc access groups to roles (either simple or decorated with metadata that maps to your organization's permission hierarchy),
- **pseudonymous access / audit logs:** thanks to the distinction between _ID tokens_ and _access tokens_ in OAuth, it is possible to set up your Keycloak, SATOSA or other OpenID-compatible server so that the front-end shows the logged user's first and last name, while the back-end only gets to know some ephemeral user identifier that will die with the session, and an app-specific set of permissions. (With little or no change required in your app of course.)

### Keycloak

The starter-kit app comes bundled with [Keycloak](https://www.keycloak.org/)-in-a-container, configured “as-code” (see [keycloak/README.md](keycloak/README.md) for details). While Java is admittedly a debatable choice (even moreso for production), Keycloak is an OpenID implementation that comes complete with a GUI that will let you set up test users, groups and roles as you please. This provides a so-called **hermetic** developer experience: you can hack while riding the bus, and worry about integration with your “real” corporate OIDC impementation (or SAML, bridged with e.g. [SATOSA](https://github.com/IdentityPython/SATOSA)) at deployment time.

### GraphQL

Once your front-end is authenticated, it will want to talk to the back-end. GraphQL is a more versatile approach than plain old REST, which future-proofs your app by alleviating some of the headaches of long-term schema maintenance, especially if more than one front-end exists to access your back-end (think mobile app). In development mode, your starter-kit app comes with a GraphQL console at the `/graphiql` URL.

### Relevant ENV variables for configuration

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
