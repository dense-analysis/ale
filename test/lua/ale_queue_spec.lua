local eq = assert.are.same
local ale = require("ale")

describe("ale.queue", function()
    local queue_calls

    setup(function()
        _G.vim = {
            fn = {
                ["ale#Queue"] = function(...)
                    table.insert(queue_calls, {...})
                end,
            },
        }
    end)

    teardown(function()
        _G.vim = nil
    end)

    before_each(function()
        queue_calls = {}
    end)

    it("should call ale#Queue with the right arguments", function()
        ale.queue(0)
        ale.queue(0, "")
        ale.queue(123, "lint_file")
        ale.queue(0, "", 42)
        ale.queue(123, "lint_file", 42)

        eq({
            {0, nil, nil},
            {0, "", nil},
            {123, "lint_file", nil},
            {0, "", 42},
            {123, "lint_file", 42},
        }, queue_calls)
    end)
end)
