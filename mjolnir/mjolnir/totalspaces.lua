local fnutils = require "mjolnir.fnutils"
local window  = require "mjolnir.window"

local totalspaces = {
  window = {}
}

-- Uses the TotalSpaces API to get the current space for this window.
function totalspaces.window.space(win)
  local handle = io.popen("ruby totalspaces2/getspace.rb " .. win:id())
  local result = handle:read("*a")
  handle:close()
  return result
end

-- Uses the TotalSpaces API to move this window to a space.
function totalspaces.window.movetospace(win, nwin)
  os.execute("ruby totalspaces2/movetospace.rb " .. win:id() .. " " .. nwin.space)
end

-- String splitting function. See: http://lua-users.org/wiki/SplitJoin
function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end


-- Uses the TotalSpaces API to return a list of all windows.
-- TODO: this is broken as is...
function totalspaces.window.allwindows()
  local handle = io.popen("ruby totalspaces2/allwindows.rb")
  local winids = handle:read("*a")
  handle:close()

  local window_ids = winids:split(',')
  local windows = {}

  fnutils.each(window_ids, function(window_id)
    print(window_id)

    -- THIS is what doesn't work. Mjolnir can't get windows that aren't on this
    -- space.
    local window = window.windowforid(tonumber(window_id))
    print (window)
    -- print(window:title())
    if window ~= nil then
      table.insert(windows, window)
    end
  end)

  return windows
end


return totalspaces
