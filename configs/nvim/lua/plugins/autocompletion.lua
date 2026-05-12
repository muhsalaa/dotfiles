-- Autocompletion
return {
  "hrsh7th/nvim-cmp",

  dependencies = {

    ----------------------------------------------------------------
    -- Snippet engine
    ----------------------------------------------------------------

    {
      "L3MON4D3/LuaSnip",

      version = "v2.*",

      -- Optional regex support for advanced snippets
      build = "make install_jsregexp",
    },

    ----------------------------------------------------------------
    -- Snippet completion source
    ----------------------------------------------------------------

    "saadparwaiz1/cmp_luasnip",

    ----------------------------------------------------------------
    -- Completion sources
    ----------------------------------------------------------------

    "hrsh7th/cmp-nvim-lsp", -- LSP completions
    "hrsh7th/cmp-buffer",   -- words from current buffer
    "hrsh7th/cmp-path",     -- filesystem paths

    ----------------------------------------------------------------
    -- Prebuilt snippets
    ----------------------------------------------------------------

    "rafamadriz/friendly-snippets",
  },

  config = function()

    ----------------------------------------------------------------
    -- Load plugins
    ----------------------------------------------------------------

    local cmp = require("cmp")

    local luasnip = require("luasnip")

    ----------------------------------------------------------------
    -- Load vscode-style snippets
    ----------------------------------------------------------------

    require("luasnip.loaders.from_vscode").lazy_load()

    luasnip.config.setup({})

    ----------------------------------------------------------------
    -- Completion item icons
    ----------------------------------------------------------------

    local kind_icons = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "",
      Variable = "󰀫",
      Class = "󰌗",
      Interface = "",
      Module = "",
      Property = "",
      Unit = "",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰇽",
      Struct = "",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "󰊄",
    }

    ----------------------------------------------------------------
    -- CMP setup
    ----------------------------------------------------------------

    cmp.setup({

      --------------------------------------------------------------
      -- Snippet expansion
      --------------------------------------------------------------

      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      --------------------------------------------------------------
      -- Completion behavior
      --------------------------------------------------------------

      completion = {
        completeopt = "menu,menuone,noinsert",
      },

      --------------------------------------------------------------
      -- Bordered completion/documentation windows
      --------------------------------------------------------------

      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      --------------------------------------------------------------
      -- Experimental features
      --------------------------------------------------------------

      experimental = {
        ghost_text = true,
      },

      --------------------------------------------------------------
      -- Keymaps
      --------------------------------------------------------------

      mapping = cmp.mapping.preset.insert({

        -- Select next completion item
        ["<C-j>"] = cmp.mapping.select_next_item(),

        -- Select previous completion item
        ["<C-k>"] = cmp.mapping.select_prev_item(),

        -- Confirm completion
        ["<CR>"] = cmp.mapping.confirm({
          select = true,
        }),

        -- Manually trigger completion menu
        ["<C-Space>"] = cmp.mapping.complete({}),

        ------------------------------------------------------------
        -- Snippet forward jump
        ------------------------------------------------------------

        ["<C-l>"] = cmp.mapping(function()

          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end

        end, { "i", "s" }),

        ------------------------------------------------------------
        -- Snippet backward jump
        ------------------------------------------------------------

        ["<C-h>"] = cmp.mapping(function()

          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end

        end, { "i", "s" }),

        ------------------------------------------------------------
        -- Tab completion
        ------------------------------------------------------------

        ["<Tab>"] = cmp.mapping(function(fallback)

          if cmp.visible() then
            cmp.select_next_item()

          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()

          else
            fallback()
          end

        end, { "i", "s" }),

        ------------------------------------------------------------
        -- Shift+Tab completion
        ------------------------------------------------------------

        ["<S-Tab>"] = cmp.mapping(function(fallback)

          if cmp.visible() then
            cmp.select_prev_item()

          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)

          else
            fallback()
          end

        end, { "i", "s" }),
      }),

      --------------------------------------------------------------
      -- Completion sources
      --------------------------------------------------------------

      sources = cmp.config.sources({

        -- Higher priority sources
        { name = "nvim_lsp" },
        { name = "luasnip" },

      }, {

        -- Lower priority sources
        { name = "buffer" },
        { name = "path" },
      }),

      --------------------------------------------------------------
      -- Formatting
      --------------------------------------------------------------

      formatting = {

        fields = { "kind", "abbr", "menu" },

        format = function(entry, vim_item)

          -- Add icons
          vim_item.kind = string.format(
            "%s",
            kind_icons[vim_item.kind]
          )

          -- Source labels
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
          })[entry.source.name]

          return vim_item
        end,
      },
    })
  end,
}
