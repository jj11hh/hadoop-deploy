#!/bin/sh

echo "checking whether $1 is installed"
rpm -qa | grep -qw $1 || yum install -y $1

