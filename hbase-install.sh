#!/bin/sh

source ./common.sh

mkdir -p /usr/hbase
tar -xzf $HBASE_TAR -C /usr/hbase

sed -i -f - /etc/profile <<"EOF"
/^# END HADOOP/a\
# HBASE\
export HBASE_HOME=/usr/hbase/hbase-1.2.4\
export PATH=$PATH:$HBASE_HOME/bin\
# END HBASE
EOF

source /etc/profile

sed -i -f - $HBASE_HOME/conf/hbase-env.sh <<"EOF"
/^# Set environment/a\
export HBASE_MANAGES_ZK=false
EOF

sed -i -f - $HBASE_HOME/conf/hbase-env.sh <<"EOF"
/^# export JAVA_HOME/a\
export JAVA_HOME=/usr/java/jdk1.8.0_171\
export HBASE_CLASSPATH=/usr/hadoop/hadoop-2.7.3/etc/hadoop
EOF

sed -i -f - $HBASE_HOME/conf/hbase-site.xml <<"EOF"
/^<configuration>/a\
<property>\
    <name>hbase.rootdir</name>\
    <value>hdfs://master:9000/hbase</value>\
</property>\
<property>\
    <name>hbase.cluster.distributed</name>\
    <value>true</value>\
</property>\
<property>\
    <name>hbase.master</name>\
    <value>hdfs://master:6000</value>\
</property>\
<property>\
    <name>hbase.zookeeper.quorum</name>\
    <value>master,slave1,slave2</value>\
</property>\
<property>\
    <name>hbase.zookeeper.property.dataDir</name>\
    <value>/usr/zookeeper/zookeeper-3.4.10</value>\
</property>
EOF

echo -e "slave1\nslave2" > $HBASE_HOME/conf/regionservers

cp $HADOOP_HOME/etc/hadoop/hdfs-site.xml $HBASE_HOME/conf/
cp $HADOOP_HOME/etc/hadoop/core-site.xml $HBASE_HOME/conf/

