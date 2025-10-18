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

local function get_buffer_dir()
  local buffer_path, err = get_buffer_path()
  if err then
    return nil, err
  end

  return vim.fs.dirname(buffer_path) .. '/', nil
end

local function in_git_repo()
  local cmd = { 'git', 'rev-parse', '--is-inside-work-tree' }
  local opts = { stdout = false, stderr = false }
  local result = vim.system(cmd, opts):wait()
  return result.code == 0
end

local function get_git_root()
  local cmd = { 'git', 'rev-parse', '--show-toplevel' }
  local opts = { text = true }
  local result = vim.system(cmd, opts):wait()

  if result.code ~= 0 then
    return nil, 'Failed to resolve git root'
  end

  local stdout = (result.stdout or ''):gsub('\n$', '')

  return vim.trim(stdout), nil
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

--- @class Opts
--- @field relative 'git' | 'cwd'

--- @return Opts
local function default_opts()
  return { relative = in_git_repo() and 'git' or 'cwd' }
end

--- @param opts Opts? Optionally configure relative root, defaults to git root if there is one.
function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', default_opts(), opts or {})
end

local function ensure_opts()
  if not M.opts then
    M.setup()
  end
end

function M.copy_path_absolute()
  local buffer_path, err = get_buffer_path()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  copy_context(buffer_path, get_selection_range())
end

function M.copy_dir_absolute()
  local buffer_dir, err = get_buffer_dir()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  copy_context(buffer_dir, nil, nil)
end

function M.copy_path_relative()
  ensure_opts()

  local buffer_path, err = get_buffer_path()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local relative_buffer_path = ''

  if M.opts.relative == 'git' and in_git_repo() then
    local git_root, err = get_git_root()
    if err then
      vim.notify(err, vim.log.levels.WARN)
      return
    end

    ---@cast buffer_path string
    relative_buffer_path = vim.fn.fnamemodify(buffer_path, ':s?' .. git_root .. '/??')
  else
    ---@cast buffer_path string
    relative_buffer_path = vim.fn.fnamemodify(buffer_path, ':.')
  end

  copy_context(relative_buffer_path, get_selection_range())
end

function M.copy_dir_relative()
  ensure_opts()

  local buffer_dir, err = get_buffer_dir()
  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local relative_buffer_dir = ''

  if M.opts.relative == 'git' and in_git_repo() then
    local git_root, err = get_git_root()
    if err then
      vim.notify(err, vim.log.levels.WARN)
      return
    end

    ---@cast buffer_dir string
    relative_buffer_dir = vim.fn.fnamemodify(buffer_dir, ':s?' .. git_root .. '/??')
  else
    ---@cast buffer_dir string
    relative_buffer_dir = vim.fn.fnamemodify(buffer_dir, ':.')
  end

  copy_context(relative_buffer_dir, get_selection_range())
end
return M
