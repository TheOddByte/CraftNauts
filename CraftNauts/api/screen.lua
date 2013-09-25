--[[
    Screen API (WIP)
    @version 0.1, 24/9/2013, Sym
    @author Symmetryc, Sym
--]]

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

function new()
  return {
    getPixel = function(self, x, y)
      return self[x] ~= nil and self[x][y] ~= nil and self[x][y] or false
    end;
    setPixel = function(self, x, y, back, text, char)
      self[x] = self[x] == nil and {} or self[x]
      self[x][y].back = back or self[x][y].back
      self[x][y].text = text or self[x][y].text
      self[x][y].char = char or self[x][y].char
    end;
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
