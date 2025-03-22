local ale = {}

local global_settings = setmetatable({}, {
    __index = function(_, key)
        return vim.g['ale_' .. key]
    end,
    __newindex = function(_, key, value)
        vim.g['ale_' .. key] = value
    end
})

local buffer_settings = setmetatable({}, {
    __index = function(_, key)
        return vim.b['ale_' .. key]
    end,
    __newindex = function(_, key, value)
        vim.b['ale_' .. key] = value
    end
})

ale.set_global = function(c)
    for key, value in pairs(c) do
        global_settings[key] = value
    end
end

ale.set_buffer = function(c)
    for key, value in pairs(c) do
        buffer_settings[key] = value
    end
end

---(when called) Set global ALE settings, just like ale.setup.global.
---@class ALESetup
---@field global fun(c: table): nil  -- Set global ALE settings.
---@field buffer fun(c: table): nil  -- Set buffer-local ALE settings.
---@overload fun(c: table): nil
---@type ALESetup
ale.setup = setmetatable({
    ---Set global ALE settings.
    ---@param c table The table of ALE settings to set.
    ---@return nil
    global = function(c)
        ale.set_global(c)
    end,
    ---Set buffer-local ALE settings.
    ---@param c table The table of ALE settings to set.
    ---@return nil
    buffer = function(c)
        ale.set_buffer(c)
    end,
}, {
    __call = function(self, c)
        self.global(c)
    end,
})

---Run ALE linters on a buffer after a delay.
---
---If a delay in milliseconds multiple times, the internal timer used by ALE
---will be reset, so ALE doesn't lint too often.
---
---If the `linting_flag` is not 'lint_file' then linters that require files to
---be saved will no be run.
---@param delay number Milliseconds to wait for. A delay of 0 lints immediately.
---@param linting_flag string|nil If set to 'lint_file', run all linters.
---@param buffer number|nil The buffer to check. Defaults to the current buffer.
---@return nil
ale.queue = function(delay, linting_flag, buffer)
    vim.fn["ale#Queue"](delay, linting_flag, buffer)
end

---Check if ALE supports a given feature.
---
---The ALE version can be checked with ale.has("ale-1.0.0"), etc.
---@param feature string The feature to test for.
---@return boolean supported If the feature is supported.
ale.has = function(feature)
    return vim.fn["ale#Has"](feature) == 1
end

---Prefix a string with a single space if it is not empty.
---nil will be treated the same as an empty string.
---
---This function is a convenience for chaining options for commands together
---without adding redundant whitespace.
---@param str string|nil A value to pad with whitespace.
---@return string padded A value padded with whitespace.
ale.pad = function(str)
    if str == nil or str == "" then
        return ""
    end

    return " " .. str
end

---Get an ALE variable for a buffer (first) or globally (second)
---@param buffer number The buffer number to retreive the variable for.
---@param variable_name string The variable to retrieve.
---@return any value The value for the ALE variable
ale.var = function(buffer, variable_name)
    variable_name = "ale_" .. variable_name
    local exists, value = pcall(vim.api.nvim_buf_get_var, buffer, variable_name)

    if exists then
        return value
    end

    return vim.g[variable_name]
end

---Escape a string for use in a shell command
---@param str string The string to escape.
---@return string escaped The escaped string.
ale.escape = function(str)
    local shell = vim.fn.fnamemodify(vim.o.shell, ":t")

    if shell:lower() == "cmd.exe" then
        local step1

        if str:find(" ") then
            step1 = '"' .. str:gsub('"', '""') .. '"'
        else
            step1 = str:gsub("([&|<>^])", "^%1")
        end

        local percent_subbed = step1:gsub("%%", "%%%%")

        return percent_subbed
    end

    return vim.fn.shellescape(str)
end

---Create a prefix for a shell command for adding environment variables.
---@param variable_name string The environment variable name.
---@param value string The value to set for the environment variable.
---@return string prefix The shell code for prefixing a command.
ale.env = function(variable_name, value)
    if vim.fn.has("win32") then
        return "set " .. ale.escape(variable_name .. "=" .. value) .. " && "
    end

    return variable_name .. "=" .. ale.escape(value) .. " "
end

---Get an array of arrays for mapping paths to and from filesystems for an ALE
---linter, as configured in the `filename_mappings` setting.
---
---The result can be used to instruct ALE how to map between filesystems.
---@param buffer number The buffer number.
---@param name string The linter name.
---@return table mappings An array of arrays for mapping filenames.
ale.get_filename_mappings = function(buffer, name)
    local linter_mappings = ale.var(buffer, "filename_mappings")

    if linter_mappings[1] ~= nil then
        return linter_mappings
    end

    if linter_mappings[name] == nil then
        name = "*"
    end

    return linter_mappings[name] or {}
end

return ale
