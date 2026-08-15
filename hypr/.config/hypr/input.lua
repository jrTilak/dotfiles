-- Personal input overrides.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
    input = {
        kb_layout = "us",
        kb_options = "compose:caps",

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
