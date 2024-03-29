#!/bin/bash

FLAG_FILE="$(pwd)/start_playbook.flag"
PLAYBOOK="$HOME/kali-build/main.yml"
INVENTORY="$HOME/kali-build/inventory.ini"
TAGS1="skip_role"
TAGS2="skip_role2"

if [ -f "$FLAG_FILE" ]; then
    ansible-playbook -i $INVENTORY $PLAYBOOK --skip-tags $TAGS1
else
    ansible-playbook -i $INVENTORY $PLAYBOOK --skip-tags $TAGS1,$TAGS2
fi