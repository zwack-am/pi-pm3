#!/bin/bash -e

cat << EOF >> /etc/dhcpcd.conf

inteface wlan0
static ip_address=192.168.23.1/24

EOF

mv /etc/dnsmasq.conf /etc/dnsmasq.orig

cat << EOF > /etc/dnsmasq.conf
interface=wlan0
  dhcp-range=192.168.23.17,192.168.23.42,255.255.255.0,24h
EOF

cat << EOF > /etc/hostapd/hostapd.conf
interface=wlan0
country_code=US
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ssid=PM3
wpa_passphrase=DangerousThings
EOF

sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd

