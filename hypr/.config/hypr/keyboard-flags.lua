-- Shared, tracked flags. Read on every Hyprland reload so no logout is needed.
-- The shared env file takes precedence so Hyprland and systemd agree.
local values = {}
local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local file = io.open(config_home .. "/jrtilak-layout/flags.env", "r")
if file then
  for line in file:lines() do
    local key, value = line:match("^%s*([A-Z_]+)%s*=%s*([01])%s*$")
    if key then values[key] = value end
  end
  file:close()
end
local function enabled(name)
  return (values[name] or os.getenv(name) or "0") == "1"
end
return {
  disable_compose = enabled("JRTILAK_DISABLE_COMPOSE"),
  layout = enabled("JRTILAK_LAYOUT"),
}
