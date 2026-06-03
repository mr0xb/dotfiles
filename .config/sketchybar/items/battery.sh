#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

battery=(
  script="$PLUGIN_DIR/battery.sh"
  #icon.font="SF Pro:Bold:20.0"
  icon.font="0xProto Nerd Font Mono:Bold:20.0"
  icon.color=$GREEN
  icon.padding_left=4
  icon.padding_right=4
  label.font="0xProto Nerd Font Mono:Bold:15.0"
  label.color=$WHITE
  label.padding_left=4
  label.padding_right=8
  background.color=$BACKGROUND_2
  background.corner_radius=8
  background.height=28
  background.drawing=on
  padding_left=4
  padding_right=4
  update_freq=120
)

sketchybar --add item battery right \
           --set battery "${battery[@]}" \
           --subscribe battery system_woke power_source_change
