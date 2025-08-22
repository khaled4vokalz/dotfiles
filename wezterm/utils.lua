local M = {}
local wezterm = require("wezterm")
local act = wezterm.action

M.filter = function(tbl, callback)
	local filt_table = {}

	for i, v in ipairs(tbl) do
		if callback(v, i) then
			table.insert(filt_table, v)
		end
	end
	return filt_table
end

M.kill_workspace = function(workspace)
	local success, stdout = wezterm.run_child_process({ "/usr/bin/wezterm", "cli", "list", "--format=json" })

	if success then
		local json = wezterm.json_parse(stdout)
		if not json then
			return
		end

		local workspace_panes = M.filter(json, function(p)
			return p.workspace == workspace
		end)

		for _, p in ipairs(workspace_panes) do
			wezterm.run_child_process({
				"/usr/bin/wezterm",
				"cli",
				"kill-pane",
				"--pane-id=" .. p.pane_id,
			})
		end
	end
end

M.toggle = function(window, pane)
  local fd = "/opt/homebrew/bin/fd"
  local personalSourceDir = wezterm.home_dir ..  "/personal"
  local workSourceDir = wezterm.home_dir ..  "/workspace"
  local projects = {}

  local success, stdout, stderr = wezterm.run_child_process({
    fd,
    "--prune",
    "-HI",
    "-td",
    "^.git$",
    "--max-depth=2",
    personalSourceDir,
    workSourceDir,
    -- add more paths here
  })

  if not success then
    wezterm.log_error("Failed to run fd: " .. stderr)
    return
  end

  for line in stdout:gmatch("([^\n]*)\n?") do
    local project = line:gsub("/.git/$", "")
    local label = project
    local id = project:gsub(".*/", "")
    table.insert(projects, { label = tostring(label), id = tostring(id) })
  end

  window:perform_action(
    act.InputSelector({
      action = wezterm.action_callback(function(win, _, id, label)
        if not id and not label then
          wezterm.log_info("Cancelled")
        else
          wezterm.log_info("Selected " .. label)
          win:perform_action(
            act.SwitchToWorkspace({ name = id, spawn = { cwd = label } }),
            pane
          )
        end
      end),
      fuzzy = true,
      title = "Select project",
      choices = projects,
    }),
    pane
  )
end

return M
