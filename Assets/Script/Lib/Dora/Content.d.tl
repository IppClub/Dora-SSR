local record Content
	userdata
	searchPaths: {string}
	const assetPath: string
	const writablePath: string
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
	saveAsync: function(self: Content, filename: string, content: string)
	copyAsync: function(self: Content, src: string, dst: string)
	getDirs: function(self: Content, path: string): {string}
	getFiles: function(self: Content, path: string): {string}
	getAllFiles: function(self: Content, path: string): {string}
	load: function(self: Content, filename: string): string
end
local content: Content
return content
