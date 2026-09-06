export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

case ":$PATH:" in
  *":$ANDROID_HOME/platform-tools:"*) ;;
  *) PATH="$ANDROID_HOME/platform-tools:$PATH" ;;
esac

case ":$PATH:" in
  *":$ANDROID_HOME/emulator:"*) ;;
  *) PATH="$ANDROID_HOME/emulator:$PATH" ;;
esac

case ":$PATH:" in
  *":$ANDROID_HOME/cmdline-tools/latest/bin:"*) ;;
  *) PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH" ;;
esac

export PATH
