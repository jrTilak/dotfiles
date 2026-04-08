#!/bin/bash
/home/jrtilak/.local/kitty.app/bin/kitty &
sleep 0.5
ID=$(xdotool search --sync --class kitty | tail -1)
xprop -id $ID -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0
