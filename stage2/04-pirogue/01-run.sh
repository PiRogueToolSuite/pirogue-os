#!/bin/bash -e

# Disable useerconfig asking for the creation of a new unix user
on_chroot << EOF
apt-get remove --purge userconf-pi
EOF

###
# Install PiRogue packages
on_chroot << EOF
curl -o /etc/apt/sources.list.d/pirogue-os.list "https://piroguetoolsuite.github.io/ppa/pirogue.list"
curl -o /etc/apt/trusted.gpg.d/pirogue-os.asc "https://piroguetoolsuite.github.io/ppa/Key.gpg"
apt update
DEBIAN_FRONTEND=noninteractive apt install -y pirogue-base
EOF

if ! on_chroot dpkg-query -s pirogue-base; then
  echo "E: pirogue-base wasn't successfully installed"
  exit 1
fi