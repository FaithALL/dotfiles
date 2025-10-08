-- neovim lsp
-- MacPath: ${HOME}/.config/nvim/lua/plugins/lsp.lua
-- LinuxPath: ${HOME}/.config/nvim/lua/plugins/lsp.lua

return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            vim.lsp.set_log_level(vim.log.levels.OFF)
            vim.lsp.inlay_hint.enable(true, nil)

            vim.diagnostic.config({
                virtual_text = false,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.INFO] = "",
                        [vim.diagnostic.severity.HINT] = "",
                    },
                    numhl = {
                        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
                        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
                    },
                },
            })

            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover, {
                    max_width = math.floor(vim.api.nvim_win_get_width(0) * 0.5),
                    max_height = math.floor(vim.api.nvim_win_get_height(0) * 0.8),
                    focusable = false,
                }
            )

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
                callback = function(args)
                    local opts = { buffer = args.buf }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "gc", vim.lsp.buf.incoming_calls, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set({ "n", "v" }, "<leader>qf", function()
                        vim.lsp.buf.code_action({ apply = true })
                    end, opts)
                    vim.keymap.set({ "n", "v" }, "<leader>fo", function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client.name == "clangd" then
                        vim.keymap.set("n", "<leader>sw", function()
                            local params = { uri = vim.uri_from_bufnr(0) }
                            vim.lsp.buf_request(0, 'textDocument/switchSourceHeader', params, function(err, result)
                                if err then
                                    vim.notify('Error switching source/header: ' .. err.message, vim.log.levels.ERROR)
                                    return
                                end
                                if not result then
                                    vim.notify('Corresponding file cannot be determined', vim.log.levels.WARN)
                                    return
                                end
                                vim.cmd.edit(vim.uri_to_fname(result))
                            end)
                        end, opts)
                    end


                    vim.api.nvim_buf_create_user_command(args.buf, "DiagnosticList", vim.diagnostic.setloclist, {})
                    vim.api.nvim_create_autocmd("DiagnosticChanged", {
                        buffer = args.buf,
                        callback = function()
                            vim.diagnostic.setloclist({ open = false, })
                        end,
                    })

                    vim.api.nvim_create_autocmd("CursorHold", {
                        buffer = args.buf,
                        callback = function()

                            -- 如果当前buffer有其他浮动窗口, 不再打开诊断浮动窗口
                            for _, winnr in ipairs(vim.api.nvim_list_wins()) do
                                local win_config = vim.api.nvim_win_get_config(winnr)
                                if win_config.relative ~= "" then
                                    return
                                end
                            end

                            vim.diagnostic.open_float({
                                focusable = false,
                                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                                scope = "line",
                            })
                        end
                    })
                end,
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            vim.lsp.enable("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=llvm",
                },
                capabilities = capabilities,
            })

            local servers = { "cmake", "dartls", "pyright", "jsonls", "lemminx" }

            for _, server in ipairs(servers) do
                vim.lsp.enable(server, {
                    capabilities = capabilities,
                })
            end
        end,
    },
}
