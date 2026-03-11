-- The `Shader` record is a singleton object used to compile Dora shaders at runtime.
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

	-- Compiles a shader source file and writes the compiled bytecode to the target file.
	-- @param sourceFile (string) Shader source file path.
	-- @param targetFile (string) Output file path for the compiled shader bytecode. Use the `.bin` suffix.
	-- @param stage (StageName) Shader stage name. One of `"Vertex"`, `"Fragment"` or `"Compute"`.
	-- @return (boolean) `true` if compilation succeeded, or `false` if compilation failed.
	-- @return (string | nil) The compilation error message, or `nil` if compilation succeeded.
	compile: function(
		self: Shader,
		sourceFile: string,
		targetFile: string,
		stage: StageName
	): boolean, string | nil

	-- Compiles a shader source file asynchronously and writes the compiled bytecode to the target file.
	-- This method should be run in a coroutine thread.
	-- @param sourceFile (string) Shader source file path.
	-- @param targetFile (string) Output file path for the compiled shader bytecode. Use the `.bin` suffix.
	-- @param stage (StageName) Shader stage name. One of `"Vertex"`, `"Fragment"` or `"Compute"`.
	-- @return (boolean) `true` if compilation succeeded, or `false` if compilation failed.
	-- @return (string | nil) The compilation error message, or `nil` if compilation succeeded.
	compileAsync: function(
		self: Shader,
		sourceFile: string,
		targetFile: string,
		stage: StageName
	): boolean, string | nil
end

return Shader
