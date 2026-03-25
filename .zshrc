# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========================
# Core: Oh My Zsh
# =========================
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git                  
  zsh-autosuggestions  
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"


# =========================
# History (better defaults)
# =========================
HISTSIZE=10000          # in-memory history
SAVEHIST=10000          # saved to disk
HISTFILE=~/.zsh_history

setopt share_history   # share history across terminals
setopt hist_ignore_dups
setopt hist_ignore_space


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# =========================
# Android SDK
# =========================
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/build-tools/36.0.0"
export PATH="$PATH:$ANDROID_HOME/emulator"


# =========================
# Flutter
# =========================
export PATH="$HOME/develop/flutter/bin:$PATH"


# =========================
# Aliases (from bash)
# =========================
alias py="python3"
alias python="python3"

alias t="tmux"
alias n="nvim"


# =========================
# Completion & UX tweaks
# =========================
autoload -Uz compinit
compinit

setopt auto_cd          # cd without typing 'cd'
setopt correct          # minor typo correction
setopt interactivecomments  # allow comments in shell


# =========================
# Editor preference
# =========================
export EDITOR="nvim"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/Applications/weylus:$PATH"


# bun completions
[ -s "/home/jrtilak/.bun/_bun" ] && source "/home/jrtilak/.bun/_bun"
export QT_QPA_PLATFORM=xcb
alias dot='git --git-dir=$HOME/dotfiles.git --work-tree=$HOME'
