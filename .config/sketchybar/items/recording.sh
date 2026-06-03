#!/bin/bash

source "$CONFIG_DIR/colors.sh"

recording=(
  script="$PLUGIN_DIR/recording.sh"
  icon=""
  icon.font="0xProto Nerd Font Mono:Bold:14.0"
  icon.color=$RED
  icon.padding_left=8
  icon.padding_right=8
  label.drawing=off
  drawing=off
  background.color=$BACKGROUND_2
  background.corner_radius=8
  background.height=28
  background.drawing=off
  padding_left=4
  padding_right=4
  update_freq=2
  click_script="$PLUGIN_DIR/recording_click.sh"
)

sketchybar --add item recording right \
           --set recording "${recording[@]}"
