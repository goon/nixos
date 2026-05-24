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

-- Input

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
})

-- General Layout

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        ["col.active_border"] = { colors = { "rgba(d4be98ff)", "rgba(7c6f64ff)" }, angle = 45 },
        ["col.inactive_border"] = "rgba(252535ff)",
        layout = "scrolling",
    },
})

-- Decoration

hl.config({
    decoration = {
        rounding = 10,
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
            color = "rgba(1F1F28ff)",
        },
    },
})

-- Animations

hl.config({
    animations = {
        enabled = true,
    },
})

-- Dwindle Layout

hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        orientation = "center",
    },
})

-- Binds

local mainMod = "SUPER"

-- Applications

hl.bind(mainMod .. " + " .. "RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind(mainMod .. " + " .. "N", hl.dsp.exec_cmd("kitty -e nvim"))
hl.bind(mainMod .. " + " .. "B", hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + " .. "M", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("kitty --class float"))
hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mainMod .. " + " .. "G", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind(mainMod .. " + " .. "S", hl.dsp.exec_cmd("qs ipc call settings toggle"))
hl.bind(mainMod .. " + " .. "P", hl.dsp.exec_cmd("qs ipc call power toggle"))

-- Screenshot (mimicking Niri's screenshot tool might need grim/slurp)

hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("CTRL" .. " + " .. "Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- Power

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Q", hl.dsp.exit())
hl.bind("CTRL + ALT" .. " + " .. "Delete", hl.dsp.exit())
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "P", hl.dsp.exec_cmd("hyprctl dispatch dpms off"))

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

hl.bind("CTRL" .. " + " .. "SHIFT" .. " + " .. "L", function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    local ws_id = tostring(ws.id)
    
    local current_idx = workspace_layouts[ws_id] or 1
    local next_idx = (current_idx % #layouts) + 1
    workspace_layouts[ws_id] = next_idx
    
    local new_layout = layouts[next_idx]
    
    hl.workspace_rule({ workspace = ws_id, layout = new_layout })
    hl.dispatch(hl.dsp.exec_cmd("notify-send 'Workspace " .. ws_id .. " Layout' '" .. new_layout .. "'"))
end)

hl.bind(mainMod .. " + " .. "X", hl.dsp.window.close())
hl.bind(mainMod .. " + " .. "V", hl.dsp.window.float())
hl.bind(mainMod .. " + " .. "F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + " .. "H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + " .. "L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + " .. "K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + " .. "J", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + " .. "Left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + " .. "Right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + " .. "Up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + " .. "Down", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + " .. "Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + " .. "W", hl.dsp.group.toggle())

hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "H", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "L", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "K", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "J", hl.dsp.window.swap({ direction = "d" }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "Left", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "Right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "Up", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "Down", hl.dsp.window.swap({ direction = "d" }))

-- Workspaces

hl.bind(mainMod .. " + " .. 1, hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + " .. 2, hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + " .. 3, hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + " .. 4, hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + " .. 5, hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + " .. 6, hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + " .. 7, hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + " .. 8, hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + " .. 9, hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 1, hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 2, hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 3, hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 4, hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 5, hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 6, hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 7, hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 8, hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. 9, hl.dsp.window.move({ workspace = 9 }))

-- Mouse Binds

hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Rules

hl.window_rule({
    name  = "float_pip",
    match = {
        class = "^brave-browser$",
        title = "^Picture-in-Picture$",
    },
    float = true,
})

hl.window_rule({
    name = "float",
    match = {
        class = "^float$",
    },
    float = true,
    size = "1250 800",
    center = true,
})

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell")
    hl.exec_cmd("vesktop")
    hl.exec_cmd("spotify")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)
