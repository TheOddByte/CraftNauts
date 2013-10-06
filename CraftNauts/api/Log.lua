--[[
    Log API. This API allows calls to write errors, warnings, and information to a log file for later review

    @version 1.0, 24 September 2013, BIT
    @author  TheOriginalBIT, BIT
--]]

local file = fs.open("/craftnauts.log", 'w')
local nativeError = _G.error

local function logWrite(output)
  file.writeLine(output)
  file.flush()
end

logWrite("============= LOG START =============")

local callerThrowback = 5

local function getCaller()
  local ok, err = pcall(nativeError, "", callerThrowback)
  return err:match("(%a+)%.?.-:.-") or "unknown" --# extract file name, remove extension
end

local function getCallerLineNumber()
  local ok, err = pcall(nativeError, "", callerThrowback)
  return err:match("%a+:(%d+).-") or 0
end

local function formatMessage(_type, needsLine, ...)
  local caller = getCaller() --# the calling API
  local clock = math.ceil(os.clock())
  local msg = table.concat(arg, ' ')
  if needsLine then
    caller = string.format("%s:%d", caller, getCallerLineNumber())
  end
  return string.format("[%s] [%s] [%s] %s", _type, caller, clock, msg)
end

--[[
    Logs an error string to the log file with the prefix of [ERROR] and the clock time

    @param  ...  any number of strings (or numbers) to output to the log file
--]]
function e(...)
  local msg = formatMessage("ERROR", true, ...)
  logWrite(msg)
end

--[[
    Logs a warning string to the log file with the prefix of [WARNING] and the clock time
    
    @param  ...  any number of strings (or numbers) to output to the log file
--]]
function w(...)
  local msg = formatMessage("WARNING", true, ...)
  logWrite(msg)
end

--[[
    Logs an information string to the log file with the prefix of [INFORMATION] and the clock time
    
    @param  ...  any number of strings (or numbers) to output to the log file
--]]
function i(...)
  local msg = formatMessage("INFO", false, ...)
  logWrite(msg)
end

--[[
    Writes the log end and closes the log file handle, should only be used when the program is about to end
    
    @param  ...  any number of strings (or numbers) to output to the log file
--]]
function close()
  logWrite("============== LOG END ==============")
  file.close()
  _G.error = nativeError
end

--[[
  An override to error that will make use of the Log API

  @param  (same as default error function)
--]]
function _G.error(msg, lvl)
  callerThrowback = 6 -- trick the caller system into not pointing here
  e(msg)
  callerThrowback = 5
  nativeError(msg, (lvl == 0 and 0 or lvl and (lvl + 1) or 2))
end

i("Loading API: Log.lua")