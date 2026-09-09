local state = {
  radio = "unknown",
  modem = "unknown",
  technology = "unknown",
  signal = "unknown",
  carrier = "unknown",
  rx = "unknown",
  tx = "unknown",
  loading = false,
  error = "",
}

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
  return string.match("\n" .. lines, "\n" .. key .. "=([^\r\n]*)") or "unknown"
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

local function detail(label, value)
  return ui.row({ gap = 12, align = "center" }, {
    ui.label({ text = label, color = "on_surface_variant", flexGrow = 1 }),
    ui.label({ text = value }),
  })
end

local function render()
  local enabled = state.radio == "enabled"
  local connected = enabled and state.modem == "connected"
  local heading = connected and "Connected" or (enabled and "Connecting" or "Mobile data off")
  local toggleText = enabled and "Turn off" or "Turn on"

  panel.render(ui.column({ flexGrow = 1, gap = 16, align = "stretch" }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "Mobile Data", fontSize = 18, fontWeight = "bold", flexGrow = 1 }),
      ui.button({ glyph = "close", variant = "ghost", onClick = "onClose" }),
    }),
    ui.row({ gap = 10, align = "center" }, {
      ui.glyph({ name = connected and "antenna-bars-5" or "antenna-bars-off", size = 28, color = connected and "primary" or "on_surface_variant" }),
      ui.column({ gap = 2, flexGrow = 1 }, {
        ui.label({ text = heading, fontWeight = "bold" }),
        ui.label({ text = state.carrier .. " · " .. state.technology, color = "on_surface_variant" }),
      }),
    }),
    ui.column({ gap = 8, padding = 12, fill = "surface_variant/0.5", radius = 10 }, {
      detail("Signal", state.signal == "unknown" and "unknown" or state.signal .. "%"),
      detail("Modem", state.modem),
      detail("Session download", formatBytes(state.rx)),
      detail("Session upload", formatBytes(state.tx)),
    }),
    state.error ~= "" and ui.label({ text = state.error, color = "error" }) or ui.spacer({ height = 0 }),
    ui.row({ gap = 8, justify = "end" }, {
      ui.button({ text = "Refresh", glyph = "refresh", variant = "outline", onClick = "onRefresh", enabled = not state.loading }),
      ui.button({ text = toggleText, glyph = enabled and "power" or "antenna", variant = enabled and "destructive" or "primary", onClick = "onToggle", enabled = not state.loading }),
    }),
  }))
end

local function refresh()
  state.loading = true
  state.error = ""
  render()
  noctalia.runAsync({ "/bin/sh", "-c", query }, function(result)
    state.loading = false
    if result.exitCode ~= 0 then
      state.error = result.stderr ~= "" and result.stderr or "Modem query failed"
      render()
      return
    end
    state.radio = value(result.stdout, "RADIO")
    state.modem = value(result.stdout, "STATE")
    state.technology = string.upper(value(result.stdout, "TECH"))
    state.signal = value(result.stdout, "SIGNAL")
    state.carrier = value(result.stdout, "CARRIER")
    state.rx = value(result.stdout, "RX")
    state.tx = value(result.stdout, "TX")
    render()
  end)
end

function onOpen()
  refresh()
end

function onRefresh()
  refresh()
end

function onToggle()
  local target = state.radio == "enabled" and "off" or "on"
  state.loading = true
  render()
  noctalia.runAsync({ "/run/current-system/sw/bin/nmcli", "radio", "wwan", target }, function(result)
    if result.exitCode ~= 0 then
      state.loading = false
      state.error = result.stderr ~= "" and result.stderr or "Could not change WWAN state"
      render()
      return
    end
    refresh()
  end)
end

function onClose()
  panel.close()
end
