local commands = require("snipsync.commands")

return {
    setup = function()
        vim.api.nvim_create_user_command("SnipSyncCheck", commands.ping, { nargs = 0 })
        vim.api.nvim_create_user_command("SnipSyncDownload", commands.download(true), { nargs = 0 })
    end,
}
