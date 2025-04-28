-- Represents an HTTP client.
local record HttpClient

	-- Makes a POST request to the specified URL with the specified JSON text and returns the response in text.
	-- @param url (string) The URL to make the request to.
	-- @param json (string) The JSON text to send in the request.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @param partCallback (function) [optional] A callback function that is called periodically to get part of the response content. Returns `true` to stop the request.
	-- @return (string) The response in text，or nil if the request fails.
	postAsync: function(self: HttpClient, url: string, json: string, timeout?: number, partCallback?: function(data: string): boolean): string | nil

	-- Makes a POST request to the specified URL with the specified headers and JSON text, and returns the response in text.
	-- @param url (string) The URL to make the request to.
	-- @param headers ({string}) The headers to send in the request. Each header should be in the format "name: value".
	-- @param json (string) The JSON text to send in the request.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @return (string) The response in text，or nil if the request fails.
	postAsync: function(self: HttpClient, url: string, headers: {string}, json: string, timeout?: number): string | nil

	-- Makes a GET request to the specified URL and returns the response in text.
	-- @param url (string) The URL to make the request to.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @return (string) The response in text，or nil if the request fails.
	getAsync: function(self: HttpClient, url: string, timeout?: number): string | nil

	-- Downloads a file asynchronously from the specified URL and saves it to the specified path. Should be run in a coroutine.
	-- @param url (string) The URL of the file to download.
	-- @param fullPath (string) The full path where the downloaded file should be saved.
	-- @param timeout (number) [optional] The download timeout in seconds (default is 30 seconds).
	-- @param progress (string) [optional] A callback function that is called periodically to report the download progress.
	--	The function receives two parameters: current (the number of bytes downloaded so far)
	--	and total (the total number of bytes to be downloaded).
	-- If the function returns true, the download will be canceled.
	-- @return (boolean) A boolean value indicating whether the download was done successfully.
	downloadAsync: function(self: HttpClient, url: string, fullPath: string, timeout?: number, progress?: function(current: integer, total: integer): boolean): boolean
end

local httpClient: HttpClient
return httpClient