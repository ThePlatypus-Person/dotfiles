vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- Copy Paste that doesn't override the Register & Clipboard Use
vim.keymap.set("n", "c", "\"_c")
vim.keymap.set("n", "<leader>y", "\"+yy")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Ctrl-d & Ctrl-u keeps cursor in the middle of the page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Search terms keeps cursor in the middle of the page
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Delete to Void
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Cool Substitution
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Move between Wrapped Lines
vim.keymap.set("n", "<Up>", "gk")
vim.keymap.set("n", "<Down>", "gj")
vim.keymap.set("v", "<Up>", "gk")
vim.keymap.set("v", "<Down>", "gj")
vim.keymap.set("i", "<Up>", "<C-o>gk")
vim.keymap.set("i", "<Down>", "<C-o>gj")

-- Show diagnostics in a floating window
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostic in floating window" })
