-- My toolchain: oxlint + oxfmt wherever their configs exist, Biome wherever a biome.json
-- exists, one vtsls per git root so it uses the workspace TypeScript. Binaries come from
-- the nearest node_modules/.bin, never from Mason.

-- Nearest node_modules/.bin/<name> at or above `from` (Bun hoists to the workspace root).
local function node_bin(from, name)
	for dir in vim.fs.parents(from .. "/.") do
		local bin = dir .. "/node_modules/.bin/" .. name
		if vim.fn.executable(bin) == 1 then
			return bin
		end
	end
	return name
end

local script_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact", "astro" }

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				vtsls = {
					root_markers = { ".git" },
					settings = { vtsls = { autoUseWorkspaceTsdk = true } },
				},
				biome = {
					mason = false,
					-- lspconfig roots Biome at the lock file; this repo keeps biome.json per app.
					root_dir = function(bufnr, on_dir)
						local root = vim.fs.root(bufnr, { "biome.json", "biome.jsonc" })
						if root then
							on_dir(root)
						end
					end,
					cmd = function(dispatchers, config)
						return vim.lsp.rpc.start(
							{ node_bin(config.root_dir, "biome"), "lsp-proxy" },
							dispatchers,
							{ cwd = config.root_dir }
						)
					end,
				},
				oxlint = {
					mason = false,
					filetypes = script_fts,
					root_markers = { ".oxlintrc.json" },
					cmd = function(dispatchers, config)
						return vim.lsp.rpc.start(
							{ node_bin(config.root_dir, "oxlint"), "--lsp" },
							dispatchers,
							{ cwd = config.root_dir }
						)
					end,
				},
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			local util = require("conform.util")
			local function formatter(bufnr)
				if vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }) then
					return { "biome" }
				end
				return { "oxfmt" }
			end
			opts.formatters = opts.formatters or {}
			opts.formatters.oxfmt = {
				command = util.from_node_modules("oxfmt"),
				args = { "--stdin-filepath", "$FILENAME" },
				stdin = true,
				cwd = util.root_file({ ".oxfmtrc.json" }),
			}
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc" }) do
				opts.formatters_by_ft[ft] = formatter
			end
		end,
	},
}
