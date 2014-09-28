-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

awful.util.spawn_with_shell("xrdb /home/jeremie/.Xresources")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
--terminal = "urxvt"
-- terminal = 'urxvt -e bash -c "tmux -q has-session && exec tmux attach-session -d || exec tmux new-session -n$USER -s$USER@$HOSTNAME"'
-- terminal = "urxvt -e tmux"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
text_editor = "vim"

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
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags =
{
  names  = {{ 1, 2, 3, 4, 5, 6},
            { 1, 2, 3, 4, 5, 6}},
  layout = {{layouts[1], layouts[2], layouts[2], layouts[2], layouts[2], layouts[2]},
            {layouts[1], layouts[2], layouts[2], layouts[2], layouts[2], layouts[2]}},
}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names[screen.count()-s+1], s, tags.layout[screen.count()-s+1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })


 -- {{{ Battery state Widget
 function battstatus(adapter)
     local str, res, time, batime, batime_h, batime_m
     local fcha = io.open("/sys/class/power_supply/"..adapter.."/charge_now")
     local fcap = io.open("/sys/class/power_supply/"..adapter.."/charge_full")
     local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
     local fcur = io.open("/sys/class/power_supply/"..adapter.."/current_now")
     local cha = fcha:read()
     local cap = fcap:read()
     local sta = fsta:read()
     local cur = fcur:read()
     local battery = math.floor(cha * 100 / cap)
     local sbattery = string.format("%.0f",battery)

     if tonumber(battery) > 75 then
         str = '<span color="green">' .. sbattery .. '</span>'
     elseif tonumber(battery) > 25 then
         str = '<span color="yellow">' .. sbattery .. '</span>'
     elseif tonumber(battery) > 10 then
         str = '<span color="orange">' .. sbattery .. '</span>'
     else
         str = '<span color="red">' .. sbattery .. '</span>'
     end

     if sta:match("Charging") then
         dir = "^"
         str = "A/C ("..str..")"
         time = " "
     elseif sta:match("Discharging") then
         dir = "v"
         batime = math.floor((cha/cur) * 60)
         batime_h = math.floor(batime / 60)
         batime_m = string.format("%02d", batime % 60)
         time = ' (' .. batime_h .. 'h' .. batime_m .. 'm) '
         if tonumber(battery) < 10 then
             naughty.notify({ title         = "Battery Warning"
                            , text          = "Battery low! "..sbattery.. "% left!"
                            , width         = 400
                            , timeout       = 5
                            , hover_timeout = 2
                            , position      = "top_right"
                            , fg            = "#000000"
                            , bg            = "#dc322f"
                            })
         end
     else
         dir = "="
         str = "A/C ("..str..")"
         time = " "
     end

     res = ' BAT: ' .. str .. '%' .. time  .. dir .. ' |'
     fcha:close()
     fcap:close()
     fsta:close()
     fcur:close()

     return res
 end
--
-- battery_timer = timer({timeout = 60})
-- battery_timer:connect_signal("timeout", function() batteryInfo("BAT1") end)
-- battery_timer:start()


battinfo = widget({ type = "textbox", name = "battinfo" })

-- Assign a hook to update info
battinfo_timer = timer({timeout = 5})
battinfo_timer:add_signal("timeout", function() battinfo.text = battstatus('BAT1') end)
battinfo_timer:start()



 -- }}}
-- RAM widget
--------------
memtot = 3961072
function activeram()
	local active, ramusg, res

	for line in io.lines("/proc/meminfo") do
		for key , value in string.gmatch(line, "(%w+):\ +(%d+).+") do
			if key == "Active" then active = tonumber(value)
			end
		end
	end

	ramusg = (active/memtot)*100

	res = string.format("%.2f", (active/1024))

	if ramusg < 51 then
		res = '<span color="green">' .. res .. '</span>MB (<span color="green">' .. string.format("%.2f",ramusg) .. '</span>%)'
	elseif	ramusg < 71 then
		res = '<span color="yellow">' .. res .. '</span>MB (<span color="green">' .. string.format("%.2f",ramusg) .. '</span>%)'
	elseif  ramusg < 86 then
		res = '<span color="orange">' .. res .. '</span>MB (<span color="green">' .. string.format("%.2f",ramusg) .. '</span>%)'
	else
		res = '<span color="red">' .. res .. '</span>MB (<span color="green">' .. string.format("%.2f",ramusg) .. '</span>%)'
	end

	return res
