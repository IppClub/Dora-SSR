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

	record HashData
		head: string
		ref: string
	end

	record CloneData
		path: string
		head: string | nil
		ref: string | nil
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

	record PathsData
		paths: {string}
	end

	record CommitData
		commit: string
	end

	record UpToDateData
		upToDate: boolean
	end

	record LogCommit
		hash: string
		message: string
		author: string
		email: string
		when: string
	end

	record LogData
		commits: {LogCommit}
	end

	record RestoreData
		paths: {string}
		staged: boolean
		worktree: boolean
	end

	record BranchInfo
		name: string
		hash: string
		current: boolean
	end

	record BranchData
		branch: string
		hash: string | nil
		deleted: boolean | nil
	end

	record BranchListData
		branches: {BranchInfo}
		current: string
	end

	record TagInfo
		name: string
		hash: string
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
	-- 支持的命令：
	-- * init [--bare]
	-- * clone <url> [dir] [-b|--branch <name>] [--depth <n>]
	-- * ls-remote <url>
	-- * status
	-- * add <path...> | add . | add -A|--all
	-- * rm <path...>
	-- * commit -m|--message <msg> [-a|--all] [--allow-empty] [--amend] [--author-name <name>] [--author-email <email>]
	-- * pull [remote] [branch] [-f|--force]
	-- * fetch [remote] [-f|--force] [-p|--prune] [--depth <n>]
	-- * push [remote] [branch] [-f|--force]
	-- * log [-n|--limit <n>] [-- <path...>]
	-- * checkout <branch-or-commit> [-f|--force]
	-- * checkout -b <branch>
	-- * reset [--soft|--mixed|--hard] <commit> [--confirm]
	-- * restore [--staged] [--worktree] <path...>
	-- * clean -f|--force
	-- * branch | branch <name> | branch -d <name>
	-- * tag | tag <name> | tag -a <name> -m <msg> | tag -d <name>
	-- * remote -v | remote add <name> <url> | remote set-url <name> <url> | remote remove <name>
	-- * mv <from> <to>（仅支持单文件）
	-- optionsJSON 是可选参数，目前支持给 clone、ls-remote、fetch、pull 和 push
	-- 提供认证信息：
	-- * {"auth":{"type":"basic","username":"user","password":"pass"}}
	-- * {"auth":{"type":"token","token":"access-token","username":"token"}}
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
