#!/bin/sh

source ./common.sh

echo $MASTER_PASSWD > master.pass
echo $SLAVE1_PASSWD > slave1.pass
echo $SLAVE2_PASSWD > slave2.pass

mkdir $HOME/.ssh

ssh-keyscan -H master >> $HOME/.ssh/known_hosts
ssh-keyscan -H slave1 >> $HOME/.ssh/known_hosts
ssh-keyscan -H slave2 >> $HOME/.ssh/known_hosts

ssh-keygen -t dsa -N '' -f ./id_dsa_master
ssh-keygen -t dsa -N '' -f ./id_dsa_slave1
ssh-keygen -t dsa -N '' -f ./id_dsa_slave2

cp ./id_dsa_master $HOME/.ssh/id_dsa
cp ./id_dsa_master.pub $HOME/.ssh/id_dsa.pub

sshpass -f master.pass ssh-copy-id root@master
sshpass -f slave1.pass ssh-copy-id root@slave1
sshpass -f slave2.pass ssh-copy-id root@slave2

cat ./id_dsa_master.pub ./id_dsa_slave1.pub ./id_dsa_slave2.pub > $HOME/.ssh/authorized_keys

sshpass -f slave1.pass scp $HOME/.ssh/authorized_keys root@slave1:/root/.ssh/
sshpass -f slave2.pass scp $HOME/.ssh/authorized_keys root@slave2:/root/.ssh/

scp ./id_dsa_slave1 root@slave1:/root/.ssh/id_dsa
scp ./id_dsa_slave2 root@slave2:/root/.ssh/id_dsa

scp ./id_dsa_slave1.pub root@slave1:/root/.ssh/id_dsa.pub
scp ./id_dsa_slave2.pub root@slave2:/root/.ssh/id_dsa.pub

scp $HOME/.ssh/known_hosts root@slave1:/root/.ssh/
scp $HOME/.ssh/known_hosts root@slave2:/root/.ssh/

