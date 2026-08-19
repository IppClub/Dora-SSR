-- [ts]: AgentStorage.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local ____AgentStorageSupport = require("Agent.AgentStorageSupport") -- 4
local toStr = ____AgentStorageSupport.toStr -- 4
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
	local dbPath = Path(Content.appPath, AGENT_DB_FILE) -- 287
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
function ____exports.cleanupTaskHeavyData(taskId) -- 414
	if taskId <= 0 then -- 414
		return false -- 415
	end -- 415
	local status = getTaskStatus(taskId) -- 416
	if status == "" then -- 416
		return false -- 417
	end -- 417
	if status == "RUNNING" or status == "WAITING_USER" then -- 417
		return false -- 418
	end -- 418
	if __TS__ArrayIndexOf( -- 418
		____exports.getAllOperableTaskIds(), -- 419
		taskId -- 419
	) >= 0 then -- 419
		return false -- 419
	end -- 419
	local targets = normalizeTaskIds(DB:query(("SELECT target_task_id FROM " .. ____exports.TABLE_TASK_REFERENCE) .. " WHERE owner_task_id = ?", {taskId})) -- 420
	local success = DB:transaction({ -- 424
		((((("DELETE FROM " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "\n\t\t\tWHERE checkpoint_id IN (SELECT id FROM ") .. ____exports.TABLE_CHECKPOINT) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ");", -- 424
		((("DELETE FROM " .. ____exports.TABLE_CHECKPOINT) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 424
		((("DELETE FROM " .. ____exports.TABLE_STEP) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 424
		((((("DELETE FROM " .. ____exports.TABLE_TASK_REFERENCE) .. "\n\t\t\tWHERE owner_task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\tOR target_task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 424
		((((((((((("DELETE FROM " .. ____exports.TABLE_TASK) .. "\n\t\t\tWHERE id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\tAND NOT EXISTS (\n\t\t\t\t\tSELECT 1 FROM ") .. ____exports.TABLE_MESSAGE) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\t)\n\t\t\t\tAND NOT EXISTS (\n\t\t\t\t\tSELECT 1 FROM ") .. ____exports.TABLE_SESSION) .. " WHERE current_task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\t)\n\t\t\t\t;" -- 424
	}) -- 424
	if not success then -- 424
		return false -- 442
	end -- 442
	Log( -- 443
		"Info", -- 443
		"[AgentStorage] cleaned heavy data task=" .. tostring(taskId) -- 443
	) -- 443
	do -- 443
		local i = 0 -- 444
		while i < #targets do -- 444
			____exports.cleanupTaskHeavyData(targets[i + 1]) -- 445
			i = i + 1 -- 444
		end -- 444
	end -- 444
	return true -- 447
end -- 414
function ____exports.auditOrphanHeavyData() -- 460
	local operable = ____exports.getAllOperableTaskIds() -- 461
	local rows = DB:query(((((((((((((((((("SELECT t.id,\n\t\t\t(SELECT COUNT(*) FROM " .. ____exports.TABLE_CHECKPOINT) .. " c WHERE c.task_id = t.id),\n\t\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. " e\n\t\t\t\tJOIN ") .. ____exports.TABLE_CHECKPOINT) .. " c ON c.id = e.checkpoint_id WHERE c.task_id = t.id),\n\t\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_STEP) .. " s WHERE s.task_id = t.id),\n\t\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_TASK_REFERENCE) .. " r WHERE r.owner_task_id = t.id),\n\t\t\t(SELECT COALESCE(SUM(e.bytes_before + e.bytes_after), 0) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. " e\n\t\t\t\tJOIN ") .. ____exports.TABLE_CHECKPOINT) .. " c ON c.id = e.checkpoint_id WHERE c.task_id = t.id),\n\t\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_MESSAGE) .. " m WHERE m.task_id = t.id)\n\t\tFROM ") .. ____exports.TABLE_TASK) .. " t\n\t\tWHERE t.status NOT IN ('RUNNING', 'WAITING_USER')") or ({}) -- 462
	local audit = { -- 475
		taskCount = 0, -- 476
		checkpointCount = 0, -- 477
		entryCount = 0, -- 478
		stepCount = 0, -- 479
		referenceCount = 0, -- 480
		rawBytes = 0, -- 481
		candidateTaskIds = {} -- 482
	} -- 482
	do -- 482
		local i = 0 -- 484
		while i < #rows do -- 484
			do -- 484
				local taskId = rows[i + 1][1] -- 485
				if __TS__ArrayIndexOf(operable, taskId) >= 0 then -- 485
					goto __continue66 -- 486
				end -- 486
				local checkpointCount = rows[i + 1][2] or 0 -- 487
				local entryCount = rows[i + 1][3] or 0 -- 488
				local stepCount = rows[i + 1][4] or 0 -- 489
				local referenceCount = rows[i + 1][5] or 0 -- 490
				local messageCount = rows[i + 1][7] or 0 -- 491
				if checkpointCount <= 0 and entryCount <= 0 and stepCount <= 0 and referenceCount <= 0 and messageCount > 0 then -- 491
					goto __continue66 -- 499
				end -- 499
				audit.taskCount = audit.taskCount + 1 -- 501
				audit.checkpointCount = audit.checkpointCount + checkpointCount -- 502
				audit.entryCount = audit.entryCount + entryCount -- 503
				audit.stepCount = audit.stepCount + stepCount -- 504
				audit.referenceCount = audit.referenceCount + referenceCount -- 505
				audit.rawBytes = audit.rawBytes + (rows[i + 1][6] or 0) -- 506
				local ____audit_candidateTaskIds_3 = audit.candidateTaskIds -- 506
				____audit_candidateTaskIds_3[#____audit_candidateTaskIds_3 + 1] = taskId -- 507
			end -- 507
			::__continue66:: -- 507
			i = i + 1 -- 484
		end -- 484
	end -- 484
	return audit -- 509
end -- 460
function ____exports.cleanupOrphanHeavyDataBatch(maxTasks) -- 512
	if maxTasks == nil then -- 512
		maxTasks = 4 -- 512
	end -- 512
	local audit = ____exports.auditOrphanHeavyData() -- 513
	local limit = math.max( -- 514
		0, -- 514
		math.floor(maxTasks) -- 514
	) -- 514
	local cleaned = 0 -- 515
	do -- 515
		local i = 0 -- 516
		while i < #audit.candidateTaskIds and cleaned < limit do -- 516
			if ____exports.cleanupTaskHeavyData(audit.candidateTaskIds[i + 1]) then -- 516
				cleaned = cleaned + 1 -- 518
			end -- 518
			i = i + 1 -- 516
		end -- 516
	end -- 516
	if audit.taskCount > 0 then -- 516
		Log( -- 522
			"Info", -- 523
			(((((((((((("[AgentStorage] orphan audit tasks=" .. tostring(audit.taskCount)) .. " checkpoints=") .. tostring(audit.checkpointCount)) .. " entries=") .. tostring(audit.entryCount)) .. " steps=") .. tostring(audit.stepCount)) .. " refs=") .. tostring(audit.referenceCount)) .. " raw_bytes=") .. tostring(audit.rawBytes)) .. " cleaned=") .. tostring(cleaned) -- 523
		) -- 523
	end -- 523
	return audit -- 527
end -- 512
initializeAgentStorage() -- 530
return ____exports -- 530