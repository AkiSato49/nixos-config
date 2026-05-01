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
      # LSP servers
      typescript-language-server
      vscode-langservers-extracted
      svelte-language-server
      lua-language-server
      nil
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
      gcc
      gnumake

      # Image rendering (image.nvim + ueberzugpp for Alacritty/Wayland)
      imagemagick
      ueberzugpp

      # Quarto
      quarto
      pandoc
    ];

    # Lua packages (image.nvim needs magick)
    extraLuaPackages = lp: [ lp.magick ];

    # Python packages (molten-nvim / Jupyter)
    extraPython3Packages = ps: with ps; [
      pynvim
      jupyter-client
      cairosvg
      plotly
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
      -- NixOS: manually prepend Nix-managed plugins to rtp
      -- (before lazy.nvim starts, so they're always visible)
      -- =============================================
      vim.opt.rtp:prepend("${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}")
      vim.opt.rtp:prepend("${pkgs.vimPlugins.telescope-fzf-native-nvim}")

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
          { import = "lazyvim.plugins.extras.lang.markdown" },

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

          -- ── NixOS: treesitter ─────────────────────────────────────────
          -- Lazy-load on buffer open (avoids first-run errors)
          -- Parsers come from Nix; plugin Lua files from lazy.nvim
          {
            "nvim-treesitter/nvim-treesitter",
            event = { "BufReadPost", "BufNewFile", "BufWritePre" },
            opts = {
              ensure_installed = {},
              highlight = { enable = true },
              indent    = { enable = true },
              autotag   = { enable = true },
            },
          },

          -- ── Image rendering ───────────────────────────────────────────
          -- Requires kitty / wezterm terminal (Hyprland compatible)
          {
            "3rd/image.nvim",
            ft = { "markdown", "norg", "oil", "python" },
            opts = {
              backend              = "kitty",  -- Ghostty supports kitty graphics protocol
              max_width            = 100,
              max_height           = 40,
              max_height_window_percentage = math.huge,
              max_width_window_percentage  = math.huge,
              window_overlap_clear_enabled = true,
              window_overlap_clear_ft      = { "cmp_menu", "cmp_docs", "" },
            },
          },

          -- ── Jupyter / REPL (molten-nvim) ──────────────────────────────
          {
            "benlubas/molten-nvim",
            version  = "^1.0.0",
            ft       = { "python", "markdown" },
            build    = ":UpdateRemotePlugins",
            init = function()
              vim.g.molten_image_provider       = "image.nvim"
              vim.g.molten_output_win_max_height = 20
              vim.g.molten_auto_open_output      = false
              vim.g.molten_wrap_output           = true
              vim.g.molten_virt_text_output      = true
              vim.g.molten_virt_lines_off_by_1   = true
            end,
            keys = {
              { "<leader>mi", "<cmd>MoltenInit<cr>",                    desc = "Molten init" },
              { "<leader>me", "<cmd>MoltenEvaluateOperator<cr>",        desc = "Evaluate operator", expr = true },
              { "<leader>ml", "<cmd>MoltenEvaluateLine<cr>",            desc = "Evaluate line" },
              { "<leader>mv", "<cmd>MoltenEvaluateVisual<cr>",          desc = "Evaluate visual", mode = "v" },
              { "<leader>mr", "<cmd>MoltenReevaluateCell<cr>",          desc = "Re-evaluate cell" },
              { "<leader>md", "<cmd>MoltenDelete<cr>",                  desc = "Delete cell" },
              { "<leader>mo", "<cmd>MoltenShowOutput<cr>",              desc = "Show output" },
              { "<leader>mh", "<cmd>MoltenHideOutput<cr>",              desc = "Hide output" },
              { "<leader>mx", "<cmd>MoltenOpenInBrowser<cr>",           desc = "Open in browser" },
            },
          },

          -- ── Quarto (notebooks + .qmd + .ipynb) ───────────────────────
          {
            "quarto-dev/quarto-nvim",
            dependencies = {
              "jmbuhr/otter.nvim",   -- LSP in embedded code blocks
              "benlubas/molten-nvim",
            },
            ft = { "quarto", "markdown", "python" },
            opts = {
              lspFeatures = {
                enabled      = true,
                languages    = { "python", "r", "julia", "bash" },
                diagnostics  = { enabled = true, triggers = { "BufWritePost" } },
                completion    = { enabled = true },
              },
              codeRunner = {
                enabled        = true,
                default_method = "molten",
              },
            },
            keys = {
              { "<leader>qp", function() require("quarto").quartoPreview() end,  desc = "Quarto preview" },
              { "<leader>qq", function() require("quarto").quartoClosePreview() end, desc = "Quarto close preview" },
              { "<leader>qr", "<cmd>QuartoSendAbove<cr>",  desc = "Run cells above" },
              { "<leader>qa", "<cmd>QuartoSendAll<cr>",    desc = "Run all cells" },
              { "]c", "<cmd>QuartoNextCell<cr>",           desc = "Next cell" },
              { "[c", "<cmd>QuartoPrevCell<cr>",           desc = "Prev cell" },
              { "<leader>rc", "<cmd>QuartoSend<cr>",       desc = "Run cell" },
              { "<leader>ra", "<cmd>QuartoSendAndAdvance<cr>", desc = "Run & advance" },
            },
          },

          -- otter.nvim: LSP support inside embedded code blocks
          {
            "jmbuhr/otter.nvim",
            opts = {},
          },

          -- ── REPL (iron.nvim) — for non-Jupyter workflows ──────────────
          {
            "Vigemus/iron.nvim",
            keys = {
              { "<leader>rs", "<cmd>IronRepl<cr>",   desc = "Open REPL" },
              { "<leader>rr", "<cmd>IronRestart<cr>", desc = "Restart REPL" },
              { "<leader>rf", "<cmd>IronFocus<cr>",  desc = "Focus REPL" },
              { "<leader>rh", "<cmd>IronHide<cr>",   desc = "Hide REPL" },
            },
            config = function()
              require("iron.core").setup({
                config = {
                  scratch_repl    = true,
                  repl_definition = {
                    python = { command = { "ipython" } },
                    sh     = { command = { "bash" } },
                    js     = { command = { "node" } },
                  },
                  repl_open_cmd = require("iron.view").right(60),
                },
                keymaps = {
                  send_motion  = "<leader>sc",
                  visual_send  = "<leader>sc",
                  send_file    = "<leader>sf",
                  send_line    = "<leader>sl",
                  send_until_cursor = "<leader>su",
                  cr           = "<leader>s<cr>",
                  interrupt     = "<leader>s<space>",
                  exit         = "<leader>sq",
                  clear        = "<leader>cl",
                },
                highlight = { italic = true },
                ignore_blank_lines = true,
              })
            end,
          },

          -- ── NixOS: telescope-fzf-native (pre-built by Nix) ───────────
          {
            "nvim-telescope/telescope-fzf-native.nvim",
            dir   = "${pkgs.vimPlugins.telescope-fzf-native-nvim}",
            build = false,
          },

          -- ── NixOS: disable mason auto-install (servers in PATH via Nix)
          {
            "mason-org/mason-lspconfig.nvim",
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

        -- ── NixOS: disable luarocks/hererocks (magick comes from Nix) ──
        rocks = { enabled = false, hererocks = false },

        -- ── Critical for NixOS ────────────────────────────────────────
        -- lazy.nvim resets packpath + rtp by default, wiping Nix plugins
        performance = {
          reset_packpath = false,
          rtp            = { reset = false },
        },
      })

      -- Treesitter is configured by LazyVim's spec above.
      -- The Nix store path is already prepended to rtp before lazy.setup().
    '';
  };
}
