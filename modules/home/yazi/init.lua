require ("git"):setup {
  order = 1500,
}

-- Remove permissions from status bar
Status:children_remove(4, Status.RIGHT)
