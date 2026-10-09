return {
  {
    "cavanaug/render-markdown-mermaid.nvim",
    ft = { "markdown", "mdx" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    opts = {
      mode = "unicode",
      auto_setup_render_markdown = false,
    },
  },
}
