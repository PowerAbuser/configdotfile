# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
fpath=(~/.zsh/completions $fpath)

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# This makes the completion menu selectable
zstyle ':completion:*' menu select
# This allows case-insensitive matching (typing 'cd doc' matches 'Documents')
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# This colors the list
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- 3. INITIALIZE COMPLETIONS ---
autoload -Uz compinit
compinit

# --- 4. FZF TAB COMPLETION (This connects Tab to FZF) ---
# Disable standard sorting so fzf handles it
zstyle ':completion:*' sort false
# Load the plugin
zinit light Aloxaf/fzf-tab

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::ubuntu
zinit snippet OMZP::command-not-found


zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# Aliases
alias l="eza -l --color=always --group-directories-first"
alias la="eza -l -a --color=always --group-directories-first"
alias ls="eza -l -a --color=always --group-directories-first"
alias bat="batcat"
alias se="sudoedit"
alias vim="nvim"
alias ..="cd .."
# db-recover lives in ~/.zshrc.local (holds the local postgres password; kept out of the dotfiles repo)
alias db-dump="$HOME/Projects/arms_utility/create_dump.sh"
alias db-restore="$HOME/Projects/arms_utility/restore_dump.sh"

# PATH Variables
export PATH=$PATH:~/.cargo/bin
export SUDO_EDITOR=/usr/local/bin/nvim
# export PATH="/usr/bin/php81:$PATH"
export EDITOR=/usr/local/bin/nvim
export PATH="/usr/bin/unzip:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$XDG_DATA_DIRS"
export XDG_DATA_DIRS="/home/nazir-maman/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
# export PATH="~/repos/yazi/target/release/yazi:$PATH"
# export PATH="~/repos/yazi/target/release/ya:$PATH"
export ATUIN_NOBIND="true"
# export RUSTUP_UPDATE_ROOT=https://dev-static.rust-lang.org/rustup rustup self update
# export RUST_MIN_STACK=8388608
export NODE_OPTIONS="--max-old-space-size=8192"

# bun completions
[ -s "/home/nazir-maman/.bun/_bun" ] && source "/home/nazir-maman/.bun/_bun"

# bun
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"

eval "$(starship init zsh)"

source <(fzf --zsh)

eval "$(atuin init zsh)"

# Rank autosuggestions by atuin history (how often + how recently) instead of
# atuin's own recency-only strategy, which `atuin init` prepends above.
# Falls back to the stock history strategy on a cold cache or a miss.
source ~/.config/zsh/atuin-smart-suggest.zsh
ZSH_AUTOSUGGEST_STRATEGY=(atuin_smart history)
bindkey '^r' atuin-search
# bind to the up key, which depends on terminal mode
bindkey '^[[A' atuin-up-search
bindkey '^[OA' atuin-up-search

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# proto
export PROTO_HOME="$HOME/.proto";
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH";


# Added by Antigravity CLI installer
export PATH="/home/nazir-maman/.local/bin:$PATH"

# Lancia moon sempre dalla workspace root (quella con .moon/)
# Evita l'errore "Failed to read path /cwd/rust-toolchain.toml" da sottocartelle.
moon() {
  local dir="$PWD"
  while [[ "$dir" != "/" && ! -d "$dir/.moon" ]]; do
    dir="${dir:h}"
  done
  if [[ -d "$dir/.moon" ]]; then
    (cd "$dir" && command moon "$@")
  else
    command moon "$@"
  fi
}

# Machine-local / secret settings, not tracked in the dotfiles repo
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
