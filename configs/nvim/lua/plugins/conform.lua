return {
  "stevearc/conform.nvim",

  event = { "BufWritePre" },

  cmd = { "ConformInfo" },

  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({
          async = true,
          lsp_format = "fallback",
        })
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
  },

  opts = {
    ----------------------------------------------------------------
    -- Formatter definitions
    ----------------------------------------------------------------

    formatters = {
      oxfmt = {
        command = "oxfmt",
        args = { "--stdin-filepath", "$FILENAME" },
      },
    },

    ----------------------------------------------------------------
    -- Format on save
    ----------------------------------------------------------------

    format_on_save = function(bufnr)

      -- disable autoformat for some filetypes if needed
      local ignore_filetypes = {}

      if ignore_filetypes[vim.bo[bufnr].filetype] then
        return
      end

      -- trim trailing whitespace before formatting
      vim.cmd([[%s/\s\+$//e]])

      return {
        timeout_ms = 2000,
        lsp_format = "fallback",
      }
    end,

    ----------------------------------------------------------------
    -- Formatters by filetype
    ----------------------------------------------------------------

    formatters_by_ft = {

      --------------------------------------------------------------
      -- JS / TS / React
      --------------------------------------------------------------

      javascript = { "oxfmt" },
      javascriptreact = { "oxfmt" },

      typescript = { "oxfmt" },
      typescriptreact = { "oxfmt" },

      json = { "oxfmt" },
      jsonc = { "oxfmt" },

      css = { "oxfmt" },
      scss = { "oxfmt" },

      html = { "oxfmt" },
      markdown = { "oxfmt" },

      --------------------------------------------------------------
      -- Rust
      --------------------------------------------------------------

      rust = { "rustfmt" },

      --------------------------------------------------------------
      -- Go
      --------------------------------------------------------------

      go = { "gofumpt", "goimports" },

      --------------------------------------------------------------
      -- Lua
      --------------------------------------------------------------

      lua = { "stylua" },

      --------------------------------------------------------------
      -- Shell
      --------------------------------------------------------------

      sh = { "shfmt" },
      bash = { "shfmt" },

      --------------------------------------------------------------
      -- TOML
      --------------------------------------------------------------

      --------------------------------------------------------------
      -- Python
      --------------------------------------------------------------

      python = { "ruff_format", "ruff_fix" },

      toml = { "taplo" },
    },
  },
}
