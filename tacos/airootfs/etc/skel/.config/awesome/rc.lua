--[[ 100x
                              \  \ \      / __|   __|   _ \    \  |  __|
                             _ \  \ \ \  /  _|  \__ \  (   |  |\/ |  _|
                           _/  _\  \_/\_/  ___| ____/ \___/  _|  _| ___|

====================================================================================================

 Files:
 - Contributions: $HOME/.config/awesome/contrib
 - Filepath: $HOME/.config/awesome/rc.lua


 - Licence: $HOME/.config/awesome/licence

====================================================================================================

 Resources:
 - API Module Docs: $BROWSER https://awesomewm.org/doc/api
 - API Script Docs: $BROWSER https://awesomewm.org/apidoc
 - Arch Wiki: $BROWSER https://wiki.archlinux.org/title/Awesome
 - Awesome Freedesktop Repo: $BROWSER https://github.com/lcpz/awesome-desktop
 - Awesome Lain Repo: $BROWSER https://github.com/lcpz/lain
 - Awesome Repo: $BROWSER https://github.com/awesomeWM/awesome
 - Awesome Streetturtle Repo: https://github.com/streetturtle/awesome-wm-widgets
 - Awesome Vicious Repo: $BROWSER https://github.com/vicious-widgets/vicious

====================================================================================================

 References:
 - Awesome-client Manpage: man -P 'less +3 +/DESCRIPTION' 'awesomerc(5)'
 - Awesome Manpage: man -P 'less +9 +/DESCRIPTION' 'awesome(1)'
 - Awesomerc Manpage: man -P 'less +3 +/SYNOPSIS' 'awesomerc(5)'

--================================================================================================]]
-- [1] Setup
--==================================================================================================

-- Libraries
local awful=require('awful', 'awful.util', 'awful.autofocus')
local beautiful=require('beautiful')
local freedesktop=require('freedesktop.desktop')
local dpi=require('beautiful.xresources').apply_dpi
local gears=require('gears')
local hotkeys_popup=require('awful.hotkeys_popup').widget
--local hotkeys_popup=require('awful.hotkeys_popup.keys') -- Default layout
local menubar=require('menubar')
local naughty=require('naughty')
local lain=require('lain')
local wibox=require('wibox')

-- Environment
local home=os.getenv('HOME')
local config_dir=os.getenv('CONFIG') or home .. '/.config'
local awesome_dir=os.getenv('AWESOME_HOME') or config_dir .. '/awesome'
local configs_dir=awesome_dir .. '/configs'
local images_dir=awesome_dir .. '/images'
local scripts_dir=awesome_dir .. '/scripts'
local theme_dir=awesome_dir .. '/themes'
local icons_dir=theme_dir .. '/icons'
local theme_file=theme_dir .. '/tacos.lua'

-- Startup Errors
if awesome.startup_errors then naughty.notify({
	preset=naughty.config.presets.critical,
	title='Startup Error',
	text=awesome.startup_errors})
end

-- Runtime Errors
do local in_error=false
	awesome.connect_signal('debug::error', function(err)
		if in_error then return end
		in_error=true naughty.notify({
			preset=naughty.config.presets.critical,
			title='Runtime Error', text=tostring(err)})
		in_error=false
	end)
end

-- Key Variables
local alt='Mod1'
local shft='Shift'
local ctl='Control'
local mod='Mod4'

-- Preset Clients
local browser=os.getenv('BROWSER') or 'firefox'
local editorgui=os.getenv('GRAPHICAL') or 'geany'
local filemanager=os.getenv('FILEMANAGER') or 'nemo'
local mailclient=os.getenv('MAILCLIENT') or 'thunderbird'
local securemsg=os.getenv('SECUREMSG') or 'telegram-desktop'
local terminal=os.getenv('TERMINAL') or 'terminator'

-- Basic Styling
local themes={'tacos'}
local num=themes[1]
local choice=string.format('%s/%s.lua', theme_dir, num)
awful.util.tagnames={' 1  ',  ' 2  ',  ' 3  ',  ' 4  ',  ' 5  ',  ' 6  ',  ' 7  ',  ' 8  ',  ' 9  '}
awful.util.terminal=terminal
beautiful.init(choice)
beautiful.font='Nimbus Mono PS Bold 9.5'
--beautiful.wallpaper='/path/wallpaper'
beautiful.notification_font='Nimbus Mono PS Bold 9.5'
naughty.config.defaults['icon_size']=100

-- Adjust Brightness
local brightness=1.0
local function adjustBrightness(inc)
	brightness=math.min(1.0, math.max(0.1, brightness+(inc*0.1)))
	awful.spawn.with_shell('xrandr --output HDMI-1 --brightness ' .. tostring(brightness))
	awful.spawn.with_shell('xrandr --output eDP-1 --brightness ' .. tostring(brightness))
end

--==================================================================================================
-- [2] Client Behaviour
--==================================================================================================

-- Window Layouts
awful.layout.layouts={
	--awful.layout.suit.corner.ne,
	--awful.layout.suit.corner.nw,
	--awful.layout.suit.corner.se,
	--awful.layout.suit.corner.sw,
	--lain.layout.cascade,
	--lain.layout.cascade.tile,
	--lain.layout.centerwork,
	--lain.layout.centerwork.horizontal,
	--lain.layout.termfair,
	--lain.layout.termfair.center
	awful.layout.suit.floating, -- Default
	awful.layout.suit.tile, -- Secondary
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.magnifier,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.top,
}

-- Layout Specifics
--awful.layout.suit.tile.left.mirror=true
lain.layout.cascade.tile.extra_padding=dpi(5)
lain.layout.cascade.tile.ncol=2
lain.layout.cascade.tile.nmaster=5
lain.layout.cascade.tile.offset_x=dpi(2)
lain.layout.cascade.tile.offset_y=dpi(32)
lain.layout.termfair.center.ncol=1
lain.layout.termfair.center.nmaster=3
lain.layout.termfair.ncol=1
lain.layout.termfair.nmaster=3


-- Taglist Behaviour
awful.util.taglist_buttons=gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end), awful.button({mod}, 1,
	function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({ }, 3, awful.tag.viewtoggle), awful.button({mod}, 3,
	function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Tasklist Behaviour
awful.util.tasklist_buttons=gears.table.join(
	awful.button({ }, 1, function(c)
		if c == client.focus then c.minimized=true
		else c.minimized=false
			if not c:isvisible() and c.first_tag then c.first_tag:view_only() end
			client.focus=c c:raise()
		end
	end),
	awful.button({ }, 3, function() local instance=nil return
		function() if instance and instance.wibox.visible
			then instance:hide() instance=nil
			else instance=awful.menu.clients({theme={width=dpi(250)}})
			end
		end
	end),
	awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
	awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
)

-- Quake Terminal
dropdown=lain.util.quake({
	app='wezterm start',
	argname='--class %s',
	name='shittydropdown',
	height=0.5,
	followtag=true,
	visible=false
})

-- Awesome Menu
menu_icons={
	['Terminal']=icons_dir .. '/terminal.png',
	['Hotkeys']=icons_dir .. '/hotkeys.png',
	['Display']=icons_dir .. '/display.png',
	['Theme']=icons_dir .. '/theme.png',
	['Applications']=icons_dir .. '/applications.png',
	['Reload']=icons_dir .. '/logout.png',
	['Suspend']=icons_dir .. '/suspend.png',
	['Reboot']=icons_dir .. '/reboot.png',
	['Shutdown']=icons_dir .. '/shutdown.png'
}

-- Awesome Menu Behaviour
main_menu=awful.menu({
	items={
		{'Terminal', terminal, menu_icons['Terminal']},
		{'Hotkeys', function() return false, hotkeys_popup.show_help end, menu_icons['Hotkeys']},
		{'Display', 'arandr', menu_icons['Display']},
		{'Theme', 'lxappearance', menu_icons['Theme']},
		{'Applications',
			function()
				local c=client.focus
				if c then c.minimized=true end
				awful.spawn.easy_async(string.format('rofi -no-config -no-lazy-grab -show drun \
				-modi drun -theme ~/.config/awesome/configs/rofi.rasi',
				beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus),
				function() if c then c.minimized=false end end)
			end, menu_icons['Applications']},
		{'Reload', function() awesome.restart() end, menu_icons['Reload']},
		{'Suspend', 'systemctl suspend', menu_icons['Suspend']},
		{'Reboot', 'systemctl reboot', menu_icons['Reboot']},
		{'Shutdown', 'systemctl poweroff', menu_icons['Shutdown']}}}
)

-- Initialize Awesome Menu
menu_launcher=awful.widget.launcher({
	menu=main_menu,
	image=beautiful.awesome_icon,
})

-- Initialize System Tray (defined in theme.lua)
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
	s.systray=wibox.widget.systray()
	s.systray.visible=true
end)

--==================================================================================================
-- [3] Key Bindings
--==================================================================================================

-- Mouse Buttons for Top Menu
root.buttons(gears.table.join(
	awful.button({ }, 3, function() main_menu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev))
)

-- Global Key Bindings
globalkeys=gears.table.join(
	-- General
	awful.key({mod}, 'Return', function() awful.util.spawn(terminal) end,
	{description='| Launch Terminal\n', group='01 General'}),
	awful.key({mod}, 'c', function() awful.util.spawn('galculator') end,
	{description='| Launch Calculator\n', group='01 General'}),
	awful.key({mod}, 'F12', function() dropdown:toggle() end,
	{description='| Launch Quake Terminal\n', group='01 General'}),
	awful.key({mod, alt}, 'r', awesome.restart,
	{description='| Reload Awesome\n', group='01 General'}),
	awful.key({mod, alt}, 'x', awesome.quit,
	{description='| Quit Awesome\n', group='01 General'}),
	awful.key({mod, alt}, 'k', function() awful.util.spawn('knotes') end,
	{description='| Take notes (Knotes)\n', group='01 General'}),
	awful.key({mod, alt}, 'o', function() awful.util.spawn('obsidian') end,
	{description='| Take Notes (Obsidian)\n', group='01 General'}),
	awful.key({mod, alt}, 'e', function() awful.util.spawn('gedit --new-window') end,
	{description='| Take Notes (Gedit)\n', group='01 General'}),
	awful.key({mod}, 'x', function()
		awful.prompt.run{prompt='Lua Code: ',
		textbox=awful.screen.focused().promptbox.widget,
		exe_callback=awful.util.eval,
		history_path=awful.util.get_cache_dir() .. '/history_eval'}
	end,
	{description='| Launch Lua Code Prompt\n', group='01 General'}),

	-- Media
	awful.key({mod}, 'F5', function() awful.util.spawn('deadbeef --random') end,
	{description='| Deadbeef Shuffle Tracks\n', group='02 Media'}),
	awful.key({mod}, 'F7', function() awful.util.spawn('deadbeef --play-pause') end,
	{description='| Deadbeef Toggle Playback\n', group='02 Media'}),
	awful.key({mod}, 'F8', function() awful.util.spawn('deadbeef --next') end,
	{description='| Deadbeef Next Track\n', group='02 Media'}),
	awful.key({mod}, 'F6', function() awful.util.spawn('deadbeef --prev') end,
	{description='| Deadbeef Last Track\n', group='02 Media'}),
	awful.key({mod, alt}, 'F7', function() awful.util.spawn('mpc play') end,
	{description='| MPC Play Media\n', group='02 Media'}),
	awful.key({mod, alt}, 'Right', function() awful.util.spawn('mpc next') end,
	{description='| MPC Next File\n', group='02 Media'}),
	awful.key({mod, alt}, 'Left', function() awful.util.spawn('mpc prev') end,
	{description='| MPC Last File\n', group='02 Media'}),
	awful.key({mod, alt}, 'F5', function() awful.util.spawn('mpc stop') end,
	{description='| MPC Stop Playback\n', group='02 Media'}),
	awful.key({alt, shft}, 'w', function() awful.util.spawn('flameshot full') end,
	{description='| Flameshot Whole Area\n', group='02 Media'}),
	awful.key({alt, shft}, 'o', function() awful.util.spawn('obs') end,
	{description='| OBS Screen Record\n', group='02 Media'}),
	awful.key({alt, shft}, 'p', function() awful.util.spawn('flameshot gui') end,
	{description='| Flameshot Area Select         \n', group='02 Media'}),

	-- Menus
	awful.key({mod}, 's', hotkeys_popup.show_help,
	{description='| Show Shortcuts Menu\n', group='03 Menus'}),
	awful.key({mod}, 'w', function() main_menu:show() end,
	{description='| Show Main Menu\n', group='03 Menus'}),
	awful.key({mod}, 'p', function() menubar.utils.terminal=terminal menubar.show() end,
	{description='| Show Quick Run Menu\n', group='03 Menus'}),
	awful.key({alt, shft}, 'r', function()
		awful.util.spawn('rofi -no-config -no-lazy-grab -show run -modi run \
		-theme ~/.config/awesome/configs/rofi_default.rasi',
		beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus)
	end,
	{description='| Show Executables\n', group='03 Menus'}),
	awful.key({alt, shft}, 'd', function()
		awful.util.spawn('rofi -no-config -no-lazy-grab -show window -modi window \
		-theme ~/.config/awesome/configs/rofi_default.rasi',
		beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus)
	end,
	{description='| Show Open Windows\n', group='03 Menus'}),
	awful.key({mod}, 'z', function()
		awful.util.spawn('rofi -no-config -no-lazy-grab -show run -modi run \
		-theme ~/.config/awesome/configs/cmd_prompt.rasi')
	end,
	{description='| Show Command Prompt\n', group='03 Menus'}),
	awful.key({mod}, 'r', function()
		local c=client.focus
		if c then c.minimized=true end
		awful.spawn.easy_async(string.format('rofi -no-config -no-lazy-grab -show drun -modi drun \
		-theme ~/.config/awesome/configs/gbl_menu.rasi',
		beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus),
		function() if c then c.minimized=false end end)
	end,
	{description='| Show Global Menu\n', group='03 Menus'}),

	-- Client
	awful.key({mod, shft}, 'j', function() awful.client.swap.byidx(1) end,
	{description='| Swap Tiled Window Left\n', group='04 Client'}),
	awful.key({mod, shft}, 'k', function() awful.client.swap.byidx(-1) end,
	{description='| Swap Tiled Window Right\n', group='04 Client'}),
	awful.key({mod, shft}, 'h', function() awful.screen.focus_relative(1) end,
	{description='| Focus Next Tiled Window\n', group='04 Client'}),
	awful.key({mod, shft}, 'l', function() awful.screen.focus_relative(-1) end,
	{description='| Focus Last Tiled Window\n', group='04 Client'}),
	awful.key({alt, shft}, 'j', function() awful.tag.incmwfact(-0.05) end,
	{description='| Decrease Tile Width\n', group='04 Client'}),
	awful.key({alt, shft}, 'k', function() awful.tag.incmwfact(0.05) end,
	{description='| Increase Tile Width\n', group='04 Client'}),
	awful.key({mod}, 'Tab', function()
		awful.client.focus.history.previous()
		if client.focus then client.focus:raise() end
	end,
	{description='| Cycle Focus Clients\n\n\n', group='04 Client'}),
	awful.key({mod}, 'j', function()
		awful.client.focus.global_bydirection('down')
		if client.focus then client.focus:raise() end
	end,
	{description='| Focus Clients from Bottom\n', group='04 Client'}),
	awful.key({mod}, 'k', function()
		awful.client.focus.global_bydirection('up')
		if client.focus then client.focus:raise() end
	end,
	{description='| Focus Clients from Top\n', group='04 Client'}),
	awful.key({mod}, 'h', function()
		awful.client.focus.global_bydirection('left')
		if client.focus then client.focus:raise() end
	end,
	{description='| Focus Clients from Left\n', group='04 Client'}),
	awful.key({mod}, 'l', function()
		awful.client.focus.global_bydirection('right')
		if client.focus then client.focus:raise() end
	end,
	{description='| Focus Clients from Right\n', group='04 Client'}),
	awful.key({mod, shft}, 'n', function()
		local c=awful.client.restore() if c then client.focus=c c:raise() end
	end,
	{description='| Restore Minimized Clients         \n', group='04 Client'}),

	-- Launchers
	awful.key({mod}, 't', function() awful.util.spawn('vivaldi-bin') end,
	{description='| Launch Browser (Vivaldi)\n', group='05 Launchers'}),
	awful.key({mod}, 'i', function() awful.util.spawn('inkscape') end,
	{description='| Launch Vector Editor\n', group='05 Launchers'}),
	awful.key({mod}, 'b', function() awful.util.spawn(browser) end,
	{description='| Launch Browser (Firefox)\n', group='05 Launchers'}),
	awful.key({mod}, 'e', function() awful.util.spawn('geany --new-instance') end,
	{description='| Launch IDE (Geany)\n', group='05 Launchers'}),
	awful.key({mod}, 'v', function() awful.util.spawn('kdenlive') end,
	{description='| Launch Video Editor\n\n\n\n\n\n\n\n', group='05 Launchers'}),
	awful.key({mod}, 'f', function() awful.util.spawn(filemanager) end,
	{description='| Launch File Manager\n', group='05 Launchers'}),
	awful.key({mod}, 'F2', function() awful.util.spawn('pavucontrol-qt') end,
	{description='| Launch Volume Control\n', group='05 Launchers'}),
	awful.key({mod}, 'F3', function() awful.util.spawn('cadence') end,
	{description='| Launch Audio Connections\n', group='05 Launchers'}),
	awful.key({mod}, 'F4', function() awful.util.spawn('nm-connection-editor') end,
	{description='| Launch Network Connections\n', group='05 Launchers'}),
	awful.key({mod}, 'F9', function() awful.util.spawn(mailclient) end,
	{description='| Launch Mail Client\n', group='05 Launchers'}),
	awful.key({mod}, 'F10', function() awful.util.spawn('lxappearance') end,
	{description='| Launch Theme Client\n', group='05 Launchers'}),
	awful.key({mod}, 'F11', function() awful.util.spawn('arandr') end,
	{description='| Launch Display Manager\n', group='05 Launchers'}),
	awful.key({mod}, 'F1', function() awful.util.spawn('deadbeef') end,
	{description='| Launch Music Client\n', group='05 Launchers'}),
	awful.key({mod}, 'g', function() awful.util.spawn('gimp') end,
	{description='| Launch Image Editor\n', group='05 Launchers'}),
	awful.key({mod}, 'o', function() awful.util.spawn('loffice') end,
	{description='| Launch Office Client\n', group='05 Launchers'}),
	awful.key({mod}, 'a', function() awful.spawn.with_shell('ardour8 -n') end,
	{description='| Launch DAW (Ardour)\n', group='05 Launchers'}),
	awful.key({mod}, 'd', function() awful.util.spawn('Discord') end,
	{description='| Launch Video Chat\n', group='05 Launchers'}),
	awful.key({mod, shft}, 'v', function() awful.util.spawn('virtualbox') end,
	{description='| Launch Virtual Machine\n', group='05 Launchers'}),
	awful.key({mod, shft}, 'w', function() awful.util.spawn('bluefish') end,
	{description='| Launch IDE (Bluefish)\n', group='05 Launchers'}),
	awful.key({mod, shft}, 'i', function() awful.util.spawn('kdevelop') end,
	{description='| Launch IDE (Kdevelop)\n', group='05 Launchers'}),
	awful.key({mod, shft}, 'q', function() awful.util.spawn('qtcreator') end,
	{description='| Launch IDE (Qtcreator)\n', group='05 Launchers'}),
	awful.key({mod, shft}, 'r', function() awful.util.spawn('reaper -nosplash') end,
	{description='| Launch DAW (REAPER)\n', group='05 Launchers'}),
	awful.key({mod, shft}, 'p', function() awful.util.spawn(securemsg) end,
	{description='| Launch Private Messager         \n', group='05 Launchers'}),
	awful.key({mod, shft}, 's', function() awful.util.spawn('steam-native') end,
	{description='| Launch Game Client\n', group='05 Launchers'}),
	awful.key({mod, shft}, 'b', function() awful.util.spawn('blender') end,
	{description='| Launch 3D Editor\n', group='05 Launchers'}),

	-- Tags
	awful.key({mod}, 'Left', awful.tag.viewprev,
	{description='| Switch to Left Tag\n', group='06 Tags'}),
	awful.key({mod}, 'Right', awful.tag.viewnext,
	{description='| Switch to Right Tag\n', group='06 Tags'}),
	awful.key({mod}, 'Escape', awful.tag.history.restore,
	{description='| Switch to Last Tag\n', group='06 Tags'}),
	awful.key({mod, alt}, 'n', function() lain.util.add_tag() end,
	{description='| Add Tag (Reload to Delete)\n', group='06 Tags'}),

	-- Layout
	awful.key({mod}, 'space', function() awful.layout.inc(1) end,
	{description='| Select Next Layout\n', group='07 Layout'}),
	awful.key({alt, ctl}, 'Up', function() adjustBrightness(1) end,
	{description='| Increase Brightness\n', group='07 Layout'}),
	awful.key({alt, ctl}, 'Down', function() adjustBrightness(-1) end,
	{description='| Decrease Brightness\n', group='07 Layout'}),
	awful.key({alt, ctl}, 'h', function() lain.util.useless_gaps_resize(7) end,
	{description='| Increment Useless Gaps\n', group='07 Layout'}),
	awful.key({alt, ctl}, 'l', function() lain.util.useless_gaps_resize(-7) end,
	{description='| Decrement Useless Gaps\n', group='07 Layout'}),
	awful.key({alt, ctl}, 'j', function() awful.tag.incnmaster(1, nil, true) end,
	{description='| Increment Master Clients\n', group='07 Layout'}),
	awful.key({alt, ctl}, 'k', function() awful.tag.incnmaster(-1, nil, true) end,
	{description='| Decrement Master Clients\n', group='07 Layout'}),
	awful.key({alt, ctl}, 'space', function() awful.layout.inc(-1) end,
	{description='| Select Last Layout\n', group='07 Layout'}),
	awful.key({alt, ctl}, '-', function()
		awful.screen.focused().systray.visible=not awful.screen.focused().systray.visible
	end,
	{description='| Toggle Systray Visibility\n', group='07 Layout'}),
	awful.key({alt, ctl}, '=', function()
		for s in screen do
			s.wibox.visible=not s.wibox.visible
			if s.bottomwibox then s.bottomwibox.visible=not s.bottomwibox.visible end
		end end,
	{description='| Toggle Wibox Visibility\n', group='07 Layout'}),

	-- Scripts
	awful.key({alt, shft}, 'F2', function()
		awful.spawn.with_shell('tog_pulse')
	end,
	{description='| Toggle Reload Pulse\n', group='08 Scripts'}),
	awful.key({alt, shft}, 'F1', function()
		awful.spawn.with_shell('tog_picom')
	end,
	{description='| Toggle Reload Picom\n', group='08 Scripts'})
)

-- External Client Keys
clientkeys=gears.table.join(
	awful.key({mod}, 'n', function(c) c.minimized=true end,
	{description='| Minimize Window\n', group='04 Client'}),
	awful.key({mod}, 'm', function(c) c.maximized=not c.maximized c:raise() end,
	{description='| Maximize Window\n', group='04 Client'}),
	awful.key({mod}, 'q', function(c) c:kill() end,
	{description='| Kill Windows\n', group='04 Client'}),
	awful.key({mod, shft}, 'm', lain.util.magnify_client,
	{description='| Magnify Focused Window\n', group='04 Client'}),
	awful.key({alt, shft}, 'space', awful.client.floating.toggle,
	{description='| Toggle Floating State\n', group='04 Client'}),
	awful.key({alt, shft}, 't', function(c) c.ontop=not c.ontop end,
	{description='| Toggle Sticky State\n', group='04 Client'}),
	awful.key({alt, shft}, 'm', function(c) c.fullscreen=not c.fullscreen c:raise() end,
	{description='| Toggle Fullscreen State\n', group='04 Client'})
)

-- Tag Selection
for i=1, 9 do local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view={description='| Switch to Tag ##\n', group='06 Tags'}
		descr_toggle={description='| Focus Main Client on Tag\n', group='06 Tags'}
		descr_move={description='| Throw Client to Tag\n', group='06 Tags'}
		descr_toggle_focus={description='| Follow Client to Tag\n', group='06 Tags'}
	end
	globalkeys=gears.table.join(globalkeys,
		awful.key({mod}, '#' .. i+9, function()
			screen=awful.screen.focused() local tag=screen.tags[i]
			if tag then tag:view_only() end
		end, descr_view),
	awful.key({alt, shft}, '#' .. i+9, function()
		screen=awful.screen.focused()
		local tag=screen.tags[i] if tag then awful.tag.viewtoggle(tag) end
	end, descr_toggle),
	awful.key({alt, ctl}, '#' .. i+9, function()
		if client.focus then local tag=client.focus.screen.tags[i]
			if tag then client.focus:move_to_tag(tag) tag:view_only() end
		end
	end, descr_move),
	awful.key({alt, mod}, '#' .. i+ 9, function()
		if client.focus then local tag=client.focus.screen.tags[i]
			if tag then client.focus:toggle_tag(tag) end
		end
	end, descr_toggle_focus))
end

-- Client Mouse Buttons
clientbuttons=gears.table.join(
	awful.button({ }, 1, function (c)
		c:emit_signal('request::activate', 'mouse_click', {raise=true})
	end),
	awful.button({mod}, 1, function(c)
		c:emit_signal('request::activate', 'mouse_click', {raise=true})
		awful.mouse.client.move(c)
	end),
	awful.button({mod}, 3, function(c)
		c:emit_signal('request::activate', 'mouse_click', {raise=true})
		awful.mouse.client.resize(c)
	end)
)
root.keys(globalkeys)

--==================================================================================================
-- [4] Client Behaviour
--==================================================================================================

-- Client Rules
awful.rules.rules={
	-- Window Defaults
	{rule={}, properties={
		border_width=beautiful.border_width,
		border_color=beautiful.border_normal,
		focus=awful.client.focus.filter,
		raise=true,
		keys=clientkeys,
		buttons=clientbuttons,
		screen=awful.screen.preferred,
		placement=awful.placement.no_overlap+awful.placement.no_offscreen,
		size_hints_honor=false}},
	-- Sticky Windows -- Temperamental
	-- Terminator shells
	{rule={class='terminator'}, properties={
		ontop=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Terminator set to floating'")
		end}},
	-- Picture-In-Picture
	{rule={class='Toolkit'}, properties={
		ontop=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Picture-In-Picture set to floating'")
		end}},
	-- Sticky notes
	{rule={class='knotes'}, properties={
		ontop=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Knotes set to floating'")
		end}},
	-- Galculator
	{rule={class='galculator'}, properties={
		ontop=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Galculator set to floating'")
		end}},
	-- Tag preset an maximized if possible
	-- Htop -- Cant be identified by class or name
--	{rule={name='htop'}, properties={
--		tag=' 1  ', maximized=true, callback=function(c)
--			awful.spawn.with_shell("notify-send 'htop moved to tag 1'")
--		end}},
--	-- Nemo -- Wont be identified by class or name without explanation
--	{rule={class='nemo'}, properties={
--		tag=' 2  ', maximized=true, callback=function(c)
--			awful.spawn.with_shell("notify-send 'Nemo moved to tag 2'")
--		end}},
	-- OBS - Placed before Obsidian to mitigate class name conflict
	{rule={class='obs'}, properties={
		tag=' 5  ', maximized=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'OBS moved to tag 5'")
		end}},
	-- Obsidian
	{rule={class='obsidian'}, properties={
		tag=' 3  ', callback=function(c)
			awful.spawn.with_shell("notify-send 'Obsidian moved to tag 3'")
		end}},
	-- Geany -- Wont be identified by class or name without explanation
--	{rule={class='geany'}, properties={
--		tag=' 4  ', callback=function(c)
--			awful.spawn.with_shell("notify-send 'Geany moved to tag 4'")
--		end}},
	-- Steam -- May cause issues with games
--	{rule={class='steam'}, properties={
--		tag=' 4  ', maximized=true, callback=function(c)
--			awful.spawn.with_shell("notify-send 'Steam moved to tag 4'")
--		end}},
	-- Telegram
	{rule={class='telegram-desktop'}, properties={
		tag=' 7  ', maximized=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Telegram moved to tag 7'")
		end}},
	-- Firefox
	{rule={class='firefox'}, properties={
		tag=' 8  ', maximized=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Firefox moved to tag 8'")
		end}},
	-- Discord
	{rule={class='discord'}, properties={
		tag=' 8  ', maximized=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Discord moved to tag 8'")
		end}},
	-- Thunderbird
	{rule={class='thunderbird'}, properties={
		tag=' 9  ', maximized=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Thunderbird moved to tag 9'")
		end}},
	-- Vivaldi
	{rule={class='vivaldi-stable'}, properties={
		tag=' 9  ', maximized=true, callback=function(c)
			awful.spawn.with_shell("notify-send 'Vivaldi moved to tag 9'")
		end}},
}

-- Client Management
client.connect_signal('manage', function(c)
	if awesome.startup and not c.size_hints.user_position
	and not c.size_hints.program_position then awful.placement.no_offscreen(c) end
end)

-- Enter Client
client.connect_signal('mouse::enter', function(c)
	c:emit_signal('request::activate', 'mouse_enter', {raise=false})
end)

-- Gain Focus
client.connect_signal('focus', function(c) c.border_color=beautiful.border_focus end)

-- Lose Focus
client.connect_signal('unfocus', function(c) c.border_color=beautiful.border_normal end)

--==================================================================================================
-- [5] Autostart Applications
--==================================================================================================

-- Execution Function
local function run(c, check_cmd)
	check_cmd=check_cmd or c
	if not awesome.startup then
		awful.spawn.easy_async_with_shell(
			string.format('pgrep -f "%s" > /dev/null || (%s)', check_cmd, c),
			function(stdout) if not stdout:match('%S') then awful.spawn(c) end end)
	else awful.spawn.easy_async_with_shell(
		string.format('pkill -x "%s" > /dev/null 2>&1; sleep 1; %s', check_cmd, c),
		function() end)
	end
end

-- Startup List & Final
run('tog_pulse')
run('/usr/share/cadence/src/cadence.py --minimized', 'cadence')
run('mpd --no-daemon')
run('knotes --skip-note')
run('volumeicon')
run('nm-applet')
run('pamac-tray')
run('picom -b --config "$HOME/.config/awesome/configs/picom.conf"')
run('tc_setxwall')