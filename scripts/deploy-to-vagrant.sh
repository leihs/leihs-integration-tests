#!/bin/bash -exu

vagrant ssh-config \
  | sed 's/Host leihs-integration/Host leihs-integration.example.com/' \
  > vagrant-ssh-config

cd ../deploy
ansible-playbook -i ../integration-tests/inventory/hosts deploy_play.yml
