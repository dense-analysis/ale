local module = {}

vim.lsp.set_log_level("debug")

module.start = function(config)
    -- Neovim's luaeval sometimes adds a Boolean key to table we need to remove.
    if config.init_options[true] ~= nil then
        config.init_options[true] = nil
    end

    config.on_init = function(_, _)
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
