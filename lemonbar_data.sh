#!/bin/bash

# Rk:
# Use %{U to underline text}
# Implement the button in the bar.
# Implement the ethernet, and improve the wifi one (connecting...)
# Implement a way to use applets (nm-applet, VLC...)

directory=$(dirname $0)
source $directory/lemonbar_config.sh
echo $PIPE

clock() {
    # Display the date with a nice format
    time=$(date '+%H:%M:%S %d-%m-%Y')
    echo "$time"
}

battery_capacity() {
    #Display the capacity of the battery
    full_bat=$(cat /sys/class/power_supply/BAT1/charge_full_design)
    actual_bat=$(cat /sys/class/power_supply/BAT1/charge_now)
    hun_actual_bat=$((100*$actual_bat))
    percentage=$(bc <<< "scale=2;$hun_actual_bat/$full_bat")
    echo $percentage
}

battery_status() {
    # Tell the battery status
    cat /sys/class/power_supply/BAT1/status
}

display_battery() {
    # Display the battery status, with its capacity in a nice form
    batt_status=$(battery_status)
    case "$batt_status" in
	"Charging") echo "CHA$(battery_capacity)" ;;
	"Discharging") capacity=$(battery_capacity | cut -b -2)
		       if [[ $capacity -le 10 ]]
		       then
			   echo "ALE $(battery_capacity)"
		       elif [[ $capacity -le 25 ]]
                       then
                           echo "25P $(battery_capacity)"
		       elif [[ $capacity -le 50 ]]
                       then
                           echo "50P $(battery_capacity)"
		       elif [[ $capacity -le 75 ]]
                       then
                           echo "75P $(battery_capacity)"
                       else
                           echo "100 $(battery_capacity)"
		       fi
		       ;;
	"Full") echo "FUL$(battery_capacity)" ;;
    esac
}

get_load() {
    # Get the load of the CPU
    uptime | sed 's/^.*average: //' | cut -b -4
}

display_load() {
    # Display the load of the CPU
    load=$(sed 's/,/./g' <<< $(get_load))
    if (( $(bc -l <<< "$load < $LOAD_THRESHOLD") ))
    then
	echo "GOO$load%"
    else
	echo "BAD$load%"
    fi
}


get_temp() {
    # get the temperature of the CPnUs
    temp=$(cut -b -2 /sys/class/thermal/thermal_zone0/temp)
    if [[ $temp -ge $TEMPERATURE_THRESHOLD ]]
    then
	echo "T: $temp°C"
    else
	echo ""
    fi
}

disk_usage_root() {
    # Display the disk usage of the main folder "/"
    disk_u=$(df / | sed -n "2p")
    disk_u=($disk_u)
    disk_per=$(( 100 - $( cut -b -2 <<< ${disk_u[4]} ) ))
    if [[ $disk_per -ge $DISK_ROOT_THRESHOLD ]]
    then
	echo "N" # We are in the normal state (under the threshold)
    else
	echo "T$disk_per" # We are above the threshold
    fi
}

disk_usage_home() {
    # Display the disk usage of the main folder "/"
    disk_u=$(df ~ | sed -n "2p")
    disk_u=($disk_u)
    disk_per=$(( 100 - $( sed 's/%.*//g' <<< ${disk_u[4]} ) ))
    if [[ $disk_per -ge $DISK_HOME_THRESHOLD ]]
    then
	echo "N"
    else
	echo "T$disk_per"
    fi
}


get_wifi() {
    # Use nmcli ???
    # Get the wifi strength of the signal
    wifi_stat=$(iwconfig wlp3s0 | grep -i quality)
    wifi_line=$(sed -n "s:.*\([0-9][0-9]/[0-9][0-9]\).*:\1:p" <<<$wifi_stat)
    wifi_strength=$(bc -l <<<"${wifi_line}*100")
    echo $(cut -b -2 <<<$wifi_strength)
}


