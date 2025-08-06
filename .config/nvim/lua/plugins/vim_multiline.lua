return {
  "mg979/vim-visual-multi",
  config = function()
    vim.g.VM_default_mappings = 0
  end,
  keys = {
    -- Define a table of keymappings.
    -- Each mapping is a table with the key, the command, the mode, and a description.
    -- The description will show up in which-key!
    {
      "<C-n>",
      "<Plug>(VM-Find-Under)",
      mode = "n",
      desc = "VM: Add cursor at next occurrence",
    },
    {
      "<C-p>",
      "<Plug>(VM-Find-Prev)",
      mode = "n",
      desc = "VM: Add cursor at previous occurrence",
    },
    {
      "<C-x>",
      "<Plug>(VM-Skip-And-Find-Under)",
      mode = "n",
      desc = "VM: Skip current and find next",
    },
    {
      "<S-Right>",
      "<Plug>(VM-Select-All)",
      mode = "n",
      desc = "VM: Select all occurrences",
    },

    -- Visual Mode Mappings
    {
      "<C-n>",
      "<Plug>(VM-Find-Under)",
      mode = "v",
      desc = "VM: Add cursor at next occurrence",
    },
    {
      "<C-p>",
      "<Plug>(VM-Find-Prev)",
      mode = "v",
      desc = "VM: Add cursor at previous occurrence",
    },
    {
      "<leader>m",
      mode = { "n", "v" },
      desc = "+Multi-Cursor",
      icon = "👥",
    },
    { "<leader>ma", "<Plug>(VM-Select-All)", mode = { "n", "v" }, desc = "Select All" },
    { "<leader>mc", "<Plug>(VM-Select-Cursor)", mode = { "n", "v" }, desc = "Select Cursor" },
    { "<leader>mj", "<Plug>(VM-Add-Cursor-Down)", mode = { "n", "v" }, desc = "Add Cursor Down" },
    { "<leader>mk", "<Plug>(VM-Add-Cursor-Up)", mode = { "n", "v" }, desc = "Add Cursor Up" },
    { "<leader>m/", "<Plug>(VM-Visual-Regex)", mode = "v", desc = "Select by Regex" },
  },
}
