return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      -- Disable the system trash (`gio trash`): the /mnt/data mount has no
      -- writable .Trash-1000 dir, so trashing fails. Delete permanently instead.
      trash = false,
    },
  },
}
