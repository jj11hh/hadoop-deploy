source ./common.sh


mkdir -p /usr/zookeeper

tar -xzf $ZK_TAR -C /usr/zookeeper

mkdir -p /usr/zookeeper/zookeeper-3.4.10/zkdata
mkdir -p /usr/zookeeper/zookeeper-3.4.10/zkdatalog

cp $ZK_DIR/conf/zoo_sample.cfg $ZK_DIR/conf/zoo.cfg

sed -e '/^tickTime/ s/^#*/#/' -i $ZK_DIR/conf/zoo.cfg
sed -e '/^initLimit/ s/^#*/#/' -i $ZK_DIR/conf/zoo.cfg
sed -e '/^syncLimit/ s/^#*/#/' -i $ZK_DIR/conf/zoo.cfg
sed -e '/^dataDir/ s/^#*/#/' -i $ZK_DIR/conf/zoo.cfg
sed -e '/^clientPort/ s/^#*/#/' -i $ZK_DIR/conf/zoo.cfg
sed -e '/^dataLogDir/ s/^#*/#/' -i $ZK_DIR/conf/zoo.cfg
sed -e '/^server./ s/^#*/#/' -i $ZK_DIR/conf/zoo.cfg

cat <<"EOF" >> $ZK_DIR/conf/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/usr/zookeeper/zookeeper-3.4.10/zkdata
clientPort=2181
dataLogDir=/usr/zookeeper/zookeeper-3.4.10/zkdatalog
server.1=master:2888:3888
server.2=slave1:2888:3888
server.3=slave2:2888:3888
EOF

sed -i.origin -f - /etc/profile <<"EOF"
/^# END JAVA/a\
# ZOOKEEPER\
export ZOOKEEPER_HOME=/usr/zookeeper/zookeeper-3.4.10\
PATH=$PATH:$ZOOKEEPER_HOME/bin\
# END ZOOKEEPER
EOF

#source /etc/profile
#pushd $ZK_DIR
#bin/zkServer.sh start
#bin/zkServer.sh status
#popd
