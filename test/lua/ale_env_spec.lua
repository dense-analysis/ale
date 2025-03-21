local eq = assert.are.same
local ale = require("ale")

describe("ale.env", function()
    local is_win32 = false

    setup(function()
        _G.vim = {
            o = setmetatable({}, {
                __index = function(_, key)
                    if key == "shell" then
                        if is_win32 then
                            return "cmd.exe"
                        end

                        return "bash"
                    end

                    return nil
                end
            }),
            fn = {
                has = function(feature)
                    return feature == "win32" and is_win32
                end,
                -- Mock a very poor version of shellescape() for Unix
                -- This shouldn't be called for Windows
                shellescape = function(str)
                    return "'" .. str .. "'"
                end,
                fnamemodify = function(shell, _)
                    return shell
                end
            }
        }
    end)

    teardown(function()
        _G.vim = nil
    end)

    before_each(function()
        is_win32 = false
    end)

    it("should escape values correctly on Unix", function()
        eq("name='xxx' ", ale.env('name', 'xxx'))
        eq("name='foo bar' ", ale.env('name', 'foo bar'))
    end)

    it("should escape values correctly on Windows", function()
        is_win32 = true
        eq('set name=xxx && ', ale.env('name', 'xxx'))
        eq('set "name=foo bar" && ', ale.env('name', 'foo bar'))
    end)
end)
