#!/usr/bin/env bash
# Install the pinned remapper and this Stow package without changing Omarchy files.
set -euo pipefail
dotfiles_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
download_dir="$(mktemp -d)"
trap 'rm -rf -- "$download_dir"' EXIT
[[ "$(uname -m)" == x86_64 ]] || { echo 'This installer currently supports x86_64 Linux.' >&2; exit 1; }
curl --fail --location --retry 3 \
  https://github.com/jtroo/kanata/releases/download/v1.12.0/linux-binaries-x64.zip \
  --output "$download_dir/kanata.zip"
printf '%s  %s\n' 0bedd91567c5d7c54679061baadc37e4f83fb71750003999bc1d11f2c9754f36 "$download_dir/kanata.zip" | sha256sum --check
unzip -q "$download_dir/kanata.zip" -d "$download_dir"
mkdir -p "$HOME/.local/bin"
install -m 755 "$download_dir/kanata_linux_x64" "$HOME/.local/bin/kanata"
stow --dir="$dotfiles_dir" --target="$HOME" --restow hypr keyboard

# This is our own additive rule, copied from the tracked source. Packaged rules
# remain untouched. uaccess grants the active desktop user keyboard/uinput access.
elevate=(sudo)
if [[ ! -t 0 ]]; then elevate=(pkexec); fi
"${elevate[@]}" install -m 644 "$dotfiles_dir/keyboard/.config/jrtilak-layout/70-jrtilak-layout.rules" /etc/udev/rules.d/70-jrtilak-layout.rules
"${elevate[@]}" udevadm control --reload-rules
"${elevate[@]}" udevadm trigger --subsystem-match=input --action=change
"${elevate[@]}" udevadm trigger --subsystem-match=misc --sysname-match=uinput --action=change
systemctl --user daemon-reload
systemctl --user enable jrtilak-layout.service
"$HOME/.local/bin/jrtilak-layout" apply
