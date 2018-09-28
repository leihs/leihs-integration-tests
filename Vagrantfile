# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # base box
  config.vm.box = "bento/ubuntu-16.04"
  # ports - prod
  config.vm.network "forwarded_port", guest: 80, host: 10080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 443, host: 10433, host_ip: "127.0.0.1"
  # ports - test only
  config.vm.network "forwarded_port", guest: 5432, host: 10054, host_ip: "127.0.0.1"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.box_check_update = false

  config.vm.provision "shell", inline: <<-SHELL
    # from <leihs/deploy/container-test/bin/install-dependencies>

    # remove this packet if installed - its not needed and causes problems on Ubuntu
    apt-get purge -y -f open-iscsi || true

    apt-get update
    apt-get install -y -f curl build-essential libssl-dev default-jdk ruby git

    # https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-releases-via-apt-debian
    echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main' > /etc/apt/sources.list.d/ansible-ppa.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 \
      || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 93C4A3FD7BB9C367
    apt-get update
    apt-get install -y -f ansible
  SHELL
end
