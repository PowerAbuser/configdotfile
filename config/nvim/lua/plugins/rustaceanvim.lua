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
          end, { desc = "Run Clippy", buffer = bufnr })
          vim.keymap.set("n", "<leader>cx", function()
            vim.cmd.RustLsp("flyCheck", "cancel")
          end, { desc = "Stop Clippy", buffer = bufnr })
          vim.keymap.set("n", "<leader>ce", function()
            vim.cmd.RustLsp("expandMacro")
          end, { desc = "Expand Macro Recursively", buffer = bufnr })
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
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
                "proc-macro-disabled",
                -- "proc-macros-disabled",
              },
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = {},
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
                ["sqlx-macros"] = { "query" },
                ["leptos_macro"] = { "component" },
              },
            },
          },
        },
      },
    },
  },
}
