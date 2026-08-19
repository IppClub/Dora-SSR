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
local ____AgentStorage = require("Agent.AgentStorage") -- 4
local TABLE_TASK = ____AgentStorage.TABLE_TASK -- 5
local TABLE_CP = ____AgentStorage.TABLE_CHECKPOINT -- 6
local TABLE_ENTRY = ____AgentStorage.TABLE_CHECKPOINT_ENTRY -- 7
local requireAgentStorage = ____AgentStorage.requireAgentStorage -- 8
local ____Utils = require("Agent.Utils") -- 10
local Log = ____Utils.Log -- 10
local ____Workspace = require("Agent.Tool.Workspace") -- 11
local isValidWorkDir = ____Workspace.isValidWorkDir -- 12
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 13
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 14
local toWorkspaceRelativePath = ____Workspace.toWorkspaceRelativePath -- 15
local ensureDirForFile = ____Workspace.ensureDirForFile -- 16
local getFileState = ____Workspace.getFileState -- 17
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 19
local sendWebIDEFileUpdate = ____WebIDESync.sendWebIDEFileUpdate -- 19
local sendWebIDERefreshTree = ____WebIDESync.sendWebIDERefreshTree -- 19
local function now() -- 162
	return os.time() -- 162
end -- 162
local function toBool(v) -- 164
	return v ~= 0 and v ~= false and v ~= nil -- 165
end -- 164
local function toStr(v) -- 168
	if v == false or v == nil then -- 168
		return "" -- 169
	end -- 169
	return tostring(v) -- 170
end -- 168
local function queryOne(sql, args) -- 173
	local ____args_0 -- 174
	if args then -- 174
		____args_0 = DB:query(sql, args) -- 174
	else -- 174
		____args_0 = DB:query(sql) -- 174
	end -- 174
	local rows = ____args_0 -- 174
	if not rows or #rows == 0 then -- 174
		return nil -- 175
	end -- 175
	return rows[1] -- 176
end -- 173
local function getTaskHeadSeq(taskId) -- 179
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 180
	if not row then -- 180
		return nil -- 181
	end -- 181
	return row[1] or 0 -- 182
end -- 179
local function getTaskStatus(taskId) -- 185
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 186
	if not row then -- 186
		return nil -- 187
	end -- 187
	return toStr(row[1]) -- 188
end -- 185
local function getLastInsertRowId() -- 191
	local row = queryOne("SELECT last_insert_rowid()") -- 192
	return row and (row[1] or 0) or 0 -- 193
end -- 191
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 196
	DB:exec( -- 197
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 197
		{ -- 199
			taskId, -- 199
			seq, -- 199
			status, -- 199
			summary, -- 199
			toolName, -- 199
			now() -- 199
		} -- 199
	) -- 199
	return getLastInsertRowId() -- 201
