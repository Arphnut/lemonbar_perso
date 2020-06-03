#!/usr/bin/python3
"""
Created at 18:31:59 on vendredi 28-06-2019

@author: Étienne de Montbrun

Name:
-----
goto_desktop.py

Description:
------------
Take as argument the desktop we wan't to go to, and go to it using i3.
"""

import i3ipc
import argparse


def goto_desk(i3con, desk_id):
    """
    Go to the desktop 'id_desk', using the connection 'i3con'

    Parameters:
    -----------
    i3con (i3ipc.Connection): the open connection with i3.
    id_desk (int): the id of the desk we want to go to.
    """
    workspaces = i3con.get_workspaces()
    workspaces.sort(key=lambda x: x.num)
    desk_name = workspaces[desk_id].name
    i3con.command("workspace {}".format(desk_name))


if __name__ == '__main__':
    i3con = i3ipc.Connection()
    parser = argparse.ArgumentParser()
    parser.add_argument('desktop_id',
                        type=int,
                        help="The id of the desktop we want to go to")
    args = parser.parse_args()
    goto_desk(i3con, args.desktop_id)
