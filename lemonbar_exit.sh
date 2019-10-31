#!/bin/bash

PIPE=/tmp/pipe_lemonbar

if [[ ! -p $PIPE ]]
then
    echo "Not running"
    exit 1
fi

echo "QUIT">$PIPE
pkill lemonbar
