#!/usr/bin/env bash
# One JSON line for the hub's Machine card:
#   {"cpu":12,"mem":41,"temp":52,"disk":63,"uptime":"3h 12m"}
# cpu is busy time over a 0.4 s window; temp is k10temp's Tctl.
read -r _ a b c d e f g _ < /proc/stat
sleep 0.4
read -r _ A B C D E F G _ < /proc/stat
busy=$(( (A+B+C+F+G) - (a+b+c+f+g) )); idle=$(( (D+E) - (d+e) ))
cpu=$(( (busy + idle) > 0 ? 100 * busy / (busy + idle) : 0 ))
mem=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d", 100*(t-a)/t}' /proc/meminfo)
temp=0
for h in /sys/class/hwmon/hwmon*; do
    [[ $(cat "$h/name" 2>/dev/null) == k10temp ]] && temp=$(( $(cat "$h/temp1_input") / 1000 )) && break
done
disk=$(df --output=pcent / | tail -1 | tr -dc '0-9')
up=$(awk '{s=int($1); d=int(s/86400); h=int(s%86400/3600); m=int(s%3600/60);
    if (d) printf "%dd %dh", d, h; else if (h) printf "%dh %dm", h, m; else printf "%dm", m}' /proc/uptime)
printf '{"cpu":%d,"mem":%d,"temp":%d,"disk":%d,"uptime":"%s"}\n' "$cpu" "$mem" "$temp" "$disk" "$up"
