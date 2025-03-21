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

return ale
