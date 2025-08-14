#!/bin/bash
### Made by VC365 <https://github.com/VC365>

RED='\033[0;31m'
NC='\033[0m'
deps=(blackbox feh jq picom tint2 xsettingsd sxhkd dunst nm-applet volume-pulse redshift rofi xscreensaver ksuperkey xdotool polkit-gnome playerctl lxappearance gnome-screenshot conky top vc-clock)
missing=()
RUN="/usr/bin/blackboxV"
SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"

for dep in "${deps[@]}"; do
    if ! whereis -b "$dep" | grep -q '/'; then
        missing+=("$dep")
    fi
done

if ! fc-list | grep -qi "Nerd Font"; then
    missing+=("nerd-fonts-inter")
fi

install() {
if [ ${#missing[@]} -ne 0 ]; then
    echo -e "${RED}Dependencies missing:${NC} ${missing[*]}"
    exit 1
fi
if [ -f "/usr/share/xsessions/blackbox.desktop" ]; then
  sudo cp "$SCRIPT_DIR/blackboxV" /usr/bin/
  sudo chmod a+x $RUN
  sudo sed -i "s|^Exec=.*|Exec=$RUN|" /usr/share/xsessions/blackbox.desktop
else
  echo "/usr/share/xsessions/blackbox.desktop : Not found!"
  exit 1
fi

sudo cp "$SCRIPT_DIR/rofi_menu.desktop" "/usr/share/applications"
sudo chmod a+x "/usr/share/applications/rofi_menu.desktop"
cp "$SCRIPT_DIR/blackboxrc" "$HOME/.blackboxrc"
rm -rf "$HOME/.blackbox"
cp -r "$SCRIPT_DIR/.blackbox" "$HOME/.blackbox"
chmod a+x $HOME/.blackbox/Scripts/*.sh
echo "done"
}
uninstall(){
  sudo sed -i "s|^Exec=.*|Exec=/usr/bin/blackbox|" /usr/share/xsessions/blackbox.desktop
  sudo rm -f $RUN
  sudo rm -f /usr/share/applications/rofi_menu.desktop
  rm -f $HOME/.blackboxrc
  rm -rf $HOME/.blackbox
  echo "done"
}
if [ "$1" == "install" ]; then
    install
elif [ "$1" == "uninstall" ]; then
    uninstall
else
    echo -e "${RED} Options $0 {install|uninstall}${NC}"
    exit 1
fi
