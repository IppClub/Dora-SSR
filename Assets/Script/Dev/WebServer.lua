local _module_0 = nil
local _ENV = Dora
local HttpServer <const> = HttpServer
local Path <const> = Path
local Content <const> = Content
local table <const> = table
local string <const> = string
local math <const> = math
local require <const> = require
local os <const> = os
local type <const> = type
local tostring <const> = tostring
local DB <const> = DB
local tonumber <const> = tonumber
local json <const> = json
local Git <const> = Git
local pcall <const> = pcall
local wait <const> = wait
local yue <const> = yue
local load <const> = load
local teal <const> = teal
local xml <const> = xml
local ipairs <const> = ipairs
local pairs <const> = pairs
local App <const> = App
local setmetatable <const> = setmetatable
local Wasm <const> = Wasm
local package <const> = package
local thread <const> = thread
local print <const> = print
local sleep <const> = sleep
local emit <const> = emit
local Node <const> = Node
local yarncompile <const> = yarncompile
HttpServer:stop()
HttpServer.wwwPath = Path(Content.appPath, ".www")
HttpServer.authToken = ""
local authFailedCount = 0
local authLockedUntil = 0.0
local PendingTTL = 60
local _anon_func_0 = function()
	local _accum_0 = { }
	local _len_0 = 1
	for _ = 1, 4 do
		_accum_0[_len_0] = string.format("%08x", math.random(0, 0x7fffffff))
		_len_0 = _len_0 + 1
	end
	return _accum_0
end
local genAuthToken
genAuthToken = function()
	return table.concat(_anon_func_0())
end
local _anon_func_1 = function()
	local _accum_0 = { }
	local _len_0 = 1
	for _ = 1, 2 do
		_accum_0[_len_0] = string.format("%08x", math.random(0, 0x7fffffff))
		_len_0 = _len_0 + 1
	end
	return _accum_0
end
local genSessionId
genSessionId = function()
	return table.concat(_anon_func_1())
end
local genConfirmCode
genConfirmCode = function()
	return string.format("%04d", math.random(0, 9999))
end
HttpServer:post("/auth", function(req)
	local Entry = require("Script.Dev.Entry")
	local AuthSession = Entry.AuthSession
	local authCode = Entry.getAuthCode()
	local now = os.time()
	if now < authLockedUntil then
		return {
			success = false,
			message = "locked",
			retryAfter = authLockedUntil - now
		}
	end
	local code = nil
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					code = _obj_0.code
				end
			end
			if code ~= nil then
				code = code
			end
		end
	end
	if code and tostring(code) == authCode then
		authFailedCount = 0
		Entry.invalidateAuthCode()
		do
			local pending = AuthSession.getPending()
			if pending then
				if now < pending.expiresAt and not pending.approved then
					return {
						success = true,
						pending = true,
						sessionId = pending.sessionId,
						confirmCode = pending.confirmCode,
						expiresIn = pending.expiresAt - now
					}
				end
			end
		end
		local sessionId = genSessionId()
		local confirmCode = genConfirmCode()
		AuthSession.beginPending(sessionId, confirmCode, now + PendingTTL, PendingTTL)
		return {
			success = true,
			pending = true,
			sessionId = sessionId,
			confirmCode = confirmCode,
			expiresIn = PendingTTL
		}
	else
		authFailedCount = authFailedCount + 1
		if authFailedCount >= 3 then
			authFailedCount = 0
			authLockedUntil = now + 30
			return {
				success = false,
				message = "locked",
				retryAfter = 30
			}
		end
		return {
			success = false,
			message = "invalid code"
		}
	end
end)
HttpServer:post("/auth/confirm", function(req)
	local now = os.time()
	local sessionId = nil
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			if sessionId ~= nil then
				sessionId = sessionId
			end
		end
	end
	if not sessionId then
		return {
			success = false,
			message = "invalid session"
		}
	end
	local Entry = require("Script.Dev.Entry")
	local AuthSession = Entry.AuthSession
	do
		local pending = AuthSession.getPending()
		if pending then
			if pending.sessionId ~= sessionId then
				return {
					success = false,
					message = "invalid session"
				}
			end
			if now >= pending.expiresAt then
				AuthSession.clearPending()
				return {
					success = false,
					message = "expired"
				}
			end
			if pending.approved then
				local secret = genAuthToken()
				HttpServer.authToken = tostring(sessionId) .. ":" .. tostring(secret)
				AuthSession.setSession(sessionId, secret)
				AuthSession.clearPending()
				return {
					success = true,
					sessionId = sessionId,
					sessionSecret = secret
				}
			end
			return {
				success = false,
				message = "pending",
				retryAfter = 2
			}
		end
	end
	return {
		success = false,
		message = "invalid session"
	}
end)
local LintYueGlobals, CheckTIC80Code
do
	local _obj_0 = require("Utils")
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code
end
local getProjectDirFromFile
getProjectDirFromFile = function(file)
	local writablePath, assetPath = Content.writablePath, Content.assetPath
	local parent, current
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then
		parent, current = writablePath, Path:getRelative(file, writablePath)
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then
		local dir = Path(assetPath, "Script")
		parent, current = dir, Path:getRelative(file, dir)
	else
		parent, current = nil, nil
	end
	if not current then
		return nil
	end
	repeat
		current = Path:getPath(current)
		if current == "" then
			break
		end
		local _list_0 = Content:getFiles(Path(parent, current))
		for _index_0 = 1, #_list_0 do
			local f = _list_0[_index_0]
			if Path:getName(f):lower() == "init" then
				return Path(parent, current, Path:getPath(f))
			end
		end
	until false
	return nil
end
local relativeToRoot
relativeToRoot = function(file, root)
	if not (file and file ~= "" and root and root ~= "") then
		return nil
	end
	if file == root then
		return ""
	end
	local prefix = root
	if not (prefix:sub(-1) == "/") then
		prefix = prefix .. "/"
	end
	if file:sub(1, #prefix) == prefix then
		return file:sub(#prefix + 1)
	else
		return nil
	end
end
local getProjectSourceRoot
getProjectSourceRoot = function(projectRoot)
	if not (projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot)) then
		return nil
	end
	return projectRoot
end
local isProjectRootDir
isProjectRootDir = function(dir)
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then
		return false
	end
	local _list_0 = Content:getFiles(dir)
	for _index_0 = 1, #_list_0 do
		local f = _list_0[_index_0]
		if Path:getName(f):lower() == "init" then
			return true
		end
	end
	return false
end
local getProjectRootFromPath
getProjectRootFromPath = function(target, isDir)
	if isDir == nil then
		isDir = false
	end
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then
		return nil, "invalid path"
	end
	if isDir then
		if isProjectRootDir(target) then
			return target
		end
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project")
	end
	return getProjectDirFromFile(target, "current file does not belong to any project")
end
local invalidArguments = {
	success = false,
	message = "invalid arguments"
}
HttpServer:post("/agent/project-root", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			local isDir
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					isDir = _obj_0.isDir
				end
			end
			if path ~= nil and isDir ~= nil then
				local projectRoot, err = getProjectRootFromPath(path, isDir)
				if projectRoot then
					return {
						success = true,
						found = true,
						projectRoot = projectRoot,
						title = Path:getFilename(projectRoot)
					}
				else
					return {
						success = true,
						found = false,
						message = err
					}
				end
			end
		end
	end
	return invalidArguments
end)
local AgentTools = require("Agent.Tools")
local AgentSession = require("Agent.AgentSession")
local GitJobs = { }
local gitTerminalState
gitTerminalState = function(status)
	if not (status and status.state) then
		return false
	end
	local _val_0 = status.state
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0
end
local gitInvalidRepoPath
gitInvalidRepoPath = function(repoPath)
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath)
end
local gitShellSplit
gitShellSplit = function(command)
	local args = { }
	local current = { }
	local quote = nil
	local escape = false
	for i = 1, #command do
		local ch = command:sub(i, i)
		if escape then
			current[#current + 1] = ch
			escape = false
		elseif ch == "\\" then
			escape = true
		elseif quote then
			if ch == quote then
				quote = nil
			else
				current[#current + 1] = ch
			end
		elseif ch == "'" or ch == '"' then
			quote = ch
		elseif ch:match("%s") then
			if #current > 0 then
				args[#args + 1] = table.concat(current)
				current = { }
			end
		else
			current[#current + 1] = ch
		end
	end
	if #current > 0 then
		args[#args + 1] = table.concat(current)
	end
	if args[1] == "git" then
		table.remove(args, 1)
	end
	return args
end
local gitQuote
gitQuote = function(value)
	local text = tostring(value)
	if text:match("^[%w%._%-%/]+$") then
		return text
	end
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\""
end
local gitDirNonEmpty
gitDirNonEmpty = function(targetPath)
	if not Content:exist(targetPath) then
		return false
	end
	if not Content:isdir(targetPath) then
		return false
	end
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0
end
local gitSafeChildPath
gitSafeChildPath = function(parentPath, childPath)
	if not (parentPath and childPath and childPath ~= "") then
		return nil
	end
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then
		return nil
	end
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then
		return nil
	end
	local targetPath = Path(parentPath, childPath)
	local relative = Path:getRelative(targetPath, parentPath)
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then
		return nil
	end
	return targetPath
end
local gitCloneDirFromURL
gitCloneDirFromURL = function(url)
	if not (url and url ~= "") then
		return nil
	end
	local text = tostring(url):match("^%s*(.-)%s*$")
	if text == "" then
		return nil
	end
	text = text:gsub("[/\\]+$", "")
	local name = text:match("([^/:]+)$")
	if not (name and name ~= "") then
		return nil
	end
	name = name:gsub("%.git$", "")
	if name == "" or name == "." or name == ".." then
		return nil
	end
	return name
end
local gitCloneTargetPath
gitCloneTargetPath = function(repoPath, command)
	local args = gitShellSplit(command)
	if not (args[1] == "clone") then
		return nil
	end
	local url = args[2]
	local index = 3
	while index <= #args do
		local arg = args[index]
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then
			index = index + 2
		elseif arg:sub(1, 1) == "-" then
			index = index + 1
		else
			return gitSafeChildPath(repoPath, arg)
		end
	end
	do
		local dirName = gitCloneDirFromURL(url)
		if dirName then
			return gitSafeChildPath(repoPath, dirName)
		end
	end
	return nil
end
local gitPathInsideRepo
gitPathInsideRepo = function(repoPath, relPath)
	if not (repoPath and relPath and relPath ~= "") then
		return false
	end
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then
		return false
	end
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then
		return false
	end
	local targetPath = Path(repoPath, relPath)
	local relative = Path:getRelative(targetPath, repoPath)
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\"
end
local gitHostFromURL
gitHostFromURL = function(url)
	if not (url and url ~= "") then
		return nil
	end
	local text = tostring(url):match("^%s*(.-)%s*$")
	if text == "" then
		return nil
	end
	local host = text:match("^[%w_%-]+://([^/:]+)")
	if not host then
		host = text:match("@([^:/]+)[:/]")
	end
	if not host then
		host = text:match("^([^:/]+):[^/]")
	end
	if not (host and host ~= "") then
		return nil
	end
	return string.lower(host)
end
local ensureGitTables
ensureGitTables = function()
	DB:exec([[		CREATE TABLE IF NOT EXISTS GitCredential(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			host TEXT NOT NULL,
			label TEXT NOT NULL,
			type TEXT NOT NULL,
			username TEXT NOT NULL DEFAULT '',
			secret TEXT NOT NULL DEFAULT '',
			created_at INTEGER,
			updated_at INTEGER,
			last_used_at INTEGER
		);
	]])
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);")
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]])
end
local gitCredentialToPublic
gitCredentialToPublic = function(row)
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8]
	return {
		id = id,
		host = host,
		label = label,
		type = typeName,
		username = username,
		createdAt = createdAt,
		updatedAt = updatedAt,
		lastUsedAt = lastUsedAt
	}
end
local gitLoadCredential
gitLoadCredential = function(id)
	ensureGitTables()
	local credentialId = tonumber(id) or 0
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", {
		credentialId
	})
	if not (rows and rows[1]) then
		return nil
	end
	local row = rows[1]
	return {
		id = row[1],
		host = row[2],
		label = row[3],
		type = row[4],
		username = row[5],
		secret = row[6]
	}
end
local gitAuthOptionsJSON
gitAuthOptionsJSON = function(credential)
	if not credential then
		return nil
	end
	local auth
	if credential.type == "token" then
		auth = {
			type = "token",
			token = credential.secret,
			username = credential.username ~= "" and credential.username or "token"
		}
	else
		auth = {
			type = "basic",
			username = credential.username,
			password = credential.secret
		}
	end
	return json.encode({
		auth = auth
	})
end
local gitLoadProfile
gitLoadProfile = function()
	ensureGitTables()
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1")
	if not (rows and rows[1]) then
		return nil
	end
	local name = tostring(rows[1][1] or "")
	local email = tostring(rows[1][2] or "")
	if name == "" and email == "" then
		return nil
	end
	return {
		name = name,
		email = email
	}
end
local _anon_func_2 = function(args, gitQuote)
	local _accum_0 = { }
	local _len_0 = 1
	for _index_0 = 1, #args do
		local arg = args[_index_0]
		_accum_0[_len_0] = gitQuote(arg)
		_len_0 = _len_0 + 1
	end
	return _accum_0
