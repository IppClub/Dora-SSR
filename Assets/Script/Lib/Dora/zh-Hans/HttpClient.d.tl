-- 代表一个HTTP客户端。
local record HttpClient

	-- 从指定的URL异步下载文件，并保存到指定的路径。必须在一个协程中调用此方法。
	-- @param url (string) 需要下载的文件的URL。
	-- @param fullPath (string) 下载文件应保存的完整路径。
	-- @param progress (string) [可选] 一个定期报告下载进度的回调函数。
	--	该函数接收两个参数：current（到目前为止下载的字节数）和 total（需要下载的总字节数）。
	-- @return (boolean) 一个布尔值，表示下载是否成功完成。
	downloadAsync: function(self: HttpClient, url: string, fullPath: string, progress?: function(current: integer, total: integer)): boolean
end

local httpClient: HttpClient
return httpClient