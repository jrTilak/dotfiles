export ANDROID_HOME=/opt/android-sdk

# pnpm
export PNPM_HOME="/home/jrtilak/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

