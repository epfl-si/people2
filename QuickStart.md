Some extra info for kickstarting people2 dev as the README.md file is
not yet very reliable (read it anyway as I might forget 1/2 of the things now)

1. my common taefik setup (Nicolas and Rosa please `git pull` because I've corrected few things)
2. ruby 3.3.8 (ideally: `rbenv install 3.3.8`). There is nothing special in the version
   but, since the version is written in the Gemfile, using a differen one may create
   Headaches
3. have access to /keybase/team/epfl_people.prod (why prod? historical reasons).
   There are a lot of files therein but the only one that are interesting are
   - `secrets_prod.sh` used by Makefile and other scripts
   - the ops directory where the deployment secrets for ansible are written
   - dev/dumps where the dumps of the legacy databases are written (don't tell to GDPR people!)
4. as usual `cp .env.sample .env` and edit. In principle it should be ok as it is
5. all the dev is done on docker although this is slower and more cumbersome to debug but
   it makes it easier to deal with databases etc.
6. Try to see if it starts
  - `make up` to start the various servers
  - `make restore` to bootstrap the legacy databases (should take the dumps from KB)
  - `make seed` to boostrap the app database
  - `make up ps logs` to eventually re-start the server: the app should be at people.dev.jkldsa.com
    if you didn't change DOMAIN in `.env`

Deploiment:
- `make patch` to increase VERSION (or just edit the file);
- `make prod` to build the image and deploy the code with ansible. Note that
  it does not run the full ansible script.
- `make prod_shell` to ssh into the application pod in production
- `make prod_console` to open a rails console in the production pod

Hope it works!
