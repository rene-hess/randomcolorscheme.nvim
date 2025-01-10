# randomcolorscheme.nvim 🎨

Load a random colorscheme. You can provide a list of colorschemes to restrict the selection to this
list. Otherwise a random colorscheme from all available colorschemes is loaded.

## Installation

Below is an example configuration using `lazy.nvim`. In this example we set a list of colorschemes
and load a random colorscheme of this list on startup. If you don't call `setup(opts)` the plugin
loads a random scheme from all available schemes.

```lua
  {
    'rene-hess/randomcolorscheme.nvim',
    lazy = false,
    priority = 1000,
    dependencies = {
      'rebelot/kanagawa.nvim',
      'folke/tokyonight.nvim',
    },
    config = function()
      local rc = require 'randomcolorscheme'

      local opts = {
        schemes = {
          'kanagawa-wave',
          'tokyodark',
        },
      }
      rc.setup(opts)

      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          rc.load()
        end,
      })
    end,
  },
```

