#!/bin/bash
smart () {
if [[ -z `lspci|grep -i "RAID bus controller"` ]]; then
    if [[ -n $(fdisk -l 2>/dev/null|grep /dev/nvme) && -n $(lsblk|grep nvme) ]];then
        echo "====== Intel NVME detected ======"
        raidcard=nvme
    else
        echo "====== No raid controller detected ======"
        raidcard=NoRaid
    fi
elif [[ -n `lspci|grep -i "RAID bus controller"|grep "MegaRAID"` && `smartctl --scan|grep -i megaraid` ]]; then
    echo "====== MegaRAID raid controller detected ======"
    raidcard=MegaRAID
elif [[ -n `lspci|grep -i "RAID bus controller"|grep "Hewlett-Packard"` && -z `lspci|grep -i "RAID bus controller"|egrep -i '(megaraid|nvme|adaptec)'` ]]; then
    echo "====== Hewlett-Packard raid controller detected ======"
    raidcard=Hewlett-Packard
else
    "I don't know this raid controller. Try run it manually"
fi
case "$raidcard" in
    nvme )
        let X=$(fdisk -l 2>/dev/null|grep /dev/nvme|wc -l)-1
        for i in $(seq 0 $X); do echo "=== /dev/nvme$i ==="; nvme smart-log /dev/nvme$i;done
        for i in $(seq 0 $X); do echo "=== /dev/nvme$i ==="; nvme intel smart-log-add /dev/nvme$i;done
        ;;
    NoRaid )
        disk=`fdisk -l 2>/dev/null| grep -i dev |egrep -v "(/dev/[brm])"| awk '/:/ {print $2}'| cut -f 1 -d ":"`
        for i in $disk; do echo ===$i===; smartctl -a $i|egrep '^(Self-test|Serial|Device M|  (5|8|9)|196|197|User|# (1|2))|result|remaining|defect';done
        for i in $disk; do echo ===$i===; smartctl -t long $i;smartstatus=$?;echo "status $smartstatus";done
            if [[ "$smartstatus" -ne 0 ]]; then
            echo "Try run smartctl manually"
            else
                echo "====== SMART testig started ======"
            fi
    ;;
    MegaRAID )
            disk=`fdisk -l 2>/dev/null| grep -i dev |egrep -v "(/dev/[brm])"| awk '/:/ {print $2}'| cut -f 1 -d ":"|wc -l`
            if [[ $disk -ge 2 ]]; then
                let disk=$disk-1
                for i in `seq 0 $disk`; do echo ===megaraid,$i===; smartctl -a -d megaraid,$i /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5|8|9)|196|197|User|# (1|2))|result|remaining|defect' ;smartstatus=$?; done
                        if [[ "$smartstatus" -ne 0 ]]; then
                                echo "===================== I do not know how to start testing in this case. Try run smartctl manually ====================="
                                echo "$(smartctl --scan)"
                        else
                            echo "====== SMART testig started ======"
                        fi
            else
                echo "====== MegaRAID is alerady set up, You don't need SW RAID, trying start smart testing  ======"
                for i in `seq 0 9` ; do echo ===megaraid,$i===; smartctl -a -d megaraid,$i /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5|8|9)|196|197|User|# (1|2))|result|remaining|defect' ; done
            fi
    ;;
    Hewlett-Packard )
    #193.29.187.101
            disk=`fdisk -l 2>/dev/null| grep -i dev |egrep -v "(/dev/[brm])"| awk '/:/ {print $2}'| cut -f 1 -d ":"|wc -l`
            if [[ $disk -ge 2 ]]; then
                let disk=$disk-1
                for i in $(seq 0 $disk); do echo ===cciss,$i===; smartctl -d cciss,$i -a /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5)|196|197|User|# (1|2))|result|remaining|defect' ;smartstatus=$?;done
                        if [[ "$smartstatus" -ne 0 ]]; then
                                        echo "===================== I do not know how to start testing in this case. Try run smartctl manually ====================="
                                        echo "$(smartctl --scan)"
                        else
                            echo "====== SMART testig started ======"
                        fi
            else
                echo "====== HW RAID is alerady set up, You don't need SW RAID, trying start smart testing  ======"
                for i in `seq 0 11` ; do echo ===cciss,$i===; smartctl -d cciss,$i -a /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5)|196|197|User|# (1|2))|result|remaining|defect'; done
            fi
    ;;
    * )
        echo "there is not this raid controller in my database"
        $(lspci|grep "RAID bus controller")
    ;;
esac
}
smart

######на одном серере 2 рейд контроллера, диски только в одном
######2 диска без рейд контроллера и 2 диска в nvme 54.37.248.14 + debian7 нету инфы в дефолтном месте по ос
