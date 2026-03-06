-- 代表一个HTTP客户端。
local record HttpClient

	-- 发起非阻塞的 POST 请求，并发送 JSON 请求体。
	-- @param url (string) 要发送请求的URL。
	-- @param json (string) 要在请求中发送的JSON文本。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @param callback (function) 请求完成时调用。参数为响应文本；如果请求失败或被取消则为 nil。
	-- @return (integer) 请求句柄；如果请求无法发起则返回 0。
	post: function(self: HttpClient, url: string, json: string, timeout: number, callback: function(data: string | nil)): integer

	-- 发起带自定义请求头和 JSON 请求体的非阻塞 POST 请求。
	-- @param url (string) 要发送请求的URL。
	-- @param headers ({string}) 要在请求中发送的头部。每个头部应该以 "name: value" 的格式。
	-- @param json (string) 要在请求中发送的JSON文本。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @param callback (function) 请求完成时调用。参数为响应文本；如果请求失败或被取消则为 nil。
	-- @return (integer) 请求句柄；如果请求无法发起则返回 0。
	post: function(self: HttpClient, url: string, headers: {string}, json: string, timeout: number, callback: function(data: string | nil)): integer

	-- 发起带自定义请求头和 JSON 请求体的非阻塞 POST 请求，并可在完成前按块处理响应内容。
	-- @param url (string) 要发送请求的URL。
	-- @param headers ({string}) 要在请求中发送的头部。每个头部应该以 "name: value" 的格式。
	-- @param json (string) 要在请求中发送的JSON文本。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @param partCallback (function) [可选] 当收到部分响应内容时调用。返回 `true` 可提前停止并取消请求。
	-- @param callback (function) 请求完成时调用。参数为完整响应文本；如果请求失败或被取消则为 nil。
	-- @return (integer) 请求句柄；如果请求无法发起则返回 0。
	post: function(self: HttpClient, url: string, headers: {string}, json: string, timeout: number, partCallback: function(data: string): boolean, callback: function(data: string | nil)): integer

	-- 发送带 JSON 请求体的 POST 请求，并等待响应文本返回。
	-- @param url (string) 要发送请求的URL。
	-- @param json (string) 要在请求中发送的JSON文本。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @return (string) 响应体的文本，如果请求失败则返回nil。
	postAsync: function(self: HttpClient, url: string, json: string, timeout?: number): string | nil

	-- 发送带自定义请求头和 JSON 请求体的 POST 请求，并可在完成前按块处理响应内容。
	-- @param url (string) 要发送请求的URL。
	-- @param headers ({string}) 要在请求中发送的头部。每个头部应该以 "name: value" 的格式。
	-- @param json (string) 要在请求中发送的JSON文本。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @param partCallback (function) [可选] 当收到部分响应内容时调用。返回 `true` 可提前停止并取消请求。
	-- @return (string) 响应体的文本，如果请求失败则返回nil。
	postAsync: function(self: HttpClient, url: string, headers: {string}, json: string, timeout?: number, partCallback?: function(data: string): boolean): string | nil

	-- 发起非阻塞的 GET 请求。
	-- @param url (string) 要发送请求的URL。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @param callback (function) 请求完成时调用。参数为响应文本；如果请求失败或被取消则为 nil。
	-- @return (integer) 请求句柄；如果请求无法发起则返回 0。
	get: function(self: HttpClient, url: string, timeout: number, callback: function(data: string | nil)): integer

	-- 发送 GET 请求，并等待响应文本返回。
	-- @param url (string) 要发送请求的URL。
	-- @param timeout (number) [可选] 请求超时时间（以秒为单位，默认为5秒）。
	-- @return (string) 响应体的文本，如果请求失败则返回nil。
	getAsync: function(self: HttpClient, url: string, timeout?: number): string | nil

	-- 发起非阻塞的文件下载。
	-- @param url (string) 需要下载的文件的URL。
	-- @param fullPath (string) 下载文件应保存的完整路径。
	-- @param timeout (number) [可选] 下载超时时间（以秒为单位，默认为30秒）。
	-- @param progress (function) [可选] 用于报告下载进度，接收 interrupted、current 和 total。返回 `true` 可取消下载。
	-- @return (integer) 请求句柄；如果请求无法发起则返回 0。
	download: function(self: HttpClient, url: string, fullPath: string, timeout?: number, progress?: function(interrupted: boolean, current: integer, total: integer): boolean): integer

	-- 下载文件并等待完成。该方法必须在协程或线程中调用。
	-- @param url (string) 需要下载的文件的URL。
	-- @param fullPath (string) 下载文件应保存的完整路径。
	-- @param timeout (number) [可选] 下载超时时间（以秒为单位，默认为30秒）。
	-- @param progress (function) [可选] 用于报告下载进度，接收 current 和 total 字节数。返回 `true` 可取消下载。
	-- @return (boolean) 如果下载成功完成则返回 `true`，否则返回 `false`。
	downloadAsync: function(self: HttpClient, url: string, fullPath: string, timeout?: number, progress?: function(current: integer, total: integer): boolean): boolean

	-- 请求取消一个正在进行中的请求。
	-- @param requestId (integer) 由 post、get 或 download 返回的请求句柄。
	-- @return (boolean) 如果找到了请求并已发起取消，则返回 `true`。
	cancel: function(self: HttpClient, requestId: integer): boolean

	-- 检查请求是否仍在进行中。
	-- @param requestId (integer) 由 post、get 或 download 返回的请求句柄。
	-- @return (boolean) 如果请求仍在运行，则返回 `true`。
	isRequestActive: function(self: HttpClient, requestId: integer): boolean
end

local httpClient: HttpClient
return httpClient
