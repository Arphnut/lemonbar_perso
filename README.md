# personal_lemonbar

This folder contains utilities that will be needed for lemonbar.

* get_desktop.py : Get the current desktop and whether it is focused, urgent, and the current mode, using i3ipc.
* goto_desktop.py : Got to the asked desktop.
* lemonbar_data.sh: Display useful data for the lemonbar.
                   It displays information such as the time, the load, the volume, the worskpaces... (I should move to conky).

* lemonbar_parser.sh:  Read the pipe (fifo), and return the aranged data received from display data.
* lemonbar_exit.sh: Allow to end the read_fifo.sh script (it removes the pipe file before ending).
* lemonbar_launcher.sh: It launches the whole lemonbar program, with its setup.
* lemonbar_config.sh: the config files. Contain the colors, fonts...

## Usage
Just launch the 'lemonbar_launcher.sh' script.

## Next improvement
* Use conky (easier to understand, and i hope, less CPU).
* Add more comment.
