local wezterm = require 'wezterm'

local windows = wezterm.target_triple:find("windows")

local config = {}

config.color_scheme = 'Dracula'
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.window_background_opacity = 0.85
config.font = wezterm.font_with_fallback {
   "PlemolJP Console",
   "Symbols Nerd Font Mono",
   {family = "Cica", assume_emoji_presentation = true},
   "Noto Color Emoji",
}
config.font_size = 13
config.freetype_load_target = "Light"
config.freetype_load_flags = "NO_HINTING"

config.use_ime = true
config.treat_east_asian_ambiguous_width_as_wide = false
config.unicode_version = 14
config.enable_tab_bar = false
config.animation_fps = 1
config.window_close_confirmation = 'NeverPrompt'

config.front_end = "WebGpu"

config.keys = {
  {
    key = 'F11',
    mods = 'SHIFT',
    action = wezterm.action.ToggleFullScreen,
  },
}

if windows then
   config.default_domain = 'WSL:Gentoo'
   -- config.default_gui_startup_args = { 'ssh', 'localhost' }
   config.cell_width = 0.9
end

return config
