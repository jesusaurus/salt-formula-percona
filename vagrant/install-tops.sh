#!/bin/bash

sudo mkdir -p /srv/salt /srv/pillar

# Install State Top
sudo ln -s /vagrant/vagrant/top.state /srv/salt/top.sls

# Install Pillar Top
sudo ln -s /vagrant/vagrant/top.pillar /srv/pillar/top.sls

# # Install Example Pillar
sudo ln -s /vagrant/pillar.example /srv/pillar/example.sls
