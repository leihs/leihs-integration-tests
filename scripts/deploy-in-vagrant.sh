#!/bin/sh -eu

cd /vagrant || { # mounted from host to guest
  echo 'must be run inside guest machine!'
  exit 1
}
cd

cd leihs-instance/leihs/deploy
cp all.yml ../../group_vars/all.yml
ansible-playbook -i ../../hosts deploy_play.yml
