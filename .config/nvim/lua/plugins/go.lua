return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      require("lint").linters.golangcilint.args = {
        "run",
        "--output.json.path=stdout",
        "--show-stats=false",
        "./...",
      }
    end,
  },
}
