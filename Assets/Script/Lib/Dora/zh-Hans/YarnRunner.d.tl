-- 用于加载和执行 Yarn 叙述脚本的类。
local record YarnRunner

	-- 表示执行返回的结果类型的枚举。
	enum ResultType

		-- 表示文本结果。
		"Text"

		-- 表示选择或选项。
		"Option"

		-- 表示错误。
		"Error"

		-- 仅用于特殊的测试模式。
		"Command"
	end

	-- 用于获取 Yarn 脚本的运行状态变量的属性
	const state: {string: string | number | boolean}

	-- 用于创建 Yarn 脚本运行器的元方法。
	-- @param filename (string) 要加载和执行的 Yarn 文件的名称。
	-- @param startTitle (string) Yarn 脚本中的起始节点/标题。
	-- @param state (table) [可选] 用于提供预定义变量的表格。
	-- @param command ({string: function}) [可选] 包含可以执行命令的Lua表。
	-- @param testing (boolean) [可选] 用于测试模式的布尔标志。当处于测试模式时，将加载Web IDE的测试变量。默认为`false`。
	-- @return (YarnRunner) 返回 YarnRunner 对象。
	metamethod __call: function(
		self: YarnRunner,
		filename: string,
		startTitle: string,
		state?: {string: string | number | boolean}, --[[{}]]
		command?: {string: function}, --[[{}]]
		testing?: boolean --[[false]]
	): YarnRunner

	-- 定义标记属性的类。
	record Markup

		-- 标记的名称。
		name: string

		-- 标记的起始位置。
		start: integer

		-- 标记的结束位置。
		stop: integer

		-- 与标记相关的属性。
		attrs: {string: boolean | number | string} | nil
	end

	-- 定义带有可选标记的文本结果的类。
	record TextResult

		-- 文本内容。
		text: string

		-- 文本的可选标记。
		marks: nil | {Markup}

		-- 表示下一个叙事推进得到的结果将为选项的标志。
		optionsFollowed: nil | boolean
	end

	-- 在叙述中定义选项的记录。
	record OptionResult

		-- 当选项为可选状态时为 TextResult，当选项被隐藏时为布尔值 false。
		{TextResult | boolean}
	end

	-- 执行并推进叙述脚本的方法。
	-- @param choice (integer) [可选] 如果提供了选项，则为选项的索引。
	-- @return (nil | ResultType) 如果叙述结束则返回 nil。当 YarnRunner 仍在运行时返回 ResultType 枚举字符串结果。
	-- @return (string | table) 根据叙述执行的情况，会返回一个和执行结果相关的内容：
	-- 执行结果为 "Text" 时，得到 TextResult 对象
	-- 执行结果为 "Option" 时，得到 OptionResult 对象
	-- 执行结果为 "Error" 时，得到一个字符串错误消息。
	-- 执行结果为 nil 时，得到一个表示叙述结束的字符串。
	advance: function(self: YarnRunner, choice?: integer): nil | ResultType, string | table
end

return YarnRunner
