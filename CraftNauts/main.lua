path = shell.dir()

local function loadAPIs()
	files = fs.list(path .. "/api/")
	for id, name in pairs(files) do
		os.loadAPI(path .. "/api/" .. name)
		print("Loading: " .. name)
	end
end

loadAPIs()

--[[
    Initialize Game and run it
--]]
