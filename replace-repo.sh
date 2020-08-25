source ./common.sh

pkill -9 yum
rm -rf /etc/yum.repos.d/*
cp bigdata.repo /etc/yum.repos.d/
yum clean all
