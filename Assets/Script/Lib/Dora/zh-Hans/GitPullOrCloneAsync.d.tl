-- 异步拉取或克隆一个 Git 仓库到指定路径。
-- @param url Git 仓库的 URL。
-- @param fullPath 仓库克隆到的完整路径。
-- @param depth [可选] 拉取的深度。默认为 0，表示拉取所有提交。
local GitPullOrCloneAsync: function(url: string, fullPath: string, depth?: number)
return GitPullOrCloneAsync
