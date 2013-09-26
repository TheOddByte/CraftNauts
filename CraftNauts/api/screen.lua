--[[
    Screen API (WIP)
    @version 0.1, 24/9/2013, Sym
    @author Symmetryc, Sym
--]]

--# Variable for containing the screen data
local cache = setmetatable({}, {
  __index = function(self, key)
    self[key] = setmetatable({}, {
      __index = function(self2, key2)
        self2[key2] = setmetatable({}, {
          __index = {
            back = colors.white;
            text = colors.black;
            char = "";
          }
        })
        return self2[key2]
      end;
    })
    return self[key]
  end;
})

--[[
    Function for getting a new buffer object
    Usage: local buffer = screen.new()
    @return    table    buffer object
--]]
function new()
  return {

    --[[
        Function for getting pixel information
        Usage: local back, text, char = buffer:getPixel(x, y)
        @param    x    x coordinate
        @param    y    y coordinate
        @return    back    background color or false if pixel hasn't been set
        @return    text    text color
        @return    char    character
    --]]
    getPixel = function(self, x, y)
      return unpack(self[x] and self[x][y] and {self[x][y].back, self[x][y].color, self[x][y].char} or {false})
    end;

    --[[
        Function for setting pixel information
        Usage: buffer:setPixel(x, y, back, text, char)
        @param    x    x coordinate
        @param    y    y coordinate
        @param    back    background color [optional]
        @param    text    text color [optional]
        @param    char    character [optional]
    --]]
    setPixel = function(self, x, y, back, text, char)
      self[x] = self[x] == nil and {} or self[x]
      self[x][y] = self[x][y] == nil and {} or self[x][y]
      self[x][y].back = back or self[x][y].back or nil
      self[x][y].text = text or self[x][y].text or nil
      self[x][y].char = tostring(char) or self[x][y].char or nil
    end;

    --[[
        Function for drawing a pixel from the buffer to the screen
        Usage: buffer:drawPixel(x, y)
        @param    x    x coordinate
        @param    y    y coordinate
    --]]
    drawPixel = function(self, x, y)
      if(self[x] ~= nil and self[x][y] ~= nil and self[x][y] ~= cache[x][y]) then
        term.setCursorPos(x, y)
        term.setBackgroundColor(self[x][y].back)
        term.setTextColor(self[x][y].text)
        term.write(self[x][y].char)
        cache[x][y] = self[x][y]
      end
    end;
  }
end
