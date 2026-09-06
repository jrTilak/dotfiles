# shellcheck disable=SC1090

# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Load ble.sh at the TOP of .bashrc
[[ $- == *i* ]] && source /usr/share/blesh/ble.sh --noattach

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

# Organized configs
source ~/.config/bash/aliases.sh
source ~/.config/bash/env.sh
source ~/.config/bash/fns.sh
source ~/.config/bash/glow-ac.sh

# Attach ble.sh at the VERY BOTTOM of .bashrc
[[ ${BLE_VERSION-} ]] && ble-attach

# pnpm
export PNPM_HOME="/home/jrtilak/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

. "$HOME/.cargo/env"
