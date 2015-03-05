-- Load Extensions
local application = require "mjolnir.application"
local eventtap    = require "mjolnir._asm.eventtap"
local fnutils     = require "mjolnir.fnutils"
local hotkey      = require "mjolnir.hotkey"
local keycodes    = require "mjolnir.keycodes"
local timer       = require "mjolnir._asm.timer"
local transform   = require "mjolnir.sk.transform"
local window      = require "mjolnir.window"

local alert       = require "mjolnir.alert"
local grid        = require "mjolnir.bg.grid"
local slateops    = require "mjolnir.chdiza.slateops"
-- local transform   = require "mjolnir.sk.transform"
local settings    = require "mjolnir._asm.settings"
local pathwatcher = require "mjolnir._asm.pathwatcher"
local data        = require "mjolnir._asm.data"
local appfinder   = require "mjolnir.cmsj.appfinder"
local inspect     = require 'inspect'

local ext         = require "mjolnir.helpers"
local ext         = require "mjolnir.ext"

-- Music controls
local audiodevice = require "mjolnir._asm.sys.audiodevice"

-- Sound and Notifications
local sound = require "mjolnir._asm.ui.sound"
local alert_sound = sound.get_byname("Tink")

-- Set up hotkey combinations
local hyper = {"ctrl", "shift"}
local mash  = {"ctrl", "shift", "alt"}
local smash = {"ctrl", "shift", "alt", "cmd"}


local function nudge(dir, dist)
  local size = 0

  if dist == "s" then
    size = 1
  elseif dist == "m" then
    size = 11
  elseif dist == "l" then
    size = 100
  end

  local nsize = -1 * size

  if dir == "nw" then
    slateops.nudge(nsize,nsize)
  elseif dir == "n" then
    slateops.nudge(0,nsize)
  elseif dir == "ne" then
    slateops.nudge(size,nsize)
  elseif dir == "e" then
    slateops.nudge(size,0)
  elseif dir == "se" then
    slateops.nudge(size,size)
  elseif dir == "s" then
    slateops.nudge(0,size)
  elseif dir == "sw" then
    slateops.nudge(nsize,size)
  elseif dir == "w" then
    slateops.nudge(nsize,0)
  end
end

local function setsize(size, stock)
  local win = window.focusedwindow()
  local app = win.application(win)
  local name = app.title(app)
  local frame = win:frame()
  local w = 0
  local h = 0
  local dims = {}

  -- Generic app configs
  if stock == "m" then
    if size == "s" then
      w = 600
      h = 500
    elseif size == "m" then
      w = 800
      h = 600
    elseif size == "l" then
      w = 1200
      h = 1000
    end

    if w > 0 then
      frame.w = w
      frame.h = h
      ext.win.set(win, frame)
    end
    return
  end

  -- Per app configs
  if name == "Sublime Text 2" then
    if size == "s" then
      w = 800
      h = 600
    elseif size == "m" then
      w = 930
      h = 700
    elseif size == "l" then
      w = 1500
      h = 800
    end
  elseif name == "Google Chrome" then
    if size == "s" then
      w = 1100
      h = 980
    elseif size == "m" then
      w = 1230
      h = 1028
    elseif size == "l" then
      w = 1400
      h = 1600
    end
  elseif name == "iTerm" then
    if size == "s" then
      w = 800
      h = 600
    elseif size == "m" then
      w = 950
      h = 600
    elseif size == "l" then
      w = 1100
      h = 800
    end
  elseif name == "Finder" then

  elseif name == "Xcode" then

  elseif name == "Slack" then
    if size == "s" then
      w = 900
      h = 600
    elseif size == "m" then
      w = 1000
      h = 700
    elseif size == "l" then
      w = 1200
      h = 1000
    end

  elseif name == "Mailbox (Beta)" then

  elseif name == "Sunrise" then

  elseif name == "Console" then

  elseif name == "Sequel Pro" then
    if size == "s" then
      w = 800
      h = 600
    elseif size == "m" then
      w = 950
      h = 700
    elseif size == "l" then
      w = 1100
      h = 800
    end
  end

  if w > 0 then
    window.setsize(win, { w = w, h = h })
  end
end

local function resize(dir, dist)
  local size = 0

  if dist == "s" then
    size = 1
  elseif dist == "m" then
    size = 10
  elseif dist == "l" then
    size = 50
  elseif dist == "x" then
    size = 100
  end

  local nsize = -1 * size

  if dir == "xinc" then
    slateops.resize(size,0)
  elseif dir == "xdec" then
    slateops.resize(nsize,0)
  elseif dir == "yinc" then
    slateops.resize(0,size)
  elseif dir == "ydec" then
    slateops.resize(0,nsize)
  end
