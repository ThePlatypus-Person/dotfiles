#!/usr/bin/env bash

blueman-applet &
nitrogen --restore &
picom &
dunst &
udiskie &
flameshot &

xsetroot -cursor_name left_ptr
xrandr --output HDMI-0 --mode 1920x1080 --rate 144 &
unclutter -idle 1 -root &
