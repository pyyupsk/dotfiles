-- save on focus loss
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
	group = vim.api.nvim_create_augroup("autosave", { clear = true }),
	callback = function()
		if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
			vim.cmd("silent! write")
		end
	end,
})
