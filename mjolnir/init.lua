-- Load Extensions
local application = require "mjolnir.application"
local eventtap    = require "mjolnir._asm.eventtap"
local fnutils     = require "mjolnir.fnutils"
local hotkey      = require "mjolnir.hotkey"
local keycodes    = require "mjolnir.keycodes"
local timer       = require "mjolnir._asm.timer"
local scrwatcher  = require "mjolnir._asm.watcher.screen"
local transform   = require "mjolnir.sk.transform"
local window      = require "mjolnir.window"
local screen      = require "mjolnir.screen"
local totalspaces = require "mjolnir.totalspaces"

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
  if name == "Sublime Text 2" or name == "Sublime Text 3" then
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
      w = 1230
      h = 1028
    elseif size == "m" then
      w = 1280
      h = 1100
    elseif size == "l" then
      w = 1280
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

function saveSpaceWins(key, withInvisible)
  local wins = nil
  if withInvisible == nil then
    wins = ext.utils.visiblewindows()
  else
    wins = window.allwindows()
  end

  for k, win in pairs(wins) do
    ext.utils.windowinfo_set(win, key)
  end
end

function replaceSpaceWins(key, invisible)
  local wins = nil
  if withInvisible == nil then
    wins = ext.utils.visiblewindows()
  else
    wins = window.allwindows()
  end

  for k, win in pairs(wins) do
    ext.utils.windowinfo_reset(win, key)
  end
end

function saveSpaceWinsByScreens(key)
  local screens = screen.allscreens()
  local keyscr = ext.utils.table_length(screens)
  local newkey = key .. '--' .. keyscr
  saveSpaceWins(newkey)
end

function restoreSpaceWinsByScreens(key)
  local screens = screen.allscreens()
  local keyscr = ext.utils.table_length(screens)
  local newkey = key .. '--' .. keyscr
  replaceSpaceWins(newkey)
end

-- Constantly save the window positions in the active space.
function screenWatcher(key)
  -- Save screens every 5 seconds, to allow revert on screen changes
  local t = timer.new(5, function()
    saveSpaceWinsByScreens('screen-window-save')
  end)
  t:start()

  -- Restore screens whenever there's a screen change.
  local sw = scrwatcher.new(function()
    restoreSpaceWinsByScreens('screen-window-save')
  end)
  sw:start()
end
hotkey.bind(mash, 'V', function() restoreSpaceWinsByScreens('screen-window-save') end)

-- testing stuff
-- hotkey.bind(hyper, 'T', function() alert.show(show_table(window.focusedwindow():frame()) .. show_table(window.focusedwindow():screen():fullframe()), 10)
-- print(show_table(window.focusedwindow():frame()), show_table(window.focusedwindow():screen():frame()) .. window.focusedwindow():id()) end)

-- hotkey.bind(hyper, 'T', function() print(ext.screen.win_screen_info(window.focusedwindow(),window.focusedwindow():screen())) end)
-- hotkey.bind(hyper, 'T', function() os.execute("ruby /Users/ryandekker/Desktop/changespace.rb " .. window.focusedwindow():id() .. " " .. 1) end)
hotkey.bind(hyper, 'T', function()
  local id = window.focusedwindow():id()
  print (id)
  print(window.windowforid(id):title())


  local handle = io.popen("whoami")
  local result = handle:read("*a")
  handle:close()
  print(result)
  -- local wins = totalspaces.window.allwindows()
  -- for k, win in pairs(wins) do
  --   print(win:title())
  -- end
end)
hotkey.bind(mash, 'T', function() print(totalspaces.window.space(window.focusedwindow())) end)


-- Copy/paste window positions in a space.
hotkey.bind(hyper, 'C', function() saveSpaceWins('manual-app-info') end)
hotkey.bind(hyper, 'V', function() replaceSpaceWins('manual-app-info') end)


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
hotkey.bind(hyper, "'", function() ext.win.throw(window.focusedwindow(), 'next') end)
hotkey.bind(hyper, ';', function() ext.win.throw(window.focusedwindow(), 'previous') end)

--WINDOW FOCUS
-- If this is sluggish, it appears to be due to a stuck process in the
-- background, kill it and the delay seems to go away
hotkey.bind(hyper, 'Y',  function() window.focusedwindow():focuswindow_west() end)
hotkey.bind(hyper, 'O', function() window.focusedwindow():focuswindow_east() end)
hotkey.bind(hyper, 'I',    function() window.focusedwindow():focuswindow_north() end)
hotkey.bind(hyper, 'U',  function() window.focusedwindow():focuswindow_south() end)

--PUSHES
hotkey.bind(mash, 'Y', function() push("w") end)
hotkey.bind(mash, 'U', function() push("s") end)
hotkey.bind(mash, 'I', function() push("n") end)
hotkey.bind(mash, 'O', function() push("e") end)

--Shoves
hotkey.bind(smash, 'Y', function() resize("w") end)
hotkey.bind(smash, 'U', function() resize("s") end)
hotkey.bind(smash, 'I', function() resize("n") end)
hotkey.bind(smash, 'O', function() resize("e") end)

-- HELPER FUNCTIONS
hotkey.bind(mash, 'R', function() mjolnir.reload() end)
-- "fancy" reloading
function reload_config(files)
  mjolnir.reload()
end
pathwatcher.new(os.getenv("HOME") .. "/.mjolnir/", reload_config):start()


-- alert_sound:play()
-- alert.show("Mjolnir, at your service.", 3)
