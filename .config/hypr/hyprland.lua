-- monitors
hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1600@240",
    position = "0x0",
    scale    = 1.667,
})

-- programs
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = os.getenv("HOME") .. "/.config/hypr/scripts/toggle_applauncher.sh"
local browser     = "brave"

-- autostart
hl.on("hyprland.start", function ()
  hl.exec_cmd("hyprpolkitagent")
  hl.exec_cmd("xdg-desktop-portal-hyprland")
  hl.exec_cmd("command -v hypridle >/dev/null 2>&1 && hypridle")
  hl.exec_cmd("quickshell -d -n")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/wall.sh --startup")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("kdeconnectd")
end)

-- environment variables
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_DATA_DIRS", os.getenv("HOME") .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- dynamic theme
local colors_file = os.getenv("HOME") .. "/.config/hypr/conf/colors.lua"
local ok, dyn_colors = pcall(dofile, colors_file)
if not ok or type(dyn_colors) ~= "table" then
    dyn_colors = {}
end

local active_border_1 = dyn_colors.primary or "rgba(33ccffee)"
local active_border_2 = dyn_colors.tertiary or dyn_colors.secondary or "rgba(00ff99ee)"
local inactive_border_col = dyn_colors.surface_container_high or dyn_colors.outline or "rgba(595959aa)"

-- appearance and window layout
hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = {4, 4, 4, 4},
        border_size = 1,
        col = {
            active_border   = { colors = { active_border_1, active_border_2 }, angle = 45 },
            inactive_border = inactive_border_col,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 6,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- animation curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

-- animations
hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- layouts
hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

-- misc
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})

-- input devices
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- per device config
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- keybindings
local mainMod = "SUPER"

-- launcher
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(menu), { release = true })

-- core apps
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))

-- lock screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/lock.sh"))

-- clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/clipboard.sh"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))

-- screenshot shortcuts
hl.bind("Print", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/screenshot.sh"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/screenshot.sh full"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/screenshot.sh full"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- fullscreen
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- focus movement
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- workspace navigation
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- special workspace
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- workspace scrolling
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- window dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- audio and brightness keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- media controls
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- wallpaper picker
hl.bind("ALT + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/wall.sh"))

-- window rules
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- picture in picture rule
hl.window_rule({
    name = "picture-in-picture",
    match = {
        title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$",
    },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    size = "(monitor_w*0.25) (monitor_h*0.25)",
    move = "(monitor_w*0.73) (monitor_h*0.72)",
})

-- hyprland run rule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})
