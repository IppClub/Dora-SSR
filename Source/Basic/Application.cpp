/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Application.h"

#include "Basic/AutoreleasePool.h"
#include "Basic/Content.h"
#include "Basic/Database.h"
#include "Basic/Director.h"
#include "Common/Async.h"
#include "Event/Event.h"
#include "GUI/ImGuiDora.h"
#include "Http/XrtHttpClient.h"
#include "Input/Controller.h"
#include "Lua/ToLua/tolua++.h"

#include "Other/utf8.h"

#include "SDL.h"
#include "SDL_syswm.h"
#include "bx/timer.h"

#include <chrono>
#include <cstring>
#include <cstdlib>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <thread>

#define DORA_VERSION "1.8.1"_slice
#define DORA_REVISION "11"_slice

#if BX_PLATFORM_ANDROID
#include <jni.h>
static std::string g_androidAPKPath;
extern "C" {
JNIEXPORT void JNICALL Java_org_ippclub_dorassr_MainActivity_nativeSetPath(JNIEnv* env, jclass cls, jstring apkPath) {
	const char* pathString = env->GetStringUTFChars(apkPath, NULL);
	g_androidAPKPath = pathString;
	env->ReleaseStringUTFChars(apkPath, pathString);
}
}
static float g_androidScreenDensity;
extern "C" {
JNIEXPORT void JNICALL Java_org_ippclub_dorassr_MainActivity_nativeSetScreenDensity(JNIEnv* env, jclass cls, jfloat screenDensity) {
	g_androidScreenDensity = s_cast<float>(screenDensity);
}
}
static std::string g_androidInstallFile;
extern "C" {
JNIEXPORT jstring JNICALL Java_org_ippclub_dorassr_MainActivity_nativeGetInstallFile(JNIEnv* env, jclass cls) {
	jstring jstr = env->NewStringUTF(g_androidInstallFile.c_str());
	g_androidInstallFile.clear();
	return jstr;
}
}
extern "C" ANativeWindow* Android_JNI_GetNativeWindow();
extern "C" int Android_JNI_SendMessage(int command, int param);
extern "C" JNIEnv* Android_JNI_GetEnv();
#endif // BX_PLATFORM_ANDROID

#if BX_PLATFORM_WINDOWS
#define DEFAULT_WIN_DPI 96
#include <shellapi.h>
#endif // BX_PLATFORM_WINDOWS

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX
#include "nfd/nfd.hpp"
#include "nfd/nfd_sdl2.h"
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX

NS_DORA_BEGIN