end

function push(dir)
  local win = window.focusedwindow()

  if dir == "n" then
    ext.win.send(win, "up")
  elseif dir == "e" then
    ext.win.send(win, "right")
  elseif dir == "s" then
    ext.win.send(win, "down")
  elseif dir == "w" then
    ext.win.send(win, "left")
  elseif dir == "ne" then
    ext.win.send(win, "upright")
  elseif dir == "se" then
    ext.win.send(win, "downright")
  elseif dir == "sw" then
    ext.win.send(win, "downleft")
  elseif dir == "nw" then
    ext.win.send(win, "upleft")
  end

end

function saveSpaceWins()
  local wins = ext.utils.visiblewindows()

  for k, win in pairs(wins) do
    ext.utils.windowinfo_set(win)
  end
end

function replaceSpaceWins()
  local wins = ext.utils.visiblewindows()

  for k, win in pairs(wins) do
    ext.utils.windowinfo_reset(win)
  end
end

-- testing stuff
hotkey.bind(hyper, 'T', function() ext.win.pos(window.focusedwindow(), "update") end)
hotkey.bind(mash, 'T', function() ext.win.pos(window.focusedwindow(), "load") end)

hotkey.bind(hyper, 'C', function() saveSpaceWins() end)
hotkey.bind(hyper, 'V', function() replaceSpaceWins() end)
-- Constantly save the window positions in the active space.
-- (actually, that kinda prevents to more than 5 seconds ago...
 -- maybe have two save types?)
-- local t = timer.new(5, saveSpaceWins)
-- t:start()

hotkey.bind(hyper, "tab", function() ext.win.cycle(window.focusedwindow()) end)

-- SETSIZES
-- Set window sizes, with per app config.
hotkey.bind(hyper, 'E', function() setsize("s") end)
hotkey.bind(hyper, 'D', function() setsize("m") end)
hotkey.bind(hyper, 'X', function() setsize("l") end)
-- Generic app sizes
hotkey.bind(mash, 'E', function() setsize("s", "m") end)
hotkey.bind(mash, 'D', function() setsize("m", "m") end)
hotkey.bind(mash, 'X', function() setsize("l", "m") end)

-- RESIZES
-- Small resizes
hotkey.bind(smash, '.', function() resize("xinc", "s") end)
hotkey.bind(smash, 'N', function() resize("xdec", "s") end)
hotkey.bind(smash, 'M', function() resize("yinc", "s") end)
hotkey.bind(smash, ',', function() resize("ydec", "s") end)
-- Medium resizes
hotkey.bind(mash, '.', function() resize("xinc", "m") end)
hotkey.bind(mash, 'N', function() resize("xdec", "m") end)
hotkey.bind(mash, 'M', function() resize("yinc", "m") end)
hotkey.bind(mash, ',', function() resize("ydec", "m") end)
-- Large resizes
hotkey.bind(hyper, '.', function() resize("xinc", "l") end)
hotkey.bind(hyper, 'N', function() resize("xdec", "l") end)
hotkey.bind(hyper, 'M', function() resize("yinc", "l") end)
hotkey.bind(hyper, ',', function() resize("ydec", "l") end)

-- NUDGES
-- Small nudges
hotkey.bind(smash, 'H', function() nudge("w", "s") end)
hotkey.bind(smash, 'J', function() nudge("s", "s") end)
hotkey.bind(smash, 'K', function() nudge("n", "s") end)
hotkey.bind(smash, 'L', function() nudge("e", "s") end)
-- Medium nudges
hotkey.bind(mash, 'H', function() nudge("w", "m") end)
hotkey.bind(mash, 'J', function() nudge("s", "m") end)
hotkey.bind(mash, 'K', function() nudge("n", "m") end)
hotkey.bind(mash, 'L', function() nudge("e", "m") end)
-- Large nudges
hotkey.bind(hyper, 'H', function() nudge("w", "l") end)
hotkey.bind(hyper, 'J', function() nudge("s", "l") end)
hotkey.bind(hyper, 'K', function() nudge("n", "l") end)
hotkey.bind(hyper, 'L', function() nudge("e", "l") end)

-- SNAPS
-- Snap to corners
hotkey.bind(hyper, 'Q', function() push("nw") end)
hotkey.bind(hyper, 'W', function() push("ne") end)
hotkey.bind(hyper, 'S', function() push("se") end)
hotkey.bind(hyper, 'A', function() push("sw") end)

