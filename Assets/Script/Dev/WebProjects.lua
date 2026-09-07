local Dora = Dora
local App = Dora.App
local Content = Dora.Content
local Path = Dora.Path
local ImGui = Dora.ImGui

local projectRoot = "/idbfs/dora/projects"
local packageRoot = "/idbfs/dora/packages"
local projects
local pickerBusy = false
local pickerMessage

local function scanProjects()
	local result = {}
	if not Content:exist(projectRoot) or not Content:isdir(projectRoot) then
		return result
	end
	for _, name in ipairs(Content:getDirs(projectRoot)) do
		local root = Path(projectRoot, name)
		local entry
		for _, extension in ipairs({"lua", "yue", "tl", "wasm"}) do
			local candidate = Path(root, "init." .. extension)
			if Content:exist(candidate) then
				entry = candidate
				break
			end
		end
		if entry then
			result[#result + 1] = {
				id = name,
				name = name,
				root = root,
				entry = entry
			}
		end
	end
	if Content:exist(packageRoot) then
		for _, name in ipairs(Content:getFiles(packageRoot)) do
			if name:lower():match("%.dora$") then
				local id = name:sub(1, -6)
				result[#result + 1] = {
					id = id,
					name = id,
					package = Path(packageRoot, name),
					kind = "package"
				}
			end
		end
	end
	table.sort(result, function(a, b) return a.name:lower() < b.name:lower() end)
	return result
end

local function refresh()
	projects = scanProjects()
end

local function findProject(path)
	for _, item in ipairs(projects or {}) do
		if item.root == path or item.package == path then
			return item
		end
	end
	if type(path) == "string" and Path:getExt(path) == "dora" then
		local id = Path:getName(Path:replaceExt(path, ""))
		return {
			id = id,
			name = id,
			package = path,
			kind = "package"
		}
	end
	return nil
end

local function runProject(project)
	local ok, runner = pcall(require, "Script.Dev.WebRunner")
	if not ok then
		pickerMessage = tostring(runner)
		return false
	end
	local run = project.kind == "package" and runner.runPackage or runner.runProject
	local started, result = pcall(run, project.kind == "package" and project.package or project.root, project.id)
	if not started or result ~= true then
		pickerMessage = started and ("Failed to start " .. project.name) or tostring(result)
		return false
	end
	pickerMessage = nil
	return true
end

local M = {}

function M.openProject(folderOnly)
	if pickerBusy then return end
	pickerBusy = true
	pickerMessage = nil
	App:openFileDialog(folderOnly, function(path)
		pickerBusy = false
		if path == nil or path == "" then return end
		refresh()
		local project = findProject(path)
		if project then
			if project.kind == "package" and not findProject(project.package) then
				projects[#projects + 1] = project
				table.sort(projects, function(a, b) return a.name:lower() < b.name:lower() end)
			end
			runProject(project)
		else
			pickerMessage = "Imported project was not found: " .. path
		end
	end)
end

function M.refresh()
	refresh()
end

function M.draw(zh, themeColor)
	if App.platform ~= "Emscripten" then return end
	if not projects then refresh() end
	ImGui.Columns(1, false)
	ImGui.TextColored(themeColor, zh and "Web 项目" or "Web Projects")
	ImGui.SameLine()
	if ImGui.Button(zh and "添加目录" or "Add Folder", Dora.Vec2(120, 30)) then
		M.openProject(true)
	end
	ImGui.SameLine()
	if ImGui.Button(zh and "导入 .dora" or "Import .dora", Dora.Vec2(120, 30)) then
		M.openProject(false)
	end
	ImGui.SameLine()
	if ImGui.Button(zh and "刷新" or "Refresh", Dora.Vec2(70, 30)) then
		refresh()
	end
	if pickerBusy then
		ImGui.SameLine()
		ImGui.Text(zh and "正在选择项目…" or "Selecting project…")
	end
	if pickerMessage then
		ImGui.TextColored(Dora.Color(0xffff7777), pickerMessage)
	end
	ImGui.Separator()
	if #projects == 0 then
		ImGui.TextWrapped(zh and "还没有 Web 项目。可以添加项目目录，或直接导入 .dora 文件。" or "No Web projects yet. Add a project folder or import a .dora file.")
	else
		for _, project in ipairs(projects) do
			if ImGui.Button((zh and "运行 " or "Run ") .. project.name .. "##web-project-" .. project.id, Dora.Vec2(-1, 40)) then
				runProject(project)
			end
		end
	end
	ImGui.Separator()
end

return M
