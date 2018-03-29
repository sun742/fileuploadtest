#!/bin/bash

useradd -m sunzs
echo "5tgb^YHN" | passwd --stdin sunzs
useradd -m tongwf
echo "5tgb^YHN" | passwd --stdin tongwf
useradd -m zhangj
echo "5tgb^YHN" | passwd --stdin zhangj

passwd -l dbus
passwd -l vcsa
passwd -l games
#passwd -l nobody
passwd -l haldaemon
passwd -l gopher
passwd -l ftp
passwd -l mail
passwd -l shutdown
passwd -l halt
passwd -l uucp
passwd -l operator
passwd -l sync
passwd -l adm
passwd -l lp


#sed -i "s/PASS_MAX_DAYS	99999/PASS_MAX_DAYS	90/" /etc/login.defs
sed -i "s/PASS_MIN_LEN	5/PASS_MIN_LEN	8/" /etc/login.defs
echo "set password complexadj is done !"
  
echo "auth            required        pam_wheel.so use_uid" >> /etc/pam.d/su
echo "SU_WHEEL_ONLY yes" >> /etc/login.defs
usermod -G10 sunzs
usermod -G10 tongwf
usermod -G10 zhangj
echo "Add su accout is done ! "

cat << EOF >> /etc/sudoers
sunzs   ALL=(ALL)       ALL
tongwf  ALL=(ALL)       ALL
EOF
echo "Add sudo accout is done ! "

#sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
#echo "root can not remote is done !"

#echo "TMOUT=600" >>/etc/profile
#echo "auth        required      pam_tally.so onerr=fail deny=6 unlock_time=300" >>/etc/pam.d/system-auth
#echo "system timeout 10 minite auto logout is done !"


sed -i "s/HISTSIZE=1000/HISTSIZE=20/" /etc/profile
echo "history command list to 20 is done !"
 
 
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf
 

 
sed -i "s/#MaxAuthTries 6/MaxAuthTries 6/" /etc/ssh/sshd_config
sed -i  "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config
sed -i  "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/" /etc/ssh/ssh_config
service sshd restart 2>&1>/dev/null
sed -i "s/exec/\#exec/" /etc/init/control-alt-delete.conf

cat >> /etc/bashrc << EOF

export HISTTIMEFORMAT="%Y-%m-%d-%H:%M:%S "
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\\$ '
LS_COLORS='di=36:fi=0:ln=31:pi=5:so=5:bd=5:cd=5:or=31:mi=0:ex=35:*.rpm=90'
EOF  

cat << EOF >> /etc/profile
history
USER_IP=\`who -u am i 2>/dev/null| awk '{print \$NF}'|sed -e 's/[()]//g'\`
if [ "\$USER_IP" = "" ]
then
USER_IP=\`hostname\`
fi
if [ ! -d /var/log/history ]
then
mkdir /var/log/history
chmod 777 /var/log/history
fi
if [ ! -d /var/log/history/\${LOGNAME} ]
then
mkdir /var/log/history/\${LOGNAME}
chmod 300 /var/log/history/\${LOGNAME}
fi
export HISTSIZE=4096
DT=\`date +"%Y%m%d_%H%M%S"\`
export HISTFILE="/var/log/history/\${LOGNAME}/\${USER_IP}.history.\$DT"
chmod 600 /var/log/history/\${LOGNAME}/*history* 2>/dev/null  
EOF

source /etc/profile
echo "The user operation information record is done !"


sed -i "s/rotate 4/rotate 10/" /etc/logrotate.conf  
cp -p /etc/logrotate.d/syslog /etc/logrotate.d/syslog.bak

cat << EOF > /etc/logrotate.d/syslog
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    size 1000k
    rotate 10
    compress
    sharedscripts
    postrotate
        /bin/kill -HUP \`cat /var/run/syslogd.pid 2> /dev/null\` 2> /dev/null || true
    endscript
}
EOF
echo "Log record is done !"


chmod 700 /bin/ping
chmod 700 /usr/bin/who
chmod 700 /usr/bin/w
chmod 700 /usr/bin/whereis
chmod 700 /sbin/ifconfig
chmod 700 /bin/vi
chmod 700 /usr/bin/which
chmod 700 /usr/bin/gcc
chmod 700 /usr/bin/make
chmod 700 /bin/rpm
echo "limit chmod important commands is is done !"


chattr +a /root/.bash_history
chattr +i /root/.bash_history

sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/sysconfig/selinux
sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config
/usr/sbin/setenforce 0
echo "disable SElinux is is done !"

echo 'ulimit -n 999999' >> /etc/profile

#chattr +i /etc/passwd
#chattr +i /etc/shadow
#chattr +i /etc/group
#chattr +i /etc/gshadow

echo "nameserver 172.16.11.25" > /etc/resolv.conf

modprobe bridge
echo "modprobe bridge">> /etc/rc.local
modprobe nf_conntrack
echo "modprobe nf_conntrack">> /etc/rc.local
cat << EOF >> /etc/sysctl.conf
net.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF
/sbin/sysctl -p
