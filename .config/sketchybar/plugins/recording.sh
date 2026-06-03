#!/bin/bash

SCREEN_RECORDING=0

# Check for active screencapture process (macOS screenshot/recording tool)
if pgrep -x screencapture > /dev/null 2>&1; then
    SCREEN_RECORDING=1
fi

# Check for common recording applications
if pgrep -x OBS > /dev/null 2>&1 || pgrep -x Kap > /dev/null 2>&1 || pgrep -x "CleanShot X" > /dev/null 2>&1 || pgrep -x Camtasia > /dev/null 2>&1; then
    SCREEN_RECORDING=1
fi

if [ $SCREEN_RECORDING -eq 1 ]; then
    sketchybar --set "$NAME" drawing=on background.drawing=on
else
    sketchybar --set "$NAME" drawing=off background.drawing=off
fi
