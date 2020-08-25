#!/bin/sh

source ./common.sh

mkdir -p /usr/spark
tar -xzf $SPARK_TAR -C /usr/spark


sed -i -f - /etc/profile <<"EOF"
/^# END SCALA/a\
# SPARK\
export SPARK_HOME=/usr/spark/spark-2.4.0-bin-hadoop2.7\
export PATH=$SPARK_HOME/bin:$PATH\
# END SPARK
EOF

pushd /usr/spark/spark-2.4.0-bin-hadoop2.7/conf
cp spark-env.sh.template spark-env.sh
cat <<EOF >> spark-env.sh
export SPARK_MASTER_IP=master
export SCALA_HOME=/usr/scala/scala-2.11.12
export SPARK_WORKER_MEMORY=8g
export JAVA_HOME=/usr/java/jdk1.8.0_171
export HADOOP_HOME=/usr/hadoop/hadoop-2.7.3
export HADOOP_CONF_DIR=/usr/hadoop/hadoop-2.7.3/etc/hadoop
EOF

echo -e "slave1\nslave2" > slaves
popd

