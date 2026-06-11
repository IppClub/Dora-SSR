-- 提供 Git 命令功能的记录。
local record Git

	enum JobState
		"queued"
		"running"
		"done"
		"error"
		"canceled"
	end

	enum Kind
		"init"
		"clone"
		"ls-remote"
		"status"
		"diff"
		"add"
		"rm"
		"commit"
		"pull"
		"fetch"
		"push"
		"log"
		"checkout"
		"reset"
		"restore"
		"clean"
		"branch"
		"tag"
		"remote"
		"mv"
	end

	enum RefKind
		"head"
		"branch"
		"tag"
		"remote"
		"ref"
	end

	record LFSData
		objects: number
		downloaded: number | nil
		uploaded: number | nil
		hydrated: boolean | nil
	end

	record HashData
		head: string
		ref: string
		lfs: LFSData | nil
	end

	record CloneData
		path: string
		head: string | nil
		ref: string | nil
		lfs: LFSData | nil
	end

	record InitData
		path: string
		bare: boolean
		ref: string | nil
	end

	record RemoteRef
		name: string
		type: RefKind
		hash: string | nil
		target: string | nil
	end

	record LsRemoteData
		url: string
		refs: {RemoteRef}
	end

	record FileStatus
		path: string
		staging: string
		worktree: string
	end

	record WorktreeStatusData
		clean: boolean
		files: {FileStatus}
	end

	enum DiffMode
		"diff"
		"empty"
		"binary"
		"large"
	end

	record DiffData
		path: string
		staged: boolean | nil
		commit: string | nil
		mode: DiffMode
		oldText: string | nil
		newText: string | nil
		binary: boolean | nil
		oldSize: number | nil
		newSize: number | nil
		message: string | nil
	end

	record PathsData
		paths: {string}
		lfs: {string} | nil
	end

	record CommitData
		commit: string
	end

	record UpstreamData
		branch: string
		remote: string
		merge: string
	end

	record UpToDateData
		upToDate: boolean | nil
		lfs: LFSData | nil
		upstream: UpstreamData | nil
	end

	record ChangedFile
		path: string
		status: string
	end

	record LogCommit
		hash: string
		message: string
		author: string
		email: string
		when: string
		files: {ChangedFile}
	end

	record LogData
		commits: {LogCommit}
	end

	record RestoreData
		paths: {string}
		staged: boolean
		worktree: boolean
		lfs: LFSData | nil
	end

	record BranchInfo
		name: string
		hash: string
		current: boolean | nil
		remote: string | nil
	end

	record BranchData
		branch: string
		hash: string | nil
		deleted: boolean | nil
		unborn: boolean | nil
	end

	record BranchListData
		branches: {BranchInfo}
		current: string
	end

	record TagInfo
		name: string
		hash: string
		ref: string
	end

	record TagData
		tag: string
		hash: string | nil
		annotated: boolean | nil
		deleted: boolean | nil
	end

	record TagListData
		tags: {TagInfo}
	end

	record RemoteInfo
		name: string
		urls: {string}
	end

	record RemoteData
		remote: string
		urls: {string} | nil
		removed: boolean | nil
	end

	record RemoteListData
		remotes: {RemoteInfo}
	end

	record MoveData
		from: string
		to: string
		hash: string
		lfs: {string} | nil
	end

	record CheckoutData
		head: string | nil
		ref: string | nil
		lfs: LFSData | nil
		branch: string | nil
		unborn: boolean | nil
	end

	record Status
		id: number
		state: JobState
		kind: Kind
		repoPath: string
		startedAt: string | nil
		endedAt: string | nil
		progress: number
		message: string | nil
		error: string | nil
		data: any
	end

	-- 运行支持的 Git 命令，并自动轮询状态。
	-- 命令可以带 "git " 前缀。不支持 shell 语法，也不支持 "git -C"；
	-- 请通过 repoPath 传入工作仓库路径。包含空格的参数可用单引号或双引号包裹。
	-- clone 时 repoPath 是父目录，可选 dir 参数是新建仓库文件夹名；
	-- 省略 dir 时会从 URL 推导文件夹名。
	-- 使用 Git LFS 的仓库会被透明处理：add 和 status 遵循 filter=lfs
	-- 属性；clone、pull、checkout、hard reset 和 restore 会下载并展开
	-- LFS 对象；fetch 会下载 LFS 对象；push 会先上传 LFS 对象再更新 Git 引用。
	-- 支持的命令：
	-- * init [--bare]
	-- * clone <url> [dir] [-b|--branch <name>] [--depth <n>]
	-- * ls-remote <url>
	-- * status
	-- * diff [--cached|--staged] [--] <path>
	-- * diff <40位commit哈希> -- <path>
	-- * add <path...> | add . | add -A|--all
	-- * rm <path...>
	-- * commit -m|--message <msg> [-a|--all] [--allow-empty] [--amend] [--author-name <name>] [--author-email <email>]
	-- * pull [remote] [branch] [-f|--force]
	-- * fetch [remote] [-f|--force] [-p|--prune] [--depth <n>]
	-- * push [remote] [branch] [-f|--force] [-u|--set-upstream]
	-- * log [-n|--limit <n>] [-- <path>]
	-- * checkout [-f|--force] <branch或40位commit哈希>
	-- * checkout [-f|--force] -b <branch> [start-point]
	-- * reset [--soft|--mixed|--hard] <40位commit哈希> [--confirm]
	-- * restore [--staged] [--worktree] <path...>
	-- * clean -f|--force
	-- * branch | branch <name> | branch -d <name>
	-- * tag | tag <name> | tag -a <name> -m <msg> | tag -d <name>
	-- * remote | remote -v | remote add <name> <url> | remote set-url <name> <url> | remote remove <name>
	-- * mv <from> <to>（仅支持单文件）
	-- 文件路径均相对于 repoPath。pull、fetch 和 push 默认使用 origin；
	-- 省略分支时使用当前分支。reset --hard 必须带 --confirm。
	-- push -u|--set-upstream 会在推送成功后更新本地分支配置。
	-- optionsJSON 是可选参数，目前支持给 clone、ls-remote、fetch、pull 和 push
	-- 及其自动触发的 LFS 传输提供认证信息：
	-- * {"auth":{"type":"basic","username":"user","password":"pass"}}
	-- * {"auth":{"type":"token","token":"access-token","username":"token"}}
	-- token 认证的 username 可省略，默认值为 "token"。仅当 LFS URL 与 Git
	-- 远程地址同 host 时，自动 LFS 请求才会复用认证信息；LFS 服务端返回的
	-- action 专用认证请求头优先。
	-- @param repoPath (string) 仓库路径。clone 时该路径是父目录。
	-- @param command (string) Git 命令字符串。
	-- @param callback (function) 接收已解码 Status 表的回调函数。
	-- @param optionsJSON (string) 可选的 JSON 配置。
	-- @return (number) 用于取消任务的 Git 命令句柄。
	run: function(self: Git, repoPath: string, command: string, callback: function(status: Status), optionsJSON?: string): number

	-- 取消 Git 任务。对 run 返回的句柄调用时，也会释放 Git 任务。
	cancel: function(self: Git, jobId: number): boolean
end

local git: Git
return git
