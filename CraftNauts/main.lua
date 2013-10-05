path = shell.dir()

--[[
    Parses the throwback level required for assert and error, making sure to not have the blame cast to the wrong function

    @param  level  number  the desired throwback level before our code overriding
    @return        number  the new level to throw
--]]
function parseThrowbackLevel(level)
  --# make sure that we don't get the blame if no level is provided
  level = level or 1
  --# preserve levels of 0 or else make sure we don't get blame
  return level == 0 and 0 or level + 1
end

--[[
    Works just like the default assert only allows for a throwback level to be supplied

    @param  condition  any     the condition to check, will trigger assert when nil or false
    @param  message    string  (optional) the message to error with
    @param  throwback  number  (optional) the level of error to produce, i.e. which function to blame
    @return            any     returns what was supplied in order to allow assignment assert statements
--]]
function assert(condition, message, throwback)
  if not condition then
    error(message or "assertion failed!", parseLevel(throwback))
  end
  return condition
end

--[[
    Safe pairs function, doesn't error when table is nil
    
    @param _t table the table to iterate through
    @return         key
    @return         value
--]]
function safePairs( _t )
  --# a table of keys
  local tKeys = {}
  for k,v in pairs( _t ) do
    table.insert(tKeys, k)
  end
  local i = 0
  return function()
    i = i + 1
    return tKeys[i], _t[tKeys[i]]
  end
end

--[[
    Round a number to the decimal place supplied or nearest whole number.
    Note: trailing 0's will be removed, Lua does this, if printing suggested fix is to use string.format to make sure trailing 0's are present

    @param    number    the number to round
    @param    number    the decimal place to round to
    @return   number    the rounded number
--]]
function math.round(num, idp) --# BOOM! injected.
  assert(type(num) == "number", "Arg #1: Expected number, got "..type(num), 2)
  assert(type(idp) == "number", "Arg #2: Expected number, got "..type(idp), 2)
  local mult = 10^(idp or 0)
  if num >= 0 then
    return math.floor(num * mult + 0.5 ) / mult
  end
  return math.ceil(num * mult - 0.5) / mult
end

--[[
    A read function override that fixes various bugs in the default read as well as allows for a read limit. The mask also now supports multiple character masking.
    All other functionality is the same as the default read function.

    @param    _mask     string  (optional)  One or many characters to show instead of the user's input
    @param    _history  table   (optional)  A sequential-numerically indexed table containing the user's input histry
    @param    _limit    number  (optional)  The maximum amount of characters to display
    @return             string
--]]
function read( _mask, _history, _limit )
  assert(not _mask or nativeType(_mask) == "string", "Invalid argument #1: Expected string, got "..nativeType(_mask), 2)
  assert( not _history or nativeType(_history) == "table", "Invalid argument #2: Expected table, got "..nativeType(_history), 2)
  assert( not _limit or nativeType(_limit) == "number", "Invalid argument #3: Expected number, got "..nativeType(_limit), 2)
 
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
    Log.i("Loading API: " .. name)
  end
  return true
end

--[[
    Initialize Game and run it
--]]
local function main(...)
  --# init game
  loadAPIs()

  --# game loop

  --# cleanup
  return true
end



--# call the main function passing the runtime arguments to it
local ok, err = pcall(main, ...)

if not ok and err ~= "Terminated" then
  Log.e("[FATAL] ", err)
  --# there has been an error, handle it here, GUI?
end

Log.close()