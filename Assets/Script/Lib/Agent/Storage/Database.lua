-- [ts]: Database.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local ____Support = require("Agent.Storage.Support") -- 4
local toStr = ____Support.toStr -- 4
____exports.AGENT_SCHEMA_VERSION = 1 -- 6
____exports.AGENT_SCHEMA = "agent" -- 7
____exports.TABLE_SESSION = "agent.AgentSession" -- 8
____exports.TABLE_MESSAGE = "agent.AgentSessionMessage" -- 9
____exports.TABLE_STEP = "agent.AgentSessionStep" -- 10
____exports.TABLE_TASK = "agent.AgentTask" -- 11
____exports.TABLE_CHECKPOINT = "agent.AgentCheckpoint" -- 12
____exports.TABLE_CHECKPOINT_ENTRY = "agent.AgentCheckpointEntry" -- 13
____exports.TABLE_TASK_REFERENCE = "agent.AgentTaskReference" -- 14
local AGENT_DB_FILE = "agent.db" -- 16
local REQUIRED_TABLES = { -- 17
	{name = "AgentSession", columns = { -- 18
		"id", -- 21
		"project_root", -- 21
		"title", -- 21
		"kind", -- 21
		"root_session_id", -- 21
		"parent_session_id", -- 22
		"memory_scope", -- 22
		"status", -- 22
		"current_task_id", -- 22
		"current_task_status", -- 23
		"created_at", -- 23
		"updated_at", -- 23
		"metrics_json", -- 23
		"work_mode" -- 24
	}}, -- 24
	{name = "AgentSessionMessage", columns = { -- 27
		"id", -- 30
		"session_id", -- 30
		"task_id", -- 30
		"role", -- 30
		"content", -- 30
		"display_content", -- 31
		"created_at", -- 31
		"updated_at" -- 31
	}}, -- 31
	{name = "AgentSessionStep", columns = { -- 34
		"id", -- 37
		"session_id", -- 37
		"task_id", -- 37
		"step", -- 37
		"tool", -- 37
		"status", -- 37
		"reason", -- 37
		"reasoning_content", -- 38
		"params_json", -- 38
		"result_json", -- 38
		"checkpoint_id", -- 38
		"checkpoint_seq", -- 39
		"files_json", -- 39
		"created_at", -- 39
		"updated_at" -- 39
	}}, -- 39
	{name = "AgentTask", columns = { -- 42
		"id", -- 45
		"status", -- 45
		"prompt", -- 45
		"head_seq", -- 45
		"work_mode", -- 45
		"created_at", -- 46
		"updated_at" -- 46
	}}, -- 46
	{name = "AgentCheckpoint", columns = { -- 49
		"id", -- 52
		"task_id", -- 52
		"seq", -- 52
		"status", -- 52
		"summary", -- 52
		"tool_name", -- 52
		"created_at", -- 53
		"applied_at", -- 53
		"reverted_at" -- 53
	}}, -- 53
	{name = "AgentCheckpointEntry", columns = { -- 56
		"id", -- 59
		"checkpoint_id", -- 59
		"ord", -- 59
		"path", -- 59
		"op", -- 59
		"before_exists", -- 59
		"before_data", -- 60
		"after_exists", -- 60
		"after_data", -- 60
		"bytes_before", -- 60
		"bytes_after" -- 61
	}}, -- 61
	{name = "AgentTaskReference", columns = {"owner_task_id", "target_task_id", "kind", "created_at"}} -- 64
} -- 64
local REQUIRED_INDEXES = { -- 70
	"idx_agent_session_project_root", -- 71
	"idx_agent_session_message_sid_id", -- 72
	"idx_agent_session_step_unique", -- 73
	"idx_agent_session_step_sid_task_step", -- 74
	"idx_agent_cp_task_seq", -- 75
	"idx_agent_entry_cp_ord", -- 76
	"idx_agent_task_ref_target" -- 77
} -- 77
local DROP_AGENT_SCHEMA_SQL = { -- 80
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. ";", -- 80
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_CHECKPOINT) .. ";", -- 80
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_STEP) .. ";", -- 80
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_MESSAGE) .. ";", -- 80
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_TASK_REFERENCE) .. ";", -- 80
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_SESSION) .. ";", -- 80
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_TASK) .. ";" -- 80
} -- 80
local CREATE_AGENT_SCHEMA_SQL = { -- 90
	("CREATE TABLE " .. ____exports.TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL,\n\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t);", -- 90
	"CREATE INDEX agent.idx_agent_session_project_root\n\t\tON AgentSession(project_root, updated_at DESC);", -- 107
	("CREATE TABLE " .. ____exports.TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 107
	"CREATE INDEX agent.idx_agent_session_message_sid_id\n\t\tON AgentSessionMessage(session_id, id);", -- 119
	("CREATE TABLE " .. ____exports.TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 119
	"CREATE UNIQUE INDEX agent.idx_agent_session_step_unique\n\t\tON AgentSessionStep(session_id, task_id, step);", -- 138
	"CREATE INDEX agent.idx_agent_session_step_sid_task_step\n\t\tON AgentSessionStep(session_id, task_id, step);", -- 140
	("CREATE TABLE " .. ____exports.TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\twork_mode TEXT NOT NULL DEFAULT 'code',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 140
	("CREATE TABLE " .. ____exports.TABLE_CHECKPOINT) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);", -- 140
	"CREATE INDEX agent.idx_agent_cp_task_seq\n\t\tON AgentCheckpoint(task_id, seq);", -- 162
	("CREATE TABLE " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_data BLOB,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_data BLOB,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);", -- 162
	"CREATE INDEX agent.idx_agent_entry_cp_ord\n\t\tON AgentCheckpointEntry(checkpoint_id, ord);", -- 177
	("CREATE TABLE " .. ____exports.TABLE_TASK_REFERENCE) .. "(\n\t\towner_task_id INTEGER NOT NULL,\n\t\ttarget_task_id INTEGER NOT NULL,\n\t\tkind TEXT NOT NULL,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tPRIMARY KEY(owner_task_id, target_task_id, kind)\n\t);", -- 177
	"CREATE INDEX agent.idx_agent_task_ref_target\n\t\tON AgentTaskReference(target_task_id);", -- 186
	("PRAGMA agent.user_version = " .. tostring(____exports.AGENT_SCHEMA_VERSION)) .. ";" -- 186
} -- 186
local DROP_LEGACY_AGENT_SQL = { -- 191
	"DROP TABLE IF EXISTS main.AgentCheckpointEntry;", -- 192
	"DROP TABLE IF EXISTS main.AgentCheckpoint;", -- 193
	"DROP TABLE IF EXISTS main.AgentSessionStep;", -- 194
	"DROP TABLE IF EXISTS main.AgentSessionMessage;", -- 195
	"DROP TABLE IF EXISTS main.AgentSession;", -- 196
	"DROP TABLE IF EXISTS main.AgentTaskReference;", -- 197
	"DROP TABLE IF EXISTS main.AgentTask;", -- 198
	"DROP TABLE IF EXISTS main.AgentQuestionnaire;" -- 199
} -- 199
local storageError -- 202
local storageReady = false -- 203
local function getSchemaVersion() -- 205
	local rows = DB:query("PRAGMA agent.user_version") -- 206
	if not rows or #rows == 0 or type(rows[1][1]) ~= "number" then -- 206
		return nil -- 207
	end -- 207
	return math.max( -- 208
		0, -- 208
		math.floor(rows[1][1]) -- 208
	) -- 208
end -- 205
local function rebuildSchema() -- 211
	local tableRows = DB:query("SELECT name FROM agent.sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'") or ({}) -- 212
	local dropAllTables = {} -- 215
	do -- 215
		local i = 0 -- 216
		while i < #tableRows do -- 216
			do -- 216
				local tableName = toStr(tableRows[i + 1][1]) -- 217
				if tableName == "" then -- 217
					goto __continue6 -- 218
				end -- 218
				local quotedName = string.gsub(tableName, "\"", "\"\"") -- 219
				dropAllTables[#dropAllTables + 1] = ("DROP TABLE IF EXISTS agent.\"" .. quotedName) .. "\";" -- 220
			end -- 220
			::__continue6:: -- 220
			i = i + 1 -- 216
		end -- 216
	end -- 216
	local ____DB_1 = DB -- 222
	local ____DB_transaction_2 = DB.transaction -- 222
	local ____array_0 = __TS__SparseArrayNew(table.unpack(dropAllTables)) -- 222
	__TS__SparseArrayPush( -- 222
		____array_0, -- 222
		table.unpack(DROP_AGENT_SCHEMA_SQL) -- 222
	) -- 222
	__TS__SparseArrayPush( -- 222
		____array_0, -- 222
		table.unpack(CREATE_AGENT_SCHEMA_SQL) -- 222
	) -- 222
	return ____DB_transaction_2( -- 222
		____DB_1, -- 222
		{__TS__SparseArraySpread(____array_0)} -- 222
	) -- 222
end -- 211
local function validateSchema() -- 225
	do -- 225
		local i = 0 -- 226
		while i < #REQUIRED_TABLES do -- 226
			local required = REQUIRED_TABLES[i + 1] -- 227
			local rows = DB:query(("PRAGMA agent.table_info(" .. required.name) .. ")") -- 228
			if not rows or #rows ~= #required.columns then -- 228
				return ("table " .. required.name) .. " has an unexpected column count" -- 230
			end -- 230
			do -- 230
				local j = 0 -- 232
				while j < #required.columns do -- 232
					if toStr(rows[j + 1][2]) ~= required.columns[j + 1] then -- 232
						return ("table " .. required.name) .. " has an unexpected schema" -- 234
					end -- 234
					j = j + 1 -- 232
				end -- 232
			end -- 232
			i = i + 1 -- 226
		end -- 226
	end -- 226
	local indexRows = DB:query("SELECT name FROM agent.sqlite_master WHERE type = 'index' AND name LIKE 'idx_agent_%'") or ({}) -- 238
	local indexes = {} -- 241
	do -- 241
		local i = 0 -- 242
		while i < #indexRows do -- 242
			indexes[toStr(indexRows[i + 1][1])] = true -- 243
			i = i + 1 -- 242
		end -- 242
	end -- 242
	do -- 242
		local i = 0 -- 245
		while i < #REQUIRED_INDEXES do -- 245
			if not indexes[REQUIRED_INDEXES[i + 1]] then -- 245
				return "missing index " .. REQUIRED_INDEXES[i + 1] -- 247
			end -- 247
			i = i + 1 -- 245
		end -- 245
	end -- 245
	return nil -- 250
end -- 225
local function validateCodecAndWrite() -- 253
	local binaryProbe = "Dora\0Blob\0Probe" -- 254
	local smallProbe = "Dora Agent small text" -- 255
	local compressedProbe = "Dora Agent checkpoint codec probe：" .. string.rep("压缩内容", 128) -- 256
	local rows = DB:query("SELECT\n\t\t\tCAST(? AS BLOB),\n\t\t\ttypeof(CAST(? AS BLOB)),\n\t\t\tdora_decompress_text(dora_compress_text(?)),\n\t\t\ttypeof(dora_compress_text(?)),\n\t\t\tdora_decompress_text(dora_compress_text(?)),\n\t\t\ttypeof(dora_compress_text(?))", { -- 257
		binaryProbe, -- 265
		binaryProbe, -- 265
		smallProbe, -- 265
		smallProbe, -- 265
		compressedProbe, -- 265
		compressedProbe -- 265
	}) -- 265
	if not rows or #rows ~= 1 or toStr(rows[1][1]) ~= binaryProbe or toStr(rows[1][2]) ~= "blob" or toStr(rows[1][3]) ~= smallProbe or toStr(rows[1][4]) ~= "text" or toStr(rows[1][5]) ~= compressedProbe or toStr(rows[1][6]) ~= "blob" then -- 265
		return false -- 277
	end -- 277
	return DB:transaction({"CREATE TABLE agent.AgentStorageProbe(value INTEGER NOT NULL);", "INSERT INTO agent.AgentStorageProbe(value) VALUES(1);", "DROP TABLE agent.AgentStorageProbe;"}) -- 279
end -- 253
local function initializeAgentStorage() -- 286
	local dbPath = Path(App.platform == "Web" and Content.writablePath or Content.appPath, AGENT_DB_FILE) -- 287
	if not DB:existDB(____exports.AGENT_SCHEMA) then -- 287
		DB:exec("ATTACH DATABASE ? AS " .. ____exports.AGENT_SCHEMA, {dbPath}) -- 289
	end -- 289
	if not DB:existDB(____exports.AGENT_SCHEMA) then -- 289
		storageError = "failed to attach " .. dbPath -- 292
		return -- 293
	end -- 293
	local version = getSchemaVersion() -- 296
	if version == nil then -- 296
		storageError = "failed to read agent.db schema version" -- 298
		return -- 299
	end -- 299
	if version > ____exports.AGENT_SCHEMA_VERSION then -- 299
		storageError = (("agent.db schema " .. tostring(version)) .. " is newer than supported ") .. tostring(____exports.AGENT_SCHEMA_VERSION) -- 302
		return -- 303
	end -- 303
	if version < ____exports.AGENT_SCHEMA_VERSION and not rebuildSchema() then -- 303
		storageError = "failed to create current agent.db schema" -- 306
		return -- 307
	end -- 307
	local schemaError = validateSchema() -- 309
	if schemaError then -- 309
		storageError = "agent.db schema error: " .. schemaError -- 311
		return -- 312
	end -- 312
	if not validateCodecAndWrite() then -- 312
		storageError = "agent.db codec or write probe failed" -- 315
		return -- 316
	end -- 316
	if not DB:transaction(DROP_LEGACY_AGENT_SQL) then -- 316
		storageError = "failed to remove legacy Agent tables from dora.db" -- 319
		return -- 320
	end -- 320
	storageReady = true -- 322
	Log( -- 323
		"Info", -- 323
		(("[AgentStorage] ready path=" .. dbPath) .. " schema=") .. tostring(____exports.AGENT_SCHEMA_VERSION) -- 323
	) -- 323
end -- 286
function ____exports.isAgentStorageReady() -- 326
	return storageReady -- 327
end -- 326
function ____exports.getAgentStorageError() -- 330
	return storageError -- 331
end -- 330
function ____exports.requireAgentStorage() -- 334
	if storageReady then -- 334
		return {success = true} -- 335
	end -- 335
	return {success = false, message = storageError and "Agent database unavailable: " .. storageError or "Agent database unavailable"} -- 336
end -- 334
local function normalizeTaskIds(rows) -- 342
	local result = {} -- 343
	if not rows then -- 343
		return result -- 344
	end -- 344
	do -- 344
		local i = 0 -- 345
		while i < #rows do -- 345
			local taskId = type(rows[i + 1][1]) == "number" and math.floor(rows[i + 1][1]) or 0 -- 346
			if taskId > 0 and __TS__ArrayIndexOf(result, taskId) < 0 then -- 346
				result[#result + 1] = taskId -- 347
			end -- 347
			i = i + 1 -- 345
		end -- 345
	end -- 345
	return result -- 349
end -- 342
function ____exports.getTaskReferenceClosure(rootTaskIds) -- 352
	local closure = {} -- 353
	local seen = {} -- 354
	local queue = {} -- 355
	do -- 355
		local i = 0 -- 356
		while i < #rootTaskIds do -- 356
			do -- 356
				local taskId = math.floor(rootTaskIds[i + 1]) -- 357
				if taskId <= 0 or seen[taskId] then -- 357
					goto __continue42 -- 358
				end -- 358
				seen[taskId] = true -- 359
				closure[#closure + 1] = taskId -- 360
				queue[#queue + 1] = taskId -- 361
			end -- 361
			::__continue42:: -- 361
			i = i + 1 -- 356
		end -- 356
	end -- 356
	do -- 356
		local offset = 0 -- 363
		while offset < #queue do -- 363
			local ownerTaskId = queue[offset + 1] -- 364
			local targets = normalizeTaskIds(DB:query(("SELECT target_task_id FROM " .. ____exports.TABLE_TASK_REFERENCE) .. " WHERE owner_task_id = ?", {ownerTaskId})) -- 365
			do -- 365
				local i = 0 -- 369
				while i < #targets do -- 369
					do -- 369
						local targetTaskId = targets[i + 1] -- 370
						if seen[targetTaskId] then -- 370
							goto __continue47 -- 371
						end -- 371
						seen[targetTaskId] = true -- 372
						closure[#closure + 1] = targetTaskId -- 373
						queue[#queue + 1] = targetTaskId -- 374
					end -- 374
					::__continue47:: -- 374
					i = i + 1 -- 369
				end -- 369
			end -- 369
			offset = offset + 1 -- 363
		end -- 363
	end -- 363
	return closure -- 377
end -- 352
function ____exports.getSessionOperableTaskIds(sessionId) -- 380
	local roots = normalizeTaskIds(DB:query(("SELECT current_task_id FROM " .. ____exports.TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0", {sessionId})) -- 381
	return ____exports.getTaskReferenceClosure(roots) -- 385
end -- 380
function ____exports.getAllOperableTaskIds() -- 388
	local roots = normalizeTaskIds(DB:query(("SELECT current_task_id FROM " .. ____exports.TABLE_SESSION) .. " WHERE current_task_id > 0")) -- 389
	return ____exports.getTaskReferenceClosure(roots) -- 392
end -- 388
function ____exports.addTaskReference(ownerTaskId, targetTaskId, kind) -- 395
	if kind == nil then -- 395
		kind = "sub_agent_handoff" -- 395
	end -- 395
	if ownerTaskId <= 0 or targetTaskId <= 0 or ownerTaskId == targetTaskId then -- 395
		return false -- 396
	end -- 396
	return DB:exec( -- 397
		("INSERT OR IGNORE INTO " .. ____exports.TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\tVALUES(?, ?, ?, ?)", -- 397
		{ -- 400
			ownerTaskId, -- 400
			targetTaskId, -- 400
			kind, -- 400
			os.time() -- 400
		} -- 400
	) >= 0 -- 400
end -- 395
function ____exports.isTaskOperableForSession(sessionId, taskId) -- 404
	if sessionId <= 0 or taskId <= 0 then -- 404
		return false -- 405
	end -- 405
	return __TS__ArrayIndexOf( -- 406
		____exports.getSessionOperableTaskIds(sessionId), -- 406
		taskId -- 406
	) >= 0 -- 406
end -- 404
local function getTaskStatus(taskId) -- 409
	local rows = DB:query(("SELECT status FROM " .. ____exports.TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 410
	return rows and #rows > 0 and toStr(rows[1][1]) or "" -- 411
end -- 409
local function getProtectedTaskIds() -- 416
	local rows = DB:query(((((("WITH RECURSIVE protected(id) AS (\n\t\tSELECT current_task_id FROM " .. ____exports.TABLE_SESSION) .. " WHERE current_task_id > 0\n\t\tUNION SELECT id FROM ") .. ____exports.TABLE_TASK) .. " WHERE status IN ('RUNNING', 'WAITING_USER')\n\t\tUNION SELECT r.target_task_id FROM ") .. ____exports.TABLE_TASK_REFERENCE) .. " r\n\t\t\tJOIN protected p ON r.owner_task_id = p.id\n\t) SELECT id FROM protected") -- 417
	return rows and normalizeTaskIds(rows) or nil -- 423
end -- 416
local function cleanupTaskHeavyDataRecord(taskId) -- 427
	if taskId <= 0 then -- 427
		return nil -- 428
	end -- 428
	local status = getTaskStatus(taskId) -- 429
	if status == "" or status == "RUNNING" or status == "WAITING_USER" then -- 429
		return nil -- 430
	end -- 430
	local protectedIds = getProtectedTaskIds() -- 431
	if not protectedIds or __TS__ArrayIndexOf(protectedIds, taskId) >= 0 then -- 431
		return nil -- 432
	end -- 432
	local targets = normalizeTaskIds(DB:query(("SELECT target_task_id FROM " .. ____exports.TABLE_TASK_REFERENCE) .. " WHERE owner_task_id = ?", {taskId})) -- 433
	local success = DB:transaction({ -- 437
		((((("DELETE FROM " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "\n\t\t\tWHERE checkpoint_id IN (SELECT id FROM ") .. ____exports.TABLE_CHECKPOINT) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ");", -- 437
		((("DELETE FROM " .. ____exports.TABLE_CHECKPOINT) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 437
		((("DELETE FROM " .. ____exports.TABLE_STEP) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 437
		((((("DELETE FROM " .. ____exports.TABLE_TASK_REFERENCE) .. "\n\t\t\tWHERE owner_task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\tOR target_task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 437
		((((((((((("DELETE FROM " .. ____exports.TABLE_TASK) .. "\n\t\t\tWHERE id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\tAND NOT EXISTS (\n\t\t\t\t\tSELECT 1 FROM ") .. ____exports.TABLE_MESSAGE) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\t)\n\t\t\t\tAND NOT EXISTS (\n\t\t\t\t\tSELECT 1 FROM ") .. ____exports.TABLE_SESSION) .. " WHERE current_task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\t)\n\t\t\t\t;" -- 437
	}) -- 437
	if not success then -- 437
		return nil -- 455
	end -- 455
	Log( -- 456
		"Info", -- 456
		"[AgentStorage] cleaned heavy data task=" .. tostring(taskId) -- 456
	) -- 456
	return targets -- 457
end -- 427
function ____exports.cleanupTaskHeavyData(taskId) -- 460
	local targets = cleanupTaskHeavyDataRecord(taskId) -- 461
	if not targets then -- 461
		return false -- 462
	end -- 462
	do -- 462
		local i = 0 -- 463
		while i < #targets do -- 463
			____exports.cleanupTaskHeavyData(targets[i + 1]) -- 463
			i = i + 1 -- 463
		end -- 463
	end -- 463
	return true -- 464
end -- 460
function ____exports.auditOrphanHeavyData() -- 478
	local protectedIds = getProtectedTaskIds() -- 479
	local ____protectedIds_3 -- 482
	if protectedIds then -- 482
		____protectedIds_3 = DB:query(((((((((((((("WITH\n\t\tcp AS (SELECT task_id, COUNT(*) AS n FROM " .. ____exports.TABLE_CHECKPOINT) .. " GROUP BY task_id),\n\t\tentries AS (SELECT c.task_id, COUNT(*) AS n, SUM(e.bytes_before + e.bytes_after) AS raw_bytes\n\t\t\tFROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. " e JOIN ") .. ____exports.TABLE_CHECKPOINT) .. " c ON c.id = e.checkpoint_id GROUP BY c.task_id),\n\t\tsteps AS (SELECT task_id, COUNT(*) AS n FROM ") .. ____exports.TABLE_STEP) .. " GROUP BY task_id),\n\t\trefs AS (SELECT owner_task_id, COUNT(*) AS n FROM ") .. ____exports.TABLE_TASK_REFERENCE) .. " GROUP BY owner_task_id),\n\t\tmessages AS (SELECT task_id, COUNT(*) AS n FROM ") .. ____exports.TABLE_MESSAGE) .. " GROUP BY task_id)\n\t\tSELECT t.id, COALESCE(cp.n, 0), COALESCE(entries.n, 0), COALESCE(steps.n, 0),\n\t\t\tCOALESCE(refs.n, 0), COALESCE(entries.raw_bytes, 0), COALESCE(messages.n, 0)\n\t\tFROM ") .. ____exports.TABLE_TASK) .. " t\n\t\tLEFT JOIN cp ON cp.task_id = t.id\n\t\tLEFT JOIN entries ON entries.task_id = t.id\n\t\tLEFT JOIN steps ON steps.task_id = t.id\n\t\tLEFT JOIN refs ON refs.owner_task_id = t.id\n\t\tLEFT JOIN messages ON messages.task_id = t.id\n\t\tWHERE t.status NOT IN ('RUNNING', 'WAITING_USER') ORDER BY t.id") -- 482
	else -- 482
		____protectedIds_3 = nil -- 497
	end -- 497
	local rows = ____protectedIds_3 -- 482
	local audit = { -- 498
		success = protectedIds ~= nil and rows ~= nil, -- 499
		taskCount = 0, -- 500
		checkpointCount = 0, -- 501
		entryCount = 0, -- 502
		stepCount = 0, -- 503
		referenceCount = 0, -- 504
		rawBytes = 0, -- 505
		candidateTaskIds = {} -- 506
	} -- 506
	if not rows or not protectedIds then -- 506
		return audit -- 508
	end -- 508
	local protectedTasks = {} -- 509
	for ____, id in ipairs(protectedIds) do -- 510
		protectedTasks[id] = true -- 510
	end -- 510
	do -- 510
		local i = 0 -- 511
		while i < #rows do -- 511
			do -- 511
				local taskId = rows[i + 1][1] -- 512
				if protectedTasks[taskId] then -- 512
					goto __continue71 -- 513
				end -- 513
				local checkpointCount = rows[i + 1][2] or 0 -- 514
				local entryCount = rows[i + 1][3] or 0 -- 515
				local stepCount = rows[i + 1][4] or 0 -- 516
				local referenceCount = rows[i + 1][5] or 0 -- 517
				local messageCount = rows[i + 1][7] or 0 -- 518
				if checkpointCount <= 0 and entryCount <= 0 and stepCount <= 0 and referenceCount <= 0 and messageCount > 0 then -- 518
					goto __continue71 -- 526
				end -- 526
				audit.taskCount = audit.taskCount + 1 -- 528
				audit.checkpointCount = audit.checkpointCount + checkpointCount -- 529
				audit.entryCount = audit.entryCount + entryCount -- 530
				audit.stepCount = audit.stepCount + stepCount -- 531
				audit.referenceCount = audit.referenceCount + referenceCount -- 532
				audit.rawBytes = audit.rawBytes + (rows[i + 1][6] or 0) -- 533
				local ____audit_candidateTaskIds_4 = audit.candidateTaskIds -- 533
				____audit_candidateTaskIds_4[#____audit_candidateTaskIds_4 + 1] = taskId -- 534
			end -- 534
			::__continue71:: -- 534
			i = i + 1 -- 511
		end -- 511
	end -- 511
	return audit -- 536
end -- 478
local orphanSweepCursor = 0 -- 544
function ____exports.cleanupOrphanHeavyDataBatch(maxTasks) -- 546
	if maxTasks == nil then -- 546
		maxTasks = 4 -- 546
	end -- 546
	local audit = ____exports.auditOrphanHeavyData() -- 547
	local limit = math.max( -- 548
		0, -- 548
		math.min( -- 548
			16, -- 548
			math.floor(maxTasks) -- 548
		) -- 548
	) -- 548
	local cleanedTaskCount = 0 -- 549
	local failedTaskCount = 0 -- 550
	local ids = audit.candidateTaskIds -- 551
	local nextIndex = __TS__ArrayFindIndex( -- 552
		ids, -- 552
		function(____, id) return id > orphanSweepCursor end -- 552
	) -- 552
	local start = nextIndex >= 0 and nextIndex or 0 -- 553
	do -- 553
		local i = 0 -- 554
		while audit.success and i < #ids and i < limit do -- 554
			local taskId = ids[(start + i) % #ids + 1] -- 555
			orphanSweepCursor = taskId -- 558
			if cleanupTaskHeavyDataRecord(taskId) ~= nil then -- 558
				cleanedTaskCount = cleanedTaskCount + 1 -- 559
			else -- 559
				failedTaskCount = failedTaskCount + 1 -- 560
			end -- 560
			i = i + 1 -- 554
		end -- 554
	end -- 554
	if not audit.success or audit.taskCount > 0 then -- 554
		Log( -- 563
			audit.success and "Info" or "Warn", -- 563
			(((((((((((((("[AgentStorage] orphan audit success=" .. tostring(audit.success)) .. " tasks=") .. tostring(audit.taskCount)) .. " checkpoints=") .. tostring(audit.checkpointCount)) .. " entries=") .. tostring(audit.entryCount)) .. " steps=") .. tostring(audit.stepCount)) .. " raw_bytes=") .. tostring(audit.rawBytes)) .. " cleaned=") .. tostring(cleanedTaskCount)) .. " failed=") .. tostring(failedTaskCount) -- 563
		) -- 563
	end -- 563
	return __TS__ObjectAssign({}, audit, {cleanedTaskCount = cleanedTaskCount, failedTaskCount = failedTaskCount}) -- 566
end -- 546
function ____exports.getStorageUsage() -- 577
	local ready = ____exports.requireAgentStorage() -- 578
	if not ready.success then -- 578
		return ready -- 579
	end -- 579
	local pageSize = DB:query("PRAGMA agent.page_size") -- 580
	local pageCount = DB:query("PRAGMA agent.page_count") -- 581
	local freeCount = DB:query("PRAGMA agent.freelist_count") -- 582
	local rows = DB:query(((((((((((((((((((((((("SELECT\n\t\t(SELECT COUNT(*) FROM " .. ____exports.TABLE_SESSION) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_MESSAGE) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_TASK) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_STEP) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_CHECKPOINT) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_TASK_REFERENCE) .. "),\n\t\t(SELECT COALESCE(SUM(length(CAST(content AS BLOB)) + length(CAST(display_content AS BLOB))), 0) FROM ") .. ____exports.TABLE_MESSAGE) .. "),\n\t\t(SELECT COALESCE(SUM(length(CAST(prompt AS BLOB))), 0) FROM ") .. ____exports.TABLE_TASK) .. "),\n\t\t(SELECT COALESCE(SUM(length(CAST(reason AS BLOB)) + length(CAST(reasoning_content AS BLOB))\n\t\t\t+ length(CAST(params_json AS BLOB)) + length(CAST(result_json AS BLOB)) + length(CAST(files_json AS BLOB))), 0) FROM ") .. ____exports.TABLE_STEP) .. "),\n\t\t(SELECT COALESCE(SUM(bytes_before + bytes_after), 0) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "),\n\t\t(SELECT COALESCE(SUM(COALESCE(length(CAST(before_data AS BLOB)), 0) + COALESCE(length(CAST(after_data AS BLOB)), 0)), 0) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. ")") -- 583
	local orphanHeavyData = ____exports.auditOrphanHeavyData() -- 597
	if not (pageSize and pageSize[1]) or not (pageCount and pageCount[1]) or not (freeCount and freeCount[1]) or not (rows and rows[1]) or not orphanHeavyData.success then -- 597
		return {success = false, message = "failed to read Agent storage usage"} -- 599
	end -- 599
	local size = pageSize[1][1] -- 601
	local pages = pageCount[1][1] -- 602
	local free = freeCount[1][1] -- 603
	local r = rows[1] -- 604
	return {success = true, usage = {database = { -- 605
		allocatedBytes = size * pages, -- 606
		freeBytes = size * free, -- 606
		usedBytes = size * (pages - free), -- 606
		pageSize = size, -- 606
		pageCount = pages, -- 606
		freePageCount = free -- 606
	}, records = { -- 606
		sessions = r[1], -- 607
		messages = r[2], -- 607
		tasks = r[3], -- 607
		steps = r[4], -- 607
		checkpoints = r[5], -- 607
		entries = r[6], -- 607
		references = r[7] -- 607
	}, payload = { -- 607
		messageBytes = r[8], -- 608
		taskPromptBytes = r[9], -- 608
		stepBytes = r[10], -- 608
		checkpointRawBytes = r[11], -- 608
		checkpointStoredBytes = r[12] -- 608
	}, orphanHeavyData = orphanHeavyData}} -- 608
end -- 577
initializeAgentStorage() -- 613
return ____exports -- 613