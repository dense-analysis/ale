local eq = assert.are.same
local lsp = require("ale.lsp")

describe("ale.lsp.send_message", function()
    local clients
    local version_minor
    local get_client_by_id_calls
    local vim_fn_calls

    setup(function()
        _G.vim = {
            version = function()
                return {minor = version_minor}
            end,
            lsp = {
                get_client_by_id = function(client_id)
                    table.insert(get_client_by_id_calls, client_id)

                    return clients[client_id]
                end,
            },
            fn = setmetatable({}, {
                __index = function(_, key)
                    return function(...)
                        table.insert(vim_fn_calls, {key, ...})

                        if key ~= "ale#lsp#HandleResponse" then
                            assert(false, "Invalid ALE function: " .. key)
                        end

                        return nil
                    end
                end,
            }),
        }
    end)

    teardown(function()
        _G.vim = nil
    end)

    before_each(function()
        clients = {}
        version_minor = 11
        get_client_by_id_calls = {}
        vim_fn_calls = {}
    end)

    it("should return 0 when a client cannot be found", function()
        eq(0, lsp.send_message({client_id = 999}))
        eq({999}, get_client_by_id_calls)
        eq({}, vim_fn_calls)
    end)

    it("should send notifications for Neovim 0.11+", function()
        local notify_calls = {}
        clients[1] = {
            notify = function(...)
                table.insert(notify_calls, {...})

                return true
            end,
        }

        eq(-1, lsp.send_message({
            client_id = 1,
            is_notification = true,
            method = "workspace/didChangeConfiguration",
            params = {settings = {python = {analysis = true}}},
        }))
        eq({1}, get_client_by_id_calls)
        eq(1, #notify_calls)
        assert.is_true(notify_calls[1][1] == clients[1])
        eq("workspace/didChangeConfiguration", notify_calls[1][2])
        eq({settings = {python = {analysis = true}}}, notify_calls[1][3])
        eq({}, vim_fn_calls)
    end)

    it("should return 0 if a notification fails for Neovim 0.11+", function()
        local notify_calls = {}

        clients[1] = {
            notify = function(...)
                table.insert(notify_calls, {...})

                return false
            end,
        }

        eq(0, lsp.send_message({
            client_id = 1,
            is_notification = true,
            method = "textDocument/didSave",
            params = {textDocument = {uri = "file://foo.py"}},
        }))
        eq({1}, get_client_by_id_calls)
        eq(1, #notify_calls)
        assert.is_true(notify_calls[1][1] == clients[1])
        eq("textDocument/didSave", notify_calls[1][2])
        eq({textDocument = {uri = "file://foo.py"}}, notify_calls[1][3])
        eq({}, vim_fn_calls)
    end)

    it("should send notifications for Neovim 0.10 and below", function()
        local notify_calls = {}

        version_minor = 10
        clients[1] = {
            notify = function(...)
                table.insert(notify_calls, {...})

                return true
            end,
        }

        eq(-1, lsp.send_message({
            client_id = 1,
            is_notification = true,
            method = "textDocument/didSave",
            params = {textDocument = {uri = "file://foo.py"}},
        }))
        eq({1}, get_client_by_id_calls)
        eq(1, #notify_calls)
        eq("textDocument/didSave", notify_calls[1][1])
        eq({textDocument = {uri = "file://foo.py"}}, notify_calls[1][2])
        eq({}, vim_fn_calls)
    end)

    it("should return 0 if a notification fails for Neovim 0.10 and below", function()
        local notify_calls = {}

        version_minor = 10
        clients[1] = {
            notify = function(...)
                table.insert(notify_calls, {...})

                return false
            end,
        }

        eq(0, lsp.send_message({
            client_id = 1,
            is_notification = true,
            method = "textDocument/didSave",
            params = {textDocument = {uri = "file://foo.py"}},
        }))
        eq({1}, get_client_by_id_calls)
        eq(1, #notify_calls)
        eq("textDocument/didSave", notify_calls[1][1])
        eq({textDocument = {uri = "file://foo.py"}}, notify_calls[1][2])
        eq({}, vim_fn_calls)
    end)

    it("should send requests and handle responses for Neovim 0.11+", function()
        local request_calls = {}
        clients[2] = {
            name = "server:/code",
            request = function(...)
                table.insert(request_calls, {...})

                return true, 347
            end,
        }

        eq(347, lsp.send_message({
            client_id = 2,
            method = "textDocument/hover",
            params = {line = 10, character = 5},
        }))
        eq({2}, get_client_by_id_calls)
        eq(1, #request_calls)
        assert.is_true(request_calls[1][1] == clients[2])
        eq("textDocument/hover", request_calls[1][2])
        eq({line = 10, character = 5}, request_calls[1][3])
        eq(-1, request_calls[1][5])
        eq("function", type(request_calls[1][4]))

        request_calls[1][4](nil, {contents = "hello"}, nil, nil)

        eq({
            {
                "ale#lsp#HandleResponse",
                "server:/code",
                {id = 347, result = {contents = "hello"}},
            },
        }, vim_fn_calls)
    end)

    it("should return 0 if a request fails for Neovim 0.11+", function()
        local request_calls = {}
        clients[2] = {
            name = "server:/code",
            request = function(...)
                table.insert(request_calls, {...})

                return false, 347
            end,
        }

        eq(0, lsp.send_message({
            client_id = 2,
            method = "textDocument/definition",
            params = {line = 10, character = 5},
        }))
        eq({2}, get_client_by_id_calls)
        eq(1, #request_calls)
        assert.is_true(request_calls[1][1] == clients[2] )
        eq("textDocument/definition", request_calls[1][2])
        eq({line = 10, character = 5}, request_calls[1][3])
        eq(-1, request_calls[1][5])
        eq("function", type(request_calls[1][4]))
        eq({}, vim_fn_calls)
    end)

    it("should send requests and handle responses for Neovim 0.10 and below", function()
        local request_calls = {}

        version_minor = 10
        clients[2] = {
            name = "server:/code",
            request = function(...)
                table.insert(request_calls, {...})

                return true, 12
            end,
        }

        eq(12, lsp.send_message({
            client_id = 2,
            method = "textDocument/hover",
            params = {line = 10, character = 5},
        }))
        eq({2}, get_client_by_id_calls)
        eq(1, #request_calls)
        eq("textDocument/hover", request_calls[1][1])
        eq({line = 10, character = 5}, request_calls[1][2])
        eq(-1, request_calls[1][4])
        eq("function", type(request_calls[1][3]))

        request_calls[1][3](nil, {contents = "legacy"}, nil, nil)

        eq({
            {
                "ale#lsp#HandleResponse",
                "server:/code",
                {id = 12, result = {contents = "legacy"}},
            },
        }, vim_fn_calls)
    end)

    it("should return 0 if a request fails for Neovim 0.10 and below", function()
        local request_calls = {}

        version_minor = 10
        clients[2] = {
            name = "server:/code",
            request = function(...)
                table.insert(request_calls, {...})

                return false, 12
            end,
        }

        eq(0, lsp.send_message({
            client_id = 2,
            method = "textDocument/hover",
            params = {line = 10, character = 5},
        }))
        eq({2}, get_client_by_id_calls)
        eq(1, #request_calls)
        eq("textDocument/hover", request_calls[1][1])
        eq({line = 10, character = 5}, request_calls[1][2])
        eq(-1, request_calls[1][4])
        eq("function", type(request_calls[1][3]))
        eq({}, vim_fn_calls)
    end)
end)
