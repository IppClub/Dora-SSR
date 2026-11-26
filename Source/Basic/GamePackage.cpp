/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
#include "Const/Header.h"
#include "Basic/GamePackage.h"

#include "Common/Async.h"
#include "Http/HttpStaticContent.h"
#include "Http/XrtNetwork.h"
#include "Lua/LuaHandler.h"
#include "Lua/LuaEngine.h"
#include "Lua/ToLua/tolua++.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"
#define MINIZ_NO_ZLIB_COMPATIBLE_NAMES
#include "miniz.h"
#include <fstream>
#include <fcntl.h>
#if defined(_WIN32)
#include <io.h>
#include <sys/stat.h>
#else
#include <unistd.h>
#endif

namespace Dora::GamePackage {

std::string read(const fs::path& file, size_t limit) {
	std::error_code error;
	auto size = fs::file_size(file, error);
	if (error || size > limit) throw std::runtime_error("Cannot read export file: " + utf8(file.filename()));
	std::string data(size, '\0');
	std::ifstream input(file, std::ios::binary);
	require(input && input.read(data.data(), static_cast<std::streamsize>(size)), "Cannot read export file");
	return data;
}

std::string base64(std::string_view bytes) {
	constexpr std::string_view alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	std::string result;
	result.reserve((bytes.size() + 2) / 3 * 4);
	for (size_t i = 0; i < bytes.size(); i += 3) {
		auto a = static_cast<uint8_t>(bytes[i]);
		auto b = i + 1 < bytes.size() ? static_cast<uint8_t>(bytes[i + 1]) : 0;
		auto c = i + 2 < bytes.size() ? static_cast<uint8_t>(bytes[i + 2]) : 0;
		result += alphabet[a >> 2];
		result += alphabet[(a & 3) * 16 + (b >> 4)];
		result += i + 1 < bytes.size() ? alphabet[(b & 15) * 4 + (c >> 6)] : '=';
		result += i + 2 < bytes.size() ? alphabet[c & 63] : '=';
	}
	return result;
}

std::string unbase64(std::string_view encoded) {
	constexpr std::string_view alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	require(encoded.size() % 4 == 0, "Invalid PKCS#12 encoding");
	std::string output;
	output.reserve(encoded.size() / 4 * 3);
	for (size_t i = 0; i < encoded.size(); i += 4) {
		auto a = alphabet.find(encoded[i]);
		auto b = alphabet.find(encoded[i + 1]);
		auto c = alphabet.find(encoded[i + 2]);
		auto d = alphabet.find(encoded[i + 3]);
		require(a < 64 && b < 64, "Invalid PKCS#12 encoding");
		output += static_cast<char>((a << 2) | (b >> 4));
		if (encoded[i + 2] == '=') {
			require(encoded[i + 3] == '=' && i + 4 == encoded.size(), "Invalid PKCS#12 encoding");
			break;
		}
		require(c < 64, "Invalid PKCS#12 encoding");
		output += static_cast<char>((b << 4) | (c >> 2));
		if (encoded[i + 3] == '=') {
			require(i + 4 == encoded.size(), "Invalid PKCS#12 encoding");
			break;
		}
		require(d < 64, "Invalid PKCS#12 encoding");
		output += static_cast<char>((c << 6) | d);
	}
	return output;
}

void replaceOnce(std::string& source, std::string_view oldText, std::string_view newText) {
	auto at = source.find(oldText);
	require(at != std::string::npos && source.find(oldText, at + oldText.size()) == std::string::npos, "Unsupported Web Player runtime");
	source.replace(at, oldText.size(), newText);
}

namespace {
constexpr size_t maxFile = 64u * 1024u * 1024u;
constexpr size_t maxProject = 256u * 1024u * 1024u;

std::string runtimeFile(const fs::path& root, std::string_view name, size_t limit) {
	auto file = root / path(name);
	if (fs::exists(file)) return read(file, limit);
	file += ".gz";
	auto unpacked = HttpPolicy::decodePrecompressedGzip(read(file, limit + 65536), limit);
	require(unpacked.has_value(), "Invalid compressed Web Player asset");
	return std::move(*unpacked);
}

std::string digest(std::string_view bytes) {
	char hash[65];
	require(DoraXrtSha256Hex(bytes.data(), bytes.size(), hash), "Cannot hash Web game asset");
	return hash;
}

template <class T> std::string json(const T& value) {
	rapidjson::StringBuffer buffer;
	rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
	require(value.Accept(writer), "Cannot encode export metadata");
	return {buffer.GetString(), buffer.GetSize()};
}

rapidjson::Value stringValue(std::string_view value, rapidjson::Document::AllocatorType& allocator) {
	return rapidjson::Value(value.data(), static_cast<rapidjson::SizeType>(value.size()), allocator);
}

std::string urlPath(std::string_view name) {
	std::string result;
	constexpr char hex[] = "0123456789ABCDEF";
	for (auto c : name) {
		auto byte = static_cast<uint8_t>(c);
		if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || std::string_view("/-._~").find(c) != std::string_view::npos) result += c;
		else {
			result += '%';
			result += hex[byte >> 4];
			result += hex[byte & 15];
		}
	}
	return result;
}

class WebArchive {
public:
	WebArchive(const fs::path& output, bool html)
		: _file(open(output, "wb")), _html(html) {
		require(_file && mz_zip_writer_init_cfile(&_zip, _file.get(), 0), "Cannot create Web game ZIP");
	}
	~WebArchive() { mz_zip_writer_end(&_zip); }
	void add(std::string_view name, std::string_view data) {
		require(mz_zip_writer_add_mem(&_zip, std::string(name).c_str(), data.data(), data.size(), 6), "Cannot write Web game ZIP");
	}
	void addAsset(std::string_view name, std::string_view data, bool embedded = false) {
		auto& alloc = _bundle.GetAllocator();
		std::string target(name);
		std::string script;
		if (_html && embedded) {
			target = "html-assets/" + std::to_string(_records.MemberCount()) + ".js";
			rapidjson::Value record(rapidjson::kObjectType);
			record.AddMember("script", stringValue(target, alloc), alloc);
			record.AddMember("size", static_cast<uint64_t>(data.size()), alloc);
			record.AddMember("sha256", stringValue(digest(data), alloc), alloc);
			_records.AddMember(stringValue(name, alloc), record, alloc);
			script = "DoraHtmlPackage.deliver(" + json(stringValue(name, alloc)) + ",\"" + base64(data) + "\");\n";
			data = script;
		}
		add(target, data);
		rapidjson::Value record(rapidjson::kObjectType);
		record.AddMember("size", static_cast<uint64_t>(data.size()), alloc);
		record.AddMember("sha256", stringValue(digest(data), alloc), alloc);
		_bundle.AddMember(stringValue(target, alloc), record, alloc);
	}
	void finalize(std::string_view metadata) {
		add("runtime.json", metadata);
		require(mz_zip_writer_finalize_archive(&_zip) && std::fflush(_file.get()) == 0, "Cannot finish Web game ZIP");
	}
	rapidjson::Document& index() { return _bundle; }
	rapidjson::Value& records() { return _records; }
private:
	File _file;
	bool _html;
	mz_zip_archive _zip{};
	rapidjson::Document _bundle{rapidjson::kObjectType};
	rapidjson::Value _records{rapidjson::kObjectType};
};

void buildWeb(const rapidjson::Value& options, bool html) {
	auto www = path(options, "www");
	auto runtime = www / "web-player";
	auto game = path(options, "assets");
	const auto& dependency = member(options, "needsGodot");
	bool godot = dependency.IsTrue();
	require(!html || !godot, "Godot projects require the HTTP export with COOP/COEP response headers");
	rapidjson::Document runtimeIndex;
	runtimeIndex.Parse(runtimeFile(runtime, "runtime.json", 65536).c_str());
	require(runtimeIndex.IsObject(), "Invalid Web Player runtime index");
	auto version = text(runtimeIndex, "engineVersion");
	require(!version.empty() && std::count(version.begin(), version.end(), '.') == 2
		&& version.find_first_not_of("0123456789.") == std::string_view::npos, "Invalid Web Player engine version");
	auto& fileIndex = member(runtimeIndex, "files");
	std::vector<std::string_view> names = {"dora-player-runtime.js", "dora-player-runtime.wasm", "dora-player-runtime.data",
		"dora-web-features.json", "audio-worklet.js", "dora-audio-mixer.wasm", "dora-logo.png",
		"LICENSE-Dora.txt", "LICENSES.3rdparty.md", "NOTICE.txt"};
	if (godot) {
		constexpr std::string_view godotNames[] = {"godot/dora-godot.js", "godot/dora-godot.wasm", "godot/shared_gl.mjs", "godot/runtime_bridge.mjs",
			"godot/manifest.json", "godot/LICENSE.txt", "godot/COPYRIGHT.txt", "godot/AUTHORS.md"};
		names.insert(names.end(), std::begin(godotNames), std::end(godotNames));
	}
	auto verified = [&](std::string_view name) {
		auto key = std::string(name);
		const auto& record = member(fileIndex, key.c_str());
		const auto& size = member(record, "size");
		require(size.IsUint() && size.GetUint() > 0 && size.GetUint() <= 128u * 1024u * 1024u, "Invalid Web Player asset size");
		auto bytes = runtimeFile(runtime, name, size.GetUint());
		require(bytes.size() == size.GetUint() && digest(bytes) == text(record, "sha256"), "Web Player checksum mismatch");
		return bytes;
	};
	auto features = verified("dora-web-features.json");
	rapidjson::Document feature;
	feature.Parse(features.c_str());
	const auto& modules = member(feature, "modules");
	auto flag = [&](const char* key) {
		auto it = modules.FindMember(key);
		return it != modules.MemberEnd() && it->value.IsTrue();
	};
	require(modules.IsObject() && text(feature, "activeProfile") == "dora-preset" && !flag("threads")
		&& !flag("crossOriginIsolationRequired") && flag("model3D") && flag("jolt3D") && flag("rustBridge") && flag("loveNode")
		&& member(modules, "yueCompiler").IsFalse() && member(modules, "tealCompiler").IsFalse() && member(modules, "xmlCompiler").IsFalse(),
		"Unsupported Web Player runtime profile");
	require(!godot || flag("godotNode"), "Godot runtime is unavailable for this project");

	require(fs::is_regular_file(game / "init.lua"), "Missing compiled Web entry: init.lua");
	WebArchive archive(path(options, "output"), html);
	for (auto name : names) {
		auto bytes = name == "dora-web-features.json" ? features : verified(name);
		if (name == "dora-player-runtime.js") {
			constexpr std::string_view optional = "if(Module.doraGodotEnabled===false||!globalThis.crossOriginIsolated)return;";
			if (!godot && flag("godotNode") && bytes.find(optional) == std::string::npos) {
				replaceOnce(bytes, "if(!globalThis.crossOriginIsolated)return;", optional);
			}
			if (html) {
				replaceOnce(bytes, "new URL(\"dora-audio-mixer.wasm\",base)", "Module.locateFile(\"dora-audio-mixer.wasm\")");
				replaceOnce(bytes, "new URL(\"audio-worklet.js\",base)", "Module.locateFile(\"audio-worklet.js\")");
			}
		}
		bool embedded = name == "dora-player-runtime.wasm" || name == "dora-player-runtime.data"
			|| name == "dora-audio-mixer.wasm" || name == "audio-worklet.js";
		archive.addAsset(name, bytes, embedded);
	}
	rapidjson::Document manifest(rapidjson::kObjectType);
	auto& alloc = manifest.GetAllocator();
	manifest.AddMember("format", "dora-web-game", alloc);
	manifest.AddMember("version", 1, alloc);
	manifest.AddMember("engineVersion", stringValue(version, alloc), alloc);
	manifest.AddMember("profile", "dora-preset", alloc);
	manifest.AddMember("entry", "init.lua", alloc);

	std::vector<fs::path> files;
	for (const auto& item : fs::recursive_directory_iterator(game)) {
		require(!item.is_symlink(), "Symbolic links are not supported in game exports");
		if (item.is_regular_file()) files.push_back(item.path().lexically_relative(game));
		require(files.size() <= 4096, "Too many Web game files");
	}
	std::sort(files.begin(), files.end());
	size_t total = 0;
	rapidjson::Value gameFiles(rapidjson::kArrayType);
	for (const auto& file : files) {
		auto name = utf8(file);
		auto bytes = read(game / file, std::min(maxFile, maxProject - total));
		total += bytes.size();
		auto hash = digest(bytes);
		auto asset = "assets/" + hash + "/" + name;
		archive.addAsset(asset, bytes, true);
		rapidjson::Value item(rapidjson::kObjectType);
		item.AddMember("path", stringValue(name, alloc), alloc);
		item.AddMember("url", stringValue(urlPath(asset), alloc), alloc);
		item.AddMember("size", static_cast<uint64_t>(bytes.size()), alloc);
		item.AddMember("sha256", stringValue(hash, alloc), alloc);
		item.AddMember("startup", true, alloc);
		gameFiles.PushBack(item, alloc);
	}
	manifest.AddMember("files", gameFiles, alloc);
	auto manifestJson = json(manifest);
	require(manifestJson.size() <= 1024 * 1024, "Web game manifest is too large");
	auto shell = runtimeFile(www, "export-player/index.html", 65536);
	replaceOnce(shell, "@DORA_GODOT@", godot ? "true" : "false");
	replaceOnce(shell, "@DORA_LOADER@", html ? "html-loader.js" : "dora-player-runtime.js");
	archive.addAsset("index.html", shell);
	if (html) {
		auto loader = runtimeFile(www, "export-player/html-loader.js", 65536);
		auto config = "{\"manifest\":" + manifestJson + ",\"records\":" + json(archive.records()) + "}";
		replaceOnce(loader, "DORA_EXPORT_CONFIG", config);
		archive.addAsset("html-loader.js", loader);
		archive.addAsset("README-Web.txt", "完整解压 ZIP 后双击 index.html 即可启动。请保留所有配套文件。\n\nExtract the entire ZIP and open index.html in a modern browser. Keep all accompanying files.\n");
	} else {
		archive.addAsset("dora-web-manifest.json", manifestJson);
		archive.addAsset("README-Web.txt", "将整个目录部署到静态网站，通过 HTTPS 或 localhost 打开 index.html。\n\nDeploy the entire directory and open index.html over HTTPS or localhost.\nGodot requires Cross-Origin-Opener-Policy: same-origin and Cross-Origin-Embedder-Policy: require-corp.\n");
	}
	auto& runtimeAlloc = runtimeIndex.GetAllocator();
	auto& runtimeFiles = runtimeIndex["files"];
	runtimeFiles.CopyFrom(archive.index(), runtimeAlloc);
	if (html) runtimeIndex.AddMember("format", "html", runtimeAlloc);
	archive.finalize(json(runtimeIndex));
}

int run(lua_State* state) {
	size_t length = 0;
	auto input = luaL_checklstring(state, 1, &length);
	luaL_checktype(state, 2, LUA_TFUNCTION);
	Ref<LuaHandler> callback(LuaHandler::create(tolua_ref_function(state, 2)));
	SharedAsyncThread.run([data = std::string(input, length)] {
		try {
			rapidjson::Document options;
			options.Parse(data.data(), data.size());
			auto format = text(options, "format");
#if DORA_APK_EXPORT
			if (format == "android") return Values::alloc(true, buildAndroid(options));
#endif
			require(format == "html" || format == "http", "Unsupported package format");
			buildWeb(options, format == "html");
			return Values::alloc(true, std::string{});
		} catch (const std::exception& error) {
			return Values::alloc(false, std::string(error.what()));
		}
	}, [callback](Own<Values>&& values) {
		bool success = false;
		std::string result;
		values->get(success, result);
		auto state = SharedLuaEngine.getState();
		auto top = lua_gettop(state);
		lua_pushboolean(state, success);
		lua_pushlstring(state, result.data(), result.size());
		LuaEngine::invoke(state, callback->get(), 2, 0);
		lua_settop(state, top);
	});
	return 0;
}

int writeKey(lua_State* state) {
	auto filename = luaL_checkstring(state, 1);
	size_t size = 0;
	auto encoded = luaL_checklstring(state, 2, &size);
	try {
		require(size <= 32768, "Invalid generated signing key");
		auto bytes = unbase64({encoded, size});
		require(!bytes.empty(), "Invalid generated signing key");
		auto destination = path(filename);
		fs::create_directories(destination.parent_path());
#if defined(_WIN32)
		int fd = _wopen(destination.c_str(), _O_WRONLY | _O_CREAT | _O_EXCL | _O_BINARY, _S_IREAD | _S_IWRITE);
		require(fd >= 0, "Cannot create PKCS#12 file (the path may already exist)");
		bool written = _write(fd, bytes.data(), static_cast<unsigned>(bytes.size())) == bytes.size();
		int closed = _close(fd);
#else
		int fd = ::open(destination.c_str(), O_WRONLY | O_CREAT | O_EXCL, 0600);
		require(fd >= 0, "Cannot create PKCS#12 file (the path may already exist)");
		bool written = ::write(fd, bytes.data(), bytes.size()) == static_cast<ssize_t>(bytes.size());
		int closed = ::close(fd);
#endif
		if (!written || closed != 0) {
			std::error_code error;
			fs::remove(destination, error);
			throw std::runtime_error("Cannot save the PKCS#12 signing key");
		}
		lua_pushboolean(state, true);
		return 1;
	} catch (const std::exception& error) {
		lua_pushnil(state);
		lua_pushstring(state, error.what());
		return 2;
	}
}
}
}

int luaopen_dora_game_package(lua_State* state) {
	lua_newtable(state);
	lua_pushcfunction(state, Dora::GamePackage::run);
	lua_setfield(state, -2, "run");
	lua_pushcfunction(state, Dora::GamePackage::writeKey);
	lua_setfield(state, -2, "writeKey");
	return 1;
}
