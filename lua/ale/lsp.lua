local module = {}

module.start = function(config)
    -- Neovim's luaeval sometimes adds a Boolean key to table we need to remove.
    if type(config.init_options) == "table"
    and config.init_options[true] ~= nil
    then
        config.init_options[true] = nil
    end

    -- If configuring LSP via a socket connection, then generate the cmd
    -- using vim.lsp.rpc.connect(), as defined in Neovim documentation.
    if config.host then
        local cmd_func = vim.lsp.rpc.connect(config.host, config.port)
        config.host = nil
        config.port = nil

        -- Wrap the cmd function so we don't throw errors back to the user
        -- if the connection to an address fails to start.
        --
        -- We will separately log in ALE that we failed to start a connection.
        --
        -- In older Neovim versions TCP connections do not function if supplied
        -- a hostname instead of an address.
        config.cmd = function(dispatch)
            local success, result = pcall(cmd_func, dispatch)

            if success then
                return result
            end

            return nil
        end
    end

    config.handlers = {
        -- Override Neovim's handling of diagnostics to run through ALE's
        -- functions so all of the functionality in ALE works.
        ["textDocument/publishDiagnostics"] = function(err, result, _, _)
            if err == nil then
                vim.fn["ale#lsp_linter#HandleLSPDiagnostics"](
                    config.name,
                    result.uri,
                    result.diagnostics
                )
            end
        end,
        -- Handle pull model diagnostic data.
        ["textDocument/diagnostic"] = function(err, result, request, _)
            if err == nil then
                local diagnostics

                if result.kind == "unchanged" then
                    diagnostics = "unchanged"
                else
                    diagnostics = result.items
                end

                vim.fn["ale#lsp_linter#HandleLSPDiagnostics"](
                    config.name,
                    request.params.textDocument.uri,
                    diagnostics
                )
            end
        end,
        -- When the pull model is enabled we have to handle and return
        -- some kind of data for a server diagnostic refresh request.
        ["workspace/diagnostic/refresh"] = function()
            return {}
        end,
    }

    config.on_init = function(client, _)
        -- Tell ALE about server capabilities as soon as we can.
        -- This will inform ALE commands what can be done with each server,
        -- such as "go to definition" support, etc.
        vim.fn["ale#lsp#UpdateCapabilities"](
            config.name,
            client.server_capabilities
        )

        -- Neovim calls `on_init` before marking a client as active, meaning
        -- we can't get a client via get_client_by_id until after `on_init` is
        -- called. By deferring execution of calling the init callbacks we
        -- can only call them after the client becomes available, which
        -- will make notifications for configuration changes work, etc.
        vim.defer_fn(function()
            vim.fn["ale#lsp#CallInitCallbacks"](config.name)
        end, 0)
    end

    config.get_language_id = function(bufnr, _)
        return vim.fn["ale#lsp#GetLanguage"](config.name, bufnr)
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- Language servers like Pyright do not enable the diagnostics pull model
    -- unless dynamicRegistration is enabled for diagnostics.
    if capabilities.textDocument.diagnostic ~= nil then
        capabilities.textDocument.diagnostic.dynamicRegistration = true
        config.capabilities = capabilities
    end

    ---@diagnostic disable-next-line: missing-fields
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

    if client == nil then
        return 0
    end

    if args.is_notification then
        -- For notifications we send a request and expect no direct response.
        local success = client.notify(args.method, args.params)

        if success then
            return -1
        end

        return 0
    end

    local success, request_id

    -- For request we send a request and handle the response.
    --
    -- We set the bufnr to -1 to prevent Neovim from flushing anything, as ALE
    -- already flushes changes to files before sending requests.
    success, request_id = client.request(
        args.method,
        args.params,
        ---@diagnostic disable-next-line: param-type-mismatch
        function(_, result, _, _)
            vim.fn["ale#lsp#HandleResponse"](client.name, {
                id = request_id,
                result = result,
            })
        end,
        ---@diagnostic disable-next-line: param-type-mismatch
        -1
    )

    if success then
        return request_id
    end

    return 0
end

return module