get_ethernet() {
    exec 3>&2
    exec 2> /dev/null
    speed=$(ethtool enp4s0f1 | grep Speed)
    echo $(cut -d' ' -f 2 <<<$speed)
    exec 2>&3
}

display_wifi() {
    wifi_status=$(cut -d':' -f 1 <<<$(nmcli -t general status))
    case $wifi_status in
        connected) devices=$(nmcli -t connection show | cut -d':' -f 4)
                   use_wifi=false
                   use_eth=false
                   for dev in $devices
                   do
                       if [[ $dev == *wlp3s0* ]]
                       then
                           use_wifi=true
                       elif [[ $dev == *enp4s0f1* ]]
                       then
                           use_eth=true
                       fi
                   done
                   if [[ $use_wifi == true ]]
                   then
                       wifi=$(get_wifi)
                       if [[ $use_eth == true ]]
                       then
                           ethernet=$(get_ethernet)
                           echo "WAE${wifi} ${ethernet}"
                       else
                           echo "WIF$wifi"
                       fi
                   elif [[ $use_eth == true ]]
                   then
                       ethernet=$(get_ethernet)
                       echo "ETH$ethernet"
                   fi
                   ;;
        connecting) echo  "CON" ;;
        disconnected) echo "DIS" ;;
        asleep) echo "ASL" ;;
        *) echo "PRO" ;;
    esac
                   
}


max_sink() {
    # max of the sinks.
    # We suppose that this is the one used.
    max='-1'
    for a in $(pactl list short sinks | cut -b 1-2);
    do
	if [[ $a -gt $max ]];
	then
	    max=$a
	fi
    done
    echo $max
}

get_volume() {
    # compute the volume
    SINK=$(max_sink)
    line=$(pactl list sinks | grep -in "Sink #$SINK" | cut -d':' -f1)
    line_status=$(($line+8))
    line_vol=$(($line+9))
    volume=$(sed -n "${line_vol}p" <<<$(pactl list sinks) | sed -n -r "s/.* ([0-9]{1,})%.*/\1/p" )
    status=$(sed -n "${line_status}p" <<<$(pactl list sinks)| cut -d" " -f2)
    case $status in
        no) if [[ $volume -lt 33 ]]
            then
                echo "33V${volume}%"
            elif [[ $volume -lt 66 ]]
            then
                echo "66V${volume}%"
            else
                echo "100${volume}%"
            fi
            ;;
        yes) echo "MUT" ;;
    esac
    
}


get_change_vol() {
    # Get the changes in the volume and diplay them.
    # Id of the volume VOL
    while read -r i
    do
	echo "VOL$(get_volume)">$PIPE
    done < <(pactl subscribe | stdbuf -oL grep sink)
}




get_change_data() {
    #Get the changes of the data
    #Id for the global data: DAT
    while :; do
	echo "LOAD$(display_load)">$PIPE &
	echo "ROOT$(disk_usage_root)">$PIPE &
	echo "HOME$(disk_usage_home)">$PIPE &
        echo "WIFI$(display_wifi)">$PIPE &
	echo "BAT$(display_battery)">$PIPE &
	echo "TEMP$(get_temp)">$PIPE &
	echo "CLOCK$(clock)">$PIPE &
	sleep 1
    done
}

if [[ ! -p $PIPE ]]
then
    echo "Not running"
    exit 1
fi

get_change_data() {
    while :; do
        if [[ ! -p $PIPE ]]
        then
            echo "Not running"
            exit 1
        fi
        echo "LOA$(display_load)">$PIPE 
        echo "ROO$(disk_usage_root)">$PIPE 
        echo "HOM$(disk_usage_home)">$PIPE 
        echo "WIF$(display_wifi)">$PIPE
        echo "BAT$(display_battery)">$PIPE
        echo "TEM$(get_temp)">$PIPE
        echo "CLO$(clock)">$PIPE
        echo "UPD">$PIPE
        sleep 1
    done
}
get_change_vol &
get_change_data &
