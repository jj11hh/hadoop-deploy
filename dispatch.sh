#!/bin/sh

source ./common.sh

scp ../deploy-usth.tar.gz root@slave1:/root/ &
scp ../deploy-usth.tar.gz root@slave2:/root/ &
wait $(jobs -p)

ssh slave1 'cd $HOME; tar xzf deploy-usth.tar.gz' &
ssh slave2 'cd $HOME; tar xzf deploy-usth.tar.gz' &
wait $(jobs -p)
