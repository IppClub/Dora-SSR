-- Native status/settings panel. Queries run only on expansion, refresh and
-- completion of an explicitly requested cleanup; no periodic job is installed.
local Dora = require("Dora")
local ImGui = Dora.ImGui
local usage, readError, notice
local busy, attempted, cleaned, failed = false, 0, 0, 0

local function bytes(value)
	if value >= 1024 * 1024 then return string.format("%.2f MiB", value / (1024 * 1024)) end
	if value >= 1024 then return string.format("%.1f KiB", value / 1024) end
	return string.format("%d B", value)
end

local function refresh()
	local ok, result = pcall(function() return require("Agent.Storage.Database").getStorageUsage() end)
	if ok and result.success then usage, readError = result.usage, nil
	else usage, readError = nil, ok and result.message or tostring(result) end
end

local function startCleanup(zh)
	refresh()
	if not usage or usage.orphanHeavyData.taskCount == 0 then return end
	local budget = usage.orphanHeavyData.taskCount
	busy, attempted, cleaned, failed, notice = true, 0, 0, 0, nil
	-- Only this user action installs a job. Its finite attempt budget also stops
	-- failed transactions from causing an endless retry loop.
	Dora.Director.systemScheduler:schedule(function()
		local ok, batch = pcall(function()
			return require("Agent.Storage.Database").cleanupOrphanHeavyDataBatch(math.min(4, budget - attempted))
		end)
		local stop = not ok or not batch.success
		if not stop then
			cleaned = cleaned + batch.cleanedTaskCount
			failed = failed + batch.failedTaskCount
			local count = batch.cleanedTaskCount + batch.failedTaskCount
			attempted = attempted + count
			stop = count == 0 or attempted >= budget
		end
		if stop then
			busy = false
			refresh()
			if not ok or not batch.success then
				notice = zh and "清理未完成，请刷新用量后重试。" or "Cleanup could not finish. Refresh usage and try again."
			else
				local remaining = usage and usage.orphanHeavyData.taskCount
				notice = zh and string.format("已清理 %d 个任务。", cleaned) or string.format("Cleaned %d tasks.", cleaned)
				if failed > 0 or (remaining and remaining > 0) then
					notice = notice .. (zh and "部分数据尚未清理，可重试。" or "Some data remains; you can try again.")
				end
			end
			return true
		end
		return false
	end)
end

return function(zh)
	local open = ImGui.TreeNode(zh and "Agent 存储" or "Agent storage", function()
		if not usage and not readError and not busy then refresh() end
		if usage then
			local db, payload, records, orphan = usage.database, usage.payload, usage.records, usage.orphanHeavyData
			ImGui.Text((zh and "数据库占用：" or "Database: ") .. bytes(db.allocatedBytes))
			ImGui.Text((zh and "可复用空间：" or "Reusable space: ") .. bytes(db.freeBytes))
			ImGui.Text(zh and string.format("聊天记录：%d 条，%s", records.messages, bytes(payload.messageBytes))
				or string.format("Chat: %d messages, %s", records.messages, bytes(payload.messageBytes)))
			ImGui.Text(zh and string.format("检查点：%d 个，%s", records.checkpoints, bytes(payload.checkpointStoredBytes))
				or string.format("Checkpoints: %d, %s", records.checkpoints, bytes(payload.checkpointStoredBytes)))
			ImGui.Text((zh and "检查点原文：" or "Checkpoint originals: ") .. bytes(payload.checkpointRawBytes))
			ImGui.Text(zh and string.format("工具记录：%d 条，%s", records.steps, bytes(payload.stepBytes))
				or string.format("Tool steps: %d, %s", records.steps, bytes(payload.stepBytes)))
			ImGui.Text(zh and string.format("可清理：%d 个旧轮次的数据", orphan.taskCount)
				or string.format("Previous turns with cleanable data: %d", orphan.taskCount))
		end
		if readError then
			ImGui.TextWrapped((zh and "读取用量失败：" or "Cannot read usage: ") .. readError)
		end
		local function buttons()
			if ImGui.Button(zh and "刷新用量" or "Refresh usage") then notice = nil; refresh() end
			ImGui.SameLine()
			local function cleanButton()
				if ImGui.Button(zh and "清理旧轮次数据" or "Clean previous turn data") then startCleanup(zh) end
			end
			if not usage or usage.orphanHeavyData.taskCount == 0 then ImGui.BeginDisabled(cleanButton)
			else cleanButton() end
		end
		if busy then ImGui.BeginDisabled(buttons) else buttons() end
		ImGui.SameLine()
		ImGui.Text("(?)")
		if ImGui.IsItemHovered() then
			ImGui.BeginTooltip(function()
				ImGui.PushTextWrapPos(360, function()
					ImGui.TextWrapped(zh and "仅清理不再被引用的工具记录和回滚快照，保留聊天历史和当前任务的完整回滚能力。"
						or "Only cleans unreferenced tool records and rollback snapshots. Preserves chat history and full rollback capability for the current task.")
					ImGui.TextWrapped(zh and "统计仅包含 Agent 数据库。清理后空间可复用，数据库文件不会立即缩小。"
						or "Usage covers the Agent database. Cleaned space is reusable; the database file does not shrink immediately.")
				end)
			end)
		end
		if busy then
			ImGui.Text(zh and string.format("正在清理，已处理 %d 个任务…", attempted)
				or string.format("Cleaning, %d tasks processed…", attempted))
		elseif notice then ImGui.TextWrapped(notice) end
	end)
	if not open and not busy then usage, readError = nil, nil end
end
