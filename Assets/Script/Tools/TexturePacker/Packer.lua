-- [ts]: Packer.ts
local ____exports = {} -- 1
local function CreatePacker() -- 31
    local packer = { -- 32
        fit = function(self, blocks) -- 33
            table.sort( -- 34
                blocks, -- 34
                function(a, b) -- 34
                    return math.max(a.w, a.h) > math.max(b.w, b.h) -- 35
                end -- 34
            ) -- 34
            local len = #blocks -- 37
            local w = len > 0 and blocks[1].w or 0 -- 38
            local h = len > 0 and blocks[1].h or 0 -- 39
            self.root = {x = 0, y = 0, w = w, h = h} -- 40
            for ____, block in ipairs(blocks) do -- 41
                local node = self:findNode(self.root, block.w, block.h) -- 42
                if node then -- 42
                    block.fit = self:splitNode(node, block.w, block.h) -- 44
                else -- 44
                    block.fit = self:growNode(block.w, block.h) -- 46
                end -- 46
            end -- 46
        end, -- 33
        findNode = function(self, node, w, h) -- 51
            if node.used then -- 51
                return node.right and self:findNode(node.right, w, h) or node.down and self:findNode(node.down, w, h) -- 53
            elseif w <= node.w and h <= node.h then -- 53
                return node -- 56
            else -- 56
                return nil -- 58
            end -- 58
        end, -- 51
        splitNode = function(self, node, w, h) -- 62
            node.used = true -- 63
            node.down = {x = node.x, y = node.y + h, w = node.w, h = node.h - h} -- 64
            node.right = {x = node.x + w, y = node.y, w = node.w - w, h = h} -- 70
            return node -- 76
        end, -- 62
        growNode = function(self, w, h) -- 79
            if self.root == nil then -- 79
                return nil -- 80
            end -- 80
            local canGrowDown = w <= self.root.w -- 81
            local canGrowRight = h <= self.root.h -- 82
            local shouldGrowRight = canGrowRight and self.root.h >= self.root.w + w -- 83
            local shouldGrowDown = canGrowDown and self.root.w >= self.root.h + h -- 84
            if shouldGrowRight then -- 84
                return self:growRight(w, h) -- 86
            elseif shouldGrowDown then -- 86
                return self:growDown(w, h) -- 88
            elseif canGrowRight then -- 88
                return self:growRight(w, h) -- 90
            elseif canGrowDown then -- 90
                return self:growDown(w, h) -- 92
            else -- 92
                return nil -- 94
            end -- 94
        end, -- 79
        growRight = function(self, w, h) -- 98
            if self.root == nil then -- 98
                return nil -- 99
            end -- 99
            self.root = { -- 100
                used = true, -- 101
                x = 0, -- 102
                y = 0, -- 103
                w = self.root.w + w, -- 104
                h = self.root.h, -- 105
                down = self.root, -- 106
                right = {x = self.root.w, y = 0, w = w, h = self.root.h} -- 107
            } -- 107
            local node = self:findNode(self.root, w, h) -- 114
            if node then -- 114
                return self:splitNode(node, w, h) -- 116
            else -- 116
                return nil -- 118
            end -- 118
        end, -- 98
        growDown = function(self, w, h) -- 122
            if self.root == nil then -- 122
                return nil -- 123
            end -- 123
            self.root = { -- 124
                used = true, -- 125
                x = 0, -- 126
                y = 0, -- 127
                w = self.root.w, -- 128
                h = self.root.h + h, -- 129
                down = {x = 0, y = self.root.h, w = self.root.w, h = h}, -- 130
                right = self.root -- 136
            } -- 136
            local node = self:findNode(self.root, w, h) -- 138
            if node then -- 138
                return self:splitNode(node, w, h) -- 140
            else -- 140
                return nil -- 142
            end -- 142
        end -- 122
    } -- 122
    return packer -- 146
end -- 31
____exports.default = CreatePacker -- 149
return ____exports -- 149