# Render: external rendering — browser-based universal previewer
# Merges: Preview (asset-preview sidecar) + Web (live-server) + Documentation (markdown-preview)
{ config, lib, ... }:
let
  cfg = config.nixvim;
  pcfg = cfg.preview;
  luaPlugin = ''
    -- asset-preview: universal browser previewer
    local M = {}
    M.job_id = nil

    function M.start()
      if M.job_id then return end
      M.job_id = vim.fn.jobstart({"asset-preview"}, {
        env = {
          PREVIEW_PORT = tostring(vim.g.asset_preview_port or 9876),
          PREVIEW_CONVERTERS = vim.g.asset_preview_converters or "{}",
        },
        on_exit = function() M.job_id = nil end,
        on_stderr = function(_, data)
          for _, line in ipairs(data) do
            if line ~= "" then vim.schedule(function() vim.notify("[preview] " .. line, vim.log.levels.DEBUG) end) end
          end
        end,
      })
      vim.defer_fn(function()
        local port = vim.g.asset_preview_port or 9876
        local browser = vim.g.asset_preview_browser or "open"
        vim.fn.jobstart({browser, "http://127.0.0.1:" .. port}, {detach = true})
      end, 500)
    end

    function M.stop()
      if M.job_id then vim.fn.jobstop(M.job_id); M.job_id = nil end
    end

    function M.toggle()
      if M.job_id then M.stop() else M.start() end
    end

    function M.send(filepath)
      if not M.job_id then return end
      local port = vim.g.asset_preview_port or 9876
      local json = vim.fn.json_encode({file = filepath})
      vim.fn.jobstart({"curl", "-sX", "POST", "http://127.0.0.1:" .. port .. "/preview", "-d", json}, {detach = true})
    end

    function M.send_current()
      local path = vim.fn.expand("%:p")
      if path ~= "" then M.send(path) end
    end

    vim.api.nvim_create_user_command("PreviewStart", function() M.start() end, {})
    vim.api.nvim_create_user_command("PreviewStop", function() M.stop() end, {})
    vim.api.nvim_create_user_command("PreviewToggle", function() M.toggle() end, {})
    vim.api.nvim_create_user_command("PreviewSend", function() M.send_current() end, {})

    if vim.g.asset_preview_auto_switch then
      vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
        callback = function()
          if M.job_id then vim.defer_fn(function() M.send_current() end, 100) end
        end,
      })
    end

    _G.AssetPreview = M
  '';
in
{
  config.nixvim.extraConfigLua.render = lib.mkIf (cfg.enable && pcfg.enable) luaPlugin;

  config.nixvim.globals.render = lib.mkIf (cfg.enable && pcfg.enable) {
    asset_preview_port = pcfg.port;
    asset_preview_auto_switch = pcfg.autoSwitch;
    asset_preview_browser = pcfg.browser;
    asset_preview_converters = builtins.toJSON pcfg.converters;
  };

  config.nixvim.extraPackages = lib.mkIf (cfg.enable && pcfg.enable) [ "asset-preview" ];

  # live-server for HTML hot reload
  config.nixvim.extraPluginConfigs.live-server = lib.mkIf cfg.enable {
    owner = "barrett-ruth";
    repo = "live-server.nvim";
    rev = "main";
    sha256 = "0hfgcz01l38arz51szbcn9068zlsnf4wsh7f9js0jfw3r140gw6h";
    config = "";
  };

  # markdown-preview for browser markdown
  config.nixvim.plugins.render = lib.mkIf cfg.enable {
    markdown-preview = {
      enable = true;
      autoLoad = true;
    };
  };

  config.nixvim.keymaps.render = lib.mkIf cfg.enable [
    # Universal preview (asset-preview sidecar)
    { mode = "n"; key = "<leader>rr"; action = "<cmd>PreviewToggle<cr>"; options.desc = "Render toggle (browser)"; }
    { mode = "n"; key = "<leader>rq"; action = "<cmd>PreviewStop<cr>"; options.desc = "Render stop"; }
    { mode = "n"; key = "<leader>rs"; action = "<cmd>PreviewSend<cr>"; options.desc = "Render send current file"; }
    # Markdown browser preview
    { mode = "n"; key = "<leader>rm"; action = "<cmd>MarkdownPreview<cr>"; options.desc = "Markdown preview (browser)"; }
    # Live server (HTML)
    { mode = "n"; key = "<leader>rl"; action = "<cmd>LiveServerStart<cr>"; options.desc = "Live server start"; }
    { mode = "n"; key = "<leader>rx"; action = "<cmd>LiveServerStop<cr>"; options.desc = "Live server stop"; }
    # Fallback: direct tool keymaps
    { mode = "n"; key = "<leader>rd"; action = "<cmd>!d2 --watch --browser % %:r.svg &<cr>"; options.desc = "D2 live (direct)"; }
    { mode = "n"; key = "<leader>r3"; action = "<cmd>!f3d %<cr>"; options.desc = "3D preview (f3d direct)"; }
    { mode = "n"; key = "<leader>rv"; action = "<cmd>!mpv %<cr>"; options.desc = "Video (mpv direct)"; }
    { mode = "n"; key = "<leader>ra"; action = "<cmd>!ffplay -autoexit %<cr>"; options.desc = "Audio (ffplay direct)"; }
    { mode = "n"; key = "<leader>rG"; action = "<cmd>!godot --editor %:h/project.godot &<cr>"; options.desc = "Godot editor (direct)"; }
  ];
}
