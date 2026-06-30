-- Prevent loading twice

if vim.g.loaded_jira_nvim then
  return
end
vim.g.loaded_jira_nvim = 1

-- Lazy load the plugin
local function get_plugin()
  return require("jira")
end

vim.api.nvim_create_user_command("Jira", function(opts)
  get_plugin().open(opts.args)
end, { nargs = "*" })
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
