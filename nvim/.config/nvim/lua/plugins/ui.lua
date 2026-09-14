return {
	-- no tab bar
	{ "akinsho/bufferline.nvim", enabled = false },
	-- explorer on the right, terminal at the bottom
	{
		"folke/snacks.nvim",
		opts = {
			-- bottom split, 30% of the screen
			terminal = { win = { position = "bottom", height = 0.3 } },
			picker = {
				sources = {
					explorer = { layout = { layout = { position = "right" } } },
				},
			},
		},
	},
}
