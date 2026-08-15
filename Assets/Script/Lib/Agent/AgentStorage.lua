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
____exports.AGENT_SCHEMA_VERSION = 1 -- 5
____exports.AGENT_SCHEMA = "agent" -- 6
____exports.TABLE_SESSION = "agent.AgentSession" -- 7
____exports.TABLE_MESSAGE = "agent.AgentSessionMessage" -- 8
____exports.TABLE_STEP = "agent.AgentSessionStep" -- 9
____exports.TABLE_TASK = "agent.AgentTask" -- 10
____exports.TABLE_CHECKPOINT = "agent.AgentCheckpoint" -- 11
____exports.TABLE_CHECKPOINT_ENTRY = "agent.AgentCheckpointEntry" -- 12
____exports.TABLE_TASK_REFERENCE = "agent.AgentTaskReference" -- 13
local AGENT_DB_FILE = "agent.db" -- 15
local REQUIRED_TABLES = { -- 16
	{name = "AgentSession", columns = { -- 17
		"id", -- 20
		"project_root", -- 20
		"title", -- 20
		"kind", -- 20
		"root_session_id", -- 20
		"parent_session_id", -- 21
		"memory_scope", -- 21
		"status", -- 21
		"current_task_id", -- 21
		"current_task_status", -- 22
		"created_at", -- 22
		"updated_at", -- 22
		"metrics_json", -- 22
		"work_mode" -- 23
	}}, -- 23
	{name = "AgentSessionMessage", columns = { -- 26
		"id", -- 29
		"session_id", -- 29
		"task_id", -- 29
		"role", -- 29
		"content", -- 29
		"display_content", -- 30
		"created_at", -- 30
		"updated_at" -- 30
	}}, -- 30
	{name = "AgentSessionStep", columns = { -- 33
		"id", -- 36
		"session_id", -- 36
		"task_id", -- 36
		"step", -- 36
		"tool", -- 36
		"status", -- 36
		"reason", -- 36
		"reasoning_content", -- 37
		"params_json", -- 37
		"result_json", -- 37
		"checkpoint_id", -- 37
		"checkpoint_seq", -- 38
		"files_json", -- 38
		"created_at", -- 38
		"updated_at" -- 38
	}}, -- 38
	{name = "AgentTask", columns = { -- 41
		"id", -- 44
		"status", -- 44
		"prompt", -- 44
		"head_seq", -- 44
		"work_mode", -- 44
		"created_at", -- 45
		"updated_at" -- 45
	}}, -- 45
	{name = "AgentCheckpoint", columns = { -- 48
		"id", -- 51
		"task_id", -- 51
		"seq", -- 51
		"status", -- 51
		"summary", -- 51
		"tool_name", -- 51
		"created_at", -- 52
		"applied_at", -- 52
		"reverted_at" -- 52
	}}, -- 52
	{name = "AgentCheckpointEntry", columns = { -- 55
		"id", -- 58
		"checkpoint_id", -- 58
		"ord", -- 58
		"path", -- 58
		"op", -- 58
		"before_exists", -- 58
		"before_data", -- 59
		"after_exists", -- 59
		"after_data", -- 59
		"bytes_before", -- 59
		"bytes_after" -- 60
	}}, -- 60
	{name = "AgentTaskReference", columns = {"owner_task_id", "target_task_id", "kind", "created_at"}} -- 63
} -- 63
local REQUIRED_INDEXES = { -- 69
	"idx_agent_session_project_root", -- 70
	"idx_agent_session_message_sid_id", -- 71
	"idx_agent_session_step_unique", -- 72
	"idx_agent_session_step_sid_task_step", -- 73
	"idx_agent_cp_task_seq", -- 74
	"idx_agent_entry_cp_ord", -- 75
	"idx_agent_task_ref_target" -- 76
} -- 76
local DROP_AGENT_SCHEMA_SQL = { -- 79
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. ";", -- 79
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_CHECKPOINT) .. ";", -- 79
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_STEP) .. ";", -- 79
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_MESSAGE) .. ";", -- 79
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_TASK_REFERENCE) .. ";", -- 79
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_SESSION) .. ";", -- 79
	("DROP TABLE IF EXISTS " .. ____exports.TABLE_TASK) .. ";" -- 79
} -- 79
local CREATE_AGENT_SCHEMA_SQL = { -- 89
	("CREATE TABLE " .. ____exports.TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcurrent_task_id INTEGER,\n\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL,\n\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t);", -- 89
	"CREATE INDEX agent.idx_agent_session_project_root\n\t\tON AgentSession(project_root, updated_at DESC);", -- 106
	("CREATE TABLE " .. ____exports.TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 106
	"CREATE INDEX agent.idx_agent_session_message_sid_id\n\t\tON AgentSessionMessage(session_id, id);", -- 118
	("CREATE TABLE " .. ____exports.TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 118
	"CREATE UNIQUE INDEX agent.idx_agent_session_step_unique\n\t\tON AgentSessionStep(session_id, task_id, step);", -- 137
	"CREATE INDEX agent.idx_agent_session_step_sid_task_step\n\t\tON AgentSessionStep(session_id, task_id, step);", -- 139
	("CREATE TABLE " .. ____exports.TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\twork_mode TEXT NOT NULL DEFAULT 'code',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);", -- 139
	("CREATE TABLE " .. ____exports.TABLE_CHECKPOINT) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);", -- 139
	"CREATE INDEX agent.idx_agent_cp_task_seq\n\t\tON AgentCheckpoint(task_id, seq);", -- 161
	("CREATE TABLE " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_data BLOB,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_data BLOB,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);", -- 161
	"CREATE INDEX agent.idx_agent_entry_cp_ord\n\t\tON AgentCheckpointEntry(checkpoint_id, ord);", -- 176
	("CREATE TABLE " .. ____exports.TABLE_TASK_REFERENCE) .. "(\n\t\towner_task_id INTEGER NOT NULL,\n\t\ttarget_task_id INTEGER NOT NULL,\n\t\tkind TEXT NOT NULL,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tPRIMARY KEY(owner_task_id, target_task_id, kind)\n\t);", -- 176
	"CREATE INDEX agent.idx_agent_task_ref_target\n\t\tON AgentTaskReference(target_task_id);", -- 185
	("PRAGMA agent.user_version = " .. tostring(____exports.AGENT_SCHEMA_VERSION)) .. ";" -- 185
} -- 185
local DROP_LEGACY_AGENT_SQL = { -- 190
	"DROP TABLE IF EXISTS main.AgentCheckpointEntry;", -- 191
	"DROP TABLE IF EXISTS main.AgentCheckpoint;", -- 192
	"DROP TABLE IF EXISTS main.AgentSessionStep;", -- 193
	"DROP TABLE IF EXISTS main.AgentSessionMessage;", -- 194
	"DROP TABLE IF EXISTS main.AgentSession;", -- 195
	"DROP TABLE IF EXISTS main.AgentTaskReference;", -- 196
	"DROP TABLE IF EXISTS main.AgentTask;", -- 197
	"DROP TABLE IF EXISTS main.AgentQuestionnaire;" -- 198
} -- 198
local storageError -- 201
local storageReady = false -- 202
local function toStr(value) -- 204
	if value == false or value == nil then -- 204
		return "" -- 205
	end -- 205
	return tostring(value) -- 206
end -- 204
local function getSchemaVersion() -- 209
	local rows = DB:query("PRAGMA agent.user_version") -- 210
	if not rows or #rows == 0 or type(rows[1][1]) ~= "number" then -- 210
		return nil -- 211
	end -- 211
	return math.max( -- 212
		0, -- 212
		math.floor(rows[1][1]) -- 212
	) -- 212
end -- 209
local function rebuildSchema() -- 215
	local tableRows = DB:query("SELECT name FROM agent.sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'") or ({}) -- 216
	local dropAllTables = {} -- 219
	do -- 219
		local i = 0 -- 220
		while i < #tableRows do -- 220
			do -- 220
				local tableName = toStr(tableRows[i + 1][1]) -- 221
				if tableName == "" then -- 221
					goto __continue8 -- 222
				end -- 222
				local quotedName = string.gsub(tableName, "\"", "\"\"") -- 223
				dropAllTables[#dropAllTables + 1] = ("DROP TABLE IF EXISTS agent.\"" .. quotedName) .. "\";" -- 224
			end -- 224
			::__continue8:: -- 224
			i = i + 1 -- 220
		end -- 220
	end -- 220
	local ____DB_1 = DB -- 226
	local ____DB_transaction_2 = DB.transaction -- 226
	local ____array_0 = __TS__SparseArrayNew(table.unpack(dropAllTables)) -- 226
	__TS__SparseArrayPush( -- 226
		____array_0, -- 226
		table.unpack(DROP_AGENT_SCHEMA_SQL) -- 226
	) -- 226
	__TS__SparseArrayPush( -- 226
		____array_0, -- 226
		table.unpack(CREATE_AGENT_SCHEMA_SQL) -- 226
	) -- 226
	return ____DB_transaction_2( -- 226
		____DB_1, -- 226
		{__TS__SparseArraySpread(____array_0)} -- 226
	) -- 226
end -- 215
local function validateSchema() -- 229
	do -- 229
		local i = 0 -- 230
		while i < #REQUIRED_TABLES do -- 230
			local required = REQUIRED_TABLES[i + 1] -- 231
			local rows = DB:query(("PRAGMA agent.table_info(" .. required.name) .. ")") -- 232
			if not rows or #rows ~= #required.columns then -- 232
				return ("table " .. required.name) .. " has an unexpected column count" -- 234
			end -- 234
			do -- 234
				local j = 0 -- 236
				while j < #required.columns do -- 236
					if toStr(rows[j + 1][2]) ~= required.columns[j + 1] then -- 236
						return ("table " .. required.name) .. " has an unexpected schema" -- 238
					end -- 238
					j = j + 1 -- 236
				end -- 236
			end -- 236
			i = i + 1 -- 230
		end -- 230
	end -- 230
	local indexRows = DB:query("SELECT name FROM agent.sqlite_master WHERE type = 'index' AND name LIKE 'idx_agent_%'") or ({}) -- 242
	local indexes = {} -- 245
	do -- 245
		local i = 0 -- 246
		while i < #indexRows do -- 246
			indexes[toStr(indexRows[i + 1][1])] = true -- 247
			i = i + 1 -- 246
		end -- 246
	end -- 246
	do -- 246
		local i = 0 -- 249
		while i < #REQUIRED_INDEXES do -- 249
			if not indexes[REQUIRED_INDEXES[i + 1]] then -- 249
				return "missing index " .. REQUIRED_INDEXES[i + 1] -- 251
			end -- 251
			i = i + 1 -- 249
		end -- 249
	end -- 249
	return nil -- 254
end -- 229
local function validateCodecAndWrite() -- 257
	local binaryProbe = "Dora\0Blob\0Probe" -- 258
	local smallProbe = "Dora Agent small text" -- 259
	local compressedProbe = "Dora Agent checkpoint codec probe：" .. string.rep("压缩内容", 128) -- 260
	local rows = DB:query("SELECT\n\t\t\tCAST(? AS BLOB),\n\t\t\ttypeof(CAST(? AS BLOB)),\n\t\t\tdora_decompress_text(dora_compress_text(?)),\n\t\t\ttypeof(dora_compress_text(?)),\n\t\t\tdora_decompress_text(dora_compress_text(?)),\n\t\t\ttypeof(dora_compress_text(?))", { -- 261
		binaryProbe, -- 269
		binaryProbe, -- 269
		smallProbe, -- 269
		smallProbe, -- 269
		compressedProbe, -- 269
		compressedProbe -- 269
	}) -- 269
	if not rows or #rows ~= 1 or toStr(rows[1][1]) ~= binaryProbe or toStr(rows[1][2]) ~= "blob" or toStr(rows[1][3]) ~= smallProbe or toStr(rows[1][4]) ~= "text" or toStr(rows[1][5]) ~= compressedProbe or toStr(rows[1][6]) ~= "blob" then -- 269
		return false -- 281
	end -- 281
	return DB:transaction({"CREATE TABLE agent.AgentStorageProbe(value INTEGER NOT NULL);", "INSERT INTO agent.AgentStorageProbe(value) VALUES(1);", "DROP TABLE agent.AgentStorageProbe;"}) -- 283
end -- 257
local function initializeAgentStorage() -- 290
	local dbPath = Path(Content.appPath, AGENT_DB_FILE) -- 291
	if not DB:existDB(____exports.AGENT_SCHEMA) then -- 291
		DB:exec("ATTACH DATABASE ? AS " .. ____exports.AGENT_SCHEMA, {dbPath}) -- 293
	end -- 293
	if not DB:existDB(____exports.AGENT_SCHEMA) then -- 293
		storageError = "failed to attach " .. dbPath -- 296
		return -- 297
	end -- 297
	local version = getSchemaVersion() -- 300
	if version == nil then -- 300
		storageError = "failed to read agent.db schema version" -- 302
		return -- 303
	end -- 303
	if version > ____exports.AGENT_SCHEMA_VERSION then -- 303
		storageError = (("agent.db schema " .. tostring(version)) .. " is newer than supported ") .. tostring(____exports.AGENT_SCHEMA_VERSION) -- 306
		return -- 307
	end -- 307
	if version < ____exports.AGENT_SCHEMA_VERSION and not rebuildSchema() then -- 307
		storageError = "failed to create current agent.db schema" -- 310
		return -- 311
	end -- 311
	local schemaError = validateSchema() -- 313
	if schemaError then -- 313
		storageError = "agent.db schema error: " .. schemaError -- 315
		return -- 316
	end -- 316
	if not validateCodecAndWrite() then -- 316
		storageError = "agent.db codec or write probe failed" -- 319
		return -- 320
	end -- 320
	if not DB:transaction(DROP_LEGACY_AGENT_SQL) then -- 320
		storageError = "failed to remove legacy Agent tables from dora.db" -- 323
		return -- 324
	end -- 324
	storageReady = true -- 326
	Log( -- 327
		"Info", -- 327
		(("[AgentStorage] ready path=" .. dbPath) .. " schema=") .. tostring(____exports.AGENT_SCHEMA_VERSION) -- 327
	) -- 327
end -- 290
function ____exports.isAgentStorageReady() -- 330
	return storageReady -- 331
end -- 330
function ____exports.getAgentStorageError() -- 334
	return storageError -- 335
end -- 334
function ____exports.requireAgentStorage() -- 338
	if storageReady then -- 338
		return {success = true} -- 339
	end -- 339
	return {success = false, message = storageError and "Agent database unavailable: " .. storageError or "Agent database unavailable"} -- 340
end -- 338
local function normalizeTaskIds(rows) -- 346
	local result = {} -- 347
	if not rows then -- 347
		return result -- 348
	end -- 348
	do -- 348
		local i = 0 -- 349
		while i < #rows do -- 349
			local taskId = type(rows[i + 1][1]) == "number" and math.floor(rows[i + 1][1]) or 0 -- 350
			if taskId > 0 and __TS__ArrayIndexOf(result, taskId) < 0 then -- 350
				result[#result + 1] = taskId -- 351
			end -- 351
			i = i + 1 -- 349
		end -- 349
	end -- 349
	return result -- 353
end -- 346
function ____exports.getTaskReferenceClosure(rootTaskIds) -- 356
	local closure = {} -- 357
	local seen = {} -- 358
	local queue = {} -- 359
	do -- 359
		local i = 0 -- 360
		while i < #rootTaskIds do -- 360
			do -- 360
				local taskId = math.floor(rootTaskIds[i + 1]) -- 361
				if taskId <= 0 or seen[taskId] then -- 361
					goto __continue44 -- 362
				end -- 362
				seen[taskId] = true -- 363
				closure[#closure + 1] = taskId -- 364
				queue[#queue + 1] = taskId -- 365
			end -- 365
			::__continue44:: -- 365
			i = i + 1 -- 360
		end -- 360
	end -- 360
	do -- 360
		local offset = 0 -- 367
		while offset < #queue do -- 367
			local ownerTaskId = queue[offset + 1] -- 368
			local targets = normalizeTaskIds(DB:query(("SELECT target_task_id FROM " .. ____exports.TABLE_TASK_REFERENCE) .. " WHERE owner_task_id = ?", {ownerTaskId})) -- 369
			do -- 369
				local i = 0 -- 373
				while i < #targets do -- 373
					do -- 373
						local targetTaskId = targets[i + 1] -- 374
						if seen[targetTaskId] then -- 374
							goto __continue49 -- 375
						end -- 375
						seen[targetTaskId] = true -- 376
						closure[#closure + 1] = targetTaskId -- 377
						queue[#queue + 1] = targetTaskId -- 378
					end -- 378
					::__continue49:: -- 378
					i = i + 1 -- 373
				end -- 373
			end -- 373
			offset = offset + 1 -- 367
		end -- 367
	end -- 367
	return closure -- 381
end -- 356
function ____exports.getSessionOperableTaskIds(sessionId) -- 384
	local roots = normalizeTaskIds(DB:query(("SELECT current_task_id FROM " .. ____exports.TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0", {sessionId})) -- 385
	return ____exports.getTaskReferenceClosure(roots) -- 389
end -- 384
function ____exports.getAllOperableTaskIds() -- 392
	local roots = normalizeTaskIds(DB:query(("SELECT current_task_id FROM " .. ____exports.TABLE_SESSION) .. " WHERE current_task_id > 0")) -- 393
	return ____exports.getTaskReferenceClosure(roots) -- 396
end -- 392
function ____exports.addTaskReference(ownerTaskId, targetTaskId, kind) -- 399
	if kind == nil then -- 399
		kind = "sub_agent_handoff" -- 399
	end -- 399
	if ownerTaskId <= 0 or targetTaskId <= 0 or ownerTaskId == targetTaskId then -- 399
		return false -- 400
	end -- 400
	return DB:exec( -- 401
		("INSERT OR IGNORE INTO " .. ____exports.TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\tVALUES(?, ?, ?, ?)", -- 401
		{ -- 404
			ownerTaskId, -- 404
			targetTaskId, -- 404
			kind, -- 404
			os.time() -- 404
		} -- 404
	) >= 0 -- 404
end -- 399
function ____exports.isTaskOperableForSession(sessionId, taskId) -- 408
	if sessionId <= 0 or taskId <= 0 then -- 408
		return false -- 409
	end -- 409
	return __TS__ArrayIndexOf( -- 410
		____exports.getSessionOperableTaskIds(sessionId), -- 410
		taskId -- 410
	) >= 0 -- 410
end -- 408
local function getTaskStatus(taskId) -- 413
	local rows = DB:query(("SELECT status FROM " .. ____exports.TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 414
	return rows and #rows > 0 and toStr(rows[1][1]) or "" -- 415
end -- 413
function ____exports.cleanupTaskHeavyData(taskId) -- 418
	if taskId <= 0 then -- 418
		return false -- 419
	end -- 419
	local status = getTaskStatus(taskId) -- 420
	if status == "" then -- 420
		return false -- 421
	end -- 421
	if status == "RUNNING" or status == "WAITING_USER" then -- 421
		return false -- 422
	end -- 422
	if __TS__ArrayIndexOf( -- 422
		____exports.getAllOperableTaskIds(), -- 423
		taskId -- 423
	) >= 0 then -- 423
		return false -- 423
	end -- 423
	local targets = normalizeTaskIds(DB:query(("SELECT target_task_id FROM " .. ____exports.TABLE_TASK_REFERENCE) .. " WHERE owner_task_id = ?", {taskId})) -- 424
	local success = DB:transaction({ -- 428
		((((("DELETE FROM " .. ____exports.TABLE_CHECKPOINT_ENTRY) .. "\n\t\t\tWHERE checkpoint_id IN (SELECT id FROM ") .. ____exports.TABLE_CHECKPOINT) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ");", -- 428
		((("DELETE FROM " .. ____exports.TABLE_CHECKPOINT) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 428
		((("DELETE FROM " .. ____exports.TABLE_STEP) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 428
		((((("DELETE FROM " .. ____exports.TABLE_TASK_REFERENCE) .. "\n\t\t\tWHERE owner_task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\tOR target_task_id = ") .. tostring(math.floor(taskId))) .. ";", -- 428
		((((((((((("DELETE FROM " .. ____exports.TABLE_TASK) .. "\n\t\t\tWHERE id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\tAND NOT EXISTS (\n\t\t\t\t\tSELECT 1 FROM ") .. ____exports.TABLE_MESSAGE) .. " WHERE task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\t)\n\t\t\t\tAND NOT EXISTS (\n\t\t\t\t\tSELECT 1 FROM ") .. ____exports.TABLE_SESSION) .. " WHERE current_task_id = ") .. tostring(math.floor(taskId))) .. "\n\t\t\t\t)\n\t\t\t\t;" -- 428
	}) -- 428
	if not success then -- 428
		return false -- 446
	end -- 446
	Log( -- 447
		"Info", -- 447
		"[AgentStorage] cleaned heavy data task=" .. tostring(taskId) -- 447
	) -- 447
	do -- 447
		local i = 0 -- 448
		while i < #targets do -- 448
			____exports.cleanupTaskHeavyData(targets[i + 1]) -- 449
			i = i + 1 -- 448
		end -- 448
	end -- 448
	return true -- 451
end -- 418
function ____exports.auditOrphanHeavyData() -- 464
	local operable = ____exports.getAllOperableTaskIds() -- 465
	local rows = DB:query(((((((((((((((((("SELECT t.id,\n\t\t\t(SELECT COUNT(*) FROM " .. ____exports.TABLE_CHECKPOINT) .. " c WHERE c.task_id = t.id),\n\t\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. " e\n\t\t\t\tJOIN ") .. ____exports.TABLE_CHECKPOINT) .. " c ON c.id = e.checkpoint_id WHERE c.task_id = t.id),\n\t\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_STEP) .. " s WHERE s.task_id = t.id),\n\t\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_TASK_REFERENCE) .. " r WHERE r.owner_task_id = t.id),\n\t\t\t(SELECT COALESCE(SUM(e.bytes_before + e.bytes_after), 0) FROM ") .. ____exports.TABLE_CHECKPOINT_ENTRY) .. " e\n\t\t\t\tJOIN ") .. ____exports.TABLE_CHECKPOINT) .. " c ON c.id = e.checkpoint_id WHERE c.task_id = t.id),\n\t\t\t(SELECT COUNT(*) FROM ") .. ____exports.TABLE_MESSAGE) .. " m WHERE m.task_id = t.id)\n\t\tFROM ") .. ____exports.TABLE_TASK) .. " t\n\t\tWHERE t.status NOT IN ('RUNNING', 'WAITING_USER')") or ({}) -- 466
	local audit = { -- 479
		taskCount = 0, -- 480
		checkpointCount = 0, -- 481
		entryCount = 0, -- 482
		stepCount = 0, -- 483
		referenceCount = 0, -- 484
		rawBytes = 0, -- 485
		candidateTaskIds = {} -- 486
	} -- 486
	do -- 486
		local i = 0 -- 488
		while i < #rows do -- 488
			do -- 488
				local taskId = rows[i + 1][1] -- 489
				if __TS__ArrayIndexOf(operable, taskId) >= 0 then -- 489
					goto __continue68 -- 490
				end -- 490
				local checkpointCount = rows[i + 1][2] or 0 -- 491
				local entryCount = rows[i + 1][3] or 0 -- 492
				local stepCount = rows[i + 1][4] or 0 -- 493
				local referenceCount = rows[i + 1][5] or 0 -- 494
				local messageCount = rows[i + 1][7] or 0 -- 495
				if checkpointCount <= 0 and entryCount <= 0 and stepCount <= 0 and referenceCount <= 0 and messageCount > 0 then -- 495
					goto __continue68 -- 503
				end -- 503
				audit.taskCount = audit.taskCount + 1 -- 505
				audit.checkpointCount = audit.checkpointCount + checkpointCount -- 506
				audit.entryCount = audit.entryCount + entryCount -- 507
				audit.stepCount = audit.stepCount + stepCount -- 508
				audit.referenceCount = audit.referenceCount + referenceCount -- 509
				audit.rawBytes = audit.rawBytes + (rows[i + 1][6] or 0) -- 510
				local ____audit_candidateTaskIds_3 = audit.candidateTaskIds -- 510
				____audit_candidateTaskIds_3[#____audit_candidateTaskIds_3 + 1] = taskId -- 511
			end -- 511
			::__continue68:: -- 511
			i = i + 1 -- 488
		end -- 488
	end -- 488
	return audit -- 513
end -- 464
function ____exports.cleanupOrphanHeavyDataBatch(maxTasks) -- 516
	if maxTasks == nil then -- 516
		maxTasks = 4 -- 516
	end -- 516
	local audit = ____exports.auditOrphanHeavyData() -- 517
	local limit = math.max( -- 518
		0, -- 518
		math.floor(maxTasks) -- 518
	) -- 518
	local cleaned = 0 -- 519
	do -- 519
		local i = 0 -- 520
		while i < #audit.candidateTaskIds and cleaned < limit do -- 520
			if ____exports.cleanupTaskHeavyData(audit.candidateTaskIds[i + 1]) then -- 520
				cleaned = cleaned + 1 -- 522
			end -- 522
			i = i + 1 -- 520
		end -- 520
	end -- 520
	if audit.taskCount > 0 then -- 520
		Log( -- 526
			"Info", -- 527
			(((((((((((("[AgentStorage] orphan audit tasks=" .. tostring(audit.taskCount)) .. " checkpoints=") .. tostring(audit.checkpointCount)) .. " entries=") .. tostring(audit.entryCount)) .. " steps=") .. tostring(audit.stepCount)) .. " refs=") .. tostring(audit.referenceCount)) .. " raw_bytes=") .. tostring(audit.rawBytes)) .. " cleaned=") .. tostring(cleaned) -- 527
		) -- 527
	end -- 527
	return audit -- 531
end -- 516
initializeAgentStorage() -- 534
return ____exports -- 534