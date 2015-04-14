#! /bin/bash
# this is a setup scripts for redis
# author: wanlei http://wanlei.net open@wanlei.net
# date: 2015.04.10

#set redis setup constants
REDIS_VER=redis-3.0.0
REDIS_OFFICIAL_URL=http://download.redis.io/releases/$REDIS_VER.tar.gz
REDIS_CONF_PATH=/etc/redis
REDIS_CONF=redis.conf
REDIS_WORK_PATH=/opt/redis
REDIS_SERVER_PATH=/usr/local/bin
REDIS_SERVER=redis-server
REDIS_INIT_SCRIPT=redis

#print message before executing action.
print_hello(){
    echo "================================================="
    echo " $1 $REDIS_VER"
    echo "================================================="
}

#print usage message
print_help(){
    echo "Usage:"
    echo "  $0 check --- check environment"
    echo "  $0 install ---check & run scripts to install $REDIS_VER server."
}

#this script must be run as root.
check_is_root(){
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

#check redis server whether is running.j
check_redis_run(){
    ps -e |grep redis-server
    if [ $? -eq 0 ]; then
        echo "Error: redis server is running."
        exit 1
    fi
}

#try download the redis source package.
download_redis(){
    if [ -f "$1" ]; then
        echo "$1 existed."
    else
        echo "$1 not existed,begin to download..."
        wget $2
        if [ $? -eq 0 ]; then
            echo "download $1 successed."
        else
            echo "Error: download $1 failed."
            return 1
        fi
    fi
    return 0
}

#download, make and install redis.
install_redis(){
    download_redis $REDIS_VER.tar.gz $REDIS_OFFICIAL_URL
    if [ $? -eq 1 ]; then
        return 1
    fi
    
    tar xzf $REDIS_VER.tar.gz
    cd $REDIS_VER 
    
    cd deps
    make hiredis jemalloc linenoise lua
    if [ $? -ne 0 ]; then
        echo "Error: build deps package failed."
        return 1
    fi

    cd ..
    make
    if [ $? -eq 0 ]; then
        echo "make redis successed."
    else
        echo "Error: make redis failed."    
        return 1
    fi

    make install
    if [ $? -eq 0 ]; then
        echo "install redis server successed"
    else
        echo "Error: install redis server failed."
        return 1
    fi
    
    cd ..
    return 0
}

#start redis server.
run_redis(){
    PROCESS=$(pgrep redis)
    if [ -z "$PROCESS" ]; then
        echo "no redis is running."
    else
        echo "Warning: redis is running."
        return 0
    fi
   
    #cp redis conf to target path. 
    cd conf/
    if  [ -f "$REDIS_CONF" ]; then
        if [ ! -d "$REDIS_CONF_PATH" ]; then
            mkdir $REDIS_CONF_PATH
        fi
        
        if [ ! -d "$REDIS_WORK_PATH" ]; then
            mkdir $REDIS_WORK_PATH
        fi

        cp -f $REDIS_CONF $REDIS_CONF_PATH/
        cd ../ 
    else
        cd ../
        echo "Error: $REDIS_CONF not existed."
        return 1
    fi 
   
    #start redis server
    $REDIS_SERVER_PATH/$REDIS_SERVER $REDIS_CONF_PATH/$REDIS_CONF 
    if [ $? -eq 0 ]; then
        echo "start redis successed."
    else
        echo "Error: start redis failed."
        return 1
    fi
    
    return 0
}

#set automatically start redis on centos startup
set_redis_initscript(){
    cd conf/
    if [ -f "$REDIS_INIT_SCRIPT" ]; then
        cp -f $REDIS_INIT_SCRIPT /etc/init.d/
        if [ -f "/etc/init.d/$REDIS_INIT_SCRIPT" ]; then    
            chmod +x "/etc/init.d/$REDIS_INIT_SCRIPT"
            chkconfig --add $REDIS_INIT_SCRIPT
            chkconfig $REDIS_INIT_SCRIPT on
            CKREDIS=$(chkconfig --list|grep $REDIS_INIT_SCRIPT)
            if [[ $CKREDIS =~ $REDIS_INIT_SCRIPT ]]; then
                echo "setup redis init script successed."
                return 0
            else
                return 1
            fi
        fi
        
        cd ..
    fi
    
    return 1
}

#download、build & install redis server.
install_run_redis(){
    install_redis
    if [ $? -ne 0 ]; then
        exit 1
    fi

    run_redis
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    set_redis_initscript
    if [ $? -ne 0 ]; then
        exit 1
    fi
}

#start point
case $1 in	
    check)
        print_hello $1
        check_is_root
        check_redis_run
        if [ $? -eq 0 ]; then
            echo "ready to install redis."
        fi
        ;;
    install)
        print_hello $1
        check_is_root
        check_is_centos
        check_redis_run
        install_run_redis
        ;;
    *)
        print_help
        ;;
esac
