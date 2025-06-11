# Project Infrastructure Overview

---

## 1. Legacy Podman-Based Architecture

The server runs on a RHEL VM using **Podman** for containerization. By default, Podman runs in _rootless_ mode and we aim to follow this standard. As a result, all application pods are executed under a regular user (`fsd`).

This setup, along with using Podman/Docker, introduces two main issues:

- _Rootless_ processes cannot bind to privileged ports such as 80 and 443.
- Podman performs NAT when exposing container ports, meaning processes like **Traefik** running in containers cannot see the original IP of the browser.

### Current solution

- Traefik runs inside Podman, binding to non-privileged ports (e.g., 8033, 4433).
- Firewall rules forward incoming HTTP traffic to the correct internal Podman ports.

### Alternative solution

A secondary reverse proxy could be added, running as root to manage SSL certificates and forward requests to the internal Traefik. This would ensure accurate `x-forwarded-for` headers. However, this method prevents dynamic certificate selection.

---

## 2. OpenShift 4 Deployment

![People component in the OS4 cluster](/Docs/Shemas_OS4-People.png)

## Prerequisites

Before deploying, ensure you have access to the following services:

- **Keybase**
  Required to retrieve application and admin secrets. You must have access to:
  `/keybase/team/epfl_people.prod/ops/secrets-prod.yml`
  `/keybase/team/epfl_people.prod/ops/secrets-admin.yml`

- **OpenShift 4 cluster access (EPFL)**
  You must have permissions to deploy to your namespace and access OpenShift routes, services, pods, and logs via `oc` CLI or the OpenShift web console.

- **Quay.io or quay-its.epfl.ch**
  Required to pull container images (`people_webapp`, `valkey`) and access image tags.

## What’s Deployed Where?

This section explains each deployed component and the Kubernetes/OpenShift resources it creates.

---

### `webapp`

