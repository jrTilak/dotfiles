-- Personal input overrides.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

-- Keep the old Compose mapping available behind a reversible flag.
-- The custom layout owns Caps, so it must also suppress Compose when enabled.
local flags = require("hypr.keyboard-flags")
local keyboard_options
if flags.disable_compose or flags.layout then
    keyboard_options = ""
else
    keyboard_options = "compose:caps"
end

hl.config({
    input = {
        kb_layout = "us",
        kb_options = keyboard_options,

        repeat_rate = 40,
        repeat_delay = 250,
        numlock_by_default = true,

        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            scroll_factor = 0.4,
            disable_while_typing = true,
        },
    },
})
