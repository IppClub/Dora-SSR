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
local ____Support = require("Agent.Storage.Support") -- 20
local getLastInsertRowId = ____Support.getLastInsertRowId -- 20
local queryOne = ____Support.queryOne -- 20
local toStr = ____Support.toStr -- 20
local function now() -- 163
	return os.time() -- 163
end -- 163
local function toBool(v) -- 165
	return v ~= 0 and v ~= false and v ~= nil -- 166
end -- 165
local function getTaskHeadSeq(taskId) -- 169
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 170
	if not row then -- 170
		return nil -- 171
	end -- 171
	return row[1] or 0 -- 172
end -- 169
local function getTaskStatus(taskId) -- 175
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 176
	if not row then -- 176
		return nil -- 177
	end -- 177
	return toStr(row[1]) -- 178
end -- 175
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 181
	DB:exec( -- 182
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 182
		{ -- 184
			taskId, -- 184
			seq, -- 184
			status, -- 184
			summary, -- 184
			toolName, -- 184
			now() -- 184
		} -- 184
	) -- 184
	return getLastInsertRowId() -- 186
end -- 181
local function getCheckpointEntries(checkpointId, desc) -- 189
	if desc == nil then -- 189
		desc = false -- 189
	end -- 189
	local rows = DB:query((("SELECT id, ord, path, op, before_exists,\n\t\t\tdora_decompress_text(before_data),\n\t\t\tafter_exists,\n\t\t\tdora_decompress_text(after_data)\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 190
	if not rows then -- 190
		return {} -- 200
	end -- 200
	local result = {} -- 201
	do -- 201
		local i = 0 -- 202
		while i < #rows do -- 202
			local row = rows[i + 1] -- 203
			result[#result + 1] = { -- 204
				id = row[1], -- 205
				ord = row[2], -- 206
				path = toStr(row[3]), -- 207
				op = toStr(row[4]), -- 208
				beforeExists = toBool(row[5]), -- 209
				beforeContent = toStr(row[6]), -- 210
				afterExists = toBool(row[7]), -- 211
				afterContent = toStr(row[8]) -- 212
			} -- 212
			i = i + 1 -- 202
		end -- 202
	end -- 202
	return result -- 215
end -- 189
local function getCheckpointEntryMetadata(checkpointId, desc) -- 218
	if desc == nil then -- 218
		desc = false -- 218
	end -- 218
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 219
	if not rows then -- 219
		return {} -- 226
	end -- 226
	local result = {} -- 227
	do -- 227
		local i = 0 -- 228
		while i < #rows do -- 228
			local row = rows[i + 1] -- 229
			result[#result + 1] = { -- 230
				id = row[1], -- 231
				ord = row[2], -- 232
				path = toStr(row[3]), -- 233
				op = toStr(row[4]), -- 234
				beforeExists = toBool(row[5]), -- 235
				afterExists = toBool(row[6]), -- 236
				bytesBefore = row[7] or 0, -- 237
				bytesAfter = row[8] or 0 -- 238
			} -- 238
			i = i + 1 -- 228
		end -- 228
	end -- 228
	return result -- 241
end -- 218
local function rejectDuplicatePaths(changes) -- 244
	local seen = __TS__New(Set) -- 245
	for ____, change in ipairs(changes) do -- 246
		local key = change.path -- 247
		if seen:has(key) then -- 247
			return key -- 248
		end -- 248
		seen:add(key) -- 249
	end -- 249
	return nil -- 251
end -- 244
local function getLinkedDeletePaths(workDir, path) -- 254
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 255
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 255
		return {} -- 256
	end -- 256
	local parent = Path:getPath(fullPath) -- 257
	local baseName = string.lower(Path:getName(fullPath)) -- 258
	local ext = Path:getExt(fullPath) -- 259
	local linked = {} -- 260
	for ____, file in ipairs(Content:getFiles(parent)) do -- 261
		do -- 261
			if string.lower(Path:getName(file)) ~= baseName then -- 261
				goto __continue23 -- 262
			end -- 262
			local siblingExt = Path:getExt(file) -- 263
			if siblingExt == "tl" and ext == "vs" then -- 263
				linked[#linked + 1] = toWorkspaceRelativePath( -- 265
					workDir, -- 265
					Path(parent, file) -- 265
				) -- 265
				goto __continue23 -- 266
			end -- 266
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 266
				linked[#linked + 1] = toWorkspaceRelativePath( -- 269
					workDir, -- 269
					Path(parent, file) -- 269
				) -- 269
			end -- 269
		end -- 269
		::__continue23:: -- 269
	end -- 269
	return linked -- 272
end -- 254
local function expandLinkedDeleteChanges(workDir, changes) -- 275
	local expanded = {} -- 276
	local seen = __TS__New(Set) -- 277
	do -- 277
		local i = 0 -- 278
		while i < #changes do -- 278
			do -- 278
				local change = changes[i + 1] -- 279
				if not seen:has(change.path) then -- 279
					seen:add(change.path) -- 281
					expanded[#expanded + 1] = change -- 282
				end -- 282
				if change.op ~= "delete" then -- 282
					goto __continue30 -- 284
				end -- 284
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 285
				do -- 285
					local j = 0 -- 286
					while j < #linkedPaths do -- 286
						do -- 286
							local linkedPath = linkedPaths[j + 1] -- 287
							if seen:has(linkedPath) then -- 287
								goto __continue34 -- 288
							end -- 288
							seen:add(linkedPath) -- 289
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 290
						end -- 290
						::__continue34:: -- 290
						j = j + 1 -- 286
					end -- 286
				end -- 286
			end -- 286
			::__continue30:: -- 286
			i = i + 1 -- 278
		end -- 278
	end -- 278
	return expanded -- 293
end -- 275
local function applySingleFile(path, exists, content) -- 296
	if exists then -- 296
		if not ensureDirForFile(path) then -- 296
			return false -- 298
		end -- 298
		return Content:save(path, content) -- 299
	end -- 299
	if Content:exist(path) then -- 299
		return Content:remove(path) -- 302
	end -- 302
	return true -- 304
end -- 296
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 307
	local entries = getCheckpointEntries(checkpointId, true) -- 312
	local remaining = appliedCount -- 313
	local failures = {} -- 314
	do -- 314
		local i = 0 -- 315
		while i < #entries and remaining > 0 do -- 315
			do -- 315
				local entry = entries[i + 1] -- 316
				if entry.ord > appliedCount then -- 316
					goto __continue42 -- 317
				end -- 317
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 318
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 318
					failures[#failures + 1] = entry.path -- 320
				else -- 320
					sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 322
				end -- 322
				remaining = remaining - 1 -- 324
			end -- 324
			::__continue42:: -- 324
			i = i + 1 -- 315
		end -- 315
	end -- 315
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 326
end -- 307
function ____exports.createTask(prompt, workMode) -- 329
	if prompt == nil then -- 329
		prompt = "" -- 329
	end -- 329
	if workMode == nil then -- 329
		workMode = "code" -- 329
	end -- 329
	local storage = requireAgentStorage() -- 330
	if not storage.success then -- 330
		return storage -- 331
	end -- 331
	local t = now() -- 332
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 333
		"RUNNING", -- 335
		prompt, -- 335
		workMode, -- 335
		t, -- 335
		t -- 335
	}) -- 335
	if affected <= 0 then -- 335
		return {success = false, message = "failed to create task"} -- 338
	end -- 338
	return { -- 340
		success = true, -- 340
		taskId = getLastInsertRowId() -- 340
	} -- 340
end -- 329
function ____exports.setTaskStatus(taskId, status) -- 343
	DB:exec( -- 344
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 344
		{ -- 344
			status, -- 344
			now(), -- 344
			taskId -- 344
		} -- 344
	) -- 344
	Log( -- 345
		"Info", -- 345
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 345
	) -- 345
end -- 343
function ____exports.listCheckpointsForTasks(taskIds) -- 348
	local normalizedTaskIds = {} -- 349
	local seenTaskIds = {} -- 350
	do -- 350
		local i = 0 -- 351
		while i < #taskIds do -- 351
			do -- 351
				local taskId = math.floor(taskIds[i + 1]) -- 352
				if taskId <= 0 or seenTaskIds[taskId] then -- 352
					goto __continue52 -- 353
				end -- 353
				seenTaskIds[taskId] = true -- 354
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 355
			end -- 355
			::__continue52:: -- 355
			i = i + 1 -- 351
		end -- 351
	end -- 351
	if #normalizedTaskIds == 0 then -- 351
		return {} -- 357
	end -- 357
	local placeholders = table.concat( -- 358
		__TS__ArrayMap( -- 358
			normalizedTaskIds, -- 358
			function() return "?" end -- 358
		), -- 358
		", " -- 358
	) -- 358
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 359
	if not rows then -- 359
		return {} -- 366
	end -- 366
	local items = {} -- 367
	do -- 367
		local i = 0 -- 368
		while i < #rows do -- 368
			local row = rows[i + 1] -- 369
			items[#items + 1] = { -- 370
				id = row[1], -- 371
				taskId = row[2], -- 372
				seq = row[3], -- 373
				status = toStr(row[4]), -- 374
				summary = toStr(row[5]), -- 375
				toolName = toStr(row[6]), -- 376
				createdAt = row[7] -- 377
			} -- 377
			i = i + 1 -- 368
		end -- 368
	end -- 368
	return items -- 380
end -- 348
function ____exports.listCheckpoints(taskId) -- 383
	return ____exports.listCheckpointsForTasks({taskId}) -- 384
end -- 383
function ____exports.getCheckpoint(checkpointId) -- 387
	if checkpointId <= 0 then -- 387
		return nil -- 388
	end -- 388
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 389
	if not rows or #rows == 0 then -- 389
		return nil -- 396
	end -- 396
	local row = rows[1] -- 397
	return { -- 398
		id = row[1], -- 399
		taskId = row[2], -- 400
		seq = row[3], -- 401
		status = toStr(row[4]), -- 402
		summary = toStr(row[5]), -- 403
		toolName = toStr(row[6]), -- 404
		createdAt = row[7] -- 405
	} -- 405
end -- 387
local function listCheckpointIdsForTask(taskId, desc) -- 409
	if desc == nil then -- 409
		desc = false -- 409
	end -- 409
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 410
	if not rows then -- 410
		return {} -- 417
	end -- 417
	local items = {} -- 418
	do -- 418
		local i = 0 -- 419
		while i < #rows do -- 419
			local row = rows[i + 1] -- 420
			items[#items + 1] = {id = row[1], seq = row[2]} -- 421
			i = i + 1 -- 419
		end -- 419
	end -- 419
	return items -- 426
end -- 409
local function deriveFileOp(beforeExists, afterExists) -- 429
	if not beforeExists and afterExists then -- 429
		return "create" -- 430
	end -- 430
	if beforeExists and not afterExists then -- 430
		return "delete" -- 431
	end -- 431
	return "write" -- 432
end -- 429
function ____exports.summarizeTaskChangeSet(taskId) -- 435
	if not getTaskStatus(taskId) then -- 435
		return {success = false, message = "task not found"} -- 437
	end -- 437
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 439
	local filesByPath = {} -- 440
	local latestCheckpointId = nil -- 446
	local latestCheckpointSeq = nil -- 447
	do -- 447
		local i = 0 -- 448
		while i < #checkpoints do -- 448
			local checkpoint = checkpoints[i + 1] -- 449
			latestCheckpointId = checkpoint.id -- 450
			latestCheckpointSeq = checkpoint.seq -- 451
			local entries = getCheckpointEntryMetadata(checkpoint.id, false) -- 452
			do -- 452
				local j = 0 -- 453
				while j < #entries do -- 453
					local entry = entries[j + 1] -- 454
					local item = filesByPath[entry.path] -- 455
					if not item then -- 455
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 457
						filesByPath[entry.path] = item -- 463
					end -- 463
					item.afterExists = entry.afterExists -- 465
					local ____item_checkpointIds_0 = item.checkpointIds -- 465
					____item_checkpointIds_0[#____item_checkpointIds_0 + 1] = checkpoint.id -- 466
					j = j + 1 -- 453
				end -- 453
			end -- 453
			i = i + 1 -- 448
		end -- 448
	end -- 448
	local files = {} -- 469
	for ____, item in pairs(filesByPath) do -- 470
		files[#files + 1] = { -- 471
			path = item.path, -- 472
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 473
			checkpointCount = #item.checkpointIds, -- 474
			checkpointIds = item.checkpointIds -- 475
		} -- 475
	end -- 475
	__TS__ArraySort( -- 478
		files, -- 478
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 478
	) -- 478
	return { -- 479
		success = true, -- 480
		taskId = taskId, -- 481
		checkpointCount = #checkpoints, -- 482
		filesChanged = #files, -- 483
		files = files, -- 484
		latestCheckpointId = latestCheckpointId, -- 485
		latestCheckpointSeq = latestCheckpointSeq -- 486
	} -- 486
end -- 435
function ____exports.getTaskChangeSetDiff(taskId) -- 490
	if not getTaskStatus(taskId) then -- 490
		return {success = false, message = "task not found"} -- 492
	end -- 492
	local entryRows = DB:query(((("SELECT e.id, e.path, e.before_exists, e.after_exists\n\t\tFROM " .. TABLE_ENTRY) .. " e\n\t\tJOIN ") .. TABLE_CP) .. " c ON c.id = e.checkpoint_id\n\t\tWHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY c.seq ASC, e.ord ASC", {taskId}) -- 494
	if not entryRows or #entryRows == 0 then -- 494
		return {success = false, message = "change set not found or empty"} -- 503
	end -- 503
	local filesByPath = {} -- 505
	do -- 505
		local i = 0 -- 512
		while i < #entryRows do -- 512
			local row = entryRows[i + 1] -- 513
			local entryId = row[1] -- 514
			local path = toStr(row[2]) -- 515
			local item = filesByPath[path] -- 516
			if not item then -- 516
				item = { -- 518
					path = path, -- 519
					firstEntryId = entryId, -- 520
					lastEntryId = entryId, -- 521
					beforeExists = toBool(row[3]), -- 522
					afterExists = toBool(row[4]) -- 523
				} -- 523
				filesByPath[path] = item -- 525
			end -- 525
			item.lastEntryId = entryId -- 527
			item.afterExists = toBool(row[4]) -- 528
			i = i + 1 -- 512
		end -- 512
	end -- 512
	local files = {} -- 530
	for ____, item in pairs(filesByPath) do -- 531
		local contentRows = DB:query(((("SELECT\n\t\t\t\t(SELECT dora_decompress_text(before_data) FROM " .. TABLE_ENTRY) .. " WHERE id = ?),\n\t\t\t\t(SELECT dora_decompress_text(after_data) FROM ") .. TABLE_ENTRY) .. " WHERE id = ?)", {item.firstEntryId, item.lastEntryId}) -- 532
		if not contentRows or #contentRows == 0 then -- 532
			return {success = false, message = "failed to read checkpoint data for " .. item.path} -- 539
		end -- 539
		files[#files + 1] = { -- 541
			path = item.path, -- 542
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 543
			beforeExists = item.beforeExists, -- 544
			afterExists = item.afterExists, -- 545
			beforeContent = toStr(contentRows[1][1]), -- 546
			afterContent = toStr(contentRows[1][2]) -- 547
		} -- 547
	end -- 547
	__TS__ArraySort( -- 550
		files, -- 550
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 550
	) -- 550
	return {success = true, files = files} -- 551
end -- 490
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 555
	if options == nil then -- 555
		options = {} -- 555
	end -- 555
	local storage = requireAgentStorage() -- 556
	if not storage.success then -- 556
		return storage -- 557
	end -- 557
	if #changes == 0 then -- 557
		return {success = false, message = "empty changes"} -- 559
	end -- 559
	if not isValidWorkDir(workDir) then -- 559
		return {success = false, message = "invalid workDir"} -- 562
	end -- 562
	if not getTaskStatus(taskId) then -- 562
		return {success = false, message = "task not found"} -- 565
	end -- 565
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 567
	local dup = rejectDuplicatePaths(expandedChanges) -- 568
	if dup then -- 568
		return {success = false, message = "duplicate path in batch: " .. dup} -- 570
	end -- 570
	for ____, change in ipairs(expandedChanges) do -- 573
		if not isValidWorkspacePath(change.path) then -- 573
			return {success = false, message = "invalid path: " .. change.path} -- 575
		end -- 575
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 575
			return {success = false, message = "missing content for " .. change.path} -- 578
		end -- 578
	end -- 578
	local headSeq = getTaskHeadSeq(taskId) -- 582
	if headSeq == nil then -- 582
		return {success = false, message = "task not found"} -- 583
	end -- 583
	local nextSeq = headSeq + 1 -- 584
	local preparedEntries = {} -- 586
	do -- 586
		local i = 0 -- 587
		while i < #expandedChanges do -- 587
			local change = expandedChanges[i + 1] -- 588
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 589
			if not fullPath then -- 589
				return {success = false, message = "invalid path: " .. change.path} -- 591
			end -- 591
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 591
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 594
			end -- 594
			if Content:exist(fullPath) and not Content:isdir(fullPath) then -- 594
				local ____, isBinary = Content:getAttr(fullPath) -- 597
				if isBinary == true then -- 597
					return {success = false, message = change.op == "delete" and "binary file deletion must use delete_file: " .. change.path or "binary files cannot be edited with text checkpoints: " .. change.path} -- 599
				end -- 599
			end -- 599
			local before = getFileState(fullPath) -- 607
			local afterExists = change.op ~= "delete" -- 608
			local afterContent = afterExists and (change.content or "") or "" -- 609
			preparedEntries[#preparedEntries + 1] = { -- 610
				id = 0, -- 611
				ord = i + 1, -- 612
				path = change.path, -- 613
				op = change.op, -- 614
				beforeExists = before.exists, -- 615
				beforeContent = before.content, -- 616
				afterExists = afterExists, -- 617
				afterContent = afterContent -- 618
			} -- 618
			i = i + 1 -- 587
		end -- 587
	end -- 587
	local checkpointId = insertCheckpoint( -- 622
		taskId, -- 622
		nextSeq, -- 622
		options.summary or "", -- 622
		options.toolName or "", -- 622
		"PREPARED" -- 622
	) -- 622
	if checkpointId <= 0 then -- 622
		return {success = false, message = "failed to create checkpoint"} -- 624
	end -- 624
	local entryRows = {} -- 626
	do -- 626
		local i = 0 -- 627
		while i < #preparedEntries do -- 627
			local entry = preparedEntries[i + 1] -- 628
			entryRows[#entryRows + 1] = { -- 629
				checkpointId, -- 630
				entry.ord, -- 631
				entry.path, -- 632
				entry.op, -- 633
				entry.beforeExists and 1 or 0, -- 634
				entry.beforeContent, -- 635
				entry.afterExists and 1 or 0, -- 636
				entry.afterContent, -- 637
				#entry.beforeContent, -- 638
				#entry.afterContent -- 639
			} -- 639
			i = i + 1 -- 627
		end -- 627
	end -- 627
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 642
	if not DB:transaction({entryInsert}) then -- 642
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 648
		return {success = false, message = "failed to insert checkpoint entries"} -- 649
	end -- 649
	local appliedCount = 0 -- 652
	for ____, entry in ipairs(preparedEntries) do -- 653
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 654
		if not fullPath then -- 654
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 656
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 657
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 658
		end -- 658
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 660
		if not ok then -- 660
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 662
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 663
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 664
		end -- 664
		appliedCount = appliedCount + 1 -- 666
		if not sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 666
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 668
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 669
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 670
		end -- 670
	end -- 670
	DB:exec( -- 674
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 674
		{ -- 676
			"APPLIED", -- 676
			now(), -- 676
			checkpointId -- 676
		} -- 676
	) -- 676
	DB:exec( -- 678
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 678
		{ -- 680
			nextSeq, -- 680
			now(), -- 680
			taskId -- 680
		} -- 680
	) -- 680
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 682
end -- 555
function ____exports.deleteFile(taskId, workDir, targetFile, options) -- 690
	if options == nil then -- 690
		options = {} -- 690
	end -- 690
	local storage = requireAgentStorage() -- 691
	if not storage.success then -- 691
		return storage -- 692
	end -- 692
	if not isValidWorkDir(workDir) then -- 692
		return {success = false, message = "invalid workDir"} -- 694
	end -- 694
	if not getTaskStatus(taskId) then -- 694
		return {success = false, message = "task not found"} -- 697
	end -- 697
	if not isValidWorkspacePath(targetFile) then -- 697
		return {success = false, message = "invalid path: " .. targetFile} -- 700
	end -- 700
	local fullPath = resolveWorkspaceFilePath(workDir, targetFile) -- 702
	if not fullPath then -- 702
		return {success = false, message = "invalid path: " .. targetFile} -- 704
	end -- 704
	if Content:exist(fullPath) and Content:isdir(fullPath) then -- 704
		return {success = false, message = "delete_file only supports files, not directories: " .. targetFile} -- 707
	end -- 707
	local isBinary = false -- 710
	if Content:exist(fullPath) then -- 710
		do -- 710
			local function ____catch(e) -- 710
				Log( -- 716
					"Warn", -- 716
					(("[Agent.Tools] Content.getAttr failed before deleting " .. fullPath) .. ": ") .. tostring(e) -- 716
				) -- 716
			end -- 716
			local ____try, ____hasReturned = pcall(function() -- 716
				local ____, detectedBinary = Content:getAttr(fullPath) -- 713
				isBinary = detectedBinary == true -- 714
			end) -- 714
			if not ____try then -- 714
				____catch(____hasReturned) -- 714
			end -- 714
		end -- 714
	end -- 714
	if not isBinary then -- 714
		local result = ____exports.applyFileChanges(taskId, workDir, {{path = targetFile, op = "delete"}}, options) -- 720
		if not result.success then -- 720
			return result -- 721
		end -- 721
		return __TS__ObjectAssign({}, result, {checkpointed = true, reversible = true, binary = false}) -- 722
	end -- 722
	if not Content:remove(fullPath) then -- 722
		return {success = false, message = "failed to delete binary file: " .. targetFile} -- 731
	end -- 731
	if not sendWebIDEFileUpdate(fullPath, false, "") then -- 731
		sendWebIDERefreshTree() -- 734
	end -- 734
	return { -- 736
		success = true, -- 737
		taskId = taskId, -- 738
		checkpointed = false, -- 739
		reversible = false, -- 740
		binary = true, -- 741
		message = "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back." -- 742
	} -- 742
end -- 690
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 746
	if not isValidWorkDir(workDir) then -- 746
		return {success = false, message = "invalid workDir"} -- 747
	end -- 747
	if checkpointId <= 0 then -- 747
		return {success = false, message = "invalid checkpointId"} -- 748
	end -- 748
	local entries = getCheckpointEntries(checkpointId, true) -- 749
	if #entries == 0 then -- 749
		return {success = false, message = "checkpoint not found or empty"} -- 751
	end -- 751
	for ____, entry in ipairs(entries) do -- 753
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 754
		if not fullPath then -- 754
			return {success = false, message = "invalid path: " .. entry.path} -- 756
		end -- 756
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 758
		if not ok then -- 758
			Log( -- 760
				"Error", -- 760
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 760
			) -- 760
			Log( -- 761
				"Info", -- 761
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 761
			) -- 761
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 762
		end -- 762
		if not sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 762
			Log( -- 765
				"Error", -- 765
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 765
			) -- 765
			Log( -- 766
				"Info", -- 766
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 766
			) -- 766
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 767
		end -- 767
	end -- 767
	DB:exec( -- 770
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 770
		{ -- 770
			"REVERTED", -- 770
			now(), -- 770
			checkpointId -- 770
		} -- 770
	) -- 770
	return {success = true, checkpointId = checkpointId} -- 771
end -- 746
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 774
	if not isValidWorkDir(workDir) then -- 774
		return {success = false, message = "invalid workDir"} -- 775
	end -- 775
	if not getTaskStatus(taskId) then -- 775
		return {success = false, message = "task not found"} -- 776
	end -- 776
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 777
	if #checkpoints == 0 then -- 777
		return {success = false, message = "change set not found or empty"} -- 779
	end -- 779
	local lastCheckpointId = 0 -- 781
	do -- 781
		local i = 0 -- 782
		while i < #checkpoints do -- 782
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 783
			if not result.success then -- 783
				return {success = false, message = result.message} -- 784
			end -- 784
			lastCheckpointId = checkpoints[i + 1].id -- 785
			i = i + 1 -- 782
		end -- 782
	end -- 782
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 787
end -- 774
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 795
	return getCheckpointEntries(checkpointId, false) -- 796
end -- 795
function ____exports.getCheckpointDiff(checkpointId) -- 799
	if checkpointId <= 0 then -- 799
		return {success = false, message = "invalid checkpointId"} -- 801
	end -- 801
	local entries = getCheckpointEntries(checkpointId, false) -- 803
	if #entries == 0 then -- 803
		return {success = false, message = "checkpoint not found or empty"} -- 805
	end -- 805
	return { -- 807
		success = true, -- 808
		files = __TS__ArrayMap( -- 809
			entries, -- 809
			function(____, entry) return { -- 809
				path = entry.path, -- 810
				op = entry.op, -- 811
				beforeExists = entry.beforeExists, -- 812
				afterExists = entry.afterExists, -- 813
				beforeContent = entry.beforeContent, -- 814
				afterContent = entry.afterContent -- 815
			} end -- 815
		) -- 815
	} -- 815
end -- 799
return ____exports -- 799