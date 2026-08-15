-- Personal look-and-feel overrides.

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        layout = "dwindle",
    },

    decoration = {
        dim_inactive = true,
        dim_strength = 0.1,
        active_opacity = 0.95,

        blur = {
            enabled = true,
            size = 12,
            passes = 3,
            new_optimizations = true,
            noise = 0.1,
            special = true,
            popups = true,
            input_methods = true,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("smooth", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "smooth", style = "popin 80%" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "overshot", style = "slide" })
