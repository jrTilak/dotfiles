return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      default_component_configs = {
        icon = {
          provider = function(icon, node)
            if node.type == "directory" then
              local mini_icons = require("mini.icons")
              local glyph, hl = mini_icons.get("directory", node.name)
              icon.text = glyph or icon.text
              icon.highlight = hl or icon.highlight
              return icon
            end

            if node.type == "file" or node.type == "terminal" then
              local ok, web_devicons = pcall(require, "nvim-web-devicons")
              local name = node.type == "terminal" and "terminal" or node.name
              if ok then
                local devicon, hl = web_devicons.get_icon(name)
                icon.text = devicon or icon.text
                icon.highlight = hl or icon.highlight
              end
            end
          end,
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = false,
          always_show_by_pattern = {
            ".env*",
          },
        },
      },
    },
  },
}
