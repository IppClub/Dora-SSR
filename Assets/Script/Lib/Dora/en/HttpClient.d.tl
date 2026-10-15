-- Represents an HTTP client.
local record HttpClient

	-- Starts a non-blocking POST request with a JSON body.
	-- @param url (string) The URL to make the request to.
	-- @param json (string) The JSON text to send in the request.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @param callback (function) Called when the request finishes. It receives the response text, or nil if the request fails or is cancelled.
	-- @return (integer) The request handle, or 0 if the request cannot be scheduled.
	post: function(self: HttpClient, url: string, json: string, timeout: number, callback: function(data: string | nil)): integer

	-- Starts a non-blocking POST request with custom headers and a JSON body.
	-- @param url (string) The URL to make the request to.
	-- @param headers ({string}) The headers to send in the request. Each header should be in the format "name: value".
	-- @param json (string) The JSON text to send in the request.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @param callback (function) Called when the request finishes. It receives the response text, or nil if the request fails or is cancelled.
	-- @return (integer) The request handle, or 0 if the request cannot be scheduled.
	post: function(self: HttpClient, url: string, headers: {string}, json: string, timeout: number, callback: function(data: string | nil)): integer

	-- Starts a non-blocking POST request with custom headers and a JSON body, and optionally consumes the response stream in chunks before completion.
	-- @param url (string) The URL to make the request to.
	-- @param headers ({string}) The headers to send in the request. Each header should be in the format "name: value".
	-- @param json (string) The JSON text to send in the request.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @param partCallback (function) [optional] Called when response chunks arrive. Return `true` to stop and cancel the request early.
	-- @param callback (function) Called when the request finishes. It receives the full response text, or nil if the request fails or is cancelled.
	-- @return (integer) The request handle, or 0 if the request cannot be scheduled.
	post: function(self: HttpClient, url: string, headers: {string}, json: string, timeout: number, partCallback: function(data: string): boolean, callback: function(data: string | nil)): integer

	-- Sends a POST request with a JSON body and waits for the response text.
	-- @param url (string) The URL to make the request to.
	-- @param json (string) The JSON text to send in the request.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @return (string) The response text, or nil if the request fails.
	postAsync: function(self: HttpClient, url: string, json: string, timeout?: number): string | nil

	-- Sends a POST request with custom headers and a JSON body, and optionally consumes the response stream in chunks before completion.
	-- @param url (string) The URL to make the request to.
	-- @param headers ({string}) The headers to send in the request. Each header should be in the format "name: value".
	-- @param json (string) The JSON text to send in the request.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @param partCallback (function) [optional] Called when response chunks arrive. Return `true` to stop and cancel the request early.
	-- @return (string) The response text, or nil if the request fails.
	postAsync: function(self: HttpClient, url: string, headers: {string}, json: string, timeout?: number, partCallback?: function(data: string): boolean): string | nil

	-- Starts a non-blocking GET request.
	-- @param url (string) The URL to make the request to.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @param callback (function) Called when the request finishes. It receives the response text, or nil if the request fails or is cancelled.
	-- @return (integer) The request handle, or 0 if the request cannot be scheduled.
	get: function(self: HttpClient, url: string, timeout: number, callback: function(data: string | nil)): integer

	-- Sends a GET request and waits for the response text.
	-- @param url (string) The URL to make the request to.
	-- @param timeout (number) [optional] The request timeout in seconds (default is 5 seconds).
	-- @return (string) The response text, or nil if the request fails.
	getAsync: function(self: HttpClient, url: string, timeout?: number): string | nil

	-- Starts a non-blocking file download.
	-- @param url (string) The URL of the file to download.
	-- @param fullPath (string) The full path where the downloaded file should be saved.
	-- @param timeout (number) [optional] The download timeout in seconds (default is 30 seconds).
	-- @param progress (function) [optional] Reports download progress with interrupted, current, and total. Return `true` to cancel the download.
	-- @return (integer) The request handle, or 0 if the request cannot be scheduled.
	download: function(self: HttpClient, url: string, fullPath: string, timeout?: number, progress?: function(interrupted: boolean, current: integer, total: integer): boolean): integer

	-- Downloads a file and waits until it finishes. This method must be called from a coroutine/thread.
	-- @param url (string) The URL of the file to download.
	-- @param fullPath (string) The full path where the downloaded file should be saved.
	-- @param timeout (number) [optional] The download timeout in seconds (default is 30 seconds).
	-- @param progress (function) [optional] Reports download progress with current and total byte counts. Return `true` to cancel the download.
	-- @return (boolean) `true` if the download finishes successfully; otherwise `false`.
	downloadAsync: function(self: HttpClient, url: string, fullPath: string, timeout?: number, progress?: function(current: integer, total: integer): boolean): boolean

	-- Requests cancellation for an in-flight request.
	-- @param requestId (integer) The request handle returned by post, get, or download.
	-- @return (boolean) `true` if the request was found and cancellation was requested.
	cancel: function(self: HttpClient, requestId: integer): boolean

	-- Checks whether a request is still active.
	-- @param requestId (integer) The request handle returned by post, get, or download.
	-- @return (boolean) `true` if the request is still running.
	isRequestActive: function(self: HttpClient, requestId: integer): boolean
end

local httpClient: HttpClient
return httpClient
