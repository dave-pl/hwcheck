#!/bin/bash
smart () {
if [[ -z $(lspci|grep "RAID bus controller") && -z $(fdisk -l 2>/dev/null|grep /dev/nvme) ]]; then
  echo "====== No raid controller detected ======"
  raidcard=NoRaid
elif [[ `lspci|grep -i "RAID bus controller" |wc -l` -eq 1 ]]; then
  if [[ -n `lspci|grep -i "RAID bus controller"|grep "MegaRAID"` ]]; then
    echo "====== MegaRAID raid controller detected ======"
    raidcard=MegaRAID
  elif [[ -n `lspci|grep -i "RAID bus controller"|grep "Hewlett-Packard"` ]]; then
    echo "====== Hewlett-Packard raid controller detected ======"
    raidcard=Hewlett-Packard
  elif [[ -n $(fdisk -l 2>/dev/null|grep /dev/nvme) ]]; then
    echo "====== NVME detected ======"
    raidcard=MVME
  fi 
elif [[ `lspci|grep -i "RAID bus controller" |wc -l` -ge 2 ]]; then
  echo "====== 2 or more raid controllers detected ======"
fi
############################
case "$raidcard" in
  NoRaid )
    if [[ $(fdisk -l 2>/dev/null| grep -i dev |egrep -v "(/dev/[brm])"| awk '/:/ {print $2}'| cut -f 1 -d ":"|wc -l) -ge 2 ]];then
      disk=$(fdisk -l 2>/dev/null| grep -i dev |egrep -v "(/dev/[brm])"| awk '/:/ {print $2}'| cut -f 1 -d ":")
      for i in $disk; do echo ===$i===; smartctl -a $i|egrep '^(Self-test|Serial|Device M|  (5|8|9)|196|197|User|# (1|2))|result|remaining|defect';done
      for i in $disk; do (echo ===$i===; smartctl -t long $i>>$MYPATH/result.txt);smartstatus=$?;done
        if [[ "$smartstatus" -ne 0 ]]; then
          smartt="Please, run SMART test mannualy"
        else
          smartt="SMART testing has begun, please check"
        fi
    else
      smartt="Please, run SMART test mannualy, maybe You have HW raid configured"
    fi
    ;;
    MegaRAID )
            disk=`fdisk -l | grep -i dev |egrep -v "(/dev/[bcache,md,ram])"| awk '/:/ {print $2}'| cut -f 1 -d ":"|wc -l`
            if [[ $disk -ge 2 ]]; then
                for i in `seq 1 $disk`; do echo ===megaraid,$i===; smartctl -a -d megaraid,$i /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5|8|9)|196|197|User|# (1|2))|result|remaining|defect' ;smartstatus=$?; done
                echo "status $smartstatus"
                        if [[ "$smartstatus" -ne 0 ]]; then
                                echo "===================== I do not know how to start testing in this case. Try run smartctl manually =====================" 
                                echo "$(smartctl --scan)"
                        fi
            else
                for i in `seq 0 9` ; do echo ===megaraid,$i===; smartctl -a -d megaraid,$i /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5|8|9)|196|197|User|# (1|2))|result|remaining|defect' ;smartstatus=$?; done
                echo "status $smartstatus"
                        if [[ "$smartstatus" -ne 0 ]]; then
                                echo "===================== I do not know how to start testing in this case. Try run smartctl manually =====================" 
                                echo "$(smartctl --scan)"
                        fi
            fi
    ;;
    Hewlett-Packard )
    #193.29.187.101
            disk=`fdisk -l | grep -i dev |egrep -v "(/dev/[bcache,md,ram])"| awk '/:/ {print $2}'| cut -f 1 -d ":"|wc -l`
            echo $disk
            if [[ $disk -ge 2 ]]; then
                for i in `seq 0 $disk` ; do echo ===cciss,$i===; smartctl -d cciss,$i -a /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5)|196|197|User|# (1|2))|result|remaining|defect' ;smartstatus=$?; done
                echo "status $smartstatus"
                        if [[ "$smartstatus" -ne 0 ]]; then
                                for i in `seq 0 11` ; do echo ===cciss,$i===; smartctl -d cciss,$i -a /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5)|196|197|User|# (1|2))|result|remaining|defect' ;smartstatus=$?; done
                                    if [[ "$smartstatus" -ne 0 ]]; then
                                        echo "===================== I do not know how to start testing in this case. Try run smartctl manually =====================" 
                                        echo "$(smartctl --scan)"
                                    fi
                        else
                            echo "====== SMART testig started ======"   
                        fi
            else
                for i in `seq 0 11` ; do echo ===cciss,$i===; smartctl -d cciss,$i -a /dev/sg0 | egrep '^(Self-test|Serial|Device M|  (5)|196|197|User|# (1|2))|result|remaining|defect' ;smartstatus=$?; done
                echo "status $smartstatus"
                        if [[ "$smartstatus" -ne 0 ]]; then
                                echo "===================== I do not know how to start testing in this case. Try run smartctl manually =====================" 
                                echo "$(smartctl --scan)"
                        fi
            fi
    ;;
    * )
    echo "there is not this raid controller in my database"
    $(lspci|grep "RAID bus controller")
    ;;
esac
#############################
}
smart