end -- 196
local function getCheckpointEntries(checkpointId, desc) -- 204
	if desc == nil then -- 204
		desc = false -- 204
	end -- 204
	local rows = DB:query((("SELECT id, ord, path, op, before_exists,\n\t\t\tdora_decompress_text(before_data),\n\t\t\tafter_exists,\n\t\t\tdora_decompress_text(after_data)\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 205
	if not rows then -- 205
		return {} -- 215
	end -- 215
	local result = {} -- 216
	do -- 216
		local i = 0 -- 217
		while i < #rows do -- 217
			local row = rows[i + 1] -- 218
			result[#result + 1] = { -- 219
				id = row[1], -- 220
				ord = row[2], -- 221
				path = toStr(row[3]), -- 222
				op = toStr(row[4]), -- 223
				beforeExists = toBool(row[5]), -- 224
				beforeContent = toStr(row[6]), -- 225
				afterExists = toBool(row[7]), -- 226
				afterContent = toStr(row[8]) -- 227
			} -- 227
			i = i + 1 -- 217
		end -- 217
	end -- 217
	return result -- 230
end -- 204
local function getCheckpointEntryMetadata(checkpointId, desc) -- 233
	if desc == nil then -- 233
		desc = false -- 233
	end -- 233
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 234
	if not rows then -- 234
		return {} -- 241
	end -- 241
	local result = {} -- 242
	do -- 242
		local i = 0 -- 243
		while i < #rows do -- 243
			local row = rows[i + 1] -- 244
			result[#result + 1] = { -- 245
				id = row[1], -- 246
				ord = row[2], -- 247
				path = toStr(row[3]), -- 248
				op = toStr(row[4]), -- 249
				beforeExists = toBool(row[5]), -- 250
				afterExists = toBool(row[6]), -- 251
				bytesBefore = row[7] or 0, -- 252
				bytesAfter = row[8] or 0 -- 253
			} -- 253
			i = i + 1 -- 243
		end -- 243
	end -- 243
	return result -- 256
end -- 233
local function rejectDuplicatePaths(changes) -- 259
	local seen = __TS__New(Set) -- 260
	for ____, change in ipairs(changes) do -- 261
		local key = change.path -- 262
		if seen:has(key) then -- 262
			return key -- 263
		end -- 263
		seen:add(key) -- 264
	end -- 264
	return nil -- 266
end -- 259
local function getLinkedDeletePaths(workDir, path) -- 269
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 270
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 270
		return {} -- 271
	end -- 271
	local parent = Path:getPath(fullPath) -- 272
	local baseName = string.lower(Path:getName(fullPath)) -- 273
	local ext = Path:getExt(fullPath) -- 274
	local linked = {} -- 275
	for ____, file in ipairs(Content:getFiles(parent)) do -- 276
		do -- 276
			if string.lower(Path:getName(file)) ~= baseName then -- 276
				goto __continue28 -- 277
			end -- 277
			local siblingExt = Path:getExt(file) -- 278
			if siblingExt == "tl" and ext == "vs" then -- 278
				linked[#linked + 1] = toWorkspaceRelativePath( -- 280
					workDir, -- 280
					Path(parent, file) -- 280
				) -- 280
				goto __continue28 -- 281
			end -- 281
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 281
				linked[#linked + 1] = toWorkspaceRelativePath( -- 284
					workDir, -- 284
					Path(parent, file) -- 284
				) -- 284
			end -- 284
		end -- 284
		::__continue28:: -- 284
	end -- 284
	return linked -- 287
end -- 269
local function expandLinkedDeleteChanges(workDir, changes) -- 290
	local expanded = {} -- 291
	local seen = __TS__New(Set) -- 292
	do -- 292
		local i = 0 -- 293
		while i < #changes do -- 293
			do -- 293
				local change = changes[i + 1] -- 294
				if not seen:has(change.path) then -- 294
					seen:add(change.path) -- 296
					expanded[#expanded + 1] = change -- 297
				end -- 297
				if change.op ~= "delete" then -- 297
					goto __continue35 -- 299
				end -- 299
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 300
				do -- 300
					local j = 0 -- 301
					while j < #linkedPaths do -- 301
						do -- 301
							local linkedPath = linkedPaths[j + 1] -- 302
							if seen:has(linkedPath) then -- 302
								goto __continue39 -- 303
							end -- 303
							seen:add(linkedPath) -- 304
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 305
						end -- 305
						::__continue39:: -- 305
						j = j + 1 -- 301
					end -- 301
				end -- 301
			end -- 301
			::__continue35:: -- 301
			i = i + 1 -- 293
		end -- 293
	end -- 293
	return expanded -- 308
end -- 290
local function applySingleFile(path, exists, content) -- 311
	if exists then -- 311
		if not ensureDirForFile(path) then -- 311
			return false -- 313
		end -- 313
		return Content:save(path, content) -- 314
	end -- 314
	if Content:exist(path) then -- 314
		return Content:remove(path) -- 317
	end -- 317
	return true -- 319
end -- 311
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 322
	local entries = getCheckpointEntries(checkpointId, true) -- 327
	local remaining = appliedCount -- 328
	local failures = {} -- 329
	do -- 329
		local i = 0 -- 330
		while i < #entries and remaining > 0 do -- 330
			do -- 330
				local entry = entries[i + 1] -- 331
				if entry.ord > appliedCount then -- 331
					goto __continue47 -- 332
				end -- 332
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 333
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 333
					failures[#failures + 1] = entry.path -- 335
				else -- 335
					sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 337
				end -- 337
				remaining = remaining - 1 -- 339
			end -- 339
			::__continue47:: -- 339
			i = i + 1 -- 330
		end -- 330
	end -- 330
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 341
end -- 322
function ____exports.createTask(prompt, workMode) -- 344
	if prompt == nil then -- 344
		prompt = "" -- 344
	end -- 344
	if workMode == nil then -- 344
		workMode = "code" -- 344
	end -- 344
	local storage = requireAgentStorage() -- 345
	if not storage.success then -- 345
		return storage -- 346
	end -- 346
	local t = now() -- 347
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 348
		"RUNNING", -- 350
		prompt, -- 350
		workMode, -- 350
		t, -- 350
		t -- 350
	}) -- 350
	if affected <= 0 then -- 350
		return {success = false, message = "failed to create task"} -- 353
	end -- 353
	return { -- 355
		success = true, -- 355
		taskId = getLastInsertRowId() -- 355
	} -- 355
end -- 344
function ____exports.setTaskStatus(taskId, status) -- 358
	DB:exec( -- 359
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 359
		{ -- 359
			status, -- 359
			now(), -- 359
			taskId -- 359
		} -- 359
	) -- 359
	Log( -- 360
		"Info", -- 360
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 360
	) -- 360
end -- 358
function ____exports.listCheckpointsForTasks(taskIds) -- 363
	local normalizedTaskIds = {} -- 364
	local seenTaskIds = {} -- 365
	do -- 365
		local i = 0 -- 366
		while i < #taskIds do -- 366
			do -- 366
				local taskId = math.floor(taskIds[i + 1]) -- 367
				if taskId <= 0 or seenTaskIds[taskId] then -- 367
					goto __continue57 -- 368
				end -- 368
				seenTaskIds[taskId] = true -- 369
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 370
			end -- 370
			::__continue57:: -- 370
			i = i + 1 -- 366
		end -- 366
	end -- 366
	if #normalizedTaskIds == 0 then -- 366
		return {} -- 372
	end -- 372
	local placeholders = table.concat( -- 373
		__TS__ArrayMap( -- 373
			normalizedTaskIds, -- 373
			function() return "?" end -- 373
		), -- 373
		", " -- 373
	) -- 373
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 374
	if not rows then -- 374
		return {} -- 381
	end -- 381
	local items = {} -- 382
	do -- 382
		local i = 0 -- 383
		while i < #rows do -- 383
			local row = rows[i + 1] -- 384
			items[#items + 1] = { -- 385
				id = row[1], -- 386
				taskId = row[2], -- 387
				seq = row[3], -- 388
				status = toStr(row[4]), -- 389
				summary = toStr(row[5]), -- 390
				toolName = toStr(row[6]), -- 391
				createdAt = row[7] -- 392
			} -- 392
			i = i + 1 -- 383
		end -- 383
	end -- 383
	return items -- 395
end -- 363
function ____exports.listCheckpoints(taskId) -- 398
	return ____exports.listCheckpointsForTasks({taskId}) -- 399
end -- 398
function ____exports.getCheckpoint(checkpointId) -- 402
	if checkpointId <= 0 then -- 402
		return nil -- 403
	end -- 403
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 404
	if not rows or #rows == 0 then -- 404
		return nil -- 411
	end -- 411
	local row = rows[1] -- 412
	return { -- 413
		id = row[1], -- 414
		taskId = row[2], -- 415
		seq = row[3], -- 416
		status = toStr(row[4]), -- 417
		summary = toStr(row[5]), -- 418
		toolName = toStr(row[6]), -- 419
		createdAt = row[7] -- 420
	} -- 420
end -- 402
local function listCheckpointIdsForTask(taskId, desc) -- 424
	if desc == nil then -- 424
		desc = false -- 424
	end -- 424
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 425
	if not rows then -- 425
		return {} -- 432
	end -- 432
	local items = {} -- 433
	do -- 433
		local i = 0 -- 434
		while i < #rows do -- 434
			local row = rows[i + 1] -- 435
			items[#items + 1] = {id = row[1], seq = row[2]} -- 436
			i = i + 1 -- 434
		end -- 434
	end -- 434
	return items -- 441
end -- 424
local function deriveFileOp(beforeExists, afterExists) -- 444
	if not beforeExists and afterExists then -- 444
		return "create" -- 445
	end -- 445
	if beforeExists and not afterExists then -- 445
		return "delete" -- 446
	end -- 446
	return "write" -- 447
end -- 444
function ____exports.summarizeTaskChangeSet(taskId) -- 450
	if not getTaskStatus(taskId) then -- 450
		return {success = false, message = "task not found"} -- 452
	end -- 452
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 454
	local filesByPath = {} -- 455
	local latestCheckpointId = nil -- 461
	local latestCheckpointSeq = nil -- 462
	do -- 462
		local i = 0 -- 463
		while i < #checkpoints do -- 463
			local checkpoint = checkpoints[i + 1] -- 464
			latestCheckpointId = checkpoint.id -- 465
			latestCheckpointSeq = checkpoint.seq -- 466
			local entries = getCheckpointEntryMetadata(checkpoint.id, false) -- 467
			do -- 467
				local j = 0 -- 468
				while j < #entries do -- 468
					local entry = entries[j + 1] -- 469
					local item = filesByPath[entry.path] -- 470
					if not item then -- 470
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 472
						filesByPath[entry.path] = item -- 478
					end -- 478
					item.afterExists = entry.afterExists -- 480
					local ____item_checkpointIds_1 = item.checkpointIds -- 480
					____item_checkpointIds_1[#____item_checkpointIds_1 + 1] = checkpoint.id -- 481
					j = j + 1 -- 468
				end -- 468
			end -- 468
			i = i + 1 -- 463
		end -- 463
	end -- 463
	local files = {} -- 484
	for ____, item in pairs(filesByPath) do -- 485
		files[#files + 1] = { -- 486
			path = item.path, -- 487
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 488
			checkpointCount = #item.checkpointIds, -- 489
			checkpointIds = item.checkpointIds -- 490
		} -- 490
	end -- 490
	__TS__ArraySort( -- 493
		files, -- 493
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 493
	) -- 493
	return { -- 494
		success = true, -- 495
		taskId = taskId, -- 496
		checkpointCount = #checkpoints, -- 497
		filesChanged = #files, -- 498
		files = files, -- 499
		latestCheckpointId = latestCheckpointId, -- 500
		latestCheckpointSeq = latestCheckpointSeq -- 501
	} -- 501
end -- 450
function ____exports.getTaskChangeSetDiff(taskId) -- 505
	if not getTaskStatus(taskId) then -- 505
		return {success = false, message = "task not found"} -- 507
	end -- 507
	local entryRows = DB:query(((("SELECT e.id, e.path, e.before_exists, e.after_exists\n\t\tFROM " .. TABLE_ENTRY) .. " e\n\t\tJOIN ") .. TABLE_CP) .. " c ON c.id = e.checkpoint_id\n\t\tWHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY c.seq ASC, e.ord ASC", {taskId}) -- 509
	if not entryRows or #entryRows == 0 then -- 509
		return {success = false, message = "change set not found or empty"} -- 518
	end -- 518
	local filesByPath = {} -- 520
	do -- 520
		local i = 0 -- 527
		while i < #entryRows do -- 527
			local row = entryRows[i + 1] -- 528
			local entryId = row[1] -- 529
			local path = toStr(row[2]) -- 530
			local item = filesByPath[path] -- 531
			if not item then -- 531
				item = { -- 533
					path = path, -- 534
					firstEntryId = entryId, -- 535
					lastEntryId = entryId, -- 536
					beforeExists = toBool(row[3]), -- 537
					afterExists = toBool(row[4]) -- 538
				} -- 538
				filesByPath[path] = item -- 540
			end -- 540
			item.lastEntryId = entryId -- 542
			item.afterExists = toBool(row[4]) -- 543
			i = i + 1 -- 527
		end -- 527
	end -- 527
	local files = {} -- 545
	for ____, item in pairs(filesByPath) do -- 546
		local contentRows = DB:query(((("SELECT\n\t\t\t\t(SELECT dora_decompress_text(before_data) FROM " .. TABLE_ENTRY) .. " WHERE id = ?),\n\t\t\t\t(SELECT dora_decompress_text(after_data) FROM ") .. TABLE_ENTRY) .. " WHERE id = ?)", {item.firstEntryId, item.lastEntryId}) -- 547
		if not contentRows or #contentRows == 0 then -- 547
			return {success = false, message = "failed to read checkpoint data for " .. item.path} -- 554
		end -- 554
		files[#files + 1] = { -- 556
			path = item.path, -- 557
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 558
			beforeExists = item.beforeExists, -- 559
			afterExists = item.afterExists, -- 560
			beforeContent = toStr(contentRows[1][1]), -- 561
			afterContent = toStr(contentRows[1][2]) -- 562
		} -- 562
	end -- 562
	__TS__ArraySort( -- 565
		files, -- 565
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 565
	) -- 565
	return {success = true, files = files} -- 566
end -- 505
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 570
	if options == nil then -- 570
		options = {} -- 570
	end -- 570
	local storage = requireAgentStorage() -- 571
	if not storage.success then -- 571
		return storage -- 572
	end -- 572
	if #changes == 0 then -- 572
		return {success = false, message = "empty changes"} -- 574
	end -- 574
	if not isValidWorkDir(workDir) then -- 574
		return {success = false, message = "invalid workDir"} -- 577
	end -- 577
	if not getTaskStatus(taskId) then -- 577
		return {success = false, message = "task not found"} -- 580
	end -- 580
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 582
	local dup = rejectDuplicatePaths(expandedChanges) -- 583
	if dup then -- 583
		return {success = false, message = "duplicate path in batch: " .. dup} -- 585
	end -- 585
	for ____, change in ipairs(expandedChanges) do -- 588
		if not isValidWorkspacePath(change.path) then -- 588
			return {success = false, message = "invalid path: " .. change.path} -- 590
		end -- 590
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 590
			return {success = false, message = "missing content for " .. change.path} -- 593
		end -- 593
	end -- 593
	local headSeq = getTaskHeadSeq(taskId) -- 597
	if headSeq == nil then -- 597
		return {success = false, message = "task not found"} -- 598
	end -- 598
	local nextSeq = headSeq + 1 -- 599
	local preparedEntries = {} -- 601
	do -- 601
		local i = 0 -- 602
		while i < #expandedChanges do -- 602
			local change = expandedChanges[i + 1] -- 603
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 604
			if not fullPath then -- 604
				return {success = false, message = "invalid path: " .. change.path} -- 606
			end -- 606
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 606
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 609
			end -- 609
			if Content:exist(fullPath) and not Content:isdir(fullPath) then -- 609
				local ____, isBinary = Content:getAttr(fullPath) -- 612
				if isBinary == true then -- 612
					return {success = false, message = change.op == "delete" and "binary file deletion must use delete_file: " .. change.path or "binary files cannot be edited with text checkpoints: " .. change.path} -- 614
				end -- 614
			end -- 614
			local before = getFileState(fullPath) -- 622
			local afterExists = change.op ~= "delete" -- 623
			local afterContent = afterExists and (change.content or "") or "" -- 624
			preparedEntries[#preparedEntries + 1] = { -- 625
				id = 0, -- 626
				ord = i + 1, -- 627
				path = change.path, -- 628
				op = change.op, -- 629
				beforeExists = before.exists, -- 630
				beforeContent = before.content, -- 631
				afterExists = afterExists, -- 632
				afterContent = afterContent -- 633
			} -- 633
			i = i + 1 -- 602
		end -- 602
	end -- 602
	local checkpointId = insertCheckpoint( -- 637
		taskId, -- 637
		nextSeq, -- 637
		options.summary or "", -- 637
		options.toolName or "", -- 637
		"PREPARED" -- 637
	) -- 637
	if checkpointId <= 0 then -- 637
		return {success = false, message = "failed to create checkpoint"} -- 639
	end -- 639
	local entryRows = {} -- 641
	do -- 641
		local i = 0 -- 642
		while i < #preparedEntries do -- 642
			local entry = preparedEntries[i + 1] -- 643
			entryRows[#entryRows + 1] = { -- 644
				checkpointId, -- 645
				entry.ord, -- 646
				entry.path, -- 647
				entry.op, -- 648
				entry.beforeExists and 1 or 0, -- 649
				entry.beforeContent, -- 650
				entry.afterExists and 1 or 0, -- 651
				entry.afterContent, -- 652
				#entry.beforeContent, -- 653
				#entry.afterContent -- 654
			} -- 654
			i = i + 1 -- 642
		end -- 642
	end -- 642
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 657
	if not DB:transaction({entryInsert}) then -- 657
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 663
		return {success = false, message = "failed to insert checkpoint entries"} -- 664
	end -- 664
	local appliedCount = 0 -- 667
	for ____, entry in ipairs(preparedEntries) do -- 668
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 669
		if not fullPath then -- 669
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 671
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 672
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 673
		end -- 673
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 675
		if not ok then -- 675
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 677
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 678
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 679
		end -- 679
		appliedCount = appliedCount + 1 -- 681
		if not sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 681
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 683
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 684
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 685
		end -- 685
	end -- 685
	DB:exec( -- 689
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 689
		{ -- 691
			"APPLIED", -- 691
			now(), -- 691
			checkpointId -- 691
		} -- 691
	) -- 691
	DB:exec( -- 693
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 693
		{ -- 695
			nextSeq, -- 695
			now(), -- 695
			taskId -- 695
		} -- 695
	) -- 695
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 697
end -- 570
function ____exports.deleteFile(taskId, workDir, targetFile, options) -- 705
	if options == nil then -- 705
		options = {} -- 705
	end -- 705
	local storage = requireAgentStorage() -- 706
	if not storage.success then -- 706
		return storage -- 707
	end -- 707
	if not isValidWorkDir(workDir) then -- 707
		return {success = false, message = "invalid workDir"} -- 709
	end -- 709
	if not getTaskStatus(taskId) then -- 709
		return {success = false, message = "task not found"} -- 712
	end -- 712
	if not isValidWorkspacePath(targetFile) then -- 712
		return {success = false, message = "invalid path: " .. targetFile} -- 715
	end -- 715
	local fullPath = resolveWorkspaceFilePath(workDir, targetFile) -- 717
	if not fullPath then -- 717
		return {success = false, message = "invalid path: " .. targetFile} -- 719
	end -- 719
	if Content:exist(fullPath) and Content:isdir(fullPath) then -- 719
		return {success = false, message = "delete_file only supports files, not directories: " .. targetFile} -- 722
	end -- 722
	local isBinary = false -- 725
	if Content:exist(fullPath) then -- 725
		do -- 725
			local function ____catch(e) -- 725
				Log( -- 731
					"Warn", -- 731
					(("[Agent.Tools] Content.getAttr failed before deleting " .. fullPath) .. ": ") .. tostring(e) -- 731
				) -- 731
			end -- 731
			local ____try, ____hasReturned = pcall(function() -- 731
				local ____, detectedBinary = Content:getAttr(fullPath) -- 728
				isBinary = detectedBinary == true -- 729
			end) -- 729
			if not ____try then -- 729
				____catch(____hasReturned) -- 729
			end -- 729
		end -- 729
	end -- 729
	if not isBinary then -- 729
		local result = ____exports.applyFileChanges(taskId, workDir, {{path = targetFile, op = "delete"}}, options) -- 735
		if not result.success then -- 735
			return result -- 736
		end -- 736
		return __TS__ObjectAssign({}, result, {checkpointed = true, reversible = true, binary = false}) -- 737
	end -- 737
	if not Content:remove(fullPath) then -- 737
		return {success = false, message = "failed to delete binary file: " .. targetFile} -- 746
	end -- 746
	if not sendWebIDEFileUpdate(fullPath, false, "") then -- 746
		sendWebIDERefreshTree() -- 749
	end -- 749
	return { -- 751
		success = true, -- 752
		taskId = taskId, -- 753
		checkpointed = false, -- 754
		reversible = false, -- 755
		binary = true, -- 756
		message = "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back." -- 757
	} -- 757
end -- 705
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 761
	if not isValidWorkDir(workDir) then -- 761
		return {success = false, message = "invalid workDir"} -- 762
	end -- 762
	if checkpointId <= 0 then -- 762
		return {success = false, message = "invalid checkpointId"} -- 763
	end -- 763
	local entries = getCheckpointEntries(checkpointId, true) -- 764
	if #entries == 0 then -- 764
		return {success = false, message = "checkpoint not found or empty"} -- 766
	end -- 766
	for ____, entry in ipairs(entries) do -- 768
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 769
		if not fullPath then -- 769
			return {success = false, message = "invalid path: " .. entry.path} -- 771
		end -- 771
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 773
		if not ok then -- 773
			Log( -- 775
				"Error", -- 775
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 775
			) -- 775
			Log( -- 776
				"Info", -- 776
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 776
			) -- 776
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 777
		end -- 777
		if not sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 777
			Log( -- 780
				"Error", -- 780
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 780
			) -- 780
			Log( -- 781
				"Info", -- 781
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 781
			) -- 781
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 782
		end -- 782
	end -- 782
	DB:exec( -- 785
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 785
		{ -- 785
			"REVERTED", -- 785
			now(), -- 785
			checkpointId -- 785
		} -- 785
	) -- 785
	return {success = true, checkpointId = checkpointId} -- 786
end -- 761
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 789
	if not isValidWorkDir(workDir) then -- 789
		return {success = false, message = "invalid workDir"} -- 790
	end -- 790
	if not getTaskStatus(taskId) then -- 790
		return {success = false, message = "task not found"} -- 791
	end -- 791
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 792
	if #checkpoints == 0 then -- 792
		return {success = false, message = "change set not found or empty"} -- 794
	end -- 794
	local lastCheckpointId = 0 -- 796
	do -- 796
		local i = 0 -- 797
		while i < #checkpoints do -- 797
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 798
			if not result.success then -- 798
				return {success = false, message = result.message} -- 799
			end -- 799
			lastCheckpointId = checkpoints[i + 1].id -- 800
			i = i + 1 -- 797
		end -- 797
	end -- 797
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 802
end -- 789
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 810
	return getCheckpointEntries(checkpointId, false) -- 811
end -- 810
function ____exports.getCheckpointDiff(checkpointId) -- 814
	if checkpointId <= 0 then -- 814
		return {success = false, message = "invalid checkpointId"} -- 816
	end -- 816
	local entries = getCheckpointEntries(checkpointId, false) -- 818
	if #entries == 0 then -- 818
		return {success = false, message = "checkpoint not found or empty"} -- 820
	end -- 820
	return { -- 822
		success = true, -- 823
		files = __TS__ArrayMap( -- 824
			entries, -- 824
			function(____, entry) return { -- 824
				path = entry.path, -- 825
				op = entry.op, -- 826
				beforeExists = entry.beforeExists, -- 827
				afterExists = entry.afterExists, -- 828
				beforeContent = entry.beforeContent, -- 829
				afterContent = entry.afterContent -- 830
			} end -- 830
		) -- 830
	} -- 830
end -- 814
return ____exports -- 814