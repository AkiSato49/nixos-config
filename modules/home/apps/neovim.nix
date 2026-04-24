{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Treesitter managed by Nix (NixOS can't compile parsers at runtime)
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];

    extraPackages = with pkgs; [
      # LSP servers
      typescript-language-server
      vscode-langservers-extracted # html, css, json, eslint
      svelte-language-server
      lua-language-server
      pyright

      # Formatters
      prettierd
      black
      stylua
      nixpkgs-fmt

      # Tools
      ripgrep
      fd
      git
    ];

    initLua = ''
      -- =============================================
      -- Bootstrap lazy.nvim
      -- =============================================
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        vim.fn.system({
          "git", "clone", "--filter=blob:none", "--branch=stable",
          "https://github.com/folke/lazy.nvim.git", lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      -- =============================================
      -- Options
      -- =============================================
      local opt = vim.opt
      opt.number         = true
      opt.relativenumber = true
      opt.tabstop        = 2
      opt.shiftwidth     = 2
      opt.expandtab      = true
      opt.smartindent    = true
      opt.wrap           = false
      opt.swapfile       = false
      opt.backup         = false
      opt.undofile       = true
      opt.undodir        = vim.fn.stdpath("data") .. "/undo"
      opt.hlsearch       = false
      opt.incsearch      = true
      opt.termguicolors  = true
      opt.scrolloff      = 8
      opt.sidescrolloff  = 8
      opt.signcolumn     = "yes"
      opt.updatetime     = 50
      opt.colorcolumn    = "100"
      opt.clipboard      = "unnamedplus"
      opt.splitbelow     = true
      opt.splitright     = true
      opt.cursorline     = true
      opt.pumheight      = 10
      opt.completeopt    = "menuone,noselect"

      vim.g.mapleader      = " "
      vim.g.maplocalleader = " "

      -- =============================================
      -- Keymaps
      -- =============================================
      local map = vim.keymap.set
      -- Navigation
      map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
      map("n", "<C-j>", "<C-w>j", { desc = "Move to below split" })
      map("n", "<C-k>", "<C-w>k", { desc = "Move to above split" })
      map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

      -- Better scrolling
      map("n", "<C-d>", "<C-d>zz")
      map("n", "<C-u>", "<C-u>zz")
      map("n", "n",     "nzzzv")
      map("n", "N",     "Nzzzv")

      -- Move lines in visual mode
      map("v", "J", ":m '>+1<CR>gv=gv")
      map("v", "K", ":m '<-2<CR>gv=gv")

      -- Quick save/quit
      map("n", "<leader>w", "<cmd>w<cr>",  { desc = "Save" })
      map("n", "<leader>q", "<cmd>q<cr>",  { desc = "Quit" })
      map("n", "<leader>x", "<cmd>x<cr>",  { desc = "Save & quit" })

      -- Buffer navigation
      map("n", "<S-h>", "<cmd>bprevious<cr>")
      map("n", "<S-l>", "<cmd>bnext<cr>")
      map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

      -- Paste without overwriting clipboard
      map("x", "<leader>p", '"_dP')

      -- =============================================
      -- Plugins
      -- =============================================
      require("lazy").setup({
        spec = {

          -- Theme: Gruvbox
          {
            "ellisonleao/gruvbox.nvim",
            priority = 1000,
            config = function()
              require("gruvbox").setup({
                contrast = "hard",
                transparent_mode = false,
                overrides = {
                  SignColumn = { bg = "#1d2021" },
                  CursorLineNr = { fg = "#d79921", bold = true },
                },
              })
              vim.cmd("colorscheme gruvbox")
            end,
          },

          -- File explorer
          {
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v3.x",
            dependencies = {
              "nvim-lua/plenary.nvim",
              "nvim-tree/nvim-web-devicons",
              "MunifTanjim/nui.nvim",
            },
            keys = {
              { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File tree" },
              { "<leader>o", "<cmd>Neotree focus<cr>",  desc = "Focus tree" },
            },
            opts = {
              window = { width = 30 },
              filesystem = { filtered_items = { hide_dotfiles = false } },
            },
          },

          -- Fuzzy finder
          {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = {
              "nvim-lua/plenary.nvim",
              { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            },
            keys = {
              { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
              { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
              { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
              { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help" },
              { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Recent files" },
              { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
            },
            config = function()
              require("telescope").setup({
                defaults = {
                  prompt_prefix = " ",
                  selection_caret = " ",
                  path_display = { "truncate" },
                },
              })
              require("telescope").load_extension("fzf")
            end,
          },

          -- Treesitter is managed by Nix (see programs.neovim.plugins)
          -- configured below after lazy.setup() to avoid rtp issues

          -- LSP + Completion
          {
            "neovim/nvim-lspconfig",
            dependencies = {
              "williamboman/mason.nvim",
              "williamboman/mason-lspconfig.nvim",
              "hrsh7th/nvim-cmp",
              "hrsh7th/cmp-nvim-lsp",
              "hrsh7th/cmp-buffer",
              "hrsh7th/cmp-path",
              "L3MON4D3/LuaSnip",
              "saadparwaiz1/cmp_luasnip",
              "rafamadriz/friendly-snippets",
              "onsails/lspkind.nvim",
            },
            config = function()
              require("mason").setup()
              require("mason-lspconfig").setup({
                ensure_installed = {
                  "ts_ls", "html", "cssls", "svelte",
                  "lua_ls", "nil_ls", "pyright",
                },
              })

              local capabilities = require("cmp_nvim_lsp").default_capabilities()

              local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr, silent = true }
                map("n", "gd",         vim.lsp.buf.definition,    opts)
                map("n", "gD",         vim.lsp.buf.declaration,   opts)
                map("n", "gr",         vim.lsp.buf.references,    opts)
                map("n", "gi",         vim.lsp.buf.implementation, opts)
                map("n", "K",          vim.lsp.buf.hover,         opts)
                map("n", "<leader>ca", vim.lsp.buf.code_action,   opts)
                map("n", "<leader>rn", vim.lsp.buf.rename,        opts)
                map("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, opts)
                map("n", "<leader>d",  vim.diagnostic.open_float, opts)
                map("n", "[d",         vim.diagnostic.goto_prev,  opts)
                map("n", "]d",         vim.diagnostic.goto_next,  opts)
              end

              local servers = {
                "ts_ls", "html", "cssls", "svelte",
                "lua_ls", "nil_ls", "pyright",
              }
              -- Use nvim 0.11+ API (replaces deprecated require('lspconfig') framework)
              for _, lsp in ipairs(servers) do
                vim.lsp.config(lsp, { capabilities = capabilities, on_attach = on_attach })
              end
              vim.lsp.enable(servers)

              -- nvim-cmp
              local cmp     = require("cmp")
              local luasnip = require("luasnip")
              local lspkind = require("lspkind")

              require("luasnip.loaders.from_vscode").lazy_load()

              cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                  ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                  ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                  ["<C-Space>"] = cmp.mapping.complete(),
                  ["<C-e>"]     = cmp.mapping.abort(),
                  ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                  ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                    else fallback() end
                  end, { "i", "s" }),
                  ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                    else fallback() end
                  end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                  { name = "nvim_lsp" },
                  { name = "luasnip" },
                  { name = "buffer" },
                  { name = "path" },
                }),
                formatting = {
                  format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 }),
                },
              })
            end,
          },

          -- Formatting
          {
            "stevearc/conform.nvim",
            event = "BufWritePre",
            config = function()
              require("conform").setup({
                formatters_by_ft = {
                  javascript       = { "prettierd" },
                  typescript       = { "prettierd" },
                  javascriptreact  = { "prettierd" },
                  typescriptreact  = { "prettierd" },
                  svelte           = { "prettierd" },
                  html             = { "prettierd" },
                  css              = { "prettierd" },
                  json             = { "prettierd" },
                  python           = { "black" },
                  lua              = { "stylua" },
                  nix              = { "nixpkgs_fmt" },
                },
                format_on_save = { timeout_ms = 500, lsp_fallback = true },
              })
            end,
          },

          -- Statusline
          {
            "nvim-lualine/lualine.nvim",
            config = function()
              require("lualine").setup({ options = { theme = "gruvbox" } })
            end,
          },

          -- Git signs in gutter
          {
            "lewis6991/gitsigns.nvim",
            config = function()
              require("gitsigns").setup({
                signs = {
                  add          = { text = "▎" },
                  change       = { text = "▎" },
                  delete       = { text = "" },
                  topdelete    = { text = "" },
                  changedelete = { text = "▎" },
                },
                on_attach = function(bufnr)
                  local gs = package.loaded.gitsigns
                  local opts = { buffer = bufnr }
                  map("n", "]h", gs.next_hunk, opts)
                  map("n", "[h", gs.prev_hunk, opts)
                  map("n", "<leader>ph", gs.preview_hunk, opts)
                  map("n", "<leader>gb", gs.blame_line, opts)
                end,
              })
            end,
          },

          -- Auto pairs
          { "windwp/nvim-autopairs",         event = "InsertEnter", config = true },
          -- Auto close/rename HTML tags
          { "windwp/nvim-ts-autotag",        config = true },
          -- Comments
          { "numToStr/Comment.nvim",          config = true },
          -- Which-key
          { "folke/which-key.nvim",           config = true },
          -- Indent guides
          { "lukas-reineke/indent-blankline.nvim", main = "ibl", config = true },
          -- Highlight TODO comments
          { "folke/todo-comments.nvim",       dependencies = "nvim-lua/plenary.nvim", config = true },
          -- Better diagnostics
          { "folke/trouble.nvim",             keys = {
            { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Trouble" },
          }, config = true },
        },

        install  = { colorscheme = { "gruvbox", "default" } },
        checker  = { enabled = true, notify = false },
        performance = {
          -- Critical for NixOS: Nix installs plugins to packpath/rtp.
          -- lazy.nvim resets both by default, wiping Nix-managed plugins.
          reset_packpath = false,
          rtp = { reset = false },
        },
      })

      -- Treesitter: configured here, outside lazy, since it's Nix-managed
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent    = { enable = true },
        autotag   = { enable = true },
      })
    '';
  };
}
