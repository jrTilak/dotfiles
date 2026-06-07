-- ignore
if true then
  return {}
end

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = {}, -- remove all formatters for markdown
      },
    },
  },
}
