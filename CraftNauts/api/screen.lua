--[[
Buffer the screen.
Draw the screen.
Communicate with Map API
]]

-- I've got a thing I've been working on, how does it look? It's a lot more than just a screen buffer; it's got a whole object system built in :P and it's no where near complete. -Symmetryc (AKA JayJuly)
cache = setmetatable(
	{
	},
	{
		__index = function(self, key)
			self[key] = setmetatable({}, {
				__index = function(self2, key2)
					self2[key2] = {}
					return self2[key2]
				end;
			})
			return self[key]
		end;
	}
)
_G.termraw = _G.term
-- alter term
class = function()
	return setmetatable(
		{
			_ = {
				func = {
					__call = function(t, ...)
						return t.draw(t.render(unpack(arg[1])), unpack(arg[2]))
					end;
					render = function(t, ...) -- render all arg
					end;
					draw = function(t, ...)
					end;
				};
				buffer = setmetatable(
					{
					},
					{
						__index = function(self, key)
							self[key] = setmetatable({}, {
								__index = function(self2, key2)
									self2[key2] = {}
									return self2[key2]
								end;
							})
							return self[key]
						end;
					}
				);
				obj = {
					_ = {
						func = {};
						pos = {0, 0, 0};
					};
				};
				x = {1, ({term.getSize()})[1], 0};
				y = {1, ({term.getSize()})[2], 0};
				z = {1, 8, 0};
			};
		},
		{
			__index = function(self, key)
				self[key] = setmetatable(self._.obj, {
					__index = function(self2, key2)
						self2[key2] = setmetatable({}, {
							__index = function(self3, key3)
								self3[key3] = setmetatable({}, {
									__index = function(self4, key4)
										self4[key4] = setmetatable({}, {
											__index = function(self5, key5)
												self5[key5] = {}
												return self5[key5]
											end;
										})
										return self4[key4]
									end;
								})
								return self3[key3]
							end;
							__call = function(self3, ...)
								return self2._.func[key2](self2, unpack(arg))
							end;
						})
						return self2[key2]
					end;
					__call = function(self2, ...)
						return self._.func[key](self, unpack(arg))
					end;
				})
				return self[key]
			end;
			__call = function(self, ...)
				return self._.func.__call(self, unpack(arg))
			end;
		}
	)
end
