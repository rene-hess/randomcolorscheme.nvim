--[[
This file was copied (and modified in here) from the nvim-telescope project.

Original source: https://github.com/nvim-telescope/telescope.nvim
File: lua/telescope/builtin/__internal.lua
Commit: a0bbec21143c7bc5f8bb02e0005fa0b982edc026 (HEAD, tag: 0.1.8, origin/0.1.x)
Original license:

MIT License

Copyright (c) 2020-2021 nvim-telescope

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local utils = require("telescope.utils")
local previewers = require("telescope.previewers")

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local config = require("randomcolorscheme.config")

-- Copied from telescope builtin
local telescope_colorscheme = function(opts)
  local before_background = vim.o.background
  local before_color = vim.api.nvim_exec2("colorscheme", { output = true }).output
  local need_restore = true

  local colors = opts.colors or { before_color }
  if not vim.tbl_contains(colors, before_color) then
    table.insert(colors, 1, before_color)
  end

  -- This is the main change: Do not add all the colorschemes. Instead we use only the schemes
  -- provided through opts.
  --
  -- colors = vim.list_extend(
  -- 	colors,
  -- 	vim.tbl_filter(function(color)
  -- 		return not vim.tbl_contains(colors, color)
  -- 	end, vim.fn.getcompletion("", "color"))
  -- )

  local previewer
  if opts.enable_preview then
    -- define previewer
    local bufnr = vim.api.nvim_get_current_buf()
    local p = vim.api.nvim_buf_get_name(bufnr)

    -- don't need previewer
    if vim.fn.buflisted(bufnr) ~= 1 then
      local deleted = false
      local function del_win(win_id)
        if win_id and vim.api.nvim_win_is_valid(win_id) then
          utils.buf_delete(vim.api.nvim_win_get_buf(win_id))
          pcall(vim.api.nvim_win_close, win_id, true)
        end
      end

      previewer = previewers.new({
        preview_fn = function(_, entry, status)
          if not deleted then
            deleted = true
            if status.layout.preview then
              del_win(status.layout.preview.winid)
              del_win(status.layout.preview.border.winid)
            end
          end
          vim.cmd.colorscheme(entry.value)
        end,
      })
    else
      -- show current buffer content in previewer
      previewer = previewers.new_buffer_previewer({
        get_buffer_by_name = function()
          return p
        end,
        define_preview = function(self, entry)
          if vim.loop.fs_stat(p) then
            conf.buffer_previewer_maker(p, self.state.bufnr, { bufname = self.state.bufname })
          else
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
          end
          vim.cmd.colorscheme(entry.value)
        end,
      })
    end
  end

  local picker = pickers.new(opts, {
    prompt_title = "Change Colorscheme",
    finder = finders.new_table({
      results = colors,
    }),
    sorter = conf.generic_sorter(opts),
    previewer = previewer,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection == nil then
          utils.__warn_no_selection("builtin.colorscheme")
          return
        end

        actions.close(prompt_bufnr)
        need_restore = false
        vim.cmd.colorscheme(selection.value)
      end)

      return true
    end,
  })

  if opts.enable_preview then
    -- rewrite picker.close_windows. restore color if needed
    local close_windows = picker.close_windows
    picker.close_windows = function(status)
      close_windows(status)
      if need_restore then
        vim.o.background = before_background
        vim.cmd.colorscheme(before_color)
      end
    end
  end

  picker:find()
end

local loader = function()
  local opts = { enable_preview = true }
  telescope_colorscheme({
    enable_preview = opts.enable_preview,
    colors = config.options.schemes,
  })
end

return loader