end
local gitApplyProfileToCommit
gitApplyProfileToCommit = function(command)
	local args = gitShellSplit(command)
	if not (args[1] == "commit") then
		return command
	end
	local hasName = false
	local hasEmail = false
	for _index_0 = 1, #args do
		local arg = args[_index_0]
		if arg == "--author-name" then
			hasName = true
		end
		if arg == "--author-email" then
			hasEmail = true
		end
	end
	if hasName and hasEmail then
		return command
	end
	local profile = gitLoadProfile()
	if not profile then
		return command
	end
	if not hasName and profile.name ~= "" then
		args[#args + 1] = "--author-name"
		args[#args + 1] = profile.name
	end
	if not hasEmail and profile.email ~= "" then
		args[#args + 1] = "--author-email"
		args[#args + 1] = profile.email
	end
	return table.concat(_anon_func_2(args, gitQuote), " ")
end
local gitStartJob
gitStartJob = function(repoPath, command, optionsJSON)
	if optionsJSON == nil then
		optionsJSON = nil
	end
	if gitInvalidRepoPath(repoPath) then
		return nil, "invalid repoPath"
	end
	if not (command and command ~= "") then
		return nil, "invalid command"
	end
	if not optionsJSON then
		optionsJSON = ""
	end
	command = gitApplyProfileToCommit(command)
	do
		local targetPath = gitCloneTargetPath(repoPath, command)
		if targetPath then
			if gitDirNonEmpty(targetPath) then
				return nil, "clone target directory is not empty"
			end
		elseif (gitShellSplit(command))[1] == "clone" then
			return nil, "invalid clone target"
		end
	end
	local statusRef = nil
	local startGit
	startGit = function()
		return Git:run(repoPath, command, (function(status)
			statusRef = status
			GitJobs[status.id] = {
				command = command,
				status = status,
				updatedAt = os.time()
			}
		end), optionsJSON)
	end
	local success, jobId = pcall(startGit)
	if not success then
		return nil, tostring(jobId)
	end
	if not jobId then
		return nil, "Git.run did not return a job id"
	end
	GitJobs[jobId] = {
		command = command,
		status = statusRef or {
			id = jobId,
			state = "queued",
			kind = gitShellSplit(command)[1] or "status",
			repoPath = repoPath,
			progress = 0,
			message = "queued"
		},
		updatedAt = os.time()
	}
	return jobId
end
local gitRunSync
gitRunSync = function(repoPath, command, optionsJSON, timeout)
	if optionsJSON == nil then
		optionsJSON = nil
	end
	if timeout == nil then
		timeout = 20
	end
	local jobId, err = gitStartJob(repoPath, command, optionsJSON)
	if not jobId then
		return {
			success = false,
			message = err
		}
	end
	local startedAt = os.time()
	wait(function()
		local job = GitJobs[jobId]
		local status = job and job.status
		return gitTerminalState(status) or os.time() - startedAt >= timeout
	end)
	local status = GitJobs[jobId] and GitJobs[jobId].status
	if not gitTerminalState(status) then
		Git:cancel(jobId)
		return {
			success = false,
			message = "git command timed out",
			jobId = jobId,
			status = status
		}
	end
	return {
		success = status.state == "done",
		jobId = jobId,
		status = status,
		message = status.error or status.message
	}
end
local gitCredentialsForHost
gitCredentialsForHost = function(host)
	if not (host and host ~= "") then
		return { }
	end
	ensureGitTables()
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", {
		host
	})
	if rows then
		local _accum_0 = { }
		local _len_0 = 1
		for _index_0 = 1, #rows do
			local row = rows[_index_0]
			_accum_0[_len_0] = gitCredentialToPublic(row)
			_len_0 = _len_0 + 1
		end
		return _accum_0
	else
		return { }
	end
end
local gitFirstRemoteURL
gitFirstRemoteURL = function(repoPath, remoteName)
	if remoteName == nil then
		remoteName = nil
	end
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10)
	local data = remoteRes.status and remoteRes.status.data
	if not (data and data.remotes) then
		return nil
	end
	local _list_0 = data.remotes
	for _index_0 = 1, #_list_0 do
		local remote = _list_0[_index_0]
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then
			return remote.urls[1]
		end
	end
	return nil
end
local gitConfigRemoteURL
gitConfigRemoteURL = function(repoPath, remoteName)
	if remoteName == nil then
		remoteName = nil
	end
	if gitInvalidRepoPath(repoPath) then
		return nil
	end
	local configPath = Path(repoPath, ".git/config")
	if not Content:exist(configPath) then
		return nil
	end
	local content = Content:load(configPath)
	if not (content and content ~= "") then
		return nil
	end
	local currentRemote = nil
	for line in content:gmatch("[^\r\n]+") do
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$')
		if sectionRemote then
			currentRemote = sectionRemote
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then
			local url = line:match("^%s*url%s*=%s*(.-)%s*$")
			if url and url ~= "" then
				return url
			end
		end
	end
	return nil
end
local gitCommandRemoteArg
gitCommandRemoteArg = function(args, startIndex)
	if startIndex == nil then
		startIndex = 2
	end
	local index = startIndex
	while index <= #args do
		local arg = args[index]
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then
			index = index + 1
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then
			index = index + 2
		elseif arg and arg:sub(1, 1) == "-" then
			index = index + 1
		else
			return arg
		end
	end
	return nil
end
local gitCommandHost
gitCommandHost = function(repoPath, command)
	local args = gitShellSplit(command)
	if not args[1] then
		return nil
	end
	do
		local _exp_0 = args[1]
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then
			return gitHostFromURL(args[2])
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then
			local remoteArg = gitCommandRemoteArg(args, 2)
			if not remoteArg then
				return nil
			end
			local url = gitHostFromURL(remoteArg)
			if url then
				return url
			end
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg))
		end
	end
	return nil
end
local gitAuthSelectionForCommand
gitAuthSelectionForCommand = function(repoPath, command)
	local host = gitCommandHost(repoPath, command)
	if not host then
		return nil
	end
	local items = gitCredentialsForHost(host)
	if #items == 0 then
		return nil
	end
	return {
		host = host,
		items = items
	}
end
local gitDefaultRemote
gitDefaultRemote = function(remoteStatus)
	local data = remoteStatus and remoteStatus.data
	if not (data and data.remotes and data.remotes[1]) then
		return nil
	end
	return data.remotes[1]
end
local gitCurrentBranch
gitCurrentBranch = function(branchStatus)
	local data = branchStatus and branchStatus.data
	if data and data.current and data.current ~= "" then
		return data.current
	end
	if data and data.branches then
		local _list_0 = data.branches
		for _index_0 = 1, #_list_0 do
			local branch = _list_0[_index_0]
			if branch.current then
				return branch.name
			end
		end
	end
	return nil
end
local gitHeadBranch
gitHeadBranch = function(repoPath)
	if gitInvalidRepoPath(repoPath) then
		return nil
	end
	local headPath = Path(repoPath, ".git", "HEAD")
	if not Content:exist(headPath) then
		return nil
	end
	local head = Content:load(headPath)
	if not head then
		return nil
	end
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$")
	if branch and branch ~= "" then
		return branch
	end
	return nil
end
local gitBranchesWithHead
gitBranchesWithHead = function(branchStatus, currentBranch)
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { }
	if not (currentBranch and currentBranch ~= "") then
		return branches
	end
	for _index_0 = 1, #branches do
		local branch = branches[_index_0]
		if branch.name == currentBranch then
			return branches
		end
	end
	local withHead
	do
		local _accum_0 = { }
		local _len_0 = 1
		for _index_0 = 1, #branches do
			local branch = branches[_index_0]
			_accum_0[_len_0] = branch
			_len_0 = _len_0 + 1
		end
		withHead = _accum_0
	end
	withHead[#withHead + 1] = {
		name = currentBranch,
		current = true,
		unborn = true
	}
	return withHead
end
local gitStatusMeansNotRepo
gitStatusMeansNotRepo = function(statusRes)
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or ""
	message = tostring(message):lower()
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true)
end
local gitSummary
gitSummary = function(repoPath)
	local statusRes = gitRunSync(repoPath, "status", nil, 120)
	if not statusRes.success then
		if gitStatusMeansNotRepo(statusRes) then
			return {
				success = true,
				isRepo = false,
				message = statusRes.message,
				status = statusRes.status
			}
		end
		return {
			success = false,
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository",
			status = statusRes.status
		}
	end
	local branchRes = gitRunSync(repoPath, "branch", nil, 120)
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120)
	local status = statusRes.status
	local branchStatus = branchRes.status
	local remoteStatus = remoteRes.status
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath)
	local branches = gitBranchesWithHead(branchStatus, currentBranch)
	local logRes = gitRunSync(repoPath, "log -n 100", nil, 120)
	local logStatus
	if logRes.success then
		logStatus = logRes.status
	else
		logStatus = {
			state = "done",
			kind = "log",
			repoPath = repoPath,
			progress = 1,
			message = "git log completed",
			data = {
				commits = { }
			}
		}
	end
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil
	local tagStatus
	if hasCommit then
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status
	else
		tagStatus = {
			state = "done",
			kind = "tag",
			repoPath = repoPath,
			progress = 1,
			message = "git tag completed",
			data = {
				tags = { }
			}
		}
	end
	local defaultRemote = gitDefaultRemote(remoteStatus)
	local lastCommit = nil
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then
		lastCommit = logStatus.data.commits[1]
	end
	return {
		success = true,
		isRepo = true,
		clean = status.data and status.data.clean or false,
		currentBranch = currentBranch,
		defaultRemote = defaultRemote,
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { },
		branches = branches,
		lastCommit = lastCommit,
		status = status,
		branchStatus = branchStatus,
		remoteStatus = remoteStatus,
		historyStatus = logStatus,
		tagStatus = tagStatus
	}
