return {
  {
    "LazyVim/LazyVim",
    init = function()
      local group = vim.api.nvim_create_augroup("MpvMedia", { clear = true })

      local function open_with_mpv(args, extra_args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        if file == "" then
          return
        end

        local command = { "mpv", "--force-window=immediate" }
        vim.list_extend(command, extra_args or {})
        table.insert(command, file)

        local job = vim.fn.jobstart(command, { detach = true })
        if job <= 0 then
          vim.notify("Failed to open media with mpv", vim.log.levels.ERROR)
          return
        end

        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            vim.api.nvim_buf_delete(args.buf, { force = true })
          end
        end)
      end

      vim.api.nvim_create_autocmd("BufReadCmd", {
        group = group,
        pattern = {
          "*.avi",
          "*.flv",
          "*.m4v",
          "*.mkv",
          "*.mov",
          "*.mp4",
          "*.mpeg",
          "*.mpg",
          "*.webm",
          "*.wmv",
        },
        callback = function(args)
          open_with_mpv(args)
        end,
      })

      vim.api.nvim_create_autocmd("BufReadCmd", {
        group = group,
        pattern = {
          "*.aac",
          "*.flac",
          "*.m4a",
          "*.mp3",
          "*.ogg",
          "*.opus",
          "*.wav",
          "*.wma",
        },
        callback = function(args)
          open_with_mpv(args, { "--audio-display=embedded-first" })
        end,
      })
    end,
  },
}
