#!/bin/bash

directory=$(dirname $0)
PIPE=/tmp/pipe_lemonbar

if [[ -e $PIPE ]]
   then
   if [[ ! -p $PIPE ]]
   then
       rm $PIPE
   fi
fi
   
       
trap "rm -f $PIPE", EXIT

if [[ ! -p $PIPE ]]
then
    mkfifo $PIPE
fi

$directory/lemonbar_data.sh &
$directory/get_desktop.py &
sleep 1
tail -f $PIPE | $directory/lemonbar_parser.sh | lemonbar  -p -b -u 3 -f "Roboto Medium-12" -f "Font Awesome-12" -f "Roboto Black-12" -B '#1D252C' | bash  & # Launch the reader, that display the datas to the lemonbar programs.
sleep 1


