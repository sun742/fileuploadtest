#!/bin/bash

read -p "输入需要增加的域名: " domain
read -p "输入对应域名的IP: " IP

Columns=`echo $domain | awk -F . '{print NF}'`
Column1=$(($Columns-1))
Column2=$(($Columns-2))
Suffix=`echo $domain | cut -d . -f $Column1-`
DomainName=`echo $domain | cut -d . -f 1-$Column2`

ZoneDir=/var/named/
ZoneConf=$ZoneDir$Suffix.zone

if [[ -f $ZoneConf ]];then
	continue
else
	echo -e "can not find $ZoneConf,请检查输入的域名"
	exit 1
fi

CheckIPAddr()
{
    echo $1|grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" > /dev/null; 
    if [ $? -ne 0 ] 
    then 
        echo -e "请检查输入的ip是否合法 $IP"
        exit 1 
    fi 
    ipaddr=$1 
    a=`echo $ipaddr|awk -F . '{print $1}'` 
    b=`echo $ipaddr|awk -F . '{print $2}'` 
    c=`echo $ipaddr|awk -F . '{print $3}'` 
    d=`echo $ipaddr|awk -F . '{print $4}'` 
    for num in $a $b $c $d 
    do 
        if [ $num -gt 255 ] || [ $num -lt 0 ]
        then 
            echo -e "请检查输入的ip是否合法 $IP"
            exit 1
        fi 
    done 
    return 0 
} 

CheckIPAddr $IP

VerisonNo=`sed -n '3p' $ZoneConf`
NewVerisonNo=$(($VerisonNo+1))
MasterDns=10.11.251.115
SlaverDns=10.11.251.114

sed -i "s/$VerisonNo/$NewVerisonNo/" $ZoneConf

echo -e "$DomainName\tIN\tA\t$IP" >> $ZoneConf

/etc/init.d/named reload

sleep 1

echo  "在主DNS上验证"
sleep 1
echo -e "nslookup $domain $MasterDns"
nslookup $domain $MasterDns
sleep 1
echo -e "在备DNS上验证"
sleep 1
echo -e "nslookup $domain $SlaverDns"
nslookup $domain $SlaverDns
