#!/usr/bin/env bash
### Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>
## Modified by VC365 <https://github.com/VC365> 

# Import Current Theme
DIR="$HOME/.blackbox/Themes"
RASI="$DIR/rofi/powermenu.rasi"
CNFR="$DIR/rofi/confirm.rasi"

# Theme Elements
prompt="`hostname` (`echo $DESKTOP_SESSION`)"
mesg="Uptime : `uptime -p | sed -e 's/up //g'`"

# Options
	option_1=" Lock"
	option_2="󰍃 Logout"
	option_3="󰒲 Suspend"
	option_4=" Hibernate"
	option_5=" Reboot"
	option_6="⏻ Shutdown"
  	option_7=" Hybrid Sleep"
	yes=' Yes'
	no=' No'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${RASI}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_7\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6\n$option_1" | rofi_cmd
}

# Confirmation CMD
confirm_cmd() {
	rofi -dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-selected-row 1 \
		-no-click-to-exit \
		-theme ${CNFR}
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Confirm and execute
confirm_run () {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
        ${1} && ${2} && ${3}
    else
        exit
    fi
}

if command -v systemctl >/dev/null 2>&1; then
    session_manager="systemctl"
elif command -v loginctl >/dev/null 2>&1; then
    session_manager="loginctl"
else
    echo "unknown session_manager">>"~/.blackbox/start_up.log"
    echo "Please set session_manager in .blackbox/Scripts/power.sh">>>>"~/.blackbox/start_up.log"
    exit 1
fi
confirm_run_HH () {
        selected="$(confirm_exit)"
        if [[ "$selected" == "$yes" ]]; then
        ${1} &
	xscreensaver-command --lock
    else
        exit
    fi
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		xscreensaver-command --lock
	elif [[ "$1" == '--opt2' ]]; then
		confirm_run 'kill -9 -1'
	elif [[ "$1" == '--opt3' ]]; then
		confirm_run 'xscreensaver-command --suspend'
	elif [[ "$1" == '--opt4' ]]; then
		confirm_run_HH '$session_manager hibernate'
	elif [[ "$1" == '--opt5' ]]; then
		confirm_run '$session_manager reboot'
	elif [[ "$1" == '--opt6' ]]; then
		confirm_run '$session_manager poweroff'
        elif [[ "$1" == '--opt7' ]]; then
                confirm_run_HH '$session_manager hybrid-sleep'
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
    $option_6)
		run_cmd --opt6
        ;;
    $option_7)
    run_cmd --opt7
    	;;
esac
