local clipboard_available = nil

local function has_clipboard_support()
  if clipboard_available == nil then
    clipboard_available = vim.fn.has 'clipboard' == 1
  end

  if not clipboard_available then
    vim.notify("No support for 'clipboard', see :checkhealth", vim.log.levels.WARN)
    return false
  end

  return true
end

local function get_buffer_path()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  if buffer_path == '' then
    return nil, 'No file name for current buffer.'
  end

  return buffer_path, nil
end

local function get_git_root()
  local git_root = vim.fn.system 'git rev-parse --show-toplevel'
  local has_shell_error = vim.v.shell_error ~= 0

  if has_shell_error then
    return nil, 'Failed to resolve git root'
  end

  return vim.trim(git_root), nil
end

local function get_selection_range()
  local lnum_start, lnum_end

  local mode = vim.fn.mode()
  if vim.tbl_contains({ 'v', 'V', '\22' }, mode) then
    lnum_start = vim.fn.getpos('v')[2]
    lnum_end = vim.fn.getpos('.')[2]
  end

  if lnum_start and lnum_end and lnum_end < lnum_start then
    return lnum_end, lnum_start
  end

  return lnum_start, lnum_end
end

local function format_selection_range(lnum_start, lnum_end)
  if not lnum_start or not lnum_end then
    return ''
  end

  if lnum_start == lnum_end then
    return string.format('#L%d', lnum_start)
  else
    return string.format('#L%d-%d', lnum_start, lnum_end)
  end
end

local function copy_context(buffer_path, lnum_start, lnum_end)
  if not has_clipboard_support() then
    return
  end

  local context = string.format('@%s%s ', buffer_path, format_selection_range(lnum_start, lnum_end))
  vim.fn.setreg('+', context)
  vim.notify(string.format('Context copied: %s', context), vim.log.levels.INFO)
end

local M = {}

function M.copy_context_absolute()
  local buffer_path, err = get_buffer_path()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  copy_context(buffer_path, get_selection_range())
end

function M.copy_context_relative()
  local buffer_path, err = get_buffer_path()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  ---@cast buffer_path string
  local relative_buffer_path = vim.fn.fnamemodify(buffer_path, ':.')

  copy_context(relative_buffer_path, get_selection_range())
end

function M.copy_context_git_relative()
  local buffer_path, err = get_buffer_path()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local git_root, err = get_git_root()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  ---@cast buffer_path string
  local relative_buffer_path = vim.fn.fnamemodify(buffer_path, ':s?' .. git_root .. '/??')

  copy_context(relative_buffer_path, get_selection_range())
end

return M
