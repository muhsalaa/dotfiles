-- Miscellaneous plugins that don't need verbose settings
return {
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},

		-- trigger: press <leader>? to see all keymaps
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Show keymaps (which-key)",
			},
		},
	},
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	{
		"m4xshen/autoclose.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"windwp/nvim-ts-autotag",
		event = "VeryLazy",
		opts = {},
	},
}
