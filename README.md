🥒 [leihs][] Integration-Tests
==============================

[Executable Specifications](https://en.wikipedia.org/wiki/Behavior-driven_development#Behavioral_specifications) for the [**leihs** software system][leihs].

## technology stack

- [**Gherkin**](https://docs.cucumber.io/gherkin/reference/) Scenarios
- [**RSpec**](https://rspec.info/) Test Runner (with [Turnip](https://github.com/jnicklas/turnip), [Sequel](https://rubygems.org/gems/sequel) Database Toolkit)
- [**Capybara**](https://teamcapybara.github.io/capybara/) (with [Selenium WebDriver](https://www.seleniumhq.org/projects/webdriver/), [geckodriver](https://github.com/mozilla/geckodriver))
- [**Firefox**](https://www.mozilla.org/firefox/) Web browser
- [**Vagrant**](https://www.vagrantup.com/) virtual machine and container management (with [VirtualBox](https://www.virtualbox.org/))
- [**Ubuntu**](https://www.ubuntu.com/server) linux operation system
- [**Ansible**](https://www.ansible.com/) software deployment, server provisioning, configuration management



Reverse Proxy 
-------------

### Caching 

Prototyping and testing caching:

* must retrieve the whole file, i.e. use `tee` 
* retrieve at least two times 
* headers should correspond to the browner headers, e.g. "copy as curl" 
* we announce caching via header for easier debugging rep verification 

    curl -i 'http://localhost:3200/my/css/fontawesome-free-5.0.13/css/fontawesome-all.css' -H 'Referer: http://localhost:3200/' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36' -H 'DNT: 1' --compressed | tee tmp/fontawesome-all.css | head -n 20

    ...
    X-Cache: HIT from localhost
    ...


### Caveats 

* disk cache seems only to work with absolute paths
* disk cache doesn't work if the "subdirectory" does not exists, e.g. `/tmp/apche-cache` will not work .i.g.; 

* memory cache shmcb seems to work just by file size; don't know if there is any management at all 

Whenever something is no right, you will get a "cache miss" and possibly some
"unwilling" note in the logs.  




Vagrant
-------

### run locally

expose ports from inside VM/container on host machine:

```shell
# those are the default values:
export LEIHS_HTTP_PORT='10080'
export LEIHS_HTTP_PORTS='10443'
export LEIHS_HOST_PORT_POSTGRES='10054' # DB backdoor for automated testing only
export LEIHS_HOST_PORT_SSH='2200' # for vagrant ssh into guest
```

NOTE: only works if checked out as part of [superproject][leihs]!

```shell
bundle install
vagrant up
./scripts/deploy-to-vagrant.sh
./scripts/ansible-to-vagrant.sh stop_play.yml
# `vagrant reload` if the following command does not work
vagrant ssh -- 'sudo sh /vagrant/scripts/config-postgres-for-vagrant.sh'
./scripts/ansible-to-vagrant.sh start_play.yml
until curl -k --fail -s https://localhost:${LEIHS_HTTP_PORTS}; do sleep 3; done
bundle exec rspec ./spec
```

### debug selenium/webdriver/geckodriver/firefox setup

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


### Cider-CI traits install (ubuntu)

```sh
# vagrant
apt update
apt install vagrant

# virtualbox
sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib non-free' > /etc/apt/sources.list.d/virtualbox.list"
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -O- | sudo apt-key add -
apt update
apt install -y virtualbox-5.1 virtualbox-dkms
usermod -a -G vboxusers ci-exec-user

# virtualbox kernel modules
apt install build-essential linux-headers-`uname -r` -y
apt install dkms -y
#  check it
lsmod | grep vboxdrv
#  => vboxdrv 446464 3 vboxnetadp,vboxnetflt,vboxpci
```

[leihs]: https://github.com/leihs/leihs
