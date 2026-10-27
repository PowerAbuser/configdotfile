#!/usr/bin/env zsh
# Tests for atuin-smart-suggest. Run: zsh ~/.config/zsh/atuin-smart-suggest.test.zsh
emulate -L zsh
setopt no_err_return

SUT=${0:A:h}/atuin-smart-suggest.zsh
[[ -r $SUT ]] || { print -u2 "FATAL: not found: $SUT"; exit 1 }
source $SUT

typeset -g PASS=0 FAIL=0
NOW=1000000000
DAY=86400

check() {  # check <name> <expected> <actual>
  if [[ "$2" == "$3" ]]; then
    print "  ok   $1"; (( ++PASS ))
  else
    print "  FAIL $1"
    print "         expected: ${(qq)2}"
    print "         actual:   ${(qq)3}"
    (( ++FAIL ))
  fi
}

# Build NUL-delimited "epoch<TAB>command" records.
records() { for r in "$@"; do printf '%s\0' "$r"; done }

print "_atuin_smart_rank"

# 1. more-frequent wins when recency is equal
out=$(records "$NOW	git status" "$NOW	git status" "$NOW	git status" \
              "$NOW	git stash" "$NOW	git stash" | _atuin_smart_rank $NOW)
check "ranks more-frequent first at equal age" "git status
git stash" "$out"

# 2. recency decay: 4 uses today beats 8 uses 60 days ago (8 * 2^-2 = 2 < 4)
old=$(( NOW - 60*DAY ))
out=$(records "$NOW	cargo test" "$NOW	cargo test" "$NOW	cargo test" "$NOW	cargo test" \
              "$old	cargo build" "$old	cargo build" "$old	cargo build" "$old	cargo build" \
              "$old	cargo build" "$old	cargo build" "$old	cargo build" "$old	cargo build" \
      | _atuin_smart_rank $NOW)
check "recent-but-fewer outranks old-but-more" "cargo test
cargo build" "$out"

# 3. every command appears exactly once
out=$(records "$NOW	ls" "$NOW	ls" "$NOW	ls" | _atuin_smart_rank $NOW | grep -c '^ls$')
check "dedupes repeated commands" "1" "$out"

# 4. multiline entries must not corrupt the line-based cache
out=$(records "$NOW	for i in 1 2; do
echo \$i
done" "$NOW	vim" | _atuin_smart_rank $NOW)
check "skips multiline commands" "vim" "$out"

print "_zsh_autosuggest_strategy_atuin_smart"

tmp=$(mktemp -d)
export ATUIN_SMART_SUGGEST_CACHE=$tmp/ranked
print -l "git pull" "git push" "grep -rn" > $ATUIN_SMART_SUGGEST_CACHE

# 5. returns the highest-ranked prefix match
suggestion=; _zsh_autosuggest_strategy_atuin_smart "git p"
check "returns top-ranked prefix match" "git pull" "$suggestion"

# 6. prefix-anchored, not substring
suggestion=; _zsh_autosuggest_strategy_atuin_smart "rep"
check "does not match mid-string" "" "$suggestion"

# 7. no match yields empty so the next strategy can answer
suggestion=; _zsh_autosuggest_strategy_atuin_smart "zzz"
check "empty when nothing matches" "" "$suggestion"

# 8. missing cache must not error
ATUIN_SMART_SUGGEST_CACHE=$tmp/does-not-exist
suggestion=; _zsh_autosuggest_strategy_atuin_smart "git"
check "empty when cache absent" "" "$suggestion"

# 9. regex metacharacters in the buffer are treated literally
ATUIN_SMART_SUGGEST_CACHE=$tmp/ranked
print -l 'echo $HOME' 'echo [a]' > $ATUIN_SMART_SUGGEST_CACHE
suggestion=; _zsh_autosuggest_strategy_atuin_smart 'echo ['
check "treats metacharacters literally" "echo [a]" "$suggestion"

rm -rf $tmp

print "atuin-smart-suggest-rebuild (integration: real atuin history)"

tmp=$(mktemp -d)
export ATUIN_SMART_SUGGEST_CACHE=$tmp/ranked
atuin-smart-suggest-rebuild

check "builds a non-empty cache" "yes" "$([[ -s $ATUIN_SMART_SUGGEST_CACHE ]] && echo yes || echo no)"

# 'git pull' is this history's runaway winner (29 uses, run recently).
suggestion=; _zsh_autosuggest_strategy_atuin_smart "git p"
check "ranks 'git pull' top for prefix 'git p'" "git pull" "$suggestion"

# Every cache line must be a single command, never a stray fragment.
check "cache has no empty lines" "0" "$(grep -c '^$' $ATUIN_SMART_SUGGEST_CACHE)"

# Atomic write: no leftover temp files beside the cache.
check "leaves no temp files" "0" "$(print -rl -- $tmp/*.tmp(N) | grep -c . || true)"

# atuin's own history list is cwd-filtered; the cache must be global regardless
# of where the rebuild happens to run from. Each rebuild starts from a removed
# cache so a cwd-scoped rebuild cannot pass by leaving the old cache in place.
empty_dir=$(mktemp -d)

rm -f $ATUIN_SMART_SUGGEST_CACHE
( cd ~ && atuin-smart-suggest-rebuild )
lines_from_home=$(wc -l < $ATUIN_SMART_SUGGEST_CACHE 2>/dev/null || echo 0)

rm -f $ATUIN_SMART_SUGGEST_CACHE
( cd $empty_dir && atuin-smart-suggest-rebuild )
lines_from_elsewhere=$(wc -l < $ATUIN_SMART_SUGGEST_CACHE 2>/dev/null || echo 0)

check "rebuild is not scoped to the current directory" \
  "$lines_from_home" "$lines_from_elsewhere"

suggestion=; _zsh_autosuggest_strategy_atuin_smart "git p"
check "suggests correctly after rebuilding elsewhere" "git pull" "$suggestion"
rmdir $empty_dir

rm -rf $tmp
print "_atuin_smart_suggest_is_stale"

tmp=$(mktemp -d)
export ATUIN_SMART_SUGGEST_CACHE=$tmp/ranked
export ATUIN_SMART_SUGGEST_MAX_AGE=300

# missing cache must trigger a rebuild
rm -f $ATUIN_SMART_SUGGEST_CACHE
_atuin_smart_suggest_is_stale
check "stale when cache is absent" "0" "$?"

# a cache just written is fresh
print "git pull" > $ATUIN_SMART_SUGGEST_CACHE
_atuin_smart_suggest_is_stale
check "fresh right after a rebuild" "1" "$?"

# older than max age must trigger a rebuild
touch -d "@$(( $(date +%s) - 600 ))" $ATUIN_SMART_SUGGEST_CACHE
_atuin_smart_suggest_is_stale
check "stale once older than max age" "0" "$?"

# just inside the window is still fresh
touch -d "@$(( $(date +%s) - 60 ))" $ATUIN_SMART_SUGGEST_CACHE
_atuin_smart_suggest_is_stale
check "fresh just inside the window" "1" "$?"

rm -rf $tmp
print ""
print "passed: $PASS  failed: $FAIL"
(( FAIL == 0 ))
