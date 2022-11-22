#!/bin/bash

Architecture=$(uname -a)
pCPU=$(cat /proc/cpuinfo | grep "physical id" | uniq | wc -l)
vCPU=$(cat /proc/cpuinfo | grep "processor" | wc -l)
CPULoad=$(top -ibn 1 |grep Cpu | tr -d "%C():[a-z],"  | awk '{print 100- $4"%"}')
MemLn=$(free | grep Mem)
MemUse=$(echo $MemLn | awk '{printf("%d",$3/1024)}')
MemTotal=$(echo $MemLn | awk '{printf("%.0f",$2/1024)}')
MemPrcent=$(echo $MemLn | awk '{printf("%.2f\n", $3*(100/$2))}')
LastReboot=$(who -b | awk '{print $3" "$4}')
DiskLn=$(df --total -BM | grep total |awk '{printf("%d/%dGb (%s)\n",$3,$2/1024,$5)}')
LVM_Active=$([[ -z "$(lvdisplay)" ]] && echo "no" || echo "yes")
ConnectionsCount=$(ss -t | grep ESTAB | wc -l)
SessionCount=$(who | wc -l)
CMDAsSudoCount=$(cat /var/log/sudo/sudo.log | grep COMMAND | wc -l)
wall "	#Architecture: $Architecture
	#CPU physical: $pCPU
	#vCPU : $vCPU
	#Memory Usage: $MemUse/${MemTotal}MB (${MemPrcent}%)
	#Disk Usage: $DiskLn
	#CPU load: $CPULoad
	#Last boot: ${LastReboot}
	#LVM use: $LVM_Active
	#Connections TCP : $ConnectionsCount ESTABLISHED
	#User log: $SessionCount
	#Network: IP $(hostname -I) ($(cat /sys/class/net/enp0s3/address))
	#Sudo : ${CMDAsSudoCount} cmd"
