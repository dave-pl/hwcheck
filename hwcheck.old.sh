#!/bin/bash
 
OSNAME=""
OSVER=""
OSVERNUM=""
OSNAME=`uname`
ARCH=`uname -m`
 
#---------/root/install----------
if  [ -d "/root/install" ]; then
        echo '/root/install already exist'
else
    mkdir /root/install
    echo '/root/install created'  
fi
#---------OS Linux-------------
if  [ "$OSNAME" == "Linux" ]; then
    echo $OSNAME
#------CentOS)---------------
    if  [ -r "/etc/redhat-release" ]; then
        OSVER=`cat /etc/redhat-release| cut -d " " -f 1`
        OSVERNUM=`egrep -o '[0-9]+\.[0-9]+' /etc/redhat-release`
        echo $OSVER $OSVERNUM
    else
        echo "This is not CentOS"
    fi
#--------Debian--------------------
    if  [ "$(cat /etc/issue.net|awk '{print $1}')" == "Debian" ]; then
        OSVER="debian"
        OSVERNUM=`cat /etc/debian_version`
        echo $OSVER $OSVERNUM
    else
        echo "This is not Debian"
    fi
#------Ubuntu-------------------------------
    if  [ "$(cat /etc/issue.net|awk '{print $1}')" == "Ubuntu" ]; then
        OSVER="Ubuntu"
        OSVERNUM=`cat /etc/issue.net|awk '{print $2,$3}'`
        echo $OSVER $OSVERNUM
    else
        echo "This is not Ubuntu"
    fi
fi
 
