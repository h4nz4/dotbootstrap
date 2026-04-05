-- LINES
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.cursorline = true
vim.opt.smartindent = true
vim.opt.termguicolors = true

-- PLUGINS
vim.opt.mouse = "a"

-- PACKER
vim.pack.add {
    "https://github.com/joshdick/onedark.vim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
}

-- TELESCOPE
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- SET COLORSCHEME
vim.cmd.colorscheme("tokyonight")