end

meminfo = widget({ type = "textbox", name = "meminfo" })

-- Assign a hook to update info
meminfo_timer = timer({timeout = 1})
meminfo_timer:add_signal("timeout", function() meminfo.text = " | RAM: " .. activeram() .. " |"  end)
meminfo_timer:start()

-- Create a CPU widget
-----------------------
nb_cpu = 8
jiffies = {}
function activecpu()
	local s, str

	for line in io.lines("/proc/stat") do
		local cpu,newjiffies = string.match(line, "(cpu)\ +(%d+)")
		if cpu and newjiffies then
			if not jiffies[cpu] then
				jiffies[cpu] = newjiffies
			end
			-- The string.format prevents your task list from jumping around
			-- When CPU usage goes above/below 10%
			str = string.format("%02d", (newjiffies-jiffies[cpu])/nb_cpu)

			if str < "31" then
				str = '<span color="green">' .. str .. '</span>'
			elseif str < "51" then
				str = '<span color="yellow">' .. str .. '</span>'
			elseif str < "70" then
				str = '<span color="orange">' .. str .. '</span>'
			else
				str = '<span color="red">' .. str .. '</span>'
			end

			s = '| CPU: ' .. str .. '% '
			jiffies[cpu] = newjiffies
		end
	end

	return s
end

cpuinfo = widget({ type = "textbox", name = "cpuinfo" })
-- register the hook to update the display
cpuinfo_timer = timer({timeout = 1})
cpuinfo_timer:add_signal("timeout", function() cpuinfo.text = activecpu() end)
cpuinfo_timer:start()


-- Create a systray
--------------------
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
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
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
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
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        s == 1 and mysystray or nil,
        mytextclock,
        battinfo,
        meminfo,
        cpuinfo,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
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
    awful.key({ "Mod1",           }, "Tab", function () awful.screen.focus_relative( 1) end),
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
    awful.key({ modkey,           }, "Return", function () awful.util.spawn("urxvt") end),
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

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Custom
    awful.key({ "Mod1", "Control" }, "l"        , function () awful.util.spawn("gnome-screensaver-command -l") end),
    awful.key({ modkey,           }, "F11"      , function () awful.util.spawn("gcalctool") end),
    awful.key({ modkey,           }, "F12"      , function () awful.util.spawn("import -window 0    /home/jeremie/Images/screenshots/pic-" .. os.date("%Y%m%d_%H%M") .. ".jpg") end),
    awful.key({                   }, "Print"    , function () awful.util.spawn("import -window root /home/jeremie/Images/screenshots/pic-" .. os.date("%Y%m%d_%H%M") .. ".jpg") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
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
                  end),
        --Custom
        awful.key({ modkey, "Mod1" }, "#" .. i + 9,
                  function ()
                        for s = 1, screen.count() do
                          awful.tag.viewonly(tags[s][i])
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

-- -- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Gimp" },
      properties = { floating = true } },
    -- Set Chromium to always map on tags number 1 of screen 1
 --    { rule = { class = "Chromium" },
 --      properties = { tag = tags[1][1] } },
--     -- Set Thunderbird to always map on tags number 1 of screen 2.
--     { rule = { class = "Thunderbird" },
--       properties = { tag = tags[2][1] } },
    -- Set Skype to always map on tags number 9 of screen 1.
    { rule = { class = "Skype" },
      properties = { tag = tags[1][9] } },
}
-- -- }}}

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
        awful.client.setslave(c)

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

-- {{{ Widget
-- }}}


-- {{{ Autostart
function run_once(prg,arg_string,pname,screen)
  if not prg then
    do return nil end
  end

  if not pname then
    pname = prg
  end

  if not arg_string then
    awful.util.spawn_with_shell("pgrep -f -u $USER '" .. pname .. "' || (" .. prg .. ")",screen)
  else
    awful.util.spawn_with_shell("pgrep -f -u $USER '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")",screen)
  end
end

run_once("parcellite")
--run_once("dropbox")
-- --run_once("bluetooth-applet")
-- --run_once("skype")
-- --run_once("thunderbird")
-- --run_once("chromium-browser",nil,"chromium")
-- -- }}}
