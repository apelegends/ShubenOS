#!/bin/sh
# shubenOS Wi-Fi helper. The kernel auto-loads drivers for known chips; this makes sure
# radios aren't blocked and leaves a clear report if no Wi-Fi device could be brought up.
LOG=/var/log/shuben-wifi.log
exec >>"$LOG" 2>&1
echo "== $(date) =="
rfkill unblock all 2>/dev/null
sleep 3
if ls /sys/class/net 2>/dev/null | grep -q '^wl'; then
  echo "Wi-Fi interface present: $(ls /sys/class/net | grep '^wl' | tr '\n' ' ')"
else
  echo "No Wi-Fi interface found. Wireless hardware seen:"
  lspci -nn 2>/dev/null | grep -Ei 'network|wireless|802\.11'
  lsusb 2>/dev/null | grep -Ei 'wireless|wlan|802\.11|wifi|realtek|mediatek|ralink|atheros|broadcom'
  echo "Firmware shipped: iwlwifi, realtek, atheros, brcm80211, libertas, misc-nonfree (MediaTek/Ralink)."
fi
systemctl try-restart NetworkManager 2>/dev/null || true
