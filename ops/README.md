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

