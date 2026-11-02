
-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
local lualine = require 'lualine'

local fallback = {
  base00 = '#202328',
  base01 = '#2b2e34',
  base04 = '#bbc2cf',
  base05 = '#d0d0d0',
  base07 = '#ffffff',
  base08 = '#ec5f67',
  base09 = '#ECBE7B',
  base0A = '#FF8800',
  base0B = '#98be65',
  base0C = '#008080',
  base0D = '#51afef',
  base0E = '#c678dd',
  base0F = '#a9a1e1',
}

local function base(index) return vim.g['base16_gui' .. index] or fallback['base' .. index] end

-- lualine re-evaluates these on every statusline refresh
local function fg(index, gui)
  return function() return { fg = base(index), gui = gui } end
end

local colors = {
  blue = fg '0D',
  cyan = fg '0C',
  dim = fg '04',
  fg = fg('05', 'bold'),
  green = fg '0B',
  light = fg '07',
  magenta = fg '0F',
  orange = fg '09',
  red = fg '08',
  violet = fg '0E',
  yellow = fg '0A',
}

local conditions = {
  buffer_not_empty = function() return vim.fn.empty(vim.fn.expand '%:t') ~= 1 end,
  hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
  check_git_workspace = function()
    local filepath = vim.fn.expand '%:p:h'
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

local function section_color(fg_index, bg_index, gui)
  return function() return { fg = base(fg_index), bg = base(bg_index), gui = gui } end
end

local theme = {}
for _, mode in ipairs { 'normal', 'insert', 'visual', 'replace', 'command', 'terminal' } do
  theme[mode] = {
    a = section_color('05', '01', 'bold'),
    b = section_color('05', '01'),
    c = section_color('05', '01'),
  }
end
theme.inactive = {
  a = section_color('04', '01'),
  b = section_color('04', '01'),
  c = section_color('04', '01'),
}

-- Config
local config = {
  options = {
    -- Disable sections and component separators
    component_separators = '',
    section_separators = '',
    theme = theme,
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component) table.insert(config.sections.lualine_c, component) end

-- Inserts a component in lualine_x at right section
local function ins_right(component) table.insert(config.sections.lualine_x, component) end

ins_left {
  function() return '▊' end,
  color = colors.blue, -- Sets highlighting of component
  padding = { left = 0, right = 1 }, -- We don't need space before this
}

ins_left {
  -- mode component
  function() return '' end,
  color = function()
    local mode_color = {
      n = '#ec5f67',
      i = '#98be65',
      v = '#51afef',
      ['\22'] = '#51afef',
      V = '#51afef',
      c = '#c678dd',
      no = '#ec5f67',
      s = '#FF8800',
      S = '#FF8800',
      ['\19'] = '#FF8800',
      ic = '#ECBE7B',
      R = '#a9a1e1',
      Rv = '#a9a1e1',
      cv = '#ec5f67',
      ce = '#ec5f67',
      r = '#008080',
      rm = '#008080',
      ['r?'] = '#008080',
      ['!'] = '#ec5f67',
      t = '#ec5f67',
    }
    return { fg = mode_color[vim.fn.mode()] or mode_color.n }
  end,
  padding = { right = 1 },
}

ins_left {
  -- filesize component
  'filesize',
  cond = conditions.buffer_not_empty,
}

ins_left {
  'filename',
  cond = conditions.buffer_not_empty,
  color = fg('0F', 'bold'),
}

ins_left { 'location' }

ins_left { 'progress', color = fg('05', 'bold') }

ins_left {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbols = { error = ' ', warn = ' ', info = ' ' },
  diagnostics_color = {
    error = fg '08',
    warn = fg '0A',
    info = fg '0D',
    hint = fg '0C',
  },
}

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left {
  function() return '%=' end,
}

ins_left {
  -- Lsp server name .
  function()
    local msg = 'No Active Lsp'
    local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
    local clients = vim.lsp.get_clients { bufnr = 0 }
    if next(clients) == nil then return msg end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then return client.name end
    end
    return msg
  end,
  icon = ' LSP:',
  color = fg('07', 'bold'),
}

-- Add components to right sections
ins_right {
  'o:encoding', -- option component same as &encoding in viml
  fmt = string.upper, -- I'm not sure why it's upper case either ;)
  cond = conditions.hide_in_width,
  color = fg('0B', 'bold'),
}

ins_right {
  'fileformat',
  fmt = string.upper,
  icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
  color = fg('0B', 'bold'),
}

ins_right {
  'branch',
  icon = '',
  color = fg('0E', 'bold'),
}

ins_right {
  'diff',
  -- Is it me or the symbol for modified us really weird
  symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
  diff_color = {
    added = fg '0B',
    modified = fg '09',
    removed = fg '08',
  },
  cond = conditions.hide_in_width,
}

ins_right {
  function() return '▊' end,
  color = colors.blue,
  padding = { left = 1 },
}

-- Now don't forget to initialize lualine
lualine.setup(config)
