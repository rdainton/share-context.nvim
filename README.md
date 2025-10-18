# share-context.nvim

A plugin for sharing context with teammates, notes, or a CLI AI tool.

**File path functions** (`copy_path_*`):
- With no visual selection: copies `@path/to/file.lua`
- With a single-line visual selection: copies `@path/to/file.lua#L12`
- With a multi-line visual selection: copies `@path/to/file.lua#L42-45`

**Directory path functions** (`copy_dir_*`):
- Always copy just the directory: `@path/to/directory`

## Installation & Usage

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'rdainton/share-context.nvim',
  config = function()
    local share_context = require 'share-context'

    -- Optional: Configure relative path behavior
    -- share_context.setup({
    --   relative = 'git'  -- 'git' or 'cwd' (default: auto-detects git repo)
    -- })

    -- Keybindings for file paths
    vim.keymap.set({ 'n', 'i', 'v' }, '<leader>cp', share_context.copy_path_relative, { desc = '[C]opy file [P]ath (relative)' })
    vim.keymap.set({ 'n', 'i', 'v' }, '<leader>cP', share_context.copy_path_absolute, { desc = '[C]opy file [P]ath (absolute)' })

    -- Keybindings for directory paths
    vim.keymap.set({ 'n', 'i', 'v' }, '<leader>cd', share_context.copy_dir_relative, { desc = '[C]opy [D]irectory (relative)' })
    vim.keymap.set({ 'n', 'i', 'v' }, '<leader>cD', share_context.copy_dir_absolute, { desc = '[C]opy [D]irectory (absolute)' })
  end,
}
```

**Functions:**
- `copy_path_relative()` - File path relative to configured root (defaults to git root if in repo, otherwise cwd)
- `copy_path_absolute()` - File path with full system path
- `copy_dir_relative()` - Directory path relative to configured root
- `copy_dir_absolute()` - Directory path with full system path

**Configuration:**
- `setup({ relative = 'git' | 'cwd' })` - Optional configuration to set relative path behavior
- Default: Automatically uses `'git'` if in a git repository, otherwise `'cwd'`

## Requirements

- Neovim >= v0.10
- Clipboard support (see `:checkhealth` if you encounter issues)
