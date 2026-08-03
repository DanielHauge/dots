require("monitors")

local terminal = "kitty --single-instance"
local fileManager = "thunar"
local menu = "walker -m desktopapplications"
local clipboards = "walker -m clipboard"
local packages = "walker -m archlinuxpkgs"
local symbols = "walker -m symbols"
local unicodes = "walker -m unicode"
local files = "walker -m files"
local editor = "nvim"
local browser = "firefox"

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("discord")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("waypaper --random --fill fill --folder /mnt/nas/wallpapers/")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("walker --gapplication-service")
    hl.exec_cmd("elephant")
    hl.exec_cmd("kdeconnectd")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("swaync")
    hl.exec_cmd("mm rss")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in = 5, gaps_out = 20, border_size = 2,
        col = { active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 }, inactive_border = "rgba(595959aa)" },
        resize_on_border = false, allow_tearing = false, layout = "dwindle",
    },
    decoration = {
        rounding = 15, active_opacity = 1.0,
        shadow = { enabled = true, range = 4, render_power = 3, color = 0xee1a1a1a },
        blur = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    master = { new_status = "master" },
    misc = { force_default_wallpaper = -1, disable_hyprland_logo = false },
    input = {
        kb_layout = "dk", kb_variant = "", kb_model = "", kb_options = "", kb_rules = "",
        follow_mouse = 1, sensitivity = 0, accel_profile = "flat",
        touchpad = { natural_scroll = true },
    },
})

hl.device({ name = "epic-mouse-v1", sensitivity = 1 })

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

local mainMod = "SUPER"
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("gmail-app"))
hl.bind(mainMod .. " + code:36", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + code:36", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(clipboards))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(packages))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(symbols))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(unicodes))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(files))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd([[pkill slurp || hyprshot -m ${1:-region} --raw | satty --filename - --early-exit --actions-on-enter save-to-clipboard --copy-command 'wl-copy']]))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("clip-rec region"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("clip-rec full"))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/rofi/applets/bin/powermenu.sh"))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + Z", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -60, y = 0 }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 60, y = 0 }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -60 }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 60 }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
