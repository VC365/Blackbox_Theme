#!/bin/sh
### Made by VC365 <https://github.com/VC365>

DIR_B="$HOME/.blackbox"
LOG_B="$DIR_B/start_up.log"
echo " -------------------------------- ">"$LOG_B"
if [ -f "$DIR_B/config.json" ]; then
  	background=$(jq -r '.background // "background.jpg"' "$DIR_B/config.json")
	  keyboard_layout=$(jq -r '.keyboard_layout // "us"' "$DIR_B/config.json")
	  keyboard_option=$(jq -r '.keyboard_option // "grp:rctrl_rshift_toggle"' "$DIR_B/config.json")
	  export REDSHIFT_DOOD=$(jq -r '.redshift // false' "$DIR_B/config.json")
	  vc_clock=$(jq -r '.vc_clock // true' "$DIR_B/config.json")
	  conky=$(jq -r '.conky // false' "$DIR_B/config.json")
	  export SCREENSHOT_FOLDER=$(jq -r '.screenshot_folder // "~/"' "$DIR_B/config.json")

fi

echo "background:$background | keyboard_layout:$keyboard_layout | keyboard_option:$keyboard_option">>"$LOG_B"
echo "redshift:$REDSHIFT_DOOD | vc_clock:$vc_clock | conky:$conky">>"$LOG_B"
run() {
  if whereis -b "$1" | grep -q '/'; then
    if pidof "$1" >/dev/null; then
      echo "---------- Restarting $1 ----------"
      killall -9 "$1"
    fi
    echo "---------- Starting $1 ----------"
    "$@" &>>"$LOG_B" &
  fi
}

## Root
run feh --bg-scale "$DIR_B/Backgrounds/$background"
run picom --backend=xrender --config "$DIR_B/Configs/picom/picom.conf"
run xsettingsd -c "$DIR_B/Configs/xsettingsd/xsettingsd.conf"
run tint2 "$DIR_B/Configs/tint2/tint2rc"
if [ "$conky" = true ]; then
    run conky -c "$DIR_B/Themes/conky/conky"
elif pidof conky >/dev/null; then
    killall -9 conky
fi

## Shortcuts
run sxhkd -c "$DIR_B/Configs/sxhkd/sxhkdrc"
run setxkbmap -layout "$keyboard_layout" -option "$keyboard_option"

## Plugins
run nm-applet
run dunst -config "$DIR_B/Configs/dunst/dunstrc"
run volume-pulse
if [ "$vc_clock" = true ]; then
    run vc-clock --no-tooltip
elif pidof vc-clock >/dev/null; then
    killall -9 vc-clock
fi

## Polkit
if ! pgrep -x polkit-gnome-authentication-agent-1 >/dev/null; then
    /lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

## ScreenSaver
run xscreensaver --no-splash
