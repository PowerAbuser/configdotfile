return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
          vim.keymap.set("n", "<leader>cb", function()
            vim.cmd.RustLsp("flyCheck")
          end, { desc = "Run Cargo Check", buffer = bufnr })
          vim.keymap.set("n", "<leader>cx", function()
            vim.cmd.RustLsp("flyCheck", "cancel")
          end, { desc = "Stop Clippy", buffer = bufnr })
          vim.keymap.set("n", "<leader>ce", function()
            vim.cmd.RustLsp("expandMacro")
          end, { desc = "Expand Macro Recursively", buffer = bufnr })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            check = {
              -- command = "check",
              command = "clippy",
            },
            cargo = {
              allFeatures = true,
              allTargets = false,
              loadOutDirsFromCheck = false,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust.
            checkOnSave = false,
            diagnostics = {
              enable = false,
              disabled = {
                -- "proc-macro-disabled",
              },
            },
            procMacro = {
              enable = true,
            },
          },
        },
      },
    },
  },
}
