# IOEditorPhase (Gas) — nixvim: plugins, keymaps, LSP, lua
{
  config,
  lib,
  inputs,
  ...
}:
let
  base = builtins.fromJSON (builtins.readFile ../../default.json);
  local =
    if builtins.pathExists ../../local.json then
      builtins.fromJSON (builtins.readFile ../../local.json)
    else
      { };
  cfg = lib.recursiveUpdate base local;
  nvim = cfg.nixvim;
in
{
  config.flake.modules.homeManager.nixvim = lib.mkIf nvim.enable {
    imports = [ inputs.nixvim.homeModules.nixvim ];
    programs.nixvim =
      { pkgs, ... }:
      {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        globals.mapleader = nvim.leader;
        colorschemes.${nvim.colorscheme}.enable = true;
        opts = {
          number = nvim.lineNumbers;
          relativenumber = nvim.relativeNumbers;
          tabstop = nvim.tabWidth;
          shiftwidth = nvim.tabWidth;
          expandtab = true;
          smartindent = true;
          foldmethod = "expr";
          foldexpr = "v:lua.vim.treesitter.foldexpr()";
          foldlevel = 99;
          foldlevelstart = 99;
          foldenable = true;
        };
        plugins = {
          lean = {
            enable = true;
            lsp.enable = true;
          };
          lsp = {
            enable = true;
            servers = {
              nil_ls.enable = true;
              nushell.enable = true;
              pyright.enable = true;
              rust_analyzer = {
                enable = true;
                installCargo = false;
                installRustc = false;
              };
              ts_ls.enable = true;
              lua_ls.enable = true;
              taplo.enable = true;
            };
          };
          none-ls = {
            enable = true;
            sources.formatting.alejandra.enable = true;
          };
          telescope = {
            enable = true;
            settings.defaults.vimgrep_arguments = [
              "rg"
              "--color=never"
              "--no-heading"
              "--with-filename"
              "--line-number"
              "--column"
              "--smart-case"
              "--hidden"
              "--glob"
              "!.git/*"
            ];
            settings.pickers.find_files.find_command = [
              "rg"
              "--files"
              "--hidden"
              "--glob"
              "!.git/*"
            ];
          };
          oil.enable = true;
          nvim-tree.enable = true;
          yazi.enable = true;
          harpoon.enable = true;
          treesitter = {
            enable = true;
            folding.enable = true;
          };
          cmp.enable = true;
          cmp-nvim-lsp.enable = true;
          cmp-buffer.enable = true;
          cmp-path.enable = true;
          luasnip.enable = true;
          image = {
            enable = true;
            integrations.neorg.enable = false;
            integrations.markdown.enable = true;
          };
          glow.enable = true;
          web-devicons.enable = true;
          lualine.enable = true;
          bufferline.enable = true;
          indent-blankline.enable = true;
          zen-mode.enable = true;
          which-key = {
            enable = true;
            settings.delay = 200;
          };
          gitsigns.enable = true;
          fugitive.enable = true;
          markdown-preview = {
            enable = true;
            autoLoad = true;
          };
        };
        extraPlugins = [
          {
            plugin = pkgs.vimUtils.buildVimPlugin {
              name = "d2";
              src = pkgs.fetchFromGitHub {
                owner = "terrastruct";
                repo = "d2-vim";
                rev = "master";
                sha256 = "0c6sg882mb6za9zgv83h1jcc9q9y0ppfqpm4q9vmyj98w9yd0q0y";
              };
            };
            config = "let g:d2_fmt_autosave = 1\nlet g:d2_ascii_autorender = 1\nlet g:d2_ascii_preview_width = 80";
          }
          {
            plugin = pkgs.vimUtils.buildVimPlugin {
              name = "live-server";
              src = pkgs.fetchFromGitHub {
                owner = "barrett-ruth";
                repo = "live-server.nvim";
                rev = "main";
                sha256 = "0hfgcz01l38arz51szbcn9068zlsnf4wsh7f9js0jfw3r140gw6h";
              };
            };
            config = "";
          }
        ];
        keymaps = [
          {
            mode = "i";
            key = "jk";
            action = "<Esc>";
            options.desc = "Exit insert mode";
          }
          {
            mode = "n";
            key = "<C-h>";
            action = "<C-w>h";
            options.desc = "Left window";
          }
          {
            mode = "n";
            key = "<C-j>";
            action = "<C-w>j";
            options.desc = "Bottom window";
          }
          {
            mode = "n";
            key = "<C-k>";
            action = "<C-w>k";
            options.desc = "Top window";
          }
          {
            mode = "n";
            key = "<C-l>";
            action = "<C-w>l";
            options.desc = "Right window";
          }
          {
            mode = "n";
            key = "gd";
            action = "<cmd>lua vim.lsp.buf.definition()<cr>";
            options.desc = "Go to definition";
          }
          {
            mode = "n";
            key = "gr";
            action = "<cmd>lua vim.lsp.buf.references()<cr>";
            options.desc = "Go to references";
          }
          {
            mode = "n";
            key = "K";
            action = "<cmd>lua vim.lsp.buf.hover()<cr>";
            options.desc = "Hover";
          }
          {
            mode = "n";
            key = "za";
            action = "za";
            options.desc = "Toggle fold";
          }
          {
            mode = "n";
            key = "zR";
            action = "zR";
            options.desc = "Open all folds";
          }
          {
            mode = "n";
            key = "zM";
            action = "zM";
            options.desc = "Close all folds";
          }
          {
            mode = "n";
            key = "<leader>ca";
            action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
            options.desc = "Code actions";
          }
          {
            mode = "n";
            key = "<leader>cf";
            action = "<cmd>lua vim.lsp.buf.format()<cr>";
            options.desc = "Format";
          }
          {
            mode = "n";
            key = "<leader>cr";
            action = "<cmd>lua vim.lsp.buf.rename()<cr>";
            options.desc = "Rename";
          }
          {
            mode = "n";
            key = "<leader>cb";
            action = "<cmd>!nix build<cr>";
            options.desc = "Nix build";
          }
          {
            mode = "n";
            key = "<leader>cc";
            action = "<cmd>!nix flake check<cr>";
            options.desc = "Nix check";
          }
          {
            mode = "n";
            key = "<leader>sd";
            action = "<cmd>lua vim.diagnostic.setloclist()<cr>";
            options.desc = "Diagnostics list";
          }
          {
            mode = "n";
            key = "<leader>sl";
            action = "<cmd>lua vim.diagnostic.open_float()<cr>";
            options.desc = "Line diagnostics";
          }
          {
            mode = "n";
            key = "<leader>sn";
            action = "<cmd>lua vim.diagnostic.goto_next()<cr>";
            options.desc = "Next diagnostic";
          }
          {
            mode = "n";
            key = "<leader>sp";
            action = "<cmd>lua vim.diagnostic.goto_prev()<cr>";
            options.desc = "Prev diagnostic";
          }
          {
            mode = "n";
            key = "<leader>if";
            action = "<cmd>Telescope find_files<cr>";
            options.desc = "Find files";
          }
          {
            mode = "n";
            key = "<leader>ig";
            action = "<cmd>Telescope live_grep<cr>";
            options.desc = "Live grep";
          }
          {
            mode = "n";
            key = "<leader>ib";
            action = "<cmd>Telescope buffers<cr>";
            options.desc = "Buffers";
          }
          {
            mode = "n";
            key = "<leader>mh";
            action = "<cmd>Telescope help_tags<cr>";
            options.desc = "Help";
          }
          {
            mode = "n";
            key = "<leader>mk";
            action = "<cmd>Telescope keymaps<cr>";
            options.desc = "Keymaps";
          }
          {
            mode = "n";
            key = "<leader>e";
            action = "<cmd>Oil<cr>";
            options.desc = "File explorer";
          }
          {
            mode = "n";
            key = "<leader>it";
            action = "<cmd>NvimTreeToggle<cr>";
            options.desc = "File tree";
          }
          {
            mode = "n";
            key = "<leader>ia";
            action.__raw = "function() require('harpoon'):list():add() end";
            options.desc = "Harpoon add";
          }
          {
            mode = "n";
            key = "<leader>ih";
            action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end";
            options.desc = "Harpoon menu";
          }
          {
            mode = "n";
            key = "<leader>i1";
            action.__raw = "function() require('harpoon'):list():select(1) end";
            options.desc = "Harpoon 1";
          }
          {
            mode = "n";
            key = "<leader>i2";
            action.__raw = "function() require('harpoon'):list():select(2) end";
            options.desc = "Harpoon 2";
          }
          {
            mode = "n";
            key = "<leader>i3";
            action.__raw = "function() require('harpoon'):list():select(3) end";
            options.desc = "Harpoon 3";
          }
          {
            mode = "n";
            key = "<leader>i4";
            action.__raw = "function() require('harpoon'):list():select(4) end";
            options.desc = "Harpoon 4";
          }
          {
            mode = "n";
            key = "<leader>li";
            action = "<cmd>LeanInfoviewToggle<cr>";
            options.desc = "Lean infoview";
          }
          {
            mode = "n";
            key = "<leader>lr";
            action = "<cmd>terminal<cr>";
            options.desc = "Terminal";
          }
          {
            mode = "n";
            key = "<leader>io";
            action = "<cmd>!open %<cr>";
            options.desc = "Open in app";
          }
          {
            mode = "n";
            key = "<leader>dj";
            action = "<cmd>%!jq .<cr>";
            options.desc = "Format JSON";
          }
          {
            mode = "n";
            key = "<leader>dy";
            action = "<cmd>%!yq .<cr>";
            options.desc = "Format YAML";
          }
          {
            mode = "v";
            key = "<leader>dj";
            action = ":'<,'>!jq .<cr>";
            options.desc = "Format selection";
          }
          {
            mode = "n";
            key = "<leader>rr";
            action = "<cmd>PreviewToggle<cr>";
            options.desc = "Render toggle";
          }
          {
            mode = "n";
            key = "<leader>rq";
            action = "<cmd>PreviewStop<cr>";
            options.desc = "Render stop";
          }
          {
            mode = "n";
            key = "<leader>rs";
            action = "<cmd>PreviewSend<cr>";
            options.desc = "Render send";
          }
          {
            mode = "n";
            key = "<leader>rm";
            action = "<cmd>MarkdownPreview<cr>";
            options.desc = "Markdown preview";
          }
          {
            mode = "n";
            key = "<leader>rl";
            action = "<cmd>LiveServerStart<cr>";
            options.desc = "Live server";
          }
          {
            mode = "n";
            key = "<leader>rx";
            action = "<cmd>LiveServerStop<cr>";
            options.desc = "Live server stop";
          }
          {
            mode = "n";
            key = "<leader>rd";
            action = "<cmd>!d2 --watch --browser % %:r.svg &<cr>";
            options.desc = "D2 live";
          }
          {
            mode = "n";
            key = "<leader>r3";
            action = "<cmd>!f3d %<cr>";
            options.desc = "3D preview";
          }
          {
            mode = "n";
            key = "<leader>rv";
            action = "<cmd>!mpv %<cr>";
            options.desc = "Video";
          }
          {
            mode = "n";
            key = "<leader>ra";
            action = "<cmd>!ffplay -autoexit %<cr>";
            options.desc = "Audio";
          }
        ];
        extraConfigLua = ''
          local M = {}
          M.job_id = nil
          function M.start()
            if M.job_id then return end
            M.job_id = vim.fn.jobstart({"asset-preview"}, {
              env = { PREVIEW_PORT = tostring(vim.g.asset_preview_port or 9876), PREVIEW_CONVERTERS = vim.g.asset_preview_converters or "{}" },
              on_exit = function() M.job_id = nil end,
              on_stderr = function(_, data) for _, line in ipairs(data) do if line ~= "" then vim.schedule(function() vim.notify("[preview] " .. line, vim.log.levels.DEBUG) end) end end end,
            })
            vim.defer_fn(function() local port = vim.g.asset_preview_port or 9876; local browser = vim.g.asset_preview_browser or "open"; vim.fn.jobstart({browser, "http://127.0.0.1:" .. port}, {detach = true}) end, 500)
          end
          function M.stop() if M.job_id then vim.fn.jobstop(M.job_id); M.job_id = nil end end
          function M.toggle() if M.job_id then M.stop() else M.start() end end
          function M.send(filepath) if not M.job_id then return end; local port = vim.g.asset_preview_port or 9876; local json = vim.fn.json_encode({file = filepath}); vim.fn.jobstart({"curl", "-sX", "POST", "http://127.0.0.1:" .. port .. "/preview", "-d", json}, {detach = true}) end
          function M.send_current() local path = vim.fn.expand("%:p"); if path ~= "" then M.send(path) end end
          vim.api.nvim_create_user_command("PreviewStart", function() M.start() end, {})
          vim.api.nvim_create_user_command("PreviewStop", function() M.stop() end, {})
          vim.api.nvim_create_user_command("PreviewToggle", function() M.toggle() end, {})
          vim.api.nvim_create_user_command("PreviewSend", function() M.send_current() end, {})
          vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, { callback = function() if M.job_id then vim.defer_fn(function() M.send_current() end, 100) end end })
          _G.AssetPreview = M
        '';
      };
  };
}
