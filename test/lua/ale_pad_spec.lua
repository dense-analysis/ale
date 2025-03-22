local eq = assert.are.same
local ale = require("ale")

describe("ale.pad", function()
    it("should pad non-empty strings", function()
        eq(" foo", ale.pad("foo"))
    end)

    it("should return empty strings for nil or empty strings", function()
        eq("", ale.pad(nil))
        eq("", ale.pad(""))
    end)
end)
