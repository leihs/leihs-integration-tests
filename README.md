# CI install (ubuntu)

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
