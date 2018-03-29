#!/bin/bash
source /etc/profile
APP_NAME=`echo $1 | awk -F ',' '{print $1}'`
PRO_ENV=`echo $1 | awk -F ',' '{print $2}'`
GCLOGPATH="logs/gc.log"
CLASS_PATH="lib/*:conf"
#MAIN_CLASS="com.ymatou.search.ymtproduct.indexer.BgProductIndexer"
#MAIN_CLASS="python"
JAVA_OPTS="-server -Xms4096m -Xmx4096m -XX:MaxMetaspaceSize=512m -Xmn1500M -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled \
		-XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=75 \
			-XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark \
			-XX:+PrintGCDateStamps -verbose:gc -XX:+PrintGCDetails -Xloggc:/usr/local/log/$APP_NAME/gc.log \
			-XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M \
			-Dsun.net.inetaddr.ttl=60 \
			-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/local/log/$APP_NAME/heapdump.hprof"

if [ -z "$APP_NAME" -o -z "$PRO_ENV" ];then
  echo "APP_NAME OR PRO_ENV ERROR" 1>&2
  exit 1
fi

if [ ! -d "/usr/local/$APP_NAME" ];then
   mkdir -pv "/usr/local/$APP_NAME" > /dev/null
fi

if [ ! -d "/usr/local/log/$APP_NAME" ];then
   mkdir -pv "/usr/local/log/$APP_NAME" > /dev/null
fi

if [ ! -d "/usr/local/config/$APP_NAME" ];then
   mkdir -pv "/usr/local/config/$APP_NAME" > /dev/null
fi

if [ -f "/usr/local/$APP_NAME/default/bin/ymt_env" ];then
        grep "=" /usr/local/$APP_NAME/default/bin/ymt_env |grep -v '`' > /usr/local/log/$APP_NAME/ymt_env
        source "/usr/local/log/$APP_NAME/ymt_env"
fi

if [ ! -d "/usr/local/$APP_NAME" -o ! -d "/usr/local/log/$APP_NAME" -o ! -d "/usr/local/config/$APP_NAME" ];then
   echo "init path error" 1>&2
   exit 1
fi

if [ -n "$MAIN_CLASS" ];then
   #############intial work##########################
   cd /usr/local/${APP_NAME}/default
   if [ -e "logs" ]; then
       rm logs
   fi
   ln -s /usr/local/log/${APP_NAME}/ logs

   ##############launch the service##################
   if [ "$PRO_ENV" = 'stg' ];then
    nohup java ${JAVA_OPTS} -cp ${CLASS_PATH} ${MAIN_CLASS} stg >> ${GCLOGPATH} 2>&1 &
   else
    if [ -f "/usr/local/$APP_NAME/default/conf/disconf.properties" ];then
	sed -i "s/STG/PRD/g" /usr/local/$APP_NAME/default/conf/disconf.properties
    fi
    nohup java ${JAVA_OPTS} -cp ${CLASS_PATH} ${MAIN_CLASS} product >> ${GCLOGPATH} 2>&1 &
   fi
	sleep 2
   ##############check the service####################
   ps aux | grep ${MAIN_CLASS} | grep -v grep > /dev/null 2>&1
   if [ $? -eq 0 ]; then
       echo "deploy ok"
       sleep 12
       exit 0
   else
       echo "process start error" 1>&2
       exit 1
   fi
else
  echo "MAIN_CLASS ARG ERROR." 1>&2
  exit 1
fi
