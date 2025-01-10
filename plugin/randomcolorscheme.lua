vim.api.nvim_create_user_command("RandomColorscheme", function()
  require("randomcolorscheme").load()
end, {})
