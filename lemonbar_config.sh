#!/bin/bash

PIPE="/tmp/pipe_lemonbar"

## Thresholds
## ----------

BATTERY_THRESHOLD=20
TEMPERATURE_THRESHOLD=70
DISK_ROOT_THRESHOLD=20
DISK_HOME_THRESHOLD=20
LOAD_THRESHOLD=4.0

## Colors
## ------
SEP_COLOR="#aaaaff"      # Color of the separator
GOOD_COLOR="#008888"     # Color to print when the output is good
DEGRADED_COLOR="#ff00ff" # Color to print when the output is degraded
BAD_COLOR="#ff0000"      # Color to output when the output is bad or dangerous for the computer.
LIGHT_GRAY='#cccccc'     # Color to output current desktop
DARK_GRAY='#888888'      # Color to output idle desktop


## Fonts
## -----

## Miscelanou
## -----------

#SEPARATOR="%{F${SEP_COLOR}} || %{F-}"
SEPARATOR=" "
