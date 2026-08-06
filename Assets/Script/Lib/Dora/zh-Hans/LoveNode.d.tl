local Sprite = require("Sprite").Type

-- Dora 场景节点，每个实例拥有并运行一个隔离的 Love Lua State。
local record LoveNode
	embed Sprite

	bootFile: string
	sourceRoot: string
	lastError: string
	running: boolean

	-- 销毁旧 Love State，重新读取 boot 文件，并启动一个全新 State。
	restart: function(self: LoveNode): boolean
end

local record LoveNodeClass
	type Type = LoveNode

	-- 使用 boot Lua 文件创建 LoveNode；加载失败时返回 nil。
	metamethod __call: function(self: LoveNodeClass, bootFile: string): LoveNode | nil
end

local loveNodeClass: LoveNodeClass
return loveNodeClass
