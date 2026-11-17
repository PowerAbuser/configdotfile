#!/bin/bash
# Restart the Quickshell shell (bar, hub, drawer, power menu).
# Also clears out any leftover waybar from the old setup.

pkill -x waybar
pkill -x qs
while pgrep -x qs >/dev/null; do sleep 0.1; done
setsid -f qs >/dev/null 2>&1
