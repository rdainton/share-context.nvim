# share-context.nvim

A plugin for sharing context with with teammates, notes, or a CLI AI tool.

When you call a function:
- Anywhere in a file with no visual selection: copies `@path/to/file.lua`
- With a single-line visual selection: copies `@path/to/file.lua#L12`
- With a multi-line visual selection: copies `@path/to/file.lua#L42-45`

## Installation & Usage

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'rdainton/share-context.nvim',
  config = function()
    local share_context = require 'share-context'

    -- Keybindings
    vim.keymap.set({ 'n', 'i', 'v' }, '<leader>cr', share_context.copy_context_relative, { desc = 'Copies [C]ontext [R]elative to CWD' })
    vim.keymap.set({ 'n', 'i', 'v' }, '<leader>cg', share_context.copy_context_git_relative, { desc = 'Copies [C]ontext relative to [G]it root' })
    vim.keymap.set({ 'n', 'i', 'v' }, '<leader>ca', share_context.copy_context_absolute, { desc = 'Copies [C]ontext with [A]bsolute path' })
  end,
}
```

**Functions:**
- `copy_context_relative()` - Path relative to where you opened Neovim
- `copy_context_git_relative()` - Path relative to git repository root (useful when tools run from project root)
- `copy_context_absolute()` - Full system path

## Requirements

- Neovim with clipboard support (see `:checkhealth` if you encounter issues)
