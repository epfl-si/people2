## Server architecture
Server runs on RHEL VM that provides podman containers. By default podman
runs _rootless_ and the idea is to follow the standard. Therefore, all the pods are running under a standard user (`fsd`).
This and the fact of using podman/docker for applications, introduces two issues:

 - _rootless_ processes cannot bind to privileged ports like standard http ports 80 and 443.
 - podman actually does NAT when exposing ports of a container. Therefore, the traefik process that runs in a container have no way to know what was the original IP address of the browser.

The solution currently implemented but which does not fix the second issue is the following:

 - traefik running on podman will bind on non-privileged ports (_e.g._ 8033, 4433);
 - we use firewall rules to forward traefik directed to http ports to the ports where podman is listening;

An alternative, is to add a second proxy which would replace the firewall rules. It would run as root, apply the ssl certificates and forward to the internal traefik (which only needs to [trust](https://doc.traefik.io/traefik/routing/entrypoints/#forwarded-headers) the `x-forwarded-for` that arrives from the edge proxy) that will dispatch to the correct application pod. The problem is that this will not allow for dynamically configuring how we select the certificates.


### Variables
  * variables that are supposed to be defined in inventories are in *CAPITAL_LETTERS*
  * modules should provide default value only when this is very safe. It is better for ansible to crash because a variable is not defined rather then configuring something incorrectly.

### Tags

Tags added as `tags:` into the playbook for `roles:` are automatically applied
to all the tasks of the role. Instead, tags added to `include_tasks` directive
are not and need to be propagated explicitly with `apply:/tags:`

Check all available tags with the following command

```bash
./possible.sh --test --list-tags
```

#### Conventions

 * all roles will have the corresponding tag added in the playbook. Therefore
 	to execute only that role, it is enough to `-t role_name` e.g. `possible.sh --test -t system` will include the `system` role and execute ALL the tasks
 	therein because the tag is in this case propagated below.
 * In roles, the `main.yml` file is mostly a manifest that loads files with `import_tasks:`. See the dummy `learn` role for an example on how to use the tags.
 * Try to keep role's tasks consistent grouping them in a consistent way. The following list seams to be a reasonable starting point:
   1. _setup_
   2. _install_
   3. _config_
   4. _run_
   5. _admin_

