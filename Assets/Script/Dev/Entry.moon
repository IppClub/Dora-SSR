_ENV = Dorothy builtin.ImGui
import "Utils" as {:Set}

print "Dorothy SSR version: #{App.version}#{App.debugging and ', debugging' or ''}"

debug.traceback = (err,level=1)->
	with require("moonp").stp
		.dump_locals = false
		.simplified = true
		msg = .stacktrace err,level+1
		return msg

LoadFontTTF "Font/sarasa-mono-sc-regular.ttf", 20--, "Chinese"

moduleCache = {}
oldRequire = _G.require
newRequire = (path)->
	loaded = package.loaded[path]
	if not loaded
		table.insert moduleCache,path
		return oldRequire path
	loaded
_G.require = newRequire
builtin.require = newRequire

allowedUseOfGlobals = Set {
	'_G'
	'_VERSION'
	'assert'
	'collectgarbage'
	'coroutine'
	'debug'
	'dofile'
	'error'
	'getfenv'
	'getmetatable'
	'ipairs'
	'load'
	'loadfile'
	'loadstring'
	'module'
	'next'
	'package'
	'pairs'
	'pcall'
	'print'
	'rawequal'
	'rawget'
	'rawlen'
	'rawset'
	'require'
	'select'
	'setfenv'
	'setmetatable'
	'string'
	'table'
	'tonumber'
	'tostring'
	'type'
	'unpack'
	'xpcall'
	"nil"
	"true"
	"false"
	'math'

	"Dorothy"
	"builtin"
}

LintMoonGlobals = (moonCodes,globals,file)->
	requireModules = {}
	withImGui = false
	withPlatformer = false
	importCodes = table.concat (
		for importLine in moonCodes\gmatch "Dorothy%s*%(?([^%)!\r\n]*)%s*[%)!]?"
			continue if importLine == ""
			importLine
		), ","
	importItems = if importCodes
		for item in importCodes\gmatch "%s*([^,\n\r]+)%s*"
			getImport = load "return #{item}"
			importItem = getImport?!
			continue if not importItem or "table" ~= type importItem
			{importItem, item}
	else {}
	importSet = {}
	for var in *globals
		{name,line,col} = var
		if not allowedUseOfGlobals[name]
			if builtin[name]
				table.insert requireModules, "local #{name} = require(\"#{name}\") -- 1"
			else
				findModule = false
				for i,importItem in ipairs importItems
					if importItem[1][name]?
						moduleName = "_module_#{i-1}"
						if not importSet[importItem[1]]
							importSet[importItem[1]] = true
							table.insert requireModules, "local #{moduleName} = #{importItem[2]} -- 1"
						table.insert requireModules, "local #{name} = #{moduleName}.#{name} -- 1"
						findModule = true
						break
				if not findModule
					countLine = 1
					code = nil
					for lineCode in moonCodes\gmatch "[^\n]*\n"
						if countLine == line
							code = lineCode
							break
						countLine += 1
					print "Used invalid global value \"#{name}\"\nin \"#{file}\", at line #{line}, col #{col}.\n#{code\gsub("\t"," ")..string.rep(" ",col-1).."^"}"
	table.concat requireModules, "\n"

building = false

getAllFiles = (path,exts)->
	filters = Set exts
	return for file in *Content\getAllFiles path
		continue if not filters[Path\getExt file]
		file

