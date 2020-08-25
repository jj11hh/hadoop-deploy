MYSQL_COMMON="https://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/mysql-community-common-5.7.30-1.el7.x86_64.rpm"
MYSQL_CLIENT="https://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/mysql-community-client-5.7.30-1.el7.x86_64.rpm"
MYSQL_LIBS="https://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/mysql-community-libs-5.7.30-1.el7.x86_64.rpm"
MYSQL_SERVER="https://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/mysql-community-server-5.7.30-1.el7.x86_64.rpm"

wget -nc $MYSQL_COMMON
wget -nc $MYSQL_CLIENT
wget -nc $MYSQL_LIBS
wget -nc $MYSQL_SERVER

yum -y remove mariadb-libs
