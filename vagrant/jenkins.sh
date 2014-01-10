#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR/../

function on_exit()
{
    mkdir -p $DIR/logs

    vagrant ssh salt --command "sudo cp /var/log/salt/master /vagrant/vagrant/logs/salt-master"
    vagrant ssh percona1 --command "sudo cp /var/log/salt/minion /vagrant/vagrant/logs/percona1-minion"
    vagrant ssh percona2 --command "sudo cp /var/log/salt/minion /vagrant/vagrant/logs/percona2-minion"
    vagrant ssh percona3 --command "sudo cp /var/log/salt/minion /vagrant/vagrant/logs/percona3-minion"

    vagrant destroy -f
}

trap on_exit EXIT

echo "***** Building Instances:" &&
vagrant up --provider lxc &&
vagrant status &&

echo "***** Delaying a few seconds for salt to be ready:"
sleep 10 &&

echo "***** Testing Ping:"
vagrant ssh salt --command "sudo salt '*' test.ping" &&

echo "***** Building Percona 1:"
vagrant ssh salt --command "sudo salt --show-timeout --timeout=600 -l debug 'percona1' state.sls percona.repo,percona.cluster_bootstrap" &&
echo "***** Running States:"
vagrant ssh salt --command "sudo salt '*' state.running" &&

echo "***** Building Percona 2:"
vagrant ssh salt --command "sudo salt --show-timeout --timeout=600 -l debug 'percona2' state.highstate" &&
echo "***** Running States:"
vagrant ssh salt --command "sudo salt '*' state.running" &&

echo "***** Building Percona 3:"
vagrant ssh salt --command "sudo salt --show-timeout --timeout=600 -l debug 'percona3' state.highstate" &&
echo "***** Running States:"
vagrant ssh salt --command "sudo salt '*' state.running" &&

echo "***** Disabling Bootstrap on Percona 1:"
vagrant ssh salt --command "sudo salt --show-timeout --timeout=600 -l debug 'percona1' state.highstate" &&
echo "***** Running States:"
vagrant ssh salt --command "sudo salt '*' state.running" &&

echo "***** Complete"
