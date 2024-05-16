-- [yue]: Script/Lib/UI/Control/Basic/AlignNode.yue
local Class = Dora.Class -- 1
local Node = Dora.Node -- 1
local Vec2 = Dora.Vec2 -- 1
local App = Dora.App -- 1
local View = Dora.View -- 1
local load = _G.load -- 1
local tostring = _G.tostring -- 1
local _module_0 = nil -- 1
_module_0 = Class(Node, { -- 12
	__init = function(self, args) -- 12
		local isRoot, inUI, hAlign, vAlign, alignOffset, alignWidth, alignHeight -- 13
		do -- 13
			local _obj_0 = args or { } -- 21
			isRoot, inUI, hAlign, vAlign, alignOffset, alignWidth, alignHeight = _obj_0.isRoot, _obj_0.inUI, _obj_0.hAlign, _obj_0.vAlign, _obj_0.alignOffset, _obj_0.alignWidth, _obj_0.alignHeight -- 13
			if isRoot == nil then -- 14
				isRoot = false -- 14
			end -- 14
			if inUI == nil then -- 15
				inUI = true -- 15
			end -- 15
			if hAlign == nil then -- 16
				hAlign = "Center" -- 16
			end -- 16
			if vAlign == nil then -- 17
				vAlign = "Center" -- 17
			end -- 17
			if alignOffset == nil then -- 18
				alignOffset = Vec2.zero -- 18
			end -- 18
		end -- 21
		self.inUI = inUI -- 22
		self._isRoot = isRoot -- 23
		if self._isRoot then -- 24
			local viewSize = inUI and App.bufferSize or View.size -- 25
			self.size = viewSize -- 26
			self._viewSize = viewSize -- 27
			self:gslot("AppSizeChanged", function() -- 28
				viewSize = self.inUI and App.bufferSize or View.size -- 29
				if self._viewSize ~= viewSize then -- 30
					self._viewSize = viewSize -- 31
					self.size = viewSize -- 32
					local width, height = viewSize.width, viewSize.height -- 33
					self:emit("AlignLayout", width, height) -- 34
					return self:eachChild(function(child) -- 35
						return child:emit("AlignLayout", width, height) -- 36
					end) -- 36
				end -- 30
			end) -- 28
			return self:slot("Enter", function() -- 37
				local width, height -- 38
				do -- 38
					local _obj_0 = self.inUI and App.bufferSize or View.size -- 38
					width, height = _obj_0.width, _obj_0.height -- 38
				end -- 38
				self:emit("AlignLayout", width, height) -- 39
				return self:eachChild(function(child) -- 40
					return child:emit("AlignLayout", width, height) -- 41
				end) -- 41
			end) -- 41
		else -- 43
			self.hAlign = hAlign -- 43
			self.vAlign = vAlign -- 44
			self.alignOffset = alignOffset -- 45
			self.alignWidth = alignWidth -- 46
			self.alignHeight = alignHeight -- 47
			return self:slot("AlignLayout", function(w, h) -- 48
				local env = { -- 49
					w = w, -- 49
					h = h -- 49
				} -- 49
				local oldSize = self.size -- 50
				if self.alignWidth then -- 51
					local widthFunc = load("local _ENV = " .. "Dora(...)\nreturn " .. tostring(self.alignWidth)) -- 52
					self.width = widthFunc(env) -- 53
				end -- 51
				if self.alignHeight then -- 54
					local heightFunc = load("local _ENV = " .. "Dora(...)\nreturn " .. tostring(self.alignHeight)) -- 55
					self.height = heightFunc(env) -- 56
				end -- 54
				do -- 57
					local _exp_0 = self.hAlign -- 57
					if "Left" == _exp_0 then -- 58
						self.x = self.width / 2 + self.alignOffset.x -- 58
					elseif "Center" == _exp_0 then -- 59
						self.x = w / 2 + self.alignOffset.x -- 59
					elseif "Right" == _exp_0 then -- 60
						self.x = w - self.width / 2 - self.alignOffset.x -- 60
					end -- 60
				end -- 60
				do -- 61
					local _exp_0 = self.vAlign -- 61
					if "Bottom" == _exp_0 then -- 62
						self.y = self.height / 2 + self.alignOffset.y -- 62
					elseif "Center" == _exp_0 then -- 63
						self.y = h / 2 + self.alignOffset.y -- 63
					elseif "Top" == _exp_0 then -- 64
						self.y = h - self.height / 2 - self.alignOffset.y -- 64
					end -- 64
				end -- 64
				local newSize = self.size -- 65
				if oldSize ~= newSize then -- 66
					local width, height = newSize.width, newSize.height -- 67
					return self:eachChild(function(child) -- 68
						return child:emit("AlignLayout", width, height) -- 69
					end) -- 69
				end -- 66
			end) -- 69
		end -- 24
	end, -- 12
	alignLayout = function(self) -- 71
		if self._isRoot then -- 72
			local width, height -- 73
			do -- 73
				local _obj_0 = self.inUI and App.bufferSize or View.size -- 73
				width, height = _obj_0.width, _obj_0.height -- 73
			end -- 73
			self:emit("AlignLayout", width, height) -- 74
			return self:eachChild(function(child) -- 75
				return child:emit("AlignLayout", width, height) -- 76
			end) -- 76
		else -- 78
			local width, height -- 78
			do -- 78
				local _obj_0 = self.size -- 78
				width, height = _obj_0.width, _obj_0.height -- 78
			end -- 78
			return self:eachChild(function(child) -- 79
				return child:emit("AlignLayout", width, height) -- 80
			end) -- 80
		end -- 72
	end -- 71
}) -- 11
return _module_0 -- 80
