---@diagnostic disable: missing-fields
--
-- DEPENDENCIES:
-- this configuration assumes you have the following tools installed on your
-- system:
--    `git` - for vim builtin package manager. (see `:h vim.pack`)
--    `ripgrep` - for fuzzy finding
--    clipboard tool: xclip/xsel/win32yank - for clipboard sharing between OS and neovim (see `h: clipboard-tool`)
--    a nerdfont (ensure the terminal running neovim is using it)
-- run `:checkhealth` inside neovim to see if your system is missing anything.

-- INFO: options
-- these change the default neovim behaviours using the 'vim.opt' API.
-- see `:h vim.opt` for more details.
-- run `:h '{option_name}'` to see what they do and what values they can take.
-- for example, `:h 'number'` for `vim.opt.number`.

-- set <space> as the leader key
-- must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- enable true color support
vim.opt.termguicolors = true

-- make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- minimal number of screen lines to keep above and below the cursor
vim.o.scrolloff = 5

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- enable mouse mode, can be useful for resizing splits
vim.opt.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- save undo history
vim.opt.undofile = true

-- keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- sets how neovim will display certain whitespace characters in the editor.
--  see `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- enable live preview of substitutions
vim.opt.inccommand = "split"

-- show which line your cursor is on
vim.opt.cursorline = true

-- set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

-- enable break indent
vim.opt.breakindent = true

-- enable line wrapping
vim.opt.wrap = true

-- formatting
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.textwidth = 80

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	virtual_text = true, -- show inline diagnostics
})

-- INFO: Keymaps

-- clear search highlights with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- TAB-based indent without losing the selection
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent and reselect" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Outdent and reselect" })

-- INFO: colorscheme
vim.pack.add({ "https://github.com/rebelot/kanagawa.nvim" }, { confirm = false })
vim.cmd.colorscheme("kanagawa")

-- INFO: autoreload check
-- Check if we need to reload the file when it changed
-- source: https://github.com/LazyVim/LazyVim/blob/25abbf546d564dc484cf903804661ba12de45507/lua/lazyvim/config/autocmds.lua#L9
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = vim.api.nvim_create_augroup("kickstart-checktime", { clear = true }),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- INFO: highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- INFO: New UI opt-in
require("vim._core.ui2").enable({})

-- INFO: plugins
-- we install plugins with neovim's builtin package manager: vim.pack
-- and then enable/configure them by calling their setup functions.
--
-- (see `:h vim.pack` for more details on how it works)
-- you can press `gx` on any of the plugin urls below to open them in your
-- browser and check out their documentation and functionality.
-- alternatively, you can run `:h {plugin-name}` to read their documentation.
--
-- plugins are then loaded and configured with a call to `setup` functions
-- provided by each plugin. this is not a rule of neovim but rather a convention
-- followed by the community.
-- these setup calls take a table as an agument and their expected contents can
-- vary wildly. refer to each plugin's documentation for details.

-- INFO: formatting and syntax highlighting
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })

require("nvim-treesitter.config").setup({
	auto_install = true, -- autoinstall languages that are not installed yet
})

-- start treesitter highlighting on buffers that have a parser available
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if lang and vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf, lang)
    end
  end,
})

-- INFO: Indent detection

vim.pack.add({ "https://github.com/NMAC427/guess-indent.nvim" }, { confirm = false })
require("guess-indent").setup({})

-- INFO: completion engine
vim.pack.add({ "https://github.com/saghen/blink.cmp" }, { confirm = false })

require("blink.cmp").setup({
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 500,
		},
	},

	appearance = {
		-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
		-- Adjusts spacing to ensure icons are aligned
		nerd_font_variant = "mono",
	},

	keymap = {
		preset = "enter",
	},

	fuzzy = {
		implementation = "lua",
	},

	signature = { enabled = true },
})

-- INFO: lsp server installation and configuration

-- lsp servers we want to use and their configuration
-- see `:h lspconfig-all` for available servers and their settings
local lsp_servers = {
	lua_ls = {
		-- https://luals.github.io/wiki/settings/ | `:h nvim_get_runtime_file`
		Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) } },
	},
	clangd = {},
	rust_analyzer = {},
	gopls = {},
	ty = {},
	ruff = {},
	ts_ls = {},
	tailwindcss = {},
	qmlls = {
		cmd = { "qmlls6" },
	},
}

vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig", -- default configs for lsps
}, { confirm = false })

-- configure each lsp server on the table
-- to check what clients are attached to the current buffer, use
-- `:checkhealth vim.lsp`. to view default lsp keybindings, use `:h lsp-defaults`.
for server, config in pairs(lsp_servers) do
	vim.lsp.config(server, {
		settings = config,

		-- only create the keymaps if the server attaches successfully
		on_attach = function(_, bufnr)
			vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = bufnr, desc = "[G]o to [D]efinition" })

			vim.keymap.set("n", "grf", vim.lsp.buf.format, { buffer = bufnr, desc = "[F]ormat" })

			vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover Documentation" })

			vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = bufnr, desc = "[R]e[n]ame" })

			vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code [A]ction" })

			vim.keymap.set("n", "grr", vim.lsp.buf.references, { buffer = bufnr, desc = "[R]eferences" })
		end,
	})
	vim.lsp.enable(server)
end

vim.keymap.set("n", "<leader>ch", "<cmd>checkhealth vim.lsp<CR>", { desc = "[C]heck [H]ealth (LSP)" })

-- INFO: autoformat
vim.pack.add({ "https://github.com/stevearc/conform.nvim" }, { confirm = false })

require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true }
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return nil
		else
			return {
				timeout_ms = 500,
				lsp_format = "fallback",
			}
		end
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
		go = { "goimports", "gofmt" },
		json = { "prettierd", "prettier", stop_after_first = true },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
	},
})

vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[C]ode [F]ormat buffer" })

-- INFO: fuzzy finder
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim", -- library dependency
	"https://github.com/nvim-tree/nvim-web-devicons", -- icons (nerd font)
	"https://github.com/nvim-telescope/telescope.nvim", -- the fuzzy finder
}, { confirm = false })

require("telescope").setup({})

local pickers = require("telescope.builtin")

vim.keymap.set("n", "<leader>sp", pickers.builtin, { desc = "[S]earch Builtin [P]ickers" })
vim.keymap.set("n", "<leader>sb", pickers.buffers, { desc = "[S]earch [B]uffers" })
vim.keymap.set("n", "<leader>sf", pickers.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sw", pickers.grep_string, { desc = "[S]earch Current [W]ord" })
vim.keymap.set("n", "<leader>sg", pickers.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sr", pickers.resume, { desc = "[S]earch [R]esume" })

vim.keymap.set("n", "<leader>sh", pickers.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sm", pickers.man_pages, { desc = "[S]earch [M]anuals" })

-- INFO: keybinding helper
vim.pack.add({ "https://github.com/folke/which-key.nvim" }, { confirm = false })

require("which-key").setup({
	spec = {
		{ "<leader>s", group = "[S]earch" },
		{ "<leader>x", group = "Trouble" },
		{ "<leader>c", group = "[C]ode" },
		{ "<leader>g", group = "[G]it" },
	},
})

-- INFO: file tree explorer

vim.pack.add({
	{
		src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
		version = vim.version.range("3"),
	},
	-- dependencies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	-- optional, but recommended
	"https://github.com/nvim-tree/nvim-web-devicons",
}, { confirm = false })

require("neo-tree").setup({
	filesystem = {
		window = {
			mappings = {
				["\\"] = "close_window",
			},
		},
	},
})

vim.keymap.set("n", "\\", ":Neotree reveal<CR>", { desc = "NeoTree reveal" })

-- INFO: trouble - A pretty list for showing diagnostics, references, etc...
vim.pack.add({
	"https://github.com/folke/trouble.nvim",
}, { confirm = false })

require("trouble").setup()

vim.keymap.set("n", "<leader>xx", ":Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>xX",
	":Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Buffer Diagnostics (Trouble)" }
)
vim.keymap.set("n", "<leader>cs", ":Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>cl",
	":Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "LSP Definitions / references / ... (Trouble)" }
)
vim.keymap.set("n", "<leader>xL", ":Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
vim.keymap.set("n", "<leader>xQ", ":Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>xi",
	":Trouble todo filter = {tag = {INFO,NOTE,HACK,IMPORTANT,WARN,WARNING}}<cr>",
	{ desc = "Info Comments (Trouble)" }
)
vim.keymap.set(
	"n",
	"<leader>xt",
	":Trouble todo filter = {tag = {TODO,FIX,FIXME,BUG}}<cr>",
	{ desc = "Todo Comments (Trouble)" }
)

-- INFO: grug-far - Search and Replace
vim.pack.add({
	"https://github.com/MagicDuck/grug-far.nvim",
}, { confirm = false })

local gf = require("grug-far")
gf.setup({})

vim.keymap.set("n", "<leader>sa", gf.open, { desc = "[S]earch [A]nd Replace" })

-- INFO: flash - Enhanced search and navigation
vim.pack.add({
	"https://github.com/folke/flash.nvim",
}, { confirm = false })

require("flash").setup({})

vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })

-- INFO: auto-session - Automatic session management
vim.pack.add({
	"https://github.com/rmagatti/auto-session",
}, { confirm = false })

require("auto-session").setup({
	suppressed_dirs = { "~/", "~/Downloads" },
})

-- INFO: other utilites
vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim", -- git integration
	"https://github.com/windwp/nvim-autopairs", -- automatic pairs
	"https://github.com/folke/todo-comments.nvim", -- hilight TODO/BUG/INFO/... comments
	"https://github.com/folke/zen-mode.nvim", -- zen mode
	"https://github.com/nvim-lua/plenary.nvim", -- library dependency
}, { confirm = false })

require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})

vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "[G]it [B]lame Line" })
vim.keymap.set("n", "<leader>gh", ":Gitsigns preview_hunk<CR>", { desc = "[G]it Preview [H]unk" })
vim.keymap.set("n", "]h", ":Gitsigns next_hunk<CR>", { desc = "Next [H]unk" })
vim.keymap.set("n", "[h", ":Gitsigns prev_hunk<CR>", { desc = "Prev [H]unk" })
require("nvim-autopairs").setup({ signs = false })
require("todo-comments").setup({ signs = false })

vim.keymap.set("n", "<leader>z", ":ZenMode<CR>", { desc = "[Z]en Mode" })

-- uncomment to enable automatic plugin updates
-- vim.pack.update()
