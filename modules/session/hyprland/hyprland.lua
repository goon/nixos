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
hl.env("XDG_SESSION_TYPE", "wayland")
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
        accel_profile = "flat",
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border = { colors = { "rgba(707389ff)", "rgba(555560ff)" }, angle = 45 },
            inactive_border = "rgba(252535ff)",
        },
        layout = "dwindle",
    },
    decoration = {
        rounding = 5,
        rounding_power = 2,
        active_opacity = 0.95,
        inactive_opacity = 0.95,
        blur = {
            enabled = true,
            size = 4,
            passes = 4,
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
})

-- Animation Curves

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("Bloom", { type = "bezier", points = { { 0.16, 1.12 }, { 0.24, 1 } } })
hl.curve("Settle", { type = "bezier", points = { { 0.18, 0.86 }, { 0.24, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 3.2, bezier = "Settle" })
hl.animation({ leaf = "windows", enabled = true, speed = 3.2, bezier = "Settle" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.8, bezier = "Bloom", style = "popin 78%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.4, bezier = "Settle", style = "popin 86%" })
hl.animation({ leaf = "border", enabled = true, speed = 3.5, bezier = "quick" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "almostLinear" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.2, bezier = "almostLinear" })
hl.animation({ leaf = "layers", enabled = true, speed = 7, bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 7, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 7, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "easeOutQuint", style = "slidefadevert 20%" })

-- Binds

local mainMod = "SUPER"

-- Applications

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("kitty -e nvim"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty --title float"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("qs ipc call settings toggle"))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("qs ipc call power toggle"))

-- Screenshot & Recording

hl.bind("Print", hl.dsp.exec_cmd("screenshot area"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty --filename -"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("recording screen"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("recording region"))

-- Power

hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind("CTRL + SHIFT + F10", hl.dsp.exit())
hl.bind("CTRL + SHIFT + F11", hl.dsp.exec_cmd("systemctl reboot"))
hl.bind("CTRL + SHIFT + F12", hl.dsp.exec_cmd("systemctl poweroff"))

-- Audio & Backlight

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true, repeating = true })

-- Window Management

hl.bind(mainMod .. " + X", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

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

local float_apps = {
    { class = "kitty",                  title = "^float$" },
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
        size = { 1000, 600 },
        center = true,
    })
end

-- Special Workspace Apps

hl.window_rule({
    match = { class = "^(vesktop|sonora)$" },
    workspace = "special:scratchpad",
})

-- Layer Rules

hl.layer_rule({
    match = { namespace = "yaks.*" },
    blur = true,
    ignore_alpha = 0.5,
    no_anim = true,
})

hl.layer_rule({
    name = "selection_no_anim",
    match = { namespace = "selection" },
    no_anim = true,
})

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    hl.exec_cmd("vesktop")
    hl.exec_cmd("sonora")
end)
