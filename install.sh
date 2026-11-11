#!/bin/sh
# Symlink dotfiles into place. Safe to re-run.
#   sh install.sh        install
#   sh install.sh -n     dry run (show what would happen)
# Anything already at a target that isn't our symlink is moved to <target>.pre-dotfiles.
# ~/.zshrc is NOT managed here: each machine keeps its own and sources zshrc.common.

DOT="$(cd "$(dirname "$0")" && pwd)"
DRY=0; [ "$1" = "-n" ] && DRY=1

link() { # link <repo-relative source> <absolute target>
  src="$DOT/$1"; dst="$2"
  if [ ! -e "$src" ]; then echo "MISSING  $1"; return; fi
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then echo "ok       $dst"; return; fi
  if [ "$DRY" = 1 ]; then echo "would link $dst -> $src"; return; fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.pre-dotfiles" && echo "backup   $dst -> $dst.pre-dotfiles"
  fi
  ln -s "$src" "$dst" && echo "linked   $dst -> $src"
}

# Shared
link tmux.conf  "$HOME/.tmux.conf"
link p10k.zsh   "$HOME/.p10k.zsh"
link gitconfig  "$HOME/.gitconfig"
link bin/tmux-stats "$HOME/.local/bin/tmux-stats"

case "$(uname -s)" in
  Darwin)
    link ghostty/config       "$HOME/.config/ghostty/config"
    ;;
  Linux)
    link lazygit/config.vm.yml "$HOME/.config/lazygit/config.yml"
    ;;
  *) echo "Unknown OS $(uname -s): only shared files linked" ;;
esac

grep -qs "$DOT/zshrc.common\|dotfiles/zshrc.common" "$HOME/.zshrc" \
  || echo "note: ~/.zshrc doesn't source zshrc.common (add: source $DOT/zshrc.common)"
