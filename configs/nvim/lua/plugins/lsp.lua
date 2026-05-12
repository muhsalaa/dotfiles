return {
  "neovim/nvim-lspconfig",

  dependencies = {
    -- LSP installer
    {
      "mason-org/mason.nvim",
      config = true,
    },

    -- Bridge between mason package names and lspconfig names
    "mason-org/mason-lspconfig.nvim",

    -- Auto install tools
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    -- LSP loading/status UI
    {
      "j-hui/fidget.nvim",
      opts = {
        notification = {
          window = {
            winblend = 0,
          },
        },
      },
    },

    -- Adds completion capabilities for nvim-cmp
    "hrsh7th/cmp-nvim-lsp",
  },

  config = function()

    ----------------------------------------------------------------
    -- LSP ATTACH
    -- Runs whenever an LSP attaches to current buffer
    ----------------------------------------------------------------

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),

      callback = function(event)

        -- Helper function for cleaner keymaps
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, {
            buffer = event.buf,
            desc = "LSP: " .. desc,
          })
        end

        ----------------------------------------------------------------
        -- Navigation
        ----------------------------------------------------------------

        -- Go to definition
        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

        -- Find references
        map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

        -- Go to implementation
        map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

        -- Go to type definition
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

        ----------------------------------------------------------------
        -- Symbols
        ----------------------------------------------------------------

        -- Symbols in current file
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

        -- Symbols in whole workspace/project
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

        ----------------------------------------------------------------
        -- Refactoring
        ----------------------------------------------------------------

        -- Rename variable/function/etc
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

        -- Code actions
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

        ----------------------------------------------------------------
        -- Documentation
        ----------------------------------------------------------------

        -- Hover docs
        map("K", vim.lsp.buf.hover, "Hover Documentation")

        -- Go to declaration
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        ----------------------------------------------------------------
        -- Workspace folders
        ----------------------------------------------------------------

        map("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")

        map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")

        map("<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "[W]orkspace [L]ist Folders")

        ----------------------------------------------------------------
        -- Highlight references under cursor
        ----------------------------------------------------------------

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then

          local highlight_augroup =
            vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

          -- Highlight references
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          -- Clear highlights when cursor moves
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          -- Cleanup when LSP detaches
          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),

            callback = function(event2)
              vim.lsp.buf.clear_references()

              vim.api.nvim_clear_autocmds({
                group = "lsp-highlight",
                buffer = event2.buf,
              })
            end,
          })
        end

        ----------------------------------------------------------------
        -- Inlay hints
        ----------------------------------------------------------------

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then

          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({
                bufnr = event.buf,
              })
            )
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    ----------------------------------------------------------------
    -- CMP capabilities
    -- Enables completion support for LSP
    ----------------------------------------------------------------

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    capabilities = vim.tbl_deep_extend(
      "force",
      capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )

    ----------------------------------------------------------------
    -- LSP SERVERS
    ----------------------------------------------------------------

    local servers = {

      --------------------------------------------------------------
      -- Lua
      --------------------------------------------------------------

      lua_ls = {
        settings = {
          Lua = {

            completion = {
              callSnippet = "Replace",
            },

            runtime = {
              version = "LuaJIT",
            },

            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },

            diagnostics = {
              globals = { "vim" },
              disable = { "missing-fields" },
            },

            -- disable formatting
            -- use stylua instead
            format = {
              enable = false,
            },
          },
        },
      },

      --------------------------------------------------------------
      -- TypeScript / JavaScript / React
      --------------------------------------------------------------

      ts_ls = {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
            },
          },
        },
      },

      --------------------------------------------------------------
      -- Rust
      --------------------------------------------------------------

      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {

            cargo = {
              allFeatures = true,
            },

            checkOnSave = true,
          },
        },
      },

      --------------------------------------------------------------
      -- Go
      --------------------------------------------------------------

      gopls = {
        settings = {
          gopls = {

            analyses = {
              unusedparams = true,
            },

            staticcheck = true,
          },
        },
      },

      --------------------------------------------------------------
      -- Infra / misc
      --------------------------------------------------------------

      jsonls = {},
      yamlls = {},
      bashls = {},
      dockerls = {},
      docker_compose_language_service = {},
      html = {},
    }

    ----------------------------------------------------------------
    -- Ensure tools are installed
    ----------------------------------------------------------------

    local ensure_installed = vim.tbl_keys(servers)

    vim.list_extend(ensure_installed, {

      -- Lua formatter
      "stylua",

      -- Go formatter
      "gofumpt",
      "goimports",
    })

    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
    })

    ----------------------------------------------------------------
    -- Setup all LSP servers
    ----------------------------------------------------------------

    for server, cfg in pairs(servers) do

      -- Merge capabilities
      cfg.capabilities = vim.tbl_deep_extend(
        "force",
        {},
        capabilities,
        cfg.capabilities or {}
      )

      -- Configure server
      vim.lsp.config(server, cfg)

      -- Enable server
      vim.lsp.enable(server)
    end
  end,
}

