-- The `Content` record is a singleton object that manages file searching,
-- loading and other operations related to resources.
-- @usage
-- local Content = require("Content")
-- local text = Content:load("filename.txt")
local record Content
	userdata

	-- An array of directories to search for resource files.
	searchPaths: {string}

	-- The path to the directory containing read-only resources. Can only be altered by the user on platform Windows, MacOS and Linux.
	assetPath: string

	-- The path to the directory where files can be written. Can only be altered by the user on platform Windows, MacOS and Linux. Default is the same as the `appPath`.
	writablePath: string

	-- The path to the directory for the application storage.
	appPath: string

	-- Loads the content of the file with the specified filename.
	-- @param filename (string) The name of the file to load.
	-- @return (string) The content of the loaded file.
	load: function(self: Content, filename: string): string

	-- Loads the content of an Excel file with the specified filename and optional sheet names
	-- @param filename (string) The name of the Excel file to load
	-- @param sheetNames ({string}) [optional] An array of strings representing the names of the sheets to load. If not provided, all sheets will be loaded.
	-- @return (table) A table containing the data in the Excel file. The keys are the sheet names and the values are tables containing the rows and columns of the sheet.
	loadExcel: function(self: Content, filename: string, sheetNames?: {string}):
		{
			--[[sheetName]] string:
			--[[rows]] {
				--[[colums]] {string | number}
			}
		} | nil

	-- Saves the specified content to a file with the specified filename.
	-- @param filename (string) The name of the file to save.
	-- @param content (string) The content to save to the file.
	-- @return (boolean) `true` if the content saves to file successfully, `false` otherwise.
	save: function(self: Content, filename: string, content: string): boolean

	-- Checks if a file with the specified filename exists.
	-- @param filename (string) The name of the file to check.
	-- @return (boolean) `true` if the file exists, `false` otherwise.
	exist: function(self: Content, filename: string): boolean

	-- Creates a new directory with the specified path.
	-- @param path (string) The path of the directory to create.
	-- @return (boolean) `true` if the directory was created, `false` otherwise.
	mkdir: function(self: Content, path: string): boolean

	-- Checks if the specified path is a directory.
	-- @param path (string) The path to check.
	-- @return (boolean) `true` if the path is a directory, `false` otherwise.
	isdir: function(self: Content, path: string): boolean

	-- Removes the file or directory with the specified path.
	-- @param path (string) The path of the file or directory to remove.
	-- @return (boolean) `true` if the file or directory was removed, `false` otherwise.
	remove: function(self: Content, path: string): boolean

	-- Copies the file or directory in the specified path to target path.
	-- @param srcPath (string) The path of the file or directory to copy.
	-- @param dstPath (string) The path to copy files to.
	-- @return (boolean) `true` if the file or directory was copied to target path, `false` otherwise.
	copy: function(self: Content, srcPath: string, dstPath: string): boolean

	-- Moves the file or directory in the specified path to target path.
	-- @param srcPath (string) The path of the file or directory to move.
	-- @param dstPath (string) The path to move files to.
	-- @return (boolean) `true` if the file or directory was moved to target path, `false` otherwise.
	move: function(self: Content, srcPath: string, dstPath: string): boolean

	-- Checks if the specified path is an absolute path.
	-- @param path (string) The path to check.
	-- @return (boolean) `true` if the path is an absolute path, `false` otherwise.
	isAbsolutePath: function(self: Content, path: string): boolean

	-- Gets the full path of a file with the specified filename.
	-- @param filename (string) The name of the file to get the full path of.
	-- @return (string) The full path of the file.
	getFullPath: function(self: Content, filename: string): string

	-- Inserts a search path at the specified index.
	-- @param index (integer) The index at which to insert the search path.
	-- @param path (string) The search path to insert.
	insertSearchPath: function(self: Content, index: integer, path: string)

	-- Adds a new search path to the end of the list.
	-- @param path (string) The search path to add.
	addSearchPath: function(self: Content, path: string)

	-- Removes the specified search path from the list.
	-- @param path (string) The search path to remove.
	removeSearchPath: function(self: Content, path: string)

	-- Asynchronously loads the content of the file with the specified filename.
	-- @param filename (string) The name of the file to load.
	-- @return (string) The content of the loaded file.
	loadAsync: function(self: Content, filename: string): string

	-- Asynchronously loads the content of an Excel file with the specified filename and optional sheet names.
	-- @param filename (string) The name of the Excel file to load.
	-- @param sheetNames ({string}) [optional] An array of strings representing the names of the sheets to load. If not provided, all sheets will be loaded.
	-- @return (table) A table containing the data in the Excel file. The keys are the sheet names and the values are tables containing the rows and columns of the sheet.
	loadExcelAsync: function(self: Content, filename: string, sheetNames?: {string}):
		{
			--[[sheetName]] string:
			--[[rows]] {
				--[[colums]] {string | number}
			}
		} | nil

	-- Asynchronously saves the specified content to a file with the specified filename.
	-- @param filename (string) The name of the file to save.
	-- @param content (string) The content to save to the file.
	-- @return (boolean) `true` if the content was saved successfully, `false` otherwise.
	saveAsync: function(self: Content, filename: string, content: string): boolean

	-- Asynchronously copies a file or a folder from the source path to the destination path.
	-- @param src (string) The path of the file or folder to copy.
	-- @param dst (string) The destination path of the copied files.
	-- @return (boolean) `true` if the file or folder was copied successfully, `false` otherwise.
	copyAsync: function(self: Content, src: string, dst: string): boolean

	-- Asynchronously compresses the specified folder to a ZIP archive with the specified filename.
	-- @param folderPath (string) The path of the folder to compress, should be under the asset writable path.
	-- @param zipFile (string) The name of the ZIP archive to create.
	-- @param filter (function) [optional] A function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	-- @return (boolean) `true` if the folder was compressed successfully, `false` otherwise.
	zipAsync: function(self: Content, folderPath: string, zipFile: string, filter?: function(string): boolean): boolean

	-- Asynchronously decompresses a ZIP archive to the specified folder.
	-- @param zipFile (string) The name of the ZIP archive to decompress, should be a file under the asset writable path.
	-- @param folderPath (string) The path of the folder to decompress to, should be under the asset writable path.
	-- @param filter (function) [optional] A function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	-- @return (boolean) `true` if the folder was decompressed successfully, `false` otherwise.
	unzipAsync: function(self: Content, zipFile: string, folderPath: string, filter?: function(string): boolean): boolean

	-- A search result item returned by `searchFilesAsync`.
	record SearchFilesResult
		-- The full path of the file.
		file: string

		-- The match position in bytes.
		pos: integer

		-- The line number of the match (1-based).
		line: integer

		-- The column number of the match (1-based).
		column: integer

		-- The matched content snippet.
		content: string
	end

	-- Asynchronously searches files and returns the match results. Should be run in a thread.
	-- @param path (string) The root path to search from, empty string means asset root.
	-- @param exts ({string}) An array of filename extensions to include, empty table means all.
	-- @param extensionLevels ({[string]: integer}) A map from extension to priority level for picking the preferred file when the same basename appears with different extensions.
	-- @param excludes ({string}) An array of directory names to skip during searching.
	-- @param pattern (string) The search pattern.
	-- @param useRegex (boolean) [optional] Whether to treat pattern as regex (default false).
	-- Regex supports:
	-- '.'        Dot, matches any character
	-- '^'        Start anchor, matches beginning of string
	-- '$'        End anchor, matches end of string
	-- '*'        Asterisk, match zero or more (greedy)
	-- '+'        Plus, match one or more (greedy)
	-- '?'        Question, match zero or one (non-greedy)
	-- '[abc]'    Character class, match if one of {'a', 'b', 'c'}
	-- '[^abc]'   Inverted class, match if NOT one of {'a', 'b', 'c'}
	-- '[a-zA-Z]' Character ranges, the character set of the ranges { a-z | A-Z }
	-- '\s'       Whitespace, \t \f \r \n \v and spaces
	-- '\S'       Non-whitespace
	-- '\w'       Alphanumeric, [a-zA-Z0-9_]
	-- '\W'       Non-alphanumeric
	-- '\d'       Digits, [0-9]
	-- '\D'       Non-digits
	-- @param caseSensitive (boolean) [optional] Whether to use case-sensitive matching (default false).
	-- @param includeContent (boolean) [optional] Whether to include the matched content snippet (default false).
	-- @param contentWindow (integer) [optional] Number of characters around the match to include when includeContent is true.
	-- @param callback (function) [optional] Called per result, return true to stop searching.
	-- @return ({SearchFilesResult}) An array of search results. See [SearchFilesResult](/docs/api/Class/Content/SearchFilesResult).
	searchFilesAsync: function(
		self: Content,
		path: string,
		exts: {string},
		extensionLevels: {string: integer},
		excludes: {string},
		pattern: string,
		useRegex?: boolean,
		caseSensitive?: boolean,
		includeContent?: boolean,
		contentWindow?: integer,
		callback?: function(result: SearchFilesResult): boolean
	): {SearchFilesResult}

	-- Gets the names of all subdirectories in the specified directory.
	-- @param path (string) The path of the directory to search.
	-- @return (table) An array of the names of all subdirectories in the specified directory.
	getDirs: function(self: Content, path: string): {string}

	-- Gets the names of all files in the specified directory.
	-- @param path (string) The path of the directory to search.
	-- @return (table) An array of the names of all files in the specified directory.
	getFiles: function(self: Content, path: string): {string}

	-- Gets the names of all files in the specified directory and its subdirectories.
	-- @param path (string) The path of the directory to search.
	-- @return (table) An array of the names of all files in the specified directory and its subdirectories.
	getAllFiles: function(self: Content, path: string): {string}

	-- Clears the search path cache of the map of relative paths to full paths.
	clearPathCache: function(self: Content)
end

local content: Content
return content
