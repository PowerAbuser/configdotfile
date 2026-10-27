# Reference

<https://github.com/l6174/hyprdots>

## Layout

Managed with [GNU Stow](https://www.gnu.org/software/stow/): the live files are
symlinks into this repo, so editing a config edits the repo directly.

| Package   | Links into  | Contents                                   |
|-----------|-------------|--------------------------------------------|
| `config/` | `~/.config` | one folder per app, plus `starship.toml`   |
| `home/`   | `~`         | `.zshrc`, `.zshenv`, `.tmux.conf`, `.gitconfig`, `.bashrc`, `.profile` |

`config/.stow-local-ignore` keeps `hyprpanel` (no longer used) from being linked.

## Install on a new machine

```sh
sudo apt install stow
git clone git@github.com:PowerAbuser/configdotfile.git ~/repos/configdotfile
cd ~/repos/configdotfile
stow -t ~/.config config   # add --adopt to pull existing files into the repo first
stow -t ~ home
```

## Daily use

Edit configs where they live; changes show up in `git status` here. Commit and
push by hand. To track a new app: `mv ~/.config/<app> config/ && stow -t ~/.config config`.

Secrets stay out of the repo: machine-local shell settings go in the untracked
`~/.zshrc.local`, and `gh` (auth token) is deliberately not tracked.
