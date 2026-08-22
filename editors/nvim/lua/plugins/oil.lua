return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {},
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
  },
}
