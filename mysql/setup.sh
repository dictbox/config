#!/bin/bash
# using the mysql yum repository to install mysql server on centos7x64
# author: wanlei
# date: 2015.03.22

# set mysql setup constants
MYSQL_REPO_NAME=mysql-community-release-el7-5.noarch.rpm
MYSQL_REPO_URL="http://dev.mysql.com/get/$MYSQL_REPO_NAME"

#MYSQL_CONF=my.cnf
#MYSQL_PASSWORD=123456

#print message before executing action.
print_hello(){
	echo "==========================================="
	echo "$1 mysql for CentOS 7 X64"
	echo "==========================================="
}

#print usage message
print_help() {
	echo "Usage: "
	echo "  $0 check --- check environment"
	echo "  $0 install --- check & run scripts to install"
}

#this script must be run as root.
check_is_root() {
	if [ $(id -u) != "0" ]; then
    	echo "Error: This script must be run as root."
    	exit 1
	fi
}

#this script must be run under centos7.0
check_is_centos(){
    OS_VERSION=$(less /etc/redhat-release)
    OS_BIT=$(getconf LONG_BIT)
    if [[ $OS_VERSION =~ "CentOS" ]] && [[ $OS_VERSION =~ "7" ]] && [[ $OS_BIT == 64 ]]; then
        return 0
    else
        echo "Error: This script must be run under the CentOS 7.x 64bit."
        exit 1
    fi
}

#check mysqld whether is running.
check_mysql_run() {
	ps -ef | grep -v 'grep' | grep mysqld
	if [ $? -eq 0 ]; then
		echo "Error: mysql is running."
		exit 1
	fi
}

#add mysql official repository.
add_mysql_reop() {
	 wget $MYSQL_REPO_URL
	 if [ $? -eq 0 ]; then
		if [ -f $MYSQL_REPO_NAME ]; then
			rpm -Uvh $MYSQL_REPO_NAME
		fi
	else
		echo "Error: download mysql repository install file failed."
		exit 1
	fi
}

#check yum status
clean_yum() {
	YUM_PID=/var/run/yum.pid
	if [ -f "$YUM_PID" ]; then
		set -x
		rm -f YUM_PID
		killall yum
		set +x
	fi
}

#install mysql server
install_mysql() {
	clean_yum
	yum -y install mysql-community-server mysql-community-devel 
	if [ $? -eq 0 ]; then
		echo "yum install mysql successed."
	else
		echo "Error: yum install mysql failed."
		exit 1;
	fi
}

#start mysql server
run_mysql() {
	PROCESS=$(pgrep mysql)
	if [ -z "$PROCESS" ]; then 
		echo "no mysql is running..." 
		systemctl start mysqld.service	
		if [ $? -eq 0 ]; then
			echo "start mysql successed."
		else
			echo "Error: start mysql failed."
			exit 1
		fi
	else 
		echo "Warning: mysql is running"
	fi
}	

install_run_mysql() {
	add_mysql_reop
	install_mysql
	run_mysql
	mysql_secure_installation
	if [ $? -eq 0 ]; then
		echo "init & set mysql root password successed."
	else
		echo "Error: init & set mysql root password failed."
		exit 1
	fi
}

case $1 in
	check)
		print_hello $1
		check_is_root
		check_is_centos
		check_mysql_run
		if [ $? -eq 0 ]; then
			echo "ready to install mysql server."
		fi
		;;
	install)
		print_hello $1
		check_is_root
		check_is_centos
		check_mysql_run
		install_run_mysql
		;;
	*)
		print_help
		;;
esac


