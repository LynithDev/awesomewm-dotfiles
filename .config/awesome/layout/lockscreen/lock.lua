-- Lockscreen
-- ~~~~~~~~~~~~~~~~~~~~
-- edited from elenapan


-- Requirements
-- ~~~~~~~~~~~~
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local lock_screen = require("layout.lockscreen")
local dpi = beautiful.xresources.apply_dpi

-- misc/vars
-- ~~~~~~~~~

local lock_screen_symbol = ""
local lock_screen_fail_symbol = ""



-- widgets themselves
-- ~~~~~~~~~~~~~~~~~~


local profile_image = wibox.widget {
    {
        image = beautiful.images.profile,
        upscale = true,
        forced_width = dpi(160),
        forced_height = dpi(160),
        clip_shape = gears.shape.circle,
        widget = wibox.widget.imagebox,
        halign = "center",
    },
    widget = wibox.container.background,
    border_width = dpi(2),
    shape = gears.shape.circle,
    border_color = beautiful.fg_color
}


local username = wibox.widget{
    widget = wibox.widget.textbox,
    markup = user_likes.username,
    font = beautiful.font_var .. "15",
    align = "center",
    valign = "center"
}


local myself = wibox.widget{
    profile_image,
    username,
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical
}

-- dummy text
local some_textbox = wibox.widget.textbox()

-- lock icon
local icon = wibox.widget{
    widget = wibox.widget.textbox,
    markup = lock_screen_symbol,
    font = beautiful.icon_var .. "14",
    align = "center",
    valign = "center"
}