end
HttpServer:post("/git/run", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON
				if authId and not optionsJSON then
					local credential = gitLoadCredential(authId)
					if credential then
						optionsJSON = gitAuthOptionsJSON(credential)
						DB:exec("update GitCredential set last_used_at = ? where id = ?", {
							os.time(),
							credential.id
						})
					end
				elseif not optionsJSON then
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command)
					if not authOk then
						authSelection = nil
					end
					if authSelection then
						if #authSelection.items == 1 then
							local credential = gitLoadCredential(authSelection.items[1].id)
							optionsJSON = gitAuthOptionsJSON(credential)
							DB:exec("update GitCredential set last_used_at = ? where id = ?", {
								os.time(),
								credential.id
							})
						else
							return {
								success = false,
								message = "select a Git credential",
								needsCredentialSelection = true,
								host = authSelection.host,
								credentials = authSelection.items
							}
						end
					end
				end
				local jobId, err = gitStartJob(repoPath, command, optionsJSON)
				if not jobId then
					return {
						success = false,
						message = err
					}
				end
				return {
					success = true,
					jobId = jobId
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/git/status", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local jobId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					jobId = _obj_0.jobId
				end
			end
			if jobId ~= nil then
				local job = GitJobs[tonumber(jobId) or 0]
				if not job then
					return {
						success = false,
						message = "git job not found"
					}
				end
				return {
					success = true,
					status = job.status,
					command = job.command
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/git/cancel", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local jobId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					jobId = _obj_0.jobId
				end
			end
			if jobId ~= nil then
				local id = tonumber(jobId)
				if not id then
					return {
						success = false,
						message = "invalid jobId"
					}
				end
				return {
					success = Git:cancel(id)
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/summary", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local repoPath
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					repoPath = _obj_0.repoPath
				end
			end
			if repoPath ~= nil then
				if gitInvalidRepoPath(repoPath) then
					return {
						success = false,
						message = "invalid repoPath"
					}
				end
				return gitSummary(repoPath)
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/status-files", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local repoPath
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					repoPath = _obj_0.repoPath
				end
			end
			if repoPath ~= nil then
				return gitRunSync(repoPath, "status", nil, 10)
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/discard-untracked", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, paths = body.repoPath, body.paths
				if gitInvalidRepoPath(repoPath) then
					return {
						success = false,
						message = "invalid repoPath"
					}
				end
				if not (type(paths) == "table") then
					return {
						success = false,
						message = "invalid paths"
					}
				end
				local statusRes = gitRunSync(repoPath, "status", nil, 10)
				if not statusRes.success then
					return statusRes
				end
				local untracked = { }
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { })
				for _index_0 = 1, #_list_0 do
					local file = _list_0[_index_0]
					if file.staging == "?" or file.worktree == "?" then
						untracked[file.path] = true
					end
				end
				local removed = { }
				for _index_0 = 1, #paths do
					local relPath = paths[_index_0]
					relPath = tostring(relPath)
					if not gitPathInsideRepo(repoPath, relPath) then
						return {
							success = false,
							message = "unsafe path: " .. tostring(relPath)
						}
					end
					if not untracked[relPath] then
						return {
							success = false,
							message = "path is not untracked: " .. tostring(relPath)
						}
					end
				end
				for _index_0 = 1, #paths do
					local relPath = paths[_index_0]
					local targetPath = Path(repoPath, tostring(relPath))
					if Content:exist(targetPath) then
						Content:remove(targetPath)
						removed[#removed + 1] = tostring(relPath)
					end
				end
				return {
					success = true,
					removed = removed
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/file-diff", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, path, staged = body.repoPath, body.path, body.staged
				if gitInvalidRepoPath(repoPath) then
					return {
						success = false,
						message = "invalid repoPath"
					}
				end
				if not gitPathInsideRepo(repoPath, tostring(path)) then
					return {
						success = false,
						message = "unsafe path"
					}
				end
				local command
				if staged == true then
					command = "diff --staged -- " .. tostring(gitQuote(path))
				else
					command = "diff -- " .. tostring(gitQuote(path))
				end
				local res = gitRunSync(repoPath, command, nil, 10)
				if not res.success then
					return res
				end
				return {
					success = true,
					status = res.status,
					data = res.status and res.status.data
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/commit-file-diff", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, commit, path = body.repoPath, body.commit, body.path
				if gitInvalidRepoPath(repoPath) then
					return {
						success = false,
						message = "invalid repoPath"
					}
				end
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then
					return {
						success = false,
						message = "invalid commit"
					}
				end
				if not gitPathInsideRepo(repoPath, tostring(path)) then
					return {
						success = false,
						message = "unsafe path"
					}
				end
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10)
				if not res.success then
					return res
				end
				return {
					success = true,
					status = res.status,
					data = res.status and res.status.data
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/history", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, limit = body.repoPath, body.limit
				limit = math.max(1, math.min(100, tonumber(limit) or 20))
				return gitRunSync(repoPath, "log -n " .. tostring(limit), nil, 10)
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/remotes", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, command = body.repoPath, body.command
				command = command or "remote -v"
				return gitRunSync(repoPath, command, nil, 10)
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/branches", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, command = body.repoPath, body.command
				command = command or "branch"
				return gitRunSync(repoPath, command, nil, 10)
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/tags", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, command = body.repoPath, body.command
				command = command or "tag"
				return gitRunSync(repoPath, command, nil, 10)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/git/profile/get", function()
	ensureGitTables()
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1")
	local profile
	if rows and rows[1] then
		profile = {
			name = rows[1][1],
			email = rows[1][2]
		}
	else
		profile = {
			name = "",
			email = ""
		}
	end
	return {
		success = true,
		profile = profile
	}
end)
HttpServer:post("/git/profile/save", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local name
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					name = _obj_0.name
				end
			end
			local email
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					email = _obj_0.email
				end
			end
			if name ~= nil and email ~= nil then
				ensureGitTables()
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", {
					tostring(name or ""),
					tostring(email or ""),
					os.time()
				})
				return {
					success = true
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/git/auth/list", function(req)
	ensureGitTables()
	local host = nil
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				host = body.host
			end
		end
	end
	local rows
	if host and host ~= "" then
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", {
			tostring(host):lower()
		})
	else
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc")
	end
	local items
	if rows then
		local _accum_0 = { }
		local _len_0 = 1
		for _index_0 = 1, #rows do
			local row = rows[_index_0]
			_accum_0[_len_0] = gitCredentialToPublic(row)
			_len_0 = _len_0 + 1
		end
		items = _accum_0
	else
		items = { }
	end
	return {
		success = true,
		items = items
	}
end)
HttpServer:postSchedule("/git/auth/match", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		local _match_0 = false
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				_match_0 = true
				local repoPath, command, url = body.repoPath, body.command, body.url
				local host
				if url and url ~= "" then
					host = gitHostFromURL(url)
				else
					host = gitCommandHost(repoPath, command)
				end
				if not host then
					return {
						success = false,
						message = "git host is required"
					}
				end
				local items = gitCredentialsForHost(host)
				return {
					success = true,
					host = host,
					items = items,
					needsSelection = #items > 1,
					authId = (#items == 1 and items[1].id or nil)
				}
			end
		end
		if not _match_0 then
			return {
				success = false,
				message = "invalid arguments"
			}
		end
	end
	return invalidArguments
end)
HttpServer:post("/git/auth/save", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$")
				label = tostring(label or ""):match("^%s*(.-)%s*$")
				local credentialType = tostring(body.type or "token")
				username = tostring(username or "")
				local secret
				if credentialType == "basic" then
					secret = tostring(password or "")
				else
					secret = tostring(token or password or "")
				end
				if host == "" then
					return {
						success = false,
						message = "host is required"
					}
				end
				if label == "" then
					return {
						success = false,
						message = "label is required"
					}
				end
				if secret == "" then
					return {
						success = false,
						message = "secret is required"
					}
				end
				if not (("basic" == credentialType or "token" == credentialType)) then
					return {
						success = false,
						message = "invalid type"
					}
				end
				ensureGitTables()
				local now = os.time()
				if id then
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", {
						host,
						label,
						credentialType,
						username,
						secret,
						now,
						(tonumber(id) or 0)
					})
					return {
						success = true,
						id = tonumber(id)
					}
				else
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", {
						host,
						label,
						credentialType,
						username,
						secret,
						now,
						now
					})
					local rows = DB:query("select last_insert_rowid()")
					return {
						success = true,
						id = rows and rows[1] and rows[1][1]
					}
				end
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/git/auth/delete", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local id
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					id = _obj_0.id
				end
			end
			if id ~= nil then
				ensureGitTables()
				local credentialId = tonumber(id) or 0
				DB:exec("delete from GitCredential where id = ?", {
					credentialId
				})
				return {
					success = true
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:postSchedule("/git/auth/test", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local repoPath, url, authId = body.repoPath, body.url, body.authId
				local credential = gitLoadCredential(authId)
				local optionsJSON = gitAuthOptionsJSON(credential)
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/session/create", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local projectRoot
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					projectRoot = _obj_0.projectRoot
				end
			end
			local title
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					title = _obj_0.title
				end
			end
			if projectRoot ~= nil and title ~= nil then
				return AgentSession.createSession(projectRoot, title)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/session/create-sub", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local parentSessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					parentSessionId = _obj_0.parentSessionId
				end
			end
			local title
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					title = _obj_0.title
				end
			end
			if parentSessionId ~= nil and title ~= nil then
				return AgentSession.createSubSession(parentSessionId, title)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/session/get", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local sessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			if sessionId ~= nil then
				return AgentSession.getSession(sessionId)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/session/send", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local sessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			local prompt
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					prompt = _obj_0.prompt
				end
			end
			if sessionId ~= nil and prompt ~= nil then
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/session/resend", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local sessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			local messageId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					messageId = _obj_0.messageId
				end
			end
			local prompt
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					prompt = _obj_0.prompt
				end
			end
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/task/status", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local sessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			if sessionId ~= nil then
				local res = AgentSession.getSession(sessionId)
				if not res.success then
					return res
				end
				local taskId = res.session.currentTaskId
				local checkpoints
				if taskId then
					checkpoints = AgentTools.listCheckpoints(taskId)
				else
					checkpoints = { }
				end
				return {
					success = true,
					session = res.session,
					relatedSessions = res.relatedSessions,
					spawnInfo = res.spawnInfo,
					messages = res.messages,
					steps = res.steps,
					checkpoints = checkpoints
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/task/running", function()
	local res = AgentSession.listRunningSessions()
	if res.success and #res.sessions == 0 then
		res.sessions = nil
	end
	return res
end)
HttpServer:post("/agent/task/stop", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local sessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			if sessionId ~= nil then
				return AgentSession.stopSessionTask(sessionId)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/checkpoint/list", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local taskId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					taskId = _obj_0.taskId
				end
			end
			local sessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			if sessionId ~= nil then
				if not taskId and sessionId then
					taskId = AgentSession.getCurrentTaskId(sessionId)
				end
				if not taskId then
					return {
						success = false,
						message = "task not found"
					}
				end
				return {
					success = true,
					taskId = taskId,
					checkpoints = AgentTools.listCheckpoints(taskId)
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/checkpoint/diff", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local checkpointId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					checkpointId = _obj_0.checkpointId
				end
			end
			if checkpointId ~= nil then
				if not (checkpointId > 0) then
					return {
						success = false,
						message = "invalid checkpointId"
					}
				end
				return AgentTools.getCheckpointDiff(checkpointId)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/task/diff", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local taskId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					taskId = _obj_0.taskId
				end
			end
			if taskId ~= nil then
				if not (taskId > 0) then
					return {
						success = false,
						message = "invalid taskId"
					}
				end
				return AgentTools.getTaskChangeSetDiff(taskId)
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/checkpoint/rollback", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local sessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			local checkpointId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					checkpointId = _obj_0.checkpointId
				end
			end
			if sessionId ~= nil and checkpointId ~= nil then
				if not (checkpointId > 0) then
					return {
						success = false,
						message = "invalid checkpointId"
					}
				end
				local res = AgentSession.getSession(sessionId)
				if not res.success then
					return res
				end
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot)
				if not rollbackRes.success then
					return rollbackRes
				end
				return {
					success = true,
					checkpointId = rollbackRes.checkpointId
				}
			end
		end
	end
	return invalidArguments
end)
HttpServer:post("/agent/task/rollback", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local sessionId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					sessionId = _obj_0.sessionId
				end
			end
			local taskId
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					taskId = _obj_0.taskId
				end
			end
			if sessionId ~= nil and taskId ~= nil then
				if not (taskId > 0) then
					return {
						success = false,
						message = "invalid taskId"
					}
				end
				local res = AgentSession.getSession(sessionId)
				if not res.success then
					return res
				end
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot)
				if not rollbackRes.success then
					return rollbackRes
				end
				return {
					success = true,
					taskId = rollbackRes.taskId,
					checkpointId = rollbackRes.checkpointId,
					checkpointCount = rollbackRes.checkpointCount
				}
			end
		end
	end
	return invalidArguments
end)
local getSearchPath
getSearchPath = function(file)
	do
		local dir = getProjectDirFromFile(file)
		if dir then
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua")
		end
	end
	return ""
end
local getSearchFolders
getSearchFolders = function(file)
	do
		local dir = getProjectDirFromFile(file)
		if dir then
			return {
				Path(dir, "Script"),
				dir
			}
		end
	end
	return { }
end
local disabledCheckForLua = {
	"incompatible number of returns",
	"unknown",
	"cannot index",
	"module not found",
	"don't know how to resolve",
	"ContainerItem",
	"cannot resolve a type",
	"invalid key",
	"inconsistent index type",
	"cannot use operator",
	"attempting ipairs loop",
	"expects record or nominal",
	"variable is not being assigned",
	"<invalid type>",
	"<any type>",
	"using the '#' operator",
	"can't match a record",
	"redeclaration of variable",
	"cannot apply pairs",
	"not a function",
	"to%-be%-closed"
}
local yueCheck
yueCheck = function(file, content, lax)
	local isTIC80, tic80APIs = CheckTIC80Code(content)
	if isTIC80 then
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")")
	end
	local searchPath = getSearchPath(file)
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax)
	local info = { }
	local globals = { }
	for _index_0 = 1, #checkResult do
		local _des_0 = checkResult[_index_0]
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4]
		if "error" == t then
			info[#info + 1] = {
				"syntax",
				file,
				line,
				col,
				msg
			}
		elseif "global" == t then
			globals[#globals + 1] = {
				msg,
				line,
				col
			}
		end
	end
	if luaCodes then
		local success, lintResult = LintYueGlobals(luaCodes, globals, false)
		if success then
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n")
			if not (lintResult == "") then
				lintResult = lintResult .. "\n"
			end
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes
		else
			for _index_0 = 1, #lintResult do
				local _des_0 = lintResult[_index_0]
				local name, line, col = _des_0[1], _des_0[2], _des_0[3]
				if isTIC80 and tic80APIs[name] then
					goto _continue_0
				end
				info[#info + 1] = {
					"syntax",
					file,
					line,
					col,
					"invalid global variable"
				}
				::_continue_0::
			end
		end
	end
	return luaCodes, info
end
local luaCheck
luaCheck = function(file, content)
	local res, err = load(content, "check")
	if not res then
		local line, msg = err:match(".*:(%d+):%s*(.*)")
		return {
			success = false,
			info = {
				{
					"syntax",
					file,
					tonumber(line),
					0,
					msg
				}
			}
		}
	end
	local success, info = teal.checkAsync(content, file, true, "")
	if info then
		do
			local _accum_0 = { }
			local _len_0 = 1
			for _index_0 = 1, #info do
				local item = info[_index_0]
				local useCheck = true
				if not item[5]:match("unused") then
					for _index_1 = 1, #disabledCheckForLua do
						local check = disabledCheckForLua[_index_1]
						if item[5]:match(check) then
							useCheck = false
						end
					end
				end
				if not useCheck then
					goto _continue_0
				end
				do
					local _exp_0 = item[1]
					if "type" == _exp_0 then
						item[1] = "warning"
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then
						goto _continue_0
					end
				end
				_accum_0[_len_0] = item
				_len_0 = _len_0 + 1
				::_continue_0::
			end
			info = _accum_0
		end
		if #info == 0 then
			info = nil
			success = true
		end
	end
	return {
		success = success,
		info = info
	}
