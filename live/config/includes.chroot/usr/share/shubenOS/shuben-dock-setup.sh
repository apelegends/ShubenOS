#!/bin/sh
# Configure the Plank dock once per user: bounce-on-launch (built in) + zoom on hover
M="$HOME/.config/shuben/.dock-configured"
[ -f "$M" ] && exit 0
mkdir -p "$(dirname "$M")"
P=/net/launchpad/plank/docks/dock1
dconf write $P/zoom-enabled true
dconf write $P/zoom-percent 160
dconf write $P/icon-size 48
dconf write $P/theme "'Transparent'"
dconf write $P/dock-items "['shuben-install.dockitem','firefox-esr.dockitem','thunar.dockitem','xfce4-terminal.dockitem','lutris.dockitem','pavucontrol.dockitem','settings.dockitem']"
touch "$M"
