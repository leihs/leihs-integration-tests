#!/bin/bash -eu

# TODO: use what is checked into project or superproject if present
GIT_REF='mfa/integration-tests' # git ref for leihs-instance project
LEIHS_GIT_REF='v/5.0-staging'   # git ref for leihs project (inside leihs-instance)

cd leihs-instance
git fetch
git reset --hard "origin/${GIT_REF}"
git submodule update --init --force --recursive
cd leihs
git fetch
git reset --hard "origin/${LEIHS_GIT_REF}"
git submodule update --init --force --recursive
cd ..

# https://github.com/leihs/leihs-instance/blob/4ca6051ff17b74891687cb4248bfce1613e4d62e/GUIDE.md
export LEIHS_HOSTNAME="leihs-integration.example.com"
sh -c "echo \"$(cat examples/hosts_example)\"" > hosts
sh -c "echo \"$(cat examples/host_vars_example.yml)\"" > "host_vars/${LEIHS_HOSTNAME}.yml"
sh -c "echo \"$(cat examples/settings.yml)\"" > "settings/${LEIHS_HOSTNAME}.yml"

# self-install, for testing only
sh -c "echo \"[leihs_server]\"" > "hosts"
sh -c "echo \"leihs-integration.example.com ansible_ssh_common_args='-F ../../../vagrant-ssh-config' ansible_ssh_user='vagrant' ansible_become='yes' ansible_become_method='sudo'\"" >> "hosts"
