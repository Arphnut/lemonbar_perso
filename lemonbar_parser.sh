#!/bin/bash

directory=$(dirname $0)
source $directory/lemonbar_config.sh


desk=""
mode=""
load=""
root=""
home=""
wifi=""
bat=""
temp="\uf059 %"
clock="$(date '+%H:%M:%S %d-%m-%Y')"
vol="\uf6a9 \uf059 %"


while read -r line
do
    if [[ $line == 'QUIT' ]]
    then
        rm $PIPE
        break
    fi
    type=$(cut -b -3 <<<$line)
    case $type in
        DES) desk=$(cut -b 4- <<<$line)
             update=true # We update the display because we changed the desktop.
             ;;
        MOD) mode=$(cut -b 4- <<<$line)
             update=true # We update the display because we changeed the mode.
             ;;
	SYS)# Set the clock
	    sys_arr=(${line#???})
	    timeclock=${sys_arr[0]}
	    timedate=${sys_arr[1]}
            clock="\uf017 $timeclock \uf073 $timedate"
	    
	    # Set the load
	    loadinter=${sys_arr[2]}
	    loadinter=$(sed 's/,/./g' <<< $loadinter)
	    if (( $(bc -l <<< "$loadinter < $LOAD_THRESHOLD") ))
	    then
                load="%{T3}L: %{T1}$loadinter"
	    else
                load="%{F${BAD_COLOR}}%{T3}L: %{T1}$loadinter%{F-}"
	    fi

	    # Usage of the main disk
	    rootinter=${sys_arr[3]}
	    if [[ $rootinter -ge $DISK_ROOT_THRESHOLD ]]
	    then
                root="%{F${BAD_COLOR}}\uf0c7 $rootinter%%{F-}"
	    fi

	    # Usage of the home disk
            homeinter=${sys_arr[4]}
            if [[ $homeinter -ge $DISK_HOME_THRESHOLD ]]
	    then
                home="%{F${BAD_COLOR}}\uf015 $homeinter%%{F-}" 
            fi

	    # Wifi parameterization
            wifinter=${sys_arr[5]}
	    if [[ $wifinter == NO ]]
	    then
		wifi="\uf1eb \uf05e  "
	    else
		wifi="\uf1eb $wifinter "
	    fi
	    

	    # Ethernet parameterization
	    ethinter=${sys_arr[6]}
	    if [[ $ethinter == YES ]]
	    then
	       eth="\uf063 "
	    else
		eth=""
	    fi

	    # The temperature of the computer
	    temp="${sys_arr[7]}°C"

	    # Battery Usage
            battype=${sys_arr[8]}
	    bat=${sys_arr[9]}
            case $battype in
                C) # Battery is charging
                    bat="%{F${GOOD_COLOR}}\uf0e7 $bat %{F-}" ;; 
                F) # Battery is full
                     bat="\uf240 100%" ;;
                E|N) # Battery is empty or not present
                    bat="%{F${BAD_COLOR}}\uf244 $bat %{F-}" ;;
		D) # Battery is discharging
		    bat_percent=$(sed 's/%//g' <<<$bat)
		    if [[ $bat_percent -le 10 ]]
		    then
			bat="%{F${BAD_COLOR}}\uf244 $bat %{F-}"
		    elif [[ $bat_percent -le 25 ]]
		    then
			 bat="%{F${DEGRADED_COLOR}}\uf244 $bat %{F-}"
		    elif [[ $bat_percent -le 50 ]]
		    then
			bat="%{F${DEGRADED_COLOR}}\uf243 $bat %{F-}"
		    elif [[ $bat_percent -le 75 ]]
		    then
			bat="%{F${DEGRADED_COLOR}}\uf242 $bat %{F-}"
		    elif [[ $bat_percent -le 100 ]]
		    then
			bat="%{F${DEGRADED_COLOR}}\uf241 $bat %{F-}"
		    else
			ba="%{F${BAD_COLOR}}\uf244 UNK %{F-}"
		    fi
		    ;;
            esac
            ;;
        VOL) volinter=$(cut -b 4- <<<$line)
             voltype=$(cut -b -3 <<<$volinter)
             vol=$(cut -b 4- <<<$volinter)
             case $voltype in
                 MUT) vol="%{T2}\uf6a9 %{T1}" ;;
                 33V) vol="\uf026 $vol" ;;
                 66V) vol="\uf027 $vol" ;;
                 100) vol="\uf028 $vol" ;;
             esac
             update=true # We update the display because we change the volume.
             ;;
        UPD) # We update the display of all data coming every second from "lemonbar_data.sh"
            update=true
            ;;
    esac
    if [[ $update == true ]]
       then
           echo -e  "${desk}${mode}%{r}${vol}${SEPARATOR}${load}${SEPARATOR}${root}${SEPARATOR}${home}${SEPARATOR}${wifi}${eth}${bat}${SEPARATOR}${temp}${SEPARATOR}${clock}"
    fi
done
