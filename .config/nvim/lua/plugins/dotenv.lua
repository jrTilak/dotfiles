return {
  "LazyVim/LazyVim",
  opts = function()
    vim.filetype.add({
      pattern = {
        ["%.env"] = "dotenv",
        ["%.env%.[%w_.-]+"] = "dotenv",
      },
    })
  end,
}
