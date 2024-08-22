#!/bin/bash

set -e
cd "$(cd "$(dirname "$0")"; pwd)"

help_and_exit () {
  fatal <<-__HELP_MSG
    Usage:

    $0 [ -t sometag ] [ ... ]
__HELP_MSG
  exit
}

die () {
    echo $* >&2
    exit 1
}

ensure_ansible () {
  if ! test -f ansible-deps-cache/.versions 2>/dev/null; then
    curl https://raw.githubusercontent.com/epfl-si/ansible.suitcase/master/install.sh | \
    SUITCASE_DIR=$PWD/ansible-deps-cache \
    SUITCASE_ANSIBLE_VERSION=9.3.0 \
    bash -x
  fi
  export PATH="$PWD/ansible-deps-cache/bin:$PATH"
  export ANSIBLE_ROLES_PATH="$PWD/ansible-deps-cache/roles"
  export ANSIBLE_COLLECTIONS_PATH="$PWD/ansible-deps-cache"

  . ansible-deps-cache/lib.sh
}

# ------------------------------------------------------------------------------

###                                                               defaults
mode=ansible-playbook
playbook_flags="-e @vars/global_vars.yml"
ansible_flags="-e @vars/global_vars.yml"
inventory_mode="test"
keybase_path="/keybase/team/epfl_people.prod"
dela_version="0.4.4"

declare -a ansible_args
while [ "$#" -gt 0 ]; do
  case "$1" in
        --help) help_and_exit ;;
        -m) mode=ansible
            ansible_args+=("-m")
            shift 
            ;;
        --prod) 
            inventory_mode="prod"
            shift 
            ;;
        --qual)
            inventory_mode="qual"
            shift 
            ;;
        --test)
            inventory_mode="test"
            shift 
            ;;
        -g|--galaxy) mode=galaxy
            shift
            ;;
        -k) keybase_path=$2
            shift 2
            ;;
        *)
            ansible_args+=("$1")
            shift ;;
    esac
done

###                                                                   validation
inventory="inventories/hosts-${inventory_mode}.yml"
[ -f "$inventory" ] || die "Inventory file $inventory does not exist"

[ -d "$keybase_path" ] || die "Invalid keybase path $keybase_path. May be keybase is not running ?"


if [ -f "playbook-${inventory_mode}.yml" ] ; then
    playbook="playbook-${inventory_mode}.yml"
else
    playbook="playbook.yml"
fi


###                                                                    execution
ensure_ansible

case "$mode" in
    ansible-playbook)
        ansible-playbook $playbook_flags -i $inventory \
                        "${ansible_args[@]}" \
                        -e "inventory_mode=$inventory_mode" \
                        -e "keybase_path='$keybase_path'" \
                        $playbook
        ;;
    ansible)
        ansible -i $inventory $ansible_flags "${ansible_args[@]}"
        ;;
    galaxy)
        ansible-galaxy "${ansible_args[@]}"
        ;;
esac
