-- [ts]: Checkpoint.ts
local ____lualib = require("lualib_bundle") -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local ____Database = require("Agent.Storage.Database") -- 4
local TABLE_TASK = ____Database.TABLE_TASK -- 5
local TABLE_CP = ____Database.TABLE_CHECKPOINT -- 6
local TABLE_ENTRY = ____Database.TABLE_CHECKPOINT_ENTRY -- 7
local requireAgentStorage = ____Database.requireAgentStorage -- 8
local ____Utils = require("Agent.Utils") -- 10
local Log = ____Utils.Log -- 10
local safeJsonEncode = ____Utils.safeJsonEncode -- 10
local ____FileCommitEvents = require("Agent.Runtime.FileCommitEvents") -- 11
local hasFileCommitListeners = ____FileCommitEvents.hasFileCommitListeners -- 11
local publishFileCommit = ____FileCommitEvents.publishFileCommit -- 11
local ____Workspace = require("Agent.Tool.Workspace") -- 12
local isValidWorkDir = ____Workspace.isValidWorkDir -- 13
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 14
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 15
local toWorkspaceRelativePath = ____Workspace.toWorkspaceRelativePath -- 16
local ensureDirForFile = ____Workspace.ensureDirForFile -- 17
local getFileState = ____Workspace.getFileState -- 18
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 20
local sendWebIDEFileUpdate = ____WebIDESync.sendWebIDEFileUpdate -- 20
local sendWebIDERefreshTree = ____WebIDESync.sendWebIDERefreshTree -- 20
local ____Support = require("Agent.Storage.Support") -- 21
local getLastInsertRowId = ____Support.getLastInsertRowId -- 21
local queryOne = ____Support.queryOne -- 21
local toStr = ____Support.toStr -- 21
local function now() -- 164
	return os.time() -- 164
end -- 164
local function toBool(v) -- 166
	return v ~= 0 and v ~= false and v ~= nil -- 167
end -- 166
local function getTaskHeadSeq(taskId) -- 170
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 171
	if not row then -- 171
		return nil -- 172
	end -- 172
	return row[1] or 0 -- 173
end -- 170
local function getTaskStatus(taskId) -- 176
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 177
	if not row then -- 177
		return nil -- 178
	end -- 178
	return toStr(row[1]) -- 179
end -- 176
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 182
	DB:exec( -- 183
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 183
		{ -- 185
			taskId, -- 185
			seq, -- 185
			status, -- 185
			summary, -- 185
			toolName, -- 185
			now() -- 185
		} -- 185
	) -- 185
	return getLastInsertRowId() -- 187
