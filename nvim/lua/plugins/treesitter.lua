return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "master",
    lazy = false,
    config = function()
	local configs = require("nvim-treesitter.configs")
	configs.setup({
	    highlight = {
		enable = true,
	    },
	    indent = { enable = true },
	    autotage = { enable = true },
	    ensure_installed = {
		"lua",
		"c",
		"tsx",
		"typescript",
		"rust",
		"java",
		"python",
		"markdown",
		"query",
	    },
	    auto_install = false,
	})
    end
}
