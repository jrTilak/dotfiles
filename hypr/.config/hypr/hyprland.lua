-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Load personal overrides after the defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Keep dedicated Helium web apps on workspace 9.
o.window("^chrome-www[.]youtube[.]com__-Default$", { workspace = "9" })
o.window("^chrome-web[.]whatsapp[.]com__-Default$", { workspace = "9" })

-- Keep T3 Code on workspace 10 (Super + 0).
o.window("^t3code$", { workspace = "10" })
