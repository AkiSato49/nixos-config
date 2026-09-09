local status = {
  radio = "unknown",
  state = "unknown",
  technology = "",
  signal = "",
  carrier = "",
  rx = "",
  tx = "",
}

-- Emit a compact, stable protocol. Parsing mmcli's aligned human output inside
-- Luau caused fields in the tooltip to intermittently remain unknown.
local query = [=[
set -eu
nmcli=/run/current-system/sw/bin/nmcli
mmcli=/run/current-system/sw/bin/mmcli
awk=/run/current-system/sw/bin/awk
printf 'RADIO=%s\n' "$("$nmcli" radio wwan)"
"$mmcli" -m 0 -K | "$awk" -F ':' '
/^modem\.generic\.state[[:space:]]/ {gsub(/^[[:space:]]+/, "", $2); print "STATE=" $2}
/^modem\.generic\.access-technologies\.value\[1\][[:space:]]/ {gsub(/^[[:space:]]+/, "", $2); print "TECH=" $2}
/^modem\.generic\.signal-quality\.value[[:space:]]/ {gsub(/^[[:space:]]+/, "", $2); print "SIGNAL=" $2}
/^modem\.3gpp\.operator-name[[:space:]]/ {gsub(/^[[:space:]]+/, "", $2); print "CARRIER=" $2}
'
"$mmcli" -b 1 -K | "$awk" -F ':' '
/^bearer\.stats\.bytes-rx[[:space:]]/ {gsub(/^[[:space:]]+/, "", $2); print "RX=" $2}
/^bearer\.stats\.bytes-tx[[:space:]]/ {gsub(/^[[:space:]]+/, "", $2); print "TX=" $2}
'
]=]

local function value(lines, key)
  return string.match("\n" .. lines, "\n" .. key .. "=([^\r\n]*)") or ""
end

local function formatBytes(raw)
  local bytes = tonumber(raw)
  if not bytes then
    return "unknown"
  end

  local units = { "B", "KB", "MB", "GB", "TB" }
  local unit = 1
  while bytes >= 1024 and unit < #units do
    bytes = bytes / 1024
    unit = unit + 1
  end

  if unit == 1 then
    return string.format("%d B", bytes)
  end
  if bytes >= 10 then
    return string.format("%.0f %s", bytes, units[unit])
  end
  return string.format("%.1f %s", bytes, units[unit])
end

local function refresh()
  noctalia.runAsync({ "/bin/sh", "-c", query }, function(result)
    if result.exitCode ~= 0 then
      barWidget.setGlyph("antenna-bars-off")
      barWidget.setText("WWAN unavailable")
      barWidget.setTooltip("Mobile Data\nQuery failed: " .. result.stderr)
      return
    end

    status.radio = value(result.stdout, "RADIO")
    status.state = value(result.stdout, "STATE")
    status.technology = string.upper(value(result.stdout, "TECH"))
    status.signal = value(result.stdout, "SIGNAL")
    status.carrier = value(result.stdout, "CARRIER")
    status.rx = value(result.stdout, "RX")
    status.tx = value(result.stdout, "TX")

    local connected = status.radio == "enabled" and status.state == "connected"
    barWidget.setGlyph(connected and "antenna-bars-5" or "antenna-bars-off")
    if connected then
      barWidget.setText((status.technology ~= "" and status.technology or "MOBILE") .. " " .. (status.signal ~= "" and status.signal .. "%" or ""))
    else
      barWidget.setText("Mobile off")
    end

    barWidget.setTooltip(
      "Mobile Data\n"
      .. "Carrier: " .. (status.carrier ~= "" and status.carrier or "unknown") .. "\n"
      .. "State: " .. (status.state ~= "" and status.state or "unknown") .. " · " .. (status.radio ~= "" and status.radio or "unknown") .. "\n"
      .. "Signal: " .. (status.signal ~= "" and status.signal .. "%" or "unknown") .. " · " .. (status.technology ~= "" and status.technology or "unknown") .. "\n"
      .. "Session: ↓ " .. formatBytes(status.rx) .. " · ↑ " .. formatBytes(status.tx) .. "\n\n"
      .. "Left click: open Mobile Data\nRight click: open modem details"
    )
  end)
end

function update()
  noctalia.setUpdateInterval(5000)
  refresh()
end

function onClick()
  noctalia.togglePanel("lawliet/mobile-data:panel")
end

function onRightClick()
  noctalia.runInTerminal("/run/current-system/sw/bin/mmcli -m 0; echo; /run/current-system/sw/bin/mmcli -b 1; echo; printf 'Press Enter to close'; read _")
end
