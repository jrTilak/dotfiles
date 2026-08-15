-- Personal keybinding overrides.
-- See current bindings and descriptions with: omarchy menu keybindings --print

local home = os.getenv("HOME")

-- Replace Omarchy's preinstalled web-app bindings with dedicated launchers.
hl.unbind("SUPER + SHIFT + Y")
o.bind("SUPER + SHIFT + Y", "YouTube", home .. "/.local/bin/launch-or-focus-youtube")

-- SUPER + SHIFT + G is Signal in Omarchy v4.
hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "WhatsApp", home .. "/.local/bin/launch-or-focus-whatsapp")

o.bind("SUPER + SHIFT + T", "T3 Code", home .. "/.local/bin/launch-or-focus-t3-code")