-- SCREENS
hotkey.bind(hyper, ']', grid.pushwindow_nextscreen)
hotkey.bind(hyper, '[', grid.pushwindow_prevscreen)

--WINDOW FOCUS
hotkey.bind(hyper, 'Y',  function() window.focusedwindow():focuswindow_west() end)
hotkey.bind(hyper, 'O', function() window.focusedwindow():focuswindow_east() end)
hotkey.bind(hyper, 'I',    function() window.focusedwindow():focuswindow_north() end)
hotkey.bind(hyper, 'U',  function() window.focusedwindow():focuswindow_south() end)

--PUSHES
hotkey.bind(mash, 'Y', function() push("w") end)
hotkey.bind(mash, 'U', function() push("s") end)
hotkey.bind(mash, 'I', function() push("n") end)
hotkey.bind(mash, 'O', function() push("e") end)

-- HELPER FUNCTIONS
hotkey.bind(mash, 'R', function() mjolnir.reload() end)
-- "fancy" reloading
function reload_config(files)
  mjolnir.reload()
end
pathwatcher.new(os.getenv("HOME") .. "/.mjolnir/", reload_config):start()
-- alert.show("Config reloaded")

-- hotkey.bind(mash, 'Q', function() nudge("nw", "s") end)
-- hotkey.bind(mash, 'E', function() nudge("ne", "s") end)
-- hotkey.bind(mash, 'C', function() nudge("se", "s") end)
-- hotkey.bind(mash, 'Z', function() nudge("sw", "s") end)

-- hotkey.bind(mash, ';', function() grid.snap(window.focusedwindow()) end)
-- hotkey.bind(mash, "'", function() fnutils.map(window.visiblewindows(), grid.snap) end)

-- hotkey.bind(mash,      '=', function() grid.adjustwidth(1) end)
-- hotkey.bind(mash,      '-', function() grid.adjustwidth(-1) end)
-- hotkey.bind(mashshift, '=', function() grid.adjustheight(1) end)
-- hotkey.bind(mashshift, '-', function() grid.adjustheight(-1) end)

-- hotkey.bind(mashshift, 'left',  function() window.focusedwindow():focuswindow_west() end)
-- hotkey.bind(mashshift, 'right', function() window.focusedwindow():focuswindow_east() end)
-- hotkey.bind(mashshift, 'up',    function() window.focusedwindow():focuswindow_north() end)
-- hotkey.bind(mashshift, 'down',  function() window.focusedwindow():focuswindow_south() end)

-- hotkey.bind(mash,      'M', grid.maximize_window)
-- hotkey.bind(mashshift, 'M', function() window.focusedwindow():minimize() end)

-- hotkey.bind(mash,      'F', function() window.focusedwindow():setfullscreen(true) end)
-- hotkey.bind(mashshift, 'F', function() window.focusedwindow():setfullscreen(false) end)

-- hotkey.bind(mash, 'N', grid.pushwindow_nextscreen)
-- hotkey.bind(mash, 'P', grid.pushwindow_prevscreen)

-- hotkey.bind(mash, 'J', grid.pushwindow_down)
-- hotkey.bind(mash, 'K', grid.pushwindow_up)
-- hotkey.bind(mash, 'H', grid.pushwindow_left)
-- hotkey.bind(mash, 'L', grid.pushwindow_right)

-- hotkey.bind(mash, 'U', grid.resizewindow_taller)
-- hotkey.bind(mash, 'O', grid.resizewindow_wider)
-- hotkey.bind(mash, 'I', grid.resizewindow_thinner)
-- hotkey.bind(mash, 'Y', grid.resizewindow_shorter)

-- hotkey.bind(mashshift, 'space', spotify.displayCurrentTrack)
-- hotkey.bind(mashshift, 'P',     spotify.play)
-- hotkey.bind(mashshift, 'O',     spotify.pause)
-- hotkey.bind(mashshift, 'N',     spotify.next)
-- hotkey.bind(mashshift, 'I',     spotify.previous)

-- hotkey.bind(mashshift, 'T', function() alert.show(os.date("%A %b %d, %Y - %I:%M%p"), 4) end)

-- hotkey.bind(mashshift, ']', function() audiodevice.defaultoutputdevice():setvolume(audiodevice.current().volume + 5) end)
-- hotkey.bind(mashshift, '[', function() audiodevice.defaultoutputdevice():setvolume(audiodevice.current().volume - 5) end)

-- alert_sound:play()
-- alert.show("Mjolnir, at your service.", 3)
