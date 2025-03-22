local eq = assert.are.same
local ale = require("ale")

describe("ale.escape for cmd.exe", function()
    setup(function()
        _G.vim = {
            o = {
                shell = "cmd.exe"
            },
            fn = {
                fnamemodify = function(shell, _)
                    return shell
                end
            }
        }
    end)

    teardown(function()
        _G.vim = nil
    end)

    it("should allow not escape paths without special characters", function()
        eq("C:", ale.escape("C:"))
        eq("C:\\", ale.escape("C:\\"))
        eq("python", ale.escape("python"))
        eq("C:\\foo\\bar", ale.escape("C:\\foo\\bar"))
        eq("/bar/baz", ale.escape("/bar/baz"))
        eq("nul", ale.escape("nul"))
        eq("'foo'", ale.escape("'foo'"))
    end)

    it("should escape Windows paths with spaces appropriately", function()
        eq('"C:\\foo bar\\baz"', ale.escape('C:\\foo bar\\baz'))
        eq('"^foo bar^"', ale.escape('^foo bar^'))
        eq('"&foo bar&"', ale.escape('&foo bar&'))
        eq('"|foo bar|"', ale.escape('|foo bar|'))
        eq('"<foo bar<"', ale.escape('<foo bar<'))
        eq('">foo bar>"', ale.escape('>foo bar>'))
        eq('"^foo bar^"', ale.escape('^foo bar^'))
        eq('"\'foo\' \'bar\'"', ale.escape('\'foo\' \'bar\''))
    end)

    it("should use caret escapes on special characters", function()
        eq('^^foo^^', ale.escape('^foo^'))
        eq('^&foo^&', ale.escape('&foo&'))
        eq('^|foo^|', ale.escape('|foo|'))
        eq('^<foo^<', ale.escape('<foo<'))
        eq('^>foo^>', ale.escape('>foo>'))
        eq('^^foo^^', ale.escape('^foo^'))
        eq('\'foo\'^^\'bar\'', ale.escape('\'foo\'^\'bar\''))
    end)

    it("should escape percent characters", function()
        eq('%%foo%%', ale.escape('%foo%'))
        eq('C:\foo%%\bar\baz%%', ale.escape('C:\foo%\bar\baz%'))
        eq('"C:\foo bar%%\baz%%"', ale.escape('C:\foo bar%\baz%'))
        eq('^^%%foo%%', ale.escape('^%foo%'))
        eq('"^%%foo%% %%bar%%"', ale.escape('^%foo% %bar%'))
        eq('"^%%foo%% %%bar%% """""', ale.escape('^%foo% %bar% ""'))
    end)
end)
