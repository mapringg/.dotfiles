return {
  "nvimdev/dashboard-nvim",
  opts = function(_, opts)
    local logo = [[
__   __     ______     ______     __   __   __     __    __
/\ "-.\ \   /\  ___\   /\  __ \   /\ \ / /  /\ \   /\ "-./  \
\ \ \-.  \  \ \  __\   \ \ \/\ \  \ \ \'/   \ \ \  \ \ \-./\ \
\ \_\\"\_\  \ \_____\  \ \_____\  \ \__|    \ \_\  \ \_\ \ \_\
\/_/ \/_/   \/_____/   \/_____/   \/_/      \/_/   \/_/  \/_/
    ]]

    logo = string.rep("\n", 8) .. logo .. "\n\n"
    opts.config.header = vim.split(logo, "\n")
  end,
}