namespace {

namespace fs = std::filesystem;

#define DORA_CLI_SUPPORTED (BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX)

bool isCliRequested(int argc, char* argv[]) {
	for (int i = 1; i < argc; i++) {
		if (!argv[i]) continue;
		std::string_view arg(argv[i]);
		if (arg == "cli") {
			return true;
		}
		if (arg == "--asset") {
			if (i + 1 < argc) i++;
			continue;
		}
		if (arg.rfind("--asset=", 0) == 0) {
			continue;
		}
		break;
	}
	return false;
}

#if DORA_CLI_SUPPORTED

extern "C" {
int luaopen_yue(lua_State* L);
int luaopen_colibc_json(lua_State* L);
} // extern "C"

struct CliLuaState {
	lua_State* L = nullptr;
	~CliLuaState() {
		if (L) lua_close(L);
	}
};

std::string cliGetString(lua_State* L, int index) {
	size_t len = 0;
	auto str = luaL_checklstring(L, index, &len);
	return {str, len};
}

fs::path cliAbsolutePath(const fs::path& path, const fs::path& base = fs::current_path()) {
	return fs::absolute(path.is_relative() ? base / path : path).lexically_normal();
}

int cliCommandIndex(int argc, char* argv[]) {
	for (int i = 1; i < argc; i++) {
		if (!argv[i]) continue;
		std::string_view arg(argv[i]);
		if (arg == "cli") {
			return i;
		}
		if (arg == "--asset") {
			if (i + 1 < argc) i++;
			continue;
		}
		if (arg.rfind("--asset=", 0) == 0) {
			continue;
		}
		break;
	}
	return -1;
}

struct CliAssetArgument {
	std::optional<fs::path> path;
	std::string error;
};

CliAssetArgument cliFindAssetArgument(int argc, char* argv[]) {
	constexpr std::string_view assetPrefix = "--asset=";
	for (int i = 1; i < argc; i++) {
		if (!argv[i]) continue;
		std::string_view arg(argv[i]);
		if (arg == "--asset") {
			if (i + 1 >= argc || !argv[i + 1] || !*argv[i + 1]) {
				return {std::nullopt, "--asset expects a value"};
			}
			return {cliAbsolutePath(argv[i + 1]), {}};
		}
		if (arg.rfind(assetPrefix, 0) == 0) {
			auto value = arg.substr(assetPrefix.size());
			if (value.empty()) {
				return {std::nullopt, "--asset expects a value"};
			}
			return {cliAbsolutePath(std::string(value)), {}};
		}
	}
	return {};
}

bool cliIsAssetArgument(int argc, char* argv[], int& index) {
	if (!argv[index]) return false;
	std::string_view arg(argv[index]);
	if (arg == "--asset") {
		if (index + 1 < argc) index++;
		return true;
	}
	return arg.rfind("--asset=", 0) == 0;
}

void cliPushFileError(lua_State* L, const std::string& message) {
	lua_pushnil(L);
	lua_pushlstring(L, message.c_str(), message.size());
}

int cliLuaCwd(lua_State* L) {
	auto path = fs::current_path().string();
	lua_pushlstring(L, path.c_str(), path.size());
	return 1;
}

int cliLuaEnv(lua_State* L) {
	auto name = cliGetString(L, 1);
	if (auto value = std::getenv(name.c_str())) {
		lua_pushstring(L, value);
	} else if (lua_gettop(L) >= 2) {
		lua_pushvalue(L, 2);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

int cliLuaAbsolute(lua_State* L) {
	auto path = fs::path(cliGetString(L, 1));
	auto base = lua_gettop(L) >= 2 && !lua_isnil(L, 2) ? fs::path(cliGetString(L, 2)) : fs::current_path();
	auto result = cliAbsolutePath(path, base).string();
	lua_pushlstring(L, result.c_str(), result.size());
	return 1;
}

int cliLuaExists(lua_State* L) {
	std::error_code err;
	lua_pushboolean(L, fs::exists(cliGetString(L, 1), err));
	return 1;
}

int cliLuaIsDir(lua_State* L) {
	std::error_code err;
	lua_pushboolean(L, fs::is_directory(cliGetString(L, 1), err));
	return 1;
}

int cliLuaIsFile(lua_State* L) {
	std::error_code err;
	lua_pushboolean(L, fs::is_regular_file(cliGetString(L, 1), err));
	return 1;
}

int cliLuaMkdirs(lua_State* L) {
	std::error_code err;
	fs::create_directories(cliGetString(L, 1), err);
	lua_pushboolean(L, !err);
	if (err) lua_pushstring(L, err.message().c_str());
	return err ? 2 : 1;
}

int cliLuaReadFile(lua_State* L) {
	auto path = cliGetString(L, 1);
	std::ifstream in(path, std::ios::binary);
	if (!in) {
		cliPushFileError(L, "failed to read file: " + path);
		return 2;
	}
	std::string content((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());
	lua_pushlstring(L, content.data(), content.size());
	return 1;
}

int cliLuaWriteFile(lua_State* L) {
	auto path = fs::path(cliGetString(L, 1));
	size_t len = 0;
	auto data = luaL_checklstring(L, 2, &len);
	if (auto parent = path.parent_path(); !parent.empty()) {
		std::error_code err;
		fs::create_directories(parent, err);
		if (err) {
			lua_pushboolean(L, false);
			lua_pushstring(L, err.message().c_str());
			return 2;
		}
	}
	std::ofstream out(path, std::ios::binary);
	if (!out) {
		lua_pushboolean(L, false);
		lua_pushstring(L, ("failed to write file: " + path.string()).c_str());
		return 2;
	}
	out.write(data, s_cast<std::streamsize>(len));
	lua_pushboolean(L, true);
	return 1;
}

int cliLuaListDir(lua_State* L) {
	auto path = cliGetString(L, 1);
	std::error_code err;
	if (!fs::is_directory(path, err)) {
		lua_newtable(L);
		return 1;
	}
	lua_newtable(L);
	int i = 1;
	for (const auto& entry : fs::directory_iterator(path, err)) {
		if (err) break;
		lua_newtable(L);
		auto name = entry.path().filename().string();
		auto fullPath = entry.path().string();
		lua_pushlstring(L, name.c_str(), name.size());
		lua_setfield(L, -2, "name");
		lua_pushlstring(L, fullPath.c_str(), fullPath.size());
		lua_setfield(L, -2, "path");
		lua_pushboolean(L, entry.is_directory());
		lua_setfield(L, -2, "isDir");
		lua_pushboolean(L, entry.is_regular_file());
		lua_setfield(L, -2, "isFile");
		lua_rawseti(L, -2, i++);
	}
	return 1;
}

int cliLuaMTime(lua_State* L) {
	std::error_code err;
	auto time = fs::last_write_time(cliGetString(L, 1), err);
	lua_pushnumber(L, err ? 0.0 : s_cast<lua_Number>(time.time_since_epoch().count()));
	return 1;
}

int cliLuaSystem(lua_State* L) {
	auto command = cliGetString(L, 1);
	fs::path cwd;
	bool hasCwd = lua_gettop(L) >= 2 && !lua_isnil(L, 2);
	if (hasCwd) cwd = cliGetString(L, 2);
	auto oldPath = fs::current_path();
	if (hasCwd) fs::current_path(cwd);
	int result = std::system(command.c_str());
	if (hasCwd) fs::current_path(oldPath);
	lua_pushinteger(L, result);
	return 1;
}

int cliLuaHttp(lua_State* L) {
	auto method = cliGetString(L, 1);
	auto url = cliGetString(L, 2);
	std::vector<std::string> names;
	std::vector<std::string> values;
	if (lua_istable(L, 3)) {
		lua_pushnil(L);
		while (lua_next(L, 3) != 0) {
			size_t keyLen = 0;
			size_t valueLen = 0;
			auto key = luaL_tolstring(L, -2, &keyLen);
			auto value = luaL_tolstring(L, -2, &valueLen);
			names.emplace_back(key, keyLen);
			values.emplace_back(value, valueLen);
			lua_pop(L, 3);
		}
	}
	size_t bodyLen = 0;
	auto body = lua_gettop(L) >= 4 && !lua_isnil(L, 4) ? luaL_checklstring(L, 4, &bodyLen) : nullptr;
	auto timeout = lua_gettop(L) >= 5 && !lua_isnil(L, 5) ? luaL_checknumber(L, 5) : 10.0;
	std::vector<const char*> headerNames;
	std::vector<const char*> headerValues;
	headerNames.reserve(names.size());
	headerValues.reserve(values.size());
	for (const auto& name : names) headerNames.push_back(name.c_str());
	for (const auto& value : values) headerValues.push_back(value.c_str());
	std::string responseBody;
	int statusCode = 0;
	auto status = DoraXrtHttpExecuteStream(
		method.c_str(),
		url.c_str(),
		headerNames.data(),
		headerValues.data(),
		headerNames.size(),
		body,
		bodyLen,
		s_cast<unsigned int>(timeout * 1000.0),
		0,
		nullptr,
		nullptr,
		[](const char* data, size_t dataLen, size_t, size_t, void* userData) {
			auto body = s_cast<std::string*>(userData);
			body->append(data, dataLen);
			return 0;
		},
		&responseBody,
		&statusCode);
	lua_newtable(L);
	lua_pushinteger(L, status);
	lua_setfield(L, -2, "netStatus");
	lua_pushstring(L, DoraXrtHttpStatusName(status));
	lua_setfield(L, -2, "netStatusName");
	lua_pushinteger(L, statusCode);
	lua_setfield(L, -2, "statusCode");
	lua_pushlstring(L, responseBody.data(), responseBody.size());
	lua_setfield(L, -2, "body");
	return 1;
}

void cliSetFunc(lua_State* L, const char* name, lua_CFunction func) {
	lua_pushcfunction(L, func);
	lua_setfield(L, -2, name);
}

void cliRegisterLua(lua_State* L, int argc, char* argv[], const fs::path& scriptPath, int cliIndex, const std::optional<fs::path>& assetPath) {
	luaL_openlibs(L);
	luaL_requiref(L, "json", luaopen_colibc_json, 1);
	lua_pop(L, 1);
	luaL_requiref(L, "yue", luaopen_yue, 1);
	lua_pop(L, 1);
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "path");
	auto packagePath = cliGetString(L, -1);
	lua_pop(L, 1);
	auto scriptDir = scriptPath.parent_path().string();
	auto assetsScriptDir = scriptPath.parent_path().parent_path().string();
	packagePath = scriptDir + "/?.lua;" + assetsScriptDir + "/?.lua;" + assetsScriptDir + "/?/init.lua;" + packagePath;
	lua_pushlstring(L, packagePath.c_str(), packagePath.size());
	lua_setfield(L, -2, "path");
	lua_pop(L, 1);

	if (assetPath) {
		auto path = assetPath->string();
		lua_newtable(L); // Content
		lua_pushlstring(L, path.c_str(), path.size());
		lua_setfield(L, -2, "assetPath");
		lua_setglobal(L, "Content");
	}

	lua_newtable(L); // Dora
	lua_newtable(L); // Dora.CLI
	lua_newtable(L); // args
	int argIndex = 1;
	for (int i = cliIndex + 1; i < argc; i++) {
		if (cliIsAssetArgument(argc, argv, i)) continue;
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, argIndex++);
	}
	lua_setfield(L, -2, "args");
	auto executablePath = cliAbsolutePath(argv[0]).string();
	lua_pushlstring(L, executablePath.c_str(), executablePath.size());
	lua_setfield(L, -2, "executablePath");
	auto path = scriptPath.string();
	lua_pushlstring(L, path.c_str(), path.size());
	lua_setfield(L, -2, "scriptPath");
	cliSetFunc(L, "cwd", cliLuaCwd);
	cliSetFunc(L, "env", cliLuaEnv);
	cliSetFunc(L, "absolute", cliLuaAbsolute);
	cliSetFunc(L, "exists", cliLuaExists);
	cliSetFunc(L, "isDir", cliLuaIsDir);
	cliSetFunc(L, "isFile", cliLuaIsFile);
	cliSetFunc(L, "mkdirs", cliLuaMkdirs);
	cliSetFunc(L, "readFile", cliLuaReadFile);
	cliSetFunc(L, "writeFile", cliLuaWriteFile);
	cliSetFunc(L, "listDir", cliLuaListDir);
	cliSetFunc(L, "mtime", cliLuaMTime);
	cliSetFunc(L, "system", cliLuaSystem);
	cliSetFunc(L, "http", cliLuaHttp);
	lua_setfield(L, -2, "CLI");
	lua_setglobal(L, "Dora");
}

bool cliSkipEntrySearchDir(const fs::path& path) {
	static const std::unordered_set<std::string> ignoredDirs = {
		".git", ".svn", ".hg", "build", "dist", "node_modules", "target",
	};
	return ignoredDirs.contains(path.filename().string());
}

std::optional<fs::path> cliFindScriptInRoot(const fs::path& root) {
	std::error_code err;
	auto base = fs::weakly_canonical(root, err);
	if (err) base = root;
	if (!fs::is_directory(base, err)) return std::nullopt;
	for (const auto& candidate : {base / "Script" / "Dev" / "cli.lua", base / "cli.lua"}) {
		if (fs::is_regular_file(candidate, err)) {
			return fs::weakly_canonical(candidate, err);
		}
		err.clear();
	}
	for (auto it = fs::recursive_directory_iterator(base, fs::directory_options::skip_permission_denied, err); it != fs::recursive_directory_iterator(); it.increment(err)) {
		if (err) {
			err.clear();
			continue;
		}
		const auto& entry = *it;
		if (entry.is_directory(err)) {
			if (cliSkipEntrySearchDir(entry.path())) {
				it.disable_recursion_pending();
			}
			continue;
		}
		if (entry.is_regular_file(err) && entry.path().filename() == "cli.lua") {
			return fs::weakly_canonical(entry.path(), err);
		}
	}
	return std::nullopt;
}

std::optional<fs::path> cliFindScript(int argc, char* argv[], const std::optional<fs::path>& assetPath) {
	if (auto script = std::getenv("DORA_CLI_SCRIPT")) {
		if (*script) return cliAbsolutePath(script);
	}
	std::vector<fs::path> candidates;
	if (assetPath) {
		candidates.push_back(*assetPath);
	}
	candidates.insert(candidates.end(), {
		fs::current_path() / "Assets",
		fs::current_path(),
	});
	if (argc > 0 && argv[0] && *argv[0]) {
		auto exe = cliAbsolutePath(argv[0]);
		auto exeDir = exe.parent_path();
		candidates.push_back(exeDir / "../Resources");
		candidates.push_back(exeDir / "..");
	}
	for (const auto& candidate : candidates) {
		if (auto script = cliFindScriptInRoot(candidate)) {
			return script;
		}
	}
	return std::nullopt;
}

int runCliApplication(int argc, char* argv[]) {
	auto cliIndex = cliCommandIndex(argc, argv);
	if (cliIndex < 0) {
		std::cerr << "Dora CLI command not found.\n";
		return 1;
	}
	auto asset = cliFindAssetArgument(argc, argv);
	if (!asset.error.empty()) {
		std::cerr << asset.error << "\n";
		return 1;
	}
	auto scriptPath = cliFindScript(argc, argv, asset.path);
	if (!scriptPath) {
		std::cerr << "Dora CLI script cli.lua not found. Set DORA_CLI_SCRIPT or run from a Dora asset root.\n";
		return 1;
	}
	CliLuaState state{luaL_newstate()};
	if (!state.L) {
		std::cerr << "Failed to create Lua state for Dora CLI.\n";
		return 1;
	}
	cliRegisterLua(state.L, argc, argv, *scriptPath, cliIndex, asset.path);
	auto path = scriptPath->string();
	if (luaL_loadfile(state.L, path.c_str()) != LUA_OK) {
		std::cerr << lua_tostring(state.L, -1) << "\n";
		return 1;
	}
	if (lua_pcall(state.L, 0, 1, 0) != LUA_OK) {
		std::cerr << lua_tostring(state.L, -1) << "\n";
		return 1;
	}
	int exitCode = 0;
	if (lua_isinteger(state.L, -1)) {
		exitCode = s_cast<int>(lua_tointeger(state.L, -1));
	} else if (lua_isboolean(state.L, -1)) {
		exitCode = lua_toboolean(state.L, -1) ? 0 : 1;
	}
	return exitCode;
}

#else // DORA_CLI_SUPPORTED

int runCliApplication(int, char*[]) {
	std::cerr << "Dora CLI mode is only supported on Windows, macOS, and Linux.\n";
	return 1;
}

#endif // DORA_CLI_SUPPORTED

#undef DORA_CLI_SUPPORTED

} // namespace

bool BGFXDora::init(const bgfx::PlatformData& data) {
	bgfx::Init init{};
#if BX_PLATFORM_LINUX
	if (data.context) {
		init.type = bgfx::RendererType::OpenGLES;
	}
#endif // BX_PLATFORM_LINUX
	bx::memCopy(&init.platformData, &data, sizeof(bgfx::PlatformData));
	return bgfx::init(init);
}

BGFXDora::~BGFXDora() {
	bgfx::shutdown();
}

Application::Application()
	: _seed(0)
	, _idled(false)
	, _fpsLimited(true)
	, _renderRunning(true)
	, _logicRunning(true)
	, _fullScreen(false)
	, _alwaysOnTop(false)
	, _devMode(false)
	, _frame(0)
	, _visualWidth(1280)
	, _visualHeight(720)
	, _winWidth(_visualWidth)
	, _winHeight(_visualHeight)
	, _bufferWidth(0)
	, _bufferHeight(0)
	, _targetFPS(60)
	, _maxFPS(60)
	, _deltaTime(0)
	, _cpuTime(0)
	, _totalTime(0)
	, _frequency(double(bx::getHPFrequency()))
	, _sdlWindow(nullptr)
	, _sdlGLContext(nullptr)
	, _themeColor(0xfffac03d)
	, _winPosition{-1.0f, -1.0f}
	, _platformData{} {
	_lastTime = bx::getHPCounter() / _frequency;
#if !BX_PLATFORM_LINUX
	auto locale = SDL_GetPreferredLocales();
	_locale = locale->language;
	SDL_free(locale);
#else
	_locale = "en"s;
#endif
}

const std::string& Application::getLocale() const noexcept {
	return _locale;
}

void Application::setLocale(String var) {
	_locale = var.toString();
	Event::send("AppChange"_slice, "Locale"s);
}

Size Application::getBufferSize() const noexcept {
	return Size{s_cast<float>(_bufferWidth), s_cast<float>(_bufferHeight)};
}

Size Application::getVisualSize() const noexcept {
	return Size{s_cast<float>(_visualWidth), s_cast<float>(_visualHeight)};
}

float Application::getDevicePixelRatio() const noexcept {
	return s_cast<float>(_bufferWidth) / _visualWidth;
}

void Application::setThemeColor(Color var) {
	_themeColor = var;
	Event::send("AppChange"_slice, "Theme"s);
}

Color Application::getThemeColor() const noexcept {
	return _themeColor;
}

void Application::setSeed(uint32_t var) {
	_seed = var;
	_randomEngine.seed(var);
}

uint32_t Application::getSeed() const noexcept {
	return _seed;
}

uint32_t Application::getRand() {
	return _randomEngine();
}

uint32_t Application::getRandMin() const noexcept {
	return std::mt19937::min();
}

uint32_t Application::getRandMax() const noexcept {
	return std::mt19937::max();
}

void Application::setTargetFPS(uint32_t var) {
	_targetFPS = var;
}

uint32_t Application::getTargetFPS() const noexcept {
	return _targetFPS;
}

uint32_t Application::getMaxFPS() const noexcept {
	return _maxFPS;
}

void Application::setIdled(bool var) {
	_idled = var;
}

bool Application::isIdled() const noexcept {
	return _idled;
}

void Application::setFPSLimited(bool var) {
	_fpsLimited = var;
}

bool Application::isFPSLimited() const noexcept {
	return _fpsLimited;
}

void Application::setWinSize(Size var) {
	if (getPlatform() == "iOS"_slice || getPlatform() == "Android"_slice) {
		Error("changing window size is not available on {}.", getPlatform().toString());
		return;
	}
	AssertIf(var.width <= 0 || var.height <= 0,
		"window size should be larger than zero.");
	invokeInRender([&, var]() {
		SDL_SetWindowFullscreen(_sdlWindow, 0);
		SDL_SetWindowSize(_sdlWindow, s_cast<int>(var.width), s_cast<int>(var.height));
		SDL_SetWindowPosition(_sdlWindow, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
	});
	_fullScreen = false;
	Event::send("AppChange"_slice, "FullScreen"s);
}

Size Application::getWinSize() const noexcept {
	return Size{s_cast<float>(_winWidth), s_cast<float>(_winHeight)};
}

void Application::setWinPosition(const Vec2& var) {
	if (getPlatform() == "iOS"_slice || getPlatform() == "Android"_slice) {
		Error("changing window position is not available on {}.", getPlatform().toString());
		return;
	}
	if (_winPosition == var) {
		return;
	}
	_winPosition = var;
	invokeInRender([&, var]() {
		SDL_SetWindowFullscreen(_sdlWindow, 0);
		int posX = s_cast<int>(var.x);
		int posY = s_cast<int>(var.y);
		if (posX < 0) posX = SDL_WINDOWPOS_CENTERED;
		if (posY < 0) posY = SDL_WINDOWPOS_CENTERED;
		SDL_SetWindowPosition(_sdlWindow, posX, posY);
	});
	Event::send("AppChange"_slice, "Position"s);
}

const Vec2& Application::getWinPosition() const noexcept {
	return _winPosition;
}

uint32_t Application::getFrame() const noexcept {
	return _frame;
}

SDL_Window* Application::getSDLWindow() const noexcept {
	return _sdlWindow;
}

bool Application::isRenderRunning() const noexcept {
	return _renderRunning;
}

bool Application::isLogicRunning() const noexcept {
	return _logicRunning;
}

void Application::setFullScreen(bool var) {
	if (getPlatform() == "iOS"_slice || getPlatform() == "Android"_slice) {
		Error("changing window full screen mode is not available on {}.", getPlatform().toString());
		return;
	}
	if (_fullScreen == var) {
		return;
	}
	_fullScreen = var;
	invokeInRender([&, var]() {
		SDL_SetWindowFullscreen(_sdlWindow, var ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
	});
	Event::send("AppChange"_slice, "FullScreen"s);
}

bool Application::isFullScreen() const noexcept {
	return _fullScreen;
}

void Application::setAlwaysOnTop(bool var) {
	if (getPlatform() == "iOS"_slice || getPlatform() == "Android"_slice) {
		Error("changing window always-on-top mode is not available on {}.", getPlatform().toString());
		return;
	}
	if (_alwaysOnTop == var) {
		return;
	}
	_alwaysOnTop = var;
	invokeInRender([&, var]() {
		SDL_SetWindowAlwaysOnTop(_sdlWindow, var ? SDL_TRUE : SDL_FALSE);
	});
	Event::send("AppChange"_slice, "AlwaysOnTop"s);
}

bool Application::isAlwaysOnTop() const noexcept {
	return _alwaysOnTop;
}

void Application::setDevMode(bool var) {
	_devMode = var;
}

bool Application::isDevMode() const noexcept {
	return _devMode;
}

// This function runs in main (render) thread, and do render work
int Application::run(MainFunc mainFunc) {
	_mainFunc = mainFunc;
	Application::setSeed(s_cast<uint32_t>(std::time(nullptr)));

	if (SDL_Init(SDL_INIT_GAMECONTROLLER) != 0) {
		Error("SDL failed to initialize! {}", SDL_GetError());
		return 1;
	}

	SharedController.initInRender();

	SDL_SetHint(SDL_HINT_MOUSE_TOUCH_EVENTS, "1");
	SDL_SetHint(SDL_HINT_VIDEO_EXTERNAL_CONTEXT, "1");
	SDL_SetHint(SDL_HINT_IME_SHOW_UI, "1");
	SDL_SetHint(SDL_HINT_ORIENTATIONS, "LandscapeLeft LandscapeRight");

	uint32_t windowFlags = SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_RESIZABLE;
#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX
	windowFlags |= SDL_WINDOW_HIDDEN;
#if BX_PLATFORM_LINUX
	const char* videoDriver = SDL_GetCurrentVideoDriver();
	const bool useKmsdrmGL = videoDriver && std::strcmp(videoDriver, "KMSDRM") == 0;
	if (useKmsdrmGL) {
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
		SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		windowFlags |= SDL_WINDOW_OPENGL | SDL_WINDOW_FULLSCREEN | SDL_WINDOW_BORDERLESS;
		_fullScreen = true;
	}
#endif // BX_PLATFORM_LINUX
	if (_alwaysOnTop) {
		windowFlags |= SDL_WINDOW_ALWAYS_ON_TOP;
	}
#elif BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
	windowFlags |= SDL_WINDOW_FULLSCREEN | SDL_WINDOW_BORDERLESS;
	_fullScreen = true;
#endif // BX_PLATFORM

	_sdlWindow = SDL_CreateWindow("Dora SSR",
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		_winWidth, _winHeight, windowFlags);
	if (!_sdlWindow) {
		Error("SDL failed to create window! {}", SDL_GetError());
		return 1;
	}

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX
	int displayIndex = SDL_GetWindowDisplayIndex(_sdlWindow);
	SDL_Rect rect;
	if (SDL_GetDisplayBounds(displayIndex, &rect) == 0 && (_winWidth > rect.w || _winHeight > rect.h)) {
		_winWidth = rect.w;
		_winHeight = rect.h;
		SDL_SetWindowSize(_sdlWindow, _winWidth, _winHeight);
	}
#endif // BX_PLATFORM

	Application::setupSdlWindow();

	// call this function here to disable default render threads creation of bgfx
	bgfx::renderFrame();

	// start running logic thread
	_logicThread.init(Application::mainLogic, this);

	SDL_Event event;
	while (_renderRunning) {
		// do render staff and swap buffers
		bgfx::renderFrame();
		if (_sdlGLContext) {
			SDL_GL_SwapWindow(_sdlWindow);
		}

		// handle SDL event in this main thread only
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				case SDL_QUIT:
					if (Singleton<DB>::isInitialized()) {
						SharedDB.stop();
					}
#if defined(NDEBUG) && !defined(DORA_AS_LIB)
					std::_Exit(EXIT_SUCCESS);
#else
					_renderRunning = false;
#endif
					break;
#if BX_PLATFORM_ANDROID
				case SDL_APP_DIDENTERFOREGROUND: {
					bgfx::PlatformData pd{};
					pd.nwh = Android_JNI_GetNativeWindow();
					if (pd.nwh) {
						bgfx::setPlatformData(pd);
					}
					break;
				}
#endif // BX_PLATFORM_ANDROID
				case SDL_WINDOWEVENT: {
					switch (event.window.event) {
						case SDL_WINDOWEVENT_RESIZED:
						case SDL_WINDOWEVENT_SIZE_CHANGED: {
#if BX_PLATFORM_ANDROID
							bgfx::PlatformData pd{};
							pd.nwh = Android_JNI_GetNativeWindow();
							if (pd.nwh) {
								bgfx::setPlatformData(pd);
							}
#endif // BX_PLATFORM_ANDROID
							updateWindowSize();
							break;
						}
						case SDL_WINDOWEVENT_MOVED:
							_winPosition = Vec2{s_cast<float>(event.window.data1), s_cast<float>(event.window.data2)};
							break;
					}
					break;
				}
#if BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
				case SDL_TEXTEDITING: {
					event.edit.start = CodeCvt::utf8_count_characters(event.edit.text);
					break;
				}
#endif // BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
				case SDL_KEYDOWN:
				case SDL_KEYUP:
					SharedController.handleDevVirtualControllerEventInRender(event);
					break;
				case SDL_CONTROLLERDEVICEADDED:
				case SDL_CONTROLLERDEVICEREMOVED:
				case SDL_CONTROLLERAXISMOTION:
				case SDL_CONTROLLERBUTTONDOWN:
				case SDL_CONTROLLERBUTTONUP: {
					bool updateControllerState = false;
					if (Singleton<ImGuiDora>::isInitialized() && SharedImGui.shouldCaptureControllerEvent(event, &updateControllerState)) {
						if (updateControllerState) {
							SharedController.handleEventInRender(event, false);
						}
					} else {
						SharedController.handleEventInRender(event);
					}
					break;
				}
				default:
					break;
			}
			_logicEvent.post("SDLEvent"_slice, event);
		}

		// poll events from logic thread
		for (Own<QEvent> event = _renderEvent.poll();
			event != nullptr;
			event = _renderEvent.poll()) {
			switch (Switch::hash(event->getName())) {
				case "Quit"_hash: {
					SDL_Event ev;
					ev.quit.type = SDL_QUIT;
					SDL_PushEvent(&ev);
					break;
				}
				case "Invoke"_hash: {
					std::function<void()> func;
					event->get(func);
					func();
					break;
				}
				default:
					break;
			}
		}
	}

	// wait for render process to stop
	while (bgfx::RenderFrame::NoContext != bgfx::renderFrame());
	_logicThread.shutdown();

	if (_sdlGLContext) {
		SDL_GL_DeleteContext(_sdlGLContext);
		_sdlGLContext = nullptr;
	}
	SDL_DestroyWindow(_sdlWindow);
	SDL_Quit();

	return _logicThread.getExitCode();
}

void Application::updateDeltaTime() {
	double currentTime = getCurrentTime();
	_deltaTime = currentTime - _lastTime;
	// in case of system timer api error
	if (_deltaTime <= 0) {
		_deltaTime = 1.0 / _targetFPS;
		_lastTime = currentTime;
	}
}

#if BX_PLATFORM_ANDROID || BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_LINUX
void Application::updateWindowSize() {
#if BX_PLATFORM_OSX
	SDL_Metal_GetDrawableSize(_sdlWindow, &_bufferWidth, &_bufferHeight);
#else
	SDL_GL_GetDrawableSize(_sdlWindow, &_bufferWidth, &_bufferHeight);
#endif
	SDL_GetWindowSize(_sdlWindow, &_winWidth, &_winHeight);
	int displayIndex = SDL_GetWindowDisplayIndex(_sdlWindow);
	SDL_DisplayMode displayMode{SDL_PIXELFORMAT_UNKNOWN, 0, 0, 0, 0};
	SDL_GetCurrentDisplayMode(displayIndex, &displayMode);
	if (displayMode.refresh_rate > 0) {
		_maxFPS = displayMode.refresh_rate;
	}
#if BX_PLATFORM_WINDOWS
	float hdpi = DEFAULT_WIN_DPI, vdpi = DEFAULT_WIN_DPI;
	SDL_GetDisplayDPI(displayIndex, nullptr, &hdpi, &vdpi);
	_visualWidth = MulDiv(_winWidth, DEFAULT_WIN_DPI, s_cast<int>(hdpi));
	_visualHeight = MulDiv(_winHeight, DEFAULT_WIN_DPI, s_cast<int>(vdpi));
#elif BX_PLATFORM_ANDROID
	_visualWidth = s_cast<int>(_winWidth / g_androidScreenDensity);
	_visualHeight = s_cast<int>(_winHeight / g_androidScreenDensity);
#else
	_visualWidth = _winWidth;
	_visualHeight = _winHeight;
#endif
}
#endif // BX_PLATFORM_ANDROID || BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_LINUX

#if BX_PLATFORM_ANDROID
const std::string& Application::getAPKPath() const noexcept {
	return g_androidAPKPath;
}
#endif // BX_PLATFORM_ANDROID

double Application::getElapsedTime() const noexcept {
	double currentTime = getCurrentTime();
	return std::max(currentTime - _lastTime, 0.0);
}

double Application::getCurrentTime() const noexcept {
	return bx::getHPCounter() / _frequency;
}

double Application::getRunningTime() const noexcept {
	return getCurrentTime() - _startTime;
}

double Application::getLastTime() const noexcept {
	return _lastTime;
}

double Application::getDeltaTime() const noexcept {
	return _deltaTime;
}

double Application::getCPUTime() const noexcept {
	return _cpuTime;
}

double Application::getGPUTime() const noexcept {
	const bgfx::Stats* stats = bgfx::getStats();
	if (stats->gpuTimeEnd < stats->gpuTimeBegin) {
		return 0;
	}
	return s_cast<double>(stats->gpuTimeEnd - stats->gpuTimeBegin) / s_cast<double>(stats->gpuTimerFreq);
}

double Application::getLogicTime() const noexcept {
	return _logicTime;
}

double Application::getRenderTime() const noexcept {
	return _renderTime;
}

double Application::getTotalTime() const noexcept {
	return _totalTime;
}

void Application::makeTimeNow() {
	_totalTime += _deltaTime;
	_lastTime = getCurrentTime();
}

void Application::shutdown() {
	if (_devMode) {
		Event::send("AppEvent"sv, "Shutdown"s);
		return;
	}
	switch (Switch::hash(getPlatform())) {
		case "Windows"_hash:
		case "macOS"_hash:
		case "Linux"_hash:
			_renderEvent.post("Quit"_slice);
			break;
	}
}

void Application::invokeInRender(const std::function<void()>& func) {
	_renderEvent.post("Invoke"_slice, func);
}

void Application::invokeInLogic(const std::function<void()>& func) {
	_logicEvent.post("Invoke"_slice, func);
}

int Application::mainLogic(Application* app) {
	app->_logicThreadID = std::this_thread::get_id();

	if (!SharedBGFX.init(app->_platformData)) {
		Error("bgfx failed to initialize!");
		return 1;
	}

	SharedPoolManager.push();
	if (!SharedDirector.init()) {
		Error("Director failed to initialize!");
		return 1;
	}

	if (app->_mainFunc) {
		if (!app->_mainFunc()) {
			Error("Failed to start main!");
			return 1;
		}
	}

#if BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_LINUX
	for (int i = 0; i < 3; i++) {
		app->_frame = bgfx::frame();
	}
	app->invokeInRender([app]() {
		SDL_ShowWindow(app->_sdlWindow);
	});
#else
	app->_frame = bgfx::frame();
#endif

	app->makeTimeNow();
	app->_startTime = app->_lastTime;

	SharedPoolManager.pop();

	while (app->_logicRunning) {
		auto startTime = app->getElapsedTime();

		SharedPoolManager.push();

		// poll events from render thread
		for (Own<QEvent> event = app->_logicEvent.poll();
			event != nullptr;
			event = app->_logicEvent.poll()) {
			switch (Switch::hash(event->getName())) {
				case "SDLEvent"_hash: {
					SDL_Event sdlEvent;
					event->get(sdlEvent);
					switch (sdlEvent.type) {
						case SDL_QUIT: {
							app->_logicRunning = false;
							app->quitHandler();
							// Info("singleton reference tree:\n{}", Life::getRefTree());
							break;
						}
						default:
							break;
					}
					SharedDirector.handleSDLEvent(sdlEvent);
					app->eventHandler(sdlEvent);
					break;
				}
				case "Invoke"_hash: {
					std::function<void()> func;
					event->get(func);
					func();
					break;
				}
				default:
					break;
			}
		}

		SharedDirector.doLogic();

		app->_logicTime = app->getElapsedTime() - startTime;

		SharedDirector.doRender();
		SharedPoolManager.pop();

		app->_cpuTime = app->getElapsedTime() - startTime;
		app->_renderTime = app->_cpuTime - app->_logicTime;

		// advance to next frame. rendering thread will be kicked to
		// process submitted rendering primitives.
		app->_frame = bgfx::frame();

		double targetDeltaTime = 1.0 / app->_targetFPS;
		if (app->_idled) {
			app->updateDeltaTime();
			double idleTime = targetDeltaTime - app->getDeltaTime();
			if (idleTime > 0) {
				std::chrono::duration<double> time{idleTime};
				std::this_thread::sleep_for(time);
			}
			app->updateDeltaTime();
		} else if (app->_fpsLimited) {
			do {
				app->updateDeltaTime();
			} while (app->getDeltaTime() < targetDeltaTime);
		} else
			app->updateDeltaTime();
		app->makeTimeNow();
	}

#ifdef DORA_AS_LIB
	bgfx::shutdown();
#else // DORA_AS_LIB
	Life::destroy("BGFXDora"_slice);
#endif // DORA_AS_LIB
	return 0;
}

int Application::mainLogic(bx::Thread* thread, void* userData) {
	DORA_UNUSED_PARAM(thread);
	Application* app = r_cast<Application*>(userData);
	try {
		return mainLogic(app);
	} catch (const std::exception& e) {
		LogError(e.what());
		if (Singleton<DB>::isInitialized()) {
			SharedDB.stop();
		}
		std::abort();
	}
}

const Slice Application::getPlatform() const noexcept {
#if BX_PLATFORM_WINDOWS
	return "Windows"_slice;
#elif BX_PLATFORM_ANDROID
	return "Android"_slice;
#elif BX_PLATFORM_OSX
	return "macOS"_slice;
#elif BX_PLATFORM_IOS
	return "iOS"_slice;
#elif BX_PLATFORM_LINUX
	return "Linux"_slice;
#else
	return "Unsupported"_slice;
#endif
}

const Slice Application::getVersion() const noexcept {
	static std::string versionStr = DORA_VERSION.toString() + '.' + DORA_REVISION;
	return versionStr;
}

bool Application::isDebugging() const noexcept {
#ifdef NDEBUG
	return false;
#else
	return true;
#endif
}

std::thread::id Application::getLogicThread() const noexcept {
	return _logicThreadID;
}

#if BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || BX_PLATFORM_LINUX
void Application::setupSdlWindow() {
	SDL_SysWMinfo wmi;
	SDL_VERSION(&wmi.version);
	SDL_GetWindowWMInfo(_sdlWindow, &wmi);
#if BX_PLATFORM_OSX
	_platformData.nwh = wmi.info.cocoa.window;
#elif BX_PLATFORM_WINDOWS
	_platformData.nwh = wmi.info.win.window;
#elif BX_PLATFORM_ANDROID
	_platformData.nwh = wmi.info.android.window;
#elif BX_PLATFORM_LINUX
	if (wmi.subsystem == SDL_SYSWM_WAYLAND) {
		_platformData.ndt = wmi.info.wl.display;
		_platformData.nwh = r_cast<void*>(wmi.info.wl.surface);
		_platformData.type = bgfx::NativeWindowHandleType::Wayland;
	} else if (wmi.subsystem == SDL_SYSWM_KMSDRM) {
		_sdlGLContext = SDL_GL_CreateContext(_sdlWindow);
		if (!_sdlGLContext) {
			Error("SDL failed to create KMSDRM GL context! {}", SDL_GetError());
			return;
		}
		if (SDL_GL_MakeCurrent(_sdlWindow, _sdlGLContext) != 0) {
			Error("SDL failed to make KMSDRM GL context current! {}", SDL_GetError());
			return;
		}
		_platformData.context = _sdlGLContext;
		_platformData.type = bgfx::NativeWindowHandleType::Default;
	} else {
		_platformData.ndt = wmi.info.x11.display;
		_platformData.nwh = r_cast<void*>(wmi.info.x11.window);
		_platformData.type = bgfx::NativeWindowHandleType::Default;
	}
#endif // BX_PLATFORM
#if BX_PLATFORM_WINDOWS
	int displayIndex = SDL_GetWindowDisplayIndex(_sdlWindow);
	float hdpi = DEFAULT_WIN_DPI, vdpi = DEFAULT_WIN_DPI;
	SDL_GetDisplayDPI(displayIndex, nullptr, &hdpi, &vdpi);
	SDL_DisplayMode displayMode{SDL_PIXELFORMAT_UNKNOWN, 0, 0, 0, 0};
	SDL_GetCurrentDisplayMode(displayIndex, &displayMode);
	int screenWidth = MulDiv(displayMode.w, DEFAULT_WIN_DPI, s_cast<int>(hdpi));
	int screenHeight = MulDiv(displayMode.h, DEFAULT_WIN_DPI, s_cast<int>(vdpi));
	_visualWidth = Math::clamp(_visualWidth, 0, screenWidth);
	_visualHeight = Math::clamp(_visualHeight, 0, screenHeight);
	if (hdpi != DEFAULT_WIN_DPI || vdpi != DEFAULT_WIN_DPI) {
		_winWidth = MulDiv(_visualWidth, s_cast<int>(hdpi), DEFAULT_WIN_DPI);
		_winHeight = MulDiv(_visualHeight, s_cast<int>(vdpi), DEFAULT_WIN_DPI);
		SDL_SetWindowSize(_sdlWindow, _winWidth, _winHeight);
		SDL_SetWindowPosition(_sdlWindow, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
	}
#endif // BX_PLATFORM_WINDOWS
	updateWindowSize();
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || BX_PLATFORM_LINUX

void Application::openURL(String url) {
	invokeInRender([url = url.toString()]() {
		if (SDL_OpenURL(url.c_str()) != 0) {
			Error("failed to open url due to: {}", SDL_GetError());
		}
	});
}

void Application::install(String path) {
#if BX_PLATFORM_WINDOWS && !defined(DORA_AS_LIB)
	AssertUnless(SharedContent.isAbsolutePath(path), "expecting an absolute path");
	auto assetPath = SharedContent.getAssetPath();
	auto appPath = path.toString();
	auto bakPath = Path::concat({assetPath, "Bak"sv});
	SharedContent.remove(bakPath);
	{
		auto dirs = SharedContent.getDirs(assetPath);
		auto files = SharedContent.getFiles(assetPath);
		SharedContent.createFolder(bakPath);
		for (const auto& dir : dirs) {
			SharedContent.move(Path::concat({assetPath, dir}), Path::concat({bakPath, dir}));
		}
		for (const auto& file : files) {
			SharedContent.move(Path::concat({assetPath, file}), Path::concat({bakPath, file}));
		}
	}
	{
		auto dirs = SharedContent.getDirs(appPath);
		auto files = SharedContent.getFiles(appPath);
		for (const auto& dir : dirs) {
			SharedContent.move(Path::concat({appPath, dir}), Path::concat({assetPath, dir}));
		}
		for (const auto& file : files) {
			SharedContent.move(Path::concat({appPath, file}), Path::concat({assetPath, file}));
		}
	}

	STARTUPINFOW si;
	PROCESS_INFORMATION pi;
	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	ZeroMemory(&pi, sizeof(pi));

	auto getCommand = [&]() -> std::wstring {
		std::string command = '"' + Path::concat({assetPath, "Dora.exe"}) + '"';
		if (command.empty()) return {};
		int len = MultiByteToWideChar(CP_UTF8, 0, command.c_str(), -1, NULL, 0);
		if (len == 0) return {};
		std::wstring wideStr(len, L'0');
		if (MultiByteToWideChar(CP_UTF8, 0, command.c_str(), -1, &wideStr[0], len) == 0) {
			wideStr.clear();
			return wideStr;
		}
		return wideStr;
	};

	if (CreateProcessW(NULL,
			getCommand().data(),
			NULL,
			NULL,
			FALSE,
			0,
			NULL,
			NULL,
			&si,
			&pi)) {
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
	}
	Application::setDevMode(false);
	Application::shutdown();
#elif BX_PLATFORM_ANDROID
	g_androidInstallFile = path.toString();
	const int COMMAND_INSTALL = 0x8000;
	Android_JNI_SendMessage(COMMAND_INSTALL, 0);
#else
	Error("Application.install() is not unsupported on this platform");
#endif
}

bool Application::saveLog(String filename) {
	return LogSaveAs(filename.toView());
}

void Application::openFileDialog(bool folderOnly, const std::function<void(std::string)>& callback) {
#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX
	invokeInRender([this, folderOnly, callback]() {
		std::string path;
		NFD::Guard nfdGuard;
		NFD::UniquePath outPath;
		nfdwindowhandle_t parentWindow{};
		NFD_GetNativeWindowFromSDLWindow(_sdlWindow, &parentWindow);
		nfdresult_t result;
		if (folderOnly) {
			result = NFD::PickFolder(outPath, nullptr, parentWindow);
		} else {
			const nfdfilteritem_t filters[] = {
				{"Images", "png,jpg,jpeg,bmp,gif,webp,ktx,pvr,dds,clip"},
				{"Scripts", "lua,ts,tsx,yue,tl,js,json,xml,md,yarn,wa"},
				{"Audio", "wav,mp3,ogg,flac"},
				{"All Files", "*"},
			};
			result = NFD::OpenDialog(outPath, filters, s_cast<nfdfiltersize_t>(sizeof(filters) / sizeof(filters[0])), nullptr, parentWindow);
		}
		if (result == NFD_OKAY) {
			path = outPath.get();
		} else if (result == NFD_ERROR) {
			Error("failed to pick a file or folder due to: {}", NFD::GetError());
		}
		invokeInLogic([callback, path]() {
			callback(std::move(path));
		});
	});
#else
	Issue("Application.openFileDialog() is not unsupported on this platform");
#endif
}

NS_DORA_END

// Entry functions needed by SDL2
#if BX_PLATFORM_OSX || BX_PLATFORM_ANDROID || BX_PLATFORM_IOS || BX_PLATFORM_LINUX
#ifndef DORA_AS_LIB
int main(int argc, char* argv[]) {
	if (Dora::isCliRequested(argc, argv)) {
		int exitCode = Dora::runCliApplication(argc, argv);
		Dora::Life::destroy(Slice::Empty);
		return exitCode;
	}
	int exitCode = SharedApplication.run();
	Dora::Life::destroy(Slice::Empty);
	return exitCode;
}
#endif // !DORA_AS_LIB
#endif // BX_PLATFORM_OSX || BX_PLATFORM_ANDROID || BX_PLATFORM_IOS || BX_PLATFORM_LINUX

#if BX_PLATFORM_WINDOWS

#if DORA_WIN_CONSOLE
#include "Common/Async.h"

NS_DORA_BEGIN

class Console : public NonCopyable {
public:
	virtual ~Console() {
		system("pause");
		FreeConsole();
	}
	inline void init() {
		AllocConsole();
		freopen("CONIN$", "r", stdin);
		freopen("CONOUT$", "w", stdout);
		freopen("CONOUT$", "w", stderr);
	}
	SINGLETON_REF(Console);
	SINGLETON_REF(AsyncLogThread, Console);
};
#define SharedConsole \
	Dora::Singleton<Dora::Console>::shared()

NS_DORA_END
#endif // DORA_WIN_CONSOLE

#ifndef DORA_AS_LIB
int CALLBACK WinMain(
	_In_ HINSTANCE hInstance,
	_In_ HINSTANCE hPrevInstance,
	_In_ LPSTR lpCmdLine,
	_In_ int nCmdShow) {
#if DORA_WIN_CONSOLE
	SharedConsole.init();
#endif
	int argc = 0;
	LPWSTR* argvW = CommandLineToArgvW(GetCommandLineW(), &argc);
	std::vector<std::string> argvStorage;
	std::vector<char*> argv;
	if (argvW) {
		argvStorage.reserve(s_cast<size_t>(argc));
		argv.reserve(s_cast<size_t>(argc));
		for (int i = 0; i < argc; i++) {
			int len = WideCharToMultiByte(CP_UTF8, 0, argvW[i], -1, nullptr, 0, nullptr, nullptr);
			std::string item(s_cast<size_t>(len > 0 ? len - 1 : 0), '\0');
			if (len > 0) {
				WideCharToMultiByte(CP_UTF8, 0, argvW[i], -1, item.data(), len, nullptr, nullptr);
			}
			argvStorage.push_back(std::move(item));
		}
		LocalFree(argvW);
		for (auto& item : argvStorage) {
			argv.push_back(item.data());
		}
	}
	if (!argv.empty() && Dora::isCliRequested(argc, argv.data())) {
		int exitCode = Dora::runCliApplication(argc, argv.data());
		Dora::Life::destroy(Slice::Empty);
		return exitCode;
	}
	int exitCode = SharedApplication.run();
	Dora::Life::destroy(Slice::Empty);
	return exitCode;
}
#endif // !DORA_AS_LIB

#endif // BX_PLATFORM_WINDOWS

#ifdef DORA_AS_LIB
extern "C" DORA_EXPORT int dora_run(MainFunc mainFunc) {
	return SharedApplication.run(mainFunc);
}
#endif // DORA_AS_LIB

#include "Http/HttpServer.h"
#include "Lua/LuaEngine.h"
#include "SQLiteCpp/SQLiteCpp.h"
#include "imgui.h"
#include "implot.h"
#include "playrho/Defines.hpp"
#include "soloud.h"
#include "spdlog/version.h"
#include "spine/Version.h"
#include "sqlite3.h"
#include "wasm3.h"
#include "yuescript/yue_compiler.h"

std::string Dora::Application::getDeps() const noexcept {
	return fmt::format(
		"- SDL2 {}.{}.{}\n"
		"- bgfx {}\n"
		"- Lua {}.{}.{}\n"
		"- Yuescript {}\n"
		"- Teal {}\n"
		"- PlayRho {}.{}.{}\n"
		"- soloud {}\n"
		"- DragonBones 5.6.3\n"
		"- Spine {}\n"
		"- ImGui {}\n"
		"- ImPlot {}\n"
		"- sqlite3 {}\n"
		"- SQLiteCpp {}\n"
		"- wasm3 {}\n"
		"- fmt {}\n"
		"- httplib {}\n"
		"- spdlog {}.{}.{}",
		SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_PATCHLEVEL,
		BGFX_API_VERSION,
		LUA_VERSION_MAJOR, LUA_VERSION_MINOR, LUA_VERSION_RELEASE,
		yue::version,
		SharedLuaEngine.getTealVersion(),
		PLAYRHO_VERSION_MAJOR, PLAYRHO_VERSION_MINOR, PLAYRHO_VERSION_PATCH,
		SOLOUD_VERSION,
		SPINE_VERSION_STRING,
		IMGUI_VERSION,
		IMPLOT_VERSION,
		SQLITE_VERSION,
		SQLITECPP_VERSION,
		M3_VERSION,
		FMT_VERSION,
		HttpServer::getVersion(),
		SPDLOG_VER_MAJOR, SPDLOG_VER_MINOR, SPDLOG_VER_PATCH);
}
