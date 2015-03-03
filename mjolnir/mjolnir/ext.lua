local application = require "mjolnir.application"
local eventtap    = require "mjolnir._asm.eventtap"
local fnutils     = require "mjolnir.fnutils"
local hotkey      = require "mjolnir.hotkey"
local keycodes    = require "mjolnir.keycodes"
local timer       = require "mjolnir._asm.timer"
local transform   = require "mjolnir.sk.transform"
local window      = require "mjolnir.window"
local alert       = require "mjolnir.alert"
local settings    = require "mjolnir._asm.settings"
-- local tiling      = require "mjolnir.tiling"
local spaces      = require "mjolnir.spaces"
local undocumented = require("mjolnir._asm.hydra.undocumented")
local inspect     = require 'inspect'

-- extensions
local ext = {
  frame = {},
  win = {},
  app = {},
  utils = {}
}


ext.win.margin     = 0
ext.win.animate    = true
ext.win.fixenabled = false
ext.win.fullframe  = true


-- saved window positions
ext.win.positions = settings.get("pos") or {}
-- couple helper mappings
-- ext.win.title_to_ids = settings.get("title_to_ids") or {}
-- ext.win.title_to_info = settings.get("title_to_info") or {}


-- check if simbl is running
-- if so, then it's for menubarhider,
-- and fullframe should be anabled
if os.execute("ps xc | grep -q SIMBL") then
  ext.win.fullframe = true
end

-- returns frame pushed to screen edge
function ext.frame.push(screen, direction)
  local m = ext.win.margin
  local h = screen.h - m
  local w = screen.w - m
  local x = screen.x + m
  local y = screen.y + m

  local frames = {
    up = function()
      return { x = x, y = y, w = w - m, h = h / 2 - m }
    end,

    down = function()
      return { x = x, y = y + h / 2 - m, w = w - m, h = h / 2 - m }
    end,

    left = function()
      return { x = x, y = y, w = w / 2 - m, h = h - m }
    end,

    right = function()
      return { x = x + w / 2 - m, y = y, w = w / 2 - m, h = h - m }
    end
  }

  return frames[direction]()
end

-- returns frame moved by ext.win.margin
function ext.frame.nudge(frame, screen, direction)
  local m = ext.win.margin
  local h = screen.h - m
  local w = screen.w - m
  local x = screen.x + m
  local y = screen.y + m

  local modifyframe = {
    up = function(frame)
      frame.y = math.max(y, frame.y - m)
      return frame
    end,

    down = function(frame)
      frame.y = math.min(y + h - frame.h - m, frame.y + m)
      return frame
    end,

    left = function(frame)
      frame.x = math.max(x, frame.x - m)
      return frame
    end,

    right = function(frame)
      frame.x = math.min(x + w - frame.w - m, frame.x + m)
      return frame
    end
  }

  return modifyframe[direction](frame)
end

-- returns frame sent to screen edge
function ext.frame.send(frame, screen, direction)
  local m = ext.win.margin
  local h = screen.h - m
  local w = screen.w - m
  local x = screen.x + m
  local y = screen.y + m

  local modifyframe = {
    up    = function(frame) frame.y = y end,
    down  = function(frame) frame.y = y + h - frame.h - m end,
    left  = function(frame) frame.x = x end,
    right = function(frame) frame.x = x + w - frame.w - m end,
    upright    = function(frame)
      frame.x = x + w - frame.w - m
      frame.y = y
    end,
    downright  = function(frame)
      frame.x = x + w - frame.w - m
      frame.y = y + h - frame.h - m
    end,
    downleft  = function(frame)
      frame.x = x
      frame.y = y + h - frame.h - m
    end,
    upleft = function(frame)
      frame.x = x
      frame.y = y
    end
  }

  modifyframe[direction](frame)
  return frame
end

-- returns frame fited inside screen
function ext.frame.fit(frame, screen)
  frame.w = math.min(frame.w, screen.w - ext.win.margin * 2)
  frame.h = math.min(frame.h, screen.h - ext.win.margin * 2)

  return frame
end

-- returns frame centered inside screen
function ext.frame.center(frame, screen)
  frame.x = screen.w / 2 - frame.w / 2 + screen.x
  frame.y = screen.h / 2 - frame.h / 2 + screen.y

  return frame
end

-- get screen frame
function ext.win.screenframe(win)
  local funcname = ext.win.fullframe and "fullframe" or "frame"
  local winscreen = win:screen()
  return winscreen[funcname](winscreen)
end

-- set frame
function ext.win.set(win, frame, time)
  time = time or 0.15

  if ext.win.animate then
    transform:setframe(win, frame, time)
  else
    win:setframe(frame)
  end
