local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local base_size = 4
local taskbar_height = base_size * 10
local icon_size = taskbar_height * 0.65
local gap_size = base_size * 0.75

beautiful.useless_gap = dpi(gap_size)

-- mykeyboardlayout = awful.widget.keyboardlayout()
local mytextclock = wibox.widget({
  format = "%b %d | %I:%M:%S %p %a",
  refresh = 1,
  widget = wibox.widget.textclock,
  align = "left",
})

-- Sound
local sound = require("config.sound")

local sound_widget = wibox.widget.textbox()
sound_widget:buttons({
  awful.button({}, 1, function()
    awful.spawn("pavucontrol")
  end),
})

local sound_closure = sound.closure()
local function update_volume()
  sound_widget:set_text(sound_closure())
end
update_volume()

local sound_timer = timer({ timeout = 1 })
sound_timer:connect_signal("timeout", update_volume)
sound_timer:start()

-- Battery
local battery = require("config.battery")

local battery_widget = wibox.widget.textbox()
battery_widget:set_align("right")
local battery_closure = battery.closure()

local function battery_update()
  battery_widget:set_text(battery_closure())
end
battery_update()

local battery_timer = timer({ timeout = 1 })
battery_timer:connect_signal("timeout", battery_update)
battery_timer:start()
--

local tasklist_buttons = {
  awful.button({}, 1, function(c)
    c:activate({ context = "tasklist", action = "toggle_minimization" })
  end),
  awful.button({}, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(-1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(1)
  end),
}

screen.connect_signal("request::desktop_decoration", function(s)
  awful.tag({ "1", "2", "3" }, s, awful.layout.layouts[1])

  local mysystray = wibox.widget.systray()
  mysystray:set_base_size(dpi(icon_size))

  s.mypromptbox = awful.widget.prompt()
  s.mylayoutbox = awful.widget.layoutbox({
    screen = s,
    forced_height = dpi(icon_size),
    buttons = {
      awful.button({}, 1, function()
        awful.layout.inc(1)
      end),
      awful.button({}, 3, function()
        awful.layout.inc(-1)
      end),
      awful.button({}, 4, function()
        awful.layout.inc(-1)
      end),
      awful.button({}, 5, function()
        awful.layout.inc(1)
      end),
    },
  })

  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = {
      awful.button({}, 1, function(t)
        t:view_only()
      end),
      awful.button({ modkey }, 1, function(t)
        if client.focus then
          client.focus:move_to_tag(t)
        end
      end),
      awful.button({}, 3, awful.tag.viewtoggle),
      awful.button({ modkey }, 3, function(t)
        if client.focus then
          client.focus:toggle_tag(t)
        end
      end),
      awful.button({}, 4, function(t)
        awful.tag.viewprev(t.screen)
      end),
      awful.button({}, 5, function(t)
        awful.tag.viewnext(t.screen)
      end),
    },
  })

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist({
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
    layout = {
      spacing = dpi(gap_size),
      layout = wibox.layout.fixed.horizontal,
    },
    widget_template = {
      layout = wibox.layout.align.vertical,
      {
        widget = wibox.container.place,
        forced_height = dpi(icon_size * 1.4),
        {
          widget = wibox.container.place,
          forced_height = dpi(icon_size),
          {
            id = "clienticon",
            layout = wibox.layout.fixed.horizontal,
            awful.widget.clienticon,
          },
        },
      },
      {
        id = "background_role",
        widget = wibox.container.background,
        wibox.widget.base.make_widget(),
      },
      -- create_callback = function(self, c)
      --   self:get_children_by_id("clienticon")[1].client = c
      -- end,
    },
  })

  -- Function to create a rounded rectangle shape
  local function rounded_rect(radius)
    return function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, radius)
    end
  end

  -- Create the wibox
  s.mywibox = awful.wibar({
    position = "top",
    screen = s,
    stretch = true,
    margins = {
      top = dpi(gap_size * 2),
      left = dpi(gap_size * 2),
      right = dpi(gap_size * 2),
    },
    height = dpi(taskbar_height),
    shape = rounded_rect(base_size),

    widget = {
      layout = wibox.layout.align.horizontal,

      -- Left Widget
      {
        layout = wibox.layout.fixed.horizontal,
        s.mytaglist,
        s.mytasklist,
        s.mypromptbox,
      },

      -- Center Widget
      {
        widget = wibox.container.place,
        {
          layout = wibox.layout.fixed.horizontal,
          mytextclock,
        },
      },

      -- Right Widget
      {
        widget = wibox.container.place,
        {
          layout = wibox.layout.fixed.horizontal,

          {
            widget = wibox.container.place,
            {
              layout = wibox.layout.fixed.horizontal,
              mysystray,
            },
          },
          sound_widget,
          battery_widget,
        },
      },
    },
  })
end)
