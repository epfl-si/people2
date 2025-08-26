# Openshift / Kubernetes

## Naming / Labeling schema
We have one namespace but we plan to have several parallel instances of the
application running. Therefore we need to pay attention to name the objects
correcly otherwise it becomes easily a mess.

Rules to chose a resource name:
 - there is clearly no need to prepend `people` everywhere as this is
   already implicit in the namespace. On the other hand, the namespace refers
   to an ITIL-service. Will the service run also other applications ? I mean,
   that's way K8s was invented. Right? Well, the resources are so limited that
   it's already a miracle if I can fit two releases of people at the same time.
   Let alone another app. Nevertheless, let's keep the useless `people` prefix anyway.
 - what needs to be unique is the tuple (name,type). Therefore, there is
   no need to append or prepend the type to the name;
 - we want more than one instance of the whole shit to be running. Therefore,
   the name must contain the an instance identifier (e.g. _prod_, _canary_, _next_);

The full name for a resource will hence be something like: `people-release-basename-runenv`
or `people-{{ RELEASE }}-basename-{{ RUNENV }}`. Resources that can be shared between
different releases of the same app will drop the `release` part. For example,
secrets depend only on the run environment `RUNENV` while app configurations might
have few parameters that depend on the `RELEASE` too such as for example the
public address of the application or flags for enabling experimental features.

The difficult part is how to chose the base name. I think we should think in
terms of global service. How should the pod of the rails application that also
contains the proxy to the legacy application (or the legacy application itself) ?
`app`, `mainapp`, `main` ? Keep in mind that the route that will be served by
the legacy application will have to use the same selector as the one for the
main application. As usual, chosing names is the most difficult part of programming.

Anyway, all the _unique identifiers_ are defined in the `vars/main.yml` file
to avoid mistakes and enable future idea changes.

Since I have very little number of objects, I will eventually add more general
labels for nicer selctors, but for the moment the only mandatory label is
`kid: "#{kid.<basename>}"` that is used to uniquely identify the relations
between objects (`[route] -> service -> [deployment] -> pod). K8s is like
AWS: millions of options when you just need a few.

## Limits (a.k.a. the NO LIMITS MANIFESTO)
OpenShift doesn’t support live pod migration — ironically, the one feature that
might actually justify its over-engineered complexity. Instead, the scheduler is
little more than a glorified game of Tetris, where rigid, indivisible blocks
(resources, memory/cpu) have to be crammed into whatever space is left. Of
course, to make this work, it demands that users magically predict in advance
the exact CPU and memory their pods will ever require.

To avoid unexpected termination due to resource overconsumption, users naturally
tend to overestimate requirements, leaving much of the computing capacity sit
idle most of the time.

Since OpenShit licenses are billed per compute unit, you don’t just waste
capacity — you waste money too. Which makes you wonder: maybe the scheduler
isn’t _dumb_ at all. Maybe it’s just perfectly designed for license sales.

Therefore, as a way to protest, I have decided to setup my resource limits
for all pods as follows:

```
resources:
  limits:
    memory: MAXIMUM_ALLOWED_LIMIT
  requests:
    cpu: MINIMUM_ALLOWED_LIMIT
    memory: MINIMUM_ALLOWED_LIMIT
```

where `limits` define the threshold beyond which a pod gets unceremoniously
killed, while `requests` represent the minimum size of the Tetris block.
The idea, of course, is to offload as much scheduling as possible to something
that actually knows what it’s doing — namely, the Linux kernel — while
reducing the odds of pods being randomly terminated.

This still needs to be tested, because the scheduler might not just be _dumb_
but downright criminal and, instead of distributing workloads evenly among the
nodes, it could very well decide to _trust_ the declared _requests_ values and
cram as much as possible into the first node before moving on to the next.
If that’s the case, my configuration would be a complete disaster. And honestly,
if it turns out to work that way, we should just stop paying for licenses

## Resource types
Two types of resources:
 - STATIC: things that do not have replicas
 - DYNAMIC:  things that can have replicas

Here is a schema and some listing (courtesy of ChatGPT)

```
[ Static Resources ]
        │
┌─────────────────────────┼─────────────────────────┐
│                                          │                                         │
Workload Controllers                    Networking                             Config / Storage
(static definitions)                    (stable front doors)                (referenced by name)
│                                          │                                         │
▼                                          ▼                                         ▼
Deployment / DC                         Service      ──────▶ Endpoints   ConfigMap / Secret
StatefulSet                             Route (OCP)                           PVC / PV / SC
DaemonSet                               Ingress
Job / CronJob
│
▼
┌─────────┐
│ Dynamic Layer │
└─────────┘
│
▼
ReplicaSet / RC  ◀───── created per rollout (dynamic)
│
▼
Pods  ◀───── created/destroyed, matched by labels
```

### Static resources (stable, name-referenced)
Have a fixed name (you create them once), are directly referenced by other
resources via name, and don’t change on their own.

 - Workload controllers
   * Deployment
   * DeploymentConfig (OpenShift)
   * StatefulSet
   * DaemonSet
   * Job / CronJob
 - Networking
   * Service
   * Route (OpenShift)
   * Ingress
   * NetworkPolicy (references by labels, but itself is static)
 - Config / Storage
   * ConfigMap
   * MariaDB (the crd, not the pods)
   * Secret
   * PersistentVolume (PV)
   * PersistentVolumeClaim (PVC)
   * StorageClass

### Dynamic resources
Are created and managed by controllers, have generated names (with suffixes),
and come and go dynamically (deleted, replaced, scaled up/down).

 - Pods (created by controllers or directly)
 - ReplicaSets (owned by Deployments)
 - ReplicationControllers (owned by DeploymentConfigs)
 - Endpoints / EndpointSlices (owned by Services)
 - Jobs’ Pods (short-lived, created by Job controller)
 - Evicted / Failed pods (transient, automatically cleaned up)
