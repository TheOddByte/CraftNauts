--[[
    Log API. This API allows calls to write errors, warnings, and information to a log file for later review

    @version 1.0, 24 September 2013, BIT
    @author  TheOriginalBIT, BIT
--]]

local file = fs.open("/craftnauts.log", 'w')
local nativeError = _G.error

file.write("============= LOG START =============")

local function logWrite(output)
  file.write(output)
  file.flush()
end

local function getCaller()
  local ok, err = pcall(error, "", 5)
  return err:match("(%a+)%.?.-:.-") or "unknown" --# extract file name, remove extension
end

local function formatMessage(_type, ...)
  local caller = getCaller() --# the calling API
  local clock = math.round(os.clock(), 1)
  local msg = table.concat(arg, ' ')
  return string.format("[%s] [%s] [%s] %s", _type, caller, clock, msg)
end

--[[
    Logs an error string to the log file with the prefix of [ERROR] and the clock time

    @param  ...  any number of strings (or numbers) to output to the log file
--]]
function e(...)
  local msg = formatMessage("ERROR", ...)
  logWrite(msg)
end

--[[
    Logs a warning string to the log file with the prefix of [WARNING] and the clock time
    
    @param  ...  any number of strings (or numbers) to output to the log file
--]]
function w(...)
  local msg = formatMessage("WARNING", ...)
  logWrite(msg)
end

--[[
    Logs an information string to the log file with the prefix of [INFORMATION] and the clock time
    
    @param  ...  any number of strings (or numbers) to output to the log file
--]]
function i(...)
  local msg = formatMessage("INFO", ...)
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
  e(msg)
  nativeError(msg, parseThrowbackLevel(lvl))
end