soft() {
    case $OSVER in
        CentOS )
        OSVERNUMTOP=`echo $OSVERNUM|cut -f1 -d"."`
            centos_install() {
                yum -y install epel-release
                yum -y install htop atop wget smartmontools nc vim pciutils dmidecode nano
                }
            case $OSVERNUMTOP in
                        6 )
                        centos_install
                        yum -y install memtester tar
                        if  [ -f /usr/*bin/cpuburn ]; then
                            echo 'cpuburn exist'
                        else
                            wget https://cdn.pmylund.com/files/tools/cpuburn/linux/cpuburn-1.0-amd64.tar.gz && tar -xvf cpuburn-1.0-amd64.tar.gz && mv cpuburn/cpuburn /usr/sbin/
                        fi
                        ;;
 
                        7 )
                        centos_install
                        if  [ -f /usr/*bin/cpuburn ]; then
                            echo 'cpuburn exist'
                        else
                            wget https://cdn.pmylund.com/files/tools/cpuburn/linux/cpuburn-1.0-amd64.tar.gz && tar -xvf cpuburn-1.0-amd64.tar.gz && mv cpuburn/cpuburn /usr/sbin/
                        fi
                        if  [ -f /usr/*bin/memtester ]; then
                            echo 'memtester exist'
                        else
                            yum -y install http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el7/en/x86_64/rpmforge/RPMS/memtester-4.2.0-1.el7.rf.x86_64.rpm
                        fi
                        ;;
             esac                       
             ;;
        debian )
        echo "debian soft install"
        OSVERNUMTOP=`echo $OSVERNUM|cut -f1 -d"."`
            debian_install() {
                apt-get update
                apt-get -y install smartmontools vim htop memtester ethtool pciutils dmidecode psmisc
                }             
            case $OSVERNUMTOP in
                        7 )
                        debian_install
                        if [ -f /usr/*bin/cpuburn ]; then
                            echo "cpuburn exist"
                        else
                            cd $PATH1
                            wget https://cdn.pmylund.com/files/tools/cpuburn/linux/cpuburn-1.0-amd64.tar.gz && tar -xvf cpuburn-1.0-amd64.tar.gz && mv cpuburn/cpuburn /usr/sbin/
                        fi
                        ;;
 
                        8 )
                        debian_install
                        if [ -f /usr/*bin/cpuburn ]; then
                            echo "cpuburn exist"
                        else
                            cd $PATH1
                            wget https://cdn.pmylund.com/files/tools/cpuburn/linux/cpuburn-1.0-amd64.tar.gz && tar -xvf cpuburn-1.0-amd64.tar.gz && mv cpuburn/cpuburn /usr/sbin/
                        fi
                        ;;
                         
                        9 )
                        debian_install
                        if [ -f /usr/*bin/cpuburn ]; then
                            echo "cpuburn exist"
                        else
                            cd $PATH1
                            wget https://cdn.pmylund.com/files/tools/cpuburn/linux/cpuburn-1.0-amd64.tar.gz && tar -xvf cpuburn-1.0-amd64.tar.gz && mv cpuburn/cpuburn /usr/sbin/
                        fi
                        ;;
            esac
            ;;
        Ubuntu )
        OSVERNUMTOP=`echo $OSVERNUM|cut -f1 -d"."`
            ubuntu_install() {
                apt-get update
                apt-get -y install smartmontools vim htop memtester ethtool pciutils dmidecode psmisc
                } 
            case $OSVERNUMTOP in
                        14 )
                        ubuntu_install
                        if [ -f /usr/*bin/cpuburn ]; then
                            echo "cpuburn exist"
                        else
                            cd $PATH1
                            wget https://cdn.pmylund.com/files/tools/cpuburn/linux/cpuburn-1.0-amd64.tar.gz && tar -xvf cpuburn-1.0-amd64.tar.gz && mv cpuburn/cpuburn /usr/sbin/
                        fi
                        ;;
 
                        16 )
                        ubuntu_install
                        if [ -f /usr/*bin/cpuburn ]; then
                            echo "cpuburn exist"
                        else
                            cd $PATH1
                            wget https://cdn.pmylund.com/files/tools/cpuburn/linux/cpuburn-1.0-amd64.tar.gz && tar -xvf cpuburn-1.0-amd64.tar.gz && mv cpuburn/cpuburn /usr/sbin/
                        fi
                        ;;
                         
                        *)
                        echo "I don't know this Ubuntu version but I don't care"
                        ubuntu_install
                        if [ -f /usr/*bin/cpuburn ]; then
                            echo "cpuburn exist"
                        else
                            cd $PATH1
                            wget https://cdn.pmylund.com/files/tools/cpuburn/linux/cpuburn-1.0-amd64.tar.gz && tar -xvf cpuburn-1.0-amd64.tar.gz && mv cpuburn/cpuburn /usr/sbin/
                        fi
                        ;;
            esac
            ;;
    esac
}
 
chkmemory() {
    case $OSVER in
        CentOS | debian | Ubuntu )
#-------------autostart_Memtester---------------------------------------------------------------------------------------------------------------------------------------------
            rm -rf /root/install/mem*.log
            let memtotal=$(grep -ri memtotal /proc/meminfo|awk '{print $2}')
            echo $memtotal
                if [[ $memtotal -lt 17000000 ]]; then
                    ram=16
                    echo $ram
                elif [[ $memtotal -ge 17000000 && $memtotal -lt 530000000 ]]; then
                    ram=16-512
#----------------------------------------------
                    if [[ $memtotal -ge 17000000 && $memtotal -lt 70000000 ]]; then
                        free=540
                        echo "free is $free"
                    elif [[ $memtotal -ge 70000000 && $memtotal -lt 135000000 ]]; then
                        free=800
                        echo "free is $free"
                    elif [[ $memtotal -ge 135000000 && $memtotal -lt 530000000 ]]; then
                        free=1500
                        echo "free is $free"
                    fi
#-------------------------------------------------------
                else
                    echo "There is more then 512Gb RAM, not tested yet. Run test mannually"
                fi
        case $ram in
            16 )
                echo "There is less then 17GB RAM, starting 1x memtester process"
                let chkmem=`grep -ri MemFree /proc/meminfo|awk '{print $2}'`/1024-512
                memtester $chkmem 1 > /root/install/memtest.log 2>&1 &
                sleep 6
                let memfree=`grep -ri MemFree /proc/meminfo | awk '{print $2}'`/1024
                echo "==================== memtester has started. You have FreeRAM: $memfree Mb ==================" 
            ;;
            16-512 )
                echo "There is more then 17GB RAM and less then 513GB"
                for (( i=1;; i++ )); do
                    let memfree=`grep -ri MemFree /proc/meminfo | awk '{print $2}'`/1024
                        if [[ "$memfree" -gt "17000" ]]; then
                            echo "There is still more then 16Gb free RAM, starting cycle "$i", Free memory: "$memfree" Mb, Run memtester #$i"
                            memtester 16000 1 > /root/install/memtest$i.log 2>&1 &
                            sleep 5
                        else
                            echo "There is less then 17GB RAM"
                            let chkmem=`grep -ri MemFree /proc/meminfo | awk '{print $2}'`/1024-$free
                            memtester $chkmem 1 > /root/install/memtest$i.log 2>&1 &
                            sleep 6
                            let memfree=`grep -ri MemFree /proc/meminfo | awk '{print $2}'`/1024
                            echo "==================== memtester has started. You have FreeRAM: $memfree Mb =================="
                            break
                        fi
                done
            ;;
            * )
                echo "There is more then 512Gb RAM, not tested yet. Run test mannually"
            ;;
        esac
#-------------autostart_Memtester---------------------------------------------------------------------------------------------------------------------------------------------
        ;;
    esac
}
 
chkcpu() { 
    case $OSVER in
        CentOS )
            cpuburn 2>&1 > /dev/null&
        ;;
        debian)
            cpuburn 2>&1 > /dev/null&
        ;;
        Ubuntu)
            cpuburn 2>&1 > /dev/null&
        ;;
    esac
}
 
 
hwinfo() {
    case $OSVER in
        CentOS | debian| Ubuntu)
                #IFACES=`ip link show|egrep "(eth[0-9]*:|enp[0-9]s[0-9]*:|em[0-9]*:|eno[0-9]*:)"|grep "state UP"|awk '{print $2}'|cut -f1,2 -d":"`
                IFACES=`ip link show|egrep "(eth[0-9]*:|enp[0-9]s[0-9]*:|enp[0-9][a-z][0-9][a-z][0-9]*:|em[0-9]*:|eno[0-9]*:)"|grep "state UP"|awk '{print $2}'|cut -f1,2 -d":"`
        let memtotalGB=`head -n1 /proc/meminfo | awk '{print $2}'`/1024/1024
        let memtotalMB=`head -n1 /proc/meminfo | awk '{print $2}'`/1024
        let memtotalKB=`head -n1 /proc/meminfo | awk '{print $2}'`
echo "
------------OS-----------
OS: $OSVER $OSVERNUM $ARCH
---------Hardware--------
CPU:`grep "model name" /proc/cpuinfo | head -n1 | cut -f 2 -d ":"| sed 's/ \{1,\}/ /g'`
CPU count: `cat /proc/cpuinfo | grep 'physical id' | sort | uniq | wc -l`
Cores per 1 CPU: `cat /proc/cpuinfo|grep 'cpu cores' | sed 's|.* ||'|head -n1`
Threads: `cat /proc/cpuinfo |grep processor|wc -l`
RAM: "$memtotalKB"Kb / "$memtotalMB"Mb / ~"$memtotalGB"Gb
Disks:
`fdisk -l 2>/dev/null | egrep -i "Disk|:"`
Number of Disks: `fdisk -l 2>/dev/null|grep "Disk /dev"|egrep -v "(/dev/[bcache,md,ram])"|wc -l`
`fdisk -l 2>/dev/null|grep "Disk /dev"|egrep -v "(/dev/[bcache,md,ram])"|awk '{print $1,$2,$3,$4}'`
Ethernet: `ip a|grep inet|egrep -vi "(127.0.0|::|tun)"|awk '{print $2}'|cut -d "/" -f 1|xargs -n 6`
`for i in $IFACES; do echo $i; ethtool $i| grep Speed; done`
lspci:
`lspci | egrep -i "ata|scsi|sas|raid|eth"`
------------------------"
                ;;
    esac
}
 
soft
chkmemory
chkcpu
hwinfo 
