#!/bin/bash
################################################################################
#
#  Copyright (C) 2016 Erol Tahirovic (erol@erol.name)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Simple utility to monitor Pine64 statistics
#
# Usage:
#
#   ./pine64_stats.sh
#

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

tabs 4

function check_temp {
	t=$1
	if [ $t -ge 55 ]; then
		if [ $t -ge 75 ]; then
			t="$Red$t"C"$Color_Off"
		else
			t="$Yellow$t"C"$Color_Off"
		fi
	else
		t="$Green$1"C"$Color_Off"
	fi
	echo $t
}

echo -e "Press [CTRL+C] to stop..\n"
high=`cat /sys/devices/virtual/thermal/thermal_zone0/temp`
sep="Cur.Time\tARM freq.\tGovernor\t\tTemp/Max\tMemory MB %\t\t\tCpu Load\n"
sep+="==========\t===========\t=============\t===========\t=================\t=========\n"
echo -e $sep 
i=0
while :
do
	now=$(date +"%T")
	cur=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq`
	mhz=`awk "BEGIN {printf \"%.2f\",$cur/1000}"`
	if [ $cur -ge 1152000 ]; then
		mhz="$Red$mhz"MHz"$Color_Off"
	else
		mhz="$Green$mhz"MHz"$Color_Off"
	fi	
	gov=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
	case $gov in
		conservative|powersave)
			gov="$Green$gov$Color_Off"
			;;
		interactive|userspace)
			gov="$Yellow$gov$Color_Off"
			;;
		performance)
			gov="$Red$gov$Color_Off"
			;;
		*)
			gov="$Purple$gov$Color_Off"
			;;
	esac
	temp=`cat /sys/devices/virtual/thermal/thermal_zone0/temp`
	if [ $temp -ge $high ]; then
		high=$temp	
	fi
	top=$(check_temp $high)
	temp=$(check_temp $temp)
	memp=`free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }'`
	memb=`free -m | awk 'NR==2{printf "%s/%s", $3,$2 }'`
	if (( $(echo "$memp > "80"" |bc -l) )); then
		if (( $(echo "$memp > "90"" |bc -l) )); then
			memp="$Red$memp%$Color_Off"
		else
			memp="$Yellow$memp%$Color_Off"
		fi
	fi
	memory="$memb $memp"
	load=`top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}'` 
	echo -e "$now\t$mhz\t$gov \t$temp/$top\t\t$memory\t\t$load" 
	i=$((i+1))
	if [ $i -ge 20 ]; then
		echo -e "\n";
		echo -e "$sep";
		i=0;
	fi
	sleep 2
done