end
local luaCheckWithLineInfo
luaCheckWithLineInfo = function(file, luaCodes)
	local res = luaCheck(file, luaCodes)
	local info = { }
	if not res.success then
		local current = 1
		local lastLine = 1
		local lineMap = { }
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do
			local num = lineCode:match("--%s*(%d+)%s*$")
			if num then
				lastLine = tonumber(num)
			end
			lineMap[current] = lastLine
			current = current + 1
		end
		local _list_0 = res.info
		for _index_0 = 1, #_list_0 do
			local item = _list_0[_index_0]
			item[3] = lineMap[item[3]] or 0
			item[4] = 0
			info[#info + 1] = item
		end
		return false, info
	end
	return true, info
end
local getCompiledYueLine
getCompiledYueLine = function(content, line, row, file, lax)
	local luaCodes = yueCheck(file, content, lax)
	if not luaCodes then
		return nil
	end
	local current = 1
	local lastLine = 1
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$")
	local targetRow = nil
	local lineMap = { }
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do
		local num = lineCode:match("--%s*(%d+)%s*$")
		if num then
			lastLine = tonumber(num)
		end
		lineMap[current] = lastLine
		if row <= lastLine and not targetRow then
			targetRow = current
			break
		end
		current = current + 1
	end
	targetRow = current
	if targetLine and targetRow then
		return luaCodes, targetLine, targetRow, lineMap
	else
		return nil
	end
end
HttpServer:postSchedule("/check", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local file
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					file = _obj_0.file
				end
			end
			local content
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					content = _obj_0.content
				end
			end
			if file ~= nil and content ~= nil then
				local ext = Path:getExt(file)
				if "tl" == ext then
					local searchPath = getSearchPath(file)
					do
						local isTIC80 = CheckTIC80Code(content)
						if isTIC80 then
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")")
						end
					end
					local success, info = teal.checkAsync(content, file, false, searchPath)
					return {
						success = success,
						info = info
					}
				elseif "lua" == ext then
					do
						local isTIC80 = CheckTIC80Code(content)
						if isTIC80 then
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")")
						end
					end
					return luaCheck(file, content)
				elseif "yue" == ext then
					local luaCodes, info = yueCheck(file, content, false)
					local success = false
					if luaCodes then
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes)
						do
							local _tab_1 = { }
							local _idx_0 = #_tab_1 + 1
							for _index_0 = 1, #info do
								local _value_0 = info[_index_0]
								_tab_1[_idx_0] = _value_0
								_idx_0 = _idx_0 + 1
							end
							local _idx_1 = #_tab_1 + 1
							for _index_0 = 1, #luaInfo do
								local _value_0 = luaInfo[_index_0]
								_tab_1[_idx_1] = _value_0
								_idx_1 = _idx_1 + 1
							end
							info = _tab_1
						end
						success = success and luaSuccess
					end
					if #info > 0 then
						return {
							success = success,
							info = info
						}
					else
						return {
							success = success
						}
					end
				elseif "xml" == ext then
					local success, result = xml.check(content)
					if success then
						local info
						success, info = luaCheckWithLineInfo(file, result)
						if #info > 0 then
							return {
								success = success,
								info = info
							}
						else
							return {
								success = success
							}
						end
					else
						local info
						do
							local _accum_0 = { }
							local _len_0 = 1
							for _index_0 = 1, #result do
								local _des_0 = result[_index_0]
								local row, err = _des_0[1], _des_0[2]
								_accum_0[_len_0] = {
									"syntax",
									file,
									row,
									0,
									err
								}
								_len_0 = _len_0 + 1
							end
							info = _accum_0
						end
						return {
							success = false,
							info = info
						}
					end
				end
			end
		end
	end
	return {
		success = true
	}
end)
HttpServer:post("/body/parse", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local file
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					file = _obj_0.file
				end
			end
			local content
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					content = _obj_0.content
				end
			end
			if file ~= nil and content ~= nil then
				if not (file:sub(-6) == ".b.lua") then
					return {
						success = false,
						phase = "request",
						message = "only .b.lua files can be converted"
					}
				end
				local loader, err = load("_ENV = {}\n" .. content)
				if not loader then
					return {
						success = false,
						phase = "parse",
						message = tostring(err)
					}
				end
				local ok, data = pcall(loader)
				if not ok then
					return {
						success = false,
						phase = "execute",
						message = tostring(data)
					}
				end
				if not ("table" == type(data) and data[1] == "Array") then
					return {
						success = false,
						phase = "validate",
						message = "body lua root must be {\"Array\", ...}"
					}
				end
				local text, jsonErr = json.encode(data, false, true)
				if not text then
					return {
						success = false,
						phase = "encode",
						message = tostring(jsonErr)
					}
				end
				return {
					success = true,
					json = text
				}
			end
		end
	end
	return {
		success = false,
		phase = "request",
		message = "invalid request"
	}
end)
local updateInferedDesc
updateInferedDesc = function(infered)
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then
		return
	end
	local key, row = infered.key, infered.row
	local codes = Content:loadAsync(key)
	if codes then
		local comments = { }
		local line = 0
		local skipping = false
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do
			line = line + 1
			if line >= row then
				break
			end
			if lineCode:match("^%s*%-%- @") then
				skipping = true
				goto _continue_0
			end
			local result = lineCode:match("^%s*%-%- (.+)")
			if result then
				if not skipping then
					comments[#comments + 1] = result
				end
			elseif #comments > 0 then
				comments = { }
				skipping = false
			end
			::_continue_0::
		end
		infered.doc = table.concat(comments, "\n")
	end
end
HttpServer:postSchedule("/infer", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local lang
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					lang = _obj_0.lang
				end
			end
			local file
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					file = _obj_0.file
				end
			end
			local content
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					content = _obj_0.content
				end
			end
			local line
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					line = _obj_0.line
				end
			end
			local row
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					row = _obj_0.row
				end
			end
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then
				local searchPath = getSearchPath(file)
				if "tl" == lang or "lua" == lang then
					if CheckTIC80Code(content) then
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")")
					end
					local infered = teal.inferAsync(content, line, row, searchPath)
					if (infered ~= nil) then
						updateInferedDesc(infered)
						return {
							success = true,
							infered = infered
						}
					end
				elseif "yue" == lang then
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true)
					if not luaCodes then
						return {
							success = false
						}
					end
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath)
					if (infered ~= nil) then
						local col
						file, row, col = infered.file, infered.row, infered.col
						if file == "" and row > 0 and col > 0 then
							infered.row = lineMap[row] or 0
							infered.col = 0
						end
						updateInferedDesc(infered)
						return {
							success = true,
							infered = infered
						}
					end
				end
			end
		end
	end
	return {
		success = false
	}
end)
local _anon_func_3 = function(doc)
	local _accum_0 = { }
	local _len_0 = 1
	local _list_0 = doc.params
	for _index_0 = 1, #_list_0 do
		local param = _list_0[_index_0]
		_accum_0[_len_0] = param.name
		_len_0 = _len_0 + 1
	end
	return _accum_0
end
local getParamDocs
getParamDocs = function(signatures)
	do
		local codes = Content:loadAsync(signatures[1].file)
		if codes then
			local comments = { }
			local params = { }
			local line = 0
			local docs = { }
			local returnType = nil
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do
				line = line + 1
				local needBreak = true
				for i, _des_0 in ipairs(signatures) do
					local row = _des_0.row
					if line >= row and not (docs[i] ~= nil) then
						if #comments > 0 or #params > 0 or returnType then
							docs[i] = {
								doc = table.concat(comments, "  \n"),
								returnType = returnType
							}
							if #params > 0 then
								docs[i].params = params
							end
						else
							docs[i] = false
						end
					end
					if not docs[i] then
						needBreak = false
					end
				end
				if needBreak then
					break
				end
				local result = lineCode:match("%s*%-%- (.+)")
				if result then
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)")
					if not name then
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)")
					end
					if name then
						local pname = name
						if desc:match("%[optional%]") or desc:match("%[可选%]") then
							pname = pname .. "?"
						end
						params[#params + 1] = {
							name = tostring(pname) .. ": " .. tostring(typ),
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc)
						}
					else
						typ = result:match("^@return%s*%(([^%)]-)%)")
						if typ then
							if returnType then
								returnType = returnType .. ", " .. typ
							else
								returnType = typ
							end
							result = result:gsub("@return", "**return:**")
						end
						comments[#comments + 1] = result
					end
				elseif #comments > 0 then
					comments = { }
					params = { }
					returnType = nil
				end
			end
			local results = { }
			for _index_0 = 1, #docs do
				local doc = docs[_index_0]
				if not doc then
					goto _continue_0
				end
				if doc.params then
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")"
				else
					doc.desc = "function()"
				end
				if doc.returnType then
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType)
					doc.returnType = nil
				end
				results[#results + 1] = doc
				::_continue_0::
			end
			if #results > 0 then
				return results
			else
				return nil
			end
		end
	end
	return nil
end
HttpServer:postSchedule("/signature", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local lang
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					lang = _obj_0.lang
				end
			end
			local file
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					file = _obj_0.file
				end
			end
			local content
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					content = _obj_0.content
				end
			end
			local line
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					line = _obj_0.line
				end
			end
			local row
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					row = _obj_0.row
				end
			end
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then
				local searchPath = getSearchPath(file)
				if "tl" == lang or "lua" == lang then
					if CheckTIC80Code(content) then
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")")
					end
					local signatures = teal.getSignatureAsync(content, line, row, searchPath)
					if signatures then
						signatures = getParamDocs(signatures)
						if signatures then
							return {
								success = true,
								signatures = signatures
							}
						end
					end
				elseif "yue" == lang then
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true)
					if not luaCodes then
						return {
							success = false
						}
					end
					do
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$")
						if chainOp then
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)")
							if withVar then
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall
							end
						end
					end
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath)
					if signatures then
						signatures = getParamDocs(signatures)
						if signatures then
							return {
								success = true,
								signatures = signatures
							}
						end
					else
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath)
						if signatures then
							signatures = getParamDocs(signatures)
							if signatures then
								return {
									success = true,
									signatures = signatures
								}
							end
						end
					end
				end
			end
		end
	end
	return {
		success = false
	}
end)
local luaKeywords = {
	'and',
	'break',
	'do',
	'else',
	'elseif',
	'end',
	'false',
	'for',
	'function',
	'goto',
	'if',
	'in',
	'local',
	'nil',
	'not',
	'or',
	'repeat',
	'return',
	'then',
	'true',
	'until',
	'while'
}
local tealKeywords = {
	'record',
	'as',
	'is',
	'type',
	'embed',
	'enum',
	'global',
	'any',
	'boolean',
	'integer',
	'number',
	'string',
	'thread'
}
local yueKeywords = {
	"and",
	"break",
	"do",
	"else",
	"elseif",
	"false",
	"for",
	"goto",
	"if",
	"in",
	"local",
	"nil",
	"not",
	"or",
	"repeat",
	"return",
	"then",
	"true",
	"until",
	"while",
	"as",
	"class",
	"continue",
	"export",
	"extends",
	"from",
	"global",
	"import",
	"macro",
	"switch",
	"try",
	"unless",
	"using",
	"when",
	"with"
}
local _anon_func_4 = function(f)
	local _val_0 = Path:getExt(f)
	return "ttf" == _val_0 or "otf" == _val_0
end
local _anon_func_5 = function(suggestions)
	local _tbl_0 = { }
	for _index_0 = 1, #suggestions do
		local item = suggestions[_index_0]
		_tbl_0[item[1] .. item[2]] = item
	end
	return _tbl_0
