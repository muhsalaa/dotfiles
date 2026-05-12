return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",

  lazy = false,

  keys = {
    {
      "\\",
      ":Neotree toggle<CR>",
      desc = "Toggle NeoTree",
    },
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,

      enable_git_status = true,
      enable_diagnostics = true,

      filesystem = {
        use_libuv_file_watcher = true,

        follow_current_file = {
          enabled = true,
        },

        filtered_items = {
          hide_dotfiles = false,
        },
      },

      window = {
        width = 30,

        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
    })

    -- Neo-tree transparent background
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "NONE" })

    -- make split dividers white
    vim.api.nvim_set_hl(0, "WinSeparator", {
      fg = "#ffffff",
      bg = "NONE",
    })
  end,
} 
-- return {
--     "nvim-neo-tree/neo-tree.nvim",
--     branch = "v3.x",
--     keys = {
--       {
--         "\\",
--         ":Neotree toggle<CR>",
--         desc = "Toggle NeoTree",
--       },
--     },
--     dependencies = {
--       "nvim-lua/plenary.nvim",
--       "MunifTanjim/nui.nvim",
--       "nvim-tree/nvim-web-devicons", -- optional, but recommended
--     },
--     lazy = false, -- neo-tree will lazily load itself
-- }
