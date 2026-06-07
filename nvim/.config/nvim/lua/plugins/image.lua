return {
  {
    "3rd/image.nvim",
    dependencies = { "vhyrro/luarocks.nvim" },
    config = function()
      require("image").setup({
        backend = "kitty",
        processor = "magick_cli",
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
        integrations = {},
      })

      local image = require("image")
      local svg_previews = {}

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.svg",
        callback = function(args)
          local file = vim.fn.expand("%:p")
          if file == "" or svg_previews[args.buf] then
            return
          end

          local code_win = vim.api.nvim_get_current_win()

          vim.cmd("vsplit")
          local preview_win = vim.api.nvim_get_current_win()
          local preview_buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_win_set_buf(preview_win, preview_buf)

          local wo = vim.wo[preview_win]
          wo.number = false
          wo.relativenumber = false
          wo.signcolumn = "no"
          wo.wrap = false
          wo.cursorline = false

          vim.bo[preview_buf].buftype = "nofile"
          vim.bo[preview_buf].filetype = "svg_preview"

          local ok, img = pcall(image.from_file, file, {
            window = preview_win,
            buffer = preview_buf,
            with_virtual_padding = true,
            inline = true,
          })

          if ok and img then
            img:render()
            svg_previews[args.buf] = {
              img = img,
              preview_buf = preview_buf,
              preview_win = preview_win,
            }
          end

          vim.api.nvim_set_current_win(code_win)
        end,
      })

      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.svg",
        callback = function(args)
          local entry = svg_previews[args.buf]
          if not entry then
            return
          end
          pcall(function()
            entry.img:clear()
            entry.img:render()
          end)
        end,
      })

      vim.api.nvim_create_autocmd("BufWipeout", {
        pattern = "*.svg",
        callback = function(args)
          local entry = svg_previews[args.buf]
          if not entry then
            return
          end
          pcall(function()
            entry.img:clear()
          end)
          pcall(vim.api.nvim_buf_delete, entry.preview_buf, { force = true })
          svg_previews[args.buf] = nil
        end,
      })
    end,
  },
}
