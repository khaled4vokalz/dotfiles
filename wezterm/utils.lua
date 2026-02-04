local M = {}
local wezterm = require("wezterm")
local act = wezterm.action

-- Cross-platform binary path resolution
local function is_macos()
  return wezterm.target_triple:find("darwin") ~= nil
end

local function find_binary(name)
  local paths
  if is_macos() then
    paths = {
      "/opt/homebrew/bin/" .. name,
      "/usr/local/bin/" .. name,
      "/usr/bin/" .. name,
    }
  else
    paths = {
      "/usr/bin/" .. name,
      "/usr/local/bin/" .. name,
      "/home/" .. os.getenv("USER") .. "/.local/bin/" .. name,
    }
  end

  for _, path in ipairs(paths) do
    local f = io.open(path, "r")
    if f then
      f:close()
      return path
    end
  end

  -- Fallback: just return the name and hope it's in PATH
  return name
end

M.find_binary = find_binary

M.filter = function(tbl, callback)
  local filt_table = {}

  for i, v in ipairs(tbl) do
    if callback(v, i) then
      table.insert(filt_table, v)
    end
  end
  return filt_table
end

local function deep_merge(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" and type(t1[k]) == "table" then
      deep_merge(t1[k], v)
    else
      t1[k] = v
    end
  end
  return t1
end

M.kill_workspace = function(workspace)
  local wezterm_bin = find_binary("wezterm")
  local success, stdout = wezterm.run_child_process({ wezterm_bin, "cli", "list", "--format=json" })

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
        wezterm_bin,
        "cli",
        "kill-pane",
        "--pane-id=" .. p.pane_id,
      })
    end
  end
end

M.toggle = function(window, pane)
  local fd = find_binary("fd")
  local nvim = find_binary("nvim")
  local personalSourceDir = wezterm.home_dir .. "/personal"
  local workSourceDir = wezterm.home_dir .. "/workspace"
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
            act.SwitchToWorkspace({ name = id, spawn = { cwd = label, args = { "zsh", "--interactive", "--login", "-c", nvim } } }),
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

M.deep_merge = deep_merge

return M
