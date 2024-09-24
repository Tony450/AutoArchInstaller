-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

local mux = wezterm.mux

local act = wezterm.action

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.window_background_opacity = 0.7

config.enable_scroll_bar = true

config.font_size = 16.0

config.initial_rows = 26
config.initial_cols = 88


-- To open the terminal in the current directory of dolphin. Be careful, the developer specified that this was only going to work in nightly builts

wezterm.on('gui-startup', function(cmd)
    -- allow `wezterm start -- something` to affect what we spawn
    -- in our initial window. If they didn't specify it, use a default empty SpawnCommand.
    local cmd = cmd or {}
    -- I prefer to use the cwd of the gui process instead of (probably) the home dir
    if not cmd.cwd then
      	cmd.cwd = wezterm.procinfo.current_working_dir_for_pid(wezterm.procinfo.pid())
    end
    mux.spawn_window(cmd)
end)




-- Key mappings
config.keys                                       = {
    -- { key = 'l', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(1) },
    -- { key = 'h', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(-1) },
    -- { key = 'j', mods = 'CMD', action = act.ActivatePaneDirection 'Down', },
    -- { key = 'k', mods = 'CMD', action = act.ActivatePaneDirection 'Up', },
    -- { key = 'N', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
    -- { key = 'PageUp', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
    -- { key = 'PageDown', mods = 'CTRL', action = act.ActivateTabRelative(1) },
    -- { key = 'LeftArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Left' },
    -- { key = 'RightArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Right' },
    -- { key = 'UpArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Up' },
    -- { key = 'DownArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Down' },
    -- { key = 'h', mods = 'CMD', action = act.ActivatePaneDirection 'Left', },
    -- { key = 'l', mods = 'CMD', action = act.ActivatePaneDirection 'Right', },
    -- { key = 't', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },
    -- { key = 'Enter', mods = 'CMD', action = act.ActivateCopyMode },

    { key = 'W', mods = 'CTRL',       action = act.ReloadConfiguration },  --Temporary
    { key = 'R', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
    { key = '+', mods = 'CTRL',       action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL',       action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL',       action = act.ResetFontSize },
    { key = 'C', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
    {
		key = 'U',
		mods = 'SHIFT|CTRL',
		action = act.CharSelect { copy_on_select = true, copy_to =
		'ClipboardAndPrimarySelection' }
    },
    { key = '`',     mods = 'CTRL',        action = act.ActivatePaneDirection 'Next' },
    { key = 'v',     mods = 'CMD',         action = act.PasteFrom 'Clipboard' },
    { key = 'd',     mods = 'CMD|SHIFT',   action = act.SplitVertical { domain = 'CurrentPaneDomain' }, },
    { key = 'd',     mods = 'CMD',         action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }, },
    { key = 'w',     mods = 'CMD',         action = act.CloseCurrentTab { confirm = true } },
    { key = 'x',     mods = 'CMD',         action = act.CloseCurrentPane { confirm = true } },
    { key = '{',     mods = 'SHIFT|ALT',   action = act.MoveTabRelative(-1) },
    { key = '}',     mods = 'SHIFT|ALT',   action = act.MoveTabRelative(1) },
    { key = 'b',     mods = 'LEADER|CTRL', action = act.SendString '\x02', },
    { key = 'Enter', mods = 'LEADER',      action = act.ActivateCopyMode, },
    { key = 'p',     mods = 'LEADER',      action = act.PasteFrom 'Clipboard' },
    { key = 't',     mods = 'SHIFT|ALT',   action = act.SpawnTab 'CurrentPaneDomain' },     					--Both keys at the same time
    { key = 'F', mods = 'SHIFT|CTRL', action = act.Search { CaseInSensitiveString = '' },},
	{ key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentTab { confirm = true },	},
    {
		key = 'k',
		mods = 'CTRL|SHIFT',
		action = act.Multiple
			{act.ClearScrollback 'ScrollbackAndViewport',
			act.SendKey { key = 'L', mods = 'CTRL' },},
    },
    { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false, }, }
}

--window:window:focus()

-- and finally, return the configuration to wezterm
return config