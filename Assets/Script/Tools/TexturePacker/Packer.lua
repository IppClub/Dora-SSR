-- [ts]: Packer.ts
local ____exports = {} -- 1
local function CreatePacker() -- 39
	local packer = { -- 40
		fit = function(self, blocks) -- 41
			table.sort( -- 42
				blocks, -- 42
				function(a, b) -- 42
					return math.max(a.w, a.h) > math.max(b.w, b.h) -- 43
				end -- 42
			) -- 42
			local len = #blocks -- 45
			local w = len > 0 and blocks[1].w or 0 -- 46
			local h = len > 0 and blocks[1].h or 0 -- 47
			self.root = {x = 0, y = 0, w = w, h = h} -- 48
			for ____, block in ipairs(blocks) do -- 49
				local node = self:findNode(self.root, block.w, block.h) -- 50
				if node then -- 50
					block.fit = self:splitNode(node, block.w, block.h) -- 52
				else -- 52
					block.fit = self:growNode(block.w, block.h) -- 54
				end -- 54
			end -- 54
		end, -- 41
		findNode = function(self, node, w, h) -- 59
			if node.used then -- 59
				return node.right and self:findNode(node.right, w, h) or node.down and self:findNode(node.down, w, h) -- 61
			elseif w <= node.w and h <= node.h then -- 61
				return node -- 64
			else -- 64
				return nil -- 66
			end -- 66
		end, -- 59
		splitNode = function(self, node, w, h) -- 70
			node.used = true -- 71
			node.down = {x = node.x, y = node.y + h, w = node.w, h = node.h - h} -- 72
			node.right = {x = node.x + w, y = node.y, w = node.w - w, h = h} -- 78
			return node -- 84
		end, -- 70
		growNode = function(self, w, h) -- 87
			if self.root == nil then -- 87
				return nil -- 88
			end -- 88
			local canGrowDown = w <= self.root.w -- 89
			local canGrowRight = h <= self.root.h -- 90
			local shouldGrowRight = canGrowRight and self.root.h >= self.root.w + w -- 91
			local shouldGrowDown = canGrowDown and self.root.w >= self.root.h + h -- 92
			if shouldGrowRight then -- 92
				return self:growRight(w, h) -- 94
			elseif shouldGrowDown then -- 94
				return self:growDown(w, h) -- 96
			elseif canGrowRight then -- 96
				return self:growRight(w, h) -- 98
			elseif canGrowDown then -- 98
				return self:growDown(w, h) -- 100
			else -- 100
				return nil -- 102
			end -- 102
		end, -- 87
		growRight = function(self, w, h) -- 106
			if self.root == nil then -- 106
				return nil -- 107
			end -- 107
			self.root = { -- 108
				used = true, -- 109
				x = 0, -- 110
				y = 0, -- 111
				w = self.root.w + w, -- 112
				h = self.root.h, -- 113
				down = self.root, -- 114
				right = {x = self.root.w, y = 0, w = w, h = self.root.h} -- 115
			} -- 115
			local node = self:findNode(self.root, w, h) -- 122
			if node then -- 122
				return self:splitNode(node, w, h) -- 124
			else -- 124
				return nil -- 126
			end -- 126
		end, -- 106
		growDown = function(self, w, h) -- 130
			if self.root == nil then -- 130
				return nil -- 131
			end -- 131
			self.root = { -- 132
				used = true, -- 133
				x = 0, -- 134
				y = 0, -- 135
				w = self.root.w, -- 136
				h = self.root.h + h, -- 137
				down = {x = 0, y = self.root.h, w = self.root.w, h = h}, -- 138
				right = self.root -- 144
			} -- 144
			local node = self:findNode(self.root, w, h) -- 146
			if node then -- 146
				return self:splitNode(node, w, h) -- 148
			else -- 148
				return nil -- 150
			end -- 150
		end -- 130
	} -- 130
	return packer -- 154
end -- 39
____exports.default = CreatePacker -- 157
return ____exports -- 157