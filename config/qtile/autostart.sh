#!/usr/bin/env bash

xrandr --output HDMI-0 --mode 1920x1080 --rate 144

blueman-applet &
nitrogen --restore &
dunst &
udiskie &
flameshot &

xsetroot -cursor_name left_ptr
unclutter -idle 1 -root &
