local record Content
	userdata
	searchPaths: {string}
	const assetPath: string
	const writablePath: string
	load: function(self: Content, filename: string): string
	loadExcel: function(self: Content, filename: string, sheetNames?: {string}): {string:{{string|number}}} | nil
	save: function(self: Content, filename: string, content: string)
	exist: function(self: Content, filename: string)
	mkdir: function(self: Content, path: string): boolean
	isdir: function(self: Content, path: string): boolean
	remove: function(self: Content, path: string): boolean
	getFullPath: function(self: Content, filename: string): string
	insertSearchPath: function(self: Content, index: integer, path: string)
	addSearchPath: function(self: Content, path: string)
	removeSearchPath: function(self: Content, path: string)
	loadAsync: function(self: Content, filename: string): string
	loadExcelAsync: function(self: Content, filename: string, sheetNames?: {string}): {string:{{string|number}}} | nil
	saveAsync: function(self: Content, filename: string, content: string): boolean
	copyAsync: function(self: Content, src: string, dst: string): boolean
	zipAsync: function(self: Content, zipFile: string, folderPath: string): boolean
	getDirs: function(self: Content, path: string): {string}
	getFiles: function(self: Content, path: string): {string}
	getAllFiles: function(self: Content, path: string): {string}
	clearPathCache: function(self: Content)
end
local content: Content
return content
