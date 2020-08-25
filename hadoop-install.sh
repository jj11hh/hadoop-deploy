#!/bin/sh

source ./common.sh

mkdir -p /usr/hadoop
tar -xzf $HADOOP_TAR -C /usr/hadoop/

sed -i.origin -f - /etc/profile <<"EOF"
/^# END ZOOKEEPER/a\
# HADOOP\
export HADOOP_HOME=/usr/hadoop/hadoop-2.7.3\
export CLASSPATH=$CLASSPATH:HADOOP_HOME/lib\
export PATH=$PATH:$HADOOP_HOME/bin\
# END HADOOP
EOF

source /etc/profile

sed -i.origin -f - $HADOOP_HOME/etc/hadoop/hadoop-env.sh <<"EOF"
/^# The java/a\
export JAVA_HOME=/usr/java/jdk1.8.0_171
EOF

sed -i.origin -f - $HADOOP_HOME/etc/hadoop/core-site.xml <<"EOF"
/^<configuration>/a\
 <property>\
  <name>fs.default.name</name>\
  <value>hdfs://master:9000</value>\
 </property>\
 <property>\
  <name>hadoop.tmp.dir</name>\
  <value>/usr/hadoop/hadoop-2.7.3/hdfs/tmp</value>\
  <description>A base for other temporary directories.</description>\
 </property>\
 <property>\
  <name>io.file.buffer.size</name>\
  <value>131072</value>\
 </property>\
 <property>\
  <name>fs.checkpoint.period</name>\
  <value>60</value>\
 </property>\
 <property>\
  <name>fs.checkpoint.size</name>\
  <value>67108864</value>\
 </property>
EOF

cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template\
   $HADOOP_HOME/etc/hadoop/mapred-site.xml

sed -i.origin -f - $HADOOP_HOME/etc/hadoop/mapred-site.xml <<"EOF"
/^<configuration>/a\
 <property>\
  <name>mapreduce.framework.name</name>\
  <value>yarn</value>\
 </property>
EOF

sed -i.origin -f - $HADOOP_HOME/etc/hadoop/yarn-site.xml <<"EOF"
/^<configuration>/a\
<property>\
    <name>yarn.resourcemanager.address</name>\
    <value>master:18040</value>\
</property>\
<property>\
    <name>yarn.resourcemanager.scheduler.address</name>\
    <value>master:18030</value>\
</property>\
<property>\
    <name>yarn.resourcemanager.webapp.address</name>\
    <value>master:18088</value>\
</property>\
<property>\
    <name>yarn.resourcemanager.resource-tracker.address</name>\
    <value>master:18025</value>\
</property>\
<property>\
    <name>yarn.resourcemanager.admin.address</name>\
    <value>master:18141</value>\
</property>\
<property>\
    <name>yarn.nodemanager.aux-services</name>\
    <value>mapreduce_shuffle</value>\
</property>\
<property>\
    <name>yarn.nodemanager.auxservices.mapreduce.shuffle.class</name>\
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>\
</property>
EOF

sed -i.origin -f - $HADOOP_HOME/etc/hadoop/hdfs-site.xml <<"EOF"
/^<configuration>/a\
<property>\
    <name>dfs.replication</name>\
    <value>2</value>\
</property>\
<property>\
    <name>dfs.namenode.name.dir</name>\
    <value>file:/usr/hadoop/hadoop-2.7.3/hdfs/name</value>\
    <final>true</final>\
</property>\
<property>\
    <name>dfs.datanode.data.dir</name>\
    <value>file:/usr/hadoop/hadoop-2.7.3/hdfs/data</value>\
    <final>true</final>\
</property>\
<property>\
    <name>dfs.namenode.secondary.http-address</name>\
    <value>master:9001</value>\
</property>\
<property>\
    <name>dfs.webhdfs.enabled</name>\
    <value>true</value>\
</property>\
<property>\
    <name>dfs.permissions</name>\
    <value>false</value>\
</property>


EOF

echo "master" > $HADOOP_HOME/etc/hadoop/master
echo -e "slave1\nslave2" > $HADOOP_HOME/etc/hadoop/slaves
