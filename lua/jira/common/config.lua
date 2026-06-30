---@class Jira.Common.Config
local M = {}

local FALLBACKS = {
  story_point_field = "customfield_10035",
  custom_fields = {
    -- { key = "customfield_10016", label = "Acceptance Criteria" }
  },
}

---@class JiraAuthOptions
---@field base? string URL of your Jira instance (e.g. https://your-domain.atlassian.net)
---@field email? string Your Jira email (required for basic auth)
---@field token? string Your Jira API token or PAT
---@field type? "basic"|"pat" Authentication type (default: "basic")
---@field api_version? "2"|"3" API version to use (default: "3")
---@field limit? number Global limit of tasks when calling API
---@field logging? boolean Enable HTTP request/response logging (default: false)

---@class JiraConfig
---@field jira JiraAuthOptions
---@field projects? table<string, table> Project-specific overrides
---@field active_sprint_query? string JQL for active sprint tab
---@field queries? table<string, string> Saved JQL queries
M.defaults = {
  jira = {
    api_version = "3",
    limit = 200,
    logging = false,
  },
  projects = {},
  active_sprint_query = "project = '%s' AND sprint in openSprints() ORDER BY Rank ASC",
  queries = {
    ["Next sprint"] = "project = '%s' AND sprint in futureSprints() ORDER BY Rank ASC",
    ["Backlog"] = "project = '%s' AND (issuetype IN standardIssueTypes() OR issuetype = Sub-task) AND (sprint IS EMPTY OR sprint NOT IN openSprints()) AND statusCategory != Done ORDER BY Rank ASC",
    ["My Tasks"] = "assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC",
  },

  -- Timer configuration
  timer = {
    auto_save_interval = 60, -- Save timer state every 60 seconds
    format = "%H:%M:%S", -- Time format (hours:minutes:seconds)
    -- Auto-tracking options
    auto_start_on_branch_change = true, -- Auto-start timer when entering branch with issue key
    auto_log_on_branch_change = true, -- Prompt to log time when switching branches
    auto_log_on_exit = true, -- Prompt to log time when closing Neovim
    minimum_log_seconds = 60, -- Minimum seconds before prompting to log (1 minute)
    skip_log_comment = true, -- Skip comment prompt for auto-logging
    branch_check_events = { "FocusGained", "BufEnter", "VimResume" }, -- Events that trigger branch check
  },

  -- Statusline configuration
  statusline = {
    enabled = true,
    mode = "lualine", -- 'standalone', 'lualine', or 'custom'
    format = "[%s] ⏱ %s", -- Format: [ISSUE-KEY] ⏱ HH:MM:SS
    show_when_inactive = false, -- Show issue even when timer is not running
    separator = " | ",
    position = "right", -- Position in statusline: 'left', 'center', or 'right'
  },

  -- Git branch patterns to extract Jira issue keys
  branch_patterns = {
    "([A-Z]+%-[0-9]+)", -- Standard PROJ-123 anywhere in branch name
    "feature/([A-Z]+%-[0-9]+)", -- feature/PROJ-123-description
    "bugfix/([A-Z]+%-[0-9]+)", -- bugfix/PROJ-123-description
    "hotfix/([A-Z]+%-[0-9]+)", -- hotfix/PROJ-123-description
  },

  -- Opiniated keymaps configuration
  keymaps = {
    enabled = true,
    prefix = "<leader>J",
  },
}

---@type JiraConfig
M.options = vim.deepcopy(M.defaults)

---@param opts JiraConfig
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})

  -- Set storage paths if not provided
  local data_path = M.get_data_dir()
  M.options.storage.auth_file = M.options.storage.auth_file or (data_path .. "/auth.json")
  M.options.storage.timer_file = M.options.storage.timer_file or (data_path .. "/timer.json")

  -- Create storage directory if it doesn't exist
  vim.fn.mkdir(data_path, "p")
  return M.options
end

---@param project_key string|nil
---@return table
function M.get_project_config(project_key)
  local projects = M.options.projects or {}
  local p_config = projects[project_key] or {}

  return {
    story_point_field = p_config.story_point_field or FALLBACKS.story_point_field,
    custom_fields = p_config.custom_fields or FALLBACKS.custom_fields,
  }
end

function M.get_data_dir()
  return vim.fn.stdpath("data") .. "/jira"
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
