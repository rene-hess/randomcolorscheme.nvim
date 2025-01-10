---@class randomcolorscheme.Config
---@field schemes? string[]: List of schemes to choose from

-- The default options contains all available colorschemes.
---@type randomcolorscheme.Config
local default_options = {
  schemes = vim.fn.getcompletion("", "color"),
}

local M = {}

---@type randomcolorscheme.Config
M.options = default_options

---@params opts? randomcolorscheme.Config
M.setup = function(opts)
  opts = opts or {}
  M.options = vim.tbl_deep_extend("force", {}, default_options, opts)
end

return M
