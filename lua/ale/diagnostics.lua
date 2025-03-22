local ale = require("ale")

local module = {}

local diagnostic_severity_map = {
    E = vim.diagnostic.severity.ERROR,
    W = vim.diagnostic.severity.WARN,
    I = vim.diagnostic.severity.INFO
}

-- A map of all possible values that we can consider virtualtext enabled for
-- from ALE's setting.
local virtualtext_enabled_set = {
    ["all"] = true,
    ["2"] = true,
    [2] = true,
    ["current"] = true,
    ["1"] = true,
    [1] = true,
    [true] = true,
}

---Send diagnostics to the Neovim diagnostics API
---@param buffer number The buffer number to retreive the variable for.
---@param loclist table The loclist array to report as diagnostics.
---@return nil
module.send = function(buffer, loclist)
    local diagnostics = {}

    -- Convert all the ALE loclist items to the shape that Neovim's diagnostic
    -- API is expecting.
    for _, location in ipairs(loclist) do
        if location.bufnr == buffer then
            table.insert(
                diagnostics,
                -- All line numbers from ALE are 1-indexed, but all line
                -- numbers in the diagnostics API are 0-indexed, so we have to
                -- subtract 1 to make this work.
                {
                    lnum = location.lnum - 1,
                    -- Ending line number, or if we don't have one, just make
                    -- it the same as the starting line number
                    end_lnum = (location.end_lnum or location.lnum) - 1,
                    -- Which column does the error start on?
                    col = math.max((location.col or 1) - 1, 0),
                    -- end_col does not appear to need 1 subtracted.
                    end_col = location.end_col,
                    -- Which severity: error, warning, or info?
                    severity = diagnostic_severity_map[location.type] or "E",
                    -- An error code
                    code = location.code,
                    -- The error message
                    message = location.text,
                    -- e.g. "rubocop"
                    source = location.linter_name,
                }
            )
        end
    end

    local set_signs = ale.var(buffer, "set_signs")
    local sign_priority = ale.var(buffer, "sign_priority")
    local signs

    if (set_signs == 1 or set_signs == true) and sign_priority then
        -- If signs are enabled, set the priority for them.
        local local_cfg = { priority = sign_priority }
        local global_cfg = vim.diagnostic.config().signs

        if type(global_cfg) == "boolean" then
            signs = local_cfg
        elseif type(global_cfg) == "table" then
            signs = vim.tbl_extend("force", global_cfg, local_cfg)
        else
            -- If a global function is defined, then define a function
            -- that calls that function when Neovim calls our function.
            signs = function(...)
                return vim.tbl_extend("force", global_cfg(...), local_cfg)
            end
        end
    end

    vim.diagnostic.set(
        vim.api.nvim_create_namespace("ale"),
        buffer,
        diagnostics,
        {
            virtual_text =
                virtualtext_enabled_set[vim.g.ale_virtualtext_cursor] ~= nil,
            signs = signs,
        }
    )
end

return module
