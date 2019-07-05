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
        LOA) loadinter=$(cut -b 4- <<<$line)
             loadtype=$(cut -b -3 <<<$loadinter)
             case $loadtype in
                 GOO) load="%{T3}L: %{T1}$(cut -b 4- <<<$loadinter)";;
                 BAD) load="%{F${BAD_COLOR}}%{T3}L: %{T1}$(cut -b 4- <<<$loadinter)%{F-}";;
             esac
             ;;
        ROO) rootinter=$(cut -b 4- <<<$line)
             rootype=$(cut -b -1 <<<$rootinter)
             case $rootype in
                 N) root="";;
                 T) root="\uf0c7 $(cut -b 2- <<<$rootinter)%" ;;
             esac
             ;;
        HOM) homeinter=$(cut -b 4- <<<$line)
             hometype=$(cut -b -1 <<<$homeinter)
             case $hometype in
                 N) home="" ;;
                 T) home="\uf015 $(cut -b 2- <<<$homeinter)%" ;;
             esac
             ;;
        WIF) wifinter=$(cut -b 4- <<<$line)
             wifitype=$(cut -b -3 <<<$wifinter)
             wifi=$(cut -b 4- <<<$wifinter)
             case $wifitype in
                 WIF) wifi="\uf1eb $wifi" ;; # Connected to the wifi
                 ETH) wifi="\uf796 $wifi " ;; # Connected to the internet
                 WAE) wif=$(cut -d' ' -f1 <<<$wifi)
                      eth=$(cut -d' ' -f2 <<<$wifi)
                      wifi="\uf1eb $wif${SEPARATOR}%{T3}\uf796 %{T1}$eth " ;; # Connected to both th wifi and ethernet
                 CON) wifi="\uf519" ;;
                 DIS) wifi="\uf1eb \uf05e" ;;
                 ASL) wifi=""
             esac
             ;;
        BAT) # The intermediate value of the battery, before prerpocessing.
            batinter=$(cut -b 4- <<<$line)
            battype=$(cut -b -3 <<<$batinter)
            bat=$(cut -b 4- <<<$batinter)
            case $battype in
                CHA) # Battery is charging
                    bat="%{F${GOOD_COLOR}}\uf0e7 $bat%%{F-}" ;; 
                ALE) # Battery is in alert mode (lower than 10%)
                    bat="%{F${BAD_COLOR}}\uf244 $bat%%{F-}" ;; 
                25P) # Battery is lower thatn 25
                     bat="%{F${DEGRADED_COLOR}}\uf244 $bat%%{F-}" ;;
                50P) # Battery is lower thatn 50
                     bat="%{F${DEGRADED_COLOR}}\uf243 $bat%%{F-}" ;;
                75P) # Battery is lower thatn 50
                     bat="%{F${DEGRADED_COLOR}}\uf242 $bat%%{F-}" ;;
                100) # Battery is lower thatn 75
                     bat="%{F${DEGRADED_COLOR}}\uf241 $bat%%{F-}" ;;
                FUL) # Battery is full
                     bat="\uf240 $bat%" ;;
            esac
             ;;
        TEM) temp=$(cut -b 4- <<<$line)
             ;;
        CLO) clockinter=$(cut -b 4- <<<$line)
             timeclock=$(cut -d' ' -f1 <<<$clockinter)
             timedate=$(cut -d' ' -f2 <<<$clockinter)
             clock="\uf017 $timeclock \uf073 $timedate"
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
           echo -e  "${desk}${mode}%{r}${vol}${SEPARATOR}${load}${SEPARATOR}${root}${SEPARATOR}${home}${SEPARATOR}${wifi}${bat}${SEPARATOR}${temp}${SEPARATOR}${clock}"
    fi
done
