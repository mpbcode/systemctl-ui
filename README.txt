systemctl-ui.lua is a simple Lua script that displays a terminal-based 
menu of Systemd units.  You can select zero or more units, and then 
stop and disable all those units.

systemctl-ui.lua is written in Lua 5.3 and uses the whiptail program to 
display the menu.  (Earlier versions of Lua may work, but have not been 
tested.)

Usage:

$ sudo lua5.3 systemctl-ui.lua

After you select zero or more units on the menu and press the Okay 
button, the script will ask to you confirm by pressing the "y" key for 
each unit.
