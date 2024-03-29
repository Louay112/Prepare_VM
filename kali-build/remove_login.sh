#!/bin/bash

cd "$(dirname "$0")"
script_dir=$(pwd)
sudo_password="kali"

echo $sudo_password | sudo -S sed -i 's/^#\?\(autologin-user=\|autologin-user-timeout=\)/\1/' /etc/lightdm/lightdm.conf
if ! grep -q "\[Seat:\*\]" /etc/lightdm/lightdm.conf; then
    echo -e "[Seat:*]\nautologin-user=kali\nautologin-user-timeout=0" | echo $sudo_password | sudo -S tee -a /etc/lightdm/lightdm.conf > /dev/null
else
    echo $sudo_password | sudo -S sed -i '/^\[Seat:\*\]/,/^\[/ s/^autologin-user=.*$/autologin-user=kali/; /^\[Seat:\*\]/,/^\[/ s/^autologin-user-timeout=.*$/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
fi
