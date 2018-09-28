# 🥒 [leihs][] Integration-Tests

[Executable Specifications](https://en.wikipedia.org/wiki/Behavior-driven_development#Behavioral_specifications) for the [**leihs** software system][leihs].

## technology stack

- [**Gherkin**](https://docs.cucumber.io/gherkin/reference/) Scenarios
- [**RSpec**](https://rspec.info/) Test Runner (with [Turnip](https://github.com/jnicklas/turnip))
- [**Capybara**](https://teamcapybara.github.io/capybara/) (with [Selenium WebDriver](https://www.seleniumhq.org/projects/webdriver/), [geckodriver](https://github.com/mozilla/geckodriver))
- [**Firefox**](https://www.mozilla.org/firefox/) Web browser
- [**Vagrant**](https://www.vagrantup.com/) virtual machine and container management (with [VirtualBox](https://www.virtualbox.org/))
- [**Ubuntu**](https://www.ubuntu.com/server) linux operation system
- [**Ansible**](https://www.ansible.com/) software deployment, server provisioning, configuration management

---

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
