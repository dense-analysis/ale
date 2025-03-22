local eq = assert.are.same
local ale = require("ale")

describe("ale.has", function()
    setup(function()
        _G.vim = {
            fn = {
                ["ale#Has"] = function(feature)
                    if feature == "ale-4.0.0" then
                        return 1
                    end

                    return 0
                end,
            },
        }
    end)

    teardown(function()
        _G.vim = nil
    end)

    it("should return valuse from ale#Has correctly", function()
        eq(true, ale.has("ale-4.0.0"))
        eq(false, ale.has("ale-20.0.0"))
    end)
end)
