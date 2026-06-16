# shellcheck disable=SC1090

# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Load ble.sh at the TOP of .bashrc
[[ $- == *i* ]] && source /usr/share/blesh/ble.sh --noattach

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Organized configs
source ~/.config/bash/aliases.sh
source ~/.config/bash/env.sh
source ~/.config/bash/fns.sh

# Attach ble.sh at the VERY BOTTOM of .bashrc
[[ ${BLE_VERSION-} ]] && ble-attach

