--[[
  ==========================================================================
  📜 名称：赛博文房：落霞孤鹜版 · 终极全能卷 (Cyber-Atelier: LXGW Edition)
  🛠️ 核心：Neovim + Lua + Lazy.nvim
  ✨ 特色：大拇指解放、物理跳转、OSC52强力剪贴板同步
  👤 所有：realexblue
  ==========================================================================
--]]

-- ==========================================================================
-- 1. 基础全局设置 (General Settings)
-- ==========================================================================
vim.g.mapleader = " "         -- 唯一的领航键
vim.g.deprecation_warnings = false -- 🤫 屏蔽烦人的弃用警告 (lsp.buf_get_clients 等)
vim.api.nvim_create_autocmd("LspTokenUpdate", { callback = function() end }) -- 额外加固
local opt = vim.opt
-- 🚫 禁用不需要的 Provider，消除 checkhealth 警告并加速启动
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- 🤫 深度屏蔽弃用警告 (针对你报告中的 vim.lsp.buf_get_clients)
vim.g.deprecation_warnings = false
opt.number = true             -- 显示行号
opt.mouse = 'a'               -- 开启鼠标支持
opt.termguicolors = true      -- 开启真彩色支持
opt.tabstop = 4               -- Tab 宽度
opt.shiftwidth = 4            -- 缩进宽度
opt.expandtab = true          -- 空格替代 Tab

-- 📋 强力版剪贴板同步 (针对 OrbStack/iTerm2 优化)
opt.clipboard = "unnamedplus" 
if vim.fn.has('ssh') == 1 or true then -- 强制启用 OSC 52 协议确保次元壁打通
    vim.g.clipboard = {
        name = 'OSC 52',
        copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
            ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
        },
        paste = {
            ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
            ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
        },
    }
end

-- 🕒 持久化撤销 (UndoTree 的后台保障)
if vim.fn.has("persistent_undo") == 1 then
    opt.undofile = true
    opt.undodir = vim.fn.expand('~/.local/share/nvim/undo')
end

-- ==========================================================================
-- 2. 插件配置与安装 (Plugin Setup)
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- 🎨 主题：Gruvbox (复古极客色调)
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = function() vim.cmd("colorscheme gruvbox") end },

  -- 📊 状态栏：Lualine (配合 iTerm2 图标补丁)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = { 
          theme = 'gruvbox', 
          globalstatus = true, 
          section_separators = { left = '', right = ''},
          component_separators = { left = '', right = ''}
        },
        sections = {
          lualine_c = { { 'filename', file_status = true, path = 1 } }
        }
      })
    end
  },

  -- 🌲 符号大纲 (Outline)：类似 VS Code 的侧栏大纲
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup({ position = 'right', width = 25, auto_preview = false })
    end
  },

  -- 🥖 面包屑导航 (Breadcrumbs via Lspsaga)
  {
    'nvimdev/lspsaga.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('lspsaga').setup({ symbol_in_winbar = { enable = true } })
    end
  },

  -- 🕒 可视化撤销树 (UndoTree)：你的代码时光机
  { "mbbill/undotree" },

  -- 🧠 语法高亮引擎 (大纲和面包屑的基础)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }
})

-- ==========================================================================
-- 3. 快捷键映射 (Keymaps)
-- ==========================================================================
local keymap = vim.keymap.set

-- ⌨️ A. 基础映射
-- 普通和可视模式下，空格变冒号
keymap({'n', 'v'}, '<Space>', ':', { desc = "空格开启命令行" })

-- 插入/命令行模式：jk 连按回退
keymap('i', 'jk', '<Esc>', { desc = "退出插入模式" })
keymap('c', 'jk', '<C-c>', { desc = "取消命令输入" })

-- 终端模式下，连按 jk 也能退出到 Normal 模式
keymap('t', 'jk', [[<C-\><C-n>]], { desc = "终端模式一键逃逸" })

-- 可视模式下连按 jk 退出到 Normal 模式
keymap('v', 'jk', '<Esc>', { desc = "可视模式一键逃逸" })

