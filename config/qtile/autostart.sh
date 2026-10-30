#!/usr/bin/env bash

if xrandr | grep -q '^HDMI-0 connected'; then
    xrandr --output HDMI-0 --mode 1920x1080 --rate 144
fi

blueman-applet &
nitrogen --restore &
dunst &
udiskie &
flameshot &

xsetroot -cursor_name left_ptr
unclutter -idle 1 -root &
