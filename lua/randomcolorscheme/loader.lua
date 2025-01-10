local config = require("randomcolorscheme.config")

local function load()
  math.randomseed(os.time())
  local randomIndex = math.random(#config.options.schemes)
  print("Loading colorscheme: " .. config.options.schemes[randomIndex])
  vim.cmd("colorscheme " .. config.options.schemes[randomIndex])
end

local M = {}
M.load = load

return M
