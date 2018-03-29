#!/bin/bash

source "/etc/profile"

APP_NAME=`echo $1 | awk -F ',' '{print $1}'`
PRO_ENV=`echo $1 | awk -F ',' '{print $2}'`
GCLOGPATH="logs/gc.log"
CLASS_PATH="lib/*:conf"

if [ -z "$APP_NAME" -o -z "$PRO_ENV" ];then
  echo "APP_NAME OR PRO_ENV ERROR"
  exit 1
fi

if [ ! -d "/usr/local/$APP_NAME" ];then
   echo "not find app env"
   exit 0
fi

if [ ! -d "/usr/local/$APP_NAME/default" ];then
  exit 0
fi

if [ -f "/usr/local/$APP_NAME/default/bin/ymt_env" ];then
   grep "=" /usr/local/$APP_NAME/default/bin/ymt_env |grep -v '`' > /usr/local/log/$APP_NAME/ymt_env
   source "/usr/local/log/$APP_NAME/ymt_env"
fi

if [ -n "$MAIN_CLASS" ];then
   #############intial work##########################
        ps aux | grep java |grep ${MAIN_CLASS} | grep -v grep | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1
        ps aux | grep ${MAIN_CLASS} | grep -v grep > /dev/null 2>&1
        if [ $? -ne 0 ]; then
                exit 0
        else
                exit 1
        fi
else
  echo "MAIN_CLASS ARG ERROR."
  exit 1
fi
