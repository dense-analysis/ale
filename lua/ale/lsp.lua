local module = {}

module.start = function(config)
    -- Neovim's luaeval sometimes adds a Boolean key to table we need to remove.
    if config.init_options[true] ~= nil then
        config.init_options[true] = nil
    end

    config.handlers = {
        -- Override Neovim's handling of diagnostics to run through ALE's
        -- functions so all of the functionality in ALE works.
        ["textDocument/publishDiagnostics"] = function(err, result, _, _)
            if err == nil then
                vim.fn["ale#lsp_linter#HandleLSPResponse"](config.name, {
                    jsonrpc = "2.0",
                    method = "textDocument/publishDiagnostics",
                    params = result
                })
            end
        end
    }

    config.on_init = function(_, _)
        -- Neovim calls `on_init` before marking a client as active, meaning
        -- we can't get a client via get_client_by_id until after `on_init` is
        -- called. By deferring execution of calling the init callbacks we
        -- can only call them after the client becomes available, which
        -- will make notifications for configuration changes work, etc.
        vim.defer_fn(function()
            vim.fn["ale#lsp#CallInitCallbacks"](config.name)
        end, 0)
    end

    return vim.lsp.start(config, {
        attach = false,
        silent = true,
    })
end

module.buf_attach = function(args)
    return vim.lsp.buf_attach_client(args.bufnr, args.client_id)
end

module.buf_detach = function(args)
    return vim.lsp.buf_detach_client(args.bufnr, args.client_id)
end

-- Send a message to an LSP server.
-- Notifications do not need to be handled.
--
-- Returns -1 when a message is sent, but no response is expected
--         0 when the message is not sent and
--         >= 1 with the message ID when a response is expected.
module.send_message = function(args)
    local client = vim.lsp.get_client_by_id(args.client_id)

    if args.is_notification then
        local success = client.notify(args.method, args.params)

        if success then
            return -1
        end

        return 0
    end

    -- NOTE: We aren't yet handling reponses to requests properly!
    -- NOTE: There is a fourth argument for a bufnr here, and it's not
    --       clear what that argument is for or why we need it.
    local success, request_id = client.request(args.method, args.params)

    if success then
        return request_id
    end

    return 0
end

return module
