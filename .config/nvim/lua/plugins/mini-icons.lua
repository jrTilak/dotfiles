-- nerdfonts icons code cheat-sheet
-- https://www.nerdfonts.com/cheat-sheet
return {
  {
    "nvim-mini/mini.icons",
    config = function(_, opts)
      local mini_icons = require("mini.icons")
      mini_icons.setup(opts)

      local original_get = mini_icons.get
      ---@diagnostic disable-next-line: duplicate-set-field
      mini_icons.get = function(category, name)
        if category == "file" then
          if name:match("^vite%.config%.") then
            return "\u{e8d7}", "MiniIconsYellow", false
          end
          if name:match("^LICEN[SC]E") then
            return "\u{f0219}", "MiniIconsYellow", false
          end
          if name:match("%.test%.") or name:match("%.spec%.") then
            return "\u{f0668}", "MiniIconsYellow", false
          end
        end
        return original_get(category, name)
      end
    end,
    opts = {
      directory = {
        [".git"] = { glyph = "\u{f1d3}", hl = "MiniIconsOrange" },
      },
      file = {
        ["bun.lock"] = { glyph = "\u{e76f}", hl = "MiniIconsYellow" },
      },
    },
  },
}
