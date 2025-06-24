-- Pull or clone a Git repository to the specified path asynchronously.
-- @param url (string) The URL of the Git repository to pull or clone.
-- @param fullPath (string) The full path where the repository should be cloned.
-- @param depth (integer) [optional] The depth of the repository to pull. Defaults to 0 which means all commits.
-- @return (boolean) Whether the Git operation started successfully.
local GitPullOrCloneAsync: function(url: string, fullPath: string, depth?: number): boolean
return GitPullOrCloneAsync
