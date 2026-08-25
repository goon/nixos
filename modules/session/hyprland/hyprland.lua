---@module 'hl'

-- Monitor

hl.monitor({
    output   = "DP-3",
    mode     = "3440x1440@160",
    position = "0x0",
    scale    = 1,
})

-- Environment Variables

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "28")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "28")

-- Configuration

hl.config({
    input = {
        kb_layout = "gb",
        repeat_delay = 200,
        repeat_rate = 35,
        numlock_by_default = true,
        follow_mouse = 1,
        accel_profile = "flat",
        force_no_accel = false,
        sensitivity = 0.0,
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        ["col.active_border"] = { colors = { "rgba(707389ff)", "rgba(555560ff)" }, angle = 45 },
        ["col.inactive_border"] = "rgba(252535ff)",
        layout = "dwindle",
    },
    decoration = {
        rounding = 5,
        rounding_power = 2,
        blur = {
            enabled = true,
            size = 4,
            passes = 4,
            new_optimizations = true,
            xray = false,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xEE121212,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        orientation = "center",
        slave_count_for_center_master = 0,
    },
})

-- Animation Curves

hl.curve("spring_menu", { type = "spring", mass = 1, stiffness = 80, dampening = 14 })
hl.curve("spring_window", { type = "spring", mass = 1, stiffness = 30, dampening = 8 })
hl.curve("spring_open", { type = "spring", mass = 1, stiffness = 30, dampening = 8 })
hl.curve("spring_workspace", { type = "spring", mass = 1.2, stiffness = 30, dampening = 10 })
hl.curve("spring_special", { type = "spring", mass = 1, stiffness = 30, dampening = 8 })

-- Binds

local mainMod = "SUPER"

-- Applications

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("kitty -e nvim"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty --class float"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("qs ipc call settings toggle"))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("qs ipc call power toggle"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("qs ipc call dashboard toggle"))
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("qs ipc call clipboard toggle"))

-- Screenshot & Recording

hl.bind("Print", hl.dsp.exec_cmd("screenshot area"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty --filename -"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("recording screen"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("recording region"))

-- Power

hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprctl dispatch dpms off"))

-- Audio & Backlight

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))

-- Window Management

local layouts = { "scrolling", "dwindle", "master" }
local workspace_layouts = {}

hl.bind("CTRL + SHIFT + L", function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    local ws_id = tostring(ws.id)

    local current_idx = workspace_layouts[ws_id] or 1
    local next_idx = (current_idx % #layouts) + 1
    workspace_layouts[ws_id] = next_idx

    local new_layout = layouts[next_idx]
    local display_name = new_layout:gsub("^%l", string.upper)

    hl.workspace_rule({ workspace = ws_id, layout = new_layout })
    local icon_path = os.getenv("HOME") .. "/.config/hypr/hyprland.svg"
    hl.dispatch(hl.dsp.exec_cmd("notify-send -i " .. icon_path .. " 'Workspace " .. ws_id .. "' 'The layout has been changed to <b>" .. display_name .. "</b>'"))
end)

hl.bind(mainMod .. " + X", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())

local directions = {
    { key = "H",     dir = "l" },
    { key = "L",     dir = "r" },
    { key = "K",     dir = "u" },
    { key = "J",     dir = "d" },
    { key = "Left",  dir = "l" },
    { key = "Right", dir = "r" },
    { key = "Up",    dir = "u" },
    { key = "Down",  dir = "d" },
}
for _, item in ipairs(directions) do
    hl.bind(mainMod .. " + " .. item.key, hl.dsp.focus({ direction = item.dir }))
    hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. item.key, hl.dsp.window.swap({ direction = item.dir }))
end

hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + W", hl.dsp.group.toggle())

-- Workspaces

for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Mouse Binds

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Rules

hl.window_rule({
    match = { title = ".*" },
    opacity = "0.95 0.95",
})


local float_apps = {
    { class = "^float$" },
    { class = "^com.gabm.satty$" },
    { title = "^Picture-in-[Pp]icture$" },
}
for _, match_criteria in ipairs(float_apps) do
    local pattern = match_criteria.class or match_criteria.title or ""
    local name_suffix = pattern:gsub("[^%w]", "")
    hl.window_rule({
        name = "float_" .. name_suffix,
        match = match_criteria,
        float = true,
        size = "1000 600",
        center = true,
    })
end

-- Special Workspace Apps

hl.workspace_rule({
    workspace = "special:scratchpad",
    layout = "dwindle",
})

hl.window_rule({
    match = { class = "vesktop" },
    workspace = "special:scratchpad",
})

hl.window_rule({
    match = { class = "Spotify" },
    workspace = "special:scratchpad",
})

-- Layer Rules 

hl.layer_rule({
    match = { namespace = "yaks.*" },
    blur = true,
    ignore_alpha = 0.5,
})

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start hyprland-session.target")

    hl.exec_cmd("setpriv --ambient-caps -all vesktop")
    hl.exec_cmd("setpriv --ambient-caps -all spotify")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

-- Event Listeners
hl.on("workspace.active", function()
    local active_special = hl.get_active_special_workspace()
    if active_special and active_special ~= "" and active_special ~= false then
        hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
    end
end)
