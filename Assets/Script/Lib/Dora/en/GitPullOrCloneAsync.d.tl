-- Pull or clone a Git repository to the specified path asynchronously.
-- @param url The URL of the Git repository to pull or clone.
-- @param fullPath The full path where the repository should be cloned.
-- @param depth [optional] The depth of the repository to pull. Defaults to 0 which means all commits.
local GitPullOrCloneAsync: function(url: string, fullPath: string, depth?: number)
return GitPullOrCloneAsync
