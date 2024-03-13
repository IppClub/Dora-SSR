-- [yue]: Script/Lib/UI/Control/Basic/AlignNode.yue
local Class = dora.Class -- 1
local Node = dora.Node -- 1
local Vec2 = dora.Vec2 -- 1
local App = dora.App -- 1
local View = dora.View -- 1
local load = _G.load -- 1
local tostring = _G.tostring -- 1
local _module_0 = nil -- 1
_module_0 = Class(Node, { -- 4
	__init = function(self, args) -- 4
		local isRoot, inUI, hAlign, vAlign, alignOffset, alignWidth, alignHeight -- 5
		do -- 5
			local _obj_0 = args or { } -- 13
			isRoot, inUI, hAlign, vAlign, alignOffset, alignWidth, alignHeight = _obj_0.isRoot, _obj_0.inUI, _obj_0.hAlign, _obj_0.vAlign, _obj_0.alignOffset, _obj_0.alignWidth, _obj_0.alignHeight -- 5
			if isRoot == nil then -- 6
				isRoot = false -- 6
			end -- 6
			if inUI == nil then -- 7
				inUI = true -- 7
			end -- 7
			if hAlign == nil then -- 8
				hAlign = "Center" -- 8
			end -- 8
			if vAlign == nil then -- 9
				vAlign = "Center" -- 9
			end -- 9
			if alignOffset == nil then -- 10
				alignOffset = Vec2.zero -- 10
			end -- 10
		end -- 13
		self.inUI = inUI -- 14
		self._isRoot = isRoot -- 15
		if self._isRoot then -- 16
			local viewSize = inUI and App.bufferSize or View.size -- 17
			self.size = viewSize -- 18
			self._viewSize = viewSize -- 19
			self:gslot("AppSizeChanged", function() -- 20
				viewSize = self.inUI and App.bufferSize or View.size -- 21
				if self._viewSize ~= viewSize then -- 22
					self._viewSize = viewSize -- 23
					self.size = viewSize -- 24
					local width, height = viewSize.width, viewSize.height -- 25
					self:emit("AlignLayout", width, height) -- 26
					return self:eachChild(function(child) -- 27
						return child:emit("AlignLayout", width, height) -- 28
					end) -- 28
				end -- 22
			end) -- 20
			return self:slot("Enter", function() -- 29
				local width, height -- 30
				do -- 30
					local _obj_0 = self.inUI and App.bufferSize or View.size -- 30
					width, height = _obj_0.width, _obj_0.height -- 30
				end -- 30
				self:emit("AlignLayout", width, height) -- 31
				return self:eachChild(function(child) -- 32
					return child:emit("AlignLayout", width, height) -- 33
				end) -- 33
			end) -- 33
		else -- 35
			self.hAlign = hAlign -- 35
			self.vAlign = vAlign -- 36
			self.alignOffset = alignOffset -- 37
			self.alignWidth = alignWidth -- 38
			self.alignHeight = alignHeight -- 39
			return self:slot("AlignLayout", function(w, h) -- 40
				local env = { -- 41
					w = w, -- 41
					h = h -- 41
				} -- 41
				local oldSize = self.size -- 42
				if self.alignWidth then -- 43
					local widthFunc = load("local _ENV = " .. "Dora(...)\nreturn " .. tostring(self.alignWidth)) -- 44
					self.width = widthFunc(env) -- 45
				end -- 43
				if self.alignHeight then -- 46
					local heightFunc = load("local _ENV = " .. "Dora(...)\nreturn " .. tostring(self.alignHeight)) -- 47
					self.height = heightFunc(env) -- 48
				end -- 46
				do -- 49
					local _exp_0 = self.hAlign -- 49
					if "Left" == _exp_0 then -- 50
						self.x = self.width / 2 + self.alignOffset.x -- 50
					elseif "Center" == _exp_0 then -- 51
						self.x = w / 2 + self.alignOffset.x -- 51
					elseif "Right" == _exp_0 then -- 52
						self.x = w - self.width / 2 - self.alignOffset.x -- 52
					end -- 52
				end -- 52
				do -- 53
					local _exp_0 = self.vAlign -- 53
					if "Bottom" == _exp_0 then -- 54
						self.y = self.height / 2 + self.alignOffset.y -- 54
					elseif "Center" == _exp_0 then -- 55
						self.y = h / 2 + self.alignOffset.y -- 55
					elseif "Top" == _exp_0 then -- 56
						self.y = h - self.height / 2 - self.alignOffset.y -- 56
					end -- 56
				end -- 56
				local newSize = self.size -- 57
				if oldSize ~= newSize then -- 58
					local width, height = newSize.width, newSize.height -- 59
					return self:eachChild(function(child) -- 60
						return child:emit("AlignLayout", width, height) -- 61
					end) -- 61
				end -- 58
			end) -- 61
		end -- 16
	end, -- 4
	alignLayout = function(self) -- 63
		if self._isRoot then -- 64
			local width, height -- 65
			do -- 65
				local _obj_0 = self.inUI and App.bufferSize or View.size -- 65
				width, height = _obj_0.width, _obj_0.height -- 65
			end -- 65
			self:emit("AlignLayout", width, height) -- 66
			return self:eachChild(function(child) -- 67
				return child:emit("AlignLayout", width, height) -- 68
			end) -- 68
		else -- 70
			local width, height -- 70
			do -- 70
				local _obj_0 = self.size -- 70
				width, height = _obj_0.width, _obj_0.height -- 70
			end -- 70
			return self:eachChild(function(child) -- 71
				return child:emit("AlignLayout", width, height) -- 72
			end) -- 72
		end -- 64
	end -- 63
}) -- 3
return _module_0 -- 72
