#!/usr/bin/env sh

echo "nameserver 1.1.1.1" > /etc/resolv.conf
# Install minimal tools
apt-get update
apt-get install wget sudo avahi-daemon -y
apt-get clean
# Ensure we have the pi user
useradd -s /bin/bash -Gsudo -m pi
usermod -aG plugdev pi
echo "pi:raspberry" | chpasswd
# Disable root login on SSH
mkdir -p /etc/ssh/sshd_config.d/
echo "PermitEmptyPasswords no" > /etc/ssh/sshd_config.d/pirogue-ssh.conf
echo "PermitRootLogin no" >> /etc/ssh/sshd_config.d/pirogue-ssh.conf
# Force egenerate SSH host keys if exist and enable SSH
rm -f /etc/ssh/ssh_host_*
systemctl enable ssh
# Change the hostname
echo "127.0.0.1 pirogue" >> /etc/hosts
echo "127.0.0.1 pirogue.local pirogue" >> /etc/hosts
echo "::1 pirogue" >> /etc/hosts
echo "::1 pirogue.local pirogue" >> /etc/hosts
echo "pirogue" > /etc/hostname
# Add PTS PPA
wget -O /etc/apt/sources.list.d/pirogue.list https://pts-project.org/debian-12/pirogue.list
wget -O /etc/apt/trusted.gpg.d/pirogue.asc   https://pts-project.org/debian-12/Key.gpg
