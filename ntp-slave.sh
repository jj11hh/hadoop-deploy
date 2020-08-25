#!/bin/sh

#sed -e '/^server / s/^#*/#/' -i /etc/ntp.conf # comment out all server
#
#sed -i.origin -f - /etc/ntp.conf <<EOF
#/server 3.centos.pool.ntp.org iburst/a\\
#server master
#EOF

ntpdate master
