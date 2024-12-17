return {
  { "rcarriga/nvim-notify", enabled = false },
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = { event = "notify", kind = { "info", "warn" } },
          opts = { skip = true },
        },
      },
      messages = {
        enabled = false,
      },
    },
  },
}
