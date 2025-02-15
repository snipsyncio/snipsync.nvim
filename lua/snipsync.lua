return {
    setup = function(opts)
        require("snipsync.config").setup(opts or {})
        require("snipsync.setup").setup()
        require("snipsync.schedule").setup()
    end,
}
