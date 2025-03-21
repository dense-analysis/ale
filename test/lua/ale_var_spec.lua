local eq = assert.are.same
local ale = require("ale")

describe("ale.var", function()
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
        buffer_map = {}
        _G.vim.g = {}
    end)

    it("should return nil for undefined variables", function()
        eq(nil, ale.var(1, "foo"))
    end)

    it("should return buffer-local values, if set", function()
        _G.vim.g.ale_foo = "global-value"
        buffer_map[1] = {ale_foo = "buffer-value"}

        eq("buffer-value", ale.var(1, "foo"))
    end)

    it("should return global values, if set", function()
        _G.vim.g.ale_foo = "global-value"

        eq("global-value", ale.var(1, "foo"))
    end)
end)