end

-- ugly fix for problem with window height when it's as big as screen
function ext.win.fix(win)
  if ext.win.fixenabled then
    local screen = ext.win.screenframe(win)
    local frame = win:frame()

    if (frame.h > (screen.h - ext.win.margin * 2)) then
      frame.h = screen.h - ext.win.margin * 10
      ext.win.set(win, frame)
    end
  end
end

-- pushes window in direction
function ext.win.push(win, direction)
  local screen = ext.win.screenframe(win)
  local frame

  frame = ext.frame.push(screen, direction)

  ext.win.fix(win)
  ext.win.set(win, frame)
end

-- nudges window in direction
function ext.win.nudge(win, direction)
  local screen = ext.win.screenframe(win)
  local frame = win:frame()

  frame = ext.frame.nudge(frame, screen, direction)
  ext.win.set(win, frame, 0.05)
end

-- push and nudge window in direction
function ext.win.pushandnudge(win, direction)
  ext.win.push(win, direction)
  ext.win.nudge(win, direction)
end

-- sends window in direction
function ext.win.send(win, direction)
  local screen = ext.win.screenframe(win)
  local frame = win:frame()

  frame = ext.frame.send(frame, screen, direction)

  ext.win.fix(win)
  ext.win.set(win, frame)
end

-- centers window
function ext.win.center(win)
  local screen = ext.win.screenframe(win)
  local frame = win:frame()

  frame = ext.frame.center(frame, screen)
  ext.win.set(win, frame)
end

-- fullscreen window with margin
function ext.win.full(win)
  local screen = ext.win.screenframe(win)
  local frame = {
    x = ext.win.margin + screen.x,
    y = ext.win.margin + screen.y,
    w = screen.w - ext.win.margin * 2,
    h = screen.h - ext.win.margin * 2
  }

  ext.win.fix(win)
  ext.win.set(win, frame)

  -- center after setting frame, fixes terminal
  ext.win.center(win)
end

-- throw to next screen, center and fit
function ext.win.throw(win, direction)
  local framefunc = ext.win.fullframe and "fullframe" or "frame"
  local screenfunc = direction == "next" and "next" or "previous"

  local winscreen = win:screen()
  local throwscreen = winscreen[screenfunc](winscreen)
  local screen = throwscreen[framefunc](throwscreen)

  local frame = win:frame()

  frame.x = screen.x
  frame.y = screen.y

  frame = ext.frame.fit(frame, screen)
  frame = ext.frame.center(frame, screen)

  ext.win.fix(win)
  ext.win.set(win, frame)

  win:focus()

  -- center after setting frame, fixes terminal and macvim
  ext.win.center(win)
end

-- set window size and center
function ext.win.size(win, size)
  local screen = ext.win.screenframe(win)
  local frame = win:frame()

  frame.w = size.w
  frame.h = size.h

  frame = ext.frame.fit(frame, screen)
  frame = ext.frame.center(frame, screen)

  ext.win.set(win, frame)
end

-- save and restore window positions
function ext.win.pos(win, option)
  local id = win:application():bundleid() .. "--" .. win:id()
  local frame = win:frame()

  -- saves window position if not saved before
  if option == "save" and not ext.win.positions[id] then
    ext.win.positions[id] = frame
  end

  -- force update saved window position
  if option == "update" then
    ext.win.positions[id] = frame
  end

  -- restores window position
  if option == "load" and ext.win.positions[id] then
    ext.win.set(win, ext.win.positions[id])
  end

  -- Save positions between launches
  settings.set("pos", ext.win.positions)
end

-- cycle application windows
-- https://github.com/nifoc/dotfiles/blob/master/mjolnir/cycle.lua
function ext.win.cycle(win)
  local windows = win:application():allwindows()
  windows = fnutils.filter(windows, function(win) return win:isstandard() end)

  if #windows >= 2 then
    table.sort(windows, function(a, b) return a:id() < b:id() end)
    local activewindowindex = fnutils.indexof(windows, win)

    if activewindowindex then
      activewindowindex = activewindowindex + 1
      if activewindowindex > #windows then activewindowindex = 1 end

      windows[activewindowindex]:focus()
    end
  end
end

