# Utilities
# =========================
# Add directory to PATH
# =========================
toPath() {
  local dir="$1"
  if [[ -d $dir ]]; then
    # Only prepend if not already in PATH
    if [[ ":$PATH:" != *":$dir:"* ]]; then
      PATH="$dir:$PATH"
      export PATH
    fi
  else
    echo "Warning: directory does not exist: $dir" >&2
  fi
}

## START FROM HERE

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


plugins=(
  git                  
  zsh-autosuggestions  
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# =========================
# Completion & UX tweaks
# =========================
autoload -Uz compinit
compinit

setopt auto_cd          # cd without typing 'cd'
setopt correct          # minor typo correction
setopt interactivecomments  # allow comments in shell

setopt share_history   # share history across terminals
setopt hist_ignore_dups
setopt hist_ignore_space

# =========================
# Editor preference
# =========================
export EDITOR="nvim"


# =========================
# History (better defaults)
# =========================
HISTSIZE=10000          # in-memory history
SAVEHIST=10000          # saved to disk
HISTFILE=~/.zsh_history

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

export BUN_INSTALL="$HOME/.bun"
toPath "$BUN_INSTALL/bin"


# =========================
# Android SDK
# =========================
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

toPath "$ANDROID_HOME/cmdline-tools/latest/bin"
toPath "$ANDROID_HOME/platform-tools"
toPath "$ANDROID_HOME/build-tools/36.0.0"
toPath "$ANDROID_HOME/emulator"


# =========================
# Flutter
# =========================
toPath "$HOME/develop/flutter/bin"


toPath "$HOME/.local/bin"
toPath "$HOME/.cargo/bin"
toPath "$HOME/Applications/weylus"


# bun completions
[ -s "/home/jrtilak/.bun/_bun" ] && source "/home/jrtilak/.bun/_bun"
export QT_QPA_PLATFORM=xcb


# =========================
# Aliases
# =========================
alias py="python3"
alias python="python3"

alias t="tmux"
alias n="nvim"

alias dot='git --git-dir=$HOME/dotfiles.git --work-tree=$HOME'


