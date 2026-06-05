-- A record that provides Git command functions.
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

	-- Runs a supported Git command and polls status automatically.
	-- The command may start with "git ". Shell syntax is rejected, and "git -C"
	-- is not supported; pass the working repository path through repoPath
	-- instead. Use single or double quotes around arguments that contain spaces.
	-- For clone, repoPath is the parent directory and the optional dir argument
	-- is the new repository folder name; when dir is omitted, the folder name is
	-- inferred from the URL.
	-- Supported commands:
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
	-- * mv <from> <to> (single files only)
	-- optionsJSON is optional and currently supports auth for clone, ls-remote,
	-- fetch, pull, and push:
	-- * {"auth":{"type":"basic","username":"user","password":"pass"}}
	-- * {"auth":{"type":"token","token":"access-token","username":"token"}}
	-- @param repoPath (string) The repository path. For clone, this is the parent directory.
	-- @param command (string) The Git command string.
	-- @param callback (function) Receives a decoded Status table.
	-- @param optionsJSON (string) Optional JSON options.
	-- @return (number) The Git command handle for canceling the task.
	run: function(self: Git, repoPath: string, command: string, callback: function(status: Status), optionsJSON?: string): number

	-- Cancels a Git job.
	-- For a handle returned by run, this also disposes the Git task.
	cancel: function(self: Git, jobId: number): boolean
end

local git: Git
return git
