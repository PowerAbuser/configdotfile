#!/usr/bin/env python3
"""Credit one hyprlock unlock to the lock-screen XP:

    lock-xp.py LOCKED_MS UNLOCKED_MS

The XP, levels, ranks, streaks and trophies of dhrruvsharma/shell's lock
screen (desktoptheme/LockStats.qml, whose evaluate() and commit() this
follows), in ~/.cache/quickshell/lockstats.json (LOCKSTATS overrides it).
hyprlock can't say how the passcode was typed, so only what time tells is
counted: the unlock, the daily bonus, time away, the streak, and the
trophies for those. Typing speed, flawless and clutch never score. A
level-up or a new trophy gets a notification.
"""
import datetime
import json
import math
import os
import subprocess
import sys
import tempfile

PATH = os.environ.get("LOCKSTATS") or os.path.expanduser("~/.cache/quickshell/lockstats.json")

RANKS = [(1, "ROOKIE"), (3, "LOCKPICK"), (5, "KEYSMITH"), (8, "CODEBREAKER"),
         (12, "GATEKEEPER"), (16, "CIPHER KNIGHT"), (20, "VAULT WARDEN"),
         (25, "SHADOW OPERATIVE"), (30, "ARCHON"), (40, "ASCENDANT"), (50, "MYTHIC")]

# The trophies time alone can earn: id, name, test on the unlock as it ends up
TROPHIES = [
    ("player_one", "Player One", lambda p: p["unlocks"] >= 1),
    ("night_owl", "Night Owl", lambda p: p["hour"] < 5),
    ("early_bird", "Early Bird", lambda p: 5 <= p["hour"] < 7),
    ("weekend", "Weekend Warrior", lambda p: p["weekday"] >= 5),
    ("blink", "Changed My Mind", lambda p: p["away_ms"] < 10000),
    ("well_rested", "Well Rested", lambda p: p["away_ms"] >= 2 * 3600000),
    ("on_fire", "On Fire", lambda p: p["streak"] >= 7),
    ("unstoppable", "Unstoppable", lambda p: p["streak"] >= 30),
    ("centurion", "Centurion", lambda p: p["unlocks"] >= 100),
    ("gatekeeper", "Gatekeeper", lambda p: p["unlocks"] >= 1000),
    ("double_digits", "Double Digits", lambda p: p["level"] >= 10),
    ("veteran", "Veteran", lambda p: p["level"] >= 25),
    ("legend", "Legend", lambda p: p["level"] >= 50),
]

DEFAULTS = {"xp": 0, "unlocks": 0, "failedAttempts": 0, "streak": 0, "bestStreak": 0,
            "lastDay": "", "flawlessRun": 0, "bestFlawlessRun": 0, "bestKeysPerSec": 0,
            "longestAwayMs": 0, "totalAwayMs": 0, "achievements": []}


def level_for(xp):
    return max(1, math.floor((1 + math.sqrt(1 + 0.08 * max(0, xp))) / 2))


def rank_for(level):
    return [name for at, name in RANKS if level >= at][-1]


def main():
    locked_ms, unlocked_ms = int(sys.argv[1]), int(sys.argv[2])
    try:
        with open(PATH) as f:
            stats = {**DEFAULTS, **json.load(f)}
    except FileNotFoundError:
        stats = dict(DEFAULTS)
    except (OSError, ValueError) as e:
        # Never overwrite a file that's there but unreadable
        sys.exit(f"lock-xp: can't read {PATH}: {e}")

    now = datetime.datetime.fromtimestamp(unlocked_ms / 1000)
    today = now.strftime("%Y-%m-%d")
    yesterday = (now - datetime.timedelta(days=1)).strftime("%Y-%m-%d")
    away_ms = max(0, unlocked_ms - locked_ms)

    base = 20                                   # UNLOCKED
    if stats["lastDay"] != today:
        base += 25                              # DAILY BONUS
    if away_ms >= 2 * 3600000:
        base += 30                              # WELL RESTED
    elif away_ms >= 30 * 60000:
        base += 12                              # RESTED

    if stats["lastDay"] == today:
        streak = max(1, stats["streak"])
    elif stats["lastDay"] == yesterday:
        streak = stats["streak"] + 1
    else:
        streak = 1
    total = round(base * (1 + min(streak - 1, 10) * 0.05))

    level_before = level_for(stats["xp"])
    post = {"unlocks": stats["unlocks"] + 1, "level": level_for(stats["xp"] + total),
            "hour": now.hour, "weekday": now.weekday(), "away_ms": away_ms, "streak": streak}
    new = [(tid, name) for tid, name, test in TROPHIES
           if tid not in stats["achievements"] and test(post)]
    total += 40 * len(new)                      # each trophy, outside the multiplier

    stats["xp"] += total
    stats["unlocks"] += 1
    stats["streak"] = streak
    stats["bestStreak"] = max(stats["bestStreak"], streak)
    stats["lastDay"] = today
    stats["longestAwayMs"] = max(stats["longestAwayMs"], away_ms)
    stats["totalAwayMs"] += away_ms
    stats["achievements"] = stats["achievements"] + [tid for tid, _ in new]

    os.makedirs(os.path.dirname(PATH), exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(PATH), prefix=".lockstats-")
    with os.fdopen(fd, "w") as f:
        json.dump(stats, f, indent=2)
    os.replace(tmp, PATH)

    level = level_for(stats["xp"])
    lines = []
    if level > level_before:
        lines.append(f"Level {level} · {rank_for(level)}")
    lines += [f"Trophy: {name}" for _, name in new]
    if lines and not os.environ.get("LOCKSTATS_QUIET"):
        subprocess.run(["notify-send", "-a", "Lock", "-i", "trophy-gold",
                        f"+{total} XP", "\n".join(lines)], check=False)
    print(f"+{total} XP -> {stats['xp']} (level {level}, {rank_for(level)}), streak {streak}"
          + (f", trophies: {', '.join(n for _, n in new)}" if new else ""))


main()
