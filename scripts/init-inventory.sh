#!/bin/sh -eu

cd /vagrant || { # mounted from host to guest
  echo 'must be run inside guest machine!'
  exit 1
}
cd

rm -rf leihs leihs-instance
mkdir leihs-instance
cd leihs-instance/

git clone --recursive https://github.com/leihs/leihs leihs
cd leihs && git checkout origin/mfa/deploy && git submodule update deploy && cd ..

cp -R leihs/deploy/inventories/integration-tests-example/* .
rm -rf group_vars/all.yml
cat leihs/deploy/all.yml > group_vars/all.yml
