echo -e "5\n9\n1\n1" | tzselect 2>&1 /dev/null
export TZ="Asia/Shanghai"
#echo 'export TZ="Asia/Shanghai"' > ~/.profile
timedatectl set-timezone Asia/Shanghai 
