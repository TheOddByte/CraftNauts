path = shell.dir()

 for _, file in ipairs(fs.list(path .. "/api/")) do
       os.loadAPI(path.."/api/"..file)
 end

--[[
Initialize Game and run it
]]
