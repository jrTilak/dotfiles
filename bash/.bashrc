# shellcheck disable=SC1090

# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

source ~/.config/bash/aliases.sh

source ~/.config/bash/env.sh

source ~/.config/bash/fns.sh
