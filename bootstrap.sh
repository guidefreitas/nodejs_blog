#!/usr/bin/env bash

apt-get update
apt-get install -y build-essential nodejs mongodb coffeescript git-all

#Heroku
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh