# -*- mode: ruby -*-
# vi: set ft=ruby :

# Leihs: supported config vars and their defaults:
LEIHS_HOST_PORT_HTTP = ENV['LEIHS_HOST_PORT_HTTP'] || '10080'
LEIHS_HOST_PORT_HTTPS = ENV['LEIHS_HOST_PORT_HTTPS'] || '10443'
LEIHS_HOST_PORT_POSTGRES = ENV['LEIHS_HOST_PORT_POSTGRES'] || '10054'
LEIHS_HOST_PORT_SSH = ENV['LEIHS_HOST_PORT_SSH'] || '2200'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # https://superuser.com/a/1182104
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.define 'leihs-integration'
  config.vm.hostname = "leihs-integration.example.com"
  # base box
  config.vm.box = "bento/ubuntu-18.04"
  # ports - prod
  config.vm.network "forwarded_port", guest: 80, host: LEIHS_HOST_PORT_HTTP, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 443, host: LEIHS_HOST_PORT_HTTPS, host_ip: "127.0.0.1"
  # ports - test only
  config.vm.network "forwarded_port", guest: 5432, host: LEIHS_HOST_PORT_POSTGRES, host_ip: "127.0.0.1"
  # ports - vagrant only
  config.vm.network "forwarded_port", guest: 22, host: LEIHS_HOST_PORT_SSH, id: 'ssh'

  config.vm.provision "shell", inline: <<-SHELL
    # from <leihs/deploy/container-test/bin/install-dependencies>

    # remove this packet if installed - its not needed and causes problems on Ubuntu
    apt-get purge -y -f open-iscsi || true

    apt-get update
    apt-get install -y -f curl build-essential libssl-dev default-jdk ruby git

    # https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-debian
    echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main' > /etc/apt/sources.list.d/ansible-ppa.list
    # FIXME: remove no-TLS fallback
    apt-key adv --keyserver hkps.pool.sks-keyservers.net --recv-keys 93C4A3FD7BB9C367 \
      || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 93C4A3FD7BB9C367
    apt-get update
    apt-get install -y -f ansible
  SHELL

  # dont automatically check for updates
  config.vm.box_check_update = false
end
