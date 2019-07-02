#!/bin/bash

pkill lemonbar
sleep 1
./lemonbar_parser.sh | lemonbar  -f "Roboto Medium-10" -f FontAwesome-10 | bash  & # Launch the reader, that display the datas to the lemonbar programs.
sleep 1
./lemonbar_data.sh &
./get_desktop.py &
