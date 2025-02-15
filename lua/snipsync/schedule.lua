local commands = require("snipsync.commands")
local config = require("snipsync.config")

return {
    setup = function()
        if config.api_key_is_valid() and config.get().schedule_min > 0 then
            local timer = vim.loop.new_timer()
            local ms = config.get().schedule_min * 60 * 1000
            timer:start(0, ms, vim.schedule_wrap(commands.download(false)))
        end
    end,
}
