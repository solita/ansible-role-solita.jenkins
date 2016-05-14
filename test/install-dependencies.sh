#!/bin/bash
set -eu

if [[ $(whoami) != 'vagrant' ]]; then
    echo 'This command is meant to be run in the Vagrant machine.' >&2
    exit 1
fi

role_name='solita.jenkins'
role_dir='/solita.jenkins'
test_roles_dir='/solita.jenkins/test/roles'
tarball=$(mktemp /tmp/solita.jenkins.XXXXXXXXXX.tar.gz)
requirements=$(mktemp /tmp/requirements.XXXXXXXXXX.yml)
temp_roles_dir=$(mktemp -d /tmp/roles.XXXXXXXXXX)

rm -rf "$test_roles_dir"
tar -C /solita.jenkins -zcvf "$tarball" . >/dev/null
cat >"$requirements" <<EOF
---
- src: $tarball
  name: $role_name
EOF
ansible-galaxy install -p "$test_roles_dir" -r "$requirements"
rm -rf "$tarball" "$requirements"

rm -rf "$test_roles_dir/$role_name"
ln -s "$role_dir" "$test_roles_dir/$role_name"
