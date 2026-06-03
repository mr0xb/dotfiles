#!/bin/sh

source "$CONFIG_DIR/colors.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON="󰂂 " ; COLOR="0xffa8ff60" ;;
  [6-8][0-9]) ICON="󰁿 " ; COLOR="0xffa8ff60" ;;
  [3-5][0-9]) ICON="󰁼 " ; COLOR="0xfffffeb7" ;;
  [1-2][0-9]) ICON="󰁺 " ; COLOR="0xfffcb6b0" ;;
  *)          ICON="󰁹 " ; COLOR="0xfffa6c60" ;;
esac

if [ "$CHARGING" != "" ]; then
  ICON=" "
  #COLOR="0xffa8ff60"
  COLOR=$GREEN
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%" label.drawing=on
