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
