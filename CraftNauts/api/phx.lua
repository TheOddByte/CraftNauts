
function createMatrix(...)
		local mt = {
		__tostring = function(t)
			return "matrix"
		end,
		__pow = function(mat1, mat2)
			if tostring(mat1) == "matrix" and type(mat2) == "number" then
				for i=1,mat2 do
					local NIL_VAL = mat1*mat1
				end
			else
				error("I'm not powering matrices.")
			end
		end,
		__sub = function(mat1, mat2)
			if tostring(mat1) == "matrix" and tostring(mat2) == "matrix" then
				if #mat1.pos == #mat2.pos and mat1.h == mat2.h then
					for i=1,#mat1.pos do
						local p1 = mat1.pos[i]
						local p2 = mat2.pos[i]
						for j=1,#p1 do
							p1[j] = p1[j] - p2[j]
						end
					end
				else
					error("simplify your own matrices... :<")
				end
			elseif tostring(mat1) == "matrix" or tostring(mat2) == "matrix" then
				local mat = mat1
				local n = mat2
				if tostring(mat2) == "matrix" then 
					mat = mat2 
					n = mat1
				end
				n = tonumber(n)
				if type(n) == "number" and tostring(mat) == "matrix" then
					mat:mathfunc(n, "-")
				end
			else
				error("invalid matrix subtraction?")
			end
		end,
		__add = function(mat1, mat2)
			if tostring(mat1) == "matrix" and tostring(mat2) == "matrix" then
				if #mat1.pos == #mat2.pos and mat1.h == mat2.h then
					for i=1,#mat1.pos do
						local p1 = mat1.pos[i]
						local p2 = mat2.pos[i]
						for j=1,#p1 do
							p1[j] = p1[j] + p2[j]
						end
					end
				else
					error("simplify your own matrices... :<")
				end
			elseif tostring(mat1) == "matrix" or tostring(mat2) == "matrix" then
				local mat = mat1
				local n = mat2
				if tostring(mat2) == "matrix" then 
					mat = mat2 
					n = mat1
				end
				n = tonumber(n)
				if type(n) == "number" and tostring(mat) == "matrix" then
					mat:mathfunc(n, "+")
				end
			else
				error("invalid matrix addition?")
			end
		end,
		__mul = function(mat1, mat2)
			if tostring(mat1) == "matrix" and tostring(mat2) == "matrix" then
				mat1.mult(mat1, mat2)
			elseif tostring(mat1) == "matrix" or tostring(mat2) == "matrix" then
				local mat = mat1
				local n = mat2
				if tostring(mat2) == "matrix" then 
					mat = mat2 
					n = mat1
				end
				n = tonumber(n)
				if type(n) == "number" and tostring(mat) == "matrix" then
					mat:mathfunc(n, "*")
				end
			else
				error("invalid matrix multiplication?")
			end
		end
	}
	local args = {...}
	local pos = {}
	local centre = args[#args]
	for i=1,#args-1,2 do
		pos[#pos + 1] = {centre[1]-args[i], centre[2]-args[i+1]}
	end
	local matrix = {
		pos = pos,
		h = 2,
		centre = centre,
		moveCentre = function(self, x, y)
			self.centre = {self.centre[1]+x, self.centre[2]+y}
		end,
		mathfunc = function(self, m, symbol)
			for i=1,#self.pos do
				local p = self.pos[i]
				for j=1,#p do
					p[j] = loadstring("return "..p[j]..symbol..m.."")()
				end
			end
		end,
		mult = function(mat1, mat2)
			if mat1.h == mat2.h and mat1.h == 2 then
				for i=1,#mat1.pos do
					local spos = mat1.pos[i] -- is the sub table {x, y} in matrix.pos { {x1, y1}, {x2, y2} ... {xn, yn} }
					if #spos == 2 then
						local mpos = mat2.pos[1]
						if #mat2.pos == 2 then
							local npos = {}
							npos[1] = (spos[1] * mpos[3]) + (spos[2] * mpos[4])
							npos[2] = (spos[1] * mpos[1]) + (spos[2] * mpos[2])
							mat1.pos[i] = npos
						elseif #mat2.pos == 1 then
							spos[1] = spos[1] * mpos[1]
							spos[2] = spos[2] * mpos[2]
						else
							error("Matrix sizes have to be consistent of 1 or 2 positions, sorry :S")
						end
					end
				end
			end
		end,
		getPos = function(self, i)
			local pos = self.pos[i]
			return pos[1]+self.centre[1], pos[2]+self.centre[2]
		end,
		getData = function(self)
			local dat = ""
			for i=1,#self.pos do
				local pos = self.pos[i]
				if i ~= 1 then dat = dat..", " end
				dat = dat.."["
				for j=1,#pos do
					if type(pos[j]) == "number" then
						if j == 1 then dat = dat..pos[j] else
							dat = dat..","..pos[j]
						end
					end
				end
				dat = dat.."]"
			end
			return dat..", {"..self.centre[1]..","..self.centre[2].."}"
		end,
		getTrueData = function(self)
			local dat = ""
			for i=1,#self.pos do
				local pos = {self:getPos(i)}
				if i ~= 1 then dat = dat..", " end
				dat = dat.."["
				for j=1,#pos do
					if type(pos[j]) == "number" then
						if j == 1 then dat = dat..pos[j] else
							dat = dat..","..pos[j]
						end
					end
				end
				dat = dat.."]"
			end
			return dat..", {"..self.centre[1]..","..self.centre[2].."}"
		end
	}
	setmetatable(matrix, mt)
	return matrix
end

function createPosition(x1, y1, x2, y2, centre)
	local pos = {
		matrix = createMatrix(x1, y1, x2, y2, centre),
		move = function(self, x, y)
			self.matrix:moveCentre(-x, -y)
		end,
		rotate = function(self, ang)
			--ang = math.deg(ang)
			local rotMat = createMatrix(1, 1, {0,0})
			rotMat.pos = { {math.cos(ang), math.sin(ang), -math.sin(ang), math.cos(ang)} }
			rotMat.h = 2
			local NIL_VAL = self.matrix * rotMat
		end,
		scale = function(self, scale)
			scale = scale
			local opos = { {self.matrix.pos[1][1], self.matrix.pos[1][2]}, {self.matrix.pos[2][1], self.matrix.pos[2][2]} }
			local NIL_VAL = self.matrix * scale
			--[[print("pre-scale-move:"..tostring(self))
			local dif = {opos[1][1]-self.matrix.pos[1][1]+1, opos[1][2]-self.matrix.pos[1][2]+1}
			print("dif:"..dif[1]..","..dif[2])
			local p1 = self.matrix.pos[1]
			local p2 = self.matrix.pos[2]
			self.matrix.pos[1] = {p1[1]+dif[1], p1[2]+dif[2]}
			self.matrix.pos[2] = {p2[1]+dif[1], p2[2]+dif[2]}]]
		end,
		getVector = function(self)
			local p1 = {self.matrix:getPos(1)}
			local p2 = {self.matrix:getPos(2)}
			return { {p1[1], p1[2]}, {p2[1], p2[2]} }
		end
	}
	local mt = {
		__tostring = function(t)
			local mat = t.matrix
			return mat:getTrueData()
		end,
	}
	setmetatable(pos, mt)
	return pos
end

function createLine(x1, y1, x2, y2)
	local grad = math.abs(y1-y2)/math.abs(x1-x2)
	local c = y1 - (grad*x1)
	return {
		from = {x1, y1},
		to = {x2, y2},
		grad = grad,
		c = c,
		intersectsLine = function(self, line)
			local g = self.grad-line.grad
			local c = line.c-self.c
			local x = c/g
			local y = (self.grad*x) + self.c
			if x >= math.min(self.from[1], self.to[1]) and x <= math.max(self.from[1], self.to[1]) and y >= math.min(self.from[2], self.to[2]) and y <= math.max(self.from[2], self.to[2]) then
				return true
			end
			return false
		end
	}
end

function createPLine(p1, p2) return createLine(p1[1], p1[2], p2[1], p2[2]) end

function createForce(x, y, force, resist)
	return {
		force = force,
		x = x,
		y = y,
		resist = resist,
		getDirection = function(self)
			return {self.x*math.ceil(self.force), math.y*math.ceil(self.force)}
		end,
		update = function(self)
			self.force = self.force - self.resist
		end,
		addForce = function(self, force)
			self.force = self.force + force
		end
	}
end

PHX_RESISTANCE_CONSTANT = 0.24
function createPhxProfile(x, y, width, height)
	local pos = createPostition(x, y, width+x-1, height+y-1, {math.floor(x+(width/2)), math.floor(y+(height/2))})
	local momentum = {
		getForce = function(self, dirX, dirY)
			if self[dirX] ~= nil then
				return self[dirX][dirY]
			end
		end,
		addForce = function(self, dirX, dirY, force)
			local f = self:getForce(dirX, dirY)
			if f ~= nil then
				f:addForce(force)
			end
		end,
		update = function(self)
			for dirX,v in pairs(self) do
				if type(v) == "table" then
					for dirY,f in pairs(v) do
						f:update()
					end
				end
			end
		end,
		getDirection = function(self)
			local dir = {0, 0}
			for dirX,v in pairs(self) do
				if type(v) == "table" then
					for dirY,f in pairs(v) do
						local d = f:getDirection()
						dir = {dir[1] + d[1], dir[2] + d[2]}
					end
				end
			end
		end
	}
	for i=-1,1,2 do
		momentum[i] = {}
		momentum[i][0] = createForce(1, 0, force, PHX_RESISTANCE_CONSTANT)
		momentum[0] = {}
		momentum[0][i] = createForce(0, i, force, PHX_RESISTANCE_CONSTANT)
	end
	momentum[0][1].resist = 0
	
	return {
		pos = pos,
		momentum = momentum,
		getLines = function(self)
			local vect = self.pos:getVector()
			local p1 = vect[1]
			local p2 = vect[2]
			local corners = {
				{math.min(p1[1], p2[1]), math.min(p1[2], p2[2])},
				{math.min(p1[1], p2[1]), math.max(p1[2], p2[2])},
				{math.max(p1[1], p2[1]), math.max(p1[2], p2[2])},
				{math.max(p1[1], p2[1]), math.min(p1[2], p2[2])},
			}
			local lines = {}
			for i=1,#corners do
				local p2 = corners[i+1]
				if i == #corners then p2 = corners[1] end
				lines[#lines + 1] = createPLine(corners[i], p2)
			end
		end
	}
end

function plotVector(vect, color)
	for i=1,#vect do
		local p = vect[i]
		term.setCursorPos(math.floor(p[1]+10), math.floor(p[2]+10))
		term.setBackgroundColour(color)
		term.write(" ")
	end
end



--[[
	Physics handling component, these are the functions use to detect collision etc.
		General rules;	
			"prof" stands for "profile" as in Phx Profile, usually followed by a number representative of which number profile it is for that function
]]

function detectCollision(prof1, prof2)
	local lines1 = prof1:getLines()
	local lines2 = prof2:getLines()
	for i=1,#lines1 do
		local l1 = lines1[i]
		for j=1,#lines2 do
			local l2 = lines2[j]
			if l1:intersectsLine(l2) then return true end
		end
	end
	return false
end	
