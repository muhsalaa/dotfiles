return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
      -- Pale pink visual mode highlight for dark mode
      vim.api.nvim_set_hl(0, "Visual", { bg = "#45303a" })

      -- CMP documentation popup — non-transparent bg so Tailwind CSS docs are readable
      vim.api.nvim_set_hl(0, "CmpDocNormal", { bg = "#1e2030", fg = "#c0caf5" })
      vim.api.nvim_set_hl(0, "CmpDocBorder", { bg = "#1e2030", fg = "#f72585" })

      -- Global floating window borders — fuchsia everywhere
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#f72585" })
    end,
}
--   {
-- 	"shaunsingh/nord.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 	-- Example config in lua
-- 	vim.g.nord_contrast = true
-- 	vim.g.nord_borders = false
-- 	vim.g.nord_disable_background = false
-- 	vim.g.nord_italic = false
-- 	vim.g.nord_uniform_diff_background = true
-- 	vim.g.nord_bold = false
--
-- 	-- Load the colorscheme
-- 	require('nord').set()
-- end
--   }
