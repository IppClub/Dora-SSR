-- A record that provides Git command functions.
local record Git
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
	-- @param callback (function) Receives a JSON status string.
	-- @param optionsJSON (string) Optional JSON options.
	-- @return (number) The Git command handle for canceling the task.
	run: function(self: Git, repoPath: string, command: string, callback: function(status: string), optionsJSON?: string): number

	-- Cancels a Git job.
	-- For a handle returned by run, this also disposes the Git task.
	cancel: function(self: Git, jobId: number): boolean
end

local git: Git
return git
