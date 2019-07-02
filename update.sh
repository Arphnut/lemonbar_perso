#!/bin/bash

directory=$(dirname $0)

$directory/lemonbar_exit.sh&
sleep 1
pkill lemonbar
pkill pactl
sleep 1
$directory/lemonbar_launcher.sh&
