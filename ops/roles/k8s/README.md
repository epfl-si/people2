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
Openshit is not able to migrate pods while they are running which would be THE
only motivation for chosing to use such an over-complicated infrastructure.
The scheduler is just a basic tetris of uncompressable resources that need to
fit in a given available space. For it to work, it needs to know in advance
the exact shape of each piece. Therefore, users are required to decide in
advance how many resources (memory/cpu) their pods will ever be using.
In order to avoid having your pods killed for overconsumpion, you are forced
to overestimate their needs leaving not only most of the computing resource
idle most of the time. Not only, since Openshit licenses are per compute unit,
this leads to a largely suboptimal usage of the licenses. Which, in turn,
explains why the scheduler is so dumb.

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

where `limits` refer to the threshold above which the pod to be killed, and
`request` is the minimum is the size of the tetris block. So that the above
parameters, delegate as much as possible the process scheduling to a capable
scheduler like the linux kernel, and minimize the risk for the pods of being
killed.

A risk exist that the scheduler is not only dumb, but also criminal and
instead of filling the nodes in a round-robin way, it waits for one node to
be filled by nominal requests before moving to the next one. In this case
my configuration would be very bad. I hope it is not the case because if it
were we should really stop paying for licenses and sue RH.

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
