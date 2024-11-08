return {
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    build = ":ToggleTerm",
    keys = { { "<leader>tf", "<cmd>ToggleTerm<cr>", desc = "Toggle floating terminal" } },
    opts = {
      open_mapping = [[<F4>]],
      direction = "float",
      shade_filetypes = {},
      hide_numbers = true,
      insert_mappings = true,
      terminal_mappings = true,
      start_in_insert = true,
      close_on_exit = true,
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>t", group = "toggleterm" },
      },
    },
  },
}
