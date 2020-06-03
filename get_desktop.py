#!/usr/bin/python3
"""
Created at 21:09:22 on dimanche 26-05-2019

@author: Étienne de Montbrun

Name:
-----
get_desktop.py

Description:
------------
A python script to get all the i3 events that I need for my lemonbar.
"""

# i3 ipc looks more to have more power.
# i3 module should be very useful to do what I need to do.
# Use i3.get_workspaces()

import i3ipc
import sys
import os

PIPE = "/tmp/pipe_lemonbar"
SEP_COLOR = "#aaaaff"  # Color of the separator
GOOD_COLOR = "#008888"  # Color to print when the output is good
DEGRADED_COLOR = "#ff00ff"  # Color to print when the output is degraded
# Color to output when the output is bad or dangerous for the computer.
BAD_COLOR = "#ff0000"
LIGHT_GRAY = '#cccccc'  # Color to output current desktop
DARK_GRAY = '#888888'  # Color to output idle desktop
MODE_COLOR = '#905500'  # COlor to output the mode
CURRENT_DIR = sys.argv[0].rsplit('/', 1)[0]


def update_workspaces(i3con):
    workspaces = i3con.get_workspaces()
    workspaces.sort(key=lambda x: x.num)
    desktop_bar = "DES"
    id_desktop = 0
    goto_desk = CURRENT_DIR + '/goto_desktop.py'
    for workspace in workspaces:
        button = "%{{A:{0} {1}:}}".format(goto_desk, id_desktop)
        if workspace.focused:
            display_workspace = "%{{U#ff0000}}%{{+o}}%{{B{0}}} {1} %{{B-}}%{{-o}}%{{U-}}".format(
                LIGHT_GRAY, workspace.name.replace('_', ' '))
            desktop_bar += button + display_workspace + "%{A}"
        elif workspace.urgent:
            display_workspace = "%{{U#ff6105}}%{{+o}}%{{B{0}}} {1} %{{B-}}%{{-o}}%{{U-}}".format(
                BAD_COLOR, workspace.name.replace('_', ' '))
            desktop_bar += button + display_workspace + "%{A}"
        else:
            display_workspace = "%{{U#ff0000}}%{{+o}}%{{B{0}}} {1} %{{B-}}%{{-o}}%{{U-}}".format(
                DARK_GRAY, workspace.name.replace('_', ' '))
            desktop_bar += button + display_workspace + "%{A}"
        id_desktop += 1
    return desktop_bar


def write_to_pipe(pipe_name, msg):
    if not os.path.exists(pipe_name):
        sys.exit()
    with open(pipe_name, "w") as pipe:
        pipe.write(msg + "\n")


def on_workspace_focus(i3con, e):
    message = update_workspaces(i3con)
    write_to_pipe(PIPE, message)


def on_workspace_init(i3con, e):
    message = update_workspaces(i3con)
    write_to_pipe(PIPE, message)


def on_workspace_urgent(i3con, e):
    message = update_workspaces(i3con)
    write_to_pipe(PIPE, message)


def on_workspace_move(i3con, e):
    message = update_workspaces(i3con)
    write_to_pipe(PIPE, message)


def on_mode(i3con, e):
    if e.change == "default":
        message = "MOD"
    else:
        message = "MOD%{{B{0}}} {1} %{{B-}}".format(MODE_COLOR, e.change)
    write_to_pipe(PIPE, message)


if __name__ == "__main__":
    i3con = i3ipc.Connection()
    message = update_workspaces(i3con)
    write_to_pipe(PIPE, message)

    i3con.on('mode', on_mode)
    i3con.on('workspace::focus', on_workspace_focus)
    i3con.on('workspace::init', on_workspace_init)
    i3con.on('workspace::urgent', on_workspace_urgent)
    i3con.on('workspace::move', on_workspace_move)
    i3con.main()
