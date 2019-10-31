#!/bin/bash

# Rk:
# Use %{U to underline text}
# Implement the button in the bar.
# Implement the ethernet, and improve the wifi one (connecting...)
# Implement a way to use applets (nm-applet, VLC...)

directory=$(dirname $0)
source $directory/lemonbar_config.sh
echo $PIPE

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
    while :; do
	if [[ ! -p $PIPE ]]
        then
            echo "Not running"
            exit 1
        fi
	con=$(conky -c $directory/lemonbar_conky)
	echo "$con">$PIPE
	sleep 1
    done
}

get_change_vol &
get_change_data &
