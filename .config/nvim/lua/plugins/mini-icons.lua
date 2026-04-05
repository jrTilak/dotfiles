-- nerdfonts icons code cheat-sheet
-- https://www.nerdfonts.com/cheat-sheet
return {
  "nvim-mini/mini.icons",
  opts = {
    directory = {
      [".git"] = { glyph = "\u{f1d3}", hl = "MiniIconsOrange" },
    },

    file = {
      -- vite config
      ["vite.config.js"] = { glyph = "\u{e8d7}", hl = "MiniIconsYellow" },
      ["vite.config.ts"] = { glyph = "\u{e8d7}", hl = "MiniIconsYellow" },
      ["vite.config.mjs"] = { glyph = "\u{e8d7}", hl = "MiniIconsYellow" },
      ["vite.config.mts"] = { glyph = "\u{e8d7}", hl = "MiniIconsYellow" },
      ["vite.config.cjs"] = { glyph = "\u{e8d7}", hl = "MiniIconsYellow" },

      -- LICENSE
      ["LICENSE"] = { glyph = "\u{f0219}", hl = "MiniIconsYellow" },
      ["LICENCE"] = { glyph = "\u{f0219}", hl = "MiniIconsYellow" },

      ["bun.lock"] = { glyph = "\u{e76f}", hl = "MiniIconsYellow" },
    },
  },
}
