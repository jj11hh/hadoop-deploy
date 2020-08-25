source ./common.sh

mkdir -p /usr/java
tar -xzf $JAVA_TAR -C /usr/java

rm -f /etc/profile.d/jdk.sh

sed -i.origin -f - /etc/profile <<"EOF"
/^# will prevent/a\
# JAVA\
export JAVA_HOME=/usr/java/jdk1.8.0_171\
export CLASSPATH=$JAVA_HOME/lib/\
export PATH=$PATH:$JAVA_HOME/bin\
# END JAVA
EOF

source /etc/profile

java -version
