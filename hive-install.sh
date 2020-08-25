#!/bin/sh

source ./common.sh

mkdir -p /usr/hive
tar -xzf apache-hive-2.1.1-bin.tar.gz -C /usr/hive/

sed -i -f - /etc/profile <<"EOF"
/^# END HBASE/a\
# HIVE\
export HIVE_HOME=/usr/hive/apache-hive-2.1.1-bin\
export PATH=$HIVE_HOME/bin:$PATH\
# END HIVE
EOF

source /etc/profile

pushd $HIVE_HOME/conf
sed -f - hive-env.sh.template <<"EOF" > hive-env.sh
s/^# HADOOP_HOME.*/HADOOP_HOME=\/usr\/hadoop\/hadoop-2.7.3/
s/^# export HIVE_CONF_DIR.*/export HIVE_CONF_DIR=\/usr\/hive\/apache-hive-2.1.1-bin\/conf/
EOF
popd

if [[ $(hostname) = "master" ]]
then
    cp $HIVE_HOME/lib/jline-2.12.jar $HADOOP_HOME/share/hadoop/yarn/lib/
    pushd $HIVE_HOME/conf
    cat <<"EOF" > hive-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive_remote/warehouse</value>
    </property>
    <property>
        <name>hive.metastore.local</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://slave1:9083</value>
    </property>
</configuration>
EOF

    popd
fi

if [[ $(hostname) = "slave1" ]]
then
    cp ./$MYSQL_CONN_JAR $HIVE_HOME/lib/
    pushd $HIVE_HOME/conf
    #cp hive-env.sh.template hive-env.sh

    cat <<"EOF" > hive-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive_remote/warehouse</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://slave2:3306/hive?createDatabaseIfNotExist=true&amp;useSSL=false</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.jdbc.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>123456</value>
    </property>
    <property>
        <name>hive.metastore.schema.verification</name>
        <value>false</value>
    </property>
    <property>
        <name>datanucleus.schema.autoCreateAll</name>
        <value>true</value>
    </property>
</configuration>
EOF
    popd
fi
