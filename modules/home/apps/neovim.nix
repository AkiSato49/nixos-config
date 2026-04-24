{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias  = true;
    vimAlias = true;

    # NixOS: compiled plugins must come from Nix (can't build at runtime)
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      telescope-fzf-native-nvim
    ];

    extraPackages = with pkgs; [
      # LSP servers (in PATH so mason-lspconfig finds them without downloading)
      typescript-language-server
      vscode-langservers-extracted  # html, css, json, eslint
      svelte-language-server
      lua-language-server
      nil                           # Nix LSP
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
      gcc   # required for some plugin builds
      gnumake
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

      -- Window navigation
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

      -- File ops
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
      -- Plugins (LazyVim base + NixOS overrides)
      -- =============================================
      require("lazy").setup({
        spec = {

          -- ── LazyVim base ──────────────────────────────────────────────
          -- Brings in: snacks, noice, mini, bufferline, which-key,
          --            lspconfig, mason, cmp, telescope, gitsigns, etc.
          {
            "LazyVim/LazyVim",
            import = "lazyvim.plugins",
            opts = {
              colorscheme = "gruvbox",
            },
          },

          -- ── Language extras ───────────────────────────────────────────
          { import = "lazyvim.plugins.extras.lang.typescript" },
          { import = "lazyvim.plugins.extras.lang.json" },
          { import = "lazyvim.plugins.extras.lang.python" },
          { import = "lazyvim.plugins.extras.lang.svelte" },

          -- ── Theme: Gruvbox ────────────────────────────────────────────
          {
            "ellisonleao/gruvbox.nvim",
            priority = 1000,
            opts = {
              contrast = "hard",
              transparent_mode = false,
              overrides = {
                SignColumn   = { bg = "#1d2021" },
                CursorLineNr = { fg = "#d79921", bold = true },
              },
            },
          },

          -- ── NixOS: treesitter (parsers via Nix, no TSUpdate) ─────────
          {
            "nvim-treesitter/nvim-treesitter",
            opts = {
              ensure_installed = {},  -- parsers come from Nix
              highlight = { enable = true },
              indent    = { enable = true },
            },
          },

          -- ── NixOS: telescope-fzf-native (pre-built by Nix) ───────────
          {
            "nvim-telescope/telescope-fzf-native.nvim",
            dir   = "${pkgs.vimPlugins.telescope-fzf-native-nvim}",
            build = false,
          },

          -- ── NixOS: disable mason auto-install (servers in PATH via Nix)
          {
            "williamboman/mason-lspconfig.nvim",
            opts = { ensure_installed = {} },
          },

          -- ── Formatters (using Nix-provided binaries) ──────────────────
          {
            "stevearc/conform.nvim",
            opts = {
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
            },
          },

          -- ── Nix filetype support ──────────────────────────────────────
          { "LnL7/vim-nix" },

        },

        defaults = {
          lazy    = false,
          version = false,  -- always use latest git for LazyVim plugins
        },
        install = { colorscheme = { "gruvbox", "tokyonight", "habamax" } },
        checker = { enabled = true, notify = false },

        -- ── Critical for NixOS ────────────────────────────────────────
        -- lazy.nvim resets packpath + rtp by default, wiping Nix plugins
        performance = {
          reset_packpath = false,
          rtp            = { reset = false },
        },
      })

      -- =============================================
      -- Treesitter config (outside lazy — Nix-managed)
      -- =============================================
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent    = { enable = true },
        autotag   = { enable = true },
      })
    '';
  };
}
