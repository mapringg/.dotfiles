return {
  "sourcegraph/amp.nvim",
  branch = "main",
  lazy = false,
  config = function()
    require("amp").setup({ auto_start = true, log_level = "info" })

    vim.api.nvim_create_user_command("AmpSend", function(opts)
      local message = opts.args
      if message == "" then
        print("Please provide a message to send")
        return
      end
      require("amp.message").send_message(message)
    end, {
      nargs = "*",
      desc = "Send a message to Amp",
    })

    vim.api.nvim_create_user_command("AmpSendBuffer", function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      require("amp.message").send_message(table.concat(lines, "\n"))
    end, {
      desc = "Send current buffer contents to Amp",
    })

    vim.api.nvim_create_user_command("AmpPromptSelection", function(opts)
      local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
      require("amp.message").send_to_prompt(table.concat(lines, "\n"))
    end, {
      range = true,
      desc = "Add selected text to Amp prompt",
    })

    vim.api.nvim_create_user_command("AmpPromptRef", function(opts)
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname == "" then
        print("Current buffer has no filename")
        return
      end
      local ref = "@" .. vim.fn.fnamemodify(bufname, ":.")
      if opts.line1 ~= opts.line2 then
        ref = ref .. "#L" .. opts.line1 .. "-" .. opts.line2
      elseif opts.line1 > 1 then
        ref = ref .. "#L" .. opts.line1
      end
      require("amp.message").send_to_prompt(ref)
    end, {
      range = true,
      desc = "Add file reference (with selection) to Amp prompt",
    })

    require("which-key").add({
      { "<leader>a", group = "amp", icon = "󰚩", mode = "v" },
      { "<leader>as", ":AmpPromptSelection<cr>", desc = "Add selection", icon = "󰚩", mode = "v" },
      { "<leader>ar", ":AmpPromptRef<cr>", desc = "Add reference", icon = "󰚩", mode = "v" },
    })
  end,
}
