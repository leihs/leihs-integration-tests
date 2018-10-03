#!/bin/bash -exu

vagrant ssh-config \
  | sed 's/Host leihs-integration/Host leihs-integration.example.com/' \
  > vagrant-ssh-config

cd leihs-instance/leihs/deploy
ansible-playbook -i ../../hosts deploy_play.yml