-- clock
local clock = wibox.widget{
    helpers.vertical_pad(dpi(40)),
    {
        font = beautiful.font_var .. "Medium 42",
        format = helpers.colorize_text("%I:%M", beautiful.fg_color),
        widget = wibox.widget.textclock,
        align = "center",
        valign = "center"
    },
    {
        font = beautiful.font_var .. "Regular 18",
        format = helpers.colorize_text("%A, %B", beautiful.fg_color),
        widget = wibox.widget.textclock,
        align = "center",
        valign = "center"
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical
}






-- password prompt
local promptbox = wibox.widget{
    widget = wibox.widget.textbox,
    markup = "",
    font = beautiful.icon_var .. "13",
    align = "center"
}

local promptboxfinal = wibox.widget{
    {
        {
            {
                promptbox,
                margins = {left = dpi(10)},
                widget = wibox.container.margin
            },
            nil,
            {
                icon,
                margins = {right = dpi(10)},
                widget = wibox.container.margin
            },
            layout = wibox.layout.align.horizontal,
            expand = "none"
        },
        widget = wibox.container.margin,
        margins = dpi(10)
    },
    widget = wibox.container.background,
    bg = beautiful.fg_color .. "1A",
    forced_width = dpi(300),
    forced_height = dpi(40),
    shape = gears.shape.rounded_bar
}

-- Create the lock screen wibox
local lock_screen_box = wibox({
    visible = false,
    ontop = true,
    type = "splash",
    bg = beautiful.bg_color .. "FE",
    fg = beautiful.fg_color,
    screen = screen.primary
})

-- Create the lock screen wibox (extra)
local function create_extender(s)
    

local lock_screen_box_ext wibox({
    visible = false,
    ontop = true,
    type = "splash",
    bg = beautiful.bg_color .. "E6",
    fg = beautiful.fg_color,
    screen = s
})

awful.placement.maximize(lock_screen_box_ext)

return lock_screen_box_ext

end

awful.placement.maximize(lock_screen_box)




-- Add lockscreen to each screen
awful.screen.connect_for_each_screen(function(s)
    if s.index == 2 then
        s.mylockscreenext = create_extender(2)
        s.mylockscreen = lock_screen_box
    else
        s.mylockscreen = lock_screen_box
    end
end)


local function set_visibility(v)
    for s in screen do
        s.mylockscreen.visible = v
        if s.mylockscreenext then
            s.mylockscreenext.visible = v
        end
    end
end



-- Lock helper functions
local characters_entered = 0


-- reset function
local function reset()
    characters_entered = 0;
    promptbox.markup = helpers.colorize_text("", beautiful.red_3)
    icon.markup = lock_screen_symbol
end

-- fail function
local function fail()
    characters_entered = 0;
    promptbox.markup = helpers.colorize_text("Incorrect", beautiful.red_3)
    icon.markup = lock_screen_fail_symbol
end


-- variables
local button_size = dpi(110)

-- icons
local icons = {
    poweroff = "",
    suspend  = "",
    reboot   = "",
    exit     = ""
}

-- Commands
local poweroff_command = function()
	awful.spawn.with_shell("systemctl poweroff")
	awesome.emit_signal('module::exit_screen:hide')
end

local reboot_command = function() 
	awful.spawn.with_shell("systemctl reboot")
	awesome.emit_signal('module::exit_screen:hide')
end

local suspend_command = function()
	awesome.emit_signal('module::exit_screen:hide')
    awful.spawn.with_shell("systemctl suspend")
end

local exit_command = function() awesome.quit() end



-- helper function for buttons
local cr_btn = function (text_cc, icon_cc, color, command)
    local i = wibox.widget{
        align = "center",
        valign = "center",
        font = beautiful.icon_var .. "30",
        markup = helpers.colorize_text(icon_cc, beautiful.ext_light_fg or beautiful.fg_color),
        widget = wibox.widget.textbox()
    }

    local text = wibox.widget{
        align = "center",
        valign = "center",
        font = beautiful.font_var .. "13",
        markup = helpers.colorize_text(text_cc, beautiful.ext_light_fg or beautiful.fg_color),
        widget = wibox.widget.textbox()
    }

    local button = wibox.widget {
        {
            nil,
            i,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        forced_height   = button_size,
        forced_width    = button_size,
        shape           = gears.shape.circle,
		border_color	= "#00000000",
		border_width	= dpi(3),
        bg              = beautiful.bg_2,
        widget          = wibox.container.background
    }

	local mainbox_button = wibox.widget{
		button,
		text,
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(12)
	}

    button:buttons(gears.table.join( awful.button({}, 1, function() command() end)))


    button:connect_signal("mouse::enter", function()
        i.markup = helpers.colorize_text(icon_cc, beautiful.red_2)
        text.markup = helpers.colorize_text(text_cc, beautiful.red_2)
        button.border_color = beautiful.red_2
    end)
    button:connect_signal("mouse::leave", function()
        i.markup = helpers.colorize_text(icon_cc, beautiful.fg_color)
        text.markup = helpers.colorize_text(text_cc, beautiful.fg_color)
        button.border_color = beautiful.bg_2
    end)

    helpers.add_hover_cursor(button, "hand2")

    return mainbox_button
    
end

-- Create the buttons
local poweroff  = cr_btn("poweroff", icons.poweroff, beautiful.accent, poweroff_command)
local reboot    = cr_btn("reboot", icons.reboot,   beautiful.accent, reboot_command)
local suspend   = cr_btn("suspend", icons.suspend,  beautiful.accent, suspend_command)
local exit      = cr_btn("exit", icons.exit,     beautiful.accent, exit_command)

-- user input
local function grab_password()
    awful.prompt.run {
        hooks = {
            {{ }, 'Escape',
                function(_)
                    reset()
                    grab_password()
                end
            },
            {{ 'Control' }, 'Delete', function ()
                reset()
                grab_password()
            end}
        },
        keypressed_callback  = function(mod, key, cmd)
            if #key == 1 then
                characters_entered = characters_entered + 1
                promptbox.markup = helpers.colorize_text(string.rep("", characters_entered), beautiful.fg_color)
            elseif key == "BackSpace" then
                if characters_entered > 0 then
                    characters_entered = characters_entered - 1
                end
                promptbox.markup = helpers.colorize_text(string.rep("", characters_entered), beautiful.fg_color)
            end

        end,
        exe_callback = function(input)
            -- compare input
            if lock_screen.authenticate(input) then
                -- YAY 
                reset()
                set_visibility(false)
            else
                -- NAH, JIT TRIPPIN
                fail()
                grab_password()
            end
        end,
        textbox = some_textbox,
    }
end



-- show lockscreen func
function lock_screen_show()
    set_visibility(true)
    grab_password()
end





-- init
-- ~~~~
lock_screen_box:setup {
    {
        clock,
        {
            myself,
            {
                {
                    promptboxfinal,
                    layout = wibox.layout.fixed.horizontal,
                },
                layout = wibox.container.place
            }, 
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(50)
        },
        {
            {
                layout = wibox.layout.align.horizontal,
                expand = "outside",
                nil,
                {
                    suspend,
                    exit,
                    poweroff,
                    reboot,
                    spacing = dpi(45),
                    layout = wibox.layout.fixed.horizontal
                },
                nil,
            },
            bottom = dpi(45),
            widget = wibox.container.margin,
        },
        widget = wibox.container.margin,
        margins = dpi(35),
        layout = wibox.layout.align.vertical,
        expand = "none"
    },
    layout = wibox.layout.stack
}
