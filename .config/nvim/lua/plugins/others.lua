-- neovim 待验证插件
-- MacPath: ${HOME}/.config/nvim/lua/plugins/others.lua
-- LinuxPath: ${HOME}/.config/nvim/lua/plugins/others.lua

return {
    {
        "echasnovski/mini.bufremove",
        keys = {
            {
                "<leader>bd",
                 function()
                    local bd = require("mini.bufremove").delete
                    if vim.bo.modified then
                        local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
                        if choice == 1 then -- Yes
                            vim.cmd.write()
                            bd(0)
                        elseif choice == 2 then -- No
                            bd(0, true)
                        end
                    else
                        bd(0)
                    end
                 end,
                desc = "Delete Buffer",
            }
        },
    },
    {
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        opts = {},
    },
    {
        "HiPhish/rainbow-delimiters.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        enabled = false,
        opts = {
        },
    },
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        enabled = false,
        config = function()
            require("illuminate").configure({
                delay = 200,
            })
        end,
    },
}