-- launch or focus or cycle app
function ext.app.launchorfocus(app)
  local focusedwindow = window.focusedwindow()
  local currentapp = focusedwindow and focusedwindow:application():title() or nil

  if currentapp == app then
    if focusedwindow then
      local appwindows = focusedwindow:application():allwindows()
      local visiblewindows = fnutils.filter(appwindows, function(win) return win:isstandard() end)

      if #visiblewindows == 0 then
        -- try sending cmd-n for new window if no windows are visible
        ext.utils.newkeyevent({ cmd = true }, "n", true):post()
        ext.utils.newkeyevent({ cmd = true }, "n", false):post()
      else
        -- cycle windows if there are any
        ext.win.cycle(focusedwindow)
      end
    end
  else
    application.launchorfocus(app)
  end
end

-- smart browser launch or focus or cycle
function ext.app.browser()
  local browsers = { "Safari", "Google Chrome" }

  local runningapps = application.runningapplications()
  local focusedwindow = window.focusedwindow()
  local currentapp = focusedwindow and focusedwindow:application():title() or nil

  -- filter running applications by browsers array
  local runningbrowsers = fnutils.map(browsers, function(browser)
    return fnutils.find(runningapps, function(app) return app:title() == browser end)
  end)

  -- try to get index of current app in running browsers
  -- this means - is one of the browsers currently selected
  local currentindex = fnutils.indexof(fnutils.map(runningbrowsers, function(app)
    return app:title()
  end), currentapp)

  -- if there are no browsers launch the first (default) one
  -- otherwise cycle between browser windows or between browsers depending on situation
  if #runningbrowsers == 0 then
    ext.app.launchorfocus(browsers[1])
  else
    local browserindex = currentindex and (currentindex % #runningbrowsers) + 1 or 1
    ext.app.launchorfocus(runningbrowsers[browserindex]:title())
  end
end

-- properly working newkeyevent
-- https://github.com/nathyong/mjolnir.ny.tiling/blob/master/spaces.lua
function ext.utils.newkeyevent(modifiers, key, pressed)
  local keyevent

  keyevent = eventtap.event.newkeyevent({}, "", pressed)
  keyevent:setkeycode(keycodes.map[key])
  keyevent:setflags(modifiers)

  return keyevent
end

-- get a better list of visible windows than  windows.visiblewindows will give.
function ext.utils.visiblewindows()
  -- get a full list of windows and whittle it down.
  local wins = window.orderedwindows()
  local visiblewindows = {}
  fnutils.each(wins, function(win)
    -- visible windows
    if win:isvisible() == true then
      -- if not one of a couple disallowed roles
      if win:role() ~= "AXUnknown" and win:subrole() ~= "AXDialog" then
        table.insert(visiblewindows, win)
      end
    end
  end)
  return visiblewindows
end

-- get a better list of visible windows than  windows.visiblewindows will give.
function ext.utils.windowinfo_set(win)
  -- get a full list of windows and whittle it down.
  local app = win:application():bundleid()
  local appwinids = settings.get("app_info--" .. app) or {}
  local id = win:id()
  local title = win:title()
  local frame = win:frame()
  local screen = win:screen()

  -- if winids[app] ~= nil then
  --   winids[app] = winids[app]
  -- else
  --   winids[app] = {}
  -- end

  -- Save the title to id mapping for later.
  appwinids[title] = id
  -- The app info to save.
  local app_info = {
    x = frame.x,
    y = frame.y,
    w = frame.w,
    h = frame.h,
    screen = screen:id()
  }

  -- Save the stuff.
  settings.set("app_info--" .. app, appwinids)
  settings.set("app_info--" .. app .. "--" .. id, app_info)
end

function ext.utils.windowinfo_reset(win)
  -- get a full list of windows and whittle it down.
  local app = win:application():bundleid()
  local appwinids = settings.get("app_info--" .. app) or {}
  -- local winfo = ext.win.title_to_info
  local id = win:id()
  local title = win:title()
  local screen = win:screen()

  -- Look up window location by id
  local nwin = settings.get("app_info--" .. app .. "--" .. id)

  -- If the window's id isn't set, try to look it up by the window's title.
  if nwin == nil then
    local newid = appwinids[title]
    nwin = settings.get("app_info--" .. app .. "--" .. newid)
  end

  local frame = {
    x = nwin.x,
    y = nwin.y,
    w = nwin.w,
    h = nwin.h
  }

  ext.win.set(win, frame)

end

-- apply function to a window with optional params, saving it's position for restore
function dowin(fn, param)
  local win = window.focusedwindow()

  if win and not win:isfullscreen() then
    ext.win.pos(win, "save")
    fn(win, param)
  end
end

-- for simple hotkey binding
function bindwin(fn, param)
  return function() dowin(fn, param) end
end

-- apply function to a window with a timer
function timewin(fn, param)
  return timer.new(0.05, function() dowin(fn, param) end)
end

return ext