end
HttpServer:postSchedule("/complete", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local lang
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					lang = _obj_0.lang
				end
			end
			local file
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					file = _obj_0.file
				end
			end
			local content
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					content = _obj_0.content
				end
			end
			local line
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					line = _obj_0.line
				end
			end
			local row
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					row = _obj_0.row
				end
			end
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then
				local searchPath = getSearchPath(file)
				repeat
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$")
					if lang == "yue" then
						if not item then
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$")
						end
						if not item then
							item = line:match("import%s*['\"]([%w%d-_%.]*)$")
						end
					end
					local searchType = nil
					if not item then
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$")
						if lang == "yue" then
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$")
						end
						if (item ~= nil) then
							searchType = "Image"
						end
					end
					if not item then
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$")
						if lang == "yue" then
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$")
						end
						if (item ~= nil) then
							searchType = "Font"
						end
					end
					if not item then
						break
					end
					local searchPaths = Content.searchPaths
					local _list_0 = getSearchFolders(file)
					for _index_0 = 1, #_list_0 do
						local folder = _list_0[_index_0]
						searchPaths[#searchPaths + 1] = folder
					end
					if searchType then
						searchPaths[#searchPaths + 1] = Content.assetPath
					end
					local tokens
					do
						local _accum_0 = { }
						local _len_0 = 1
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do
							_accum_0[_len_0] = mod
							_len_0 = _len_0 + 1
						end
						tokens = _accum_0
					end
					local suggestions = { }
					for _index_0 = 1, #searchPaths do
						local path = searchPaths[_index_0]
						local sPath = Path(path, table.unpack(tokens))
						if not Content:exist(sPath) then
							goto _continue_0
						end
						if searchType == "Font" then
							local fontPath = Path(sPath, "Font")
							if Content:exist(fontPath) then
								local _list_1 = Content:getFiles(fontPath)
								for _index_1 = 1, #_list_1 do
									local f = _list_1[_index_1]
									if _anon_func_4(f) then
										if "." == f:sub(1, 1) then
											goto _continue_1
										end
										suggestions[#suggestions + 1] = {
											Path:getName(f),
											"font",
											"field"
										}
									end
									::_continue_1::
								end
							end
						end
						local _list_1 = Content:getFiles(sPath)
						for _index_1 = 1, #_list_1 do
							local f = _list_1[_index_1]
							if "Image" == searchType then
								do
									local _exp_0 = Path:getExt(f)
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then
										if "." == f:sub(1, 1) then
											goto _continue_2
										end
										suggestions[#suggestions + 1] = {
											f,
											"image",
											"field"
										}
									end
								end
								goto _continue_2
							elseif "Font" == searchType then
								do
									local _exp_0 = Path:getExt(f)
									if "ttf" == _exp_0 or "otf" == _exp_0 then
										if "." == f:sub(1, 1) then
											goto _continue_2
										end
										suggestions[#suggestions + 1] = {
											f,
											"font",
											"field"
										}
									end
								end
								goto _continue_2
							end
							local _exp_0 = Path:getExt(f)
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then
								local name = Path:getName(f)
								if "d" == Path:getExt(name) then
									goto _continue_2
								end
								if "." == name:sub(1, 1) then
									goto _continue_2
								end
								suggestions[#suggestions + 1] = {
									name,
									"module",
									"field"
								}
							end
							::_continue_2::
						end
						local _list_2 = Content:getDirs(sPath)
						for _index_1 = 1, #_list_2 do
							local dir = _list_2[_index_1]
							if "." == dir:sub(1, 1) then
								goto _continue_3
							end
							suggestions[#suggestions + 1] = {
								dir,
								"folder",
								"variable"
							}
							::_continue_3::
						end
						::_continue_0::
					end
					if item == "" and not searchType then
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath)
						for _index_0 = 1, #_list_1 do
							local _des_0 = _list_1[_index_0]
							local name = _des_0[1]
							suggestions[#suggestions + 1] = {
								name,
								"dora module",
								"function"
							}
						end
					end
					if #suggestions > 0 then
						do
							local _accum_0 = { }
							local _len_0 = 1
							for _, v in pairs(_anon_func_5(suggestions)) do
								_accum_0[_len_0] = v
								_len_0 = _len_0 + 1
							end
							suggestions = _accum_0
						end
						return {
							success = true,
							suggestions = suggestions
						}
					else
						return {
							success = false
						}
					end
				until true
				if "tl" == lang or "lua" == lang then
					do
						local isTIC80 = CheckTIC80Code(content)
						if isTIC80 then
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")")
						end
					end
					local suggestions = teal.completeAsync(content, line, row, searchPath)
					if not line:match("[%.:]$") then
						local checkSet
						do
							local _tbl_0 = { }
							for _index_0 = 1, #suggestions do
								local _des_0 = suggestions[_index_0]
								local name = _des_0[1]
								_tbl_0[name] = true
							end
							checkSet = _tbl_0
						end
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath)
						for _index_0 = 1, #_list_0 do
							local item = _list_0[_index_0]
							if not checkSet[item[1]] then
								suggestions[#suggestions + 1] = item
							end
						end
						for _index_0 = 1, #luaKeywords do
							local word = luaKeywords[_index_0]
							suggestions[#suggestions + 1] = {
								word,
								"keyword",
								"keyword"
							}
						end
						if lang == "tl" then
							for _index_0 = 1, #tealKeywords do
								local word = tealKeywords[_index_0]
								suggestions[#suggestions + 1] = {
									word,
									"keyword",
									"keyword"
								}
							end
						end
					end
					if #suggestions > 0 then
						return {
							success = true,
							suggestions = suggestions
						}
					end
				elseif "yue" == lang then
					local suggestions = { }
					local gotGlobals = false
					do
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true)
						if luaCodes then
							gotGlobals = true
							do
								local chainOp = line:match("[^%w_]([%.\\])$")
								if chainOp then
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)")
									if not withVar then
										return {
											success = false
										}
									end
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.')
								elseif line:match("^([%.\\])$") then
									return {
										success = false
									}
								end
							end
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath)
							for _index_0 = 1, #_list_0 do
								local item = _list_0[_index_0]
								suggestions[#suggestions + 1] = item
							end
							if #suggestions == 0 then
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath)
								for _index_0 = 1, #_list_1 do
									local item = _list_1[_index_0]
									suggestions[#suggestions + 1] = item
								end
							end
						end
					end
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then
						local checkSet
						do
							local _tbl_0 = { }
							for _index_0 = 1, #suggestions do
								local _des_0 = suggestions[_index_0]
								local name = _des_0[1]
								_tbl_0[name] = true
							end
							checkSet = _tbl_0
						end
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath)
						for _index_0 = 1, #_list_0 do
							local item = _list_0[_index_0]
							if not checkSet[item[1]] then
								suggestions[#suggestions + 1] = item
							end
						end
						if not gotGlobals then
							local _list_1 = teal.completeAsync("", "x", 1, searchPath)
							for _index_0 = 1, #_list_1 do
								local item = _list_1[_index_0]
								if not checkSet[item[1]] then
									suggestions[#suggestions + 1] = item
								end
							end
						end
						for _index_0 = 1, #yueKeywords do
							local word = yueKeywords[_index_0]
							if not checkSet[word] then
								suggestions[#suggestions + 1] = {
									word,
									"keyword",
									"keyword"
								}
							end
						end
					end
					if #suggestions > 0 then
						return {
							success = true,
							suggestions = suggestions
						}
					end
				elseif "xml" == lang then
					local items = xml.complete(content)
					if #items > 0 then
						local suggestions
						do
							local _accum_0 = { }
							local _len_0 = 1
							for _index_0 = 1, #items do
								local _des_0 = items[_index_0]
								local label, insertText = _des_0[1], _des_0[2]
								_accum_0[_len_0] = {
									label,
									insertText,
									"field"
								}
								_len_0 = _len_0 + 1
							end
							suggestions = _accum_0
						end
						return {
							success = true,
							suggestions = suggestions
						}
					end
				end
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:upload("/upload", function(req, filename)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.params
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				local uploadPath = Path(Content.writablePath, ".upload")
				if not Content:exist(uploadPath) then
					Content:mkdir(uploadPath)
				end
				local targetPath = Path(uploadPath, filename)
				Content:mkdir(Path:getPath(targetPath))
				return targetPath
			end
		end
	end
	return nil
end, function(req, file)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.params
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				path = Path(Content.writablePath, path)
				if Content:exist(path) then
					local uploadPath = Path(Content.writablePath, ".upload")
					local targetPath = Path(path, Path:getRelative(file, uploadPath))
					Content:mkdir(Path:getPath(targetPath))
					if Content:move(file, targetPath) then
						return true
					end
				end
			end
		end
	end
	return false
end)
HttpServer:post("/list", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				if Content:exist(path) then
					local files = { }
					local visitAssets
					visitAssets = function(path, folder)
						local dirs = Content:getDirs(path)
						for _index_0 = 1, #dirs do
							local dir = dirs[_index_0]
							if dir:match("^%.") then
								goto _continue_0
							end
							local current
							if folder == "" then
								current = dir
							else
								current = Path(folder, dir)
							end
							files[#files + 1] = current
							visitAssets(Path(path, dir), current)
							::_continue_0::
						end
						local fs = Content:getFiles(path)
						for _index_0 = 1, #fs do
							local f = fs[_index_0]
							if (".DS_Store" == f) then
								goto _continue_1
							end
							if folder == "" then
								files[#files + 1] = f
							else
								files[#files + 1] = Path(folder, f)
							end
							::_continue_1::
						end
					end
					visitAssets(path, "")
					if #files == 0 then
						files = nil
					end
					return {
						success = true,
						files = files
					}
				end
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:post("/info", function()
	local Entry = require("Script.Dev.Entry")
	local webProfiler, drawerWidth
	do
		local _obj_0 = Entry.getConfig()
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth
	end
	local engineDev = Entry.getEngineDev()
	Entry.connectWebIDE()
	return {
		platform = App.platform,
		locale = App.locale,
		version = App.version,
		engineDev = engineDev,
		webProfiler = webProfiler,
		drawerWidth = drawerWidth
	}
end)
local ensureLLMConfigTable
ensureLLMConfigTable = function()
	local columns = DB:query("PRAGMA table_info(LLMConfig)")
	if columns and #columns > 0 then
		local expected = {
			id = true,
			name = true,
			url = true,
			model = true,
			api_key = true,
			context_window = true,
			temperature = true,
			max_tokens = true,
			reasoning_effort = true,
			custom_options = true,
			supports_function_calling = true,
			active = true,
			created_at = true,
			updated_at = true
		}
		local existing = { }
		local valid = true
		for _index_0 = 1, #columns do
			local row = columns[_index_0]
			local columnName = tostring(row[2])
			existing[columnName] = true
			if not expected[columnName] then
				valid = false
				break
			end
		end
		if valid then
			if not existing.context_window then
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000")
			end
			if not existing.temperature then
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1")
			end
			if not existing.max_tokens then
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192")
			end
			if not existing.reasoning_effort then
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''")
			end
			if not existing.custom_options then
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''")
			end
			if not existing.supports_function_calling then
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1")
			end
		else
			DB:exec("DROP TABLE IF EXISTS LLMConfig")
		end
	end
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			context_window INTEGER NOT NULL DEFAULT 64000,
			temperature REAL NOT NULL DEFAULT 0.1,
			max_tokens INTEGER NOT NULL DEFAULT 8192,
			reasoning_effort TEXT NOT NULL DEFAULT '',
			custom_options TEXT NOT NULL DEFAULT '',
			supports_function_calling INTEGER NOT NULL DEFAULT 1,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]])
end
local normalizeContextWindow
normalizeContextWindow = function(value)
	local contextWindow = tonumber(value)
	if contextWindow == nil or contextWindow < 64000 then
		return 64000
	end
	return math.max(64000, math.floor(contextWindow))
end
local normalizeTemperature
normalizeTemperature = function(value)
	local temperature = tonumber(value)
	if temperature == nil then
		return 0.1
	end
	return math.max(0, math.min(2, temperature))
end
local normalizeMaxTokens
normalizeMaxTokens = function(value)
	local maxTokens = tonumber(value)
	if maxTokens == nil or maxTokens < 1 then
		return 8192
	end
	return math.max(1, math.floor(maxTokens))
end
local normalizeReasoningEffort
normalizeReasoningEffort = function(value)
	if value == nil then
		return ""
	end
	local effort = tostring(value)
	return effort:match("^%s*(.-)%s*$") or ""
end
local normalizeCustomOptions
normalizeCustomOptions = function(value)
	if value == nil then
		return ""
	end
	local options = tostring(value)
	options = options:match("^%s*(.-)%s*$") or ""
	return options
end
local validateCustomOptions
validateCustomOptions = function(value)
	local options = normalizeCustomOptions(value)
	if options == "" then
		return true
	end
	if not options:match("^%s*{") then
		return false
	end
	local decoded = json.decode(options)
	return type(decoded) == "table"
end
HttpServer:post("/llm/list", function()
	ensureLLMConfigTable()
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc")
	local items
	if rows and #rows > 0 then
		local _accum_0 = { }
		local _len_0 = 1
		for _index_0 = 1, #rows do
			local _des_0 = rows[_index_0]
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12]
			_accum_0[_len_0] = {
				id = id,
				name = name,
				url = url,
				model = model,
				key = key,
				contextWindow = normalizeContextWindow(contextWindow),
				temperature = normalizeTemperature(temperature),
				maxTokens = normalizeMaxTokens(maxTokens),
				reasoningEffort = normalizeReasoningEffort(reasoningEffort),
				customOptions = normalizeCustomOptions(customOptions),
				supportsFunctionCalling = supportsFunctionCalling ~= 0,
				active = active ~= 0
			}
			_len_0 = _len_0 + 1
		end
		items = _accum_0
	end
	return {
		success = true,
		items = items
	}
end)
HttpServer:post("/llm/create", function(req)
	ensureLLMConfigTable()
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling
				local now = os.time()
				if name == nil or url == nil or model == nil or key == nil then
					return {
						success = false,
						message = "invalid"
					}
				end
				contextWindow = normalizeContextWindow(contextWindow)
				temperature = normalizeTemperature(temperature)
				maxTokens = normalizeMaxTokens(maxTokens)
				reasoningEffort = normalizeReasoningEffort(reasoningEffort)
				customOptions = normalizeCustomOptions(customOptions)
				if not validateCustomOptions(customOptions) then
					return {
						success = false,
						message = "customOptions must be a JSON object"
					}
				end
				if supportsFunctionCalling == false then
					supportsFunctionCalling = 0
				else
					supportsFunctionCalling = 1
				end
				if active then
					active = 1
				else
					active = 0
				end
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", {
					tostring(name),
					tostring(url),
					tostring(model),
					tostring(key),
					contextWindow,
					temperature,
					maxTokens,
					reasoningEffort,
					customOptions,
					supportsFunctionCalling,
					active,
					now,
					now
				})
				return {
					success = affected >= 0
				}
			end
		end
	end
	return {
		success = false,
		message = "invalid"
	}
end)
HttpServer:post("/llm/update", function(req)
	ensureLLMConfigTable()
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local body = req.body
			if body ~= nil then
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling
				local now = os.time()
				id = tonumber(id)
				if id == nil then
					return {
						success = false,
						message = "invalid"
					}
				end
				contextWindow = normalizeContextWindow(contextWindow)
				temperature = normalizeTemperature(temperature)
				maxTokens = normalizeMaxTokens(maxTokens)
				reasoningEffort = normalizeReasoningEffort(reasoningEffort)
				customOptions = normalizeCustomOptions(customOptions)
				if not validateCustomOptions(customOptions) then
					return {
						success = false,
						message = "customOptions must be a JSON object"
					}
				end
				if supportsFunctionCalling == false then
					supportsFunctionCalling = 0
				else
					supportsFunctionCalling = 1
				end
				if active then
					active = 1
				else
					active = 0
				end
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", {
					tostring(name),
					tostring(url),
					tostring(model),
					tostring(key),
					contextWindow,
					temperature,
					maxTokens,
					reasoningEffort,
					customOptions,
					supportsFunctionCalling,
					active,
					now,
					id
				})
				return {
					success = affected >= 0
				}
			end
		end
	end
	return {
		success = false,
		message = "invalid"
	}
