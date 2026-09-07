{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local capabilities = require('cmp_nvim_lsp').default_capabilities()
          vim.lsp.config('html', { capabilities = capabilities })
          vim.lsp.config('elixirls', {
            cmd = {"${pkgs.elixir-ls}/bin/elixir-ls"},
            capabilities = capabilities,
          })
          vim.lsp.config('nil_ls', { capabilities = capabilities })
          vim.lsp.config('pyright', { capabilities = capabilities })
          vim.lsp.config('lua_ls', { capabilities = capabilities })
          vim.lsp.enable({'html', 'elixirls', 'nil_ls', 'pyright', 'lua_ls'})
        '';
      }
      cmp-nvim-lsp
      cmp-buffer
      cmp-cmdline
      cmp-path
      nvim-cmp
      luasnip
      cmp_luasnip
      fidget-nvim
      telescope-nvim
      nvim-web-devicons
      nvim-treesitter.withAllGrammars
      telescope-zoxide
      vim-tmux-navigator
      {
        plugin = tokyonight-nvim;
        type = "lua";
        config = ''
          vim.cmd[[colorscheme tokyonight]]
        '';
      }
      {
        plugin = conform-nvim;
        type = "lua";
        config = ''
          local conform = require("conform")

          conform.setup({
            formatters_by_ft = {
              javascript = { "prettier" },
              typescript = { "prettier" },
              javascriptreact = { "prettier" },
              typescriptreact = { "prettier" },
              svelte = { "prettier" },
              css = { "prettier" },
              html = { "prettier" },
              json = { "prettier" },
              yaml = { "prettier" },
              markdown = { "prettier" },
              graphql = { "prettier" },
              lua = { "stylua" },
              python = { "isort", "black" },
              nix = { "nixfmt" },
            },
            format_on_save = {
              lsp_fallback = true,
              async = false,
              timeout_ms = 1000,
            },
          })

          vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
              lsp_fallback = true,
              async = false,
              timeout_ms = 1000,
            })
          end, { desc = "Format file or range (in visual mode)" })
        '';
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup()
        '';
      }
      lualine-lsp-progress
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
          require("nvim-tree").setup()
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          vim.o.timeout = true
          vim.o.timeoutlen = 500
          require("which-key").setup()
        '';
      }
      {
        plugin = nvim-surround;
        type = "lua";
        config = ''
          require("nvim-surround").setup()
        '';
      }
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require("nvim-autopairs").setup()
        '';
      }
    ];
    extraLuaConfig = ''
      -- options
      local opt = vim.opt -- for conciseness

      -- line numbers
      opt.relativenumber = true -- show relative line numbers
      opt.number = true -- shows absolute line number on cursor line (when relative number is on)

      -- tabs & indentation
      opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
      opt.shiftwidth = 2 -- 2 spaces for indent width
      opt.expandtab = true -- expand tab to spaces
      opt.autoindent = true -- copy indent from current line when starting new one

      -- line wrapping
      opt.wrap = false -- disable line wrapping

      -- search settings
      opt.ignorecase = true -- ignore case when searching
      opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

      -- cursor line
      opt.cursorline = true -- highlight the current cursor line

      -- appearance

      -- turn on termguicolors for nightfly colorscheme to work
      -- (have to use iterm2 or any other true color terminal)
      opt.termguicolors = true
      opt.background = "dark" -- colorschemes that can be light or dark will be made dark
      opt.signcolumn = "yes" -- show sign column so that text doesn't shift

      -- backspace
      opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

      -- clipboard
      opt.clipboard:append("unnamedplus") -- use system clipboard as default register

      -- split windows
      opt.splitright = true -- split vertical window to the right
      opt.splitbelow = true -- split horizontal window to the bottom

      -- turn off swapfile
      opt.swapfile = false

      opt.foldmethod = "expr"
      opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = false

      -- keymaps
      -- set leader key to space
      vim.g.mapleader = " "

      local keymap = vim.keymap -- for conciseness

      ---------------------
      -- General Keymaps -------------------

      -- use jk to exit insert mode
      keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

      -- clear search highlights
      keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

      -- increment/decrement numbers
      keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
      keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

      -- window management
      keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
      keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
      keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
      keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

      keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
      keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
      keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
      keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
      keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab


      keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
      keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
      keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
      keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })

      -- NVIM Tree --
      keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
      keymap.set("n", "<leader> ", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
      keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) -- toggle file explorer on current file
      keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
      keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer

      -- completion
      vim.g.completeopt = "menu,menuone,noselect,noinsert"

      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        },
      })

      -- Set configuration for specific filetype.
      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    '';
  };
}
