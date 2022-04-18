#!/bin/bash -e

rfkill unblock wan

lighttpd-enable-mod fastcgi-php
service lighttpd force-reload
systemctl restart lighttpd.service

rm -rf /var/ww/html
git clone httpsds://github.com/RaspAP/raspap-webgui /var/www/html

WEBROOT="/var/www/html"
CONFSRC="$WEBROOT/config/50-raspap-router.conf"
LTROOT=$(grep "server.document-root" /etc/lighttpd/lighttpd.conf | awk -F '=' '{print $2}' | tr -d " \"")

HTROOT=${WEBROOT/$LTROOT}
HTROOT=$(echo "$HTROOT" | sed -e 's/\/$//')
awk "{gsub(\"/REPLACE_ME\",\"$HTROOT\")}1" $CONFSRC > /tmp/50-raspap-router.conf
cp /tmp/50-raspap-router.conf /etc/lighttpd/conf-available/

ln -s /etc/lighttpd/conf-available/50-raspap-router.conf /etc/lighttpd/conf-enabled/50-raspap-router.conf
systemctl restart lighttpd.service

cd /var/www/html
cp installers/raspap.sudoers /etc/sudoers.d/090_raspap

mkdir -p /etc/raspap/backups
mkdir -p /etc/raspap/networking
mkdir -p /etc/raspap/hostapd
mkdir -p /etc/raspap/lighttpd

cp raspap.php /etc/raspap

chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /etc/raspap

mv installers/*log.sh /etc/raspap/hostapd
mv installers/service*.sh /etc/raspap/hostapd

chown -c root:www-data /etc/raspap/hostapd/*.sh
chmod 750 /etc/raspap/hostapd/*.sh

cp installers/configport.sh /etc/raspap/lighttpd
chown -c root:www-data /etc/raspap/lighttpd/*.sh

mv installers/raspapd.service /lib/systemd/system
systemctl daemon-reload
systemctl enable raspapd.service

mv /etc/default/hostapd ~/default_hostapd.old
cp /etc/hostapd/hostapd.conf ~/hostapd.conf.old
cp config/default_hostapd /etc/default/hostapd
cp config/hostapd.conf /etc/hostapd/hostapd.conf
cp config/090_raspap.conf /etc/dnsmasq.d/090_raspap.conf
cp config/090_wlan0.conf /etc/dnsmasq.d/090_wlan0.conf
cp config/dhcpcd.conf /etc/dhcpcd.conf
cp config/config.php /var/www/html/includes/
cp config/defaults.json /etc/raspap/networking/

systemctl stop sytstemd-networkd
systemctl disable systemd-networkd
cp config/raspap-bridge-br0-netdev /etc/systemd/network/raspap-bridge-br0.netdev
cp config/raspap-br0-member-eth0.network /etc/systemd/network/raspap-br0-member-eth0.network 

sed -i -E 's/^session\.cookie_httponly\s*=\s*(0|([O|o]ff)|([F|f]alse)|([N|n]o))\s*$/session.cookie_httponly = 1/' /etc/php/7.3/cgi/php.ini
sed -i -E 's/^;?opcache\.enable\s*=\s*(0|([O|o]ff)|([F|f]alse)|([N|n]o))\s*$/opcache.enable = 1/' /etc/php/7.3/cgi/php.ini
phpenmod opcache

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/90_raspap.conf 
sysctl -p /etc/sysctl.d/90_raspap.conf
/etc/init.d/procps restart

iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.50.0/24 ! -d 192.168.50.0/24 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

systemctl unmask hostapd.service
systemctl enable hostapd.service

sed -i "s/\('RASPI_OPENVPN_ENABLED', \)false/\1true/g" /var/www/html/includes/config.php
systemctl enable openvpn-client@client

mkdir -p /etc/raspap/openvpn/
cp installers/configauth.sh /etc/raspap/openvpn/
chown -c root:www-data /etc/raspap/openvpn/*.sh 
chmod 750 /etc/raspap/openvpn/*.sh

sed -i "s/\('RASPI_WIREGUARD_ENABLED', \)false/\1true/g" /var/www/html/includes/config.php
systemctl enable wg-quick@wg

mkdir -p /etc/raspap/adblock
wget https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt -O /tmp/hostnames.txt
wget https://raw.githubusercontent.com/notracking/hosts-blocklists/master/domains.txt -O /tmp/domains.txt
cp /tmp/hostnames.txt /etc/raspap/adblock
cp /tmp/domains.txt /etc/raspap/adblock 
cp installers/update_blocklist.sh /etc/raspap/adblock/
chown -c root:www-data /etc/raspap/adblock/*.*
chmod 750 /etc/raspap/adblock/*.sh
touch /etc/dnsmasq.d/090_adblock.conf
echo "conf-file=/etc/raspap/adblock/domains.txt" > /etc/dnsmasq.d/090_adblock.conf
echo "addn-hosts=/etc/raspap/adblock/hostnames.txt" > /etc/dnsmasq.d/090_adblock.conf
sed -i '/dhcp-option=6/d' /etc/dnsmasq.d/090_raspap.conf
sed -i "s/\('RASPI_ADBLOCK_ENABLED', \)false/\1true/g" includes/config.php

