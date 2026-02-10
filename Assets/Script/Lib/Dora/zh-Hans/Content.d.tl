-- 用于管理资源文件的搜索、加载和执行其它与资源文件相关的操作的单例类。
-- @usage
-- local Content = require("Content")
-- local text = Content:load("filename.txt")
local record Content
	userdata

	-- 用于搜索资源文件的文件路径列表。
	searchPaths: {string}

	-- 游戏引擎只读资源所在目录的路径。只有在平台 Windows、MacOS 和 Linux 上能被设置为新路径。
	assetPath: string

	-- 游戏引擎可以做写入操作的文件路径。只有在平台 Windows、MacOS 和 Linux 上能被设置为新路径。默认与 `appPath` 相同。
	writablePath: string

	-- 游戏引擎应用程序存储目录的路径。
	appPath: string

	-- 以阻塞的方式读取文件内容。
	-- @param filename (string) 要读取的文件名。
	-- @return (string) 读取的文件内容。
	load: function(self: Content, filename: string): string

	-- 以阻塞的方式按表名读取 Excel 文件的内容。
	-- @param filename (string) 要读取的 Excel 文件名。
	-- @param sheetNames ({string}) [可选] 要读取的Excel表名的字符串列表。如果不提供，则默认会读取所有表。
	-- @return (table) 包含 Excel 文件数据的Lua表。Lua表的键是表名，值是包含Excel表的行列数据的表。如果读取失败则返回nil。
	loadExcel: function(self: Content, filename: string, sheetNames?: {string}):
		{
			--[[表名]] string:
			--[[行]] {
				--[[列]] {string | number}
			}
		} | nil

	-- 保存文本内容到指定文件名的文件中。
	-- @param filename (string) 要保存到的文件名。
	-- @param content (string) 要保存到文件中的内容。
	-- @return (boolean) 如果文件保存成功，则为 `true`，否则为 `false`。
	save: function(self: Content, filename: string, content: string): boolean

	-- 检查是否存在指定文件名的文件。
	-- @param filename (string) 要检查的文件名。
	-- @return (boolean) 如果文件存在，则为 `true`，否则为 `false`。
	exist: function(self: Content, filename: string): boolean

	-- 创建具有指定路径的新目录。
	-- @param path (string) 要创建的目录的路径。
	-- @return (boolean) 如果创建了目录，则为 `true`，否则为 `false`。
	mkdir: function(self: Content, path: string): boolean

	-- 检查指定路径是否为目录。
	-- @param path (string) 要检查的路径。
	-- @return (boolean) 如果路径为目录，则为 `true`，否则为 `false`。
	isdir: function(self: Content, path: string): boolean

	-- 删除指定路径的文件或目录。
	-- @param path (string) 要删除的文件或目录的路径。
	-- @return (boolean) 如果删除了文件或目录，则为 `true`，否则为 `false`。
	remove: function(self: Content, path: string): boolean

	-- 复制指定路径下的单个文件或目录下的所有文件到目标路径。
	-- @param srcPath (string) 要复制的文件或目录的路径。
	-- @param dstPath (string) 复制文件到的目标路径。
	-- @return (boolean) 如果成功复制了文件或目录，则为 `true`，否则为 `false`。
	copy: function(self: Content, srcPath: string, dstPath: string): boolean

	-- 移动指定路径下的单个文件或目录到目标路径。
	-- @param srcPath (string) 要移动的文件或目录的路径。
	-- @param dstPath (string) 移动文件或目录到的目标路径。
	-- @return (boolean) 如果成功移动了文件或目录，则为 `true`，否则为 `false`。
	move: function(self: Content, srcPath: string, dstPath: string): boolean

	-- 检查指定路径是否为绝对路径。
	-- @param path (string) 要检查的路径。
	-- @return (boolean) 如果路径为绝对路径，则为 `true`，否则为 `false`。
	isAbsolutePath: function(self: Content, path: string): boolean

	-- 获取指定文件名的文件的完整路径。
	-- @param filename (string) 要获取完整路径的文件名。
	-- @return (string) 文件的完整路径。
	getFullPath: function(self: Content, filename: string): string

	-- 在指定索引处插入文件搜索路径。
	-- @param index (integer) 要插入搜索路径的索引。
	-- @param path (string) 要插入的搜索路径。
	insertSearchPath: function(self: Content, index: integer, path: string)

	-- 添加新的文件搜索路径。
	-- @param path (string) 要添加的搜索路径。
	addSearchPath: function(self: Content, path: string)

	-- 从列表中删除指定的搜索路径。
	-- @param path (string) 要删除的搜索路径。
	removeSearchPath: function(self: Content, path: string)

	-- 异步读取指定文件名的文件内容。
	-- @param filename (string) 要读取的文件名。
	-- @return (string) 读取的文件内容。
	loadAsync: function(self: Content, filename: string): string

	-- 以异步的方式按表名读取 Excel 文件的内容。
	-- @param filename (string) 要读取的 Excel 文件名。
	-- @param sheetNames ({string}) [可选] 要读取的Excel表名的字符串列表。如果不提供，则默认会读取所有表。
	-- @return (table) 包含 Excel 文件数据的Lua表。Lua表的键是表名，值是包含Excel表的行列数据的表。如果读取失败则返回nil。
	loadExcelAsync: function(self: Content, filename: string, sheetNames?: {string}):
		{
			--[[表名]] string:
			--[[行]] {
				--[[列]] {string | number}
			}
		} | nil

	-- 异步将指定内容保存到指定文件名的文件中。
	-- @param filename (string) 要保存到的文件名。
	-- @param content (string) 要保存到文件中的内容。
	-- @return (boolean) 如果成功保存内容，则为 `true`，否则为 `false`。
	saveAsync: function(self: Content, filename: string, content: string): boolean

	-- 异步从源路径复制文件或文件夹到目标路径。
	-- @param src (string) 要复制的文件或文件夹的路径。
	-- @param dst (string) 复制文件的目标路径。
	-- @return (boolean) 如果成功复制了文件或文件夹，则为 `true`，否则为 `false`。
	copyAsync: function(self: Content, src: string, dst: string): boolean

	-- 异步将指定文件夹压缩为具有指定文件名的 ZIP 归档文件。
	-- @param folderPath (string) 要压缩的文件夹的路径，应在可写资源路径下。
	-- @param zipFile (string) 要创建的 ZIP 归档文件的名称。
	-- @param filter (function, 可选) 用于过滤要包含在归档中的文件的函数。该函数以文件名作为输入，并返回一个布尔值，表示是否包含文件。如果未提供，则包含所有文件。
	-- @return (boolean) 如果成功压缩了文件夹，则为 `true`，否则为 `false`。
	zipAsync: function(self: Content, folderPath: string, zipFile: string, filter?: function(string): boolean): boolean

	-- 异步将指定 ZIP 归档文件解压缩到指定的文件夹目录。
	-- @param zipFile (string) 要做解压的 ZIP 归档文件的名称，该文件必须在可写资源路径下。
	-- @param folderPath (string) 要解压缩到的文件夹的路径，应在可写资源路径下。
	-- @param filter (function, 可选) 用于过滤要做解压的 ZIP 归档包中的文件的函数。该函数以文件名作为输入，并返回一个布尔值，表示是否解压文件。如果未提供，则解压所有文件。
	-- @return (boolean) 如果成功解压缩了文件，则为 `true`，否则为 `false`。
	unzipAsync: function(self: Content, zipFile: string, folderPath: string, filter?: function(string): boolean): boolean

	-- 获取指定目录及其子目录中所有文件的名称。
	-- @param path (string) 要搜索的目录的路径。
	-- @param globs ({string}) 用于匹配文件名或相对路径的 glob 模式列表。示例：
	-- - 目标目录下（不包含子目录）的 .txt 文件和 .json 文件：["*.txt", "*.json"]
	-- - 目标目录下的所有文件，但排除 .txt 文件：["**", "!**.txt"]
	-- @param extensionLevels ({[string]: integer}) [可选] 扩展名到优先级的映射，用于同名不同后缀时选择优先级最高的文件。
	-- @return (table) 包含指定目录及其子目录中所有文件名称的列表。
	glob: function(self: Content, path: string, globs: {string}, extensionLevels?: {string: integer}): {string}

	-- `searchFilesAsync` 返回的搜索结果项。
	record SearchFilesResult
		-- 匹配到的文件完整路径。
		file: string

		-- 匹配位置（字节偏移）。
		pos: integer

		-- 匹配所在行号（从 1 开始）。
		line: integer

		-- 匹配所在列号（从 1 开始）。
		column: integer

		-- 匹配到的内容片段。
		content: string
	end

	-- 异步搜索文件并返回匹配结果，应在协程线程中调用。
	-- @param path (string) 搜索根路径，空字符串表示资源根目录。
	-- @param exts ({string}) 需要包含的扩展名列表，空表表示不过滤。
	-- @param extensionLevels ({[string]: integer}) 扩展名到优先级的映射，用于同名不同后缀时选择优先级最高的文件。
	-- @param globs ({string}) 需要匹配的文件名通配符列表。
	-- @param pattern (string) 搜索的匹配模式。
	-- @param useRegex (boolean) [可选] 是否使用正则匹配（默认 false）。
	-- 正则通配符支持:
	-- '.'        点，匹配任意单个字符
	-- '^'        行首锚点，匹配字符串开始位置
	-- '$'        行尾锚点，匹配字符串结束位置
	-- '*'        星号，匹配前面的内容零次或多次（贪婪）
	-- '+'        加号，匹配前面的内容一次或多次（贪婪）
	-- '?'        问号，匹配前面的内容零次或一次（非贪婪）
	-- '[abc]'    字符集，匹配括号内的任意一个字符（如 'a'、'b'、'c'）
	-- '[^abc]'   反集，匹配不是括号内任意字符的内容
	-- '[a-zA-Z]' 字符范围，匹配 a 到 z 或 A 到 Z 范围内的字符
	-- '\s'       匹配任意空白字符（如：\t \f \r \n \v 和空格）
	-- '\S'       匹配任意非空白字符
	-- '\w'       匹配任意字母、数字或下划线（[a-zA-Z0-9_]）
	-- '\W'       匹配任意非字母、数字或下划线的字符
	-- '\d'       匹配任意数字（[0-9]）
	-- '\D'       匹配任意非数字字符
	-- @param caseSensitive (boolean) [可选] 是否区分大小写（默认 false）。
	-- @param includeContent (boolean) [可选] 是否返回匹配内容片段（默认 false）。
	-- @param contentWindow (integer) [可选] includeContent 为 true 时返回匹配附近的字符数量。
	-- @param callback (function) [可选] 每条结果回调，返回 true 可中止搜索。
	-- @return ({SearchFilesResult}) 搜索结果列表。参考 [SearchFilesResult](/docs/api/Class/Content/SearchFilesResult)。
	searchFilesAsync: function(
		self: Content,
		path: string,
		exts: {string},
		extensionLevels: {string: integer},
		globs: {string},
		pattern: string,
		useRegex?: boolean,
		caseSensitive?: boolean,
		includeContent?: boolean,
		contentWindow?: integer,
		callback?: function(result: SearchFilesResult): boolean
	): {SearchFilesResult}

	-- 获取指定目录中所有子目录的名称。
	-- @param path (string) 要搜索的目录的路径。
	-- @return (table) 包含指定目录中所有子目录名称的列表。
	getDirs: function(self: Content, path: string): {string}

	-- 获取指定目录中所有文件的名称。
	-- @param path (string) 要搜索的目录的路径。
	-- @return (table) 包含指定目录中所有文件名称的列表。
	getFiles: function(self: Content, path: string): {string}

	-- 获取指定目录及其子目录中所有文件的名称。
	-- @param path (string) 要搜索的目录的路径。
	-- @return (table) 包含指定目录及其子目录中所有文件名称的列表。
	getAllFiles: function(self: Content, path: string): {string}

	-- 清除相对路径到完整路径映射的搜索路径缓存。
	clearPathCache: function(self: Content)
end

local content: Content
return content
