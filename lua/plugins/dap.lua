return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mxsdev/nvim-dap-vscode-js",
      -- build debugger from source
      {
        "microsoft/vscode-js-debug",
        version = "1.x",
        build = "npm i && npm run compile vsDebugServerBundle && mv dist out",
      },
    },
    config = function()
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
      })
      -- vscode-js-debug (js-debug-adapter in Mason)
      -- require("dap-vscode-js").setup({
      --   debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
      --   debugger_cmd = { "js-debug-adapter" },
      --   adapters = {
      --     "pwa-node",
      --     "pwa-chrome",
      --     "pwa-msedge",
      --     "node-terminal",
      --     "pwa-extensionHost",
      --   },
      -- })
      for _, language in ipairs({
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        -- using pwa-chrome
        "vue",
        "svelte",
      }) do
        require("dap").configurations[language] = {
          -- attach to a node process that has been started with
          -- `--inspect` for longrunning tasks or `--inspect-brk` for short tasks
          -- npm script -> `node --inspect-brk ./node_modules/.bin/vite dev`
          {
            -- use nvim-dap-vscode-js's pwa-node debug adapter
            type = "pwa-node",
            -- attach to an already running node process with --inspect flag
            -- default port: 9222
            request = "attach",
            -- allows us to pick the process using a picker
            processId = require("dap.utils").pick_process,
            -- name of the debug action you have to select for this config
            name = "Attach debugger to existing `node --inspect` process",
            -- for compiled languages like TypeScript or Svelte.js
            sourceMaps = true,
            -- resolve source maps in nested locations while ignoring node_modules
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
            -- path to src in vite based projects (and most other projects as well)
            cwd = "${workspaceFolder}/src",
            -- we don't want to debug code inside node_modules, so skip it!
            skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
          },
          {
            type = "pwa-chrome",
            name = "Launch Chrome to debug client",
            request = "launch",
            url = "http://localhost:5173",
            sourceMaps = true,
            protocol = "inspector",
            port = 9222,
            webRoot = "${workspaceFolder}/src",
            -- skip files from vite's hmr
            skipFiles = { "**/node_modules/**/*", "**/@vite/*", "**/src/client/*", "**/src/*" },
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch (Node)",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "npx",
            runtimeArgs = { "tsx" },
          },
          {
            request = "launch",
            name = "Deno launch",
            type = "pwa-node",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "deno",
            runtimeArgs = { "run", "--inspect-brk", "-A" },
            attachSimplePort = 9229,
          },
        }
      end

      -- require("dapui").setup()
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local dap, dapui = require("dap"), require("dapui")
          dapui.setup()
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({ reset = true })
          end
          dap.listeners.before.event_terminated["dapui_config"] = dapui.close
          dap.listeners.before.event_exited["dapui_config"] = dapui.close
        end,
      })
    end,
  },
}
