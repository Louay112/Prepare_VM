#!/bin/bash

cd "$(dirname "$0")"
sudo_password="kali"
echo $sudo_password | sudo -S apt update
echo $sudo_password | sudo -S apt install -y ansible-core
sed -i "s/PASSWORD_TO_REPLACE/$sudo_password/" "inventory.ini"
ansible-galaxy install -r "requirements.yml"
ansible-playbook -i "inventory.ini" "main.yml"
