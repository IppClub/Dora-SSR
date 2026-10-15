-- `Shader` 是一个用于在运行时编译 Dora 着色器的单例对象。
-- @usage
-- local Shader = require("Shader")
-- local ok, err = Shader:compile("vs_sprite.sc", "compiled/vs_sprite.bin", "Vertex")
local record Shader
	userdata

	enum StageName
		"Vertex"
		"Fragment"
		"Compute"
	end

	-- 编译着色器源码文件，并将编译后的字节码写入目标文件。
	-- @param sourceFile (string) 着色器源码文件路径。
	-- @param targetFile (string) 编译后着色器字节码的输出文件路径，请使用 `.bin` 后缀。
	-- @param stage (StageName) 着色器阶段名称，只能是 `"Vertex"`、`"Fragment"` 或 `"Compute"`。
	-- @return (boolean) 编译成功时返回 `true`；如果编译失败则返回 `false`。
	-- @return (string | nil) 编译错误信息；如果编译成功则返回 `nil`。
	compile: function(
		self: Shader,
		sourceFile: string,
		targetFile: string,
		stage: StageName
	): boolean, string | nil

	-- 使用引擎内部的着色器队列异步编译着色器源码文件，并将编译后的字节码写入目标文件。
	-- 这个函数应在协程线程中调用。
	-- @param sourceFile (string) 着色器源码文件路径。
	-- @param targetFile (string) 编译后着色器字节码的输出文件路径，请使用 `.bin` 后缀。
	-- @param stage (StageName) 着色器阶段名称，只能是 `"Vertex"`、`"Fragment"` 或 `"Compute"`。
	-- @return (boolean) 编译成功时返回 `true`；如果编译失败则返回 `false`。
	-- @return (string | nil) 编译错误信息；如果编译成功则返回 `nil`。
	compileAsync: function(
		self: Shader,
		sourceFile: string,
		targetFile: string,
		stage: StageName
	): boolean, string | nil
end

return Shader
