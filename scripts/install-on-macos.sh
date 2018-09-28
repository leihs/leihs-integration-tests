#!/bin/sh -eu

brew cask install vagrant virtualbox || {
  echo 'homebrew install did not work, download manually!'
  open 'https://www.vagrantup.com/downloads.html'
  open 'https://www.virtualbox.org'
}
