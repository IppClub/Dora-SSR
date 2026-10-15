local Sprite = require("Sprite").Type

-- Dora 场景节点，每个实例拥有并运行一个隔离的 Love Lua State。
local record LoveNode
	-- 继承自 `Sprite`。
	embed Sprite

	-- 创建该 LoveNode 时使用的启动文件或项目包路径。
	bootFile: string

	-- 解析该 LoveNode 项目文件时使用的根目录。
	sourceRoot: string

	-- 加载或运行 Love 项目时最近一次报告的错误；空字符串表示尚未报告错误。
	lastError: string

	-- 该 LoveNode 当前是否持有正在运行的 Love Lua State。
	running: boolean

	-- 销毁旧 Love State，重新读取 boot 文件，并启动一个全新 State。
	-- @return (boolean) Love 项目是否成功重新启动。
	restart: function(self: LoveNode): boolean
end

-- 用于创建 LoveNode 对象的类。
local record LoveNodeClass
	type Type = LoveNode

	-- 使用启动 Lua 文件、`.love` 包或 ZIP 包创建 LoveNode。不带扩展名的相对路径也会解析到对应的 `.love`、`.zip` 或 `main.lua` 项目入口。
	-- @param bootFile (string) 启动 Lua 文件、`.love` 包、ZIP 包或不带扩展名的 Love 项目在 Dora Content 中的路径。
	-- @return (LoveNode | nil) 创建的 LoveNode；项目无法加载时返回 nil。
	metamethod __call: function(self: LoveNodeClass, bootFile: string): LoveNode | nil
end

local loveNodeClass: LoveNodeClass
return loveNodeClass
