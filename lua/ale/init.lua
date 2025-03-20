local ale = {}

local global_settings = setmetatable({}, {
    __index = function (_, key)
        return vim.g['ale_' .. key]
    end,
    __newindex = function (_, key, value)
        vim.g['ale_' .. key] = value
    end
})

local buffer_settings = setmetatable({}, {
    __index = function (_, key)
        return vim.b['ale_' .. key]
    end,
    __newindex = function (_, key, value)
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

ale.setup = setmetatable({
  global = function(c)
    ale.set_global(c)
  end,
  buffer = function(c)
    ale.set_buffer(c)
  end,
}, {
  __call = function(self, c)
    self.global(c)
  end,
})

return ale
