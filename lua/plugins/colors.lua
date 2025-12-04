return {
    --[=[
    {
        "catppuccin/nvim",
        priority = 1000,
        config = function()
            require("config.colors")
        end,
    },]=]
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.cmd.colorscheme "tokyonight-night";
            vim.cmd [[
		highlight clear Folded
		highlight! link Folded Normal
		highlight clear FoldColumn
		highlight! link FoldColumn Normal
	    ]]
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            theme = "tokyonight",
            --theme = "catppuccin",
        },
    }
}
