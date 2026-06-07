return {

  {
    "okuuva/auto-save.nvim",
    config = function()
      require("auto-save").setup({
        enabled = true,
        trigger_events = { "InsertLeave", "TextChanged" },
        condition = function(buf)
          return vim.bo[buf].modifiable and vim.bo[buf].filetype ~= "gitcommit"
        end,
      })
    end,
  },
}
