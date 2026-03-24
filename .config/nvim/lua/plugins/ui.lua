return {
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      -- Remove any snacks_layout_box offset to avoid blank row above explorer
      opts.options = opts.options or {}
      opts.options.offsets = vim.tbl_filter(function(offset)
        return offset.filetype ~= "snacks_layout_box"
      end, opts.options.offsets or {})
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
          },
          explorer = {
            hidden = true,
            win = {
              input = {
                title = "",
              },
            },
          },
        },
      },
    },
  },
}
