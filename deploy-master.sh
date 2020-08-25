#!/bin/bash

source ./common.sh

# functions pre-defined
slave () {
    ssh slave1 "cd \$HOME/deploy-usth/; $1"
    ssh slave2 "cd \$HOME/deploy-usth/; $1"
}

async_slave () {
    ssh slave1 "cd \$HOME/deploy-usth/; $1" &
    ssh slave2 "cd \$HOME/deploy-usth/; $1" &
    wait $(jobs -p)
}

all () {
    bash -c "cd \$HOME/deploy-usth/; $1"
    ssh slave1 "cd \$HOME/deploy-usth/; $1"
    ssh slave2 "cd \$HOME/deploy-usth/; $1"
}

async_all () {
    bash -c "cd \$HOME/deploy-usth/; $1" &
    ssh slave1 "cd \$HOME/deploy-usth/; $1" &
    ssh slave2 "cd \$HOME/deploy-usth/; $1" &
    wait $(jobs -p)
}

# routines

bootstrap()
{
    sh ./set-hostname.sh master
    sh ./download.sh
    sh ./replace-repo.sh
    sh ./firewalld.sh
    sh ./hosts.sh

    sh ./init.sh # install needed packages and do keyscan
    sh ./ssh-gen.sh #generate keys and dispatch

# Dispatch Scripts

    sh ./dispatch.sh

# Set Hostname for Slaves

    ssh slave1 'hostnamectl set-hostname slave1'
    ssh slave2 'hostnamectl set-hostname slave2'
}

# Initialize Slaves

init_slaves(){
    scp ./bigdata.repo root@slave1:/root/deploy-usth/
    scp ./bigdata.repo root@slave2:/root/deploy-usth/

    async_slave 'sh replace-repo.sh'
    async_slave 'sh init.sh'
    async_slave 'sh download.sh'
    async_slave 'sh firewalld.sh'
    slave 'sh hosts.sh'
}



# Set NTP

setup_ntp(){

# Set Time Zone
    echo "Setting time zone"
    async_all "sh ./tz.sh" > /dev/null 2>&1

    echo "Setting NTP Server"
    sh ./ntp-master.sh

    sleep 3 # wait for NTP server start up

    async_slave 'echo $(hostname): ; sh ntp-slave.sh'
}

setup_java(){
# Install Java
    echo "Installing Java"
    async_all "sh ./java-install.sh"
}

setup_zk(){
# Install ZooKeeper
    echo "Installing ZooKeeper"
    async_all "sh ./zk-install.sh"

    sh ./zk-setid.sh 1
    ssh slave1 'cd $HOME/deploy-usth; sh ./zk-setid.sh 2'
    ssh slave2 'cd $HOME/deploy-usth; sh ./zk-setid.sh 3'

    async_all 'source /etc/profile; zkServer.sh start'

    sleep 3
    all 'source /etc/profile; zkServer.sh status'
}

setup_hadoop(){
# Install Hadoop
    echo "Installing Hadoop"
    async_all 'sh ./hadoop-install.sh'

    source /etc/profile

    echo "Formatting namenode"
    hadoop namenode -format

    /usr/hadoop/hadoop-2.7.3/sbin/start-all.sh

    all 'source /etc/profile; jps'
}

# Install HBase
setup_hbase(){

    echo "Installing HBase"

    async_all 'sh ./hbase-install.sh'

    source /etc/profile
    start-hbase.sh
    jps
}

# Install MySQL
setup_mysql(){
    echo "Installing MySQL on slave2"
    ssh slave2 'cd $HOME/deploy-usth; sh ./mysql-install.sh'
}

# Install MySQL from USTC
setup_mysql_ustc(){
    echo "Installing MySQL on slave2"
    ssh slave2 'cd $HOME/deploy-usth; sh ./mysql-download.sh'
    ssh slave2 'cd $HOME/deploy-usth; sh ./mysql-install-local.sh'
}

setup_hive(){
# Install Hive

    echo "Installing Hive"

    sh ./hive-install.sh
    source /etc/profile

    ssh slave1 'cd $HOME/deploy-usth; sh ./hive-install.sh'
    ssh slave1 'source /etc/profile; nohup hive --service metastore >> /root/hive.log 2>&1 &'

    echo "Wait 20 seconds for Hive Metastore"
    sleep 20;

    hive -e "show databases; create database hive_db; show databases;"
    #hive -e "create database hive_db"

    jps
}

setup_scala(){
# Install Scala
    echo "Installing Scala"
    async_all 'sh ./scala-install.sh'
    all 'source /etc/profile; scala -version'
}

setup_spark(){
# Install Spark
    echo "Installing Spark"
    async_all 'sh ./spark-install.sh'

    source /etc/profile
    $SPARK_HOME/sbin/start-all.sh
}

echo "Choose a task to run"


while true; do
    PS3="Enter a number: "
    select task in "BootStrap" "InitSlaves" "SetupNTP"\
        "SetupJava" "SetupZK" "SetupHadoop" "SetupHBase" "SetupMySQL"\
        "SetupMySQLFromUSTC" "SetupHive" "SetupScala" "SetupSpark"\
        "All"
    do
        
        case $task in
        BootStrap)
            bootstrap
            break
            ;;
        InitSlaves)
            init_slaves
            break
            ;;
        SetupNTP)
            setup_ntp
            break
            ;;
        SetupJava)
            setup_java
            break
            ;;
        SetupZK)
            setup_zk
            break
            ;;
        SetupHadoop)
            setup_hadoop
            break
            ;;
        SetupHBase)
            setup_hbase
            break
            ;;
        SetupMySQL)
            setup_mysql
            break
            ;;
        SetupMySQLFromUSTC)
            setup_mysql_ustc
            break
            ;;
        SetupHive)
            setup_hive
            break
            ;;
        SetupScala)
            setup_scala
            break
            ;;
        SetupSpark)
            setup_spark
            break
            ;;
        All)
            bootstrap
            init_slaves
            setup_ntp
            setup_java
            setup_zk
            setup_hadoop
            setup_hbase
            setup_mysql
            setup_hive
            setup_scala
            setup_spark
            break
            ;;
        *)
            echo "ERROR: Invalid Selection"
            break
            ;;
        esac
    done
done


# End of File