- **Deployment:** `apps/v1.Deployment` named `people-webapp`
- **Service:** `v1.Service` named `people` — exposes port `8080` targeting the container’s port `3000`
- **Route:** `route.openshift.io/v1.Route` named `people-webapp` — exposes the service at [https://people-next.epfl.ch](https://people-next.epfl.ch)
- **Image:** Pulled from `quay-its.epfl.ch/svc0041/people_webapp`
- **Configuration:**
  - `ConfigMap`: `people-app-config`
  - `Secret`: `people-app-secrets` (user DB/API) and `people-admin-secrets` (admin DB)
- **Volumes:**
  - PVC `people-storage` mounted to `/srv/app/storage`
  - `emptyDir` volume for temporary files mounted to `/srv/app/tmp`

---

### `redis`

- **Deployment:** `apps/v1.Deployment` named `people-redis`
- **Image:** `quay-its.epfl.ch/svc0041/valkey`
- **Volume:** PVC `people-redis` mounted at `/srv/filecache`
- **Service:** `v1.Service` named `people-redis` exposing port `6379`

---

### `init`

Sets up required base components:

- Creates `quay-pull-secret` from a local `secrets.yml` file
- Creates `puller` `ServiceAccount` using the pull secret
- Creates the initial `people` service and PVCs:
  - `people-storage` for app file storage
  - `people-redis` for Redis cache volume

---

### `route`

- Creates an OpenShift `Route` object
- Exposes the service `people` as [https://people-next.epfl.ch](https://people-next.epfl.ch)

---

### `monitoring`

- Deploys a `monitoring.coreos.com/v1.PodMonitor` named `people-webapp` visible at https://go.epfl.ch/people-monitoring_puma
- Configured to scrape metrics on:
  - **Port:** `metrics` (9394)
  - **Path:** `/metrics`
  - **Interval:** every `30s`

### Usage

#### Standard test deployment:

```bash
./possible --test
```

#### Production deployment with a specific tag:

```bash
./possible --prod -t vX.Y.Z
```

#### Deploy a single component:

```bash
# Deploy the web application (people_webapp) and all its environment variables and secrets
./possible --prod -T webapp

# Deploy the Redis cache backend (Valkey) with a PVC
./possible --prod -T redis

# Initialize project prerequisites:
# - Create quay secrets
# - Setup ServiceAccount
# - Deploy default Service and PVCs
./possible --prod -T init

# Deploy the OpenShift Route to expose the application externally (people-next.epfl.ch)
./possible --prod -T route

# Setup the PodMonitor for Prometheus to scrape metrics from the web application
./possible --prod -T monitoring
```

Secrets and configuration are managed via **Keybase**, converted to Kubernetes `Secret` and `ConfigMap` using Ansible.

Monitoring is integrated using **Yabeda** as Prometheus exporter, and a `PodMonitor` is set up for metrics collection in the OpenShift cluster.

Grafana dashboards can be provisioned manually or through API using the `grafana/people_dashboard.json` definition.

---

## Shared Conventions

### Variables

- Variables to be defined in inventories are written in **CAPITAL_LETTERS**.
- Modules should only define defaults when it's _safe_. It is better to fail fast than misconfigure something silently.

### Tags

Tags added via `roles:` in the playbook are automatically inherited by the role’s tasks. Tags added via `include_tasks` must be propagated using `apply:`.

Check all available tags with:

```bash
./possible.sh --test --list-tags
```

#### Tagging Conventions

- Every role has a corresponding tag in the playbook.
  Example: `./possible.sh --test -t system` runs all tasks of the `system` role.
- The `main.yml` in each role is a manifest and imports grouped task files:
  1. _setup_
  2. _install_
  3. _config_
  4. _run_
  5. _admin_

---

## Common Tasks

### Renew certificate on the test server:

```bash
./possible.sh --test -t ingress.config.certs
```

---

## Useful Addresses

- `128.178.1.17` → Developer workstation
- `128.178.224.34`, `128.178.224.35` → Legacy VMs (dinfo11, dinfo12)
- `10.95.96.153` → peonext (test deployment)
- `10.98.72.0/21` → OpenShift cluster node range
- `10.98.72.140–142` → Cluster egress IPs (for external requests)

---

## 🔧 Local Image Build and Push to Quay

The application NEED to be built locally and pushed manually to the EPFL Quay registry if changed.

### Makefile Snippet

```makefile
APP_NAME=people
QUAY_REPO=quay-its.epfl.ch/svc0033/$(APP_NAME)
TAG=latest

# Path to the Dockerfile
DOCKERFILE=../../../Dockerfile

# Build the image locally
build: ../../../VERSION
	docker build -t $(APP_NAME):$(TAG) -f $(DOCKERFILE) ../../..

# Tag and push to Quay
push: build
	docker tag $(APP_NAME):$(TAG) $(QUAY_REPO):$(TAG)
	docker push $(QUAY_REPO):$(TAG)

# Local cleanup
clean:
	docker rmi $(APP_NAME):$(TAG) || true
	docker rmi $(QUAY_REPO):$(TAG) || true

# Automatically extract the latest git tag as the image version
../../../VERSION:
	git tag -l --sort=creatordate | tail -n 1 | sed 's/\n//' > $@
```

### Notes

- `build` compiles the Docker image locally using the provided `Dockerfile`.
- `push` tags the image and uploads it to your Quay repository.
- `clean` removes local images to avoid clutter.
- `VERSION` auto-populates from the latest `git tag`.

Ensure you are authenticated with Docker to `quay-its.epfl.ch` and have permission to push to the `svc0033` namespace.

## Final Migration to Production

 - [] Set version 1.0.0 in `VERSION` file, `make tag`, and `git push` (optional);
 - [] `make prod_push` to build the final docker image and push it to Quay;
 - [] Clean the production database: `./bin/nuke_prod.sh`;
 - [] Deploy the app to production: `make prod_deploy`;
 - [] Run migrations and seed data: this is not yet fully automatic:
   - [] `make prod_shell`
   - [] `./bin/rails db:migrate`
   - [] `./bin/rails db:seed`
   - [] `./bin/rails data:refresh_courses`
   - [] `./bin/rails legacy:adoptions`
   - [] `./bin/rails legacy:seed_eligible_scipers`
   - [] `./bin/rails legacy:fetch_all_texts`
   - [] `./bin/rails legacy:txt_lang_detect`
   - [] `./bin/rails legacy:txt_translate`
 - [] change the DNS: `people.epfl.ch` should point to ??