doCompile = (minify)->
	return if building
	building = true
	inputPath = Path Content.assetPath,"Script"
	outputPath = Path Content.writablePath,"Script"
	moonFiles = getAllFiles inputPath,{"moon"}
	xmlFiles = getAllFiles inputPath,{"xml"}
	paths = {Path\getPath(file),true for file in *moonFiles}
	Content\mkdir Path outputPath,path for path in pairs paths
	totalFiles = #moonFiles+#xmlFiles
	fileCount = 0
	errors = {}
	for file in *moonFiles
		dest = Path\replaceExt Path(outputPath,file),"lua"
		<- mooncompile file,dest,(codes,err,globals)->
			if not codes
				table.insert errors,"Compile errors in #{file}.\n#{err}"
				fileCount += 1
				return
			requires = LintMoonGlobals(codes,globals,file)
			requires ..= "\n" unless requires == ""
			"-- [moon]: #{file}\n"..requires..codes\gsub "local%s*_ENV%s*=%s*Dorothy%([^%)]*%)[^\r\n]*[\r\n]*",""
		print "Moon compiled: #{file}"
		fileCount += 1
	paths = {Path\getPath(file),true for file in *xmlFiles}
	Content\mkdir Path outputPath,path for path in pairs paths
	thread ->
		for file in *xmlFiles
			dest = Path\replaceExt Path(outputPath,file),"lua"
			sourceCodes = Content\loadAsync file
			codes,err = xmltolua sourceCodes
			if not codes
				table.insert errors,"Compile errors in #{file}.\n#{err}"
			else
				Content\saveAsync dest,codes
				print "Xml compiled: #{file}"
			fileCount += 1
	thread ->
		wait -> fileCount == totalFiles
		if minify
			inputPath = Path Content.assetPath,"Script"
			outputPath = Path Content.writablePath,"Script"
			luaFiles = getAllFiles inputPath,{"lua"}
			for file in *getAllFiles outputPath,{"lua"}
				table.insert luaFiles,file
			paths = {Path\getPath(file),true for file in *luaFiles}
			Content\mkdir Path outputPath,path for path in pairs paths
			import "luaminify.FormatMini"
			for file in *luaFiles
				sourceCodes = Content\loadAsync file
				res,err = FormatMini sourceCodes
				if res
					Content\saveAsync Path(outputPath,file),res
					print "Minify: #{file}"
				else
					table.insert errors,"Minify errors in #{file}.\n#{err}"
		print err for err in *errors
		print "Build complete!"
		building = false

doClean = ->
	return if building
	targetDir = Path Content.writablePath,"Script"
	if Content\remove targetDir
		print "Cleaned: #{targetDir}"
	else
		print "Nothing to clean."

isInEntry = true
currentEntryName = nil

allClear = ->
	for module in *moduleCache
		package.loaded[module] = nil
	moduleCache = {}
	with Director.ui
		\removeAllChildren!
		.userData = nil
	with Director.entry
		\removeAllChildren!
		.userData = nil
	with Director.postNode
		\removeAllChildren!
		.userData = nil
	Director\popCamera!
	Cache\unload!
	Entity\clear!
	Platformer.Data\clear!
	Platformer.UnitAction\clear!
	currentEntryName = nil
	isInEntry = true
	Audio\stopStream 0.2
	collectgarbage!

games = [Path\getName item for item in *Content\getDirs Path Content.assetPath,"Script","Game"]
table.sort games
examples = [Path\getName item for item in *getAllFiles Path(Content.assetPath,"Script","Example"), {"xml","lua","moon"}]
table.sort examples
tests = [Path\getName item for item in *getAllFiles Path(Content.assetPath,"Script","Test"), {"xml","lua","moon"}]
table.sort tests
allNames = [Path "Game",game,"init" for game in *games]
for example in *examples do table.insert allNames,Path "Example",example
for test in *tests do table.insert allNames,Path "Test",test

enterDemoEntry = (name)->
	isInEntry = false
	xpcall (->
		result = require name
		if "function" == type result
			result = result!
			Director.entry\addChild if tolua.cast result,"Node"
				result
			else
				Node!
		else
			Director.entry\addChild Node!
		currentEntryName = name
	),(msg)->
		print debug.traceback msg
		allClear!

showEntry = false

thread ->
	:width,:height = App.visualSize
	scale = App.deviceRatio*0.7*math.min(width,height)/760
	if false
		with Sprite GetDorothySSRHappyWhite scale
			\addTo Director.entry
			sleep 1.0
			\removeFromParent!
	showEntry = true
	Director.clearColor = Color 0xff1a1a1a

