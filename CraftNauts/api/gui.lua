--[[
    Support menus
    Make informational screens: Health, Abilities.
--]]


 --# Table saving/loading functions, The convert function turns the whole file into a table
function getTable(fileName)
     file = fs.open(fileName,"r"); nTable = textutils.unserialize(file.readAll()); file.close()
   return nTable
end




function convertFileToTable(fileName)
    if fs.exists(fileName) then
	    file = fs.open(fileName,"r")
        local nTable = {}
        local line = file.readLine()
            repeat
                table.insert(nTable,line)
                line = file.readLine()
            until line == nil
        
		  file.close()
		  return nTable
	else
	    error("File didn't exist: "..fileName,2)
	end
end




function saveTable(fileName,nTable)
     file = fs.open(fileName,"w"); file.writeLine(textutils.serialize(nTable)); file.close()
end



 --# Basic drawing functions
local function drawAt(x,y,text)
    term.setCursorPos(x,y) write(text)
end
 
 

 
local function clear()
      term.clear()
      term.setCursorPos(1,1)
end

 
 
 
local function drawBox(sX,fX,sY,fY,bColor)

    if bColor ~= nil then
        term.setBackgroundColor(bColor)
    end

   local str = ""
       for x = sX, fX do
           str = str.." "
       end


       for y = sY, fY do
           drawAt(sX,y,str)
       end
end   
   
  

  
local function drawLine(sX,fX,y,tColor,bColor,ch)
 
    if ch == nil then
        ch = " "
    end
 
    if tColor ~= nil then
        term.setTextColor(tColor)
    end
 
    if bColor ~= nil then
        term.setBackgroundColor(bColor)
    end
 
     local str = "" 
        for x = sX, fX do
            str = str..ch 
        end
  drawAt(sX,y,str)
end




function centerPrint(y,tColor,bColor,text)
    if tColor ~= nil then
        term.setTextColor(tColor)
    end
   
    if bColor ~= nil then
        term.setBackgroundColor(bColor) 
    end	
        term.setCursorPos(w/2 - #text/2,y)
        write(text)
end




--# Loading the theme file for the menu
function loadTheme(destination)

    local names = {"activeTextCol", "bColor", "defaultTextCol", "headerTextCol", "headerBackCol", "activeBackCol",}
	local colorTable = {}
	
   --# Loading the theme file and converting it into a color table.
    local menuTheme = convertFileToTable(destination)

	  --# Now we get the index names for the table
	    for i, v in ipairs(menuTheme) do
		     for k = 1,#names do
			     if string.find(v,names[k]) then name = names[k] break end
		     end
            colorTable[name] = colors[v:match("%=% *(%w+)")]
        end
	        return colorTable
			
end




local function handleMenu(tMenu,language,mNum,artProperties)

local menu = tMenu.defMenu --# The default/starting menu you will enter the first time
local visitedMenus = {}

  while true do

 --# We start with drawing the menu, Then we wait for the events
      if artProperties == nil then 
	      error("Failed, Theme was corrupt/empty",2)
	  end
 
         --# Local variables that are used for drawing the menu, They are the ones that set text color etc.
          local mBackCol        = artProperties.bColor
	      local mDefaultTextCol = artProperties.defaultTextCol
	      local mActiveTextCol  = artProperties.activeTextCol
	      local mActiveBackCol  = artProperties.activeBackCol
	      local headerBackCol   = artProperties.headerBackCol
	      local headerTextCol   = artProperties.headerTextCol
	
  
         --# Actually start drawing the menu
          term.setBackgroundColor(mBackCol)
          clear()
          drawBox(1,w,1,3,headerBackCol)
          centerPrint(2,headerTextCol,headerBackCol,tMenu[language][menu].title)

              for i = 1,#tMenu[language][menu] do

                  if mNum == i then
                      centerPrint(5 + i,mActiveTextCol,mActiveBackCol," "..tMenu[language][menu][i].name.." ")
                  else
                      centerPrint(5 + i,mDefaultTextCol,mBackCol,tMenu[language][menu][i].name)
                  end
              end


 --# Here we wait for the events and handle them
    evt, p1, mX, mY = os.pullEvent()
        if evt == "key" then
		
            if p1 == 200 then
	            mNum = mNum  - 1  if mNum < 1 then mNum = 1 end
	
	        elseif p1 == 208 then
	            mNum = mNum + 1
	                if mNum > #tMenu[language][menu] then mNum = #tMenu[language][menu] end
	
	        elseif p1 == 28 then
	            if tMenu[language][menu][mNum].destination ~= nil and tMenu[language][menu][mNum].destination ~= "_back" and tMenu[language][menu][mNum].destination ~= "_exit" and tMenu[language][menu][mNum].destination ~= "_function" then 
	                table.insert(visitedMenus,menu)
	                menu = tMenu[language][menu][mNum].destination
	                mNum = 1
	 
	 
	            elseif tMenu[language][menu][mNum].destination == "_back" then --# Going back to the previous menu that you were in
	                mNum = 1
	                menu = visitedMenus[#visitedMenus]
	                table.remove(visitedMenus,#visitedMenus)
	 
	            elseif tMenu[language][menu][mNum].destination == "_function" then
	                functionName = tMenu[language][menu][mNum]["tFunction"].name
	  
	                if tMenu[language][menu][mNum]["tFunction"]["args"] ~= nil then
	                    args = tMenu[language][menu][mNum]["tFunction"]["args"]
	  
	                else
	                    args = ""
	                end
	  
	                functionName(unpack(tMenu[language][menu][mNum]["tFunction"]["args"])) --# Calling the function from the table
	 
	            elseif tMenu[language][menu][mNum].destination == "_exit" then --# Exiting the program/game if the destionation in the table is "_exit"
	                term.setTextColor(colors.white) term.setBackgroundColor(colors.black)
	                clear()
	                error()
	            end
	 
            end
        end
  end
  
end
