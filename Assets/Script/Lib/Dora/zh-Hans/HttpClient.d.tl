-- 代表一个HTTP客户端。
local record HttpClient

	-- 向指定的URL发送JSON文本的POST请求，并返回响应文本。
	-- @param url (string) 要发送请求的URL。
	-- @param json (string) 要在请求中发送的JSON文本。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @return (string) 响应体的文本，如果请求失败则返回nil。
	postAsync: function(self: HttpClient, url: string, json: string, timeout?: number): string | nil

	-- 向指定的URL发送带有指定头部和JSON文本的POST请求，并返回响应文本。
	-- @param url (string) 要发送请求的URL。
	-- @param headers ({string}) 要在请求中发送的头部。每个头部应该以 "name: value" 的格式。
	-- @param json (string) 要在请求中发送的JSON文本。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @param partCallback (function) [可选] 一个定期报告部分接收到的响应内容的回调函数。返回 `true` 以停止请求。
	-- @return (string) 响应体的文本，如果请求失败则返回nil。
	postAsync: function(self: HttpClient, url: string, headers: {string}, json: string, timeout?: number, partCallback?: function(data: string): boolean): string | nil

	-- 向指定的URL发送GET请求，并返回响应文本。
	-- @param url (string) 要发送请求的URL。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @return (string) 响应体的文本，如果请求失败则返回nil。
	getAsync: function(self: HttpClient, url: string, timeout?: number): string | nil

	-- 从指定的URL异步下载文件，并保存到指定的路径。必须在一个协程中调用此方法。
	-- @param url (string) 需要下载的文件的URL。
	-- @param fullPath (string) 下载文件应保存的完整路径。
	-- @param timeout (number) [可选] 下载超时时间（以秒为单位，默认为30秒）。
	-- @param progress (string) [可选] 一个定期报告下载进度的回调函数。
	--	该函数接收两个参数：current（到目前为止下载的字节数）和 total（需要下载的总字节数）。
	-- 如果回调函数返回 `true`，则下载将被取消。
	-- @return (boolean) 一个布尔值，表示下载是否成功完成。
	downloadAsync: function(self: HttpClient, url: string, fullPath: string, timeout?: number, progress?: function(current: integer, total: integer): boolean): boolean
end

local httpClient: HttpClient
return httpClient