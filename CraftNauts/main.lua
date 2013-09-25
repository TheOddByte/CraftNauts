path = shell.dir()

--[[
    Parses the throwback level required for assert and error, making sure to not have the blame cast to the wrong function

    @param  level  number  the desired throwback level before our code overriding
    @return        number  the new level to throw
--]]
local function parseLevel(level)
  --# make sure that we don't get the blame if no level is provided
  level = level or 1
  --# preserve levels of 0 or else make sure we don't get blame
  return level == 0 and 0 or leve + 1
end

--[[
    Log API. This API allows calls to write errors, warnings, and information to a log file for later review

    @version 1.0, 24 September 2013, BIT
    @author  TheOriginalBIT, BIT
--]]
do
  --# os.day/time/clock are used to avoid duplicates
  local fileName = string.format("/.craftnauts-%s-%s-%s.log", os.day(), os.time(), os.clock())

  local file = fs.open(fileName, "a")
  file.write("============= LOG START =============")
  
  local function logWrite(output)
    file.write(output)
    file.flush()
  end
  
  --# backup the error so we can restore it later
  nativeError = _G.error
  Log = {
    --[[
        Logs an error string to the log file with the prefix of [ERROR] and the clock time

        @param  ...  any number of strings (or numbers) to output to the log file
    --]]
    e = function(...)
      logWrite(string.format("[ERROR] %s: %s", os.clock(), table.concat(arg)))
    end;

    --[[
        Logs a warning string to the log file with the prefix of [WARNING] and the clock time
        
        @param  ...  any number of strings (or numbers) to output to the log file
    --]]
    w = function(...)
      logWrite(string.format("[WARNING] %s: %s", os.clock(), table.concat(arg)))
    end;

    --[[
        Logs an information string to the log file with the prefix of [INFORMATION] and the clock time
        
        @param  ...  any number of strings (or numbers) to output to the log file
    --]]
    i = function(...)
      logWrite(string.format("[INFO] %s: %s", os.clock(), table.concat(arg)))
    end;

    --[[
        Writes the log end and closes the log file handle, should only be used when the program is about to end
        
        @param  ...  any number of strings (or numbers) to output to the log file
    --]]
    pack = function()
      logWrite("============== LOG END ==============")
      file.close()
    end;
  }

  --[[
      An override to error that will make use of the Log API

      @param  (same as default)
  --]]
  function _G.error(msg, lvl)
    Log.e(msg)
    nativeError(msg, parseLevel(lvl))
  end
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
    print("Loading: " .. name)
  end
  return true
end

loadAPIs()

--[[
    Initialize Game and run it
--]]
local function main(...)
  --# init game

  --# game loop

  --# cleanup
  return true
end

--# call the main function passing the runtime arguments to it
local ok, err = pcall(main, ...)

if not ok and err ~= "Terminated" then
  --# there has been an error, handle it here, GUI?
end

Log.close()
_G.error = nativeError