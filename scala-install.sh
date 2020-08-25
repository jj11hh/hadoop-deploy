#!/bin/sh

source ./common.sh

mkdir -p /usr/scala
tar -xzf $SCALA_TAR -C /usr/scala

sed -i -f - /etc/profile <<"EOF"
/^# END JAVA/a\
# SCALA\
export SCALA_HOME=/usr/scala/scala-2.11.12\
export PATH=$SCALA_HOME/bin:$PATH\
# END SCALA
EOF

