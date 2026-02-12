local eq = assert.are.same
local lsp = require("ale.lsp")

describe("ale.lsp.start", function()
    local start_calls
    local rpc_connect_calls
    local vim_fn_calls
    local defer_calls
    local nvim_default_capabilities

    setup(function()
        _G.vim = {
            defer_fn = function(func, delay)
                table.insert(defer_calls, {func, delay})
            end,
            empty_dict = function()
                -- Returns a table with a metatable to distinguish it from arrays
                return setmetatable({}, {__empty_dict = true})
            end,
            fn = setmetatable({}, {
                __index = function(_, key)
                    return function(...)
                        table.insert(vim_fn_calls, {key, ...})

                        if key == "ale#lsp#GetLanguage" then
                            return "python"
                        end

                        if key ~= "ale#lsp_linter#HandleLSPDiagnostics"
                        and key ~= "ale#lsp#UpdateCapabilities"
                        and key ~= "ale#lsp#CallInitCallbacks"
                        then
                            assert(false, "Invalid ALE function: " .. key)
                        end

                        return nil
                    end
                end,
            }),
            lsp = {
                rpc = {
                    connect = function(host, port)
                        return function(dispatch)
                            table.insert(rpc_connect_calls, {
                                host = host,
                                port = port,
                                dispatch = dispatch,
                            })
                        end
                    end,
                },
                start = function(...)
                    table.insert(start_calls, {...})

                    return 42
                end,
                protocol = {
                    make_client_capabilities = function()
                        return nvim_default_capabilities
                    end,
                },
            },
        }
    end)

    teardown(function()
        _G.vim = nil
    end)

    before_each(function()
        start_calls = {}
        rpc_connect_calls = {}
        vim_fn_calls = {}
        defer_calls = {}
        nvim_default_capabilities = {
            textDocument = {},
        }
    end)

    it("should start lsp programs with the correct arguments", function()
        lsp.start({
            name = "server:/code",
            cmd = "server",
            root_dir = "/code",
            -- This Boolean value somehow ends up in Dictionaries from
            -- Vim for init_options, and we need to remove it.
            init_options = {[true] = 123},
        })

        -- Remove arguments with functions we can't apply equality checks
        -- for easily.
        for _, args in pairs(start_calls) do
            args[1].handlers = nil
            args[1].on_init = nil
            args[1].get_language_id = nil
        end

        eq({
            {
                {
                    cmd = "server",
                    name = "server:/code",
                    root_dir = "/code",
                    init_options = {},
                },
                {attach = false, silent = true}
            }
        }, start_calls)
        eq({}, vim_fn_calls)
    end)

    it("should convert empty init_options to vim.empty_dict", function()
        -- Mock vim.empty_dict
        local empty_dict_called = false
        _G.vim.empty_dict = function()
            empty_dict_called = true
            return setmetatable({}, {__empty_dict = true})
        end

        lsp.start({
            name = "gopls:/code",
            cmd = "gopls",
            root_dir = "/code",
            -- Empty table without metatable (like from VimScript {})
            init_options = {},
        })

        -- Verify that empty_dict was called
        eq(true, empty_dict_called)

        -- Verify init_options has metatable now
        eq(1, #start_calls)
        local init_opts = start_calls[1][1].init_options
        eq(true, getmetatable(init_opts) ~= nil)
    end)

    it("should preserve non-empty init_options", function()
        lsp.start({
            name = "gopls:/code",
            cmd = "gopls",
            root_dir = "/code",
            init_options = {foo = "bar", nested = {baz = 123}},
        })

        -- Remove functions we can't compare
        for _, args in pairs(start_calls) do
            args[1].handlers = nil
            args[1].on_init = nil
            args[1].get_language_id = nil
        end

        eq(1, #start_calls)
        eq({foo = "bar", nested = {baz = 123}}, start_calls[1][1].init_options)
    end)

    it("should start lsp socket connections with the correct arguments", function()
        lsp.start({
            name = "localhost:1234:/code",
            host = "localhost",
            port = 1234,
            root_dir = "/code",
            init_options = {foo = "bar"},
        })

        local cmd

        -- Remove arguments with functions we can't apply equality checks
        -- for easily.
        for _, args in pairs(start_calls) do
            cmd = args[1].cmd
            args[1].cmd = nil
            args[1].handlers = nil
            args[1].on_init = nil
            args[1].get_language_id = nil
        end

        eq({
            {
                {
                    name = "localhost:1234:/code",
                    root_dir = "/code",
                    init_options = {foo = "bar"},
                },
                {attach = false, silent = true}
            }
        }, start_calls)

        cmd("dispatch_value")

        eq({
            {dispatch = "dispatch_value", host = "localhost", port = 1234},
        }, rpc_connect_calls)
        eq({}, vim_fn_calls)
    end)

    it("should return the client_id value from vim.lsp.start", function()
        eq(42, lsp.start({}))
    end)

    it("should implement get_language_id correctly", function()
        lsp.start({name = "server:/code"})

        eq(1, #start_calls)
        eq("python", start_calls[1][1].get_language_id(347, "ftype"))
        eq({{"ale#lsp#GetLanguage", "server:/code", 347}}, vim_fn_calls)
    end)

    it("should enable dynamicRegistration for the pull model", function()
        nvim_default_capabilities = {textDocument = {diagnostic = {}}}

        lsp.start({name = "server:/code"})
        eq(1, #start_calls)

        eq(
            {
                textDocument = {
                    diagnostic = {
                        dynamicRegistration = true,
                    },
                },
            },
            start_calls[1][1].capabilities
        )
    end)

    it("should initialize clients with ALE correctly", function()
        lsp.start({name = "server:/code"})

        eq(1, #start_calls)

        start_calls[1][1].on_init({server_capabilities = {cap = 1}})

        eq({
            {"ale#lsp#UpdateCapabilities", "server:/code", {cap = 1}},
        }, vim_fn_calls)
        eq(1, #defer_calls)
        eq(2, #defer_calls[1])
        eq("function", type(defer_calls[1][1]))
        eq(0, defer_calls[1][2])

        defer_calls[1][1]()

        eq({
            {"ale#lsp#UpdateCapabilities", "server:/code", {cap = 1}},
            {"ale#lsp#CallInitCallbacks", "server:/code"},
        }, vim_fn_calls)
    end)

    it("should configure handlers correctly", function()
        lsp.start({name = "server:/code"})

        eq(1, #start_calls)

        local handlers = start_calls[1][1].handlers
        local handler_names = {}

        -- get keys from handlers
        for key, _ in pairs(handlers) do
            -- add key to handler_names mapping
            handler_names[key] = true
        end

        eq({
            ["textDocument/publishDiagnostics"] = true,
            ["textDocument/diagnostic"] = true,
            ["workspace/diagnostic/refresh"] = true,
        }, handler_names)
    end)

    it("should handle push model published diagnostics", function()
        lsp.start({name = "server:/code"})

        eq(1, #start_calls)

        local handlers = start_calls[1][1].handlers

        eq("function", type(handlers["textDocument/publishDiagnostics"]))

        handlers["textDocument/publishDiagnostics"](nil, {
            uri = "file://code/foo.py",
            diagnostics = {
                {
                    lnum = 1,
                    end_lnum = 2,
                    col = 3,
                    end_col = 5,
                    severity = 1,
                    code = "123",
                    message = "Warning message",
                }
            },
        })

        eq({
            {
                "ale#lsp_linter#HandleLSPDiagnostics",
                "server:/code",
                "file://code/foo.py",
                {
                    {
                        lnum = 1,
                        end_lnum = 2,
                        col = 3,
                        end_col = 5,
                        severity = 1,
                        code = "123",
                        message = "Warning message",
                    },
                },
            },
        }, vim_fn_calls)
    end)

    it("should respond to workspace diagnostic refresh requests", function()
        lsp.start({name = "server:/code"})

        eq(1, #start_calls)

        local handlers = start_calls[1][1].handlers

        eq("function", type(handlers["workspace/diagnostic/refresh"]))

        eq({}, handlers["workspace/diagnostic/refresh"]())
    end)

    it("should handle pull model diagnostics", function()
        lsp.start({name = "server:/code"})

        eq(1, #start_calls)

        local handlers = start_calls[1][1].handlers

        eq("function", type(handlers["textDocument/diagnostic"]))

        handlers["textDocument/diagnostic"](
            nil,
            {
                kind = "full",
                items = {
                    {
                        lnum = 1,
                        end_lnum = 2,
                        col = 3,
                        end_col = 5,
                        severity = 1,
                        code = "123",
                        message = "Warning message",
                    }
                },
            },
            {
                params = {
                    textDocument = {
                        uri = "file://code/foo.py",
                    },
                },
            }
        )

        eq({
            {
                "ale#lsp_linter#HandleLSPDiagnostics",
                "server:/code",
                "file://code/foo.py",
                {
                    {
                        lnum = 1,
                        end_lnum = 2,
                        col = 3,
                        end_col = 5,
                        severity = 1,
                        code = "123",
                        message = "Warning message",
                    },
                },
            },
        }, vim_fn_calls)
    end)

    it("should handle unchanged pull model diagnostics", function()
        lsp.start({name = "server:/code"})

        eq(1, #start_calls)

        local handlers = start_calls[1][1].handlers

        eq("function", type(handlers["textDocument/diagnostic"]))

        handlers["textDocument/diagnostic"](
            nil,
            {kind = "unchanged"},
            {
                params = {
                    textDocument = {
                        uri = "file://code/foo.py",
                    },
                },
            }
        )

        eq({
            {
                "ale#lsp_linter#HandleLSPDiagnostics",
                "server:/code",
                "file://code/foo.py",
                "unchanged",
            },
        }, vim_fn_calls)
    end)
end)
