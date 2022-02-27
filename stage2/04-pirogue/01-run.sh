#!/bin/bash -e

# Install firewall persistency
on_chroot << EOF
DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent
EOF

# Configure dnsmasq
install -m 644 files/dnsmasq.conf  "${ROOTFS_DIR}/etc/"

# Configure dhcpcd
install -m 644 files/dhcpcd.conf  "${ROOTFS_DIR}/etc/"

# Configure hostapd
install -m 644 files/hostapd.conf  "${ROOTFS_DIR}/etc/hostapd/"

# Enable hostapd service
on_chroot << EOF
systemctl unmask hostapd
systemctl enable hostapd
EOF

# Install mitmproxy
on_chroot << EOF
pip3 install mitmproxy
EOF

# Enable wlan
on_chroot << EOF
rfkill unblock wlan
EOF

# Enable IP forward
on_chroot << EOF
echo "Enable IP forward"
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/routed-ap.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.d/routed-ap.conf
EOF

# Create firewall rules
install -m 644 files/iptables.rules  "${ROOTFS_DIR}/etc/iptables/rules.v4"
install -m 644 files/iptables.rules  "${ROOTFS_DIR}/etc/iptables/rules.v6"


# Install InfluxDB and Chronograf
on_chroot << EOF
echo "Install InfluxDB and Chronograf"
wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
echo "deb https://repos.influxdata.com/debian buster stable" | tee /etc/apt/sources.list.d/influxdb.list
apt-get update
apt-get install -y influxdb chronograf python3-influxdb
systemctl enable influxdb
EOF
# Patch InfluxDB startup script
mkdir -p "${ROOTFS_DIR}/usr/lib/influxdb/scripts/"
install -v -m 755 files/influxd-systemd-start.sh	        "${ROOTFS_DIR}/usr/lib/influxdb/scripts/influxd-systemd-start.sh"


# Install Grafana
on_chroot << EOF
echo "Install Grafana"
wget https://dl.grafana.com/oss/release/grafana_8.1.5_armhf.deb
dpkg -i grafana_8.1.5_armhf.deb
rm -f grafana_8.1.5_armhf.deb
systemctl enable grafana-server
grafana-cli plugins install grafana-worldmap-panel
EOF

install -v -m 644 files/grafana.ini	 "${ROOTFS_DIR}/etc/grafana/grafana.ini"


# Install Python stuff
on_chroot << EOF
echo "Install Python stuff"
pip3 install -U pyshark frida-tools objection geoip2 Adafruit-Blinka Pillow communityid numpy==1.22.0 mvt
EOF

###
# Configure Suricata
on_chroot << EOF
suricata-update --no-check-certificate update-sources
suricata-update --no-check-certificate enable-source et/open || true
suricata-update --no-check-certificate enable-source oisf/trafficid || true
suricata-update --no-check-certificate enable-source ptresearch/attackdetection || true
suricata-update --no-check-certificate enable-source sslbl/ssl-fp-blacklist || true
suricata-update --no-check-certificate 
EOF

install -m 644 files/pirogue_rfkill.service  "${ROOTFS_DIR}/etc/systemd/system/pirogue_rfkill.service"
on_chroot << EOF
systemctl enable pirogue_rfkill
EOF


# Enable I2C and SPI
on_chroot << EOF
echo dtparam=i2c_arm=on >> /boot/config.txt
echo dtparam=spi=on >> /boot/config.txt
EOF

# Configure RTC
on_chroot << EOF
echo dtoverlay=i2c-rtc,ds3231 >> /boot/config.txt
echo rtc-ds3231 >> /etc/modules
apt-get purge -y fake-hwclock
EOF

install -m 644 files/85-hwclock.rules "/etc/udev/rules.d/85-hwclock.rules"

# Configure temperature regulation
on_chroot << EOF
echo dtoverlay=gpio-fan,gpiopin=13,temp=37000 >> /boot/config.txt
EOF

###
# Install nfstream
on_chroot << EOF
# libgpg-error
git clone --branch libgpg-error-1.42 https://github.com/gpg/libgpg-error
cd libgpg-error
./autogen.sh
./configure -enable-maintainer-mode --enable-static --enable-shared --with-pic --disable-doc --disable-nls
make
make install
cd ..
rm -rf libgpg-error
# libgcrypt
git clone --branch libgcrypt-1.8.8 https://github.com/gpg/libgcrypt
cd libgcrypt
./autogen.sh
./configure -enable-maintainer-mode --enable-static --enable-shared --with-pic --disable-doc
make
make install
cd ..
rm -rf libgcrypt
# libpcap
git clone --branch fanout https://github.com/tsnoam/libpcap
cd libpcap
./configure --enable-ipv6 --disable-universal --enable-dbus=no --without-libnl
make
make install
cd ..
rm -rf libpcap
# nDPI
git clone --branch dev https://github.com/ntop/nDPI.git
cd nDPI
git checkout 550e6fe6fcd96e507763db66873791b96f19fe2b
./autogen.sh
./configure
make
mkdir -p /usr/local/include/ndpi
cp -a src/include/. /usr/local/include/ndpi/
cp example/ndpiReader /usr/local/bin/ndpiReader
cp src/lib/libndpi.a /usr/local/lib/libndpi.a
cd ..
rm -rf nDPI

# nfstream
git clone https://github.com/nfstream/nfstream.git
cd nfstream
git checkout v6.3.5
python3 -m pip install -r requirements.txt
python3 setup.py bdist_wheel
pip3 install . 
EOF


###
# Install PiRogue packages
on_chroot << EOF
curl -o /etc/apt/sources.list.d/pirogue.list "https://piroguetoolsuite.github.io/ppa/pirogue.list"
curl https://piroguetoolsuite.github.io/ppa/Key.gpg | apt-key add -
apt update
apt install -y -o Dpkg::Options::="--force-overwrite" pirogue-base
EOF