local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("randomcolorscheme.nvim requires nvim-telescope/telescope.nvim")
end

return telescope.register_extension({
  exports = {
    loader = require("telescope._extensions.loader"),
  },
})
