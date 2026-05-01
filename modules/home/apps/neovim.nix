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
      gopls
      rust-analyzer
      clang-tools
      beam27Packages.elixir-ls
      kotlin-language-server
      ruby-lsp
      phpactor
      terraform-ls
      yaml-language-server
      taplo
      dockerfile-language-server-nodejs
      sqls
      metals
      zls
      astro-language-server
      helm-ls
      marksman
      cmake-language-server
      bash-language-server
      ocamlPackages.ocaml-lsp

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
          { import = "lazyvim.plugins.extras.lang.go" },
          { import = "lazyvim.plugins.extras.lang.rust" },
          { import = "lazyvim.plugins.extras.lang.clangd" },
          { import = "lazyvim.plugins.extras.lang.elixir" },
          { import = "lazyvim.plugins.extras.lang.kotlin" },
          { import = "lazyvim.plugins.extras.lang.ruby" },
          { import = "lazyvim.plugins.extras.lang.php" },
          { import = "lazyvim.plugins.extras.lang.terraform" },
          { import = "lazyvim.plugins.extras.lang.yaml" },
          { import = "lazyvim.plugins.extras.lang.toml" },
          { import = "lazyvim.plugins.extras.lang.docker" },
          { import = "lazyvim.plugins.extras.lang.sql" },
          { import = "lazyvim.plugins.extras.lang.scala" },
          { import = "lazyvim.plugins.extras.lang.zig" },
          { import = "lazyvim.plugins.extras.lang.astro" },
          { import = "lazyvim.plugins.extras.lang.nix" },
          { import = "lazyvim.plugins.extras.lang.helm" },
          { import = "lazyvim.plugins.extras.lang.tailwind" },
          { import = "lazyvim.plugins.extras.lang.cmake" },
          { import = "lazyvim.plugins.extras.lang.git" },

          -- ── Editor extras ────────────────────────────────────────
          { import = "lazyvim.plugins.extras.editor.aerial" },
          { import = "lazyvim.plugins.extras.editor.illuminate" },
          { import = "lazyvim.plugins.extras.editor.navic" },
          { import = "lazyvim.plugins.extras.ui.indent-blankline" },
          { import = "lazyvim.plugins.extras.ui.mini-indentscope" },

          -- ── Rainbow delimiters ─────────────────────────────────────
          {
            "HiPhish/rainbow-delimiters.nvim",
            event = "BufReadPost",
            config = function()
              local rainbow = require("rainbow-delimiters")
              require("rainbow-delimiters.setup").setup({
                strategy = { [""] = rainbow.strategy["global"] },
                query    = { [""] = "rainbow-delimiters" },
                highlight = {
                  "RainbowDelimiterYellow",
                  "RainbowDelimiterBlue",
                  "RainbowDelimiterOrange",
                  "RainbowDelimiterGreen",
                  "RainbowDelimiterViolet",
                  "RainbowDelimiterCyan",
                  "RainbowDelimiterRed",
                },
              })
            end,
          },

          -- ── Diffview ───────────────────────────────────────────
          {
            "sindrets/diffview.nvim",
            cmd  = { "DiffviewOpen", "DiffviewFileHistory" },
            keys = {
              { "<leader>gd", "<cmd>DiffviewOpen<cr>",        desc = "Diffview open" },
              { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
              { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",  desc = "Repo history" },
              { "<leader>gc", "<cmd>DiffviewClose<cr>",       desc = "Diffview close" },
            },
          },

          -- ── Project root detection ─────────────────────────────────
          {
            "ahmedkhalf/project.nvim",
            opts = {},
            config = function(_, opts)
              require("project_nvim").setup(opts)
              require("telescope").load_extension("projects")
            end,
            keys = {
              { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Projects" },
            },
          },


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
                -- LSP semantic tokens — distinct from treesitter
                ["@lsp.type.parameter"]  = { fg = "#d8a657", italic = true },
                ["@lsp.type.property"]   = { fg = "#89b482" },
                ["@lsp.type.class"]      = { fg = "#d3869b", bold = true },
                ["@lsp.type.interface"]  = { fg = "#7daea3", bold = true },
                ["@lsp.type.enum"]       = { fg = "#d3869b" },
                ["@lsp.type.enumMember"] = { fg = "#d8a657" },
                ["@lsp.type.namespace"]  = { fg = "#7daea3" },
                ["@lsp.type.decorator"]  = { fg = "#a9b665", italic = true },
                ["@lsp.type.variable"]   = { fg = "#d4be98" },
                ["@lsp.mod.deprecated"]  = { strikethrough = true },
                ["@lsp.mod.readonly"]    = { italic = true, bold = true },
                ["@lsp.mod.static"]      = { italic = true },
              },
            },
          },

          -- ── NixOS: treesitter ─────────────────────────────────────────
          -- Lazy-load on buffer open (avoids first-run errors)
          -- Parsers come from Nix; plugin Lua files from lazy.nvim
          {
            "nvim-treesitter/nvim-treesitter",
            -- NixOS: parsers symlinked to ~/.config/nvim/parser/ via xdg.configFile
            build = false,
            event = { "BufReadPost", "BufNewFile", "BufWritePre" },
            opts = function(_, opts)
              opts.ensure_installed = {}
              return opts
            end,
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

    '';
  };

  # NixOS: symlink all treesitter parsers into ~/.config/nvim/parser/
  # so neovim finds them natively without rtp hacks
  xdg.configFile."nvim/parser".source =
    let
      parsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
      };
    in "${parsers}/parser";
}
