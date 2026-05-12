return {
  -- Statusline plugin
  "nvim-lualine/lualine.nvim",

  dependencies = {
    -- File icons
    "nvim-tree/nvim-web-devicons",
  },

  config = function()

    -- Load TokyoNight lualine theme
    local theme = require("lualine.themes.tokyonight")

    -- Make middle sections transparent
    -- (works nicely with transparent terminal + TokyoNight)
    -- theme.normal.c.bg = "NONE"
    -- theme.insert.c.bg = "NONE"
    -- theme.visual.c.bg = "NONE"
    -- theme.replace.c.bg = "NONE"
    -- theme.command.c.bg = "NONE"
    -- theme.inactive.c.bg = "NONE"
   
    -- make lualine transparent safely
    for _, mode in pairs(theme) do
      if mode.c then
        mode.c.bg = "NONE"
      end
    end
    -- Helper function:
    -- only show some statusline items if window is wide enough
    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    -- MODE section (NORMAL / INSERT / VISUAL etc)
    local mode = {
      "mode",

      -- format displayed text
      fmt = function(str)

        -- If window is large:
        -- show full mode text
        if hide_in_width() then
          return " " .. str

        -- If split window is narrow:
        -- show only first letter
        else
          return " " .. str:sub(1, 1)
        end
      end,
    }

    -- FILE NAME section
    local filename = {
      "filename",

      -- show readonly / modified indicators
      file_status = true,

      -- path options:
      -- 0 = filename only
      -- 1 = relative path
      -- 2 = absolute path
      path = 1,
    }

    -- LSP diagnostics section
    local diagnostics = {
      "diagnostics",

      -- use Neovim built-in diagnostics
      sources = { "nvim_diagnostic" },

      -- show all diagnostic types
      sections = { "error", "warn", "info", "hint" },

      -- icons
      symbols = {
        error = " ",
        warn = " ",
        info = " ",
        hint = " ",
      },

      colored = true,

      -- don't constantly update while typing
      update_in_insert = false,

      -- hide if no diagnostics
      always_visible = false,

      -- only show on wide windows
      cond = hide_in_width,
    }

    -- Git diff section
    local diff = {
      "diff",

      symbols = {
        added = " ",
        modified = " ",
        removed = " ",
      },

      -- hide in narrow splits
      cond = hide_in_width,
    }

    -- Main lualine setup
    require("lualine").setup({

      options = {

        -- use TokyoNight colors
        theme = theme,

        -- ONE global statusline for all windows
        globalstatus = true,

        icons_enabled = true,

        -- separators between sections
        -- empty = minimalist look
        section_separators = {
          left = "",
          right = "",
        },

        -- separators between components
        component_separators = {
          left = "|",
          right = "|",
        },

        -- disable statusline in these filetypes
        disabled_filetypes = {
          statusline = {
            "neo-tree",
            "alpha",
          },
        },

        always_divide_middle = true,
      },

      -- ACTIVE WINDOW SECTIONS
      sections = {

        -- left-most section
        lualine_a = {
          mode,
        },

        lualine_b = {
          "branch", -- current git branch
          diff,     -- git added/modified/removed
        },

        lualine_c = {
          filename,
        },

        lualine_x = {

          diagnostics,

          {
            "encoding",

            -- only show in wide windows
            cond = hide_in_width,
          },

          {
            "filetype",

            -- only show in wide windows
            cond = hide_in_width,
          },
        },

        lualine_y = {
          "progress", -- file progress %
        },

        lualine_z = {
          "location", -- line:column
        },
      },

      -- INACTIVE WINDOW SECTIONS
      inactive_sections = {

        lualine_a = {},
        lualine_b = {},

        lualine_c = {

          {
            "filename",

            -- relative path
            path = 1,
          },
        },

        lualine_x = {

          {
            "location",

            -- reduce padding
            padding = 0,
          },
        },

        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}

