--[[ 80x

                \ \      /  __| __  / __ __|  __|  _ \   \  |
                 \ \ \  /   _|     /     |    _|     /  |\/ |
                  \_/\_/   ___| ____|   _|   ___| _|_\ _|  _|

================================================================================

 Files:
 - Filepath: $HOME/.config/wezterm/wezterm.lua

================================================================================

 Resources:
 - Git Repo: $BROWSER https://github.com/wez/wezterm
 - Official Site: $BROWSER https://wezfurlong.org/wezterm
 - Wez Furlong Official Site: $BROWSER https://wezfurlong.org/wezterm/index.html

--============================================================================]]
-- [1] Environment
--==============================================================================

local wezterm=require('wezterm')
local config={}
if wezterm.config_builder then config=wezterm.config_builder() end

--==============================================================================
-- [2] Settings
--==============================================================================

config.color_scheme='theme2 (terminal.sexy)'
config.font=wezterm.font_with_fallback({{family='Nimbus Mono PS', scale=0.8}})
config.window_background_opacity=0.8
config.window_decorations='RESIZE'
config.enable_tab_bar=false
config.scrollback_lines=3500
config.default_workspace='home'
config.status_update_interval=1000
return config