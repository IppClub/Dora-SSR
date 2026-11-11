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
____exports.AGENT_SCHEMA_VERSION = 2 -- 6
____exports.AGENT_SCHEMA = "agent" -- 7
____exports.TABLE_SESSION = "agent.AgentSession" -- 8
____exports.TABLE_MESSAGE = "agent.AgentSessionMessage" -- 9
____exports.TABLE_STEP = "agent.AgentSessionStep" -- 10
____exports.TABLE_TASK = "agent.AgentTask" -- 11
____exports.TABLE_CHECKPOINT = "agent.AgentCheckpoint" -- 12
____exports.TABLE_CHECKPOINT_ENTRY = "agent.AgentCheckpointEntry" -- 13
____exports.TABLE_TASK_REFERENCE = "agent.AgentTaskReference" -- 14
local INPUT_SCHEMA_SQL = {"CREATE TABLE agent.AgentSessionInput(id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER NOT NULL,\n request_id TEXT NOT NULL, content TEXT NOT NULL, delivery TEXT NOT NULL, status TEXT NOT NULL,\n held INTEGER NOT NULL DEFAULT 0, task_id INTEGER, options_json TEXT NOT NULL, position INTEGER NOT NULL, message_id INTEGER, delivered_step INTEGER,\n UNIQUE(session_id,request_id));", "CREATE INDEX agent.idx_agent_input_pending ON AgentSessionInput(session_id,status,position);", "CREATE INDEX agent.idx_agent_input_message ON AgentSessionInput(message_id);"} -- 16
local AGENT_DB_FILE = "agent.db" -- 25
local REQUIRED_TABLES = { -- 26
	{name = "AgentSessionInput", columns = { -- 27
		"id", -- 27
		"session_id", -- 27
		"request_id", -- 27
		"content", -- 27
		"delivery", -- 27
		"status", -- 27
		"held", -- 27
		"task_id", -- 27
		"options_json", -- 27
		"position", -- 27
		"message_id", -- 27
		"delivered_step" -- 27
	}}, -- 27
	{name = "AgentSession", columns = { -- 28
		"id", -- 31
		"project_root", -- 31
		"title", -- 31
		"kind", -- 31
		"root_session_id", -- 31
		"parent_session_id", -- 32
		"memory_scope", -- 32
		"status", -- 32
		"current_task_id", -- 32
		"current_task_status", -- 33
		"created_at", -- 33
		"updated_at", -- 33
		"metrics_json", -- 33
		"work_mode" -- 34
	}}, -- 34
	{name = "AgentSessionMessage", columns = { -- 37
		"id", -- 40
		"session_id", -- 40
		"task_id", -- 40
		"role", -- 40
		"content", -- 40
		"display_content", -- 41
		"created_at", -- 41
		"updated_at" -- 41
	}}, -- 41
	{name = "AgentSessionStep", columns = { -- 44
		"id", -- 47
		"session_id", -- 47
		"task_id", -- 47
		"step", -- 47
		"tool", -- 47
		"status", -- 47
		"reason", -- 47
		"reasoning_content", -- 48
		"params_json", -- 48
		"result_json", -- 48
		"checkpoint_id", -- 48
		"checkpoint_seq", -- 49
		"files_json", -- 49
		"created_at", -- 49
		"updated_at" -- 49
	}}, -- 49
	{name = "AgentTask", columns = { -- 52
		"id", -- 55
		"status", -- 55
		"prompt", -- 55
		"head_seq", -- 55
		"work_mode", -- 55
		"created_at", -- 56
		"updated_at" -- 56
	}}, -- 56
	{name = "AgentCheckpoint", columns = { -- 59
		"id", -- 62
		"task_id", -- 62
		"seq", -- 62
		"status", -- 62
		"summary", -- 62
		"tool_name", -- 62
		"created_at", -- 63
		"applied_at", -- 63
		"reverted_at" -- 63
	}}, -- 63
	{name = "AgentCheckpointEntry", columns = { -- 66
		"id", -- 69
		"checkpoint_id", -- 69
		"ord", -- 69
		"path", -- 69
		"op", -- 69
		"before_exists", -- 69
		"before_data", -- 70
		"after_exists", -- 70
		"after_data", -- 70
		"bytes_before", -- 70
		"bytes_after" -- 71
	}}, -- 71
	{name = "AgentTaskReference", columns = {"owner_task_id", "target_task_id", "kind", "created_at"}} -- 74
} -- 74
local REQUIRED_INDEXES = { -- 80
	"idx_agent_input_pending", -- 81
	"idx_agent_input_message", -- 82
	"idx_agent_session_project_root", -- 83
	"idx_agent_session_message_sid_id", -- 84
	"idx_agent_session_step_unique", -- 85
	"idx_agent_session_step_sid_task_step", -- 86
	"idx_agent_cp_task_seq", -- 87
	"idx_agent_entry_cp_ord", -- 88
	"idx_agent_task_ref_target" -- 89
} -- 89
local DROP_AGENT_SCHEMA_SQL = { -- 92
	"DROP TABLE IF EXISTS agent.AgentSessionInput;", -- 93
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. ";", -- 93
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_CHECKPOINT) .. ";", -- 93
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_STEP) .. ";", -- 93
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_MESSAGE) .. ";", -- 93
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_TASK_REFERENCE) .. ";", -- 93
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_SESSION) .. ";", -- 93
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_TASK) .. ";" -- 93
} -- 93
local ____array_0 = __TS__SparseArrayNew(table.unpack(INPUT_SCHEMA_SQL)) -- 93
__TS__SparseArrayPush( -- 93
	____array_0, -- 93
	("CREATE TABLE " .. ____exports.TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL,\n\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t);", -- 93
	"CREATE INDEX agent.idx_agent_session_project_root\n\t\tON AgentSession(project_root, updated_at DESC);", -- 121
	("CREATE TABLE " .. ____exports.TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 121
	"CREATE INDEX agent.idx_agent_session_message_sid_id\n\t\tON AgentSessionMessage(session_id, id);", -- 133
	("CREATE TABLE " .. ____exports.TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 133
	"CREATE UNIQUE INDEX agent.idx_agent_session_step_unique\n\t\tON AgentSessionStep(session_id, task_id, step);", -- 152
	"CREATE INDEX agent.idx_agent_session_step_sid_task_step\n\t\tON AgentSessionStep(session_id, task_id, step);", -- 154
	("CREATE TABLE " .. ____exports.TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\twork_mode TEXT NOT NULL DEFAULT 'code',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 154
	("CREATE TABLE " .. ____exports.TABLE_CHECKPOINT) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);", -- 154
	"CREATE INDEX agent.idx_agent_cp_task_seq\n\t\tON AgentCheckpoint(task_id, seq);", -- 176
	("CREATE TABLE " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_data BLOB,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_data BLOB,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);", -- 176
	"CREATE INDEX agent.idx_agent_entry_cp_ord\n\t\tON AgentCheckpointEntry(checkpoint_id, ord);", -- 191
	("CREATE TABLE " .. ____exports.TABLE_TASK_REFERENCE) .. "(\n\t\towner_task_id INTEGER NOT NULL,\n\t\ttarget_task_id INTEGER NOT NULL,\n\t\tkind TEXT NOT NULL,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tPRIMARY KEY(owner_task_id, target_task_id, kind)\n\t);", -- 191
	"CREATE INDEX agent.idx_agent_task_ref_target\n\t\tON AgentTaskReference(target_task_id);", -- 200
	("PRAGMA agent.user_version = " .. tostring(____exports.AGENT_SCHEMA_VERSION)) .. ";" -- 200
) -- 200
local CREATE_AGENT_SCHEMA_SQL = {__TS__SparseArraySpread(____array_0)} -- 103
local DROP_LEGACY_AGENT_SQL = { -- 205
	"DROP TABLE IF EXISTS main.AgentCheckpointEntry;", -- 206
	"DROP TABLE IF EXISTS main.AgentCheckpoint;", -- 207
	"DROP TABLE IF EXISTS main.AgentSessionStep;", -- 208
	"DROP TABLE IF EXISTS main.AgentSessionMessage;", -- 209
	"DROP TABLE IF EXISTS main.AgentSession;", -- 210
	"DROP TABLE IF EXISTS main.AgentTaskReference;", -- 211
	"DROP TABLE IF EXISTS main.AgentTask;", -- 212
	"DROP TABLE IF EXISTS main.AgentQuestionnaire;" -- 213
} -- 213
local storageError -- 216
local storageReady = false -- 217
local function getSchemaVersion() -- 219
	local rows = DB:query("PRAGMA agent.user_version") -- 220
	if not rows or #rows == 0 or type(rows[1][1]) ~= "number" then -- 220
		return nil -- 221
	end -- 221
	return math.max( -- 222
		0, -- 222
		math.floor(rows[1][1]) -- 222
	) -- 222
end -- 219
local function rebuildSchema() -- 225
	local tableRows = DB:query("SELECT name FROM agent.sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'") or ({}) -- 226
	local dropAllTables = {} -- 229
	do -- 229
		local i = 0 -- 230
		while i < #tableRows do -- 230
			do -- 230
				local tableName = toStr(tableRows[i + 1][1]) -- 231
				if tableName == "" then -- 231
					goto __continue6 -- 232
				end -- 232
				local quotedName = string.gsub(tableName, "\"", "\"\"") -- 233
				dropAllTables[#dropAllTables + 1] = ("DROP TABLE IF EXISTS agent.\"" .. quotedName) .. "\";" -- 234
			end -- 234
			::__continue6:: -- 234
			i = i + 1 -- 230
		end -- 230
	end -- 230
	local ____DB_2 = DB -- 236
	local ____DB_transaction_3 = DB.transaction -- 236
	local ____array_1 = __TS__SparseArrayNew(table.unpack(dropAllTables)) -- 236
	__TS__SparseArrayPush( -- 236
		____array_1, -- 236
		table.unpack(DROP_AGENT_SCHEMA_SQL) -- 236
	) -- 236
	__TS__SparseArrayPush( -- 236
		____array_1, -- 236
		table.unpack(CREATE_AGENT_SCHEMA_SQL) -- 236
	) -- 236
	return ____DB_transaction_3( -- 236
		____DB_2, -- 236
		{__TS__SparseArraySpread(____array_1)} -- 236
	) -- 236
end -- 225
local function validateSchema() -- 239
	do -- 239
		local i = 0 -- 240
		while i < #REQUIRED_TABLES do -- 240
			local required = REQUIRED_TABLES[i + 1] -- 241
			local rows = DB:query(("PRAGMA agent.table_info(" .. required.name) .. ")") -- 242
			if not rows or #rows ~= #required.columns then -- 242
				return ("table " .. required.name) .. " has an unexpected column count" -- 244
			end -- 244
			do -- 244
				local j = 0 -- 246
				while j < #required.columns do -- 246
					if toStr(rows[j + 1][2]) ~= required.columns[j + 1] then -- 246
						return ("table " .. required.name) .. " has an unexpected schema" -- 248
					end -- 248
					j = j + 1 -- 246
				end -- 246
			end -- 246
			i = i + 1 -- 240
		end -- 240
	end -- 240
	local indexRows = DB:query("SELECT name FROM agent.sqlite_master WHERE type = 'index' AND name LIKE 'idx_agent_%'") or ({}) -- 252
	local indexes = {} -- 255
	do -- 255
		local i = 0 -- 256
		while i < #indexRows do -- 256
			indexes[toStr(indexRows[i + 1][1])] = true -- 257
			i = i + 1 -- 256
		end -- 256
	end -- 256
	do -- 256
		local i = 0 -- 259
		while i < #REQUIRED_INDEXES do -- 259
			if not indexes[REQUIRED_INDEXES[i + 1]] then -- 259
				return "missing index " .. REQUIRED_INDEXES[i + 1] -- 261
			end -- 261
			i = i + 1 -- 259
		end -- 259
	end -- 259
	return nil -- 264
end -- 239
local function validateCodecAndWrite() -- 267
	local binaryProbe = "Dora\0Blob\0Probe" -- 268
	local smallProbe = "Dora Agent small text" -- 269
	local compressedProbe = "Dora Agent checkpoint codec probe：" .. string.rep("压缩内容", 128) -- 270
	local rows = DB:query("SELECT\n\t\t\tCAST(? AS BLOB),\n\t\t\ttypeof(CAST(? AS BLOB)),\n\t\t\tdora_decompress_text(dora_compress_text(?)),\n\t\t\ttypeof(dora_compress_text(?)),\n\t\t\tdora_decompress_text(dora_compress_text(?)),\n\t\t\ttypeof(dora_compress_text(?))", { -- 271
		binaryProbe, -- 279
		binaryProbe, -- 279
		smallProbe, -- 279
		smallProbe, -- 279
		compressedProbe, -- 279
		compressedProbe -- 279
	}) -- 279
	if not rows or #rows ~= 1 or toStr(rows[1][1]) ~= binaryProbe or toStr(rows[1][2]) ~= "blob" or toStr(rows[1][3]) ~= smallProbe or toStr(rows[1][4]) ~= "text" or toStr(rows[1][5]) ~= compressedProbe or toStr(rows[1][6]) ~= "blob" then -- 279
		return false -- 291
	end -- 291
	return DB:transaction({"CREATE TABLE agent.AgentStorageProbe(value INTEGER NOT NULL);", "INSERT INTO agent.AgentStorageProbe(value) VALUES(1);", "DROP TABLE agent.AgentStorageProbe;"}) -- 293
end -- 267
local function initializeAgentStorage() -- 300
	local dbPath = Path(App.platform == "Web" and Content.writablePath or Content.appPath, AGENT_DB_FILE) -- 301
	if not DB:existDB(____exports.AGENT_SCHEMA) then -- 301
		DB:exec("ATTACH DATABASE ? AS " .. ____exports.AGENT_SCHEMA, {dbPath}) -- 303
	end -- 303
	if not DB:existDB(____exports.AGENT_SCHEMA) then -- 303
		storageError = "failed to attach " .. dbPath -- 306
		return -- 307
	end -- 307
	local version = getSchemaVersion() -- 310
	if version == nil then -- 310
		storageError = "failed to read agent.db schema version" -- 312
		return -- 313
	end -- 313
	if version > ____exports.AGENT_SCHEMA_VERSION then -- 313
		storageError = (("agent.db schema " .. tostring(version)) .. " is newer than supported ") .. tostring(____exports.AGENT_SCHEMA_VERSION) -- 316
		return -- 317
	end -- 317
	local ____temp_8 = version < ____exports.AGENT_SCHEMA_VERSION -- 319
	if ____temp_8 then -- 319
		local ____temp_7 -- 319
		if version == 1 then -- 319
			local ____DB_5 = DB -- 320
			local ____DB_transaction_6 = DB.transaction -- 320
			local ____array_4 = __TS__SparseArrayNew(table.unpack(INPUT_SCHEMA_SQL)) -- 320
			__TS__SparseArrayPush( -- 320
				____array_4, -- 320
				("PRAGMA agent.user_version = " .. tostring(____exports.AGENT_SCHEMA_VERSION)) .. ";" -- 320
			) -- 320
			____temp_7 = ____DB_transaction_6( -- 320
				____DB_5, -- 320
				{__TS__SparseArraySpread(____array_4)} -- 320
			) -- 320
		else -- 320
			____temp_7 = rebuildSchema() -- 321
		end -- 321
		____temp_8 = not ____temp_7 -- 319
	end -- 319
	if ____temp_8 then -- 319
		storageError = "failed to create current agent.db schema" -- 322
		return -- 323
	end -- 323
	local schemaError = validateSchema() -- 325
	if schemaError then -- 325
		storageError = "agent.db schema error: " .. schemaError -- 327
		return -- 328
	end -- 328
	if not validateCodecAndWrite() then -- 328
		storageError = "agent.db codec or write probe failed" -- 331
		return -- 332
	end -- 332
	if not DB:transaction(DROP_LEGACY_AGENT_SQL) then -- 332
		storageError = "failed to remove legacy Agent tables from dora.db" -- 335
		return -- 336
	end -- 336
	storageReady = true -- 338
	Log( -- 339
		"Info", -- 339
		(("[AgentStorage] ready path=" .. dbPath) .. " schema=") .. tostring(____exports.AGENT_SCHEMA_VERSION) -- 339
	) -- 339
end -- 300
function ____exports.isAgentStorageReady() -- 342
	return storageReady -- 343
end -- 342
function ____exports.getAgentStorageError() -- 346
	return storageError -- 347
end -- 346
function ____exports.requireAgentStorage() -- 350
	if storageReady then -- 350
		return {success = true} -- 351
	end -- 351
	return {success = false, message = storageError and "Agent database unavailable: " .. storageError or "Agent database unavailable"} -- 352
end -- 350
local function normalizeTaskIds(rows) -- 358
	local result = {} -- 359
	if not rows then -- 359
		return result -- 360
	end -- 360
	do -- 360
		local i = 0 -- 361
		while i < #rows do -- 361
			local taskId = type(rows[i + 1][1]) == "number" and math.floor(rows[i + 1][1]) or 0 -- 362
			if taskId > 0 and __TS__ArrayIndexOf(result, taskId) < 0 then -- 362
				result[#result + 1] = taskId -- 363
			end -- 363
			i = i + 1 -- 361
		end -- 361
	end -- 361
	return result -- 365
end -- 358
function ____exports.getTaskReferenceClosure(rootTaskIds) -- 368
	local closure = {} -- 369
	local seen = {} -- 370
	local queue = {} -- 371
	do -- 371
		local i = 0 -- 372
		while i < #rootTaskIds do -- 372
			do -- 372
				local taskId = math.floor(rootTaskIds[i + 1]) -- 373
				if taskId <= 0 or seen[taskId] then -- 373
					goto __continue42 -- 374
				end -- 374
				seen[taskId] = true -- 375
				closure[#closure + 1] = taskId -- 376
				queue[#queue + 1] = taskId -- 377
			end -- 377
			::__continue42:: -- 377
			i = i + 1 -- 372
		end -- 372
	end -- 372
	do -- 372
		local offset = 0 -- 379
		while offset < #queue do -- 379
			local ownerTaskId = queue[offset + 1] -- 380
			local targets = normalizeTaskIds(DB:query(("SELECT target_task_id FROM " .. ____exports.TABLE_TASK_REFERENCE) .. " WHERE owner_task_id = ?", {ownerTaskId})) -- 381
			do -- 381
				local i = 0 -- 385
				while i < #targets do -- 385
					do -- 385
						local targetTaskId = targets[i + 1] -- 386
						if seen[targetTaskId] then -- 386
							goto __continue47 -- 387
						end -- 387
						seen[targetTaskId] = true -- 388
						closure[#closure + 1] = targetTaskId -- 389
						queue[#queue + 1] = targetTaskId -- 390
					end -- 390
					::__continue47:: -- 390
					i = i + 1 -- 385
				end -- 385
			end -- 385
			offset = offset + 1 -- 379
		end -- 379
	end -- 379
	return closure -- 393
end -- 368
function ____exports.getSessionOperableTaskIds(sessionId) -- 396
	local roots = normalizeTaskIds(DB:query(("SELECT current_task_id FROM " .. ____exports.TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0", {sessionId})) -- 397
	return ____exports.getTaskReferenceClosure(roots) -- 401
end -- 396
function ____exports.getAllOperableTaskIds() -- 404
	local roots = normalizeTaskIds(DB:query(("SELECT current_task_id FROM " .. ____exports.TABLE_SESSION) .. " WHERE current_task_id > 0")) -- 405
	return ____exports.getTaskReferenceClosure(roots) -- 408
end -- 404
function ____exports.addTaskReference(ownerTaskId, targetTaskId, kind) -- 411
	if kind == nil then -- 411
		kind = "sub_agent_handoff" -- 411
	end -- 411
	if ownerTaskId <= 0 or targetTaskId <= 0 or ownerTaskId == targetTaskId then -- 411
		return false -- 412
	end -- 412
	return DB:exec( -- 413
		("INSERT OR IGNORE INTO " .. ____exports.TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\tVALUES(?, ?, ?, ?)", -- 413
		{ -- 416
			ownerTaskId, -- 416
			targetTaskId, -- 416
			kind, -- 416
			os.time() -- 416
		} -- 416
	) >= 0 -- 416
end -- 411
function ____exports.isTaskOperableForSession(sessionId, taskId) -- 420
	if sessionId <= 0 or taskId <= 0 then -- 420
		return false -- 421
	end -- 421
	return __TS__ArrayIndexOf( -- 422
		____exports.getSessionOperableTaskIds(sessionId), -- 422
		taskId -- 422
	) >= 0 -- 422
end -- 420
local function getTaskStatus(taskId) -- 425
	local rows = DB:query(("SELECT status FROM " .. ____exports.TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 426
	return rows and #rows > 0 and toStr(rows[1][1]) or "" -- 427
end -- 425
local function getProtectedTaskIds() -- 432
	local rows = DB:query(((((("WITH RECURSIVE protected(id) AS (\n\t\tSELECT current_task_id FROM " .. ____exports.TABLE_SESSION) .. " WHERE current_task_id > 0\n\t\tUNION SELECT id FROM ") .. ____exports.TABLE_TASK) .. " WHERE status IN ('RUNNING', 'WAITING_USER')\n\t\tUNION SELECT r.target_task_id FROM ") .. ____exports.TABLE_TASK_REFERENCE) .. " r\n\t\t\tJOIN protected p ON r.owner_task_id = p.id\n\t) SELECT id FROM protected") -- 433
	return rows and normalizeTaskIds(rows) or nil -- 439
end -- 432
local function cleanupTaskHeavyDataRecord(taskId) -- 443
	if taskId <= 0 then -- 443
		return nil -- 444
	end -- 444
	local status = getTaskStatus(taskId) -- 445
	if status == "" or status == "RUNNING" or status == "WAITING_USER" then -- 445
		return nil -- 446
	end -- 446
	local protectedIds = getProtectedTaskIds() -- 447
	if not protectedIds or __TS__ArrayIndexOf(protectedIds, taskId) >= 0 then -- 447
		return nil -- 448
	end -- 448
	local targets = normalizeTaskIds(DB:query(("SELECT target_task_id FROM " .. ____exports.TABLE_TASK_REFERENCE) .. " WHERE owner_task_id = ?", {taskId})) -- 449
	local success = DB:transaction({ -- 453
		((((("DELETE FROM " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "\n\t\t\tWHERE checkpoint_id IN (SELECT id FROM ") .. ____exports.TABLE_CHECKPOINT) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ");", -- 453
		((("DELETE FROM " .. ____exports.TABLE_CHECKPOINT) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 453
		((("DELETE FROM " .. ____exports.TABLE_STEP) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 453
		((((("DELETE FROM " .. ____exports.TABLE_TASK_REFERENCE) .. "\n\t\t\tWHERE owner_task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\tOR target_task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 453
		((((((((((("DELETE FROM " .. ____exports.TABLE_TASK) .. "\n\t\t\tWHERE id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\tAND NOT EXISTS (\n\t\t\t\t\tSELECT 1 FROM ") .. ____exports.TABLE_MESSAGE) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\t)\n\t\t\t\tAND NOT EXISTS (\n\t\t\t\t\tSELECT 1 FROM ") .. ____exports.TABLE_SESSION) .. " WHERE current_task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\t)\n\t\t\t\t;" -- 453
	}) -- 453
	if not success then -- 453
		return nil -- 471
	end -- 471
	Log( -- 472
		"Info", -- 472
		"[AgentStorage] cleaned heavy data task=" .. tostring(taskId) -- 472
	) -- 472
	return targets -- 473
end -- 443
function ____exports.cleanupTaskHeavyData(taskId) -- 476
	local targets = cleanupTaskHeavyDataRecord(taskId) -- 477
	if not targets then -- 477
		return false -- 478
	end -- 478
	do -- 478
		local i = 0 -- 479
		while i < #targets do -- 479
			____exports.cleanupTaskHeavyData(targets[i + 1]) -- 479
			i = i + 1 -- 479
		end -- 479
	end -- 479
	return true -- 480
end -- 476
function ____exports.auditOrphanHeavyData() -- 494
	local protectedIds = getProtectedTaskIds() -- 495
	local ____protectedIds_9 -- 498
	if protectedIds then -- 498
		____protectedIds_9 = DB:query(((((((((((((("WITH\n\t\tcp AS (SELECT task_id, COUNT(*) AS n FROM " .. ____exports.TABLE_CHECKPOINT) .. " GROUP BY task_id),\n\t\tentries AS (SELECT c.task_id, COUNT(*) AS n, SUM(e.bytes_before + e.bytes_after) AS raw_bytes\n\t\t\tFROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. " e JOIN ") .. ____exports.TABLE_CHECKPOINT) .. " c ON c.id = e.checkpoint_id GROUP BY c.task_id),\n\t\tsteps AS (SELECT task_id, COUNT(*) AS n FROM ") .. ____exports.TABLE_STEP) .. " GROUP BY task_id),\n\t\trefs AS (SELECT owner_task_id, COUNT(*) AS n FROM ") .. ____exports.TABLE_TASK_REFERENCE) .. " GROUP BY owner_task_id),\n\t\tmessages AS (SELECT task_id, COUNT(*) AS n FROM ") .. ____exports.TABLE_MESSAGE) .. " GROUP BY task_id)\n\t\tSELECT t.id, COALESCE(cp.n, 0), COALESCE(entries.n, 0), COALESCE(steps.n, 0),\n\t\t\tCOALESCE(refs.n, 0), COALESCE(entries.raw_bytes, 0), COALESCE(messages.n, 0)\n\t\tFROM ") .. ____exports.TABLE_TASK) .. " t\n\t\tLEFT JOIN cp ON cp.task_id = t.id\n\t\tLEFT JOIN entries ON entries.task_id = t.id\n\t\tLEFT JOIN steps ON steps.task_id = t.id\n\t\tLEFT JOIN refs ON refs.owner_task_id = t.id\n\t\tLEFT JOIN messages ON messages.task_id = t.id\n\t\tWHERE t.status NOT IN ('RUNNING', 'WAITING_USER') ORDER BY t.id") -- 498
	else -- 498
		____protectedIds_9 = nil -- 513
	end -- 513
	local rows = ____protectedIds_9 -- 498
	local audit = { -- 514
		success = protectedIds ~= nil and rows ~= nil, -- 515
		taskCount = 0, -- 516
		checkpointCount = 0, -- 517
		entryCount = 0, -- 518
		stepCount = 0, -- 519
		referenceCount = 0, -- 520
		rawBytes = 0, -- 521
		candidateTaskIds = {} -- 522
	} -- 522
	if not rows or not protectedIds then -- 522
		return audit -- 524
	end -- 524
	local protectedTasks = {} -- 525
	for ____, id in ipairs(protectedIds) do -- 526
		protectedTasks[id] = true -- 526
	end -- 526
	do -- 526
		local i = 0 -- 527
		while i < #rows do -- 527
			do -- 527
				local taskId = rows[i + 1][1] -- 528
				if protectedTasks[taskId] then -- 528
					goto __continue71 -- 529
				end -- 529
				local checkpointCount = rows[i + 1][2] or 0 -- 530
				local entryCount = rows[i + 1][3] or 0 -- 531
				local stepCount = rows[i + 1][4] or 0 -- 532
				local referenceCount = rows[i + 1][5] or 0 -- 533
				local messageCount = rows[i + 1][7] or 0 -- 534
				if checkpointCount <= 0 and entryCount <= 0 and stepCount <= 0 and referenceCount <= 0 and messageCount > 0 then -- 534
					goto __continue71 -- 542
				end -- 542
				audit.taskCount = audit.taskCount + 1 -- 544
				audit.checkpointCount = audit.checkpointCount + checkpointCount -- 545
				audit.entryCount = audit.entryCount + entryCount -- 546
				audit.stepCount = audit.stepCount + stepCount -- 547
				audit.referenceCount = audit.referenceCount + referenceCount -- 548
				audit.rawBytes = audit.rawBytes + (rows[i + 1][6] or 0) -- 549
				local ____audit_candidateTaskIds_10 = audit.candidateTaskIds -- 549
				____audit_candidateTaskIds_10[#____audit_candidateTaskIds_10 + 1] = taskId -- 550
			end -- 550
			::__continue71:: -- 550
			i = i + 1 -- 527
		end -- 527
	end -- 527
	return audit -- 552
end -- 494
local orphanSweepCursor = 0 -- 560
function ____exports.cleanupOrphanHeavyDataBatch(maxTasks) -- 562
	if maxTasks == nil then -- 562
		maxTasks = 4 -- 562
	end -- 562
	local audit = ____exports.auditOrphanHeavyData() -- 563
	local limit = math.max( -- 564
		0, -- 564
		math.min( -- 564
			16, -- 564
			math.floor(maxTasks) -- 564
		) -- 564
	) -- 564
	local cleanedTaskCount = 0 -- 565
	local failedTaskCount = 0 -- 566
	local ids = audit.candidateTaskIds -- 567
	local nextIndex = __TS__ArrayFindIndex( -- 568
		ids, -- 568
		function(____, id) return id > orphanSweepCursor end -- 568
	) -- 568
	local start = nextIndex >= 0 and nextIndex or 0 -- 569
	do -- 569
		local i = 0 -- 570
		while audit.success and i < #ids and i < limit do -- 570
			local taskId = ids[(start + i) % #ids + 1] -- 571
			orphanSweepCursor = taskId -- 574
			if cleanupTaskHeavyDataRecord(taskId) ~= nil then -- 574
				cleanedTaskCount = cleanedTaskCount + 1 -- 575
			else -- 575
				failedTaskCount = failedTaskCount + 1 -- 576
			end -- 576
			i = i + 1 -- 570
		end -- 570
	end -- 570
	if not audit.success or audit.taskCount > 0 then -- 570
		Log( -- 579
			audit.success and "Info" or "Warn", -- 579
			(((((((((((((("[AgentStorage] orphan audit success=" .. tostring(audit.success)) .. " tasks=") .. tostring(audit.taskCount)) .. " checkpoints=") .. tostring(audit.checkpointCount)) .. " entries=") .. tostring(audit.entryCount)) .. " steps=") .. tostring(audit.stepCount)) .. " raw_bytes=") .. tostring(audit.rawBytes)) .. " cleaned=") .. tostring(cleanedTaskCount)) .. " failed=") .. tostring(failedTaskCount) -- 579
		) -- 579
	end -- 579
	return __TS__ObjectAssign({}, audit, {cleanedTaskCount = cleanedTaskCount, failedTaskCount = failedTaskCount}) -- 582
end -- 562
function ____exports.getStorageUsage() -- 593
	local ready = ____exports.requireAgentStorage() -- 594
	if not ready.success then -- 594
		return ready -- 595
	end -- 595
	local pageSize = DB:query("PRAGMA agent.page_size") -- 596
	local pageCount = DB:query("PRAGMA agent.page_count") -- 597
	local freeCount = DB:query("PRAGMA agent.freelist_count") -- 598
	local rows = DB:query(((((((((((((((((((((((("SELECT\n\t\t(SELECT COUNT(*) FROM " .. ____exports.TABLE_SESSION) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_MESSAGE) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_TASK) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_STEP) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_CHECKPOINT) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "),\n\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_TASK_REFERENCE) .. "),\n\t\t(SELECT COALESCE(SUM(length(CAST(content AS BLOB)) + length(CAST(display_content AS BLOB))), 0) FROM ") .. ____exports.TABLE_MESSAGE) .. "),\n\t\t(SELECT COALESCE(SUM(length(CAST(prompt AS BLOB))), 0) FROM ") .. ____exports.TABLE_TASK) .. "),\n\t\t(SELECT COALESCE(SUM(length(CAST(reason AS BLOB)) + length(CAST(reasoning_content AS BLOB))\n\t\t\t+ length(CAST(params_json AS BLOB)) + length(CAST(result_json AS BLOB)) + length(CAST(files_json AS BLOB))), 0) FROM ") .. ____exports.TABLE_STEP) .. "),\n\t\t(SELECT COALESCE(SUM(bytes_before + bytes_after), 0) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "),\n\t\t(SELECT COALESCE(SUM(COALESCE(length(CAST(before_data AS BLOB)), 0) + COALESCE(length(CAST(after_data AS BLOB)), 0)), 0) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. ")") -- 599
	local orphanHeavyData = ____exports.auditOrphanHeavyData() -- 613
	if not (pageSize and pageSize[1]) or not (pageCount and pageCount[1]) or not (freeCount and freeCount[1]) or not (rows and rows[1]) or not orphanHeavyData.success then -- 613
		return {success = false, message = "failed to read Agent storage usage"} -- 615
	end -- 615
	local size = pageSize[1][1] -- 617
	local pages = pageCount[1][1] -- 618
	local free = freeCount[1][1] -- 619
	local r = rows[1] -- 620
	return {success = true, usage = {database = { -- 621
		allocatedBytes = size * pages, -- 622
		freeBytes = size * free, -- 622
		usedBytes = size * (pages - free), -- 622
		pageSize = size, -- 622
		pageCount = pages, -- 622
		freePageCount = free -- 622
	}, records = { -- 622
		sessions = r[1], -- 623
		messages = r[2], -- 623
		tasks = r[3], -- 623
		steps = r[4], -- 623
		checkpoints = r[5], -- 623
		entries = r[6], -- 623
		references = r[7] -- 623
	}, payload = { -- 623
		messageBytes = r[8], -- 624
		taskPromptBytes = r[9], -- 624
		stepBytes = r[10], -- 624
		checkpointRawBytes = r[11], -- 624
		checkpointStoredBytes = r[12] -- 624
	}, orphanHeavyData = orphanHeavyData}} -- 624
end -- 593
initializeAgentStorage() -- 629
return ____exports -- 629