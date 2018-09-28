#!/bin/sh -eu

git clone https://github.com/leihs/leihs-instance
cd leihs-instance
git checkout origin/mfa/v5

# https://github.com/leihs/leihs-instance/blob/4ca6051ff17b74891687cb4248bfce1613e4d62e/GUIDE.md
export LEIHS_HOSTNAME="leihs.example.com"
sh -c "echo \"$(cat examples/hosts_example)\"" > hosts
sh -c "echo \"$(cat examples/host_vars_example.yml)\"" > "host_vars/${LEIHS_HOSTNAME}.yml"
sh -c "echo \"$(cat examples/settings.yml)\"" > "settings/${LEIHS_HOSTNAME}.yml"

# self-install, for testing only
sh -c "echo \"ansible_connection: local\"" >> "host_vars/${LEIHS_HOSTNAME}.yml"
