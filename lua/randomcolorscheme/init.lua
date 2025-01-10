local config = require("randomcolorscheme.config")
local loader = require("randomcolorscheme.loader")

local M = {}

M.setup = config.setup
M.load = loader.load

return M
