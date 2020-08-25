source ./common.sh

if [[ ! -f bigdata.repo ]]
then
    echo "Download repofile for $(hostname)"
    wget --quiet "http://$REPO_IP/bigdata/repofile/bigdata.repo"
fi

download_tar(){
    if [[ ! -f $1 ]]
    then
        echo "Download $1 for $(hostname)"
        wget --quiet "http://$REPO_IP/bigdata/bigdata_tar/$1"
    fi
}

download_tar $JAVA_TAR
download_tar $ZK_TAR
download_tar $HADOOP_TAR
download_tar $HBASE_TAR
download_tar $SCALA_TAR
download_tar $SPARK_TAR
download_tar $HIVE_TAR
download_tar $MYSQL_CONN_JAR
