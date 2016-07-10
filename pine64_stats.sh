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

echo -e "Press [CTRL+C] to stop..\n"
high=`cat /sys/devices/virtual/thermal/thermal_zone0/temp`

sep="Time\t\tARM\t\tGovernor\tTemperature\t(Max)\n"
sep+="==============\t=============\t=============\t==============\t==============\n"
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
	# interactive conservative ondemand userspace powersave performance
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
	if [ $high -ge 55 ]; then
		if [ $high -ge 75 ]; then
			top="$Red$high"C"$Color_Off"
		else
			top="$Yellowi$high"C"$Color_Off"
		fi
	else
		top="$Green$high"C"$Color_Off"
	fi
	if [ $temp -ge 55 ]; then
		if [ $temp -ge 75 ]; then
			temp="$Red$temp"C"$Color_Off"
		else
			temp="$Yellow$temp"C"$Color_Off"
		fi
	else
		temp="$Green$temp"C"$Color_Off"
	fi

	echo -e "$now\t$mhz\t $gov\t \t $temp\t\t($top)" 
	i=$((i+1))
	if [ $i -ge 20 ]; then
		echo -e "\n";
		echo -e $sep;
		i=0;
	fi
	sleep 2
done
