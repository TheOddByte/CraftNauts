--[[
    @@Todo:
    drawCharacter - Communicates with Character API, loads the character image and stores in buffer.
    drawMap       - Communicates with Map API, loads the map and stores in buffer.
    drawBox       - Stores a box in the buffer with specified color and character
    drawText      - Stores characters in the buffer with specified background and text color.
    printText     - Same as drawText, but also wraps text to the specified width, or screen edge if unspecified.
    getPixel      - Reads a pixel from the buffer. This incldes character and text and background color.
--]]

--[[
    Screen API (WIP), sorry for hacky metatables
    @version 0.1, 23/9/2013, Sym
    @author Symmetryc, Sym
--]]

local screenWidth, screenHeight = term.getSize()

--[[
    Variable that buffers all of the information on the screen.
    The metatable makes it so that buffer[1][1].character doesn't error
    even if you haven't defined buffer[1] as a table.
    It also sets a default for everything on the screen (so that we
    don't need a term hijack)
--]]
local buffer = setmetatable({}, {
  __index = function(self, key)
    self[key] = setmetatable({}, {
      __index = function(self2, key2)
        self2[key2] = {
          backgroundColor = colors.white;
          textColor = colors.black;
          character = "";
        }
        return self2[key2]
      end;
    })
    return self[key]
  end;
})

--[[
    Caches the information so that it can be compared to the buffer
    during draw time.
--]]
local cache = setmetatable({}, getmetatable(buffer))

--[[
    Used to set pixels of the buffer.
    Usage: screen.setPixel[<x coord>][<y coord>](pixelData)
    @param x coord number x coordinate
    @param y coord number y coordinate
    @param pixelData table contains background color in
    "backgroundColor" index, text color in "textColor" index,
    and character in "character" index.
--]]
setPixel = setmetatable({}, {
  __index = function(self, key)
    self[key] = setmetatable({}, {
      __index = function(self2, key2)
        self2[key2] = function(pixelData)
          buffer[key][key2] = pixelData
        end
        return self2[key2]
      end;
    })
    return self[key]
  end;
})

--[[
    Used to draw out the buffer to the computer screen, will
    also cache the buffer for next comparison.
--]]
function drawBuffer()
  for x = 1, screenWidth do
    for y = 1, screenHeight do
      if buffer[x][y] ~= cache[x][y] then
        term.setCursorPos(x, y)
        term.setTextColor(buffer[x][y].textColor)
        term.setBackgroundColor(buffer[x][y].backgroundColor)
        term.write(buffer[x][y].character)
        cache[x][y] = buffer[x][y]
      end
    end
  end
end
