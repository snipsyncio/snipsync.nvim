local M = {}

local config = {
    base_url = "https://app.snipsync.io",
    api_key = vim.env.SNIPSYNC_API_KEY,
    schedule_min = 5,
}

M.setup = function(opts)
    for key, value in pairs(opts) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
end

M.get = function()
    return config
end

M.api_key_is_valid = function()
    local api_key = M.get().api_key
    return api_key and type(api_key) == "string" and string.len(api_key) == 55
end

return M
