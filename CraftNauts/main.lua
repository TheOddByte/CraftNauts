path = shell.dir()

--[[
    A read function override that fixes various bugs in the default read as well as allows for a read limit. The mask also now supports multiple character masking.
    All other functionality is the same as the default read function.

    @param    _mask     string  (optional)  One or many characters to show instead of the user's input
    @param    _history  table   (optional)  A sequential-numerically indexed table containing the user's input histry
    @param    _limit    number  (optional)  The maximum amount of characters to display
    @return             string
--]]
function read( _mask, _history, _limit )
  if _mask and type(_mask) ~= "string" then
    error("Invalid parameter #1: Expected string, got "..type(_mask), 2)
  end
  if _history and type(_history) ~= "table" then
    error("Invalid parameter #2: Expected table, got "..type(_history), 2)
  end
  if _limit and type(_limit) ~= "number" then
    error("Invalid parameter #3: Expected number, got "..type(_limit), 2)
  end
 
  term.setCursorBlink(true)
 
  local input = ""
  local pos = 0
  local historyPos = nil
 
  local sw, sh = term.getSize()
  local sx, sy = term.getCursorPos()
 
  local function redraw( _special )
    local scroll = (sx + pos >= sw and (sx + pos) - sw or 0)
    local replace = _special or _mask
    local output = replace and (string.rep( replace, math.ceil(#input / #replace) - scroll )):sub(1, #input) or input:sub(scroll + 1)
    term.setCursorPos( sx, sy )
    term.write( output )
    term.setCursorPos( sx + pos - scroll, sy )
  end
 
  local nativeScroll = term.scroll
  term.scroll = function( _n ) local ok, err = pcall( function() return nativeScroll( _n ) end ) if ok then sy = sy - _n return err end error( err, 2 ) end
 
  while true do
    local event, code = os.pullEventRaw()
    if event == "char" and (not _limit or #input < _limit) then
      input = input:sub(1, pos)..code..input:sub(pos+1)
      pos = pos + 1
    elseif event == "key" then
      if code == keys.enter or code == keys.numPadEnter then
        break
      elseif code == keys.backspace and pos > 0 then
        redraw(' ')
        input = input:sub(1, math.max(pos-1, 0))..input:sub(pos+1)
        pos = math.max(pos-1, 0)
      elseif code == keys.delete and pos < #input then
        redraw(' ')
        input = input:sub(1, pos)..input:sub(pos+2)
      elseif code == keys.home then
        pos = 0
      elseif code == keys["end"] then
        pos = #input
      elseif code == keys.left and pos > 0 then
        pos = math.max(pos-1, 0)
      elseif code == keys.right and pos < #input then
        pos = math.min(pos+1, #input)
      elseif _history and code == keys.up or code == keys.down then
        redraw(' ')
        if code == keys.up then
          if not historyPos then
            historyPos = #_history
          elseif historyPos > 1 then
            historyPos = historyPos - 1
          end
        else
          if historyPos ~= nil and historyPos < #_history then
            historyPos = math.max(historyPos+1, #_history)
          elseif historyPos == #_history then
            historyPos = nil
          end
        end
 
        if historyPos and #_history > 0 then
          input = string.sub(_history[historyPos], 1, _limit) or ""
          pos = #input
        else
          input = ""
          pos = 0
        end
      end
    end
 
    redraw(_mask)
  end
 
  term.scroll = nativeScroll
 
  term.setCursorBlink(false)
 
  if sy + 1 > sh then
    term.scroll(sy + 1 - sh)
    term.setCursorPos(1, sy)
  else
    term.setCursorPos(1, sy + 1)
  end
 
  return input
end

--[[
  Loads all files as API's in the API folder
  @return boolean
--]]
local function loadAPIs()
  files = fs.list(path .. "/api/")
  for id, name in pairs(files) do
    if not os.loadAPI(path .. "/api/" .. name) then 
      return false 
    end
    print("Loading: " .. name)
  end
  return true
end

loadAPIs()

--[[
    Initialize Game and run it
--]]
