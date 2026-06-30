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

-- Command: Start timer
-- Usage: :Jira time Start [issue-key]
vim.api.nvim_create_user_command("Jira time start", function(opts)
  local issue_key = opts.args ~= "" and opts.args or nil
  get_plugin().start_timer(issue_key)
end, {
  nargs = "?",
  desc = "Start Jira time tracker (auto-detects from branch or prompts)",
})

-- Command: Stop timer
-- Usage: :Jira time Stop
vim.api.nvim_create_user_command("Jira time stop", function()
  get_plugin().stop_timer()
end, {
  nargs = 0,
  desc = "Stop Jira time tracker",
})

-- Command: Log time to Jira
-- Usage: :Jira time Log [duration]
-- Examples: :Jira time Log 2h 30m
--           :Jira time Log 150m
--           :Jira time Log (uses current timer)
vim.api.nvim_create_user_command("Jira time log", function(opts)
  local duration = opts.args ~= "" and opts.args or nil
  get_plugin().log_time(nil, duration)
end, {
  nargs = "?",
  desc = "Log tracked time to Jira issue",
})

-- Command: View worklogs
-- Usage: :Jira time View [issue-key]
vim.api.nvim_create_user_command("Jira time view", function(opts)
  local issue_key = opts.args ~= "" and opts.args or nil
  get_plugin().view_worklogs(issue_key)
end, {
  nargs = "?",
  desc = "View worklogs for current or specified issue",
})

-- Command: Select issue
-- Usage: :Jira time Select
vim.api.nvim_create_user_command("Jira time select", function()
  get_plugin().select_issue()
end, {
  nargs = 0,
  desc = "Manually select a Jira issue",
})
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
