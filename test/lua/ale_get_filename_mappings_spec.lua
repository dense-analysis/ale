local eq = assert.are.same
local ale = require("ale")

describe("ale.get_filename_mappings", function()
    local buffer_map

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
            },
            g = {
            },
        }
    end)

    teardown(function()
        _G.vim = nil
    end)

    before_each(function()
        buffer_map = {[42] = {}}
        _G.vim.g = {}
    end)

    it("should return the correct mappings for given linters/fixers", function()
        vim.g.ale_filename_mappings = {
            a = {{"foo", "bar"}},
            b = {{"baz", "foo"}},
        }

        eq({{"foo", "bar"}}, ale.get_filename_mappings(42, "a"))
        eq({{"baz", "foo"}}, ale.get_filename_mappings(42, "b"))
        eq({}, ale.get_filename_mappings(42, "c"))

        buffer_map[42].ale_filename_mappings = {b = {{"abc", "xyz"}}}

        eq({}, ale.get_filename_mappings(42, "a"))
        eq({{"abc", "xyz"}}, ale.get_filename_mappings(42, "b"))
        eq({}, ale.get_filename_mappings(42, "c"))
    end)

    it("should return arrays set for use with all tools", function()
        vim.g.ale_filename_mappings = {{"foo", "bar"}}

        eq({{"foo", "bar"}}, ale.get_filename_mappings(42, "a"))
        eq({{"foo", "bar"}}, ale.get_filename_mappings(42, ""))

        buffer_map[42].ale_filename_mappings = {{"abc", "xyz"}}

        eq({{"abc", "xyz"}}, ale.get_filename_mappings(42, "a"))
        eq({{"abc", "xyz"}}, ale.get_filename_mappings(42, ""))
    end)

    it("should let you use * as a fallback", function()
        vim.g.ale_filename_mappings = {
            a = {{"foo", "bar"}},
            ["*"] = {{"abc", "xyz"}},
        }

        eq({{"foo", "bar"}}, ale.get_filename_mappings(42, "a"))
        eq({{"abc", "xyz"}}, ale.get_filename_mappings(42, "b"))
        eq({{"abc", "xyz"}}, ale.get_filename_mappings(42, ""))
    end)
end)
