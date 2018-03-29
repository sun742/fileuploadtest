#!/bin/bash
hostname="`ifconfig |grep 10.|grep "inet addr:"|awk -F "  Bcast:" '{print $1}'|awk -F "inet addr:" '{print $2}'`"
zabbix_server=10.12.251.21
tcp_send_file="/tmp/tcp_send_file"
zabbix_conf="/etc/zabbix/zabbix_agentd.conf"
zabbix_send="/usr/bin/zabbix_sender"
service="netstat"

function get_status()
{
    ss -a |grep -v State|awk '
        BEGIN{
            a["SYN-SENT"]=0;
            a["LAST-ACK"]=0;
            a["SYN-RECV"]=0;
            a["ESTAB"]=0;
            a["FIN-WAIT-1"]=0;
            a["FIN-WAIT-2"]=0;
            a["TIME-WAIT"]=0;
            a["CLOSE-WAIT"]=0;
            a["LISTEN"]=0;
            a["CLOSE"]=0;
            a["CLOSING"]=0;
        }
        {
            a[$1]+=1
        }
        END{
            for (i in a){
                print hostname,prefix"_"i,a[i]
            }
        }' hostname=${hostname} prefix=${service} > ${tcp_send_file}
}
function send2zabbix()
{
    ${zabbix_send}  -z $zabbix_server -c ${zabbix_conf} -i ${tcp_send_file} |grep failed |awk  -F ';' '{print $2}' |awk -F : '{print $2}'
}
get_status
send2zabbix

