path = shell.dir()

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
