#!/bin/sh



#sed -i.origin -f - /etc/ntp.conf <<"EOF"
#/# Hosts on local network are less restricted./a\
#restrict 192.168.56.0 mask 255.255.255.0 nomodify notrap
#EOF

sed -i.origin -f - /etc/ntp.conf <<"EOF"
/server 3.centos.pool.ntp.org iburst/a\
server 127.127.1.0\
fudge 127.127.1.0 stratum 10
EOF

systemctl restart ntpd
systemctl enable ntpd
