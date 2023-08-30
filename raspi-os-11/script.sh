#!/usr/bin/env sh

# Ensure we have the pi user
useradd -s /bin/bash -Gsudo -m pi
echo "pi:raspberry" | chpasswd
# Enable SSH, disabled by default
systemctl enable ssh
systemctl enable regenerate_ssh_host_keys
# Change the hostname
sed -i 's/raspberrypi/pirogue/g' /etc/hosts
echo 'pirogue' > /etc/hostname
# Add PTS PPA
curl -o /etc/apt/sources.list.d/pirogue.list https://pts-project.org/ppa/pirogue.list
curl -o /etc/apt/trusted.gpg.d/pirogue.asc   https://pts-project.org/ppa/Key.gpg
