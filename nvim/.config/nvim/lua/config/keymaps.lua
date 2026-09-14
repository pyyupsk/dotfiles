-- Ctrl shortcuts. Ctrl+Shift combos need a terminal that sends them distinctly
-- (Windows Terminal does for letters, not always for Enter/Tab/slash).
local map = vim.keymap.set

local function root()
	return LazyVim.root()
end

-- Terminal
map({ "n", "t" }, "<C-t>", function() Snacks.terminal.toggle(nil, { cwd = root() }) end, { desc = "Toggle terminal" })
map({ "n", "t" }, "<C-A-t>", function() Snacks.terminal.open(nil, { cwd = root() }) end, { desc = "New terminal" })
map("t", "<C-q>", "<cmd>close<cr>", { desc = "Close terminal" })
map({ "n", "t" }, "<C-g>", "<cmd>wincmd p<cr>", { desc = "Focus editor" })

-- Comment (overrides LazyVim's <C-/> terminal binding; <C-t> covers that)
map("n", "<C-/>", "gcc", { remap = true, desc = "Comment line" })
map("v", "<C-/>", "gc", { remap = true, desc = "Comment selection" })
map("n", "<C-_>", "gcc", { remap = true, desc = "which_key_ignore" })
map("v", "<C-_>", "gc", { remap = true, desc = "which_key_ignore" })

-- Quick access
map("n", "<C-e>", function() Snacks.picker.files({ cwd = root() }) end, { desc = "Quick open" })
map("n", "<C-S-p>", function() Snacks.picker.commands() end, { desc = "Command palette" })
map("n", "<C-f>", "/", { desc = "Find" })
map({ "n", "v" }, "<C-S-f>", function() LazyVim.format({ force = true }) end, { desc = "Format document" })

-- Buffers
map("n", "<C-Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<C-S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })

-- Explorer
map("n", "<C-S-e>", function() Snacks.explorer.open({ cwd = root() }) end, { desc = "Focus explorer" })
map("n", "<C-S-b>", function() Snacks.explorer({ cwd = root() }) end, { desc = "Toggle explorer" })

-- Navigation
map("n", "<C-S-CR>", vim.lsp.buf.definition, { desc = "Go to definition" })