end)
HttpServer:post("/llm/delete", function(req)
	ensureLLMConfigTable()
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local id
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					id = _obj_0.id
				end
			end
			if id ~= nil then
				id = tonumber(id)
				if id == nil then
					return {
						success = false,
						message = "invalid"
					}
				end
				local affected = DB:exec("delete from LLMConfig where id = ?", {
					id
				})
				return {
					success = affected >= 0
				}
			end
		end
	end
	return {
		success = false,
		message = "invalid"
	}
end)
HttpServer:post("/stat", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				if not Content:exist(path) then
					return {
						success = false,
						message = "target not existed"
					}
				end
				if Content:isdir(path) then
					return {
						success = false,
						message = "failed to stat a directory"
					}
				end
				local size, isBinary = Content:getAttr(path)
				if size then
					return {
						success = true,
						size = size,
						isBinary = isBinary
					}
				end
			end
		end
	end
	return {
		success = false,
		message = "failed to stat"
	}
end)
HttpServer:post("/new", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			local content
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					content = _obj_0.content
				end
			end
			local folder
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					folder = _obj_0.folder
				end
			end
			if path ~= nil and content ~= nil and folder ~= nil then
				if Content:exist(path) then
					return {
						success = false,
						message = "TargetExisted"
					}
				end
				local parent = Path:getPath(path)
				local files = Content:getFiles(parent)
				if folder then
					local name = Path:getFilename(path):lower()
					for _index_0 = 1, #files do
						local file = files[_index_0]
						if name == Path:getFilename(file):lower() then
							return {
								success = false,
								message = "TargetExisted"
							}
						end
					end
					if Content:mkdir(path) then
						return {
							success = true
						}
					end
				else
					local name = Path:getName(path):lower()
					for _index_0 = 1, #files do
						local file = files[_index_0]
						if name == Path:getName(file):lower() then
							local ext = Path:getExt(file)
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then
								goto _continue_0
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then
								goto _continue_0
							end
							return {
								success = false,
								message = "SourceExisted"
							}
						end
						::_continue_0::
					end
					if Content:save(path, content) then
						return {
							success = true
						}
					end
				end
			end
		end
	end
	return {
		success = false,
		message = "Failed"
	}
end)
HttpServer:post("/delete", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				if Content:exist(path) then
					local projectRoot
					if Content:isdir(path) and isProjectRootDir(path) then
						projectRoot = path
					else
						projectRoot = nil
					end
					local parent = Path:getPath(path)
					local files = Content:getFiles(parent)
					local name = Path:getName(path):lower()
					local ext = Path:getExt(path)
					for _index_0 = 1, #files do
						local file = files[_index_0]
						if name == Path:getName(file):lower() then
							local _exp_0 = Path:getExt(file)
							if "tl" == _exp_0 then
								if ("vs" == ext) then
									Content:remove(Path(parent, file))
								end
							elseif "lua" == _exp_0 then
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then
									Content:remove(Path(parent, file))
								end
							end
						end
					end
					if Content:remove(path) then
						if projectRoot then
							AgentSession.deleteSessionsByProjectRoot(projectRoot)
						end
						return {
							success = true
						}
					end
				end
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:post("/rename", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local old
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					old = _obj_0.old
				end
			end
			local new
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					new = _obj_0.new
				end
			end
			if old ~= nil and new ~= nil then
				if Content:exist(old) and not Content:exist(new) then
					local renamedDir = Content:isdir(old)
					local parent = Path:getPath(new)
					local files = Content:getFiles(parent)
					if renamedDir then
						local name = Path:getFilename(new):lower()
						for _index_0 = 1, #files do
							local file = files[_index_0]
							if name == Path:getFilename(file):lower() then
								return {
									success = false
								}
							end
						end
					else
						local name = Path:getName(new):lower()
						local ext = Path:getExt(new)
						for _index_0 = 1, #files do
							local file = files[_index_0]
							if name == Path:getName(file):lower() then
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then
									goto _continue_0
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then
									goto _continue_0
								end
								return {
									success = false
								}
							end
							::_continue_0::
						end
					end
					if Content:move(old, new) then
						if renamedDir then
							AgentSession.renameSessionsByProjectRoot(old, new)
						end
						local newParent = Path:getPath(new)
						parent = Path:getPath(old)
						files = Content:getFiles(parent)
						local newName = Path:getName(new)
						local oldName = Path:getName(old)
						local name = oldName:lower()
						local ext = Path:getExt(old)
						for _index_0 = 1, #files do
							local file = files[_index_0]
							if name == Path:getName(file):lower() then
								local _exp_0 = Path:getExt(file)
								if "tl" == _exp_0 then
									if ("vs" == ext) then
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl"))
									end
								elseif "lua" == _exp_0 then
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua"))
									end
								end
							end
						end
						return {
							success = true
						}
					end
				end
			end
		end
	end
	return {
		success = false
	}
end)
local withProjectSearchPaths
withProjectSearchPaths = function(projectRoot, projFile, fn)
	local fallbackPaths = { }
	local addFallback
	addFallback = function(dir)
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then
			fallbackPaths[#fallbackPaths + 1] = dir
		end
	end
	if projectRoot and projectRoot ~= "" then
		addFallback(Path(projectRoot, "Script"))
		addFallback(projectRoot)
	end
	if projFile then
		local projDir = getProjectDirFromFile(projFile)
		if projDir then
			addFallback(Path(projDir, "Script"))
			addFallback(projDir)
		else
			addFallback(Path:getPath(projFile))
		end
	end
	if not (#fallbackPaths > 0) then
		return fn()
	end
	local searchPaths = Content.searchPaths
	for _index_0 = 1, #fallbackPaths do
		local dir = fallbackPaths[_index_0]
		Content:addSearchPath(dir)
	end
	local _ <close> = setmetatable({ }, {
		__close = function()
			Content.searchPaths = searchPaths
		end
	})
	return fn()
end
HttpServer:post("/exist", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local file
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					file = _obj_0.file
				end
			end
			if file ~= nil then
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function()
					return {
						success = Content:exist(file)
					}
				end)
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:postSchedule("/read", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				local readFile
				readFile = function()
					if Content:exist(path) then
						local content = Content:loadAsync(path)
						if content then
							return {
								content = content,
								success = true,
								fullPath = Content:getFullPath(path)
							}
						end
					end
					return nil
				end
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile)
				if result then
					return result
				end
			end
		end
	end
	return {
		success = false
	}
end)
local agentDocLanguage
agentDocLanguage = function(language)
	if language == "zh-Hans" then
		return "zh"
	else
		return "en"
	end
end
HttpServer:postSchedule("/doc/search", function(req)
	local body = req.body or { }
	local language = body.docLanguage
	if not (("en" == language or "zh-Hans" == language)) then
		return {
			success = false,
			message = "unsupported doc language"
		}
	end
	local source = body.docSource
	if not (("api" == source or "tutorial" == source)) then
		return {
			success = false,
			message = "unsupported doc source"
		}
	end
	local codeLanguage = body.programmingLanguage
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then
		return {
			success = false,
			message = "unsupported programming language"
		}
	end
	if not body.pattern then
		return {
			success = false,
			message = "missing pattern"
		}
	end
	local result = nil
	AgentTools.searchDoraAPIHttp({
		pattern = body.pattern,
		docLanguage = agentDocLanguage(language),
		docSource = source,
		programmingLanguage = codeLanguage,
		limit = body.limit,
		useRegex = body.useRegex,
		caseSensitive = body.caseSensitive,
		includeContent = body.includeContent,
		contentWindow = body.contentWindow
	}, function(res)
		result = res
	end)
	wait(function()
		return result ~= nil
	end)
	if result and result.success then
		result.docLanguage = language
	end
	if result then
		return result
	else
		return {
			success = false,
			message = "doc search failed"
		}
	end
	return {
		success = false,
		message = "invalid call"
	}
end)
HttpServer:postSchedule("/doc/read", function(req)
	local body = req.body or { }
	local language = body.docLanguage
	if not (("en" == language or "zh-Hans" == language)) then
		return {
			success = false,
			message = "unsupported doc language"
		}
	end
	if not body.file then
		return {
			success = false,
			message = "missing file"
		}
	end
	local result = AgentTools.readDoraDoc({
		docLanguage = agentDocLanguage(language),
		file = body.file,
		startLine = body.startLine,
		endLine = body.endLine
	})
	if result and result.success then
		result.docLanguage = language
	end
	return result
end)
HttpServer:get("/read-sync", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local params = req.params
			if params ~= nil then
				local path = params.path
				local exts
				if params.exts then
					local _accum_0 = { }
					local _len_0 = 1
					for ext in params.exts:gmatch("[^|]*") do
						_accum_0[_len_0] = ext
						_len_0 = _len_0 + 1
					end
					exts = _accum_0
				else
					exts = {
						""
					}
				end
				local readFileAt
				readFileAt = function(targetPath)
					if Content:exist(targetPath) then
						local content = Content:load(targetPath)
						if content then
							return {
								content = content,
								success = true,
								fullPath = Content:getFullPath(targetPath)
							}
						end
					end
					return nil
				end
				local readFile
				readFile = function(fallbackPaths)
					for _index_0 = 1, #exts do
						local ext = exts[_index_0]
						local targetPath = path .. ext
						if not Content:isAbsolutePath(targetPath) then
							for _index_1 = 1, #fallbackPaths do
								local fallback = fallbackPaths[_index_1]
								local fallbackResult = readFileAt(Path(fallback, targetPath))
								if fallbackResult then
									return fallbackResult
								end
							end
						end
						local fileResult = readFileAt(targetPath)
						if fileResult then
							return fileResult
						end
					end
					return nil
				end
				local fallbackPaths = { }
				local fallbackCandidates = { }
				do
					local projectRoot = req.params.projectRoot
					if projectRoot then
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script")
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot
						end
					end
				end
				do
					local projFile = req.params.projFile
					if projFile then
						local projDir = getProjectDirFromFile(projFile)
						if projDir then
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script")
							fallbackCandidates[#fallbackCandidates + 1] = projDir
						else
							projDir = Path:getPath(projFile)
							fallbackCandidates[#fallbackCandidates + 1] = projDir
						end
					end
				end
				for _index_0 = 1, #fallbackCandidates do
					local dir = fallbackCandidates[_index_0]
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then
						local exists = false
						for _index_1 = 1, #fallbackPaths do
							local fallback = fallbackPaths[_index_1]
							if fallback == dir then
								exists = true
								break
							end
						end
						if not exists then
							fallbackPaths[#fallbackPaths + 1] = dir
						end
					end
				end
				local readResult = readFile(fallbackPaths)
				if readResult then
					return readResult
				end
			end
		end
	end
	return {
		success = false
	}
end)
local compileFileAsync
compileFileAsync = function(inputFile, sourceCodes, projectRoot)
	if projectRoot == nil then
		projectRoot = nil
	end
	local file = inputFile
	local searchPath
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua")
	elseif not Content:isAbsolutePath(inputFile) then
		searchPath = ""
	else
		local dir = getProjectDirFromFile(inputFile)
		if dir then
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua")
		else
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile
			searchPath = ""
		end
	end
	local outputFile = Path:replaceExt(inputFile, "lua")
	local yueext = yue.options.extension
	local resultCodes = nil
	local resultError = nil
	do
		local _exp_0 = Path:getExt(inputFile)
		if yueext == _exp_0 then
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes)
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals)
				if not codes then
					resultError = err
					return
				end
				local extraGlobal
				if isTIC80 then
					extraGlobal = tic80APIs
				else
					extraGlobal = nil
				end
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal)
				if not success then
					resultError = message
					return
				end
				if codes == "" then
					resultCodes = ""
					return nil
				end
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes)
				return resultCodes
			end, function(success)
				if not success then
					Content:remove(outputFile)
					if resultCodes == nil then
						resultCodes = false
					end
				end
			end)
		elseif "tl" == _exp_0 then
			local isTIC80 = CheckTIC80Code(sourceCodes)
			if isTIC80 then
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")")
			end
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath)
			if codes then
				if isTIC80 then
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80")
				end
				resultCodes = codes
				Content:saveAsync(outputFile, codes)
			else
				Content:remove(outputFile)
				resultCodes = false
				resultError = err
			end
		elseif "xml" == _exp_0 then
			local codes, err = xml.tolua(sourceCodes)
			if codes then
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)
				Content:saveAsync(outputFile, resultCodes)
			else
				Content:remove(outputFile)
				resultCodes = false
				resultError = err
			end
		end
	end
	wait(function()
		return resultCodes ~= nil
	end)
	if resultCodes then
		return resultCodes
	else
		return nil, resultError
	end
	return nil
