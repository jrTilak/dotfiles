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
      mini_icons.get = function(category, name, ...)
        if category == "file" then
          -- vite.config.*
          if name:match("^vite%.config%.") then
            return "\u{e8d7}", "MiniIconsYellow", false
          end

          -- babel.config.*
          if name:match("^babel%.config%.") then
            return "\u{e639}", "MiniIconsYellow", false
          end

          -- .env.*
          if name:match("^%.env%.") then
            return "\u{f292}", "MiniIconsGreen", false
          end

          -- LISCENSE
          if name:match("^LICEN[SC]E") then
            return "\u{f0219}", "MiniIconsYellow", false
          end

          -- *.spec.*
          if name:match("%.test%.") or name:match("%.spec%.") then
            return "\u{f0668}", "MiniIconsYellow", false
          end
        end
        return original_get(category, name, ...)
      end
    end,
    opts = {
      directory = {
        [".git"] = { glyph = "", hl = "MiniIconsOrange" },

        ["android"] = { glyph = "\u{e70e}", hl = "MiniIconsGreen" },

        ["config"] = { glyph = "\u{e5fc}", hl = "MiniIconsBlue" },
        ["configs"] = { glyph = "\u{e5fc}", hl = "MiniIconsBlue" },

        ["const"] = { glyph = "\u{f0ae7}", hl = "MiniIconsPurple" },
        ["constant"] = { glyph = "\u{f0ae7}", hl = "MiniIconsPurple" },
        ["constants"] = { glyph = "\u{f0ae7}", hl = "MiniIconsPurple" },

        ["context"] = { glyph = "\u{f162a}", hl = "MiniIconsPurple" },
        ["contexts"] = { glyph = "\u{f162a}", hl = "MiniIconsPurple" },

        ["database"] = { glyph = "\u{f1c0}", hl = "MiniIconsOrange" },
        ["db"] = { glyph = "\u{f1c0}", hl = "MiniIconsOrange" },

        ["hooks"] = { glyph = "\u{f06e2}", hl = "MiniIconsAzure" },

        ["lib"] = { glyph = "\u{f487}", hl = "MiniIconsBlue" },
        ["libs"] = { glyph = "\u{f487}", hl = "MiniIconsBlue" },
        ["util"] = { glyph = "\u{f487}", hl = "MiniIconsBlue" },
        ["utils"] = { glyph = "\u{f487}", hl = "MiniIconsBlue" },

        ["node_modules"] = { glyph = "\u{e5fa}", hl = "MiniIconsGreen" },

        ["screen"] = { glyph = "\u{f0e51}", hl = "MiniIconsCyan" },
        ["screens"] = { glyph = "\u{f0e51}", hl = "MiniIconsCyan" },

        ["store"] = { glyph = "\u{f162a}", hl = "MiniIconsPurple" },
        ["stores"] = { glyph = "\u{f162a}", hl = "MiniIconsPurple" },

        ["type"] = { glyph = "\u{f06e6}", hl = "MiniIconsAzure" },
        ["types"] = { glyph = "\u{f06e6}", hl = "MiniIconsAzure" },
      },
      file = {
        ["bun.lock"] = { glyph = "\u{e76f}", hl = "MiniIconsYellow" },
      },
    },
  },
}
