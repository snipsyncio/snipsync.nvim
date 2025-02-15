local config = require("snipsync.config")

local api_key_invalid = function()
    if not config.api_key_is_valid() then
        vim.notify("SnipSync: invalid API key", vim.log.levels.ERROR)
        return true
    end
    return false
end

local curl = function(path, output)
    return {
        "curl", "-s",
        "-o", output,
        "-w", "%{http_code}",
        "-H", "Authorization: Bearer " .. config.get().api_key,
        config.get().base_url .. path,
    }
end

return {
    download = function(show_info)
        return function()
            if api_key_invalid() then
                return
            end

            local temp_filename = os.tmpname()
            local snippets_file = vim.fn.stdpath("config") .. "/all.code-snippets"

            local job_id = vim.fn.jobstart(curl("/api/snippets", temp_filename), {
                stdout_buffered = true,
                on_stdout = function(_, data, _)
                    local status_code = table.concat(data, "")
                    if status_code == "200" then
                        local input_file = io.open(temp_filename, "r")
                        if not input_file then
                            vim.notify("SnipSync: failed to open temporary file", vim.log.levels.ERROR)
                            return
                        end

                        local content = input_file:read("*all")
                        input_file:close()

                        local output_file = io.open(snippets_file, "w")
                        if not output_file then
                            vim.notify("SnipSync: failed to open snippets file", vim.log.levels.ERROR)
                            return
                        end

                        output_file:write(content)
                        output_file:close()

                        if show_info then
                            vim.notify("SnipSync: snippets saved to " .. snippets_file, vim.log.levels.INFO)
                        end
                    else
                        vim.notify("SnipSync: failed to download snippets, status code: " .. status_code,
                            vim.log.levels.ERROR)
                    end
                    os.remove(temp_filename)
                end,
            })
            if job_id <= 0 then
                vim.notify("SnipSync: failed to download snippets", vim.log.levels.ERROR)
            end
        end
    end,

    ping = function()
        if api_key_invalid() then
            return
        end
        local job_id = vim.fn.jobstart(curl("/api/ping", "/dev/null"), {
            stdout_buffered = true,
            on_stdout = function(_, data, _)
                local status_code = table.concat(data, "")
                if status_code == "200" then
                    vim.notify("SnipSync: successfully pinged the API", vim.log.levels.INFO)
                else
                    vim.notify("SnipSync: failed to ping the API, status code: " .. status_code, vim.log.levels.ERROR)
                end
            end,
        })
        if job_id <= 0 then
            vim.notify("SnipSync: failed to ping the API", vim.log.levels.ERROR)
        end
    end,
}