-- 🕒 撤销与重做 (realexblue 极速方案)
keymap('n', 'u', 'u', { desc = "撤销" })
keymap('n', 'U', '<C-r>', { desc = "重做 (Redo)" }) -- 用大写 U 代替 Ctrl+r

-- 🎯 B. 物理级跳转与逻辑跳转
-- H 跳到绝对行首（第 0 列），L 跳到绝对行末（最后一格）
keymap({'n', 'v'}, 'H', '0', { desc = "绝对行首" })
keymap({'n', 'v'}, 'L', '$', { desc = "绝对行末" })
-- (注：大写 I 和 A 依然保持原生逻辑：跳转到内容边缘并编辑)

-- 📖 极速翻页 (Page Navigation)
-- 用空格 + j/k 实现半页翻转，比 Ctrl 更近
keymap({'n', 'v'}, '<leader>j', '<C-d>', { desc = "向下翻半页" })
keymap({'n', 'v'}, '<leader>k', '<C-u>', { desc = "向上翻半页" })

-- 🛠️ C. 功能扩展 (Leader 键组合技)
-- 空格 + o : 切换右侧大纲 (Outline)
keymap('n', '<leader>o', ':SymbolsOutline<CR>', { desc = "切换代码大纲" })
-- 空格 + u : 开启时光机 (UndoTree)
keymap('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = "开启撤销历史树" })
-- 快速开启终端的快捷键 (空格 + t)
keymap('n', '<leader>t', ':split | term<CR>', { desc = "下方开启终端" })

-- 🪟 D. 窗口穿梭 (realexblue 终极免配置方案)
local win_opts = { noremap = true, silent = true }

-- 1. 普通模式跳转 (保持原样)
keymap('n', '<C-h>', '<C-w>h', win_opts)
keymap('n', '<C-j>', '<C-w>j', win_opts)
keymap('n', '<C-k>', '<C-w>k', win_opts)
keymap('n', '<C-l>', '<C-w>l', win_opts)

-- 2. 终端模式：绕过被拦截的 Ctrl 键
-- 在终端里飞速按 jk 接着按 k，就能跳回上面的窗口
keymap('t', 'jkk', [[<C-\><C-n><C-w>k]], win_opts)
keymap('t', 'jkj', [[<C-\><C-n><C-w>j]], win_opts)
keymap('t', 'jkh', [[<C-\><C-n><C-w>h]], win_opts)
keymap('t', 'jkl', [[<C-\><C-n><C-w>l]], win_opts)

-- 🚀 热重载配置 (空格 + s)
keymap("n", "<leader>s", function()
    vim.cmd("source $MYVIMRC")
    vim.notify("配置已重载！Gruvbox 依然在线 🚀", vim.log.levels.INFO)
end)

-- 🌊 E. 平滑滚动优化 (光标纹丝不动，屏幕丝般顺滑)
local scroll_opts = { silent = true }
keymap('n', '<ScrollWheelUp>', '<C-y>', scroll_opts)
keymap('n', '<ScrollWheelDown>', '<C-e>', scroll_opts)
keymap('i', '<ScrollWheelUp>', '<C-o><C-y>', scroll_opts)
keymap('i', '<ScrollWheelDown>', '<C-o><C-e>', scroll_opts)
keymap('v', '<ScrollWheelUp>', '<C-y>', scroll_opts)
keymap('v', '<ScrollWheelDown>', '<C-e>', scroll_opts)

-- ==========================================================================
-- 4. 自动命令 (AutoCommands)
-- ==========================================================================

-- 🔦 复制时闪烁高亮
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 300 })
  end,
})

-- 📝 针对 .conf 文件的语法高亮
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.conf", "*.ini", ".env*"},
  command = "set filetype=dosini",
})

-- 💾 保存 init.lua 时自动重载
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "init.lua",
    callback = function()
        vim.cmd("source $MYVIMRC")
    end,
})
