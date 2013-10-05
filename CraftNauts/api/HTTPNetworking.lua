--[[
    The HTTPNetworking API runs as a coroutine waiting until it is needed. When needed it acts as a medium between the internet-based server and the game

    @version 1.0, 5 October 2013, BIT
    @author  TheOriginalBIT, BIT
--]]

assert(Log, "Log should be loaded before HTTPNetworking", 0)

Log.i("HTTPNetworking init!")

local routineNetworking = nil
local busy = false

local function try(func, ...)
  local ok, err = pcall(func, ...)
  if not ok then
    Log.e("Caught: ", err or "undefined")
  end
  return ok, err
end

local function decode(str)
  if not str then return nil end
  str = tostring(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

local function waitForResponse()
  local event, _, data
  repeat
    event, _, data = coroutine.yield()
  until event:sub(1, 4) == "http"
  Log.i("Got response: ", event)
  return event == "http_success", data
end

local function handleCommunication(url, callback, data)
  -- try to send data
  Log.i("Requesting: ", url)
  try(http.request, url, textutils.urlEncode(data))

  -- wait for a response
  local success, response = waitForResponse()
  Log.i("Response for: ", url)

  -- check response code
  local responseCode = response and response.getResponseCode() or 0
  
  if not success or responseCode ~= 200 then
    Log.i("Connection failure!")
    try(callback, url, false, "Connection failure: "..responseCode)
  else
    Log.i("Decoding response")
    local responseData = decode(response.readAll())
    response.close()
    if callback then
      try(callback, url, true, responseData)
    end
  end
end

local function run()
  while true do
    busy = false
    local url, callback, data = coroutine.yield()
    busy = true

    if url == "die" then
      return Log.i("Shutting down HTTPNetworking routine")
    end

    -- handle invalid callback
    if callback and type(callback) ~= "function" then
      Log.e(string.format("Invalid callback type ('%s') for url: %s", type(callback), url))
      callback = nil
    end

    try(handleCommunication, url, callback, data)    
  end
end

--[[
    Returns whether the networking coroutine is still working

    @return   boolean   whether the coroutine is alive
--]]
function isAlive()
  return routineNetworking and coroutine.status(routineNetworking) ~= "dead" or false
end

--[[
    Starts/restarts the networking coroutine
--]]
function startCoroutine()
  if not isAlive() then
    Log.i("Starting networking routine")
    routineNetworking = coroutine.create(run)
    coroutine.resume(routineNetworking)
  else
    Log.w("Networking routine is already started")
  end
end

--[[
    This function makes a POST request out to the internet with the supplied data, invoking the callback when provided

    @param    url         string      the address of the server to POST
    @param    data        string      the data to POST to the server
    @param    callback    function    where to send response data to for processing
    @return               boolean     whether or not it was successful
--]]
function call(url, data, callback)
  if busy then
    Log.w("I'm busy, you should be validating that!")
    return false
  end
  return coroutine.resume(routineNetworking, url, callback, data)
end

--[[
    This function is what to call to resume the networking routine, anywhere that networking occurs, provide this function with the event data
    NOTE: Will not run if not busy

    @param    vararg    the event details
--]]
function event(...)
  if not busy then
    Log.w("Recieved event details when I've nothing to do, am I meant to be doing something?")
    return false
  end
  coroutine.resume(routineNetworking, ...)
  return true
end

--[[
    Returns whether the networking routine is currently working on a request

    @return   boolean   whether a request is being performed
--]]
function isBusy()
  return busy
end

if http then
  startCoroutine()
else
  Log.w("HTTP API is turned off, not starting HTTPNetworking routine")
end