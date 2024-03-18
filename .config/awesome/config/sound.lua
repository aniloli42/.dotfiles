local execute_cmd = require("utils.execute_cmd")

local function get_volume_status()
  local volume = execute_cmd(
    "pactl get-sink-volume $(pactl get-default-sink) | awk -F'[/,]' '{print $2}'"
  )

  local mute_status = execute_cmd(
    "pactl get-sink-mute $(pactl get-default-sink) | cut -d' ' -f 2"
  )

  return mute_status:gsub("%s+", "") == "no" and "🔊" .. volume or "🔇"
end

return get_volume_status
