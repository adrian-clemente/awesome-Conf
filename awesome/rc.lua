-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("vicious")
-- Load Debian menu entries
require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/adrian/.config/awesome/themes/byte/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
tags = { names = { "Console   ", "Chrome   ", "PHPStorm   ", "VirtualBox  " },
         layout = { layouts[1], layouts[1], layouts[1], layouts[2] } }

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

networks = {'eth0'}


-- {{{ Menu
-- Create a laucher widget and a main menu
mymainmenu = awful.menu({ items = { { "restart",  awesome.restart },
				    {"quit", awesome.quit },
			            {"shutdown", "sudo poweroff"}
                                  }
                        })

mylauncher = awful.widget.launcher({ 
	image = image(beautiful.awesome_icon),
       	menu = mymainmenu,
})
-- }}}

--------------------------
------- START APPS -------
function run_once(prg,prgCheck,arg_string,screen)
    if not prg then
        do return nil end
    end
	    
    if not arg_string then 
    	awful.util.spawn_with_shell("pgrep '" .. prgCheck .. "' || (" .. prg .. ")",screen)
    else
        awful.util.spawn_with_shell("pgrep '" .. prgCheck .. "' || (" .. prg .. " " .. arg_string .. ")",screen)
    end

end
-------------------------
------END START APPS-----

run_once("nm-applet","nm-applet","",1)
run_once("dropbox","dropbox","start",1)
---------------------------
---------WIDGETS-----------
---------------------------

-- Containers
topbar = {}
bottombar = {}

------ CPU WIDGET ---------
cpuicon = widget ({ type = "textbox" })
cpuicon.bg_image = image(beautiful.widget_cpu)
cpuicon.bg_align = "middle"
cpuicon.width = 8
cpuinfo = widget ({ type = "textbox" })
cpuinfo.width = 65

----- SPACER WIDGET ------
separator = widget({ type = "textbox" })
separator.text = " | "
spacer = widget({ type = "textbox" })
spacer.width = 6
spacerfat = widget({ type = "textbox" })
spacerfat.width = 18

---- BATTERY WIDGET -----
batticon = widget ({ type = "textbox" })
batticon.bg_image = image(beautiful.widget_batt_full)
batticon.bg_align = "middle"
batticon.width = 8
battinfo = widget ({ type = "textbox" })

----- CLOCK WIDGET -----
clockicon = widget ({ type = "textbox" })
clockicon.bg_image = image(beautiful.widget_clock)
clockicon.bg_align = "middle"
clockicon.width = 8
clock = awful.widget.textclock({align = "right"}, "%a %b %d, %I:%M %p")

----- TEMP WIDGET -----
tempicon = widget ({ type = "textbox" })
tempicon.bg_image = image(beautiful.widget_temp)
tempicon.bg_align = "middle"
tempicon.width = 8
cputemp = widget ({ type = "textbox" })

----- MEMORY WIDGET -----
memicon = widget ({ type = "textbox" })
memicon.bg_image = image(beautiful.widget_mem)
memicon.bg_align = "middle"
memicon.width = 8
meminfo = widget ({ type = "textbox" })

----- NET WIDGET -----
netwidget =  widget ({ type = "textbox" }) 
netupicon = widget ({ type = "textbox" })
netupicon.bg_image = image(beautiful.widget_netup)
netupicon.bg_align = "middle"
netupicon.width = 8


----- WIDGET REGISTER ----
vicious.register(cpuinfo, vicious.widgets.cpu, "$1% / $2%")
vicious.register(battinfo, vicious.widgets.bat,
  function (widget, args)
    if args[2] < 25 then
      batticon.bg_image = image(beautiful.widget_batt_empty)
      return args[2]
    elseif args[2] < 50 then
      batticon.bg_image = image(beautiful.widget_batt_low)
      return args[2]
    else
      batticon.bg_image = image(beautiful.widget_batt_full)
      return args[2]
    end
  end, 59, "BAT0")
vicious.register(cputemp, vicious.widgets.thermal, "$1 C", 19, "thermal_zone0")
vicious.cache(vicious.widgets.mem)
vicious.register(meminfo, vicious.widgets.mem, "$1% ($2Mb)", 5)


-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do

    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
--    mytasklist[s] = awful.widget.tasklist(function(c)
  --                                            return awful.widget.tasklist.label.currenttags(c, s)
    --                                      end, mytasklist.buttons)

    -- Create the bars
    topbar[s] = awful.wibox({
                position = "top", screen = s, height = 27,
                fg = beautiful.fg_normal, bg = beautiful.bg_normal,
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                cursor = "/usr/share/themes/Human/cursor.theme"
    })
    bottombar[s] = awful.wibox({
                position = "bottom", screen = s, height = 18,
                fg = beautiful.fg_normal, bg = beautiful.bg_normal,
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal
    })
   

    right_aligned = { layout = awful.widget.layout.horizontal.rightleft}
    if s == 1 then
	 table.insert(right_aligned, mysystray) 
    end
    table.insert(right_aligned, mylayoutbox[s])

    bottombar[s].widgets = {
	{
		mytasklist[s],
		layout = awful.widget.layout.horizontal.leftright,
		width = 100
	},
	{	spacerfat,
		cpuinfo,
		spacer,
		cpuicon,
		spacerfat,
		separator,
		spacerfat,
		cputemp,
		spacer,
		tempicon,
		spacerfat,
		separator,
		spacerfat,
		meminfo,
		spacer,
		memicon,
	 	layout = awful.widget.layout.horizontal.rightleft,
	        height = 13
	},
        layout = awful.widget.layout.horizontal.leftright, height = 13
    }
    topbar[s].widgets = {
	spacer,
	mylauncher,
	spacerfat,
        mytaglist[s],
	right_aligned,
	{
		mypromptbox[s],
		spacerfat,
		clock,
		spacer,
		clockicon,
		spacerfat,
		battinfo,
		spacer,
		batticon,
		spacerfat,
       		layout = awful.widget.layout.horizontal.rightleft,
		height = 13
	},
        layout = awful.widget.layout.horizontal.leftright,
        height = 13
    }


end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i]) 
			    if i==2 then			    
                                run_once("google-chrome","chrome","",1)
			    elseif i==3 then
				run_once("/home/adrian/PhpStorm-121.285/bin/phpstorm.sh","phpstorm.sh","",1) 
		            elseif i==4 then
				run_once("","","",1)
			    end
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                         awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
		     properties = { tag = tags[1][3]} } },
     --Set Firefox and Chrome to always map on tags number 2 of screen 1.
     --{ rule = { class = "Firefox" },
     --  properties = { tag = tags[1][2] } 
     --},
      { rule = { class = "Google-chrome" },
           properties = { tag = tags[1][2] }
      },
      { rule = { class = "jetbrains-phpstorm" },
           properties = { tag = tags[1][3] }
      }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


