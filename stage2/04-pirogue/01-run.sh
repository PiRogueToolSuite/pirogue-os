#!/bin/bash -e

# Disable useerconfig asking for the creation of a new unix user
on_chroot << EOF
systemctl disable userconfig.service
EOF

###
# Install PiRogue packages
on_chroot << EOF
curl -o /etc/apt/sources.list.d/pirogue-os.list "https://piroguetoolsuite.github.io/ppa/pirogue.list"
curl -o /etc/apt/trusted.gpg.d/pirogue-os.asc "https://piroguetoolsuite.github.io/ppa/Key.gpg"
apt update
DEBIAN_FRONTEND=noninteractive apt install -y pirogue-base
EOF