# atuin-smart-suggest
# Ranks zsh autosuggestions by how often and how recently you ran a command,
# sourcing history from atuin. Approximates atuin's TUI smart_sort, which is
# not reachable from the CLI.

zmodload zsh/datetime
zmodload -F zsh/stat b:zstat

: ${ATUIN_SMART_SUGGEST_CACHE:=${XDG_CACHE_HOME:-$HOME/.cache}/atuin-smart-suggest/ranked}
: ${ATUIN_SMART_SUGGEST_HALFLIFE_DAYS:=30}
: ${ATUIN_SMART_SUGGEST_MAX_AGE:=300}

# Rank NUL-delimited "<epoch>\t<command>" records from stdin.
# Writes unique commands one per line, best first.
_atuin_smart_rank() {
  local now=${1:-$EPOCHSECONDS}
  gawk -v now="$now" -v halflife="${ATUIN_SMART_SUGGEST_HALFLIFE_DAYS}" '
    BEGIN { RS = "\0" }
    {
      if ($0 == "") next
      i = index($0, "\t")
      if (i == 0) next
      cmd = substr($0, i + 1)
      # A newline would split one entry across two cache lines.
      if (cmd == "" || index(cmd, "\n")) next
      ts = substr($0, 1, i - 1) + 0
      count[cmd]++
      if (ts > last[cmd]) last[cmd] = ts
    }
    END {
      for (c in count) {
        age = (now - last[c]) / 86400
        if (age < 0) age = 0
        printf "%018.6f\t%s\n", count[c] * 2 ^ (-age / halflife), c
      }
    }
  ' | sort -rn -k1,1 | cut -f2-
}

# zsh-autosuggestions strategy. Cache is pre-sorted, so the first prefix
# match is the best-ranked one.
_zsh_autosuggest_strategy_atuin_smart() {
  typeset -g suggestion=""
  local prefix=$1
  [[ -n $prefix && -r $ATUIN_SMART_SUGGEST_CACHE ]] || return 0
  suggestion=$(gawk -v p="$prefix" 'index($0, p) == 1 { print; exit }' \
    "$ATUIN_SMART_SUGGEST_CACHE" 2>/dev/null)
}

# atuin's `history list` honours filter_mode from the user's config, which is
# directory-scoped here (0 entries from an unrelated directory, 6096 globally).
# Rebuilds therefore run against a private config that forces global scope and
# disables network calls. The history database itself is unaffected by
# ATUIN_CONFIG_DIR, so this reads exactly the same history.
_atuin_smart_suggest_config_dir() {
  local dir=${ATUIN_SMART_SUGGEST_CACHE:h}/atuin-config
  if [[ ! -f $dir/config.toml ]]; then
    mkdir -p $dir || return 1
    cat > $dir/config.toml <<'TOML' || return 1
filter_mode = "global"
workspaces = false
auto_sync = false
update_check = false
TOML
  fi
  print -r -- $dir
}

# Rebuild the ranked cache from atuin's history. Written atomically so a
# concurrent lookup never sees a half-written file.
atuin-smart-suggest-rebuild() {
  local cache=$ATUIN_SMART_SUGGEST_CACHE
  local dir=${cache:h}
  [[ -d $dir ]] || mkdir -p $dir || return 1
  local tmp=${cache}.$$.tmp
  local cfg
  cfg=$(_atuin_smart_suggest_config_dir) || return 1
  if ATUIN_CONFIG_DIR=$cfg atuin history list --print0 --format $'{time}\t{command}' 2>/dev/null \
      | gawk '
          BEGIN { RS = "\0"; ORS = "\0" }
          {
            if ($0 == "") next
            i = index($0, "\t")
            if (i == 0) next
            t = substr($0, 1, i - 1)
            gsub(/[-:]/, " ", t)
            e = mktime(t)
            if (e < 0) next
            print e "\t" substr($0, i + 1)
          }
        ' \
      | _atuin_smart_rank > $tmp 2>/dev/null; [[ -s $tmp ]]; then
    command mv -f $tmp $cache
  else
    command rm -f $tmp
    return 1
  fi
}

# True when the cache is missing, empty, or older than ATUIN_SMART_SUGGEST_MAX_AGE.
_atuin_smart_suggest_is_stale() {
  local cache=$ATUIN_SMART_SUGGEST_CACHE
  [[ -s $cache ]] || return 0
  local mtime
  mtime=$(zstat +mtime $cache 2>/dev/null) || return 0
  (( EPOCHSECONDS - mtime > ATUIN_SMART_SUGGEST_MAX_AGE ))
}

# Refresh in the background so the prompt never waits on atuin.
_atuin_smart_suggest_precmd() {
  _atuin_smart_suggest_is_stale || return 0
  # Bump mtime first so other shells in the same moment do not all rebuild.
  [[ -e $ATUIN_SMART_SUGGEST_CACHE ]] && command touch $ATUIN_SMART_SUGGEST_CACHE
  ( atuin-smart-suggest-rebuild >/dev/null 2>&1 & )
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _atuin_smart_suggest_precmd