end -- 182
local function getCheckpointEntries(checkpointId, desc) -- 190
	if desc == nil then -- 190
		desc = false -- 190
	end -- 190
	local rows = DB:query((("SELECT id, ord, path, op, before_exists,\n\t\t\tdora_decompress_text(before_data),\n\t\t\tafter_exists,\n\t\t\tdora_decompress_text(after_data)\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 191
	if not rows then -- 191
		return {} -- 201
	end -- 201
	local result = {} -- 202
	do -- 202
		local i = 0 -- 203
		while i < #rows do -- 203
			local row = rows[i + 1] -- 204
			result[#result + 1] = { -- 205
				id = row[1], -- 206
				ord = row[2], -- 207
				path = toStr(row[3]), -- 208
				op = toStr(row[4]), -- 209
				beforeExists = toBool(row[5]), -- 210
				beforeContent = toStr(row[6]), -- 211
				afterExists = toBool(row[7]), -- 212
				afterContent = toStr(row[8]) -- 213
			} -- 213
			i = i + 1 -- 203
		end -- 203
	end -- 203
	return result -- 216
end -- 190
local function getCheckpointEntryMetadata(checkpointId, desc) -- 219
	if desc == nil then -- 219
		desc = false -- 219
	end -- 219
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 220
	if not rows then -- 220
		return {} -- 227
	end -- 227
	local result = {} -- 228
	do -- 228
		local i = 0 -- 229
		while i < #rows do -- 229
			local row = rows[i + 1] -- 230
			result[#result + 1] = { -- 231
				id = row[1], -- 232
				ord = row[2], -- 233
				path = toStr(row[3]), -- 234
				op = toStr(row[4]), -- 235
				beforeExists = toBool(row[5]), -- 236
				afterExists = toBool(row[6]), -- 237
				bytesBefore = row[7] or 0, -- 238
				bytesAfter = row[8] or 0 -- 239
			} -- 239
			i = i + 1 -- 229
		end -- 229
	end -- 229
	return result -- 242
end -- 219
local function rejectDuplicatePaths(changes) -- 245
	local seen = __TS__New(Set) -- 246
	for ____, change in ipairs(changes) do -- 247
		local key = change.path -- 248
		if seen:has(key) then -- 248
			return key -- 249
		end -- 249
		seen:add(key) -- 250
	end -- 250
	return nil -- 252
end -- 245
local function getLinkedDeletePaths(workDir, path) -- 255
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 256
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 256
		return {} -- 257
	end -- 257
	local parent = Path:getPath(fullPath) -- 258
	local baseName = string.lower(Path:getName(fullPath)) -- 259
	local ext = Path:getExt(fullPath) -- 260
	local linked = {} -- 261
	for ____, file in ipairs(Content:getFiles(parent)) do -- 262
		do -- 262
			if string.lower(Path:getName(file)) ~= baseName then -- 262
				goto __continue23 -- 263
			end -- 263
			local siblingExt = Path:getExt(file) -- 264
			if siblingExt == "tl" and ext == "vs" then -- 264
				linked[#linked + 1] = toWorkspaceRelativePath( -- 266
					workDir, -- 266
					Path(parent, file) -- 266
				) -- 266
				goto __continue23 -- 267
			end -- 267
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 267
				linked[#linked + 1] = toWorkspaceRelativePath( -- 270
					workDir, -- 270
					Path(parent, file) -- 270
				) -- 270
			end -- 270
		end -- 270
		::__continue23:: -- 270
	end -- 270
	return linked -- 273
end -- 255
local function expandLinkedDeleteChanges(workDir, changes) -- 276
	local expanded = {} -- 277
	local seen = __TS__New(Set) -- 278
	do -- 278
		local i = 0 -- 279
		while i < #changes do -- 279
			do -- 279
				local change = changes[i + 1] -- 280
				if not seen:has(change.path) then -- 280
					seen:add(change.path) -- 282
					expanded[#expanded + 1] = change -- 283
				end -- 283
				if change.op ~= "delete" then -- 283
					goto __continue30 -- 285
				end -- 285
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 286
				do -- 286
					local j = 0 -- 287
					while j < #linkedPaths do -- 287
						do -- 287
							local linkedPath = linkedPaths[j + 1] -- 288
							if seen:has(linkedPath) then -- 288
								goto __continue34 -- 289
							end -- 289
							seen:add(linkedPath) -- 290
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 291
						end -- 291
						::__continue34:: -- 291
						j = j + 1 -- 287
					end -- 287
				end -- 287
			end -- 287
			::__continue30:: -- 287
			i = i + 1 -- 279
		end -- 279
	end -- 279
	return expanded -- 294
end -- 276
local function applySingleFile(path, exists, content) -- 297
	if exists then -- 297
		if not ensureDirForFile(path) then -- 297
			return false -- 299
		end -- 299
		return Content:save(path, content) -- 300
	end -- 300
	if Content:exist(path) then -- 300
		return Content:remove(path) -- 303
	end -- 303
	return true -- 305
end -- 297
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 308
	local entries = getCheckpointEntries(checkpointId, true) -- 313
	local remaining = appliedCount -- 314
	local failures = {} -- 315
	do -- 315
		local i = 0 -- 316
		while i < #entries and remaining > 0 do -- 316
			do -- 316
				local entry = entries[i + 1] -- 317
				if entry.ord > appliedCount then -- 317
					goto __continue42 -- 318
				end -- 318
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 319
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 319
					failures[#failures + 1] = entry.path -- 321
				else -- 321
					sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 323
				end -- 323
				remaining = remaining - 1 -- 325
			end -- 325
			::__continue42:: -- 325
			i = i + 1 -- 316
		end -- 316
	end -- 316
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 327
end -- 308
function ____exports.createTask(prompt, workMode) -- 330
	if prompt == nil then -- 330
		prompt = "" -- 330
	end -- 330
	if workMode == nil then -- 330
		workMode = "code" -- 330
	end -- 330
	local storage = requireAgentStorage() -- 331
	if not storage.success then -- 331
		return storage -- 332
	end -- 332
	local t = now() -- 333
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 334
		"RUNNING", -- 336
		prompt, -- 336
		workMode, -- 336
		t, -- 336
		t -- 336
	}) -- 336
	if affected <= 0 then -- 336
		return {success = false, message = "failed to create task"} -- 339
	end -- 339
	return { -- 341
		success = true, -- 341
		taskId = getLastInsertRowId() -- 341
	} -- 341
end -- 330
function ____exports.setTaskStatus(taskId, status) -- 344
	DB:exec( -- 345
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 345
		{ -- 345
			status, -- 345
			now(), -- 345
			taskId -- 345
		} -- 345
	) -- 345
	Log( -- 346
		"Info", -- 346
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 346
	) -- 346
end -- 344
function ____exports.listCheckpointsForTasks(taskIds) -- 349
	local normalizedTaskIds = {} -- 350
	local seenTaskIds = {} -- 351
	do -- 351
		local i = 0 -- 352
		while i < #taskIds do -- 352
			do -- 352
				local taskId = math.floor(taskIds[i + 1]) -- 353
				if taskId <= 0 or seenTaskIds[taskId] then -- 353
					goto __continue52 -- 354
				end -- 354
				seenTaskIds[taskId] = true -- 355
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 356
			end -- 356
			::__continue52:: -- 356
			i = i + 1 -- 352
		end -- 352
	end -- 352
	if #normalizedTaskIds == 0 then -- 352
		return {} -- 358
	end -- 358
	local placeholders = table.concat( -- 359
		__TS__ArrayMap( -- 359
			normalizedTaskIds, -- 359
			function() return "?" end -- 359
		), -- 359
		", " -- 359
	) -- 359
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 360
	if not rows then -- 360
		return {} -- 367
	end -- 367
	local items = {} -- 368
	do -- 368
		local i = 0 -- 369
		while i < #rows do -- 369
			local row = rows[i + 1] -- 370
			items[#items + 1] = { -- 371
				id = row[1], -- 372
				taskId = row[2], -- 373
				seq = row[3], -- 374
				status = toStr(row[4]), -- 375
				summary = toStr(row[5]), -- 376
				toolName = toStr(row[6]), -- 377
				createdAt = row[7] -- 378
			} -- 378
			i = i + 1 -- 369
		end -- 369
	end -- 369
	return items -- 381
end -- 349
function ____exports.listCheckpoints(taskId) -- 384
	return ____exports.listCheckpointsForTasks({taskId}) -- 385
end -- 384
function ____exports.getCheckpoint(checkpointId) -- 388
	if checkpointId <= 0 then -- 388
		return nil -- 389
	end -- 389
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 390
	if not rows or #rows == 0 then -- 390
		return nil -- 397
	end -- 397
	local row = rows[1] -- 398
	return { -- 399
		id = row[1], -- 400
		taskId = row[2], -- 401
		seq = row[3], -- 402
		status = toStr(row[4]), -- 403
		summary = toStr(row[5]), -- 404
		toolName = toStr(row[6]), -- 405
		createdAt = row[7] -- 406
	} -- 406
end -- 388
local function listCheckpointIdsForTask(taskId, desc) -- 410
	if desc == nil then -- 410
		desc = false -- 410
	end -- 410
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 411
	if not rows then -- 411
		return {} -- 418
	end -- 418
	local items = {} -- 419
	do -- 419
		local i = 0 -- 420
		while i < #rows do -- 420
			local row = rows[i + 1] -- 421
			items[#items + 1] = {id = row[1], seq = row[2]} -- 422
			i = i + 1 -- 420
		end -- 420
	end -- 420
	return items -- 427
end -- 410
local function deriveFileOp(beforeExists, afterExists) -- 430
	if not beforeExists and afterExists then -- 430
		return "create" -- 431
	end -- 431
	if beforeExists and not afterExists then -- 431
		return "delete" -- 432
	end -- 432
	return "write" -- 433
end -- 430
function ____exports.summarizeTaskChangeSet(taskId) -- 436
	if not getTaskStatus(taskId) then -- 436
		return {success = false, message = "task not found"} -- 438
	end -- 438
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 440
	local filesByPath = {} -- 441
	local latestCheckpointId = nil -- 447
	local latestCheckpointSeq = nil -- 448
	do -- 448
		local i = 0 -- 449
		while i < #checkpoints do -- 449
			local checkpoint = checkpoints[i + 1] -- 450
			latestCheckpointId = checkpoint.id -- 451
			latestCheckpointSeq = checkpoint.seq -- 452
			local entries = getCheckpointEntryMetadata(checkpoint.id, false) -- 453
			do -- 453
				local j = 0 -- 454
				while j < #entries do -- 454
					local entry = entries[j + 1] -- 455
					local item = filesByPath[entry.path] -- 456
					if not item then -- 456
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 458
						filesByPath[entry.path] = item -- 464
					end -- 464
					item.afterExists = entry.afterExists -- 466
					local ____item_checkpointIds_0 = item.checkpointIds -- 466
					____item_checkpointIds_0[#____item_checkpointIds_0 + 1] = checkpoint.id -- 467
					j = j + 1 -- 454
				end -- 454
			end -- 454
			i = i + 1 -- 449
		end -- 449
	end -- 449
	local files = {} -- 470
	for ____, item in pairs(filesByPath) do -- 471
		files[#files + 1] = { -- 472
			path = item.path, -- 473
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 474
			checkpointCount = #item.checkpointIds, -- 475
			checkpointIds = item.checkpointIds -- 476
		} -- 476
	end -- 476
	__TS__ArraySort( -- 479
		files, -- 479
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 479
	) -- 479
	return { -- 480
		success = true, -- 481
		taskId = taskId, -- 482
		checkpointCount = #checkpoints, -- 483
		filesChanged = #files, -- 484
		files = files, -- 485
		latestCheckpointId = latestCheckpointId, -- 486
		latestCheckpointSeq = latestCheckpointSeq -- 487
	} -- 487
end -- 436
function ____exports.getTaskChangeSetDiff(taskId) -- 491
	if not getTaskStatus(taskId) then -- 491
		return {success = false, message = "task not found"} -- 493
	end -- 493
	local entryRows = DB:query(((("SELECT e.id, e.path, e.before_exists, e.after_exists\n\t\tFROM " .. TABLE_ENTRY) .. " e\n\t\tJOIN ") .. TABLE_CP) .. " c ON c.id = e.checkpoint_id\n\t\tWHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY c.seq ASC, e.ord ASC", {taskId}) -- 495
	if not entryRows or #entryRows == 0 then -- 495
		return {success = false, message = "change set not found or empty"} -- 504
	end -- 504
	local filesByPath = {} -- 506
	do -- 506
		local i = 0 -- 513
		while i < #entryRows do -- 513
			local row = entryRows[i + 1] -- 514
			local entryId = row[1] -- 515
			local path = toStr(row[2]) -- 516
			local item = filesByPath[path] -- 517
			if not item then -- 517
				item = { -- 519
					path = path, -- 520
					firstEntryId = entryId, -- 521
					lastEntryId = entryId, -- 522
					beforeExists = toBool(row[3]), -- 523
					afterExists = toBool(row[4]) -- 524
				} -- 524
				filesByPath[path] = item -- 526
			end -- 526
			item.lastEntryId = entryId -- 528
			item.afterExists = toBool(row[4]) -- 529
			i = i + 1 -- 513
		end -- 513
	end -- 513
	local files = {} -- 531
	for ____, item in pairs(filesByPath) do -- 532
		local contentRows = DB:query(((("SELECT\n\t\t\t\t(SELECT dora_decompress_text(before_data) FROM " .. TABLE_ENTRY) .. " WHERE id = ?),\n\t\t\t\t(SELECT dora_decompress_text(after_data) FROM ") .. TABLE_ENTRY) .. " WHERE id = ?)", {item.firstEntryId, item.lastEntryId}) -- 533
		if not contentRows or #contentRows == 0 then -- 533
			return {success = false, message = "failed to read checkpoint data for " .. item.path} -- 540
		end -- 540
		files[#files + 1] = { -- 542
			path = item.path, -- 543
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 544
			beforeExists = item.beforeExists, -- 545
			afterExists = item.afterExists, -- 546
			beforeContent = toStr(contentRows[1][1]), -- 547
			afterContent = toStr(contentRows[1][2]) -- 548
		} -- 548
	end -- 548
	__TS__ArraySort( -- 551
		files, -- 551
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 551
	) -- 551
	return {success = true, files = files} -- 552
end -- 491
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 556
	if options == nil then -- 556
		options = {} -- 556
	end -- 556
	local storage = requireAgentStorage() -- 557
	if not storage.success then -- 557
		return storage -- 558
	end -- 558
	if #changes == 0 then -- 558
		return {success = false, message = "empty changes"} -- 560
	end -- 560
	if not isValidWorkDir(workDir) then -- 560
		return {success = false, message = "invalid workDir"} -- 563
	end -- 563
	if not getTaskStatus(taskId) then -- 563
		return {success = false, message = "task not found"} -- 566
	end -- 566
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 568
	local dup = rejectDuplicatePaths(expandedChanges) -- 569
	if dup then -- 569
		return {success = false, message = "duplicate path in batch: " .. dup} -- 571
	end -- 571
	for ____, change in ipairs(expandedChanges) do -- 574
		if not isValidWorkspacePath(change.path) then -- 574
			return {success = false, message = "invalid path: " .. change.path} -- 576
		end -- 576
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 576
			return {success = false, message = "missing content for " .. change.path} -- 579
		end -- 579
	end -- 579
	local headSeq = getTaskHeadSeq(taskId) -- 583
	if headSeq == nil then -- 583
		return {success = false, message = "task not found"} -- 584
	end -- 584
	local nextSeq = headSeq + 1 -- 585
	local preparedEntries = {} -- 587
	do -- 587
		local i = 0 -- 588
		while i < #expandedChanges do -- 588
			local change = expandedChanges[i + 1] -- 589
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 590
			if not fullPath then -- 590
				return {success = false, message = "invalid path: " .. change.path} -- 592
			end -- 592
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 592
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 595
			end -- 595
			if Content:exist(fullPath) and not Content:isdir(fullPath) then -- 595
				local ____, isBinary = Content:getAttr(fullPath) -- 598
				if isBinary == true then -- 598
					return {success = false, message = change.op == "delete" and "binary file deletion must use delete_file: " .. change.path or "binary files cannot be edited with text checkpoints: " .. change.path} -- 600
				end -- 600
			end -- 600
			local before = getFileState(fullPath) -- 608
			local afterExists = change.op ~= "delete" -- 609
			local afterContent = afterExists and (change.content or "") or "" -- 610
			preparedEntries[#preparedEntries + 1] = { -- 611
				id = 0, -- 612
				ord = i + 1, -- 613
				path = change.path, -- 614
				op = change.op, -- 615
				beforeExists = before.exists, -- 616
				beforeContent = before.content, -- 617
				afterExists = afterExists, -- 618
				afterContent = afterContent -- 619
			} -- 619
			i = i + 1 -- 588
		end -- 588
	end -- 588
	local checkpointId = insertCheckpoint( -- 623
		taskId, -- 623
		nextSeq, -- 623
		options.summary or "", -- 623
		options.toolName or "", -- 623
		"PREPARED" -- 623
	) -- 623
	if checkpointId <= 0 then -- 623
		return {success = false, message = "failed to create checkpoint"} -- 625
	end -- 625
	local entryRows = {} -- 627
	do -- 627
		local i = 0 -- 628
		while i < #preparedEntries do -- 628
			local entry = preparedEntries[i + 1] -- 629
			entryRows[#entryRows + 1] = { -- 630
				checkpointId, -- 631
				entry.ord, -- 632
				entry.path, -- 633
				entry.op, -- 634
				entry.beforeExists and 1 or 0, -- 635
				entry.beforeContent, -- 636
				entry.afterExists and 1 or 0, -- 637
				entry.afterContent, -- 638
				#entry.beforeContent, -- 639
				#entry.afterContent -- 640
			} -- 640
			i = i + 1 -- 628
		end -- 628
	end -- 628
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 643
	if not DB:transaction({entryInsert}) then -- 643
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 649
		return {success = false, message = "failed to insert checkpoint entries"} -- 650
	end -- 650
	local appliedCount = 0 -- 653
	for ____, entry in ipairs(preparedEntries) do -- 654
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 655
		if not fullPath then -- 655
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 657
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 658
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 659
		end -- 659
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 661
		if not ok then -- 661
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 663
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 664
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 665
		end -- 665
		appliedCount = appliedCount + 1 -- 667
		if not sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 667
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 669
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 670
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 671
		end -- 671
	end -- 671
	DB:exec( -- 675
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 675
		{ -- 677
			"APPLIED", -- 677
			now(), -- 677
			checkpointId -- 677
		} -- 677
	) -- 677
	DB:exec( -- 679
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 679
		{ -- 681
			nextSeq, -- 681
			now(), -- 681
			taskId -- 681
		} -- 681
	) -- 681
	if hasFileCommitListeners(workDir) then -- 681
		do -- 681
			pcall(function() -- 681
				local payload = safeJsonEncode({ -- 685
					version = 1, -- 685
					taskId = taskId, -- 685
					checkpointId = checkpointId, -- 685
					checkpointSeq = nextSeq, -- 685
					changes = __TS__ArrayMap( -- 686
						preparedEntries, -- 686
						function(____, entry) return {path = entry.path, op = entry.op} end -- 686
					) -- 686
				}) -- 686
				if payload then -- 686
					publishFileCommit(workDir, payload) -- 687
				end -- 687
			end) -- 687
		end -- 687
	end -- 687
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 690
end -- 556
function ____exports.deleteFile(taskId, workDir, targetFile, options) -- 698
	if options == nil then -- 698
		options = {} -- 698
	end -- 698
	local storage = requireAgentStorage() -- 699
	if not storage.success then -- 699
		return storage -- 700
	end -- 700
	if not isValidWorkDir(workDir) then -- 700
		return {success = false, message = "invalid workDir"} -- 702
	end -- 702
	if not getTaskStatus(taskId) then -- 702
		return {success = false, message = "task not found"} -- 705
	end -- 705
	if not isValidWorkspacePath(targetFile) then -- 705
		return {success = false, message = "invalid path: " .. targetFile} -- 708
	end -- 708
	local fullPath = resolveWorkspaceFilePath(workDir, targetFile) -- 710
	if not fullPath then -- 710
		return {success = false, message = "invalid path: " .. targetFile} -- 712
	end -- 712
	if Content:exist(fullPath) and Content:isdir(fullPath) then -- 712
		return {success = false, message = "delete_file only supports files, not directories: " .. targetFile} -- 715
	end -- 715
	local isBinary = false -- 718
	if Content:exist(fullPath) then -- 718
		do -- 718
			local function ____catch(e) -- 718
				Log( -- 724
					"Warn", -- 724
					(("[Agent.Tools] Content.getAttr failed before deleting " .. fullPath) .. ": ") .. tostring(e) -- 724
				) -- 724
			end -- 724
			local ____try, ____hasReturned = pcall(function() -- 724
				local ____, detectedBinary = Content:getAttr(fullPath) -- 721
				isBinary = detectedBinary == true -- 722
			end) -- 722
			if not ____try then -- 722
				____catch(____hasReturned) -- 722
			end -- 722
		end -- 722
	end -- 722
	if not isBinary then -- 722
		local result = ____exports.applyFileChanges(taskId, workDir, {{path = targetFile, op = "delete"}}, options) -- 728
		if not result.success then -- 728
			return result -- 729
		end -- 729
		return __TS__ObjectAssign({}, result, {checkpointed = true, reversible = true, binary = false}) -- 730
	end -- 730
	if not Content:remove(fullPath) then -- 730
		return {success = false, message = "failed to delete binary file: " .. targetFile} -- 739
	end -- 739
	if not sendWebIDEFileUpdate(fullPath, false, "") then -- 739
		sendWebIDERefreshTree() -- 742
	end -- 742
	return { -- 744
		success = true, -- 745
		taskId = taskId, -- 746
		checkpointed = false, -- 747
		reversible = false, -- 748
		binary = true, -- 749
		message = "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back." -- 750
	} -- 750
end -- 698
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 754
	if not isValidWorkDir(workDir) then -- 754
		return {success = false, message = "invalid workDir"} -- 755
	end -- 755
	if checkpointId <= 0 then -- 755
		return {success = false, message = "invalid checkpointId"} -- 756
	end -- 756
	local entries = getCheckpointEntries(checkpointId, true) -- 757
	if #entries == 0 then -- 757
		return {success = false, message = "checkpoint not found or empty"} -- 759
	end -- 759
	for ____, entry in ipairs(entries) do -- 761
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 762
		if not fullPath then -- 762
			return {success = false, message = "invalid path: " .. entry.path} -- 764
		end -- 764
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 766
		if not ok then -- 766
			Log( -- 768
				"Error", -- 768
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 768
			) -- 768
			Log( -- 769
				"Info", -- 769
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 769
			) -- 769
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 770
		end -- 770
		if not sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 770
			Log( -- 773
				"Error", -- 773
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 773
			) -- 773
			Log( -- 774
				"Info", -- 774
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 774
			) -- 774
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 775
		end -- 775
	end -- 775
	DB:exec( -- 778
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 778
		{ -- 778
			"REVERTED", -- 778
			now(), -- 778
			checkpointId -- 778
		} -- 778
	) -- 778
	return {success = true, checkpointId = checkpointId} -- 779
end -- 754
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 782
	if not isValidWorkDir(workDir) then -- 782
		return {success = false, message = "invalid workDir"} -- 783
	end -- 783
	if not getTaskStatus(taskId) then -- 783
		return {success = false, message = "task not found"} -- 784
	end -- 784
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 785
	if #checkpoints == 0 then -- 785
		return {success = false, message = "change set not found or empty"} -- 787
	end -- 787
	local lastCheckpointId = 0 -- 789
	do -- 789
		local i = 0 -- 790
		while i < #checkpoints do -- 790
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 791
			if not result.success then -- 791
				return {success = false, message = result.message} -- 792
			end -- 792
			lastCheckpointId = checkpoints[i + 1].id -- 793
			i = i + 1 -- 790
		end -- 790
	end -- 790
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 795
end -- 782
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 803
	return getCheckpointEntries(checkpointId, false) -- 804
end -- 803
function ____exports.getCheckpointDiff(checkpointId) -- 807
	if checkpointId <= 0 then -- 807
		return {success = false, message = "invalid checkpointId"} -- 809
	end -- 809
	local entries = getCheckpointEntries(checkpointId, false) -- 811
	if #entries == 0 then -- 811
		return {success = false, message = "checkpoint not found or empty"} -- 813
	end -- 813
	return { -- 815
		success = true, -- 816
		files = __TS__ArrayMap( -- 817
			entries, -- 817
			function(____, entry) return { -- 817
				path = entry.path, -- 818
				op = entry.op, -- 819
				beforeExists = entry.beforeExists, -- 820
				afterExists = entry.afterExists, -- 821
				beforeContent = entry.beforeContent, -- 822
				afterContent = entry.afterContent -- 823
			} end -- 823
		) -- 823
	} -- 823
end -- 807
return ____exports -- 807
