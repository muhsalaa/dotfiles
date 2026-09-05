return {
	"folke/persistence.nvim",
	lazy = false,
	opts = {
		dir = vim.fn.stdpath("data") .. "/sessions/",
	},
	config = function(_, opts)
		local group = vim.api.nvim_create_augroup("persistence_fix", { clear = true })

		local function is_neotree_buf(buf)
			if not vim.api.nvim_buf_is_valid(buf) then
				return false
			end
			local ok, ft = pcall(vim.api.nvim_get_option_value, "filetype", { buf = buf })
			local name = vim.api.nvim_buf_get_name(buf)
			return (ok and ft:find("^neo%-tree") ~= nil) or (name:find("neo-tree", 1, true) ~= nil)
		end

		-- Registered BEFORE setup(), so it runs BEFORE persistence's own
		-- VimLeavePre saver. Session file stays tree-free.
		vim.api.nvim_create_autocmd("VimLeavePre", {
			group = group,
			callback = function()
				pcall(vim.cmd, "Neotree close")
			end,
		})

		require("persistence").setup(opts)

		local fixing = false
		local function fix_after_restore()
			if fixing then
				return
			end
			fixing = true
			vim.schedule(function()
				-- Close windows showing restored tree buffers (match by
				-- filetype OR name: restored ones often have empty filetype).
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_is_valid(win) then
						local buf = vim.api.nvim_win_get_buf(win)
						if is_neotree_buf(buf) then
							pcall(vim.api.nvim_win_close, win, true)
						end
					end
				end
				-- Wipe the buffers so Neotree show can't collide (E95).
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if is_neotree_buf(buf) then
						pcall(vim.api.nvim_buf_delete, buf, { force = true })
					end
				end
				-- Drop lingering `nvim .` directory buffer.
				local displayed = {}
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_is_valid(win) then
						displayed[vim.api.nvim_win_get_buf(win)] = true
					end
				end
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(buf) and not displayed[buf] then
						local name = vim.api.nvim_buf_get_name(buf)
						if name ~= "" and vim.fn.isdirectory(name) == 1 then
							pcall(vim.api.nvim_buf_delete, buf, { force = true })
						end
					end
				end
				pcall(require("lazy").load, { plugins = { "neo-tree.nvim" } })
				pcall(vim.cmd, "Neotree show")
				vim.defer_fn(function()
					fixing = false
				end, 1000)
			end)
		end

		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "PersistenceLoadPost",
			callback = fix_after_restore,
		})

		-- Autoload on `nvim` and `nvim .`
		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			nested = true,
			callback = function()
				if vim.g.started_with_stdin then
					return
				end
				local argc = vim.fn.argc()
				if argc == 0 then
					pcall(require("persistence").load)
				elseif argc == 1 then
					local arg = vim.fn.argv(0)
					if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
						pcall(require("persistence").load)
					end
				end
			end,
		})
	end,
	keys = {
		{ "<leader>sr", function() require("persistence").load() end, desc = "[S]ession [R]estore" },
		{ "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "[S]ession [L]ast" },
		{ "<leader>sd", function() require("persistence").stop() end, desc = "[S]ession [D]on't save" },
	},
}
