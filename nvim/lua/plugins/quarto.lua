return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      'jmbuhr/otter.nvim',
      'hrsh7th/nvim-cmp',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
      require("quarto").setup{
        debug = false,
        closePreviewOnExit = true,
        cell_delimiter = "```",
        lspFeatures = {
          enabled = true,
          chunks = "curly",
          languages = { "r", "python", "julia", "bash", "html", "latex", "markdown" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        otter = {
          enabled = true,
          default = "python",
          languages = { "r", "python", "julia", "bash" },
        },
        codeRunner = {
          enabled = true,
          default_method = 'molten', -- 'molten' or 'slime'
          ft_runners = {python = "molten", r = "molten"}, -- filetype to runner, ie. `{ python = "molten" }`.
          -- Takes precedence over `default_method`
          never_run = { "yaml" }, -- filetypes which are never sent to a code runner
        },
      }
    end
  }
}
