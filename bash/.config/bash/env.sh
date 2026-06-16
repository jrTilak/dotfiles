export ANDROID_HOME=/opt/android-sdk

export PATH=$PATH:$HOME/go/bin

export PATH="$HOME/.cache/.bun/bin:$PATH"

export PATH="$PATH:$HOME.lmstudio/bin"

# pnpm
export PNPM_HOME="/home/jrtilak/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