showStats = false
showLog = true
showFooter = true
scaleContent = false
footerFocus = false
screenScale = 2 -- App.deviceRatio
threadLoop ->
	return unless showEntry
	left = Keyboard\isKeyDown "Left"
	right = Keyboard\isKeyDown "Right"
	App\shutdown! if Keyboard\isKeyDown "Escape"
	:width,:height = App.visualSize
	SetNextWindowSize Vec2(190,50)
	SetNextWindowPos Vec2(width-190,height-50)
	if width >= 600
		if not footerFocus
			footerFocus = true
			SetNextWindowFocus!
		return true if PushStyleColor "WindowBg", Color(0x0), ->
			Begin "Show", "NoTitleBar|NoResize|NoMove|NoCollapse|NoSavedSettings", ->
				Columns 2,false
				if showFooter
					changed, scaleContent = Checkbox string.format("%.1fx",screenScale), scaleContent
					View.scale = scaleContent and screenScale or 1 if changed
				else
					Dummy Vec2 10,30
				SameLine!
				NextColumn!
				_, showFooter = Checkbox "Footer", showFooter
	elseif footerFocus
		footerFocus = false
	return unless showFooter
	SetNextWindowSize Vec2(width,60)
	SetNextWindowPos Vec2(0,height-60)
	return true if Begin "Footer", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings", ->
		Separator!
		_, showStats = Checkbox "Stats", showStats
		SameLine!
		_, showLog = Checkbox "Log", showLog
		SameLine!
		if isInEntry
			OpenPopup "build" if Button "Build", Vec2(70,30)
			return true if BeginPopup "build", ->
				doCompile false if Selectable "Compile"
				Separator!
				doCompile true if Selectable "Minify"
				Separator!
				doClean! if Selectable "Clean"
		else
			SameLine!
			allClear! if Button "Home", Vec2(70,30)
			currentIndex = 1
			for i,name in ipairs allNames
				if currentEntryName == name
					currentIndex = i
			SameLine!
			if currentIndex > 1
				if Button("Prev", Vec2(70,30)) or left
					allClear!
					isInEntry = false
					thread -> enterDemoEntry allNames[currentIndex-1]
			else Dummy Vec2 70,30
			SameLine!
			if currentIndex < #allNames
				if Button("Next", Vec2(70,30)) or right
					allClear!
					isInEntry = false
					thread -> enterDemoEntry allNames[currentIndex+1]
			else Dummy Vec2 70,30
		if showStats
			SetNextWindowPos Vec2(0,height-65-296), "FirstUseEver"
			ShowStats!
		if showLog
			SetNextWindowPos Vec2(width-400,height-65-300), "FirstUseEver"
			ShowLog!

threadLoop ->
	return unless showEntry
	return unless isInEntry
	:width,:height = App.visualSize
	SetNextWindowPos Vec2.zero
	SetNextWindowSize Vec2(width,53)
	return true if PushStyleColor "TitleBgActive", Color(0xcc000000), ->
		Begin "Dorothy Dev", "NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings", ->
			Separator!
	SetNextWindowPos Vec2(0,53)
	SetNextWindowSize Vec2(width,height-107)
	return true if PushStyleColor "WindowBg",Color(0x0), ->
		Begin "Content", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings", ->
			TextColored Color(0xff00ffff), "Game Demos"
			Columns math.max(math.floor(width/200),1), false
			for game in *games
				if Button game, Vec2(-1,40)
					enterDemoEntry Path "Game",game,"init"
				NextColumn!
			Columns 1, false
			TextColored Color(0xff00ffff), "Examples"
			Columns math.max(math.floor(width/200),1), false
			for example in *examples
				if Button example, Vec2(-1,40)
					enterDemoEntry Path "Example",example
				NextColumn!
			Columns 1, false
			TextColored Color(0xff00ffff), "Tests"
			Columns math.max(math.floor(width/200),1), false
			for test in *tests
				if Button test, Vec2(-1,40)
					enterDemoEntry Path "Test",test
				NextColumn!
