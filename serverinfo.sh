#!/bin/bash

# wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/serverinfo.sh

Line='==========='

#linux发行版名称
if [[ -f /usr/bin/lsb_release ]]; then 
OS=$(/usr/bin/lsb_release -a |grep Description |awk -F : '{print $2}' |sed 's/^[ \t]*//g') 
else 
OS=$(cat /etc/issue |sed -n '1p') 
fi 

echo -e "${Line}\nOS:\n${OS}\n${Line}"

######################################################################################################

#查看系统是否为64位：uname -m，若出现x86_64，则为64位
OS_version=$(uname -m)
echo -e "OS_version:\n${OS_version}\n${Line}"


#系统内核版本 
kernel_version=$(uname -r) 
echo -e "Kernel_version:\n${kernel_version}\n${Line}"

#cpu型号
CPU=$(grep 'model name' /proc/cpuinfo |uniq |awk -F : '{print $2}' |sed 's/^[ \t]*//g' |sed 's/ \+/ /g')
echo -e "CPU model:\n${CPU}\n${Line}"

#物理cpu个数
Counts=$(grep 'physical id' /proc/cpuinfo |sort |uniq |wc -l)
echo -e "Total of physical CPU:\n${Counts}\n${Line}" 

#物理cpu内核数
Cores=$(grep 'cpu cores' /proc/cpuinfo |uniq |awk -F : '{print $2}' |sed 's/^[ \t]*//g')
echo -e "Number of CPU cores\n${Cores}\n${Line}"

#逻辑cpu个数 
PROCESSOR=$(grep 'processor' /proc/cpuinfo |sort |uniq |wc -l)
echo -e "Number of logical CPUs:\n${PROCESSOR}\n${Line}"

#查看CPU当前运行模式是64位还是32位
Mode=$(getconf LONG_BIT) 
echo -e "Present Mode Of CPU:\n${Mode}\n${Line}" 


#查看CPU是否支持64位技术：grep 'flags' /proc/cpuinfo，若flags信息中包含lm字段，则支持64位
Numbers=$(grep 'lm' /proc/cpuinfo |wc -l) 
if (( ${Numbers} > 0)); then lm=64 
else lm=32 
fi
echo -e "Support Mode Of CPU:\n${lm}\n${Line}"
######################################################################

#Memtotal 内存总大小
Total=$(cat /proc/meminfo |grep 'MemTotal' |awk -F : '{print $2}' |sed 's/^[ \t]*//g')
echo -e "Total Memory:\n${Total}\n${Line}" 

#系统支持最大内存 
Max_Capacity=$(dmidecode -t memory -q |grep 'Maximum Capacity' |awk -F : '{print $2}' |sed 's/^[ \t]*//g')
echo -e "Maxinum Memory Capacity:\n${Max_Capacity}\n${Line}" 

#查看内存类型、频率、条数、最大支持内存等信息：dmidecode -t memory，或dmidecode | grep -A16 "Memory Device$"
#下面为统计内存条数
Number=$(dmidecode | grep -A16 "Memory Device$" |grep Size|sort |sed 's/^[ \t]*//g'| grep -v 'No Module Installed' | wc -l)
echo -e "Number of Physical Memory:\n${Number}\n${Line}"


#SwapTotal swap分区总大小
SwapTotal=$(cat /proc/meminfo |grep 'SwapTotal' |awk -F : '{print $2}' |sed 's/^[ \t]*//g')
echo -e "Total Swap:\n${SwapTotal}\n${Line}"

#Buffers size 
Buffers=$(cat /proc/meminfo |grep 'Buffers' |awk -F : '{print $2}' |sed 's/^[ \t]*//g')
echo -e "Buffers:\n${Buffers}\n${Line}" 

#Cached size
Cached=$(cat /proc/meminfo |grep '\<Cached\>' |awk -F : '{print $2}' |sed 's/^[ \t]*//g')
echo -e "Cached:\n${Cached}\n${Line}" 

#空闲内存 + buffers/cache
Available=$(free -m |grep - |awk -F : '{print $2}' |awk '{print $2}')
echo -e "Available Memory:\n${Available} MB\n${Line}"

#显示硬盘，以及大小 
Disk=$(fdisk -l |grep 'Disk' |awk -F , '{print $1}' | sed 's/Disk identifier.*//g' | sed '/^$/d')
echo -e "Amount Of Disks:\n${Disk}\n${Line}"

#各挂载分区使用情况
Partion=$(df -hlP |sed -n '2,$p')
echo -e "Usage Of partions:\n${Partion}\n${Line}"
