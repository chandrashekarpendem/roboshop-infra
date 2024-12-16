#!/bin/bash

labauto ansible
ansible-pull  -e host=localhost, -U https://github.com/chandrashekarpendem/roboshop-ansible.git roboshop.yml  -e role_name=${component} -e env=${env} | tee /opt/ansible.log
