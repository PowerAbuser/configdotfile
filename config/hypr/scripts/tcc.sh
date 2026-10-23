#!/usr/bin/env bash
# Waybar status readout for TUXEDO Control Center (tccd). Read-only:
# profile management belongs to the TCC GUI, which right-click opens.
#
# TCC reports powerDraw and fan speed as -1 on this machine, so watts and
# temp come from hwmon instead. hwmon numbering shifts across boots, so
# both are resolved by driver name at runtime.

set -uo pipefail

DEST=com.tuxedocomputers.tccd
OBJ=/com/tuxedocomputers/tccd

call() { busctl --json=short call "$DEST" "$OBJ" "$DEST" "$@" 2>/dev/null | jq -r '.data[0]' 2>/dev/null; }

hwmon() {
  local h
  for h in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$h/name" 2>/dev/null)" = "$1" ] && { printf '%s' "$h"; return 0; }
  done
  return 1
}

active=$(call GetActiveProfileJSON)
if [ -z "$active" ]; then
  jq -cn '{text:"󰈐 n/a", tooltip:"tccd not responding", class:"off"}'
  exit 0
fi

name=$(jq -r '.name // "?"'           <<<"$active")
fan=$(jq  -r '.fan.fanProfile // "-"' <<<"$active")
charging=$(call GetCurrentChargingProfile)

gpu=$(hwmon amdgpu)  && watts=$(awk '{printf "%.0f", $1/1000000}' "$gpu/power1_average" 2>/dev/null)
cpu=$(hwmon k10temp) && temp=$(awk  '{printf "%.0f", $1/1000}'    "$cpu/temp1_input"    2>/dev/null)

# A profile can pin scaling_max_freq below what the silicon allows (Powersave
# extreme caps at 605264 = 0.6GHz). Read it live so any capping source shows up.
hwmax=$(cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq  2>/dev/null | sort -n | tail -1)
curmax=$(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq 2>/dev/null | sort -n | tail -1)

cap=""
class="${fan,,}"
if [ -n "$hwmax" ] && [ -n "$curmax" ] && [ "$curmax" -lt "$hwmax" ]; then
  cap=$(awk -v f="$curmax" 'BEGIN{printf "%.1fGHz ", f/1000000}')
  class="capped"
fi

jq -cn \
  --arg t  "󰈐 ${cap}${watts:-?}W ${temp:-?}°C" \
  --arg tt "Profile:  ${name}
Fan:      ${fan}
Charging: ${charging:-unknown}
Package:  ${watts:-?} W
CPU temp: ${temp:-?} °C
Max clock: $(awk -v f="${curmax:-0}" 'BEGIN{printf "%.2f GHz", f/1000000}')$([ -n "$cap" ] && echo "  (CAPPED)")

Right click: open TUXEDO Control Center" \
  --arg c  "$class" \
  '{text:$t, tooltip:$tt, class:$c}'
