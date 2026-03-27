return {
  "stevearc/aerial.nvim",
  event = "LazyFile",
  opts = function(_, opts)
    opts.manage_folds = true
    opts.link_tree_to_values = true

    -- 3. Optimization: Prefer Treesitter if LSP is flattening things
    -- Treesitter is often better at seeing 'impl' as a parent node
    opts.backends = { "treesitter", "lsp", "markdown", "man" }

    return opts
  end,
}
