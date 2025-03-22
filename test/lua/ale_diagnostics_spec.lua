local eq = assert.are.same
local diagnostics

describe("ale.diagnostics.send", function()
    local buffer_map
    local signs_config
    local diagnostic_set_calls

    setup(function()
        _G.vim = {
            api = {
                nvim_buf_get_var = function(buffer, key)
                    local buffer_table = buffer_map[buffer] or {}
                    local value = buffer_table[key]

                    if value == nil then
                        error(key .. " is missing")
                    end

                    return value
                end,
                nvim_create_namespace = function()
                    return 42
                end,
            },
            diagnostic = {
                severity = {ERROR = 1, WARN = 2, INFO = 3},
                config = function()
                    return {signs = signs_config}
                end,
                set = function(namespace, bufnr, _diagnostics, opts)
                    table.insert(diagnostic_set_calls, {
                        namespace = namespace,
                        bufnr = bufnr,
                        diagnostics = _diagnostics,
                        opts = opts,
                    })
                end,
            },
            tbl_extend = function(behavior, ...)
                assert(behavior == "force", "We should only use `force`")

                local merged = {}

                for _, arg in ipairs({...}) do
                    for key, value in pairs(arg) do
                        merged[key] = value
                    end
                end

                return merged
            end,
            g = {},
        }

        diagnostics = require("ale.diagnostics")
    end)

    teardown(function()
        _G.vim = nil
    end)

    before_each(function()
        buffer_map = {}
        diagnostic_set_calls = {}
        signs_config = false
        _G.vim.g = {}
    end)

    it("should set an empty list of diagnostics correctly", function()
        diagnostics.send(7, {})

        eq(
            {
                {
                    namespace = 42,
                    bufnr = 7,
                    diagnostics = {},
                    opts = {virtual_text = false}
                },
            },
            diagnostic_set_calls
        )
    end)

    it("should handle basic case with all fields", function()
        diagnostics.send(1, {
            {
                bufnr = 1,
                lnum = 2,
                end_lnum = 3,
                col = 4,
                end_col = 5,
                type = "W",
                code = "123",
                text = "Warning message",
                linter_name = "eslint",
            },
        })
        eq({
            {
                lnum = 1,
                end_lnum = 2,
                col = 3,
                end_col = 5,
                severity = vim.diagnostic.severity.WARN,
                code = "123",
                message = "Warning message",
                source = "eslint",
            },
        }, diagnostic_set_calls[1].diagnostics)
    end)

    it("should default end_lnum to lnum when missing", function()
        diagnostics.send(1, {
            {
                bufnr = 1,
                lnum = 5,
                col = 2,
                end_col = 8,
                type = "E",
                text = "Error message",
                linter_name = "mylinter",
            },
        })
        eq({
            {
                lnum = 4,
                end_lnum = 4,
                col = 1,
                end_col = 8,
                severity = vim.diagnostic.severity.ERROR,
                code = nil,
                message = "Error message",
                source = "mylinter",
            },
        }, diagnostic_set_calls[1].diagnostics)
    end)

    it("should default col to 0 when missing", function()
        diagnostics.send(1, {
            {
                bufnr = 1,
                lnum = 10,
                end_lnum = 12,
                end_col = 6,
                type = "I",
                text = "Info message",
            },
        })
        eq({
            {
                lnum = 9,
                end_lnum = 11,
                col = 0,
                end_col = 6,
                severity = vim.diagnostic.severity.INFO,
                code = nil,
                message = "Info message",
                source = nil,
            },
        }, diagnostic_set_calls[1].diagnostics)
    end)

    it("should ignore non-matching buffers", function()
        diagnostics.send(1, {
            {
                bufnr = 2,
                lnum = 1,
                end_lnum = 2,
                col = 1,
                end_col = 4,
                type = "W",
                text = "Message",
            },
        })
        eq({}, diagnostic_set_calls[1].diagnostics)
    end)

    for _, set_signs_value in ipairs {1, true} do
        describe("signs with setting set_signs = " .. tostring(set_signs_value), function()
            before_each(function()
                _G.vim.g.ale_set_signs = set_signs_value
                _G.vim.g.ale_sign_priority = 10
            end)

            it("and global config as `false` should enable signs with the given priority", function()
                diagnostics.send(7, {})
                eq({priority = 10}, diagnostic_set_calls[1].opts.signs)
            end)

            it("and global config as a table should enable signs with the given priority", function()
                signs_config = {foo = "bar", priority = 5}
                diagnostics.send(7, {})
                eq(
                    {foo = "bar", priority = 10},
                    diagnostic_set_calls[1].opts.signs
                )
            end)

            it("and global config as a function should enable signs with the given priority", function()
                signs_config = function()
                    return {foo = "bar", priority = 5}
                end
                diagnostics.send(7, {})

                local local_signs = diagnostic_set_calls[1].opts.signs

                eq("function", type(local_signs))
                eq({foo = "bar", priority = 10}, local_signs())
            end)
        end)
    end

    it("should toggle virtual_text correctly", function()
        for _, value in ipairs({"all", "2", 2, "current", "1", 1, true}) do
            diagnostic_set_calls = {}
            _G.vim.g.ale_virtualtext_cursor = value
            diagnostics.send(7, {})

            eq({virtual_text = true}, diagnostic_set_calls[1].opts)
        end

        for _, value in ipairs({"disabled", "0", 0, false, nil}) do
            diagnostic_set_calls = {}
            _G.vim.g.ale_virtualtext_cursor = value
            diagnostics.send(7, {})

            eq({virtual_text = false}, diagnostic_set_calls[1].opts)
        end
    end)
end)
