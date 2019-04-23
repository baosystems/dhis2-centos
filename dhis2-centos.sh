#!/bin/bash

cd "${BASH_SOURCE%/*}"

rpm -q ansible > /dev/null 2>&1 || yum -y install ansible

ansible-playbook -i 'localhost,' -c local main.yml -vv
