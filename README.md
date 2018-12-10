# 🥒 [leihs][] Integration-Tests

[Executable Specifications](https://en.wikipedia.org/wiki/Behavior-driven_development#Behavioral_specifications) for the [**leihs** software system][leihs].

## technology stack

- [**Gherkin**](https://docs.cucumber.io/gherkin/reference/) Scenarios
- [**RSpec**](https://rspec.info/) Test Runner (with [Turnip](https://github.com/jnicklas/turnip), [Sequel](https://rubygems.org/gems/sequel) Database Toolkit)
- [**Capybara**](https://teamcapybara.github.io/capybara/) (with [Selenium WebDriver](https://www.seleniumhq.org/projects/webdriver/), [geckodriver](https://github.com/mozilla/geckodriver))
- [**Firefox**](https://www.mozilla.org/firefox/) Web browser
- [**Vagrant**](https://www.vagrantup.com/) virtual machine and container management (with [VirtualBox](https://www.virtualbox.org/))
- [**Ubuntu**](https://www.ubuntu.com/server) linux operation system
- [**Ansible**](https://www.ansible.com/) software deployment, server provisioning, configuration management

---

## run locally

expose ports from inside VM/container on host machine:

```shell
# those are the default values:
export LEIHS_HOST_PORT_HTTP='10080'
export LEIHS_HOST_PORT_HTTPS='10443'
export LEIHS_HOST_PORT_POSTGRES='10054' # DB backdoor for automated testing only
export LEIHS_HOST_PORT_SSH='2200' # for vagrant ssh into guest
```

NOTE: only works if checked out as part of [superproject][leihs]!

```shell
bundle install
vagrant up
./scripts/deploy-to-vagrant.sh
./scripts/ansible-to-vagrant.sh stop_play.yml
vagrant ssh -- 'sudo sh /vagrant/scripts/config-postgres-for-vagrant.sh'
vagrant ssh -- "sudo systemctl restart postgresql"
./scripts/ansible-to-vagrant.sh start_play.yml
until curl -k --fail -s https://localhost:${LEIHS_HOST_PORT_HTTPS}; do sleep 3; done
bundle exec rspec ./spec
```

## debug selenium/webdriver/geckodriver/firefox setup

```sh
# start ruby repl
xvfb-run -a -e log/xvfb.log bundle exec irb -W --verbose
```

```ruby
require 'selenium-webdriver'

opts = Selenium::WebDriver::Firefox::Options.new(
  log_level: :trace, binary: ENV['FIREFOX_ESR_60_PATH'])

driver = Selenium::WebDriver.for :firefox, options: opts

# should now accept commands:
driver.manage.window.resize_to(1024,768)
```

# TEMP

## Cider-CI traits install (ubuntu)

```sh
# vagrant
apt update
apt install vagrant

# virtualbox
sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib non-free' > /etc/apt/sources.list.d/virtualbox.list"
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | sudo apt-key add -
apt update
apt install virtualbox-5.1 -y
usermod -a -G vboxusers ci-exec-user

# virtualbox kernel modules
apt install build-essential linux-headers-`uname -r` -y
apt install dkms -y
#  check it
lsmod | grep vboxdrv
#  => vboxdrv 446464 3 vboxnetadp,vboxnetflt,vboxpci
```

[leihs]: https://github.com/leihs/leihs