end
HttpServer:postSchedule("/write", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			local content
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					content = _obj_0.content
				end
			end
			if path ~= nil and content ~= nil then
				if Content:saveAsync(path, content) then
					do
						local _exp_0 = Path:getExt(path)
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then
							if '' == Path:getExt(Path:getName(path)) then
								local resultCodes = compileFileAsync(path, content)
								return {
									success = true,
									resultCodes = resultCodes
								}
							end
						end
					end
					return {
						success = true
					}
				end
			end
		end
	end
	return {
		success = false
	}
end)
local getWaProjectDirFromFile = nil
HttpServer:postSchedule("/build", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				local projectRoot = req.body.projectRoot
				if Content:isdir(path) then
					local projDir = getWaProjectDirFromFile(path)
					if projDir then
						local message = Wasm:buildWaAsync(projDir)
						if message == "" then
							return {
								success = true
							}
						else
							return {
								success = false,
								message = message
							}
						end
					end
				end
				local _exp_0 = Path:getExt(path)
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then
					if '' == Path:getExt(Path:getName(path)) then
						local content = Content:loadAsync(path)
						if content then
							local resultCodes = compileFileAsync(path, content, projectRoot)
							if resultCodes then
								return {
									success = true,
									resultCodes = resultCodes
								}
							end
						end
					end
				elseif "wa" == _exp_0 then
					local projDir = getWaProjectDirFromFile(path)
					if projDir then
						local message = Wasm:buildWaAsync(projDir)
						if message == "" then
							return {
								success = true
							}
						else
							return {
								success = false,
								message = message
							}
						end
					else
						return {
							success = false,
							message = 'Wa file needs a project'
						}
					end
				end
			end
		end
	end
	return {
		success = false
	}
end)
local extentionLevels = {
	vs = 2,
	bl = 2,
	ts = 1,
	tsx = 1,
	tl = 1,
	yue = 1,
	xml = 1,
	lua = 0
}
HttpServer:post("/assets", function()
	local Entry = require("Script.Dev.Entry")
	local engineDev = Entry.getEngineDev()
	local visitAssets
	visitAssets = function(path, tag)
		local isWorkspace = tag == "Workspace"
		local builtin
		if tag == "Builtin" then
			builtin = true
		else
			builtin = nil
		end
		local children = nil
		local dirs = Content:getDirs(path)
		for _index_0 = 1, #dirs do
			local dir = dirs[_index_0]
			if isWorkspace then
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then
					goto _continue_0
				end
			elseif dir == ".git" then
				goto _continue_0
			end
			if not children then
				children = { }
			end
			children[#children + 1] = visitAssets(Path(path, dir))
			::_continue_0::
		end
		local files = Content:getFiles(path)
		local names = { }
		for _index_0 = 1, #files do
			local file = files[_index_0]
			if (".DS_Store" == file) then
				goto _continue_1
			end
			local name = Path:getName(file)
			local ext = names[name]
			if ext then
				local lv1
				do
					local _exp_0 = extentionLevels[ext]
					if _exp_0 ~= nil then
						lv1 = _exp_0
					else
						lv1 = -1
					end
				end
				ext = Path:getExt(file)
				local lv2
				do
					local _exp_0 = extentionLevels[ext]
					if _exp_0 ~= nil then
						lv2 = _exp_0
					else
						lv2 = -1
					end
				end
				if lv2 > lv1 then
					names[name] = ext
				elseif lv2 == lv1 then
					names[name .. '.' .. ext] = ""
				end
			else
				ext = Path:getExt(file)
				if not extentionLevels[ext] then
					names[file] = ""
				else
					names[name] = ext
				end
			end
			::_continue_1::
		end
		do
			local _accum_0 = { }
			local _len_0 = 1
			for name, ext in pairs(names) do
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext
				_len_0 = _len_0 + 1
			end
			files = _accum_0
		end
		for _index_0 = 1, #files do
			local file = files[_index_0]
			if not children then
				children = { }
			end
			children[#children + 1] = {
				key = Path(path, file),
				dir = false,
				title = file,
				builtin = builtin
			}
		end
		if children then
			table.sort(children, function(a, b)
				if a.dir == b.dir then
					return a.title < b.title
				else
					return a.dir
				end
			end)
		end
		if isWorkspace and children then
			return children
		else
			return {
				key = path,
				dir = true,
				title = Path:getFilename(path),
				builtin = builtin,
				children = children
			}
		end
	end
	local zh = (App.locale:match("^zh") ~= nil)
	return {
		key = Content.writablePath,
		dir = true,
		root = true,
		title = "Assets",
		children = (function()
			local _tab_0 = {
				{
					key = Path(Content.assetPath),
					dir = true,
					builtin = true,
					title = zh and "内置资源" or "Built-in",
					children = {
						(function()
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin")
							_with_0.title = zh and "说明文档" or "Readme"
							return _with_0
						end)(),
						(function()
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin")
							_with_0.title = zh and "接口文档" or "API Doc"
							return _with_0
						end)(),
						(function()
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin")
							_with_0.title = zh and "开发工具" or "Tools"
							return _with_0
						end)(),
						(function()
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin")
							_with_0.title = zh and "字体" or "Font"
							return _with_0
						end)(),
						(function()
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin")
							_with_0.title = zh and "程序库" or "Lib"
							if engineDev then
								local _list_0 = _with_0.children
								for _index_0 = 1, #_list_0 do
									local child = _list_0[_index_0]
									if not (child.title == "Dora") then
										goto _continue_0
									end
									local title = zh and "zh-Hans" or "en"
									do
										local _accum_0 = { }
										local _len_0 = 1
										local _list_1 = child.children
										for _index_1 = 1, #_list_1 do
											local c = _list_1[_index_1]
											if c.title ~= title then
												_accum_0[_len_0] = c
												_len_0 = _len_0 + 1
											end
										end
										child.children = _accum_0
									end
									break
									::_continue_0::
								end
							else
								local _accum_0 = { }
								local _len_0 = 1
								local _list_0 = _with_0.children
								for _index_0 = 1, #_list_0 do
									local child = _list_0[_index_0]
									if child.title ~= "Dora" then
										_accum_0[_len_0] = child
										_len_0 = _len_0 + 1
									end
								end
								_with_0.children = _accum_0
							end
							return _with_0
						end)(),
						(function()
							if engineDev then
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin")
								local _obj_0 = _with_0.children
								_obj_0[#_obj_0 + 1] = {
									key = Path(Content.assetPath, "Script", "init.yue"),
									dir = false,
									builtin = true,
									title = "init.yue"
								}
								return _with_0
							end
						end)()
					}
				}
			}
			local _obj_0 = visitAssets(Content.writablePath, "Workspace")
			local _idx_0 = #_tab_0 + 1
			for _index_0 = 1, #_obj_0 do
				local _value_0 = _obj_0[_index_0]
				_tab_0[_idx_0] = _value_0
				_idx_0 = _idx_0 + 1
			end
			return _tab_0
		end)()
	}
end)
HttpServer:post("/entry/list", function()
	local Entry = require("Script.Dev.Entry")
	local res = Entry.getLaunchEntries()
	res.success = true
	return res
end)
HttpServer:post("/run/status", function()
	local Entry = require("Script.Dev.Entry")
	return Entry.getCurrentEntryStatus()
end)
HttpServer:postSchedule("/run", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local file
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					file = _obj_0.file
				end
			end
			local asProj
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					asProj = _obj_0.asProj
				end
			end
			if file ~= nil and asProj ~= nil then
				if not Content:isAbsolutePath(file) then
					local devFile = Path(Content.writablePath, file)
					if Content:exist(devFile) then
						file = devFile
					end
				end
				local Entry = require("Script.Dev.Entry")
				local workDir
				if asProj then
					local projectRoot = req.body.projectRoot
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then
						workDir = projectRoot
					else
						workDir = getProjectDirFromFile(file)
					end
					if workDir then
						Entry.allClear()
						local target = Path(workDir, "init")
						local success, err = Entry.enterEntryAsync({
							entryName = "Project",
							fileName = target,
							workDir = workDir,
							projectRoot = workDir,
							runKind = "project"
						})
						target = Path:getName(Path:getPath(target))
						return {
							success = success,
							target = target,
							err = err
						}
					end
				else
					workDir = getProjectDirFromFile(file)
					if not workDir and Path:getExt(file) == "wasm" then
						local parent = Path:getPath(file)
						if Content:exist(Path(parent, "wa.mod")) then
							workDir = parent
						end
					end
				end
				Entry.allClear()
				file = Path:replaceExt(file, "")
				local entry = {
					entryName = Path:getName(file),
					fileName = file,
					runKind = "file"
				}
				if workDir then
					entry.workDir = workDir
					entry.projectRoot = workDir
				end
				local success, err = Entry.enterEntryAsync(entry)
				return {
					success = success,
					err = err
				}
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:postSchedule("/stop", function()
	local Entry = require("Script.Dev.Entry")
	return {
		success = Entry.stop()
	}
end)
local minifyAsync
minifyAsync = function(sourcePath, minifyPath)
	if not Content:exist(sourcePath) then
		return
	end
	local Entry = require("Script.Dev.Entry")
	local errors = { }
	local files = Entry.getAllFiles(sourcePath, {
		"lua"
	}, true)
	do
		local _accum_0 = { }
		local _len_0 = 1
		for _index_0 = 1, #files do
			local file = files[_index_0]
			if file:sub(1, 1) ~= '.' then
				_accum_0[_len_0] = file
				_len_0 = _len_0 + 1
			end
		end
		files = _accum_0
	end
	local paths
	do
		local _tbl_0 = { }
		for _index_0 = 1, #files do
			local file = files[_index_0]
			_tbl_0[Path:getPath(file)] = true
		end
		paths = _tbl_0
	end
	for path in pairs(paths) do
		Content:mkdir(Path(minifyPath, path))
	end
	local _ <close> = setmetatable({ }, {
		__close = function()
			package.loaded["luaminify.FormatMini"] = nil
			package.loaded["luaminify.ParseLua"] = nil
			package.loaded["luaminify.Scope"] = nil
			package.loaded["luaminify.Util"] = nil
		end
	})
	local FormatMini
	do
		local _obj_0 = require("luaminify")
		FormatMini = _obj_0.FormatMini
	end
	local fileCount = #files
	local count = 0
	for _index_0 = 1, #files do
		local file = files[_index_0]
		thread(function()
			local _ <close> = setmetatable({ }, {
				__close = function()
					count = count + 1
				end
			})
			local input = Path(sourcePath, file)
			local output = Path(minifyPath, Path:replaceExt(file, "lua"))
			if Content:exist(input) then
				local sourceCodes = Content:loadAsync(input)
				local res, err = FormatMini(sourceCodes)
				if res then
					Content:saveAsync(output, res)
					return print("Minify " .. tostring(file))
				else
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err)
				end
			else
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!"
			end
		end)
		sleep()
	end
	wait(function()
		return count == fileCount
	end)
	if #errors > 0 then
		print(table.concat(errors, '\n'))
	end
	print("Obfuscation done.")
	return files
end
local zipping = false
HttpServer:postSchedule("/zip", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			local zipFile
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					zipFile = _obj_0.zipFile
				end
			end
			local obfuscated
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					obfuscated = _obj_0.obfuscated
				end
			end
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then
				if zipping then
					goto failed
				end
				zipping = true
				local _ <close> = setmetatable({ }, {
					__close = function()
						zipping = false
					end
				})
				if not Content:exist(path) then
					goto failed
				end
				Content:mkdir(Path:getPath(zipFile))
				if obfuscated then
					local scriptPath = Path(Content.writablePath, ".download", ".script")
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated")
					local tempPath = Path(Content.writablePath, ".download", ".temp")
					Content:remove(scriptPath)
					Content:remove(obfuscatedPath)
					Content:remove(tempPath)
					Content:mkdir(scriptPath)
					Content:mkdir(obfuscatedPath)
					Content:mkdir(tempPath)
					if not Content:copyAsync(path, tempPath) then
						goto failed
					end
					local Entry = require("Script.Dev.Entry")
					local luaFiles = minifyAsync(tempPath, obfuscatedPath)
					local scriptFiles = Entry.getAllFiles(tempPath, {
						"tl",
						"yue",
						"lua",
						"ts",
						"tsx",
						"vs",
						"bl",
						"xml",
						"wa",
						"mod"
					}, true)
					for _index_0 = 1, #scriptFiles do
						local file = scriptFiles[_index_0]
						Content:remove(Path(tempPath, file))
					end
					for _index_0 = 1, #luaFiles do
						local file = luaFiles[_index_0]
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file))
					end
					if not Content:zipAsync(tempPath, zipFile, function(file)
						return not (file:match('^%.') or file:match("[\\/]%."))
					end) then
						goto failed
					end
					return {
						success = true
					}
				else
					return {
						success = Content:zipAsync(path, zipFile, function(file)
							return not (file:match('^%.') or file:match("[\\/]%."))
						end)
					}
				end
			end
		end
	end
	::failed::
	return {
		success = false
	}
