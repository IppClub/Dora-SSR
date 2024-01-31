-- Represents an HTTP client.
local record HttpClient

	-- Downloads a file asynchronously from the specified URL and saves it to the specified path. Should be run in a coroutine.
	-- @param url (string) The URL of the file to download.
	-- @param fullPath (string) The full path where the downloaded file should be saved.
	-- @param progress (string) [optional] A callback function that is called periodically to report the download progress.
	--	The function receives two parameters: current (the number of bytes downloaded so far)
	--	and total (the total number of bytes to be downloaded).
	-- @return (boolean) A boolean value indicating whether the download was done successfully.
	downloadAsync: function(self: HttpClient, url: string, fullPath: string, progress: function(current: integer, total: integer)): boolean
end

local httpClient: HttpClient
return httpClient