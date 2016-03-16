#!/bin/bash

apt-get update
apt-get install -y make curl git
curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh
/etc/init.d/td-agent start
/etc/init.d/td-agent status

cp /vagrant/etc/td-agent.conf /etc/td-agent/td-agent.conf
