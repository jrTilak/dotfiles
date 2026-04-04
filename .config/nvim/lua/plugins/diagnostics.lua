return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      vim.diagnostic.config({
        virtual_text = false,
        float = { border = "rounded" },
      })

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        callback = function()
          vim.diagnostic.open_float(nil, { focus = false })
        end,
      })
    end,
  },
}