end)
HttpServer:postSchedule("/unzip", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local zipFile
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					zipFile = _obj_0.zipFile
				end
			end
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if zipFile ~= nil and path ~= nil then
				return {
					success = Content:unzipAsync(zipFile, path, function(file)
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX"))
					end)
				}
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:post("/editing-info", function(req)
	local Entry = require("Script.Dev.Entry")
	local config = Entry.getConfig()
	local _type_0 = type(req)
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0
	local _match_0 = false
	if _tab_0 then
		local editingInfo
		do
			local _obj_0 = req.body
			local _type_1 = type(_obj_0)
			if "table" == _type_1 or "userdata" == _type_1 then
				editingInfo = _obj_0.editingInfo
			end
		end
		if editingInfo ~= nil then
			_match_0 = true
			config.editingInfo = editingInfo
			return {
				success = true
			}
		end
	end
	if not _match_0 then
		if not (config.editingInfo ~= nil) then
			local folder
			if App.locale:match('^zh') then
				folder = 'zh-Hans'
			else
				folder = 'en'
			end
			config.editingInfo = json.encode({
				index = 0,
				files = {
					{
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'),
						title = "welcome.md"
					}
				}
			})
		end
		return {
			success = true,
			editingInfo = config.editingInfo
		}
	end
end)
HttpServer:post("/command", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local code
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					code = _obj_0.code
				end
			end
			local log
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					log = _obj_0.log
				end
			end
			if code ~= nil and log ~= nil then
				emit("AppCommand", code, log)
				return {
					success = true
				}
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:post("/log/save", function()
	local folder = ".download"
	local fullLogFile = "dora_full_logs.txt"
	local fullFolder = Path(Content.writablePath, folder)
	Content:mkdir(fullFolder)
	local logPath = Path(fullFolder, fullLogFile)
	if App:saveLog(logPath) then
		return {
			success = true,
			path = Path(folder, fullLogFile)
		}
	end
	return {
		success = false
	}
end)
local tailLines
tailLines = function(text, count)
	local lines = { }
	text = text:gsub("\r\n", "\n")
	for line in (text .. "\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = line
	end
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then
		table.remove(lines)
	end
	local start = math.max(1, #lines - count + 1)
	local out = { }
	for i = start, #lines do
		out[#out + 1] = lines[i]
	end
	return table.concat(out, "\n")
end
HttpServer:post("/log", function(req)
	local count = 100
	if req and req.body and req.body.count ~= nil then
		count = req.body.count
	end
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then
		return {
			success = false,
			message = "count must be a positive integer"
		}
	end
	local folder = ".download"
	local fullLogFile = "dora_full_logs.txt"
	local fullFolder = Path(Content.writablePath, folder)
	Content:mkdir(fullFolder)
	local logPath = Path(fullFolder, fullLogFile)
	if App:saveLog(logPath) then
		local text = Content:load(logPath)
		if text then
			return {
				success = true,
				log = tailLines(text, count)
			}
		else
			return {
				success = false,
				message = "failed to read log"
			}
		end
	else
		return {
			success = false,
			message = "failed to save log"
		}
	end
	return {
		success = false
	}
end)
HttpServer:post("/yarn/check", function(req)
	local yarncompile = require("yarncompile")
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local code
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					code = _obj_0.code
				end
			end
			if code ~= nil then
				local jsonObject = json.decode(code)
				if jsonObject then
					local errors = { }
					local _list_0 = jsonObject.nodes
					for _index_0 = 1, #_list_0 do
						local node = _list_0[_index_0]
						local title, body = node.title, node.body
						local luaCode, err = yarncompile(body)
						if not luaCode then
							errors[#errors + 1] = title .. ":" .. err
						end
					end
					return {
						success = true,
						syntaxError = table.concat(errors, "\n\n")
					}
				end
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:post("/yarn/check-file", function(req)
	local yarncompile = require("yarncompile")
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local code
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					code = _obj_0.code
				end
			end
			if code ~= nil then
				local res, _, err = yarncompile(code, true)
				if not res then
					local message, line, column, node = err[1], err[2], err[3], err[4]
					return {
						success = false,
						message = message,
						line = line,
						column = column,
						node = node
					}
				end
			end
		end
	end
	return {
		success = true
	}
end)
getWaProjectDirFromFile = function(file)
	local current
	if Content:isdir(file) then
		current = file
	else
		current = Path:getPath(file)
	end
	if current == "" then
		return nil
	end
	repeat
		local modPath = Path(current, "wa.mod")
		if Content:exist(modPath) then
			return current, modPath
		end
		local parent = Path:getPath(current)
		if parent == "" or parent == current then
			break
		end
		current = parent
	until false
	return nil
end
HttpServer:postSchedule("/wa/update_dora", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				local projDir = getWaProjectDirFromFile(path)
				if projDir then
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora")
					if not Content:exist(sourceDoraPath) then
						return {
							success = false,
							message = "missing dora template"
						}
					end
					local targetVendorPath = Path(projDir, "vendor")
					local targetDoraPath = Path(targetVendorPath, "dora")
					if not Content:exist(targetVendorPath) then
						if not Content:mkdir(targetVendorPath) then
							return {
								success = false,
								message = "failed to create vendor folder"
							}
						end
					elseif not Content:isdir(targetVendorPath) then
						return {
							success = false,
							message = "vendor path is not a folder"
						}
					end
					if Content:exist(targetDoraPath) then
						if not Content:remove(targetDoraPath) then
							return {
								success = false,
								message = "failed to remove old dora"
							}
						end
					end
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then
						return {
							success = false,
							message = "failed to copy dora"
						}
					end
					return {
						success = true
					}
				else
					return {
						success = false,
						message = 'Wa file needs a project'
					}
				end
			end
		end
	end
	return {
		success = false,
		message = "invalid call"
	}
end)
HttpServer:postSchedule("/wa/build", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				local projDir = getWaProjectDirFromFile(path)
				if projDir then
					local message = Wasm:buildWaAsync(projDir)
					if message == "" then
						return {
							success = true
						}
					else
						return {
							success = false,
							message = message
						}
					end
				else
					return {
						success = false,
						message = 'Wa file needs a project'
					}
				end
			end
		end
	end
	return {
		success = false,
		message = 'failed to build'
	}
end)
HttpServer:postSchedule("/wa/format", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local file
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					file = _obj_0.file
				end
			end
			if file ~= nil then
				local code = Wasm:formatWaAsync(file)
				if code == "" then
					return {
						success = false
					}
				else
					return {
						success = true,
						code = code
					}
				end
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:postSchedule("/wa/create", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				if not Content:exist(Path:getPath(path)) then
					return {
						success = false,
						message = "target path not existed"
					}
				end
				if Content:exist(path) then
					return {
						success = false,
						message = "target project folder existed"
					}
				end
				local srcPath = Path(Content.assetPath, "dora-wa", "src")
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor")
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod")
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then
					return {
						success = false,
						message = "missing template project"
					}
				end
				if not Content:mkdir(path) then
					return {
						success = false,
						message = "failed to create project folder"
					}
				end
				if not Content:copyAsync(srcPath, Path(path, "src")) then
					Content:remove(path)
					return {
						success = false,
						message = "failed to copy template"
					}
				end
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then
					Content:remove(path)
					return {
						success = false,
						message = "failed to copy template"
					}
				end
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then
					Content:remove(path)
					return {
						success = false,
						message = "failed to copy template"
					}
				end
				return {
					success = true
				}
			end
		end
	end
	return {
		success = false,
		message = "invalid call"
	}
end)
local tsBuildGlobs = {
	"**/*.ts",
	"**/*.tsx",
	"!**/.*/**",
	"!**/node_modules/**"
}
local transpileTSFile
do
	local tsBuildTimeout <const> = 30
	local tsBuildRequestId = 0
	transpileTSFile = function(file, content, sourceRoot)
		tsBuildRequestId = tsBuildRequestId + 1
		local requestId = tsBuildRequestId
		local done = false
		local result = nil
		local listener = Node()
		listener:gslot("AppWS", function(event)
			if event.type == "Receive" then
				local res = json.decode(event.msg)
				if res then
					if res.name == "TranspileTS" and res.id == requestId then
						listener:removeFromParent()
						if res.success then
							local luaFile = Path:replaceExt(file, "lua")
							Content:save(luaFile, res.luaCode)
							result = {
								success = true,
								file = file
							}
						else
							result = {
								success = false,
								file = file,
								message = res.message
							}
						end
						done = true
					end
				end
			end
		end)
		emit("AppWS", "Send", json.encode({
			name = "TranspileTS",
			id = requestId,
			file = file,
			content = content,
			projectRoot = sourceRoot
		}))
		local deadline = App.runningTime + tsBuildTimeout
		wait(function()
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline
		end)
		if not done then
			listener:removeFromParent()
			if HttpServer.wsConnectionCount == 0 then
				return {
					success = false,
					file = file,
					message = "Web IDE disconnected"
				}
			end
			return {
				success = false,
				file = file,
				message = "TypeScript transpile timed out"
			}
		end
		return result
	end
end
local _anon_func_6 = function(path)
	local _val_0 = Path:getExt(path)
	return "ts" == _val_0 or "tsx" == _val_0
end
HttpServer:postSchedule("/ts/build", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local path
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					path = _obj_0.path
				end
			end
			if path ~= nil then
				if HttpServer.wsConnectionCount == 0 then
					return {
						success = false,
						message = "Web IDE not connected"
					}
				end
				local projectRoot = req.body.projectRoot
				local sourceRoot = getProjectSourceRoot(projectRoot)
				if not Content:exist(path) then
					return {
						success = false,
						message = "path not existed"
					}
				end
				if not Content:isdir(path) then
					if not (_anon_func_6(path)) then
						return {
							success = false,
							message = "expecting a TypeScript file"
						}
					end
					local messages = { }
					local content = Content:load(path)
					if not content then
						return {
							success = false,
							message = "failed to read file"
						}
					end
					emit("AppWS", "Send", json.encode({
						name = "UpdateFile",
						file = path,
						exists = true,
						content = content,
						projectRoot = sourceRoot
					}))
					if "d" ~= Path:getExt(Path:getName(path)) then
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot)
					end
					return {
						success = true,
						messages = messages
					}
				else
					local fileData = { }
					local messages = { }
					local _list_0 = Content:glob(path, tsBuildGlobs)
					for _index_0 = 1, #_list_0 do
						local subFile = _list_0[_index_0]
						local file = Path(path, subFile)
						local content = Content:load(file)
						if content then
							fileData[file] = content
							emit("AppWS", "Send", json.encode({
								name = "UpdateFile",
								file = file,
								exists = true,
								content = content,
								projectRoot = sourceRoot
							}))
						else
							messages[#messages + 1] = {
								success = false,
								file = file,
								message = "failed to read file"
							}
						end
					end
					for file, content in pairs(fileData) do
						if "d" == Path:getExt(Path:getName(file)) then
							goto _continue_0
						end
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot)
						::_continue_0::
					end
					return {
						success = true,
						messages = messages
					}
				end
			end
		end
	end
	return {
		success = false
	}
end)
HttpServer:post("/download", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local url
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					url = _obj_0.url
				end
			end
			local target
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					target = _obj_0.target
				end
			end
			if url ~= nil and target ~= nil then
				local Entry = require("Script.Dev.Entry")
				Entry.downloadFile(url, target)
				return {
					success = true
				}
			end
		end
	end
	return {
		success = false
	}
end)
local isDesktopPlatform
isDesktopPlatform = function()
	local _val_0 = App.platform
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0
end
local getServerStatus
getServerStatus = function()
	local Entry = require("Script.Dev.Entry")
	local running = Entry.getCurrentEntryStatus()
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod"))
	local wsConnectionCount = HttpServer.wsConnectionCount
	return {
		success = true,
		platform = App.platform,
		locale = App.locale,
		version = App.version,
		url = "http://localhost:8866",
		wsConnectionCount = wsConnectionCount,
		webIDEConnected = wsConnectionCount > 0,
		assetPath = Content.assetPath,
		writablePath = Content.writablePath,
		appPath = Content.appPath,
		waTemplateReady = waTemplateReady,
		running = running
	}
end
HttpServer:post("/status", function()
	return getServerStatus()
end)
HttpServer:postSchedule("/doctor/fix", function(req)
	do
		local _type_0 = type(req)
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0
		if _tab_0 then
			local openWebIDE
			do
				local _obj_0 = req.body
				local _type_1 = type(_obj_0)
				if "table" == _type_1 or "userdata" == _type_1 then
					openWebIDE = _obj_0.openWebIDE
				end
			end
			if openWebIDE ~= nil then
				if not openWebIDE then
					return {
						success = false,
						message = "nothing to fix"
					}
				end
				local status = getServerStatus()
				if status.webIDEConnected then
					return {
						success = true,
						fixed = false,
						message = "Web IDE already connected.",
						status = status
					}
				end
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3))
				if waitSeconds > 0 then
					local deadline = os.time() + waitSeconds
					repeat
						sleep(0.2)
						status = getServerStatus()
						if status.webIDEConnected then
							return {
								success = true,
								fixed = false,
								reconnected = true,
								message = "Web IDE reconnected.",
								status = status
							}
						end
					until os.time() >= deadline
				end
				if not isDesktopPlatform() then
					return {
						success = false,
						message = "opening Web IDE is only supported on desktop platforms",
						status = status
					}
				end
				local url = "http://localhost:8866"
				App:openURL(url)
				status.openedURL = url
				return {
					success = true,
					fixed = true,
					message = "Opened Web IDE in the local browser.",
					url = url,
					status = status
				}
			end
		end
	end
	return {
		success = false,
		message = "invalid call"
	}
end)
local status = { }
_module_0 = status
status.buildAsync = function(path)
	if not Content:exist(path) then
		return {
			success = false,
			file = path,
			message = "file not existed"
		}
	end
	do
		local _exp_0 = Path:getExt(path)
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then
			if '' == Path:getExt(Path:getName(path)) then
				local content = Content:loadAsync(path)
				if content then
					local resultCodes, err = compileFileAsync(path, content)
					if resultCodes then
						return {
							success = true,
							file = path
						}
					else
						return {
							success = false,
							file = path,
							message = err
						}
					end
				end
			end
		elseif "lua" == _exp_0 then
			local content = Content:loadAsync(path)
			if content then
				do
					local isTIC80 = CheckTIC80Code(content)
					if isTIC80 then
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")")
					end
				end
				local success, info
				do
					local _obj_0 = luaCheck(path, content)
					success, info = _obj_0.success, _obj_0.info
				end
				if success then
					return {
						success = true,
						file = path
					}
				elseif info and #info > 0 then
					local messages = { }
					for _index_0 = 1, #info do
						local _des_0 = info[_index_0]
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5]
						local lineText = ""
						if line then
							local currentLine = 1
							for text in content:gmatch("([^\r\n]*)\r?\n?") do
								if currentLine == line then
									lineText = text
									break
								end
								currentLine = currentLine + 1
							end
						end
						if line then
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message)
						else
							messages[#messages + 1] = message
						end
					end
					return {
						success = false,
						file = path,
						message = table.concat(messages, "\n")
					}
				else
					return {
						success = false,
						file = path,
						message = "lua check failed"
					}
				end
			end
		elseif "yarn" == _exp_0 then
			local content = Content:loadAsync(path)
			if content then
				local res, _, err = yarncompile(content, true)
				if res then
					return {
						success = true,
						file = path
					}
				else
					local message, line, column, node = err[1], err[2], err[3], err[4]
					local lineText = ""
					if line then
						local currentLine = 1
						for text in content:gmatch("([^\r\n]*)\r?\n?") do
							if currentLine == line then
								lineText = text
								break
							end
							currentLine = currentLine + 1
						end
					end
					if node ~= "" then
						node = "node: " .. tostring(node) .. ", "
					else
						node = ""
					end
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message)
					return {
						success = false,
						file = path,
						message = message
					}
				end
			end
		end
	end
	return {
		success = false,
		file = path,
		message = "invalid file to build"
	}
end
thread(function()
	local doraWeb = Path(Content.assetPath, "www", "index.html")
	local doraReady = Path(Content.appPath, ".www", "dora-ready")
	if Content:exist(doraWeb) then
		local readyContent = App.version .. "\n" .. Content:load(doraWeb)
		local needReload
		if Content:exist(doraReady) then
			needReload = readyContent ~= Content:load(doraReady)
		else
			needReload = true
		end
		if needReload then
			Content:remove(Path(Content.appPath, ".www"))
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www"))
			Content:save(doraReady, readyContent)
			print("Dora Dora is ready!")
		end
	end
	if HttpServer:start(8866) then
		local localIP = HttpServer.localIP
		if localIP == "" then
			localIP = "localhost"
		end
		status.url = "http://" .. tostring(localIP) .. ":8866"
		return HttpServer:startWS(8868)
	else
		status.url = nil
		return print("8866 Port not available!")
	end
end)
return _module_0
