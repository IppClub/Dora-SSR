/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Love/LoveRuntime.h"
#include "Common/Debug.h"
#include "Lua/BuiltinModules.h"
#include "3rdParty/Love/src/libraries/lz4/lz4.h"
#include "3rdParty/Love/src/libraries/lz4/lz4hc.h"
#include "3rdParty/Love/src/common/Object.h"
#include "3rdParty/Love/src/common/runtime.h"
#include "3rdParty/Love/src/modules/data/HashFunction.h"
#include "3rdParty/Love/src/common/floattypes.h"
#include "3rdParty/Love/src/modules/filesystem/File.h"
#include "3rdParty/Love/src/modules/video/theora/TheoraVideoStream.h"
#include "3rdParty/Zip/zlib/zlib.h"
#include "3rdParty/stb/stb_truetype.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <bit>
#include <charconv>
#include <cctype>
#include <chrono>
#include <condition_variable>
#include <cmath>
#include <cstring>
#include <cstdlib>
#include <filesystem>
#include <iomanip>
#include <iterator>
#include <limits>
#include <memory>
#include <mutex>
#include <new>
#include <numbers>
#include <set>
#include <sstream>
#include <thread>
#include <tuple>
#include <type_traits>

// Compile LOVE's vendored public-domain noise implementation into the same
// runtime translation unit so every platform uses the exact 11.5 algorithm.
#include "3rdParty/Love/src/libraries/noise1234/noise1234.cpp"
#undef FASTFLOOR
#include "3rdParty/Love/src/libraries/noise1234/simplexnoise1234.cpp"
#undef FASTFLOOR

// ImageData uses the same half/packed-float conversions as Love 11.5. Keep the
// implementation in this backend-independent runtime translation unit so all
// Dora targets and the standalone compatibility tests share identical bits.
#include "3rdParty/Love/src/common/floattypes.cpp"

// Reuse Love 11.5's canonical key and scancode string tables without bringing
// its process-global SDL keyboard Module into an isolated LoveRuntime.
#include "3rdParty/Love/src/modules/keyboard/Keyboard.cpp"

extern "C"
{
#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"
}

namespace Dora::Love
{

struct ThreadChannel;
struct ThreadContext;

struct ThreadFilesystemRequest
{
	std::mutex mutex;
	std::condition_variable changed;
	std::function<void()> work;
	bool done = false;
	bool cancelled = false;
};

struct ThreadValue
{
	enum class Type { Nil, Boolean, Number, String, Data, ImageData, Table, Channel };
	Type type = Type::Nil;
	bool boolean = false;
	double number = 0.0;
	std::string string;
	std::vector<std::uint8_t> data;
	int width = 0;
	int height = 0;
	std::string format;
	std::vector<std::pair<ThreadValue, ThreadValue>> table;
	std::shared_ptr<ThreadChannel> channel;
};

struct ThreadChannel
{
	struct Entry { std::uint64_t id = 0; ThreadValue value; };
	std::recursive_mutex mutex;
	std::condition_variable_any changed;
	std::deque<Entry> values;
	std::uint64_t nextId = 1;
	std::uint64_t lastReadId = 0;
	std::weak_ptr<ThreadContext> context;
};

struct ThreadContext
{
	std::mutex mutex;
	std::unordered_map<std::string, std::shared_ptr<ThreadChannel>> namedChannels;
	std::vector<std::weak_ptr<ThreadChannel>> channels;
	std::vector<std::shared_ptr<ThreadWorker>> workers;
	std::mutex errorMutex;
	std::vector<std::pair<std::weak_ptr<ThreadWorker>, std::string>> pendingErrors;
	std::mutex filesystemMutex;
	std::deque<std::shared_ptr<ThreadFilesystemRequest>> filesystemRequests;
	std::atomic<bool> stopping = false;
};

class ThreadFilesystemBackend final : public FilesystemBackend
{
public:
	ThreadFilesystemBackend(std::shared_ptr<ThreadContext> context, FilesystemBackend *backend)
		: _context(std::move(context)), _backend(backend) { }

	bool exist(const std::string &path) const override
	{
		return invoke(false, [&]() { return _backend->exist(path); });
	}
	bool isFolder(const std::string &path) const override
	{
		return invoke(false, [&]() { return _backend->isFolder(path); });
	}
	bool load(const std::string &path, std::string &data, std::string &error) const override
	{
		return invoke(false, [&]() { return _backend->load(path, data, error); });
	}
	bool save(const std::string &path, std::string_view data, std::string &error) override
	{
		const std::string copy(data);
		return invoke(false, [&]() { return _backend->save(path, copy, error); });
	}
	bool createFolder(const std::string &path, std::string &error) override
	{
		return invoke(false, [&]() { return _backend->createFolder(path, error); });
	}
	bool remove(const std::string &path, std::string &error) override
	{
		return invoke(false, [&]() { return _backend->remove(path, error); });
	}
	std::optional<std::uint64_t> getFileSize(const std::string &path) const override
	{
		return invoke(std::optional<std::uint64_t>{}, [&]() { return _backend->getFileSize(path); });
	}
	std::vector<std::string> getDirectoryItems(const std::string &path) const override
	{
		return invoke(std::vector<std::string>{}, [&]() { return _backend->getDirectoryItems(path); });
	}
	std::string getExecutablePath() const override
	{
		return invoke(std::string{}, [&]() { return _backend->getExecutablePath(); });
	}
	bool mountArchive(std::string_view archiveName, std::string_view data,
		std::string &mountedRoot, std::string &error) override
	{
		const std::string nameCopy(archiveName);
		const std::string dataCopy(data);
		return invoke(false, [&]() {
			return _backend->mountArchive(nameCopy, dataCopy, mountedRoot, error);
		});
	}
	void unmountArchive(const std::string &mountedRoot) override
	{
		invoke(false, [&]() { _backend->unmountArchive(mountedRoot); return true; });
	}

private:
	template <class Result, class Callback>
	Result invoke(Result fallback, Callback callback) const
	{
		if (!_backend || !_context || _context->stopping.load(std::memory_order_acquire))
			return fallback;
		Result result = fallback;
		auto request = std::make_shared<ThreadFilesystemRequest>();
		request->work = [&]() { result = callback(); };
		{
			std::lock_guard lock(_context->filesystemMutex);
			_context->filesystemRequests.push_back(request);
		}
		std::unique_lock lock(request->mutex);
		request->changed.wait(lock, [&]() {
			return request->done || _context->stopping.load(std::memory_order_acquire);
		});
		if (!request->done)
		{
			request->cancelled = true;
			request->work = {};
			return fallback;
		}
		return result;
	}

	std::shared_ptr<ThreadContext> _context;
	FilesystemBackend *_backend = nullptr;
};

struct ThreadWorker
{
	~ThreadWorker()
	{
		if (worker.joinable()) worker.join();
	}
	std::mutex mutex;
	std::thread worker;
	std::string code;
	std::string chunkName;
	std::vector<ThreadValue> arguments;
	std::shared_ptr<ThreadContext> context;
	FilesystemBackend *filesystem = nullptr;
	std::string sourceRoot;
	std::string saveBaseRoot;
	std::string identity;
	std::unordered_map<std::string, std::string> preloadModules;
	bool running = false;
	bool started = false;
	std::string error;
};

namespace
{
constexpr const char *AudioSourceRegistry = "Dora.Love.AudioSource.Registry";
constexpr const char *RecordingDeviceRegistry = "Dora.Love.RecordingDevice.Registry";
constexpr const char *ThreadContextRegistry = "Dora.Love.Thread.Context";
constexpr const char *LoveRuntimeRegistry = "Dora.Love.Runtime";

::love::Type LoveThreadableType("Threadable", &::love::Object::type);
::love::Type ThreadLoveType("Thread", &LoveThreadableType);
::love::Type ChannelLoveType("Channel", &::love::Object::type);

struct ThreadUserdata final : ::love::Object
{
	~ThreadUserdata() override = default;
	std::shared_ptr<ThreadWorker> worker;
	LoveRuntime *runtime = nullptr;
};

struct ChannelUserdata final : ::love::Object
{
	~ChannelUserdata() override = default;
	std::shared_ptr<ThreadChannel> channel;
	LoveRuntime *runtime = nullptr;
};

struct DataSpan
{
	const std::uint8_t *bytes = nullptr;
	std::size_t size = 0;
};

bool getDataSpan(lua_State *state, int index, DataSpan &span);
void pushThreadData(lua_State *state, const std::vector<std::uint8_t> &bytes);
bool getThreadImageData(lua_State *state, int index, ThreadValue &value);
void pushThreadImageData(lua_State *state, const ThreadValue &value);

bool threadValueFromLua(lua_State *state, int index, ThreadValue &value,
	std::string &error, int depth = 0)
{
	if (depth > 32)
	{
		error = "thread value table nesting exceeds 32 levels";
		return false;
	}
	index = lua_absindex(state, index);
	switch (lua_type(state, index))
	{
		case LUA_TNIL: value.type = ThreadValue::Type::Nil; return true;
		case LUA_TBOOLEAN:
			value.type = ThreadValue::Type::Boolean;
			value.boolean = lua_toboolean(state, index) != 0;
			return true;
		case LUA_TNUMBER:
			value.type = ThreadValue::Type::Number;
			value.number = lua_tonumber(state, index);
			return true;
		case LUA_TSTRING:
		{
			std::size_t size = 0;
			const char *bytes = lua_tolstring(state, index, &size);
			value.type = ThreadValue::Type::String;
			value.string.assign(bytes, size);
			return true;
		}
		case LUA_TUSERDATA:
		{
			auto *channel = luaL_testudata(state, index, ChannelLoveType.getName())
				? ::love::luax_checktype<ChannelUserdata>(state, index, ChannelLoveType) : nullptr;
			if (channel && channel->channel)
			{
				value.type = ThreadValue::Type::Channel;
				value.channel = channel->channel;
				return true;
			}
			if (getThreadImageData(state, index, value)) return true;
			DataSpan span;
			if (getDataSpan(state, index, span))
			{
				value.type = ThreadValue::Type::Data;
				value.data.clear();
				if (span.size > 0) value.data.assign(span.bytes, span.bytes + span.size);
				return true;
			}
			break;
		}
		case LUA_TTABLE:
		{
			value.type = ThreadValue::Type::Table;
			value.table.clear();
			lua_pushnil(state);
			while (lua_next(state, index) != 0)
			{
				ThreadValue key, item;
				if (!threadValueFromLua(state, -2, key, error, depth + 1)
					|| !threadValueFromLua(state, -1, item, error, depth + 1))
				{
					lua_pop(state, 2);
					return false;
				}
				if (key.type != ThreadValue::Type::Boolean
					&& key.type != ThreadValue::Type::Number
					&& key.type != ThreadValue::Type::String)
				{
					error = "thread value table keys must be booleans, numbers, or strings";
					lua_pop(state, 2);
					return false;
				}
				value.table.emplace_back(std::move(key), std::move(item));
				lua_pop(state, 1);
			}
			return true;
		}
	}
	error = "boolean, number, string, Data, Channel, or table expected";
	return false;
}

void pushThreadValue(lua_State *state, const ThreadValue &value)
{
	switch (value.type)
	{
		case ThreadValue::Type::Nil: lua_pushnil(state); break;
		case ThreadValue::Type::Boolean: lua_pushboolean(state, value.boolean); break;
		case ThreadValue::Type::Number: lua_pushnumber(state, value.number); break;
		case ThreadValue::Type::String:
			lua_pushlstring(state, value.string.data(), value.string.size()); break;
		case ThreadValue::Type::Data:
			pushThreadData(state, value.data); break;
		case ThreadValue::Type::ImageData:
			pushThreadImageData(state, value); break;
		case ThreadValue::Type::Channel:
		{
			lua_getfield(state, LUA_REGISTRYINDEX, LoveRuntimeRegistry);
			auto *runtime = static_cast<LoveRuntime *>(lua_touserdata(state, -1));
			lua_pop(state, 1);
			auto *channel = new ChannelUserdata;
			channel->channel = value.channel; channel->runtime = runtime;
			::love::luax_pushtype(state, ChannelLoveType, channel); channel->release();
			break;
		}
		case ThreadValue::Type::Table:
			lua_createtable(state, 0, static_cast<int>(value.table.size()));
			for (const auto &[key, item] : value.table)
			{
				pushThreadValue(state, key);
				pushThreadValue(state, item);
				lua_rawset(state, -3);
			}
			break;
	}
}

ThreadUserdata *checkThread(lua_State *state, int index)
{
	return ::love::luax_checktype<ThreadUserdata>(state, index, ThreadLoveType);
}

ChannelUserdata *checkChannel(lua_State *state, int index)
{
	return ::love::luax_checktype<ChannelUserdata>(state, index, ChannelLoveType);
}

void pushThread(lua_State *state, const std::shared_ptr<ThreadWorker> &worker)
{
	lua_getfield(state, LUA_REGISTRYINDEX, LoveRuntimeRegistry);
	auto *runtime = static_cast<LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	auto *thread = new ThreadUserdata;
	thread->worker = worker; thread->runtime = runtime;
	::love::luax_pushtype(state, ThreadLoveType, thread); thread->release();
}

void pushChannel(lua_State *state, const std::shared_ptr<ThreadChannel> &channel)
{
	lua_getfield(state, LUA_REGISTRYINDEX, LoveRuntimeRegistry);
	auto *runtime = static_cast<LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	auto *result = new ChannelUserdata;
	result->channel = channel; result->runtime = runtime;
	::love::luax_pushtype(state, ChannelLoveType, result); result->release();
}

bool threadContextStopping(const std::shared_ptr<ThreadChannel> &channel)
{
	const auto context = channel ? channel->context.lock() : nullptr;
	return context && context->stopping.load(std::memory_order_acquire);
}

void threadCancellationHook(lua_State *state, lua_Debug *)
{
	lua_getfield(state, LUA_REGISTRYINDEX, ThreadContextRegistry);
	auto *context = static_cast<ThreadContext *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (context && context->stopping.load(std::memory_order_acquire))
		luaL_error(state, "Love thread stopped because its runtime is closing");
}

std::string incompatibleBytecodeError(std::string_view code)
{
	if (code.size() >= 3 && static_cast<unsigned char>(code[0]) == 0x1b
		&& code[1] == 'L' && code[2] == 'J')
		return "Dora Love runtime uses Lua 5.5 and cannot load LuaJIT bytecode; provide Lua source or recompile it with Lua 5.5";
	if (code.size() >= 5 && static_cast<unsigned char>(code[0]) == 0x1b
		&& code.substr(1, 3) == "Lua")
	{
		const auto version = static_cast<unsigned char>(code[4]);
		constexpr unsigned char CurrentVersion =
			static_cast<unsigned char>(((LUA_VERSION_NUM / 100) << 4) | (LUA_VERSION_NUM % 100));
		if (version != CurrentVersion)
		{
			const int major = version >> 4;
			const int minor = version & 0x0f;
			return "Dora Love runtime uses Lua 5.5 and cannot load Lua "
				+ std::to_string(major) + "." + std::to_string(minor)
				+ " bytecode; provide Lua source or recompile it with Lua 5.5";
		}
	}
	else if (!code.empty() && static_cast<unsigned char>(code[0]) == 0x1b)
		return "Dora Love runtime uses Lua 5.5 and cannot load this precompiled bytecode; provide Lua source or recompile it with Lua 5.5";
	return {};
}

int loadLoveChunk(lua_State *state, std::string_view code, const char *chunkName)
{
	if (code.size() >= 3
		&& static_cast<unsigned char>(code[0]) == 0xef
		&& static_cast<unsigned char>(code[1]) == 0xbb
		&& static_cast<unsigned char>(code[2]) == 0xbf)
		code.remove_prefix(3);
	const std::string compatibilityError = incompatibleBytecodeError(code);
	if (!compatibilityError.empty())
	{
		lua_pushlstring(state, compatibilityError.data(), compatibilityError.size());
		return LUA_ERRSYNTAX;
	}
	return luaL_loadbufferx(state, code.data(), code.size(), chunkName, "bt");
}
constexpr int DefaultWindowWidth = 800;
constexpr int DefaultWindowHeight = 600;
constexpr int MaximumWindowDimension = 8192;
constexpr std::size_t MaximumSoundDataBytes = 256 * 1024 * 1024;
constexpr std::size_t MaximumLoveDataBytes = 256 * 1024 * 1024;

int totalImageMipmapCount(int width, int height, int depth = 1)
{
	int dimension = std::max({width, height, depth});
	int count = 1;
	while (dimension > 1)
	{
		dimension >>= 1;
		++count;
	}
	return count;
}

GraphicsBackend::ImageLevel downsampleImageLevel(
	const GraphicsBackend::ImageLevel &source, GraphicsBackend::TextureType type)
{
	GraphicsBackend::ImageLevel result;
	result.width = std::max(1, source.width / 2);
	result.height = std::max(1, source.height / 2);
	result.slices = type == GraphicsBackend::TextureType::Volume
		? std::max(1, source.slices / 2) : source.slices;
	result.rgba8.resize(static_cast<std::size_t>(result.width) * result.height
		* result.slices * 4);
	const int zSamples = type == GraphicsBackend::TextureType::Volume && source.slices > 1 ? 2 : 1;
	for (int z = 0; z < result.slices; ++z)
		for (int y = 0; y < result.height; ++y)
			for (int x = 0; x < result.width; ++x)
				for (int channel = 0; channel < 4; ++channel)
				{
					unsigned int sum = 0;
					int samples = 0;
					for (int dz = 0; dz < zSamples; ++dz)
						for (int dy = 0; dy < (source.height > 1 ? 2 : 1); ++dy)
							for (int dx = 0; dx < (source.width > 1 ? 2 : 1); ++dx)
							{
								const int sourceX = std::min(source.width - 1, x * 2 + dx);
								const int sourceY = std::min(source.height - 1, y * 2 + dy);
								const int sourceZ = std::min(source.slices - 1, z * 2 + dz);
								const auto offset = ((static_cast<std::size_t>(sourceZ) * source.height
									+ sourceY) * source.width + sourceX) * 4 + channel;
								sum += source.rgba8[offset];
								++samples;
							}
					const auto destination = ((static_cast<std::size_t>(z) * result.height
						+ y) * result.width + x) * 4 + channel;
					result.rgba8[destination] = static_cast<std::uint8_t>((sum + samples / 2) / samples);
				}
	return result;
}

void generateImageMipmaps(std::vector<GraphicsBackend::ImageLevel> &levels,
	GraphicsBackend::TextureType type)
{
	if (levels.size() != 1) return;
	const int count = totalImageMipmapCount(levels.front().width, levels.front().height,
		type == GraphicsBackend::TextureType::Volume ? levels.front().slices : 1);
	levels.reserve(static_cast<std::size_t>(count));
	while (static_cast<int>(levels.size()) < count)
		levels.push_back(downsampleImageLevel(levels.back(), type));
}

GraphicsBackend::ImageLevel extractImageRegion(const GraphicsBackend::ImageLevel &source,
	int x, int y, int width, int height)
{
	GraphicsBackend::ImageLevel result;
	result.width = width;
	result.height = height;
	result.slices = 1;
	result.rgba8.resize(static_cast<std::size_t>(width) * height * 4);
	for (int row = 0; row < height; ++row)
		std::memcpy(result.rgba8.data() + static_cast<std::size_t>(row) * width * 4,
			source.rgba8.data() + (static_cast<std::size_t>(y + row) * source.width + x) * 4,
			static_cast<std::size_t>(width) * 4);
	return result;
}

bool splitCubeImage(const GraphicsBackend::ImageLevel &source,
	GraphicsBackend::ImageLevel &faces, std::string &error)
{
	struct Region { int x; int y; };
	std::array<Region, 6> regions{};
	int size = 0;
	if (source.width % 3 == 0 && source.height % 4 == 0
		&& source.width / 3 == source.height / 4)
	{
		size = source.width / 3;
		regions = {{{1, 1}, {1, 3}, {1, 0}, {1, 2}, {0, 1}, {2, 1}}};
	}
	else if (source.width % 4 == 0 && source.height % 3 == 0
		&& source.width / 4 == source.height / 3)
	{
		size = source.width / 4;
		regions = {{{2, 1}, {0, 1}, {1, 0}, {1, 2}, {1, 1}, {3, 1}}};
	}
	else if (source.height % 6 == 0 && source.width == source.height / 6)
	{
		size = source.width;
		for (int face = 0; face < 6; ++face) regions[face] = {0, face};
	}
	else if (source.width % 6 == 0 && source.width / 6 == source.height)
	{
		size = source.height;
		for (int face = 0; face < 6; ++face) regions[face] = {face, 0};
	}
	else
	{
		error = "Unknown cubemap image dimensions!";
		return false;
	}
	faces = {};
	faces.width = faces.height = size;
	faces.slices = 6;
	faces.rgba8.reserve(static_cast<std::size_t>(size) * size * 6 * 4);
	for (const auto &region : regions)
	{
		auto face = extractImageRegion(source, region.x * size, region.y * size, size, size);
		faces.rgba8.insert(faces.rgba8.end(), face.rgba8.begin(), face.rgba8.end());
	}
	error.clear();
	return true;
}

bool splitVolumeImage(const GraphicsBackend::ImageLevel &source,
	GraphicsBackend::ImageLevel &layers, std::string &error)
{
	int size = 0;
	int count = 0;
	const bool horizontal = source.width % source.height == 0;
	if (horizontal) { size = source.height; count = source.width / source.height; }
	else if (source.height % source.width == 0) { size = source.width; count = source.height / source.width; }
	else
	{
		error = "Cannot extract volume layers from source ImageData.";
		return false;
	}
	layers = {};
	layers.width = layers.height = size;
	layers.slices = count;
	layers.rgba8.reserve(static_cast<std::size_t>(size) * size * count * 4);
	for (int slice = 0; slice < count; ++slice)
	{
		auto layer = extractImageRegion(source, horizontal ? slice * size : 0,
			horizontal ? 0 : slice * size, size, size);
		layers.rgba8.insert(layers.rgba8.end(), layer.rgba8.begin(), layer.rgba8.end());
	}
	error.clear();
	return true;
}

bool decodeUtf8(std::string_view text, std::vector<std::uint32_t> &codepoints,
	std::string &error)
{
	codepoints.clear();
	for (std::size_t offset = 0; offset < text.size();)
	{
		const auto first = static_cast<std::uint8_t>(text[offset]);
		std::size_t length = 0;
		std::uint32_t codepoint = 0;
		if (first < 0x80) { length = 1; codepoint = first; }
		else if ((first & 0xe0) == 0xc0) { length = 2; codepoint = first & 0x1f; }
		else if ((first & 0xf0) == 0xe0) { length = 3; codepoint = first & 0x0f; }
		else if ((first & 0xf8) == 0xf0) { length = 4; codepoint = first & 0x07; }
		else { error = "invalid UTF-8 leading byte"; return false; }
		if (offset + length > text.size()) { error = "truncated UTF-8 sequence"; return false; }
		for (std::size_t index = 1; index < length; ++index)
		{
			const auto byte = static_cast<std::uint8_t>(text[offset + index]);
			if ((byte & 0xc0) != 0x80) { error = "invalid UTF-8 continuation byte"; return false; }
			codepoint = (codepoint << 6) | (byte & 0x3f);
		}
		const std::uint32_t minimum = length == 1 ? 0 : length == 2 ? 0x80 : length == 3 ? 0x800 : 0x10000;
		if (codepoint < minimum || codepoint > 0x10ffff
			|| (codepoint >= 0xd800 && codepoint <= 0xdfff))
		{
			error = "invalid or overlong UTF-8 codepoint";
			return false;
		}
		codepoints.push_back(codepoint);
		offset += length;
	}
	error.clear();
	return true;
}

std::string encodeUtf8(std::uint32_t codepoint)
{
	std::string result;
	if (codepoint <= 0x7f)
		result.push_back(static_cast<char>(codepoint));
	else if (codepoint <= 0x7ff)
	{
		result.push_back(static_cast<char>(0xc0 | (codepoint >> 6)));
		result.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
	}
	else if (codepoint <= 0xffff)
	{
		result.push_back(static_cast<char>(0xe0 | (codepoint >> 12)));
		result.push_back(static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
		result.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
	}
	else
	{
		result.push_back(static_cast<char>(0xf0 | (codepoint >> 18)));
		result.push_back(static_cast<char>(0x80 | ((codepoint >> 12) & 0x3f)));
		result.push_back(static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
		result.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
	}
	return result;
}

std::uint32_t checkGlyphCodepoint(lua_State *state, int index)
{
	if (lua_type(state, index) == LUA_TSTRING)
	{
		size_t length = 0;
		const char *text = lua_tolstring(state, index, &length);
		std::vector<std::uint32_t> codepoints;
		std::string error;
		if (!decodeUtf8(std::string_view(text, length), codepoints, error) || codepoints.empty())
			luaL_argerror(state, index, error.empty() ? "expected a non-empty UTF-8 string" : error.c_str());
		return codepoints.front();
	}
	const lua_Number value = luaL_checknumber(state, index);
	if (!std::isfinite(value) || value < 0.0 || value > 0x10ffff
		|| (value >= 0xd800 && value <= 0xdfff))
		luaL_argerror(state, index, "glyph codepoint must be a valid Unicode value");
	return static_cast<std::uint32_t>(value);
}

double steadySeconds()
{
	return std::chrono::duration<double>(std::chrono::steady_clock::now().time_since_epoch()).count();
}

enum class ImagePixelFormat
{
	R8, RG8, RGBA8, R16, RG16, RGBA16, R16F, RG16F, RGBA16F,
	R32F, RG32F, RGBA32F, RGBA4, RGB5A1, RGB565, RGB10A2, RG11B10F,
};

struct ImagePixelFormatInfo
{
	ImagePixelFormat value;
	const char *name;
	std::size_t bytes;
};

const ImagePixelFormatInfo *imagePixelFormatInfo(std::string_view format)
{
	static constexpr ImagePixelFormatInfo formats[] = {
		{ImagePixelFormat::R8, "r8", 1}, {ImagePixelFormat::RG8, "rg8", 2},
		{ImagePixelFormat::RGBA8, "rgba8", 4}, {ImagePixelFormat::R16, "r16", 2},
		{ImagePixelFormat::RG16, "rg16", 4}, {ImagePixelFormat::RGBA16, "rgba16", 8},
		{ImagePixelFormat::R16F, "r16f", 2}, {ImagePixelFormat::RG16F, "rg16f", 4},
		{ImagePixelFormat::RGBA16F, "rgba16f", 8}, {ImagePixelFormat::R32F, "r32f", 4},
		{ImagePixelFormat::RG32F, "rg32f", 8}, {ImagePixelFormat::RGBA32F, "rgba32f", 16},
		{ImagePixelFormat::RGBA4, "rgba4", 2}, {ImagePixelFormat::RGB5A1, "rgb5a1", 2},
		{ImagePixelFormat::RGB565, "rgb565", 2}, {ImagePixelFormat::RGB10A2, "rgb10a2", 4},
		{ImagePixelFormat::RG11B10F, "rg11b10f", 4},
	};
	const auto found = std::find_if(std::begin(formats), std::end(formats),
		[format](const auto &entry) { return format == entry.name; });
	return found == std::end(formats) ? nullptr : found;
}

struct ImagePixelColor
{
	float red = 0.0f;
	float green = 0.0f;
	float blue = 0.0f;
	float alpha = 1.0f;
};

template <class T> T loadPixelValue(const std::uint8_t *bytes)
{
	T value{};
	std::memcpy(&value, bytes, sizeof(value));
	return value;
}

template <class T> void storePixelValue(std::uint8_t *bytes, T value)
{
	std::memcpy(bytes, &value, sizeof(value));
}

float clampPixel(float value)
{
	return std::clamp(value, 0.0f, 1.0f);
}

void initializeLoveFloatFormats()
{
	static const bool initialized = []() {
		::love::float16Init();
		return true;
	}();
	(void)initialized;
}

bool readImagePixel(const ImagePixelFormatInfo &format, const std::uint8_t *bytes,
	ImagePixelColor &color)
{
	initializeLoveFloatFormats();
	color = {};
	switch (format.value)
	{
		case ImagePixelFormat::R8:
			color.red = bytes[0] / 255.0f; break;
		case ImagePixelFormat::RG8:
			color.red = bytes[0] / 255.0f; color.green = bytes[1] / 255.0f; break;
		case ImagePixelFormat::RGBA8:
			color.red = bytes[0] / 255.0f; color.green = bytes[1] / 255.0f;
			color.blue = bytes[2] / 255.0f; color.alpha = bytes[3] / 255.0f; break;
		case ImagePixelFormat::R16:
			color.red = loadPixelValue<std::uint16_t>(bytes) / 65535.0f; break;
		case ImagePixelFormat::RG16:
			color.red = loadPixelValue<std::uint16_t>(bytes) / 65535.0f;
			color.green = loadPixelValue<std::uint16_t>(bytes + 2) / 65535.0f; break;
		case ImagePixelFormat::RGBA16:
			color.red = loadPixelValue<std::uint16_t>(bytes) / 65535.0f;
			color.green = loadPixelValue<std::uint16_t>(bytes + 2) / 65535.0f;
			color.blue = loadPixelValue<std::uint16_t>(bytes + 4) / 65535.0f;
			color.alpha = loadPixelValue<std::uint16_t>(bytes + 6) / 65535.0f; break;
		case ImagePixelFormat::R16F:
			color.red = ::love::float16to32(loadPixelValue<::love::float16>(bytes)); break;
		case ImagePixelFormat::RG16F:
			color.red = ::love::float16to32(loadPixelValue<::love::float16>(bytes));
			color.green = ::love::float16to32(loadPixelValue<::love::float16>(bytes + 2)); break;
		case ImagePixelFormat::RGBA16F:
			color.red = ::love::float16to32(loadPixelValue<::love::float16>(bytes));
			color.green = ::love::float16to32(loadPixelValue<::love::float16>(bytes + 2));
			color.blue = ::love::float16to32(loadPixelValue<::love::float16>(bytes + 4));
			color.alpha = ::love::float16to32(loadPixelValue<::love::float16>(bytes + 6)); break;
		case ImagePixelFormat::R32F:
			color.red = loadPixelValue<float>(bytes); break;
		case ImagePixelFormat::RG32F:
			color.red = loadPixelValue<float>(bytes); color.green = loadPixelValue<float>(bytes + 4); break;
		case ImagePixelFormat::RGBA32F:
			color.red = loadPixelValue<float>(bytes); color.green = loadPixelValue<float>(bytes + 4);
			color.blue = loadPixelValue<float>(bytes + 8); color.alpha = loadPixelValue<float>(bytes + 12); break;
		case ImagePixelFormat::RGBA4:
		{
			const auto value = loadPixelValue<std::uint16_t>(bytes);
			color.red = ((value >> 12) & 0xf) / 15.0f; color.green = ((value >> 8) & 0xf) / 15.0f;
			color.blue = ((value >> 4) & 0xf) / 15.0f; color.alpha = (value & 0xf) / 15.0f; break;
		}
		case ImagePixelFormat::RGB5A1:
		{
			const auto value = loadPixelValue<std::uint16_t>(bytes);
			color.red = ((value >> 11) & 0x1f) / 31.0f; color.green = ((value >> 6) & 0x1f) / 31.0f;
			color.blue = ((value >> 1) & 0x1f) / 31.0f; color.alpha = value & 1; break;
		}
		case ImagePixelFormat::RGB565:
		{
			const auto value = loadPixelValue<std::uint16_t>(bytes);
			color.red = ((value >> 11) & 0x1f) / 31.0f; color.green = ((value >> 5) & 0x3f) / 63.0f;
			color.blue = (value & 0x1f) / 31.0f; break;
		}
		case ImagePixelFormat::RGB10A2:
		{
			const auto value = loadPixelValue<std::uint32_t>(bytes);
			color.red = (value & 0x3ff) / 1023.0f; color.green = ((value >> 10) & 0x3ff) / 1023.0f;
			color.blue = ((value >> 20) & 0x3ff) / 1023.0f; color.alpha = ((value >> 30) & 3) / 3.0f; break;
		}
		case ImagePixelFormat::RG11B10F:
		{
			const auto value = loadPixelValue<std::uint32_t>(bytes);
			color.red = ::love::float11to32(static_cast<::love::float11>(value & 0x7ff));
			color.green = ::love::float11to32(static_cast<::love::float11>((value >> 11) & 0x7ff));
			color.blue = ::love::float10to32(static_cast<::love::float10>((value >> 22) & 0x3ff)); break;
		}
	}
	return true;
}

bool writeImagePixel(const ImagePixelFormatInfo &format, std::uint8_t *bytes,
	const ImagePixelColor &color)
{
	initializeLoveFloatFormats();
	auto normalized = [](float value, float maximum) {
		return static_cast<std::uint32_t>(clampPixel(value) * maximum + 0.5f);
	};
	switch (format.value)
	{
		case ImagePixelFormat::R8: bytes[0] = static_cast<std::uint8_t>(normalized(color.red, 255)); break;
		case ImagePixelFormat::RG8:
			bytes[0] = static_cast<std::uint8_t>(normalized(color.red, 255));
			bytes[1] = static_cast<std::uint8_t>(normalized(color.green, 255)); break;
		case ImagePixelFormat::RGBA8:
			bytes[0] = static_cast<std::uint8_t>(normalized(color.red, 255));
			bytes[1] = static_cast<std::uint8_t>(normalized(color.green, 255));
			bytes[2] = static_cast<std::uint8_t>(normalized(color.blue, 255));
			bytes[3] = static_cast<std::uint8_t>(normalized(color.alpha, 255)); break;
		case ImagePixelFormat::R16:
			storePixelValue(bytes, static_cast<std::uint16_t>(normalized(color.red, 65535))); break;
		case ImagePixelFormat::RG16:
			storePixelValue(bytes, static_cast<std::uint16_t>(normalized(color.red, 65535)));
			storePixelValue(bytes + 2, static_cast<std::uint16_t>(normalized(color.green, 65535))); break;
		case ImagePixelFormat::RGBA16:
			storePixelValue(bytes, static_cast<std::uint16_t>(normalized(color.red, 65535)));
			storePixelValue(bytes + 2, static_cast<std::uint16_t>(normalized(color.blue, 65535)));
			storePixelValue(bytes + 4, static_cast<std::uint16_t>(normalized(color.green, 65535)));
			storePixelValue(bytes + 6, static_cast<std::uint16_t>(normalized(color.alpha, 65535))); break;
		case ImagePixelFormat::R16F:
			storePixelValue(bytes, ::love::float32to16(color.red)); break;
		case ImagePixelFormat::RG16F:
			storePixelValue(bytes, ::love::float32to16(color.red));
			storePixelValue(bytes + 2, ::love::float32to16(color.green)); break;
		case ImagePixelFormat::RGBA16F:
			storePixelValue(bytes, ::love::float32to16(color.red));
			storePixelValue(bytes + 2, ::love::float32to16(color.green));
			storePixelValue(bytes + 4, ::love::float32to16(color.blue));
			storePixelValue(bytes + 6, ::love::float32to16(color.alpha)); break;
		case ImagePixelFormat::R32F: storePixelValue(bytes, color.red); break;
		case ImagePixelFormat::RG32F:
			storePixelValue(bytes, color.red); storePixelValue(bytes + 4, color.green); break;
		case ImagePixelFormat::RGBA32F:
			storePixelValue(bytes, color.red); storePixelValue(bytes + 4, color.green);
			storePixelValue(bytes + 8, color.blue); storePixelValue(bytes + 12, color.alpha); break;
		case ImagePixelFormat::RGBA4:
			storePixelValue(bytes, static_cast<std::uint16_t>((normalized(color.red, 15) << 12)
				| (normalized(color.green, 15) << 8) | (normalized(color.blue, 15) << 4)
				| normalized(color.alpha, 15))); break;
		case ImagePixelFormat::RGB5A1:
			storePixelValue(bytes, static_cast<std::uint16_t>((normalized(color.red, 31) << 11)
				| (normalized(color.green, 31) << 6) | (normalized(color.blue, 31) << 1)
				| normalized(color.alpha, 1))); break;
		case ImagePixelFormat::RGB565:
			storePixelValue(bytes, static_cast<std::uint16_t>((normalized(color.red, 31) << 11)
				| (normalized(color.green, 63) << 5) | normalized(color.blue, 31))); break;
		case ImagePixelFormat::RGB10A2:
			storePixelValue(bytes, normalized(color.red, 1023) | (normalized(color.green, 1023) << 10)
				| (normalized(color.blue, 1023) << 20) | (normalized(color.alpha, 3) << 30)); break;
		case ImagePixelFormat::RG11B10F:
			storePixelValue(bytes, static_cast<std::uint32_t>(::love::float32to11(color.red))
				| (static_cast<std::uint32_t>(::love::float32to11(color.green)) << 11)
				| (static_cast<std::uint32_t>(::love::float32to10(color.blue)) << 22)); break;
	}
	return true;
}

::love::Type LoveDrawableType("Drawable", &::love::Object::type);
::love::Type LoveTextureType("Texture", &LoveDrawableType);

template <class Handle, void (LoveRuntime::*Retain)(Handle) noexcept,
	void (LoveRuntime::*Release)(Handle) noexcept,
	void (LoveRuntime::*Forget)(Handle) noexcept>
struct DoraHandleObject : ::love::Object
{
	DoraHandleObject() = default;
	DoraHandleObject(LoveRuntime *valueRuntime, Handle valueHandle)
		: runtime(valueRuntime)
	{
		adoptDoraHandle(valueHandle);
	}
	~DoraHandleObject() override { releaseDoraHandle(); }

	DoraHandleObject(const DoraHandleObject &) = delete;
	DoraHandleObject &operator=(const DoraHandleObject &) = delete;

	void releaseDoraHandle() noexcept
	{
		if (runtime && handle != Handle{})
		{
			const auto value = handle;
			handle = Handle{};
			(runtime->*Release)(value);
		}
	}

	void invalidateDoraHandle() noexcept
	{
		if (runtime && handle != Handle{})
			(runtime->*Forget)(handle);
		handle = Handle{};
	}

	void adoptDoraHandle(Handle valueHandle) noexcept
	{
		handle = valueHandle;
		if (runtime && handle != Handle{})
			(runtime->*Retain)(handle);
	}

	void replaceDoraHandle(Handle valueHandle) noexcept
	{
		releaseDoraHandle();
		adoptDoraHandle(valueHandle);
	}

	LoveRuntime *runtime = nullptr;
	Handle handle{};
};

template <class Object>
void pushNewDoraHandleObject(lua_State *state, ::love::Type &type, Object *object)
{
	static_assert(std::is_base_of_v<::love::Object, Object>);
	::love::luax_pushtype(state, type, object);
	// A freshly constructed Love Object owns one native reference and the Proxy
	// retained another one above. Hand the constructor reference to the Proxy so
	// release()/__gc can actually destroy the wrapper and its Dora handle.
	object->release();
}

struct ImageUserdata final
	: DoraHandleObject<GraphicsBackend::ImageHandle, &LoveRuntime::retainLoveImageHandle,
		&LoveRuntime::releaseLoveImage, &LoveRuntime::forgetLoveImageHandle>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::ImageHandle,
		&LoveRuntime::retainLoveImageHandle, &LoveRuntime::releaseLoveImage,
		&LoveRuntime::forgetLoveImageHandle>;
	static ::love::Type type;
	ImageUserdata(LoveRuntime *valueRuntime, GraphicsBackend::ImageHandle valueHandle,
		GraphicsBackend::TextureType valueType, int valueSlices)
		: DoraHandle(valueRuntime, valueHandle), textureType(valueType), slices(valueSlices) { }
	GraphicsBackend::TextureType textureType = GraphicsBackend::TextureType::Texture2D;
	int slices = 1;
	GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
	GraphicsBackend::TextureFilter magFilter = GraphicsBackend::TextureFilter::Linear;
	GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
	GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
	GraphicsBackend::TextureWrap wrapW = GraphicsBackend::TextureWrap::Clamp;
	float anisotropy = 1.0f;
	int mipmapCount = 1;
	float dpiScale = 1.0f;
	std::string format = "rgba8";
	bool readable = true;
	bool compressed = false;
	bool linear = true;
	std::optional<GraphicsBackend::TextureFilter> mipmapFilter;
	float mipmapSharpness = 0.0f;
	std::optional<std::string> depthSampleMode;
};

::love::Type ImageUserdata::type("Image", &LoveTextureType);

ImageUserdata *testImage(lua_State *state, int index)
{
	if (luaL_testudata(state, index, ImageUserdata::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<ImageUserdata>(state, index);
}

struct CanvasUserdata final
	: DoraHandleObject<GraphicsBackend::CanvasHandle, &LoveRuntime::retainLoveCanvasHandle,
		&LoveRuntime::releaseLoveCanvas, &LoveRuntime::forgetLoveCanvasHandle>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::CanvasHandle,
		&LoveRuntime::retainLoveCanvasHandle, &LoveRuntime::releaseLoveCanvas,
		&LoveRuntime::forgetLoveCanvasHandle>;
	static ::love::Type type;
	CanvasUserdata(LoveRuntime *valueRuntime, GraphicsBackend::CanvasHandle valueHandle,
		const char *valueFormat, int valueMSAA, bool valueReadable)
		: DoraHandle(valueRuntime, valueHandle), format(valueFormat), msaa(valueMSAA), readable(valueReadable) { }
	const char *format = "rgba8";
	int msaa = 0;
	bool readable = true;
	GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
	GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
	GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
	GraphicsBackend::TextureWrap wrapW = GraphicsBackend::TextureWrap::Clamp;
	float anisotropy = 1.0f;
	GraphicsBackend::TextureType textureType = GraphicsBackend::TextureType::Texture2D;
	int slices = 1;
	int mipmapCount = 1;
	float dpiScale = 1.0f;
	std::string mipmapMode = "none";
	std::optional<GraphicsBackend::TextureFilter> mipmapFilter;
	float mipmapSharpness = 0.0f;
	std::optional<std::string> depthSampleMode;
};

::love::Type CanvasUserdata::type("Canvas", &LoveTextureType);

CanvasUserdata *testCanvas(lua_State *state, int index)
{
	if (luaL_testudata(state, index, CanvasUserdata::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<CanvasUserdata>(state, index);
}

bool isDepthStencilCanvasFormat(std::string_view format)
{
	return format == "stencil8" || format == "depth16" || format == "depth24"
		|| format == "depth32f" || format == "depth24stencil8"
		|| format == "depth32fstencil8";
}

bool canvasFormatHasDepth(std::string_view format)
{
	return format != "stencil8" && isDepthStencilCanvasFormat(format);
}

bool canvasFormatHasStencil(std::string_view format)
{
	return format == "stencil8" || format == "depth24stencil8"
		|| format == "depth32fstencil8";
}

struct LoveDataObject : ::love::Object
{
	static ::love::Type type;
	virtual DataSpan dataSpan() const noexcept = 0;
};

::love::Type LoveDataObject::type("Data", &::love::Object::type);

struct ImageDataUserdata final : LoveDataObject
{
	static ::love::Type type;
	ImageDataUserdata() = default;
	ImageDataUserdata(LoveRuntime *valueRuntime, int valueWidth, int valueHeight,
		const char *valueFormat, std::vector<std::uint8_t> valuePixels)
		: runtime(valueRuntime), width(valueWidth), height(valueHeight), format(valueFormat),
		  pixels(std::move(valuePixels)) { }
	DataSpan dataSpan() const noexcept override { return {pixels.data(), pixels.size()}; }
	LoveRuntime *runtime = nullptr;
	int width = 0;
	int height = 0;
	const char *format = "rgba8";
	std::vector<std::uint8_t> pixels;
};

::love::Type ImageDataUserdata::type("ImageData", &LoveDataObject::type);

ImageDataUserdata *testImageData(lua_State *state, int index)
{
	if (luaL_testudata(state, index, ImageDataUserdata::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<ImageDataUserdata>(state, index);
}

bool getThreadImageData(lua_State *state, int index, ThreadValue &value)
{
	auto *data = testImageData(state, index);
	if (!data) return false;
	value.type = ThreadValue::Type::ImageData;
	value.width = data->width;
	value.height = data->height;
	value.format = data->format;
	value.data = data->pixels;
	return true;
}

struct CursorUserdata final
	: DoraHandleObject<MouseBackend::CursorHandle, &LoveRuntime::retainLoveCursorHandle,
		&LoveRuntime::releaseLoveCursor, &LoveRuntime::forgetLoveCursorHandle>
{
	using DoraHandle = DoraHandleObject<MouseBackend::CursorHandle,
		&LoveRuntime::retainLoveCursorHandle, &LoveRuntime::releaseLoveCursor,
		&LoveRuntime::forgetLoveCursorHandle>;
	static ::love::Type type;
	CursorUserdata(LoveRuntime *valueRuntime, MouseBackend::CursorHandle valueHandle,
		std::string valueType) : DoraHandle(valueRuntime, valueHandle), cursorType(std::move(valueType)) { }
	std::string cursorType;
};

::love::Type CursorUserdata::type("Cursor", &::love::Object::type);

struct CompressedImageDataUserdata final : LoveDataObject
{
	static ::love::Type type;
	CompressedImageDataUserdata(ImageBackend::CompressedImage valueImage,
		std::vector<std::uint8_t> valueBytes)
		: image(std::move(valueImage)), bytes(std::move(valueBytes)) { }
	DataSpan dataSpan() const noexcept override { return {bytes.data(), bytes.size()}; }
	ImageBackend::CompressedImage image;
	std::vector<std::uint8_t> bytes;
};

::love::Type CompressedImageDataUserdata::type("CompressedImageData", &LoveDataObject::type);

CompressedImageDataUserdata *testCompressedImageData(lua_State *state, int index)
{
	if (luaL_testudata(state, index, CompressedImageDataUserdata::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<CompressedImageDataUserdata>(state, index);
}

struct ImageRasterizerGlyph
{
	std::uint32_t codepoint = 0;
	int x = 0;
	int width = 0;
};

struct BMFontGlyph
{
	std::uint32_t codepoint = 0;
	int x = 0;
	int y = 0;
	int page = 0;
	int width = 0;
	int height = 0;
	int advance = 0;
	int bearingX = 0;
	int bearingY = 0;
};

::love::Type RasterizerLoveType("Rasterizer", &::love::Object::type);

struct RasterizerUserdata final : ::love::Object
{
	~RasterizerUserdata() override = default;
	enum class Kind { Image, TrueType, BMFont } kind = Kind::Image;
	LoveRuntime *runtime = nullptr;
	int height = 0;
	int advance = 0;
	int ascent = 0;
	int descent = 0;
	int lineHeight = 0;
	int extraSpacing = 0;
	float dpiScale = 1.0f;
	float fontScale = 1.0f;
	bool monochrome = false;
	std::array<std::uint8_t, 4> spacer{};
	std::vector<::love::StrongRef<LoveDataObject>> sourceObjects;
	std::vector<std::uint32_t> glyphs;
	std::vector<ImageRasterizerGlyph> imageGlyphs;
	std::vector<std::uint8_t> fontBytes;
	stbtt_fontinfo fontInfo{};
	std::unordered_map<std::uint32_t, BMFontGlyph> bmGlyphs;
};

struct GlyphDataUserdata final : LoveDataObject
{
	static ::love::Type type;
	GlyphDataUserdata() = default;
	GlyphDataUserdata(const GlyphDataUserdata &other)
		: LoveDataObject(other), glyph(other.glyph), width(other.width), height(other.height),
		  advance(other.advance), bearingX(other.bearingX), bearingY(other.bearingY),
		  pixelSize(other.pixelSize), format(other.format), pixels(other.pixels) { }
	GlyphDataUserdata(GlyphDataUserdata &&other) noexcept
		: LoveDataObject(other), glyph(other.glyph), width(other.width), height(other.height),
		  advance(other.advance), bearingX(other.bearingX), bearingY(other.bearingY),
		  pixelSize(other.pixelSize), format(other.format), pixels(std::move(other.pixels)) { }
	DataSpan dataSpan() const noexcept override { return {pixels.data(), pixels.size()}; }
	std::uint32_t glyph = 0;
	int width = 0;
	int height = 0;
	int advance = 0;
	int bearingX = 0;
	int bearingY = 0;
	int pixelSize = 4;
	const char *format = "rgba8";
	std::vector<std::uint8_t> pixels;
};

::love::Type GlyphDataUserdata::type("GlyphData", &LoveDataObject::type);

struct SoundDataUserdata final : LoveDataObject
{
	static ::love::Type type;
	SoundDataUserdata(int valueSampleRate, int valueBitDepth, int valueChannels,
		int valueSampleCount, std::vector<std::uint8_t> valueSamples)
		: sampleRate(valueSampleRate), bitDepth(valueBitDepth), channels(valueChannels),
		  sampleCount(valueSampleCount), samples(std::move(valueSamples)) { }
	DataSpan dataSpan() const noexcept override { return {samples.data(), samples.size()}; }
	int sampleRate = 0;
	int bitDepth = 0;
	int channels = 0;
	int sampleCount = 0;
	std::vector<std::uint8_t> samples;
};

::love::Type SoundDataUserdata::type("SoundData", &LoveDataObject::type);

SoundDataUserdata *testSoundData(lua_State *state, int index)
{
	if (luaL_testudata(state, index, SoundDataUserdata::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<SoundDataUserdata>(state, index);
}

::love::Type DecoderLoveType("Decoder", &::love::Object::type);

struct DecoderUserdata final : ::love::Object
{
	~DecoderUserdata() override = default;
	int sampleRate = 0;
	int bitDepth = 16;
	int channels = 0;
	int sampleCount = 0;
	std::size_t bufferSize = 16384;
	std::size_t bytePosition = 0;
	std::vector<std::uint8_t> samples;
};

::love::Type RandomGeneratorLoveType("RandomGenerator", &::love::Object::type);

struct RandomGeneratorUserdata final : ::love::Object
{
	~RandomGeneratorUserdata() override = default;
	std::uint64_t seed = 0;
	std::uint64_t state = 0;
	double cachedNormal = std::numeric_limits<double>::infinity();
};

struct MathPoint
{
	double x = 0.0;
	double y = 0.0;
};

struct MathTriangle
{
	MathPoint a;
	MathPoint b;
	MathPoint c;
};

::love::Type TransformLoveType("Transform", &::love::Object::type);

struct TransformUserdata final : ::love::Object
{
	TransformUserdata() = default;
	TransformUserdata(const TransformUserdata &other) : ::love::Object(other)
	{
		std::copy(std::begin(other.elements), std::end(other.elements), std::begin(elements));
	}
	TransformUserdata &operator=(const TransformUserdata &other)
	{
		if (this != &other)
			std::copy(std::begin(other.elements), std::end(other.elements), std::begin(elements));
		return *this;
	}
	~TransformUserdata() override = default;
	float elements[16]{};
};

::love::Type BezierCurveLoveType("BezierCurve", &::love::Object::type);

struct BezierCurveUserdata final : ::love::Object
{
	~BezierCurveUserdata() override = default;
	std::vector<MathPoint> controlPoints;
};

struct ByteDataUserdata final : LoveDataObject
{
	static ::love::Type type;
	explicit ByteDataUserdata(std::vector<std::uint8_t> value)
		: bytes(std::move(value)) { }
	DataSpan dataSpan() const noexcept override { return {bytes.data(), bytes.size()}; }
	std::vector<std::uint8_t> bytes;
};

::love::Type ByteDataUserdata::type("ByteData", &LoveDataObject::type);

struct DataViewUserdata final : LoveDataObject
{
	static ::love::Type type;
	DataViewUserdata(LoveDataObject *value, std::size_t valueOffset, std::size_t valueSize)
		: parent(value), offset(valueOffset), size(valueSize) { }
	DataSpan dataSpan() const noexcept override
	{
		const auto source = parent->dataSpan();
		return {source.bytes + offset, size};
	}
	::love::StrongRef<LoveDataObject> parent;
	std::size_t offset = 0;
	std::size_t size = 0;
};

struct CompressedDataUserdata final : LoveDataObject
{
	static ::love::Type type;
	CompressedDataUserdata(std::string valueFormat, std::size_t valueDecompressedSize,
		std::vector<std::uint8_t> valueBytes)
		: format(std::move(valueFormat)), decompressedSize(valueDecompressedSize), bytes(std::move(valueBytes)) { }
	DataSpan dataSpan() const noexcept override { return {bytes.data(), bytes.size()}; }
	std::string format;
	std::size_t decompressedSize = 0;
	std::vector<std::uint8_t> bytes;
};

::love::Type DataViewUserdata::type("DataView", &LoveDataObject::type);
::love::Type CompressedDataUserdata::type("CompressedData", &LoveDataObject::type);

struct FontUserdata final
	: DoraHandleObject<GraphicsBackend::FontHandle, &LoveRuntime::retainLoveFontHandle,
		&LoveRuntime::releaseLoveFont, &LoveRuntime::forgetLoveFontHandle>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::FontHandle,
		&LoveRuntime::retainLoveFontHandle, &LoveRuntime::releaseLoveFont,
		&LoveRuntime::forgetLoveFontHandle>;
	static ::love::Type type;
	FontUserdata(LoveRuntime *valueRuntime, GraphicsBackend::FontHandle valueHandle)
		: DoraHandle(valueRuntime, valueHandle) { }
	GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
	float anisotropy = 1.0f;
	float dpiScale = 1.0f;
	std::vector<::love::StrongRef<::love::Object>> fallbackObjects;
};

::love::Type FontUserdata::type("Font", &::love::Object::type);

::love::Type QuadLoveType("Quad", &::love::Object::type);

struct QuadUserdata final : ::love::Object
{
	~QuadUserdata() override = default;
	LoveRuntime *runtime = nullptr;
	float x = 0.0f;
	float y = 0.0f;
	float width = 0.0f;
	float height = 0.0f;
	float textureWidth = 0.0f;
	float textureHeight = 0.0f;
	int layer = 1;
};

struct MeshAttribute
{
	std::string name;
	std::string type;
	int components = 0;
	std::size_t offset = 0;
	std::size_t byteOffset = 0;
	std::size_t byteSize = 0;
	bool enabled = true;
};

struct MeshUserdata;

struct MeshAttachment
{
	MeshUserdata *mesh = nullptr;
	std::size_t attributeIndex = 0;
	std::string step = "pervertex";
	bool enabled = true;
};

::love::Type MeshLoveType("Mesh", &LoveDrawableType);

struct MeshUserdata final : ::love::Object
{
	~MeshUserdata() override = default;
	LoveRuntime *runtime = nullptr;
	std::vector<MeshAttribute> format;
	std::vector<float> values;
	std::vector<std::uint8_t> bytes;
	std::vector<std::uint32_t> vertexMap;
	bool useVertexMap = false;
	std::unordered_map<std::string, MeshAttachment> attachments;
	std::unordered_map<std::string, ::love::StrongRef<::love::Object>> attachmentObjects;
	std::size_t vertexCount = 0;
	std::size_t componentCount = 0;
	std::size_t vertexStride = 0;
	std::string drawMode = "fan";
	std::string usage = "dynamic";
	int drawStart = -1;
	int drawCount = 0;
	GraphicsBackend::ImageHandle image = 0;
	GraphicsBackend::CanvasHandle canvas = 0;
	::love::StrongRef<::love::Object> textureObject;
};

struct SpriteBatchSprite
{
	GraphicsBackend::MeshVertex vertices[4];
};

struct SpriteBatchAttachment
{
	MeshUserdata *mesh = nullptr;
	std::size_t attributeIndex = 0;
};

::love::Type SpriteBatchLoveType("SpriteBatch", &LoveDrawableType);

struct SpriteBatchUserdata final : ::love::Object
{
	~SpriteBatchUserdata() override = default;
	LoveRuntime *runtime = nullptr;
	GraphicsBackend::ImageHandle image = 0;
	GraphicsBackend::CanvasHandle canvas = 0;
	::love::StrongRef<::love::Object> textureObject;
	GraphicsBackend::TextureType textureType = GraphicsBackend::TextureType::Texture2D;
	int layerCount = 1;
	std::vector<SpriteBatchSprite> sprites;
	std::size_t count = 0;
	std::size_t bufferSize = 0;
	bool colorEnabled = false;
	float color[4]{1.0f, 1.0f, 1.0f, 1.0f};
	int drawStart = -1;
	int drawCount = 0;
	std::string usage = "dynamic";
	std::unordered_map<std::string, SpriteBatchAttachment> attachments;
	std::unordered_map<std::string, ::love::StrongRef<::love::Object>> attachmentObjects;
};

struct ParticleColor
{
	float red = 1.0f;
	float green = 1.0f;
	float blue = 1.0f;
	float alpha = 1.0f;
};

struct ParticleQuad
{
	float x = 0.0f;
	float y = 0.0f;
	float width = 0.0f;
	float height = 0.0f;
	float textureWidth = 0.0f;
	float textureHeight = 0.0f;
};

struct ParticleState
{
	float lifetime = 0.0f;
	float life = 0.0f;
	float x = 0.0f;
	float y = 0.0f;
	float originX = 0.0f;
	float originY = 0.0f;
	float velocityX = 0.0f;
	float velocityY = 0.0f;
	float accelerationX = 0.0f;
	float accelerationY = 0.0f;
	float radialAcceleration = 0.0f;
	float tangentialAcceleration = 0.0f;
	float linearDamping = 0.0f;
	float size = 1.0f;
	float sizeOffset = 0.0f;
	float sizeInterval = 1.0f;
	float rotation = 0.0f;
	float angle = 0.0f;
	float spinStart = 0.0f;
	float spinEnd = 0.0f;
	ParticleColor color;
	std::size_t quadIndex = 0;
};

::love::Type ParticleSystemLoveType("ParticleSystem", &LoveDrawableType);

struct ParticleSystemUserdata final : ::love::Object
{
	~ParticleSystemUserdata() override = default;
	LoveRuntime *runtime = nullptr;
	GraphicsBackend::ImageHandle image = 0;
	GraphicsBackend::CanvasHandle canvas = 0;
	::love::StrongRef<::love::Object> textureObject;
	std::vector<ParticleState> particles;
	std::vector<float> sizes{1.0f};
	std::vector<ParticleColor> colors{{}};
	std::vector<ParticleQuad> quads;
	std::vector<::love::StrongRef<::love::Object>> quadObjects;
	std::size_t bufferSize = 1000;
	bool active = true;
	std::string insertMode = "top";
	float emissionRate = 0.0f;
	float emitCounter = 0.0f;
	float positionX = 0.0f;
	float positionY = 0.0f;
	float previousX = 0.0f;
	float previousY = 0.0f;
	std::string emissionDistribution = "none";
	float emissionX = 0.0f;
	float emissionY = 0.0f;
	float emissionAngle = 0.0f;
	bool directionRelativeToCenter = false;
	float emitterLifetime = -1.0f;
	float emitterLife = 0.0f;
	float particleLifetimeMin = 0.0f;
	float particleLifetimeMax = 0.0f;
	float direction = 0.0f;
	float spread = 0.0f;
	float speedMin = 0.0f;
	float speedMax = 0.0f;
	float accelerationMinX = 0.0f;
	float accelerationMinY = 0.0f;
	float accelerationMaxX = 0.0f;
	float accelerationMaxY = 0.0f;
	float radialMin = 0.0f;
	float radialMax = 0.0f;
	float tangentialMin = 0.0f;
	float tangentialMax = 0.0f;
	float dampingMin = 0.0f;
	float dampingMax = 0.0f;
	float sizeVariation = 0.0f;
	float rotationMin = 0.0f;
	float rotationMax = 0.0f;
	float spinStart = 0.0f;
	float spinEnd = 0.0f;
	float spinVariation = 0.0f;
	float offsetX = 0.0f;
	float offsetY = 0.0f;
	bool defaultOffset = true;
	bool relativeRotation = false;
	std::uint64_t randomState = 0x853c49e6748fea9bULL;
};

struct TextFragment
{
	std::string text;
	float color[4]{1.0f, 1.0f, 1.0f, 1.0f};
};

struct TextLayoutRun
{
	std::string text;
	float x = 0.0f;
	float y = 0.0f;
	float color[4]{1.0f, 1.0f, 1.0f, 1.0f};
};

struct TextEntry
{
	std::vector<TextFragment> fragments;
	std::vector<TextLayoutRun> runs;
	TransformUserdata transform;
	float wrap = -1.0f;
	std::string align = "left";
	float width = 0.0f;
	float height = 0.0f;
};

::love::Type TextLoveType("Text", &LoveDrawableType);

struct TextUserdata final : ::love::Object
{
	~TextUserdata() override = default;
	LoveRuntime *runtime = nullptr;
	GraphicsBackend::FontHandle font = 0;
	::love::StrongRef<::love::Object> fontObject;
	std::vector<TextEntry> entries;
};

struct ShaderUserdata final
	: DoraHandleObject<GraphicsBackend::ShaderHandle, &LoveRuntime::retainLoveShaderHandle,
		&LoveRuntime::releaseLoveShader, &LoveRuntime::forgetLoveShaderHandle>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::ShaderHandle,
		&LoveRuntime::retainLoveShaderHandle, &LoveRuntime::releaseLoveShader,
		&LoveRuntime::forgetLoveShaderHandle>;
	static ::love::Type type;
	ShaderUserdata(LoveRuntime *valueRuntime, GraphicsBackend::ShaderHandle valueHandle,
		std::string valueWarnings)
		: DoraHandle(valueRuntime, valueHandle), warnings(std::move(valueWarnings)) { }
	std::string warnings;
	std::unordered_map<std::string, std::vector<::love::StrongRef<::love::Object>>> samplerObjects;
};

::love::Type ShaderUserdata::type("Shader", &::love::Object::type);

struct AudioSourceUserdata final
	: DoraHandleObject<AudioBackend::SourceHandle, &LoveRuntime::retainLoveAudioSourceHandle,
		&LoveRuntime::releaseLoveAudioSource, &LoveRuntime::forgetLoveAudioSourceHandle>
{
	using DoraHandle = DoraHandleObject<AudioBackend::SourceHandle,
		&LoveRuntime::retainLoveAudioSourceHandle, &LoveRuntime::releaseLoveAudioSource,
		&LoveRuntime::forgetLoveAudioSourceHandle>;
	static ::love::Type type;
	AudioSourceUserdata(LoveRuntime *valueRuntime, AudioBackend::SourceHandle valueHandle,
		bool valueStream, bool valueQueue)
		: DoraHandle(valueRuntime, valueHandle), stream(valueStream), queue(valueQueue) { }
	bool stream = false;
	bool queue = false;
};

::love::Type AudioSourceUserdata::type("Source", &::love::Object::type);

class ContentVideoFile final : public ::love::filesystem::File
{
public:
	ContentVideoFile(std::string filename, std::string bytes)
		: _filename(std::move(filename)), _bytes(std::move(bytes)) { }

	bool open(Mode mode) override
	{
		if (mode != MODE_READ) return false;
		_mode = mode;
		_position = 0;
		return true;
	}
	bool close() override { _mode = MODE_CLOSED; return true; }
	bool isOpen() const override { return _mode != MODE_CLOSED; }
	::love::int64 getSize() override { return static_cast<::love::int64>(_bytes.size()); }
	::love::int64 read(void *destination, ::love::int64 size) override
	{
		if (size <= 0 || _position >= _bytes.size()) return 0;
		const auto count = std::min<std::size_t>(static_cast<std::size_t>(size),
			_bytes.size() - _position);
		std::memcpy(destination, _bytes.data() + _position, count);
		_position += count;
		return static_cast<::love::int64>(count);
	}
	bool write(const void *, ::love::int64) override { return false; }
	bool flush() override { return false; }
	bool isEOF() override { return _position >= _bytes.size(); }
	::love::int64 tell() override { return static_cast<::love::int64>(_position); }
	bool seek(::love::uint64 position) override
	{
		if (position > _bytes.size()) return false;
		_position = static_cast<std::size_t>(position);
		return true;
	}
	bool setBuffer(BufferMode mode, ::love::int64 size) override
	{
		_bufferMode = mode;
		_bufferSize = size;
		return true;
	}
	BufferMode getBuffer(::love::int64 &size) const override
	{
		size = _bufferSize;
		return _bufferMode;
	}
	Mode getMode() const override { return _mode; }
	const std::string &getFilename() const override { return _filename; }

private:
	std::string _filename;
	std::string _bytes;
	std::size_t _position = 0;
	Mode _mode = MODE_READ;
	BufferMode _bufferMode = BUFFER_NONE;
	::love::int64 _bufferSize = 0;
};

class DoraAudioFrameSync final : public ::love::video::VideoStream::FrameSync
{
public:
	DoraAudioFrameSync(AudioBackend *backend, AudioBackend::SourceHandle source)
		: _backend(backend), _source(source) { }
	double getPosition() const override { return _backend->tellSource(_source); }
	void play() override { _backend->playSource(_source); }
	void pause() override { _backend->pauseSource(_source, true); }
	void seek(double seconds) override { _backend->seekSource(_source, seconds); }
	bool isPlaying() const override { return _backend->isSourcePlaying(_source); }

private:
	AudioBackend *_backend = nullptr;
	AudioBackend::SourceHandle _source = 0;
};

struct VideoStreamState
{
	~VideoStreamState()
	{
		stopping.store(true);
		if (worker.joinable()) worker.join();
		if (luaState && sourceReference != LUA_NOREF)
			luaL_unref(luaState, LUA_REGISTRYINDEX, sourceReference);
	}
	void start()
	{
		worker = std::thread([this]() {
			auto previous = std::chrono::steady_clock::now();
			while (!stopping.load())
			{
				const auto now = std::chrono::steady_clock::now();
				const double delta = std::chrono::duration<double>(now - previous).count();
				previous = now;
				try { stream->threadedFillBackBuffer(delta); }
				catch (...) { stopping.store(true); }
				std::this_thread::sleep_for(std::chrono::milliseconds(2));
			}
		});
	}

	LoveRuntime *runtime = nullptr;
	lua_State *luaState = nullptr;
	::love::StrongRef<ContentVideoFile> file;
	::love::StrongRef<::love::video::theora::TheoraVideoStream> stream;
	std::thread worker;
	std::atomic<bool> stopping = false;
	int sourceReference = LUA_NOREF;
	::love::StrongRef<::love::Object> sourceObject;
};

::love::Type LoveStreamType("Stream", &::love::Object::type);
::love::Type VideoStreamLoveType("VideoStream", &LoveStreamType);

struct VideoStreamUserdata final : ::love::Object
{
	~VideoStreamUserdata() override = default;
	std::shared_ptr<VideoStreamState> state;
};

struct VideoUserdata final
	: DoraHandleObject<GraphicsBackend::ImageHandle, &LoveRuntime::retainLoveImageHandle,
		&LoveRuntime::releaseLoveImage, &LoveRuntime::forgetLoveImageHandle>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::ImageHandle,
		&LoveRuntime::retainLoveImageHandle, &LoveRuntime::releaseLoveImage,
		&LoveRuntime::forgetLoveImageHandle>;
	static ::love::Type type;
	VideoUserdata(LoveRuntime *valueRuntime, std::shared_ptr<VideoStreamState> valueState,
		GraphicsBackend::ImageHandle valueImage)
		: DoraHandle(valueRuntime, valueImage), state(std::move(valueState)) { }
	std::shared_ptr<VideoStreamState> state;
	GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
	float anisotropy = 1.0f;
};

::love::Type VideoUserdata::type("Video", &LoveDrawableType);

std::vector<std::uint8_t> convertVideoFrame(const ::love::video::VideoStream::Frame &frame);

struct RecordingDeviceUserdata final
	: DoraHandleObject<AudioBackend::RecordingHandle, &LoveRuntime::retainLoveRecordingHandle,
		&LoveRuntime::stopLoveRecording, &LoveRuntime::forgetLoveRecordingHandle>
{
	using DoraHandle = DoraHandleObject<AudioBackend::RecordingHandle,
		&LoveRuntime::retainLoveRecordingHandle, &LoveRuntime::stopLoveRecording,
		&LoveRuntime::forgetLoveRecordingHandle>;
	static ::love::Type type;
	RecordingDeviceUserdata(LoveRuntime *valueRuntime, std::string valueName)
		: DoraHandle(valueRuntime, 0), name(std::move(valueName)) { }
	std::string name;
	int maxSamples = 8192;
	int sampleRate = 8000;
	int bitDepth = 16;
	int channels = 1;
};

::love::Type RecordingDeviceUserdata::type("RecordingDevice", &::love::Object::type);

::love::Type JoystickLoveType("Joystick", &::love::Object::type);

struct JoystickUserdata final : ::love::Object
{
	~JoystickUserdata() override = default;
	LoveRuntime *runtime = nullptr;
	int id = -1;
};

enum class FileMode
{
	Closed,
	Read,
	Write,
	Append,
};

::love::Type FileLoveType("File", &::love::Object::type);

struct FileUserdata final : ::love::Object
{
	~FileUserdata() override = default;
	LoveRuntime *runtime = nullptr;
	std::string filename;
	std::string data;
	std::size_t position = 0;
	FileMode mode = FileMode::Closed;
	std::string bufferMode = "none";
	std::size_t bufferSize = 0;
};

struct FileDataUserdata final : LoveDataObject
{
	static ::love::Type type;
	FileDataUserdata(std::string valueFilename, std::string valueData)
		: filename(std::move(valueFilename)), data(std::move(valueData)) { }
	DataSpan dataSpan() const noexcept override
	{
		return {reinterpret_cast<const std::uint8_t *>(data.data()), data.size()};
	}
	std::string filename;
	std::string data;
};

::love::Type FileDataUserdata::type("FileData", &LoveDataObject::type);

FileDataUserdata *testFileData(lua_State *state, int index)
{
	if (luaL_testudata(state, index, FileDataUserdata::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<FileDataUserdata>(state, index);
}

::love::Type PhysicsWorldLoveType("World", &::love::Object::type);
::love::Type PhysicsBodyLoveType("Body", &::love::Object::type);
::love::Type PhysicsShapeLoveType("Shape", &::love::Object::type);
::love::Type PhysicsFixtureLoveType("Fixture", &::love::Object::type);
::love::Type PhysicsJointLoveType("Joint", &::love::Object::type);
::love::Type PhysicsContactLoveType("Contact", &::love::Object::type);

struct PhysicsWorldUserdata final
	: DoraHandleObject<PhysicsBackend::WorldHandle, &LoveRuntime::retainLovePhysicsWorldHandle,
		&LoveRuntime::releaseLovePhysicsWorld, &LoveRuntime::forgetLovePhysicsWorldHandle>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::WorldHandle,
		&LoveRuntime::retainLovePhysicsWorldHandle, &LoveRuntime::releaseLovePhysicsWorld,
		&LoveRuntime::forgetLovePhysicsWorldHandle>;
	PhysicsWorldUserdata(LoveRuntime *valueRuntime, PhysicsBackend::WorldHandle valueHandle)
		: DoraHandle(valueRuntime, valueHandle) { }
};

struct PhysicsBodyUserdata final
	: DoraHandleObject<PhysicsBackend::BodyHandle, &LoveRuntime::retainLovePhysicsBodyHandle,
		&LoveRuntime::releaseLovePhysicsBody, &LoveRuntime::forgetLovePhysicsBodyHandle>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::BodyHandle,
		&LoveRuntime::retainLovePhysicsBodyHandle, &LoveRuntime::releaseLovePhysicsBody,
		&LoveRuntime::forgetLovePhysicsBodyHandle>;
	PhysicsBodyUserdata(LoveRuntime *valueRuntime, PhysicsBackend::BodyHandle valueHandle,
		PhysicsBackend::WorldHandle valueWorld, std::string valueType)
		: DoraHandle(valueRuntime, valueHandle), world(valueWorld), type(std::move(valueType)) { }
	PhysicsBackend::WorldHandle world = 0;
	std::string type;
	::love::StrongRef<PhysicsWorldUserdata> worldObject;
};

struct PhysicsShapeUserdata final
	: DoraHandleObject<PhysicsBackend::ShapeHandle, &LoveRuntime::retainLovePhysicsShapeHandle,
		&LoveRuntime::releaseLovePhysicsShape, &LoveRuntime::forgetLovePhysicsShapeHandle>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::ShapeHandle,
		&LoveRuntime::retainLovePhysicsShapeHandle, &LoveRuntime::releaseLovePhysicsShape,
		&LoveRuntime::forgetLovePhysicsShapeHandle>;
	PhysicsShapeUserdata() = default;
	PhysicsShapeUserdata(LoveRuntime *valueRuntime, PhysicsBackend::ShapeHandle valueHandle,
		std::string valueType, float valueRadius, std::vector<float> valuePoints)
		: DoraHandle(valueRuntime, valueHandle), type(std::move(valueType)),
		  radius(valueRadius), points(std::move(valuePoints)) { }
	std::string type;
	float radius = 0.0f;
	std::vector<float> points;
	bool loop = false;
	bool hasPreviousVertex = false;
	float previousX = 0.0f;
	float previousY = 0.0f;
	bool hasNextVertex = false;
	float nextX = 0.0f;
	float nextY = 0.0f;
};

struct PhysicsFixtureUserdata final
	: DoraHandleObject<PhysicsBackend::FixtureHandle, &LoveRuntime::retainLovePhysicsFixtureHandle,
		&LoveRuntime::releaseLovePhysicsFixture, &LoveRuntime::forgetLovePhysicsFixtureHandle>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::FixtureHandle,
		&LoveRuntime::retainLovePhysicsFixtureHandle, &LoveRuntime::releaseLovePhysicsFixture,
		&LoveRuntime::forgetLovePhysicsFixtureHandle>;
	PhysicsFixtureUserdata() = default;
	PhysicsFixtureUserdata(LoveRuntime *valueRuntime, PhysicsBackend::FixtureHandle valueHandle,
		float valueDensity) : DoraHandle(valueRuntime, valueHandle), density(valueDensity) { }
	float density = 1.0f;
	float friction = 0.2f;
	float restitution = 0.0f;
	bool sensor = false;
	::love::StrongRef<PhysicsBodyUserdata> bodyObject;
	::love::StrongRef<PhysicsShapeUserdata> shapeObject;
};

struct PhysicsJointUserdata final
	: DoraHandleObject<PhysicsBackend::JointHandle, &LoveRuntime::retainLovePhysicsJointHandle,
		&LoveRuntime::releaseLovePhysicsJoint, &LoveRuntime::forgetLovePhysicsJointHandle>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::JointHandle,
		&LoveRuntime::retainLovePhysicsJointHandle, &LoveRuntime::releaseLovePhysicsJoint,
		&LoveRuntime::forgetLovePhysicsJointHandle>;
	PhysicsJointUserdata(LoveRuntime *valueRuntime, PhysicsBackend::JointHandle valueHandle,
		std::string valueType) : DoraHandle(valueRuntime, valueHandle), type(std::move(valueType)) { }
	std::string type;
	::love::StrongRef<PhysicsBodyUserdata> bodyAObject;
	::love::StrongRef<PhysicsBodyUserdata> bodyBObject;
	::love::StrongRef<PhysicsJointUserdata> jointAObject;
	::love::StrongRef<PhysicsJointUserdata> jointBObject;
};

struct PhysicsContactUserdata final : ::love::Object
{
	PhysicsContactUserdata() = default;
	PhysicsContactUserdata(LoveRuntime *valueRuntime, PhysicsBackend::ContactHandle valueHandle,
		PhysicsBackend::WorldHandle valueWorld, PhysicsBackend::FixtureHandle valueFixtureA,
		PhysicsBackend::FixtureHandle valueFixtureB, int valueChildA, int valueChildB)
		: runtime(valueRuntime), handle(valueHandle), world(valueWorld), fixtureA(valueFixtureA),
		  fixtureB(valueFixtureB), childA(valueChildA), childB(valueChildB) { }
	~PhysicsContactUserdata() override = default;
	LoveRuntime *runtime = nullptr;
	PhysicsBackend::ContactHandle handle = 0;
	PhysicsBackend::WorldHandle world = 0;
	PhysicsBackend::FixtureHandle fixtureA = 0;
	PhysicsBackend::FixtureHandle fixtureB = 0;
	int childA = 0;
	int childB = 0;
	::love::StrongRef<PhysicsFixtureUserdata> fixtureAObject;
	::love::StrongRef<PhysicsFixtureUserdata> fixtureBObject;
};

const char *physicsShapeObjectName(const PhysicsShapeUserdata *shape)
{
	if (shape->type == "circle") return "CircleShape";
	if (shape->type == "edge") return "EdgeShape";
	if (shape->type == "chain") return "ChainShape";
	return "PolygonShape";
}

int physicsShapeObjectType(lua_State *state)
{
	auto *shape = ::love::luax_checktype<PhysicsShapeUserdata>(state, 1, PhysicsShapeLoveType);
	lua_pushstring(state, physicsShapeObjectName(shape));
	return 1;
}

int physicsShapeObjectTypeOf(lua_State *state)
{
	auto *shape = ::love::luax_checktype<PhysicsShapeUserdata>(state, 1, PhysicsShapeLoveType);
	const std::string_view requested = luaL_checkstring(state, 2);
	lua_pushboolean(state, requested == physicsShapeObjectName(shape)
		|| requested == "Shape" || requested == "Object");
	return 1;
}

const char *physicsJointObjectName(const PhysicsJointUserdata *joint)
{
	if (joint->type == "distance") return "DistanceJoint";
	if (joint->type == "revolute") return "RevoluteJoint";
	if (joint->type == "prismatic") return "PrismaticJoint";
	if (joint->type == "weld") return "WeldJoint";
	if (joint->type == "friction") return "FrictionJoint";
	if (joint->type == "rope") return "RopeJoint";
	if (joint->type == "pulley") return "PulleyJoint";
	if (joint->type == "wheel") return "WheelJoint";
	if (joint->type == "mouse") return "MouseJoint";
	if (joint->type == "motor") return "MotorJoint";
	return "GearJoint";
}

int physicsJointObjectType(lua_State *state)
{
	auto *joint = ::love::luax_checktype<PhysicsJointUserdata>(state, 1, PhysicsJointLoveType);
	lua_pushstring(state, physicsJointObjectName(joint));
	return 1;
}

int physicsJointObjectTypeOf(lua_State *state)
{
	auto *joint = ::love::luax_checktype<PhysicsJointUserdata>(state, 1, PhysicsJointLoveType);
	const std::string_view requested = luaL_checkstring(state, 2);
	lua_pushboolean(state, requested == physicsJointObjectName(joint)
		|| requested == "Joint" || requested == "Object");
	return 1;
}

LoveRuntime *runtimeFromUpvalue(lua_State *state)
{
	return static_cast<LoveRuntime *>(lua_touserdata(state, lua_upvalueindex(1)));
}

ImageUserdata *checkImage(lua_State *state, int index)
{
	return ::love::luax_checktype<ImageUserdata>(state, index);
}

CanvasUserdata *checkCanvas(lua_State *state, int index)
{
	return ::love::luax_checktype<CanvasUserdata>(state, index);
}

ImageDataUserdata *checkImageData(lua_State *state, int index)
{
	return ::love::luax_checktype<ImageDataUserdata>(state, index);
}

CursorUserdata *checkCursor(lua_State *state, int index)
{
	return ::love::luax_checktype<CursorUserdata>(state, index);
}

CursorUserdata *testCursor(lua_State *state, int index)
{
	return luaL_testudata(state, index, CursorUserdata::type.getName())
		? ::love::luax_checktype<CursorUserdata>(state, index) : nullptr;
}

CompressedImageDataUserdata *checkCompressedImageData(lua_State *state, int index)
{
	return ::love::luax_checktype<CompressedImageDataUserdata>(state, index);
}

RasterizerUserdata *checkRasterizer(lua_State *state, int index)
{
	return ::love::luax_checktype<RasterizerUserdata>(state, index, RasterizerLoveType);
}

GlyphDataUserdata *checkGlyphData(lua_State *state, int index)
{
	return ::love::luax_checktype<GlyphDataUserdata>(state, index);
}

SoundDataUserdata *checkSoundData(lua_State *state, int index)
{
	return ::love::luax_checktype<SoundDataUserdata>(state, index);
}

DecoderUserdata *checkDecoder(lua_State *state, int index)
{
	return ::love::luax_checktype<DecoderUserdata>(state, index, DecoderLoveType);
}

FontUserdata *checkFont(lua_State *state, int index)
{
	return ::love::luax_checktype<FontUserdata>(state, index);
}

FontUserdata *testFont(lua_State *state, int index)
{
	return luaL_testudata(state, index, FontUserdata::type.getName())
		? ::love::luax_checktype<FontUserdata>(state, index) : nullptr;
}

QuadUserdata *checkQuad(lua_State *state, int index)
{
	return ::love::luax_checktype<QuadUserdata>(state, index, QuadLoveType);
}

MeshUserdata *checkMesh(lua_State *state, int index)
{
	return ::love::luax_checktype<MeshUserdata>(state, index, MeshLoveType);
}

SpriteBatchUserdata *checkSpriteBatch(lua_State *state, int index)
{
	return ::love::luax_checktype<SpriteBatchUserdata>(state, index, SpriteBatchLoveType);
}

ParticleSystemUserdata *checkParticleSystem(lua_State *state, int index)
{
	return ::love::luax_checktype<ParticleSystemUserdata>(state, index, ParticleSystemLoveType);
}

TextUserdata *checkText(lua_State *state, int index)
{
	return ::love::luax_checktype<TextUserdata>(state, index, TextLoveType);
}

ShaderUserdata *checkShader(lua_State *state, int index)
{
	return ::love::luax_checktype<ShaderUserdata>(state, index);
}

bool loadShaderArgument(lua_State *state, int index, LoveRuntime *runtime,
	std::string &source, std::string &error)
{
	if (auto *data = testFileData(state, index))
	{
		source = data->data;
		error.clear();
		return true;
	}
	if (!lua_isstring(state, index))
	{
		error = "expected shader source code, a filename, or FileData";
		return false;
	}
	size_t size = 0;
	const char *text = lua_tolstring(state, index, &size);
	std::string candidate(text, size);
	if (candidate.find('\n') == std::string::npos && runtime->getFilesystemBackend())
	{
		std::string resolved;
		std::string resolveError;
		if (runtime->resolveReadPath(candidate, resolved, resolveError))
		{
			if (!runtime->getFilesystemBackend()->load(resolved, source, error))
				return false;
			error.clear();
			return true;
		}
		const auto dot = candidate.find('.');
		if (candidate.size() < 64 && dot != std::string::npos
			&& candidate.find(';', dot) == std::string::npos
			&& candidate.find(' ', dot) == std::string::npos)
		{
			error = "Could not open shader file " + candidate + ". Does not exist.";
			return false;
		}
	}
	source = std::move(candidate);
	error.clear();
	return true;
}

bool classifyShaderSources(std::span<const std::string> arguments,
	std::string &vertex, std::string &pixel, std::string &error)
{
	vertex.clear();
	pixel.clear();
	for (const auto &source : arguments)
	{
		const bool isVertex = source.find("position") != std::string::npos;
		const bool isPixel = source.find("effect") != std::string::npos;
		if (isVertex) vertex = source;
		if (isPixel) pixel = source;
	}
	if (arguments.size() == 2 && (vertex.empty() || pixel.empty()))
	{
		error = vertex.empty()
			? "Could not parse vertex shader code (missing 'position' function?)"
			: "Could not parse pixel shader code (missing 'effect' function?)";
		return false;
	}
	if (vertex.empty() && pixel.empty())
	{
		error = "shader source is missing a 'position' or 'effect' function";
		return false;
	}
	error.clear();
	return true;
}

bool isMeshDrawMode(std::string_view mode)
{
	return mode == "fan" || mode == "strip" || mode == "triangles" || mode == "points";
}

bool isMeshUsage(std::string_view usage)
{
	return usage == "stream" || usage == "dynamic" || usage == "static";
}

bool isMeshAttributeType(std::string_view type)
{
	return type == "float" || type == "byte" || type == "unorm16";
}

void readMeshVertex(lua_State *state, int tableIndex, const MeshUserdata &mesh,
	std::span<float> values)
{
	tableIndex = lua_absindex(state, tableIndex);
	for (std::size_t component = 0; component < mesh.componentCount; ++component)
	{
		lua_rawgeti(state, tableIndex, static_cast<lua_Integer>(component + 1));
		float fallback = 0.0f;
		for (const auto &attribute : mesh.format)
		{
			if (component >= attribute.offset && component < attribute.offset + attribute.components)
			{
				if (attribute.name == "VertexColor") fallback = 1.0f;
				else if (attribute.name == "VertexPosition" && component - attribute.offset == 3) fallback = 1.0f;
				break;
			}
		}
		const float value = static_cast<float>(luaL_optnumber(state, -1, fallback));
		lua_pop(state, 1);
		luaL_argcheck(state, std::isfinite(value), tableIndex, "Mesh vertex values must be finite numbers");
		values[component] = value;
	}
	for (const auto &attribute : mesh.format)
	{
		if (attribute.type == "float") continue;
		for (int component = 0; component < attribute.components; ++component)
			values[attribute.offset + component] = std::clamp(values[attribute.offset + component], 0.0f, 1.0f);
	}
}

void readMeshVertexArguments(lua_State *state, int startIndex, const MeshUserdata &mesh,
	std::span<float> values)
{
	for (std::size_t component = 0; component < mesh.componentCount; ++component)
	{
		float fallback = 0.0f;
		for (const auto &attribute : mesh.format)
		{
			if (component >= attribute.offset && component < attribute.offset + attribute.components)
			{
				if (attribute.name == "VertexColor") fallback = 1.0f;
				else if (attribute.name == "VertexPosition" && component - attribute.offset == 3) fallback = 1.0f;
				break;
			}
		}
		const float value = static_cast<float>(luaL_optnumber(state,
			startIndex + static_cast<int>(component), fallback));
		luaL_argcheck(state, std::isfinite(value), startIndex + static_cast<int>(component),
			"Mesh vertex values must be finite numbers");
		values[component] = value;
	}
	for (const auto &attribute : mesh.format)
	{
		if (attribute.type == "float") continue;
		for (int component = 0; component < attribute.components; ++component)
			values[attribute.offset + component] = std::clamp(values[attribute.offset + component], 0.0f, 1.0f);
	}
}

std::span<const std::uint8_t> meshDataBytes(lua_State *state, int index)
{
	if (auto *data = testFileData(state, index))
		return {reinterpret_cast<const std::uint8_t *>(data->data.data()), data->data.size()};
	if (auto *data = testImageData(state, index))
		return data->pixels;
	if (auto *data = testCompressedImageData(state, index))
		return data->bytes;
	if (auto *data = testSoundData(state, index))
		return data->samples;
	return {};
}

bool isMeshData(lua_State *state, int index)
{
	return testFileData(state, index)
		|| testImageData(state, index)
		|| testCompressedImageData(state, index)
		|| testSoundData(state, index);
}

std::size_t meshAttributeByteSize(std::string_view type, int components)
{
	const std::size_t componentSize = type == "float" ? sizeof(float)
		: type == "unorm16" ? sizeof(std::uint16_t) : sizeof(std::uint8_t);
	return componentSize * static_cast<std::size_t>(components);
}

bool decodeMeshStorage(const MeshUserdata &mesh, std::span<const std::uint8_t> bytes,
	std::vector<float> &values)
{
	if (mesh.vertexStride == 0 || bytes.size() < mesh.vertexCount * mesh.vertexStride)
		return false;
	values.assign(mesh.vertexCount * mesh.componentCount, 0.0f);
	for (std::size_t vertex = 0; vertex < mesh.vertexCount; ++vertex)
	{
		const std::uint8_t *source = bytes.data() + vertex * mesh.vertexStride;
		float *destination = values.data() + vertex * mesh.componentCount;
		for (const auto &attribute : mesh.format)
		{
			const std::uint8_t *attributeBytes = source + attribute.byteOffset;
			for (int component = 0; component < attribute.components; ++component)
			{
				float value = 0.0f;
				if (attribute.type == "float")
				{
					std::memcpy(&value, attributeBytes + component * sizeof(float), sizeof(float));
					if (!std::isfinite(value)) return false;
				}
				else if (attribute.type == "unorm16")
				{
					std::uint16_t raw = 0;
					std::memcpy(&raw, attributeBytes + component * sizeof(std::uint16_t), sizeof(raw));
					value = static_cast<float>(raw) / 65535.0f;
				}
				else value = static_cast<float>(attributeBytes[component]) / 255.0f;
				destination[attribute.offset + static_cast<std::size_t>(component)] = value;
			}
		}
	}
	return true;
}

void encodeMeshVertex(MeshUserdata &mesh, std::size_t vertex)
{
	std::uint8_t *destination = mesh.bytes.data() + vertex * mesh.vertexStride;
	float *values = mesh.values.data() + vertex * mesh.componentCount;
	for (const auto &attribute : mesh.format)
	{
		std::uint8_t *attributeBytes = destination + attribute.byteOffset;
		for (int component = 0; component < attribute.components; ++component)
		{
			float &value = values[attribute.offset + static_cast<std::size_t>(component)];
			if (attribute.type == "float")
				std::memcpy(attributeBytes + component * sizeof(float), &value, sizeof(float));
			else if (attribute.type == "unorm16")
			{
				const auto raw = static_cast<std::uint16_t>(std::clamp(value, 0.0f, 1.0f) * 65535.0f);
				std::memcpy(attributeBytes + component * sizeof(std::uint16_t), &raw, sizeof(raw));
				value = static_cast<float>(raw) / 65535.0f;
			}
			else
			{
				const auto raw = static_cast<std::uint8_t>(std::clamp(value, 0.0f, 1.0f) * 255.0f);
				attributeBytes[component] = raw;
				value = static_cast<float>(raw) / 255.0f;
			}
		}
	}
}

void encodeMeshStorage(MeshUserdata &mesh)
{
	mesh.bytes.assign(mesh.vertexCount * mesh.vertexStride, 0);
	for (std::size_t vertex = 0; vertex < mesh.vertexCount; ++vertex)
		encodeMeshVertex(mesh, vertex);
}

std::size_t meshAttributeIndex(const MeshUserdata &mesh, std::string_view name)
{
	for (std::size_t index = 0; index < mesh.format.size(); ++index)
		if (mesh.format[index].name == name) return index;
	return mesh.format.size();
}

AudioSourceUserdata *checkAudioSource(lua_State *state, int index)
{
	return ::love::luax_checktype<AudioSourceUserdata>(state, index);
}

AudioSourceUserdata *testAudioSource(lua_State *state, int index)
{
	return luaL_testudata(state, index, AudioSourceUserdata::type.getName())
		? ::love::luax_checktype<AudioSourceUserdata>(state, index) : nullptr;
}

VideoStreamUserdata *checkVideoStream(lua_State *state, int index)
{
	return ::love::luax_checktype<VideoStreamUserdata>(state, index, VideoStreamLoveType);
}

VideoUserdata *checkVideo(lua_State *state, int index)
{
	return ::love::luax_checktype<VideoUserdata>(state, index);
}

VideoUserdata *testVideo(lua_State *state, int index)
{
	return luaL_testudata(state, index, VideoUserdata::type.getName())
		? ::love::luax_checktype<VideoUserdata>(state, index) : nullptr;
}

JoystickUserdata *checkJoystick(lua_State *state, int index)
{
	return ::love::luax_checktype<JoystickUserdata>(state, index, JoystickLoveType);
}

FileUserdata *checkFile(lua_State *state, int index)
{
	return ::love::luax_checktype<FileUserdata>(state, index, FileLoveType);
}

FileDataUserdata *checkFileData(lua_State *state, int index)
{
	return ::love::luax_checktype<FileDataUserdata>(state, index);
}

PhysicsWorldUserdata *checkPhysicsWorld(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsWorldUserdata>(state, index, PhysicsWorldLoveType);
}

PhysicsBodyUserdata *checkPhysicsBody(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsBodyUserdata>(state, index, PhysicsBodyLoveType);
}

PhysicsShapeUserdata *checkPhysicsShape(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsShapeUserdata>(state, index, PhysicsShapeLoveType);
}

PhysicsFixtureUserdata *checkPhysicsFixture(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsFixtureUserdata>(state, index, PhysicsFixtureLoveType);
}

PhysicsJointUserdata *checkPhysicsJoint(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsJointUserdata>(state, index, PhysicsJointLoveType);
}

PhysicsContactUserdata *checkPhysicsContact(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsContactUserdata>(state, index, PhysicsContactLoveType);
}

void pushFile(lua_State *state, LoveRuntime *runtime, std::string filename)
{
	auto *file = new FileUserdata;
	file->runtime = runtime;
	file->filename = std::move(filename);
	::love::luax_pushtype(state, FileLoveType, file);
	file->release();
}

void pushFileData(lua_State *state, std::string filename, std::string data)
{
	auto *fileData = new FileDataUserdata(std::move(filename), std::move(data));
	::love::luax_pushtype(state, FileDataUserdata::type, fileData);
	fileData->release();
}

const ImagePixelFormatInfo &getImageDataFormat(const ImageDataUserdata &data)
{
	const auto *format = imagePixelFormatInfo(data.format);
	if (!format) std::abort();
	return *format;
}

const std::uint8_t *getImageDataPixel(const ImageDataUserdata &data, int x, int y)
{
	const auto &format = getImageDataFormat(data);
	return data.pixels.data() + (static_cast<std::size_t>(y) * data.width + x) * format.bytes;
}

std::uint8_t *getImageDataPixel(ImageDataUserdata &data, int x, int y)
{
	const auto &format = getImageDataFormat(data);
	return data.pixels.data() + (static_cast<std::size_t>(y) * data.width + x) * format.bytes;
}

bool imageDataToRGBA8(const ImageDataUserdata &data, std::vector<std::uint8_t> &rgba8)
{
	const auto &format = getImageDataFormat(data);
	if (format.value == ImagePixelFormat::RGBA8)
	{
		rgba8 = data.pixels;
		return true;
	}
	rgba8.resize(static_cast<std::size_t>(data.width) * data.height * 4);
	for (int y = 0; y < data.height; ++y)
		for (int x = 0; x < data.width; ++x)
		{
			ImagePixelColor color;
			readImagePixel(format, getImageDataPixel(data, x, y), color);
			const std::size_t offset = (static_cast<std::size_t>(y) * data.width + x) * 4;
			const auto &rgba8Format = *imagePixelFormatInfo("rgba8");
			writeImagePixel(rgba8Format, rgba8.data() + offset, color);
		}
	return true;
}

bool decodeUncompressedImageSource(lua_State *state, int index, LoveRuntime *runtime,
	int &width, int &height, std::vector<std::uint8_t> &rgba8,
	std::string &sourceName, std::string &error)
{
	if (auto *data = testImageData(state, index))
	{
		if (data->runtime != runtime)
		{
			error = "ImageData belongs to another LoveRuntime";
			return false;
		}
		width = data->width;
		height = data->height;
		imageDataToRGBA8(*data, rgba8);
		sourceName = "ImageData";
		error.clear();
		return true;
	}
	DataSpan encoded;
	if (!getDataSpan(state, index, encoded))
	{
		error = "expected ImageData, FileData, or Data";
		return false;
	}
	auto *imageBackend = runtime->getImageBackend();
	if (!imageBackend)
	{
		error = "Love Image Data input requires the Dora image backend";
		return false;
	}
	if (auto *fileData = testFileData(state, index)) sourceName = fileData->filename;
	else sourceName = "Data";
	const char *bytes = encoded.size == 0 ? ""
		: reinterpret_cast<const char *>(encoded.bytes);
	ImageBackend::CompressedImage compressed;
	std::string compressedError;
	if (imageBackend->decodeCompressedImage(std::string_view(bytes, encoded.size),
		compressed, compressedError) && !compressed.format.empty() && !compressed.levels.empty())
	{
		error = "compressed Data is not supported in uncompressed Image mipmap or slice tables";
		return false;
	}
	if (!imageBackend->decodeImage(std::string_view(bytes, encoded.size), width, height, rgba8, error))
	{
		if (error.empty()) error = compressedError;
		return false;
	}
	if (width <= 0 || height <= 0
		|| rgba8.size() != static_cast<std::size_t>(width) * height * 4)
	{
		error = "decoded Image Data has invalid RGBA8 dimensions";
		return false;
	}
	error.clear();
	return true;
}

std::optional<float> imageDPIScaleFromFilename(std::string_view sourceName)
{
	const std::size_t slash = sourceName.find_last_of("/\\");
	std::string_view name = slash == std::string_view::npos
		? sourceName : sourceName.substr(slash + 1);
	const std::size_t dot = name.find_last_of('.');
	if (dot != std::string_view::npos) name = name.substr(0, dot);
	if (name.size() < 3 || (name.back() != 'x' && name.back() != 'X')) return std::nullopt;
	const std::size_t at = name.find_last_of('@');
	if (at == std::string_view::npos || at + 2 >= name.size()) return std::nullopt;
	int density = 0;
	const char *begin = name.data() + at + 1;
	const char *end = name.data() + name.size() - 1;
	const auto parsed = std::from_chars(begin, end, density);
	if (parsed.ec == std::errc{} && parsed.ptr == end && density > 0)
		return static_cast<float>(density);
	return std::nullopt;
}

void pushImageData(lua_State *state, LoveRuntime *runtime, int width, int height,
	const char *format, std::vector<std::uint8_t> pixels)
{
	auto *imageData = new ImageDataUserdata(runtime, width, height, format, std::move(pixels));
	::love::luax_pushtype(state, ImageDataUserdata::type, imageData);
	imageData->release();
}

void pushCursor(lua_State *state, LoveRuntime *runtime, MouseBackend::CursorHandle handle,
	std::string type)
{
	auto *cursor = new CursorUserdata(runtime, handle, std::move(type));
	pushNewDoraHandleObject(state, CursorUserdata::type, cursor);
}

void pushImageData(lua_State *state, LoveRuntime *runtime, int width, int height,
	std::vector<std::uint8_t> pixels)
{
	pushImageData(state, runtime, width, height, "rgba8", std::move(pixels));
}

void pushThreadImageData(lua_State *state, const ThreadValue &value)
{
	lua_getfield(state, LUA_REGISTRYINDEX, LoveRuntimeRegistry);
	auto *runtime = static_cast<LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	const auto *format = imagePixelFormatInfo(value.format);
	pushImageData(state, runtime, value.width, value.height,
		format ? format->name : "rgba8", value.data);
}

void pushCompressedImageData(lua_State *state, ImageBackend::CompressedImage image)
{
	std::size_t byteCount = 0;
	for (const auto &level : image.levels)
		byteCount += level.bytes.size();
	std::vector<std::uint8_t> bytes;
	bytes.reserve(byteCount);
	for (const auto &level : image.levels)
		bytes.insert(bytes.end(), level.bytes.begin(), level.bytes.end());
	auto *data = new CompressedImageDataUserdata(std::move(image), std::move(bytes));
	::love::luax_pushtype(state, CompressedImageDataUserdata::type, data);
	data->release();
}

void pushRasterizer(lua_State *state, RasterizerUserdata rasterizer, int imageDataIndex)
{
	if (imageDataIndex != 0) imageDataIndex = lua_absindex(state, imageDataIndex);
	auto *object = new RasterizerUserdata(std::move(rasterizer));
	if (object->kind == RasterizerUserdata::Kind::TrueType && !object->fontBytes.empty())
	{
		const int offset = stbtt_GetFontOffsetForIndex(object->fontBytes.data(), 0);
		if (offset >= 0) stbtt_InitFont(&object->fontInfo, object->fontBytes.data(), offset);
	}
	if (imageDataIndex != 0)
	{
		if (lua_istable(state, imageDataIndex))
		{
			const std::size_t count = lua_rawlen(state, imageDataIndex);
			for (std::size_t index = 0; index < count; ++index)
			{
				lua_rawgeti(state, imageDataIndex, static_cast<lua_Integer>(index + 1));
				if (auto *source = testImageData(state, -1))
					object->sourceObjects.emplace_back(source);
				lua_pop(state, 1);
			}
		}
		else if (auto *source = testImageData(state, imageDataIndex))
			object->sourceObjects.emplace_back(source);
	}
	::love::luax_pushtype(state, RasterizerLoveType, object);
	if (imageDataIndex != 0) lua_pushvalue(state, imageDataIndex);
	else lua_pushnil(state);
	lua_setiuservalue(state, -2, 1);
	object->release();
}

void pushGlyphData(lua_State *state, GlyphDataUserdata glyphData)
{
	auto *data = new GlyphDataUserdata(std::move(glyphData));
	::love::luax_pushtype(state, GlyphDataUserdata::type, data);
	data->release();
}

void pushRasterizerGlyphData(lua_State *state, int rasterizerIndex, std::uint32_t codepoint)
{
	rasterizerIndex = lua_absindex(state, rasterizerIndex);
	auto *rasterizer = checkRasterizer(state, rasterizerIndex);
	if (rasterizer->kind == RasterizerUserdata::Kind::BMFont)
	{
		GlyphDataUserdata glyphData;
		glyphData.glyph = codepoint;
		const auto found = rasterizer->bmGlyphs.find(codepoint);
		if (found != rasterizer->bmGlyphs.end())
		{
			const auto &glyph = found->second;
			glyphData.width = glyph.width;
			glyphData.height = glyph.height;
			glyphData.advance = glyph.advance;
			glyphData.bearingX = glyph.bearingX;
			glyphData.bearingY = glyph.bearingY;
			luaL_argcheck(state, glyph.page >= 0
				&& static_cast<std::size_t>(glyph.page) < rasterizer->sourceObjects.size(),
				rasterizerIndex, "Rasterizer page reference is missing");
			auto *image = static_cast<ImageDataUserdata *>(
				rasterizer->sourceObjects[static_cast<std::size_t>(glyph.page)].get());
			std::vector<std::uint8_t> rgba8;
			imageDataToRGBA8(*image, rgba8);
			glyphData.pixels.resize(static_cast<std::size_t>(glyph.width)
				* static_cast<std::size_t>(glyph.height) * 4);
			for (int row = 0; row < glyph.height; ++row)
			{
				const auto source = rgba8.begin() + static_cast<std::ptrdiff_t>(
					(static_cast<std::size_t>(glyph.y + row) * image->width + glyph.x) * 4);
				const auto destination = glyphData.pixels.begin() + static_cast<std::ptrdiff_t>(
					static_cast<std::size_t>(row) * glyph.width * 4);
				std::copy_n(source, static_cast<std::size_t>(glyph.width) * 4, destination);
			}
		}
		pushGlyphData(state, std::move(glyphData));
		return;
	}
	if (rasterizer->kind == RasterizerUserdata::Kind::TrueType)
	{
		GlyphDataUserdata glyphData;
		glyphData.glyph = codepoint;
		glyphData.pixelSize = 2;
		glyphData.format = "la8";
		int unscaledAdvance = 0;
		int leftBearing = 0;
		stbtt_GetCodepointHMetrics(&rasterizer->fontInfo, static_cast<int>(codepoint),
			&unscaledAdvance, &leftBearing);
		int x0 = 0, y0 = 0, x1 = 0, y1 = 0;
		stbtt_GetCodepointBitmapBox(&rasterizer->fontInfo, static_cast<int>(codepoint),
			rasterizer->fontScale, rasterizer->fontScale, &x0, &y0, &x1, &y1);
		glyphData.width = std::max(0, x1 - x0);
		glyphData.height = std::max(0, y1 - y0);
		glyphData.advance = static_cast<int>(std::floor(unscaledAdvance * rasterizer->fontScale + 0.5f));
		glyphData.bearingX = x0;
		glyphData.bearingY = -y0;
		if (glyphData.width > 0 && glyphData.height > 0)
		{
			std::vector<std::uint8_t> coverage(static_cast<std::size_t>(glyphData.width)
				* static_cast<std::size_t>(glyphData.height));
			stbtt_MakeCodepointBitmap(&rasterizer->fontInfo, coverage.data(), glyphData.width,
				glyphData.height, glyphData.width, rasterizer->fontScale, rasterizer->fontScale,
				static_cast<int>(codepoint));
			glyphData.pixels.resize(coverage.size() * 2);
			for (std::size_t index = 0; index < coverage.size(); ++index)
			{
				const std::uint8_t alpha = rasterizer->monochrome
					? (coverage[index] >= 128 ? 255 : 0) : coverage[index];
				glyphData.pixels[index * 2] = 255;
				glyphData.pixels[index * 2 + 1] = alpha;
			}
		}
		pushGlyphData(state, std::move(glyphData));
		return;
	}
	luaL_argcheck(state, !rasterizer->sourceObjects.empty(), rasterizerIndex,
		"Rasterizer ImageData reference is missing");
	auto *image = static_cast<ImageDataUserdata *>(rasterizer->sourceObjects.front().get());
	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*image, rgba8);

	GlyphDataUserdata glyphData;
	glyphData.glyph = codepoint;
	glyphData.height = rasterizer->height;
	const auto found = std::find_if(rasterizer->imageGlyphs.begin(), rasterizer->imageGlyphs.end(),
		[codepoint](const ImageRasterizerGlyph &glyph) { return glyph.codepoint == codepoint; });
	if (found != rasterizer->imageGlyphs.end())
	{
		glyphData.width = found->width;
		glyphData.advance = found->width + rasterizer->extraSpacing;
		const std::size_t byteCount = static_cast<std::size_t>(glyphData.width)
			* static_cast<std::size_t>(glyphData.height) * 4;
		glyphData.pixels.resize(byteCount);
		for (int row = 0; row < glyphData.height; ++row)
		{
			for (int column = 0; column < glyphData.width; ++column)
			{
				const std::size_t sourceOffset = (static_cast<std::size_t>(row)
					* static_cast<std::size_t>(image->width)
					+ static_cast<std::size_t>(found->x + column)) * 4;
				const std::size_t destinationOffset = (static_cast<std::size_t>(row)
					* static_cast<std::size_t>(glyphData.width)
					+ static_cast<std::size_t>(column)) * 4;
				if (std::equal(rasterizer->spacer.begin(), rasterizer->spacer.end(),
					rgba8.begin() + static_cast<std::ptrdiff_t>(sourceOffset)))
					std::fill_n(glyphData.pixels.begin() + static_cast<std::ptrdiff_t>(destinationOffset), 4, 0);
				else
					std::copy_n(rgba8.begin() + static_cast<std::ptrdiff_t>(sourceOffset), 4,
						glyphData.pixels.begin() + static_cast<std::ptrdiff_t>(destinationOffset));
			}
		}
	}
	pushGlyphData(state, std::move(glyphData));
}

void pushSoundData(lua_State *state, int sampleRate, int bitDepth, int channels,
	int sampleCount, std::vector<std::uint8_t> samples)
{
	auto *data = new SoundDataUserdata(sampleRate, bitDepth, channels, sampleCount, std::move(samples));
	::love::luax_pushtype(state, SoundDataUserdata::type, data);
	data->release();
}

void pushDecoder(lua_State *state, int sampleRate, int channels, std::size_t bufferSize,
	std::vector<std::uint8_t> samples)
{
	auto *decoder = new DecoderUserdata;
	decoder->sampleRate = sampleRate;
	decoder->channels = channels;
	decoder->sampleCount = static_cast<int>(samples.size()
		/ (static_cast<std::size_t>(channels) * 2));
	decoder->bufferSize = bufferSize;
	decoder->samples = std::move(samples);
	::love::luax_pushtype(state, DecoderLoveType, decoder);
	decoder->release();
}

std::uint64_t wangHash64(std::uint64_t value)
{
	value = (~value) + (value << 21);
	value ^= value >> 24;
	value = (value + (value << 3)) + (value << 8);
	value ^= value >> 14;
	value = (value + (value << 2)) + (value << 4);
	value ^= value >> 28;
	return value + (value << 31);
}

void setRandomSeed(RandomGeneratorUserdata &generator, std::uint64_t seed)
{
	generator.seed = seed;
	do seed = wangHash64(seed); while (seed == 0);
	generator.state = seed;
	generator.cachedNormal = std::numeric_limits<double>::infinity();
}

std::uint64_t randomBits(RandomGeneratorUserdata &generator)
{
	generator.state ^= generator.state >> 12;
	generator.state ^= generator.state << 25;
	generator.state ^= generator.state >> 27;
	return generator.state * UINT64_C(2685821657736338717);
}

double randomUnit(RandomGeneratorUserdata &generator)
{
	const std::uint64_t bits = (UINT64_C(0x3ff) << 52) | (randomBits(generator) >> 12);
	return std::bit_cast<double>(bits) - 1.0;
}

double randomNormalValue(RandomGeneratorUserdata &generator, double standardDeviation)
{
	if (generator.cachedNormal != std::numeric_limits<double>::infinity())
	{
		const double cached = generator.cachedNormal;
		generator.cachedNormal = std::numeric_limits<double>::infinity();
		return cached * standardDeviation;
	}
	const double radius = std::sqrt(-2.0 * std::log(1.0 - randomUnit(generator)));
	const double phi = 2.0 * std::numbers::pi * (1.0 - randomUnit(generator));
	generator.cachedNormal = radius * std::cos(phi);
	return radius * std::sin(phi) * standardDeviation;
}

RandomGeneratorUserdata *checkRandomGenerator(lua_State *state, int index)
{
	return ::love::luax_checktype<RandomGeneratorUserdata>(state, index,
		RandomGeneratorLoveType);
}

void pushRandomGenerator(lua_State *state, std::uint64_t seed)
{
	auto *generator = new RandomGeneratorUserdata;
	setRandomSeed(*generator, seed);
	::love::luax_pushtype(state, RandomGeneratorLoveType, generator);
	generator->release();
}

TransformUserdata *checkTransform(lua_State *state, int index)
{
	return ::love::luax_checktype<TransformUserdata>(state, index, TransformLoveType);
}

bool isAffine2DTransform(const TransformUserdata &transform) noexcept
{
	const float *elements = transform.elements;
	constexpr float epsilon = 0.00001f;
	return std::abs(elements[2]) < epsilon && std::abs(elements[3]) < epsilon
		&& std::abs(elements[6]) < epsilon && std::abs(elements[7]) < epsilon
		&& std::abs(elements[8]) < epsilon && std::abs(elements[9]) < epsilon
		&& std::abs(elements[10] - 1.0f) < epsilon && std::abs(elements[11]) < epsilon
		&& std::abs(elements[14]) < epsilon && std::abs(elements[15] - 1.0f) < epsilon;
}

void setTransformIdentity(TransformUserdata &transform)
{
	std::fill(std::begin(transform.elements), std::end(transform.elements), 0.0f);
	transform.elements[0] = transform.elements[5] = transform.elements[10]
		= transform.elements[15] = 1.0f;
}

void multiplyTransforms(const TransformUserdata &left, const TransformUserdata &right,
	TransformUserdata &result)
{
	float values[16]{};
	for (int column = 0; column < 4; ++column)
		for (int row = 0; row < 4; ++row)
			for (int component = 0; component < 4; ++component)
				values[column * 4 + row] += left.elements[component * 4 + row]
					* right.elements[column * 4 + component];
	std::copy(std::begin(values), std::end(values), std::begin(result.elements));
}

void setTransform(TransformUserdata &transform, float x, float y, float angle,
	float sx, float sy, float ox, float oy, float kx, float ky)
{
	std::fill(std::begin(transform.elements), std::end(transform.elements), 0.0f);
	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	transform.elements[10] = transform.elements[15] = 1.0f;
	transform.elements[0] = cosine * sx - ky * sine * sy;
	transform.elements[1] = sine * sx + ky * cosine * sy;
	transform.elements[4] = kx * cosine * sx - sine * sy;
	transform.elements[5] = kx * sine * sx + cosine * sy;
	transform.elements[12] = x - ox * transform.elements[0] - oy * transform.elements[4];
	transform.elements[13] = y - ox * transform.elements[1] - oy * transform.elements[5];
}

void appendTransform(TransformUserdata &transform, const TransformUserdata &other)
{
	TransformUserdata result;
	multiplyTransforms(transform, other, result);
	transform = result;
}

bool invertTransform(const TransformUserdata &input, TransformUserdata &output)
{
	// Gauss-Jordan elimination is used here to preserve the complete 4x4
	// setMatrix/inverse contract, rather than only the common affine subset.
	double augmented[4][8]{};
	for (int row = 0; row < 4; ++row)
		for (int column = 0; column < 4; ++column)
		{
			augmented[row][column] = input.elements[column * 4 + row];
			augmented[row][column + 4] = row == column ? 1.0 : 0.0;
		}
	for (int pivot = 0; pivot < 4; ++pivot)
	{
		int best = pivot;
		for (int row = pivot + 1; row < 4; ++row)
			if (std::abs(augmented[row][pivot]) > std::abs(augmented[best][pivot])) best = row;
		if (augmented[best][pivot] == 0.0)
		{
			std::fill(std::begin(output.elements), std::end(output.elements),
				std::numeric_limits<float>::quiet_NaN());
			return true;
		}
		if (best != pivot)
			for (int column = 0; column < 8; ++column)
				std::swap(augmented[pivot][column], augmented[best][column]);
		const double divisor = augmented[pivot][pivot];
		for (double &value : augmented[pivot]) value /= divisor;
		for (int row = 0; row < 4; ++row)
		{
			if (row == pivot) continue;
			const double factor = augmented[row][pivot];
			for (int column = 0; column < 8; ++column)
				augmented[row][column] -= factor * augmented[pivot][column];
		}
	}
	for (int row = 0; row < 4; ++row)
		for (int column = 0; column < 4; ++column)
			output.elements[column * 4 + row] = static_cast<float>(augmented[row][column + 4]);
	return true;
}

void pushTransform(lua_State *state, const TransformUserdata &value)
{
	auto *transform = new TransformUserdata;
	std::copy(std::begin(value.elements), std::end(value.elements),
		std::begin(transform->elements));
	::love::luax_pushtype(state, TransformLoveType, transform);
	transform->release();
}

BezierCurveUserdata *checkBezierCurve(lua_State *state, int index)
{
	return ::love::luax_checktype<BezierCurveUserdata>(state, index,
		BezierCurveLoveType);
}

void pushBezierCurve(lua_State *state, std::vector<MathPoint> points)
{
	auto *curve = new BezierCurveUserdata;
	curve->controlPoints = std::move(points);
	::love::luax_pushtype(state, BezierCurveLoveType, curve);
	curve->release();
}

std::size_t wrapCurveIndex(lua_State *state, const BezierCurveUserdata &curve,
	lua_Integer luaIndex, bool allowEnd = false)
{
	const auto count = static_cast<lua_Integer>(curve.controlPoints.size());
	if (count == 0) luaL_error(state, "Curve contains no control points.");
	lua_Integer index = luaIndex > 0 ? luaIndex - 1 : luaIndex;
	if (allowEnd && index == count) return static_cast<std::size_t>(count);
	index %= count;
	if (index < 0) index += count;
	return static_cast<std::size_t>(index);
}

MathPoint evaluateBezier(const std::vector<MathPoint> &controlPoints, double time)
{
	auto points = controlPoints;
	for (std::size_t step = 1; step < controlPoints.size(); ++step)
		for (std::size_t index = 0; index < controlPoints.size() - step; ++index)
		{
			points[index].x = points[index].x * (1.0 - time) + points[index + 1].x * time;
			points[index].y = points[index].y * (1.0 - time) + points[index + 1].y * time;
		}
	return points.front();
}

void subdivideBezier(std::vector<MathPoint> &points, int accuracy)
{
	if (accuracy <= 0) return;
	std::vector<MathPoint> left;
	std::vector<MathPoint> right;
	left.reserve(points.size());
	right.reserve(points.size());
	for (std::size_t step = 1; step < points.size(); ++step)
	{
		left.push_back(points.front());
		right.push_back(points[points.size() - step]);
		for (std::size_t index = 0; index < points.size() - step; ++index)
		{
			points[index].x = (points[index].x + points[index + 1].x) * 0.5;
			points[index].y = (points[index].y + points[index + 1].y) * 0.5;
		}
	}
	left.push_back(points.front());
	right.push_back(points.front());
	subdivideBezier(left, accuracy - 1);
	subdivideBezier(right, accuracy - 1);
	points.resize(left.size() + right.size() - 1);
	std::copy(left.begin(), left.end(), points.begin());
	for (std::size_t index = 1; index < right.size(); ++index)
		points[index - 1 + left.size()] = right[right.size() - index - 1];
}

void pushBezierPoints(lua_State *state, const std::vector<MathPoint> &points)
{
	lua_createtable(state, static_cast<int>(points.size() * 2), 0);
	for (std::size_t index = 0; index < points.size(); ++index)
	{
		lua_pushnumber(state, points[index].x);
		lua_rawseti(state, -2, static_cast<lua_Integer>(index * 2 + 1));
		lua_pushnumber(state, points[index].y);
		lua_rawseti(state, -2, static_cast<lua_Integer>(index * 2 + 2));
	}
}

std::uint64_t checkRandomSeed(lua_State *state, int index)
{
		const double low = luaL_checknumber(state, index);
		luaL_argcheck(state, std::isfinite(low), index, "invalid random seed");
		const auto convert = [](double value, int bits) {
			const double modulus = std::ldexp(1.0, bits);
			if (bits == 64)
			{
				constexpr double wordModulus = 4294967296.0;
				const auto split = [](double magnitude) {
					const auto high = static_cast<std::uint64_t>(std::floor(magnitude / wordModulus));
					const auto low = static_cast<std::uint64_t>(std::fmod(magnitude, wordModulus));
					return (high << 32) | low;
				};
				const double truncated = std::trunc(value);
				if (truncated < 0.0)
					return std::uint64_t{0} - split(std::fmod(-truncated, modulus));
				return split(std::fmod(truncated, modulus));
			}
			double wrapped = std::fmod(std::trunc(value), modulus);
			if (wrapped < 0.0) wrapped += modulus;
			return static_cast<std::uint64_t>(wrapped);
		};
	if (!lua_isnoneornil(state, index + 1))
	{
		const double high = luaL_checknumber(state, index + 1);
		luaL_argcheck(state, std::isfinite(high), index + 1, "invalid random seed");
		return convert(low, 32) | (convert(high, 32) << 32);
	}
	return convert(low, 64);
}

double clampUnit(double value)
{
	return std::clamp(value, 0.0, 1.0);
}

std::vector<MathPoint> checkMathPolygon(lua_State *state)
{
	const bool table = lua_istable(state, 1);
	const int coordinateCount = table ? static_cast<int>(lua_rawlen(state, 1)) : lua_gettop(state);
	luaL_argcheck(state, coordinateCount % 2 == 0, 1, "expected an even number of coordinates");
	luaL_argcheck(state, coordinateCount <= 2'000'000, 1, "polygon has too many coordinates");
	std::vector<MathPoint> points;
	points.reserve(static_cast<std::size_t>(coordinateCount / 2));
	for (int coordinate = 0; coordinate < coordinateCount; coordinate += 2)
	{
		double x = 0.0;
		double y = 0.0;
		if (table)
		{
			lua_rawgeti(state, 1, coordinate + 1);
			x = luaL_checknumber(state, -1);
			lua_pop(state, 1);
			lua_rawgeti(state, 1, coordinate + 2);
			y = luaL_checknumber(state, -1);
			lua_pop(state, 1);
		}
		else
		{
			x = luaL_checknumber(state, coordinate + 1);
			y = luaL_checknumber(state, coordinate + 2);
		}
		luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 1,
			"polygon coordinates must be finite");
		points.push_back({x, y});
	}
	return points;
}

double mathCross(const MathPoint &a, const MathPoint &b, const MathPoint &c)
{
	return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

bool isMathPolygonConvex(const std::vector<MathPoint> &points)
{
	if (points.size() < 3) return false;
	double winding = 0.0;
	for (std::size_t index = 0; index < points.size(); ++index)
	{
		const double cross = mathCross(points[index], points[(index + 1) % points.size()],
			points[(index + 2) % points.size()]);
		if (cross == 0.0) continue;
		if (winding == 0.0) winding = cross;
		else if (cross * winding < 0.0) return false;
	}
	return true;
}

bool mathPointInTriangle(const MathPoint &point, const MathPoint &a,
	const MathPoint &b, const MathPoint &c)
{
	const double ab = mathCross(a, b, point);
	const double bc = mathCross(b, c, point);
	const double ca = mathCross(c, a, point);
	return (ab >= 0.0 && bc >= 0.0 && ca >= 0.0)
		|| (ab <= 0.0 && bc <= 0.0 && ca <= 0.0);
}

bool triangulateMathPolygon(const std::vector<MathPoint> &points,
	std::vector<MathTriangle> &triangles)
{
	triangles.clear();
	if (points.size() < 3) return false;
	std::vector<std::size_t> indices(points.size());
	for (std::size_t index = 0; index < points.size(); ++index) indices[index] = index;
	double area = 0.0;
	for (std::size_t index = 0; index < points.size(); ++index)
	{
		const auto &current = points[index];
		const auto &next = points[(index + 1) % points.size()];
		area += current.x * next.y - next.x * current.y;
	}
	if (area < 0.0) std::reverse(indices.begin(), indices.end());
	std::size_t skipped = 0;
	std::size_t cursor = 0;
	while (indices.size() > 3)
	{
		const std::size_t previous = indices[(cursor + indices.size() - 1) % indices.size()];
		const std::size_t current = indices[cursor];
		const std::size_t next = indices[(cursor + 1) % indices.size()];
		bool ear = mathCross(points[previous], points[current], points[next]) >= 0.0;
		if (ear)
		{
			for (const std::size_t candidate : indices)
			{
				if (candidate != previous && candidate != current && candidate != next
					&& mathPointInTriangle(points[candidate], points[previous], points[current], points[next]))
				{
					ear = false;
					break;
				}
			}
		}
		if (ear)
		{
			triangles.push_back({points[previous], points[current], points[next]});
			indices.erase(indices.begin() + static_cast<std::ptrdiff_t>(cursor));
			if (cursor >= indices.size()) cursor = 0;
			skipped = 0;
		}
		else
		{
			cursor = (cursor + 1) % indices.size();
			if (++skipped > indices.size()) return false;
		}
	}
	triangles.push_back({points[indices[0]], points[indices[1]], points[indices[2]]});
	return true;
}

std::string fileExtension(std::string_view filename)
{
	const std::size_t dot = filename.rfind('.');
	return dot == std::string_view::npos ? std::string{} : std::string(filename.substr(dot + 1));
}

void pushAudioSource(lua_State *state, LoveRuntime *runtime, AudioBackend::SourceHandle handle,
	bool stream, bool queue = false)
{
	auto *source = new AudioSourceUserdata(runtime, handle, stream, queue);
	pushNewDoraHandleObject(state, AudioSourceUserdata::type, source);

	// Love's no-argument audio.pause() returns the existing Source userdata
	// objects which were playing. A weak handle -> userdata index makes that
	// possible without keeping otherwise unreachable Sources alive.
	lua_getfield(state, LUA_REGISTRYINDEX, AudioSourceRegistry);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		lua_newtable(state);
		lua_newtable(state);
		lua_pushliteral(state, "v");
		lua_setfield(state, -2, "__mode");
		lua_setmetatable(state, -2);
		lua_pushvalue(state, -1);
		lua_setfield(state, LUA_REGISTRYINDEX, AudioSourceRegistry);
	}
	lua_pushinteger(state, static_cast<lua_Integer>(handle));
	lua_pushvalue(state, -3);
	lua_rawset(state, -3);
	lua_pop(state, 1);
}

bool pushAudioSourceByHandle(lua_State *state, AudioBackend::SourceHandle handle)
{
	lua_getfield(state, LUA_REGISTRYINDEX, AudioSourceRegistry);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		return false;
	}
	lua_pushinteger(state, static_cast<lua_Integer>(handle));
	lua_rawget(state, -2);
	lua_remove(state, -2);
	if (lua_isnil(state, -1))
	{
		lua_pop(state, 1);
		return false;
	}
	if (luaL_testudata(state, -1, AudioSourceUserdata::type.getName()) == nullptr
		|| !::love::luax_istype(state, -1, AudioSourceUserdata::type))
	{
		lua_pop(state, 1);
		return false;
	}
	return true;
}

RecordingDeviceUserdata *checkRecordingDevice(lua_State *state, int index)
{
	return ::love::luax_checktype<RecordingDeviceUserdata>(state, index);
}

void pushRecordingDevice(lua_State *state, LoveRuntime *runtime, std::string_view name)
{
	// Keep device identity stable across repeated enumeration, as Love's audio
	// module does for its retained RecordingDevice objects.
	lua_getfield(state, LUA_REGISTRYINDEX, RecordingDeviceRegistry);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		lua_newtable(state);
		lua_newtable(state);
		lua_pushliteral(state, "v");
		lua_setfield(state, -2, "__mode");
		lua_setmetatable(state, -2);
		lua_pushvalue(state, -1);
		lua_setfield(state, LUA_REGISTRYINDEX, RecordingDeviceRegistry);
	}
	lua_pushlstring(state, name.data(), name.size());
	lua_rawget(state, -2);
	if (!lua_isnil(state, -1)
		&& luaL_testudata(state, -1, RecordingDeviceUserdata::type.getName()) != nullptr
		&& ::love::luax_istype(state, -1, RecordingDeviceUserdata::type))
	{
		lua_remove(state, -2);
		return;
	}
	lua_pop(state, 1);

	auto *device = new RecordingDeviceUserdata(runtime, std::string(name));
	pushNewDoraHandleObject(state, RecordingDeviceUserdata::type, device);
	lua_pushlstring(state, name.data(), name.size());
	lua_pushvalue(state, -2);
	lua_rawset(state, -4);
	lua_remove(state, -2);
}

void pushFont(lua_State *state, LoveRuntime *runtime, GraphicsBackend::FontHandle handle)
{
	auto *font = new FontUserdata(runtime, handle);
	font->filter = runtime->getGraphicsDefaultFilter();
	font->anisotropy = runtime->getGraphicsDefaultAnisotropy();
	pushNewDoraHandleObject(state, FontUserdata::type, font);
}

float colorComponent(lua_State *state, int index, float defaultValue)
{
	return std::clamp(static_cast<float>(luaL_optnumber(state, index, defaultValue)), 0.0f, 1.0f);
}

bool drawMode(lua_State *state, int index)
{
	const std::string_view mode = luaL_checkstring(state, index);
	if (mode == "fill")
		return true;
	if (mode == "line")
		return false;
	luaL_argerror(state, index, "expected 'fill' or 'line'");
	return false;
}

bool normalizeLoveVirtualPath(std::string_view filename, std::string &normalized,
	bool allowEmpty = false)
{
	if (filename.find('\\') != std::string_view::npos)
		return false;
	// PhysFS-backed LÖVE paths are rooted at the game's virtual filesystem.
	// Existing games commonly spell that root with a leading slash and keep a
	// trailing slash for directories. Normalize both forms before confinement.
	while (filename.starts_with('/'))
		filename.remove_prefix(1);
	while (filename.starts_with("./"))
		filename.remove_prefix(2);
	while (filename.ends_with('/'))
		filename.remove_suffix(1);
	if (filename.empty())
	{
		normalized.clear();
		return allowEmpty;
	}
	normalized.clear();
	std::size_t start = 0;
	while (start <= filename.size())
	{
		const std::size_t slash = filename.find('/', start);
		const std::size_t end = slash == std::string_view::npos ? filename.size() : slash;
		const std::string_view component = filename.substr(start, end - start);
		if (component.empty() || component == "." || component == "..")
			return false;
		if (!normalized.empty()) normalized.push_back('/');
		normalized.append(component);
		if (slash == std::string_view::npos) break;
		start = slash + 1;
	}
	return true;
}

bool isSafeVirtualPath(std::string_view filename, bool allowEmpty = false)
{
	std::string normalized;
	return normalizeLoveVirtualPath(filename, normalized, allowEmpty);
}

bool normalizeLoveModulePath(std::string_view moduleName, std::string &modulePath)
{
	while (moduleName.starts_with("./"))
		moduleName.remove_prefix(2);
	if (moduleName.empty())
		return false;
	modulePath.clear();
	modulePath.reserve(moduleName.size());
	bool componentEmpty = true;
	for (const char character : moduleName)
	{
		if (character == '.' || character == '/')
		{
			// Lua accepts both package-style names (foo.bar) and path-style names
			// (foo/bar). Empty components also cover '.', '..', repeated
			// separators, and leading/trailing separators after normalization.
			if (componentEmpty)
				return false;
			modulePath.push_back('/');
			componentEmpty = true;
			continue;
		}
		if (character == '\\' || character == ':' || character == '\0')
			return false;
		modulePath.push_back(character);
		componentEmpty = false;
	}
	return !componentEmpty && isSafeVirtualPath(modulePath);
}

bool isGamepadButtonName(std::string_view name)
{
	static const std::set<std::string_view> names = {
		"a", "b", "x", "y", "back", "guide", "start", "leftstick", "rightstick",
		"leftshoulder", "rightshoulder", "dpup", "dpdown", "dpleft", "dpright", "misc1",
		"paddle1", "paddle2", "paddle3", "paddle4", "touchpad"};
	return names.contains(name);
}

bool isGamepadAxisName(std::string_view name)
{
	static const std::set<std::string_view> names = {
		"leftx", "lefty", "rightx", "righty", "triggerleft", "triggerright"};
	return names.contains(name);
}

bool isInsideRoot(const std::filesystem::path &root, const std::filesystem::path &candidate, bool allowRoot = false)
{
	const std::filesystem::path relative = candidate.lexically_relative(root);
	if (relative.empty() || relative == ".")
		return allowRoot;
	return *relative.begin() != "..";
}

bool resolveEntryWithinRoot(const std::string &rootText, std::string_view filename,
	std::filesystem::path &resolved, bool allowRoot, std::string &error)
{
	if (rootText.empty())
		return false;
	std::string normalized;
	if (!normalizeLoveVirtualPath(filename, normalized, allowRoot))
	{
		error = "Love filesystem path must be relative and cannot contain '.', '..', or backslashes: "
			+ std::string(filename);
		return false;
	}
	std::error_code pathError;
	const std::filesystem::path root = std::filesystem::weakly_canonical(rootText, pathError);
	if (pathError)
	{
		error = "failed to resolve Love filesystem root: " + pathError.message();
		return false;
	}
	const std::filesystem::path unresolved = normalized.empty()
		? root : root / std::filesystem::path(normalized);
	resolved = std::filesystem::weakly_canonical(unresolved, pathError);
	if (pathError || !isInsideRoot(root, resolved, allowRoot))
	{
		error = "Love filesystem path escapes its instance root: " + std::string(filename);
		return false;
	}
	return true;
}

bool resolveMountedEntry(const std::string &root, const std::string &mountpoint,
	std::string_view filename, std::filesystem::path &resolved, bool allowRoot, std::string &error)
{
	std::string_view relative;
	if (mountpoint.empty())
		relative = filename;
	else if (filename == mountpoint)
		relative = {};
	else if (filename.size() > mountpoint.size()
		&& filename.substr(0, mountpoint.size()) == mountpoint
		&& filename[mountpoint.size()] == '/')
		relative = filename.substr(mountpoint.size() + 1);
	else
		return false;
	return resolveEntryWithinRoot(root, relative, resolved, allowRoot, error);
}

int pushFilesystemFailure(lua_State *state, const std::string &message)
{
	lua_pushnil(state);
	lua_pushlstring(state, message.data(), message.size());
	return 2;
}

bool resolveWritableEntry(LoveRuntime *runtime, std::string_view filename,
	std::filesystem::path &resolved, bool allowRoot, std::string &error)
{
	// A leading slash is accepted as a read-only virtual-root spelling for
	// compatibility, but writes remain explicitly relative to the identity
	// directory so no game can confuse them with host absolute paths.
	if (filename.starts_with('/'))
	{
		error = "Love filesystem write path must be relative: " + std::string(filename);
		return false;
	}
	if (runtime == nullptr || runtime->getSaveRoot().empty())
	{
		error = "Love filesystem save directory is not configured";
		return false;
	}
	auto *backend = runtime->getFilesystemBackend();
	if (backend == nullptr)
	{
		error = "Love filesystem is not attached to a Dora Content backend";
		return false;
	}
	if (!backend->createFolder(runtime->getSaveRoot(), error))
		return false;
	return resolveEntryWithinRoot(runtime->getSaveRoot(), filename, resolved, allowRoot, error);
}

const char *fileModeName(FileMode mode)
{
	switch (mode)
	{
		case FileMode::Read: return "r";
		case FileMode::Write: return "w";
		case FileMode::Append: return "a";
		default: return "c";
	}
}

bool parseFileMode(std::string_view name, FileMode &mode)
{
	if (name == "r") mode = FileMode::Read;
	else if (name == "w") mode = FileMode::Write;
	else if (name == "a") mode = FileMode::Append;
	else if (name == "c") mode = FileMode::Closed;
	else return false;
	return true;
}

bool flushFile(FileUserdata *file, std::string &error)
{
	if (!file || !file->runtime || (file->mode != FileMode::Write && file->mode != FileMode::Append))
	{
		error = "File is not open for writing";
		return false;
	}
	std::filesystem::path target;
	if (!resolveWritableEntry(file->runtime, file->filename, target, false, error))
		return false;
	auto *backend = file->runtime->getFilesystemBackend();
	if (!backend->isFolder(target.parent_path().string()))
	{
		error = "Love filesystem parent directory does not exist: " + file->filename;
		return false;
	}
	if (!backend->save(target.string(), file->data, error))
	{
		if (error.empty()) error = "failed to write Love filesystem file: " + file->filename;
		return false;
	}
	error.clear();
	return true;
}

bool openFile(FileUserdata *file, FileMode mode, std::string &error)
{
	if (!file || !file->runtime || !file->runtime->getFilesystemBackend())
	{
		error = "Love filesystem is not attached to a Dora Content backend";
		return false;
	}
	if (mode == FileMode::Closed)
	{
		file->mode = FileMode::Closed;
		file->position = 0;
		return true;
	}
	std::string data;
	if (mode == FileMode::Read)
	{
		std::string resolved;
		if (!file->runtime->resolveReadPath(file->filename, resolved, error)
			|| !file->runtime->getFilesystemBackend()->load(resolved, data, error))
		{
			if (error.empty()) error = "failed to open Love filesystem file for reading: " + file->filename;
			return false;
		}
	}
	else
	{
		std::filesystem::path target;
		if (!resolveWritableEntry(file->runtime, file->filename, target, false, error))
			return false;
		auto *backend = file->runtime->getFilesystemBackend();
		if (!backend->isFolder(target.parent_path().string()))
		{
			error = "Love filesystem parent directory does not exist: " + file->filename;
			return false;
		}
		if (mode == FileMode::Append && backend->exist(target.string())
			&& !backend->load(target.string(), data, error))
			return false;
		if (!backend->save(target.string(), data, error))
		{
			if (error.empty()) error = "failed to create Love filesystem file: " + file->filename;
			return false;
		}
	}
	file->data = std::move(data);
	file->mode = mode;
	file->position = mode == FileMode::Append ? file->data.size() : 0;
	error.clear();
	return true;
}
} // namespace

LoveRuntime::~LoveRuntime()
{
	close();
}

void LoveRuntime::releaseLoveImage(GraphicsBackend::ImageHandle handle) noexcept
{
	if (handle != 0 && _imageHandles.erase(handle) != 0 && _graphicsBackend)
		_graphicsBackend->releaseImage(handle);
}

void LoveRuntime::retainLoveImageHandle(GraphicsBackend::ImageHandle handle) noexcept
{
	if (handle != 0) _imageHandles.insert(handle);
}

void LoveRuntime::forgetLoveImageHandle(GraphicsBackend::ImageHandle handle) noexcept
{
	_imageHandles.erase(handle);
}

void LoveRuntime::retainLoveCanvasHandle(GraphicsBackend::CanvasHandle handle) noexcept
{
	if (handle != 0) _canvasHandles.insert(handle);
}

void LoveRuntime::releaseLoveCanvas(GraphicsBackend::CanvasHandle handle) noexcept
{
	if (handle != 0 && _canvasHandles.erase(handle) != 0 && _graphicsBackend)
		_graphicsBackend->releaseCanvas(handle);
}

void LoveRuntime::forgetLoveCanvasHandle(GraphicsBackend::CanvasHandle handle) noexcept
{
	_canvasHandles.erase(handle);
}

void LoveRuntime::retainLoveFontHandle(GraphicsBackend::FontHandle handle) noexcept
{
	if (handle != 0) _fontHandles.insert(handle);
}

void LoveRuntime::releaseLoveFont(GraphicsBackend::FontHandle handle) noexcept
{
	if (handle != 0 && _fontHandles.erase(handle) != 0 && _graphicsBackend)
		_graphicsBackend->releaseFont(handle);
}

void LoveRuntime::forgetLoveFontHandle(GraphicsBackend::FontHandle handle) noexcept
{
	_fontHandles.erase(handle);
}

void LoveRuntime::retainLoveShaderHandle(GraphicsBackend::ShaderHandle handle) noexcept
{
	if (handle != 0) _shaderHandles.insert(handle);
}

void LoveRuntime::releaseLoveShader(GraphicsBackend::ShaderHandle handle) noexcept
{
	if (handle != 0 && _shaderHandles.erase(handle) != 0 && _graphicsBackend)
		_graphicsBackend->releaseShader(handle);
}

void LoveRuntime::forgetLoveShaderHandle(GraphicsBackend::ShaderHandle handle) noexcept
{
	_shaderHandles.erase(handle);
}

void LoveRuntime::retainLoveAudioSourceHandle(AudioBackend::SourceHandle handle) noexcept
{
	if (handle != 0) _audioHandles.insert(handle);
}

void LoveRuntime::releaseLoveAudioSource(AudioBackend::SourceHandle handle) noexcept
{
	if (handle == 0) return;
	_audioSourceFilters.erase(handle);
	_audioSourceEffects.erase(handle);
	if (_audioHandles.erase(handle) != 0 && _audioBackend)
		_audioBackend->releaseSource(handle);
}

void LoveRuntime::forgetLoveAudioSourceHandle(AudioBackend::SourceHandle handle) noexcept
{
	_audioSourceFilters.erase(handle);
	_audioSourceEffects.erase(handle);
	_audioHandles.erase(handle);
}

void LoveRuntime::retainLoveCursorHandle(MouseBackend::CursorHandle handle) noexcept
{
	if (handle != 0) _mouseCursorHandles.insert(handle);
}

void LoveRuntime::releaseLoveCursor(MouseBackend::CursorHandle handle) noexcept
{
	if (handle != 0 && _mouseCursorHandles.erase(handle) != 0 && _mouseBackend)
		_mouseBackend->releaseCursor(handle);
}

void LoveRuntime::forgetLoveCursorHandle(MouseBackend::CursorHandle handle) noexcept
{
	_mouseCursorHandles.erase(handle);
}

void LoveRuntime::retainLoveRecordingHandle(AudioBackend::RecordingHandle handle) noexcept
{
	if (handle != 0) _recordingHandles.insert(handle);
}

void LoveRuntime::stopLoveRecording(AudioBackend::RecordingHandle handle) noexcept
{
	if (handle != 0 && _recordingHandles.erase(handle) != 0 && _audioBackend)
		_audioBackend->stopRecording(handle);
}

void LoveRuntime::forgetLoveRecordingHandle(AudioBackend::RecordingHandle handle) noexcept
{
	_recordingHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsWorldHandle(PhysicsBackend::WorldHandle handle) noexcept
{
	if (handle != 0) _physicsWorldHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsWorld(PhysicsBackend::WorldHandle handle) noexcept
{
	if (handle != 0 && _physicsWorldHandles.erase(handle) != 0 && _physicsBackend
		&& _physicsBackend->isWorldValid(handle))
		_physicsBackend->releaseWorld(handle);
}

void LoveRuntime::forgetLovePhysicsWorldHandle(PhysicsBackend::WorldHandle handle) noexcept
{
	_physicsWorldHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsBodyHandle(PhysicsBackend::BodyHandle handle) noexcept
{
	if (handle != 0) _physicsBodyHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsBody(PhysicsBackend::BodyHandle handle) noexcept
{
	if (handle != 0 && _physicsBodyHandles.erase(handle) != 0 && _physicsBackend
		&& _physicsBackend->isBodyValid(handle))
		_physicsBackend->releaseBody(handle);
}

void LoveRuntime::forgetLovePhysicsBodyHandle(PhysicsBackend::BodyHandle handle) noexcept
{
	_physicsBodyHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsShapeHandle(PhysicsBackend::ShapeHandle handle) noexcept
{
	if (handle != 0) _physicsShapeHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsShape(PhysicsBackend::ShapeHandle handle) noexcept
{
	if (handle != 0 && _physicsShapeHandles.erase(handle) != 0 && _physicsBackend)
		_physicsBackend->releaseShape(handle);
}

void LoveRuntime::forgetLovePhysicsShapeHandle(PhysicsBackend::ShapeHandle handle) noexcept
{
	_physicsShapeHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsFixtureHandle(PhysicsBackend::FixtureHandle handle) noexcept
{
	if (handle != 0) _physicsFixtureHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsFixture(PhysicsBackend::FixtureHandle handle) noexcept
{
	if (handle != 0 && _physicsFixtureHandles.erase(handle) != 0 && _physicsBackend
		&& _physicsBackend->isFixtureValid(handle))
		_physicsBackend->releaseFixture(handle);
}

void LoveRuntime::forgetLovePhysicsFixtureHandle(PhysicsBackend::FixtureHandle handle) noexcept
{
	_physicsFixtureHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsJointHandle(PhysicsBackend::JointHandle handle) noexcept
{
	if (handle != 0) _physicsJointHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsJoint(PhysicsBackend::JointHandle handle) noexcept
{
	if (handle != 0 && _physicsJointHandles.erase(handle) != 0 && _physicsBackend
		&& _physicsBackend->isJointValid(handle))
		_physicsBackend->releaseJoint(handle);
}

void LoveRuntime::forgetLovePhysicsJointHandle(PhysicsBackend::JointHandle handle) noexcept
{
	_physicsJointHandles.erase(handle);
}

void *LoveRuntime::luaAllocator(void *userdata, void *pointer, std::size_t oldSize, std::size_t newSize)
{
	auto *runtime = static_cast<LoveRuntime *>(userdata);
	if (newSize == 0)
	{
		std::free(pointer);
		if (pointer != nullptr)
			runtime->_allocationBytes -= std::min(runtime->_allocationBytes, oldSize);
		return nullptr;
	}

	void *newPointer = std::realloc(pointer, newSize);
	if (newPointer == nullptr)
		return nullptr;

	if (pointer == nullptr)
		runtime->_allocationBytes += newSize;
	else if (newSize >= oldSize)
		runtime->_allocationBytes += newSize - oldSize;
	else
		runtime->_allocationBytes -= std::min(runtime->_allocationBytes, oldSize - newSize);

	runtime->_peakAllocationBytes = std::max(runtime->_peakAllocationBytes, runtime->_allocationBytes);
	return newPointer;
}

bool LoveRuntime::open(std::string &error)
{
	if (_state != nullptr)
	{
		error = "LoveRuntime is already open";
		return false;
	}

	if (!_threadContext)
	{
		_threadContext = std::make_shared<ThreadContext>();
		_ownsThreadContext = true;
	}
	_allocationBytes = 0;
	_peakAllocationBytes = 0;
	_state = lua_newstate(luaAllocator, this, luaL_makeseed(nullptr));
	if (_state == nullptr)
	{
		if (_ownsThreadContext) _threadContext.reset();
		_ownsThreadContext = false;
		error = "failed to create Love Lua 5.5 state";
		return false;
	}
	// LÖVE 11.5 embeds LuaJIT/Lua 5.1 semantics, where loop variables can be
	// reassigned. Keep this compatibility local to the isolated Love state.
	lua_setloopvarcompat(_state, 1);
	lua_pushlightuserdata(_state, this);
	lua_setfield(_state, LUA_REGISTRYINDEX, LoveRuntimeRegistry);

	luaL_openlibs(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, runtimePrint, 1);
	lua_setglobal(_state, "print");
	// LOVE Reference instances (used by compatibility bridges while userdata
	// types are migrated incrementally) require a pinned thread for unref.
	::love::luax_insistpinnedthread(_state);
	static constexpr std::string_view compatibility = R"lua(
unpack = table.unpack
table.getn = table.getn or function(value)
	return #value
end
math.pow = math.pow or function(base, exponent)
	return base ^ exponent
end
math.atan2 = math.atan2 or function(y, x)
	return math.atan(y, x)
end
local native_require = require
require = function(name)
	-- Lua 5.2+ also returns loader data. LuaJIT/Lua 5.1 LÖVE code
	-- expects one result, especially when require is the final argument.
	return (native_require(name))
end
local native_load = load
load = function(chunk, chunkname, mode, env)
	if type(chunk) == "string" and chunk:byte(1) == 0x1b then
		if chunk:sub(2, 3) == "LJ" then
			return nil, "Dora Love runtime uses Lua 5.5 and cannot load LuaJIT bytecode; provide Lua source or recompile it with Lua 5.5"
		end
		if chunk:sub(2, 4) == "Lua" and chunk:byte(5) ~= 0x55 then
			local version = chunk:byte(5) or 0
			return nil, ("Dora Love runtime uses Lua 5.5 and cannot load Lua %d.%d bytecode; provide Lua source or recompile it with Lua 5.5")
				:format(version >> 4, version & 0x0f)
		end
	end
	-- Passing an explicit nil environment to Lua 5.5 creates a chunk whose
	-- _ENV is nil. LuaJIT loadstring omits that argument and inherits _G.
	if env == nil then return native_load(chunk, chunkname, mode) end
	return native_load(chunk, chunkname, mode, env)
end
loadstring = load
package.loaders = package.searchers
package.loadlib = function()
	error("Dora Love runtime uses Lua 5.5 and does not support native Lua modules", 0)
end

local compatibility_global = _G
local compatibility_type = type
local compatibility_error = error
local compatibility_native_randomseed = math.randomseed
local compatibility_native_random = math.random
local compatibility_getinfo = debug.getinfo
local compatibility_getupvalue = debug.getupvalue
local compatibility_upvaluejoin = debug.upvaluejoin
local compatibility_noenv = setmetatable({}, {__mode = "k"})

-- LuaJIT's math.randomseed accepts any finite number, while Lua 5.5 requires
-- an exact integer. Existing Love games commonly seed it from getTime(), so
-- truncate fractional inputs just like LuaJIT-compatible numeric C APIs.
math.randomseed = function(seed, stream)
	if compatibility_type(seed) == "number" and math.tointeger(seed) == nil then
		seed = seed < 0 and math.ceil(seed) or math.floor(seed)
	end
	if compatibility_type(stream) == "number" and math.tointeger(stream) == nil then
		stream = stream < 0 and math.ceil(stream) or math.floor(stream)
	end
	return compatibility_native_randomseed(seed, stream)
end

-- LuaJIT's numeric C API truncates finite numeric bounds toward zero. Lua 5.5
-- requires exact integer values, so preserve the behavior expected by older
-- LÖVE games without changing Dora's main Lua state.
math.random = function(lower, upper)
	if lower == nil then return compatibility_native_random() end
	if compatibility_type(lower) == "number" and math.tointeger(lower) == nil then
		lower = lower < 0 and math.ceil(lower) or math.floor(lower)
	end
	if upper == nil then return compatibility_native_random(lower) end
	if compatibility_type(upper) == "number" and math.tointeger(upper) == nil then
		upper = upper < 0 and math.ceil(upper) or math.floor(upper)
	end
	return compatibility_native_random(lower, upper)
end

local function compatibility_function(selector, api)
	local kind = compatibility_type(selector)
	if kind == "function" then
		return selector, selector
	end
	if kind ~= "number" or selector < 0 or selector % 1 ~= 0 then
		compatibility_error(("bad argument #1 to '%s' (function or non-negative integer expected)"):format(api), 3)
	end
	if selector == 0 then
		return nil, selector
	end
	local info = compatibility_getinfo(selector + 2, "f")
	if info == nil then
		compatibility_error("invalid level", 3)
	end
	return info.func, selector
end

local function compatibility_env_upvalue(func)
	local index = 1
	while true do
		local name, value = compatibility_getupvalue(func, index)
		if name == nil then return nil end
		if name == "_ENV" then return index, value end
		index = index + 1
	end
end

getfenv = function(selector)
	if selector == nil then selector = 1 end
	local func = compatibility_function(selector, "getfenv")
	if func == nil then return compatibility_global end
	local info = compatibility_getinfo(func, "S")
	if info == nil or (info.what ~= "Lua" and info.what ~= "main") then
		return compatibility_global
	end
	local _, env = compatibility_env_upvalue(func)
	return env or compatibility_noenv[func] or compatibility_global
end

setfenv = function(selector, env)
	if compatibility_type(env) ~= "table" then
		compatibility_error("bad argument #2 to 'setfenv' (table expected)", 2)
	end
	local func, original = compatibility_function(selector, "setfenv")
	if func == nil then
		compatibility_error("Dora Love runtime uses Lua 5.5 and cannot replace the running thread environment with setfenv(0, env)", 2)
	end
	local info = compatibility_getinfo(func, "S")
	if info == nil or (info.what ~= "Lua" and info.what ~= "main") then
		compatibility_error("setfenv cannot change the environment of a C function", 2)
	end
	local index = compatibility_env_upvalue(func)
	if index == nil then
		compatibility_noenv[func] = env
	else
		local function holder() return env end
		compatibility_upvaluejoin(func, index, holder, 1)
	end
	return original
end

package.preload.ffi = function()
	error("Dora Love runtime uses Lua 5.5 and does not support LuaJIT ffi", 0)
end

package.preload.jit = function()
	error("Dora Love runtime uses Lua 5.5 and does not provide the LuaJIT compiler", 0)
end

package.preload.bit = function()
	local bit = {}
	local mask = 0xffffffff
	local function tobit(value)
		value = math.tointeger(value) & mask
		if value >= 0x80000000 then return value - 0x100000000 end
		return value
	end
	bit.tobit = tobit
	function bit.bnot(value) return tobit(~math.tointeger(value)) end
	function bit.band(value, ...)
		local result = math.tointeger(value)
		for index = 1, select("#", ...) do result = result & math.tointeger(select(index, ...)) end
		return tobit(result)
	end
	function bit.bor(value, ...)
		local result = math.tointeger(value)
		for index = 1, select("#", ...) do result = result | math.tointeger(select(index, ...)) end
		return tobit(result)
	end
	function bit.bxor(value, ...)
		local result = math.tointeger(value)
		for index = 1, select("#", ...) do result = result ~ math.tointeger(select(index, ...)) end
		return tobit(result)
	end
	function bit.lshift(value, shift) return tobit((math.tointeger(value) & mask) << (math.tointeger(shift) & 31)) end
	function bit.rshift(value, shift) return ((math.tointeger(value) & mask) >> (math.tointeger(shift) & 31)) & mask end
	function bit.arshift(value, shift)
		shift = math.tointeger(shift) & 31
		return tobit(math.floor(tobit(value) / (2 ^ shift)))
	end
	function bit.rol(value, shift)
		shift = math.tointeger(shift) & 31
		local input = math.tointeger(value) & mask
		if shift == 0 then return tobit(input) end
		return tobit((input << shift) | (input >> (32 - shift)))
	end
	function bit.ror(value, shift) return bit.rol(value, -(math.tointeger(shift) & 31)) end
	function bit.tohex(value, digits)
		digits = digits or 8
		local upper = digits < 0
		digits = math.min(math.abs(math.tointeger(digits)), 8)
		local text = string.format("%08x", math.tointeger(value) & mask):sub(9 - digits)
		return upper and text:upper() or text
	end
	return bit
end
)lua";
	if (luaL_loadbufferx(_state, compatibility.data(), compatibility.size(), "@dora-love-compat.lua", "t") != LUA_OK
		|| lua_pcall(_state, 0, 0, 0) != LUA_OK)
	{
		error = lua_tostring(_state, -1);
		close();
		return false;
	}
	if (!dora_open_builtin_modules(_state, error))
	{
		close();
		return false;
	}
	for (const auto &[name, code] : _preloadModules)
	{
		if (!installPreloadModule(name, code, error))
		{
			close();
			return false;
		}
	}
	registerImageType();
	registerCanvasType();
	registerImageDataType();
	registerCompressedImageDataType();
	registerRasterizerType();
	registerGlyphDataType();
	registerSoundDataType();
	registerDecoderType();
	registerRandomGeneratorType();
	registerTransformType();
	registerBezierCurveType();
	registerByteDataType();
	registerDataViewType();
	registerCompressedDataType();
	registerQuadType();
	registerMeshType();
	registerSpriteBatchType();
	registerParticleSystemType();
	registerTextType();
	registerShaderType();
	registerFontType();
	registerAudioSourceType();
	registerVideoTypes();
	registerRecordingDeviceType();
	registerCursorType();
	registerJoystickType();
	registerFileType();
	registerFileDataType();
	registerThreadTypes();
	registerPhysicsTypes();
	registerLoveModule();
	_graphicsColor[0] = _graphicsColor[1] = _graphicsColor[2] = _graphicsColor[3] = 1.0f;
	_graphicsBackgroundColor[0] = _graphicsBackgroundColor[1] = _graphicsBackgroundColor[2] = 0.0f;
	_graphicsBackgroundColor[3] = 1.0f;
	_graphicsDefaultFilter = GraphicsBackend::TextureFilter::Linear;
	_graphicsDefaultAnisotropy = 1.0f;
	_graphicsLineWidth = 1.0f;
	_graphicsLineStyle = GraphicsBackend::LineStyle::Smooth;
	_graphicsLineJoin = GraphicsBackend::LineJoin::Miter;
	_graphicsPointSize = 1.0f;
	_graphicsBlendMode = "alpha";
	_graphicsBlendAlphaMode = "alphamultiply";
	_graphicsScissorEnabled = false;
	std::fill(std::begin(_graphicsScissor), std::end(_graphicsScissor), 0.0f);
	std::fill(std::begin(_graphicsColorMask), std::end(_graphicsColorMask), true);
	_graphicsDepthCompare = "always";
	_graphicsDepthWrite = false;
	_graphicsMeshCullMode = "none";
	_graphicsFrontFaceWinding = "ccw";
	_graphicsWireframe = false;
	_graphicsStencilTestEnabled = false;
	_graphicsStencilCompare = "always";
	_graphicsStencilValue = 0;
	_graphicsStencilWriting = false;
	_graphicsCanvasDepthStencil = 0;
	_graphicsCanvasDepthStencilTarget = {};
	_graphicsCanvasDepthStencilReference = LUA_NOREF;
	_graphicsCanvasDepth = false;
	_graphicsCanvasStencil = false;
	_graphicsShader = 0;
	_graphicsShaderReference = LUA_NOREF;
	_graphicsShaderObject.set(nullptr);
	if (_graphicsBackend)
	{
		if (!_graphicsBackend->setBlendMode(_graphicsBlendMode, _graphicsBlendAlphaMode, error))
		{
			close();
			return false;
		}
		_graphicsBackend->setScissor(false, 0.0f, 0.0f, 0.0f, 0.0f);
		_graphicsBackend->setColorMask(true, true, true, true);
		_graphicsBackend->setDepthMode(_graphicsDepthCompare, _graphicsDepthWrite);
		_graphicsBackend->setMeshCullMode(_graphicsMeshCullMode, _graphicsFrontFaceWinding);
		_graphicsBackend->setWireframe(_graphicsWireframe);
		_graphicsBackend->setStencilTest(_graphicsStencilCompare, _graphicsStencilValue);
	}
	_configuredWidth = DefaultWindowWidth;
	_configuredHeight = DefaultWindowHeight;
	_windowResizable = false;
	_windowTitle = "Untitled";
	_windowVSync = 1;
	_windowDisplaySleepEnabled = false;
	_sourceRoot.clear();
	_saveBaseRoot.clear();
	_saveRoot.clear();
	_identity.clear();
	_requirePath = {"?.lua", "?/init.lua"};
	_generatedLineMaps.clear();
	resetGraphicsTransform();
	_graphicsStateStack.clear();
	_graphicsCanvases.clear();
	_graphicsCanvasTargets.clear();
	_graphicsCanvasReferences.clear();
	_graphicsCanvasObjects.clear();
	_graphicsCanvasDepthStencilObject.set(nullptr);
	_screenshotRequests.clear();
	_nextScreenshotRequest = 1;
	clearQueuedEvents();
	_pressedKeys.clear();
	_pressedScancodes.clear();
	_keyRepeatEnabled = false;
	_pressedMouseButtons.clear();
	_touches.clear();
	_fontHandles.clear();
	_imageHandles.clear();
	_canvasHandles.clear();
	_shaderHandles.clear();
	_audioHandles.clear();
	_recordingHandles.clear();
	_physicsWorldHandles.clear();
	_physicsBodyHandles.clear();
	_physicsShapeHandles.clear();
	_physicsFixtureHandles.clear();
	_physicsJointHandles.clear();
	_audioEffects.clear();
	_audioSourceFilters.clear();
	_audioSourceEffects.clear();
	_audioVolume = 1.0f;
	if (_audioBackend)
		_audioBackend->setInstanceVolume(_audioVolume);
	_physicsMeter = 30.0f;
	if (_physicsBackend)
		_physicsBackend->setMeter(_physicsMeter);
	_currentFont = 0;
	_graphicsFontObject.set(nullptr);
	_mouseX = _mouseY = 0.0f;
	_mouseVisible = true;
	_mouseGrabbed = false;
	_mouseRelativeMode = false;
	_mouseCursor = 0;
	_mouseCursorReference = LUA_NOREF;
	_mouseCursorObject.set(nullptr);
	_systemCursorReferences.clear();
	_systemCursorObjects.clear();
	_mouseCursorHandles.clear();
	_timerOrigin = steadySeconds();
	_timerDelta = 0.0;
	_timerAverageDelta = 0.0;
	_timerWindow = 0.0;
	_timerFrames = 0;
	_timerFPS = 0;
	_status = Status::Ready;
	_lastError.clear();
	error.clear();
	return true;
}

int LoveRuntime::runtimePrint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int argumentCount = lua_gettop(state);
	std::string output;
	for (int index = 1; index <= argumentCount; ++index)
	{
		std::size_t length = 0;
		const char *text = luaL_tolstring(state, index, &length);
		if (index > 1) output.push_back('\t');
		output.append(text, length);
		lua_pop(state, 1);
	}
	const std::string_view identity = runtime && !runtime->_identity.empty()
		? std::string_view(runtime->_identity) : std::string_view("runtime");
	LogInfoThreaded("[Love:" + std::string(identity) + "] " + output);
	return 0;
}

bool LoveRuntime::installPreloadModule(std::string_view name, std::string_view code,
	std::string &error)
{
	const int base = lua_gettop(_state);
	const std::string chunkName = "@dora-preload/" + std::string(name) + ".lua";
	if (loadLoveChunk(_state, code, chunkName.c_str()) != LUA_OK)
	{
		error = lua_tostring(_state, -1);
		lua_settop(_state, base);
		return false;
	}
	lua_getglobal(_state, "package");
	lua_getfield(_state, -1, "preload");
	lua_pushvalue(_state, base + 1);
	lua_setfield(_state, -2, std::string(name).c_str());
	lua_settop(_state, base);
	error.clear();
	return true;
}

bool LoveRuntime::setPreloadModule(std::string_view name, std::string_view code,
	std::string &error)
{
	if (name.empty() || name.front() == '.' || name.back() == '.'
		|| name.find("..") != std::string_view::npos
		|| name.find('/') != std::string_view::npos || name.find('\\') != std::string_view::npos)
	{
		error = "invalid Love preload module name: " + std::string(name);
		return false;
	}
	if (_status != Status::Closed && _status != Status::Ready)
	{
		error = "Love preload modules can only be changed while the runtime is closed or ready";
		return false;
	}
	_preloadModules[std::string(name)] = std::string(code);
	if (_state != nullptr && !installPreloadModule(name, code, error))
	{
		_preloadModules.erase(std::string(name));
		return false;
	}
	error.clear();
	return true;
}

void LoveRuntime::close()
{
	if (_state == nullptr)
		return;
	if (_ownsThreadContext && _threadContext)
	{
		_threadContext->stopping.store(true, std::memory_order_release);
		{
			std::lock_guard lock(_threadContext->filesystemMutex);
			for (const auto &request : _threadContext->filesystemRequests)
				request->changed.notify_all();
		}
		std::vector<std::shared_ptr<ThreadChannel>> channels;
		std::vector<std::shared_ptr<ThreadWorker>> workers;
		{
			std::lock_guard lock(_threadContext->mutex);
			for (const auto &weak : _threadContext->channels)
				if (auto channel = weak.lock()) channels.push_back(std::move(channel));
			workers = _threadContext->workers;
		}
		for (const auto &channel : channels) channel->changed.notify_all();
		for (const auto &worker : workers)
			if (worker && worker->worker.joinable()) worker->worker.join();
		{
			std::lock_guard lock(_threadContext->mutex);
			_threadContext->workers.clear();
			_threadContext->channels.clear();
			_threadContext->namedChannels.clear();
		}
		{
			std::lock_guard lock(_threadContext->errorMutex);
			_threadContext->pendingErrors.clear();
		}
		{
			std::lock_guard lock(_threadContext->filesystemMutex);
			_threadContext->filesystemRequests.clear();
		}
	}
	_threadWorkers.clear();
	if (_graphicsBackend)
	{
		std::string ignored;
		if (_graphicsStencilWriting)
			_graphicsBackend->endStencilWrite();
		_graphicsBackend->setCanvases({}, 0, false, false, ignored);
		_graphicsBackend->setShader(0, ignored);
	}

	_screenshotRequests.clear();
	clearQueuedEvents();
	clearMountedArchives();
	lua_close(_state);
	_state = nullptr;
	while (!_mouseCursorHandles.empty())
		releaseLoveCursor(*_mouseCursorHandles.begin());
	_systemCursorReferences.clear();
	_systemCursorObjects.clear();
	_mouseCursor = 0;
	_mouseCursorReference = LUA_NOREF;
	_mouseCursorObject.set(nullptr);
	_physicsFixtureReferences.clear();
	_physicsContactReferences.clear();
	_physicsFixtureObjects.clear();
	_physicsContactObjects.clear();
	_physicsWorldCallbacks.clear();
	if (_audioBackend)
	{
		std::string ignored;
		for (const auto &[name, _] : _audioEffects)
			_audioBackend->setEffect(name, nullptr, ignored);
	}
	while (!_recordingHandles.empty())
		stopLoveRecording(*_recordingHandles.begin());
	while (!_audioHandles.empty())
		releaseLoveAudioSource(*_audioHandles.begin());
	_audioEffects.clear();
	_audioSourceFilters.clear();
	_audioSourceEffects.clear();
	// lua_close does not guarantee that every still-referenced Shader userdata
	// reaches our __gc path before the state disappears. Release any remaining
	// backend handles explicitly, and do it before Canvas handles so Shader
	// sampler bindings cannot retain their textures past Runtime shutdown.
	while (!_shaderHandles.empty())
		releaseLoveShader(*_shaderHandles.begin());
	while (!_imageHandles.empty())
		releaseLoveImage(*_imageHandles.begin());
	while (!_canvasHandles.empty())
		releaseLoveCanvas(*_canvasHandles.begin());
	while (!_fontHandles.empty())
		releaseLoveFont(*_fontHandles.begin());
	// A parent Physics destroy can invalidate several child handles at once.
	// Drain owned handles from leaves to roots so Runtime close never depends
	// on Lua finalizer order and each surviving Dora handle is released once.
	while (!_physicsJointHandles.empty())
		releaseLovePhysicsJoint(*_physicsJointHandles.begin());
	while (!_physicsFixtureHandles.empty())
		releaseLovePhysicsFixture(*_physicsFixtureHandles.begin());
	while (!_physicsBodyHandles.empty())
		releaseLovePhysicsBody(*_physicsBodyHandles.begin());
	while (!_physicsWorldHandles.empty())
		releaseLovePhysicsWorld(*_physicsWorldHandles.begin());
	while (!_physicsShapeHandles.empty())
		releaseLovePhysicsShape(*_physicsShapeHandles.begin());
	_canvasHandles.clear();
	_imageHandles.clear();
	_shaderHandles.clear();
	_recordingHandles.clear();
	_physicsWorldHandles.clear();
	_physicsBodyHandles.clear();
	_physicsShapeHandles.clear();
	_physicsFixtureHandles.clear();
	_physicsJointHandles.clear();
	_graphicsCanvases.clear();
	_graphicsCanvasTargets.clear();
	_graphicsCanvasReferences.clear();
	_graphicsCanvasObjects.clear();
	_graphicsCanvasDepthStencil = 0;
	_graphicsCanvasDepthStencilTarget = {};
	_graphicsCanvasDepthStencilReference = LUA_NOREF;
	_graphicsCanvasDepthStencilObject.set(nullptr);
	_graphicsCanvasDepth = false;
	_graphicsCanvasStencil = false;
	_graphicsShader = 0;
	_graphicsShaderReference = LUA_NOREF;
	_graphicsShaderObject.set(nullptr);
	_graphicsStencilWriting = false;
	_graphicsStateStack.clear();
	_fontHandles.clear();
	_currentFont = 0;
	_graphicsFontObject.set(nullptr);
	_status = Status::Closed;
	_lastError.clear();
	_bootCode.clear();
	_bootChunkName.clear();
	_generatedLineMaps.clear();
	_sourceRoot.clear();
	_saveBaseRoot.clear();
	_saveRoot.clear();
	_identity.clear();
	_requirePath.clear();
	_pressedKeys.clear();
	_pressedScancodes.clear();
	_keyRepeatEnabled = false;
	_pressedMouseButtons.clear();
	_touches.clear();
	if (_joystickBackend)
	{
		for (const auto &[id, joystick] : _joysticks)
		{
			if (joystick.connected && (joystick.vibrationLeft > 0.0f || joystick.vibrationRight > 0.0f))
				_joystickBackend->setJoystickVibration(id, 0.0f, 0.0f, 0.0);
		}
	}
	_joysticks.clear();
	_textInputEnabled = true;
	_threadContext.reset();
	_ownsThreadContext = false;
}

void LoveRuntime::releaseQueuedEvent(QueuedEvent &event) noexcept
{
	if (_state && event.registryReference != LUA_NOREF)
		luaL_unref(_state, LUA_REGISTRYINDEX, event.registryReference);
	event.registryReference = LUA_NOREF;
}

void LoveRuntime::clearQueuedEvents() noexcept
{
	for (auto &event : _eventQueue)
		releaseQueuedEvent(event);
	_eventQueue.clear();
}

void LoveRuntime::drainThreadErrors()
{
	if (!_state || !_threadContext) return;
	std::vector<std::pair<std::weak_ptr<ThreadWorker>, std::string>> errors;
	{
		std::lock_guard lock(_threadContext->errorMutex);
		errors.swap(_threadContext->pendingErrors);
	}
	for (auto &[weakWorker, message] : errors)
	{
		auto worker = weakWorker.lock();
		if (!worker) continue;
		lua_createtable(_state, 2, 0);
		pushThread(_state, worker);
		lua_rawseti(_state, -2, 1);
		lua_pushlstring(_state, message.data(), message.size());
		lua_rawseti(_state, -2, 2);
		QueuedEvent event{QueuedEventType::Custom};
		event.first = "threaderror";
		event.presses = 2;
		event.registryReference = luaL_ref(_state, LUA_REGISTRYINDEX);
		_eventQueue.push_back(std::move(event));
	}
}

void LoveRuntime::drainThreadFilesystemRequests()
{
	if (!_threadContext || !_ownsThreadContext) return;
	std::deque<std::shared_ptr<ThreadFilesystemRequest>> requests;
	{
		std::lock_guard lock(_threadContext->filesystemMutex);
		requests.swap(_threadContext->filesystemRequests);
	}
	for (const auto &request : requests)
	{
		std::unique_lock lock(request->mutex);
		if (!request->cancelled && request->work) request->work();
		request->work = {};
		request->done = true;
		lock.unlock();
		request->changed.notify_all();
	}
}

int LoveRuntime::pushQueuedEventArguments(QueuedEvent &event, const char *&name)
{
	name = nullptr;
	switch (event.type)
	{
		case QueuedEventType::KeyPressed:
			_pressedKeys.insert(event.first);
			_pressedScancodes.insert(event.second);
			name = "keypressed";
			lua_pushlstring(_state, event.first.data(), event.first.size());
			lua_pushlstring(_state, event.second.data(), event.second.size());
			lua_pushboolean(_state, event.flag);
			return 3;
		case QueuedEventType::KeyReleased:
			_pressedKeys.erase(event.first);
			_pressedScancodes.erase(event.second);
			name = "keyreleased";
			lua_pushlstring(_state, event.first.data(), event.first.size());
			lua_pushlstring(_state, event.second.data(), event.second.size());
			return 2;
		case QueuedEventType::TextInput:
			name = "textinput";
			lua_pushlstring(_state, event.first.data(), event.first.size());
			return 1;
		case QueuedEventType::TextEdited:
			name = "textedited";
			lua_pushlstring(_state, event.first.data(), event.first.size());
			lua_pushinteger(_state, event.button);
			lua_pushinteger(_state, event.presses);
			return 3;
		case QueuedEventType::MousePressed:
			_mouseX = event.x;
			_mouseY = event.y;
			_pressedMouseButtons.insert(event.button);
			name = "mousepressed";
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			lua_pushinteger(_state, event.button);
			lua_pushboolean(_state, event.flag);
			lua_pushinteger(_state, event.presses);
			return 5;
		case QueuedEventType::MouseReleased:
			_mouseX = event.x;
			_mouseY = event.y;
			_pressedMouseButtons.erase(event.button);
			name = "mousereleased";
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			lua_pushinteger(_state, event.button);
			lua_pushboolean(_state, event.flag);
			lua_pushinteger(_state, event.presses);
			return 5;
		case QueuedEventType::MouseMoved:
			_mouseX = event.x;
			_mouseY = event.y;
			name = "mousemoved";
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			lua_pushnumber(_state, event.deltaX);
			lua_pushnumber(_state, event.deltaY);
			lua_pushboolean(_state, event.flag);
			return 5;
		case QueuedEventType::WheelMoved:
			name = "wheelmoved";
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			return 2;
		case QueuedEventType::TouchPressed:
		case QueuedEventType::TouchMoved:
		case QueuedEventType::TouchReleased:
			if (event.type == QueuedEventType::TouchReleased)
				_touches.erase(event.touchId);
			else
				_touches[event.touchId] = {event.x, event.y, event.pressure};
			name = event.type == QueuedEventType::TouchPressed ? "touchpressed"
				: event.type == QueuedEventType::TouchMoved ? "touchmoved" : "touchreleased";
			lua_pushlightuserdata(_state, reinterpret_cast<void *>(event.touchId));
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			lua_pushnumber(_state, event.deltaX);
			lua_pushnumber(_state, event.deltaY);
			lua_pushnumber(_state, event.pressure);
			return 6;
		case QueuedEventType::JoystickAdded:
			name = "joystickadded";
			pushJoystick(event.controllerId);
			return 1;
		case QueuedEventType::JoystickRemoved:
			name = "joystickremoved";
			pushJoystick(event.controllerId);
			return 1;
		case QueuedEventType::JoystickPressed:
		case QueuedEventType::JoystickReleased:
			name = event.type == QueuedEventType::JoystickPressed
				? "joystickpressed" : "joystickreleased";
			pushJoystick(event.controllerId);
			lua_pushinteger(_state, event.button + 1);
			return 2;
		case QueuedEventType::JoystickAxis:
			name = "joystickaxis";
			pushJoystick(event.controllerId);
			lua_pushinteger(_state, event.button + 1);
			lua_pushnumber(_state, event.x);
			return 3;
		case QueuedEventType::JoystickHat:
			name = "joystickhat";
			pushJoystick(event.controllerId);
			lua_pushinteger(_state, event.button + 1);
			lua_pushlstring(_state, event.first.data(), event.first.size());
			return 3;
		case QueuedEventType::GamepadPressed:
		{
			auto found = _joysticks.find(event.controllerId);
			if (found == _joysticks.end())
				return -1;
			found->second.buttons.insert(event.first);
			name = "gamepadpressed";
			pushJoystick(event.controllerId);
			lua_pushlstring(_state, event.first.data(), event.first.size());
			return 2;
		}
		case QueuedEventType::GamepadReleased:
		{
			auto found = _joysticks.find(event.controllerId);
			if (found == _joysticks.end())
				return -1;
			found->second.buttons.erase(event.first);
			name = "gamepadreleased";
			pushJoystick(event.controllerId);
			lua_pushlstring(_state, event.first.data(), event.first.size());
			return 2;
		}
		case QueuedEventType::GamepadAxis:
		{
			auto found = _joysticks.find(event.controllerId);
			if (found == _joysticks.end())
				return -1;
			found->second.axes[event.first] = event.x;
			name = "gamepadaxis";
			pushJoystick(event.controllerId);
			lua_pushlstring(_state, event.first.data(), event.first.size());
			lua_pushnumber(_state, event.x);
			return 3;
		}
		case QueuedEventType::Custom:
		{
			name = event.first.c_str();
			if (event.registryReference == LUA_NOREF)
				return 0;
			const int base = lua_gettop(_state);
			lua_rawgeti(_state, LUA_REGISTRYINDEX, event.registryReference);
			for (int index = 1; index <= event.presses; ++index)
				lua_rawgeti(_state, base + 1, index);
			lua_remove(_state, base + 1);
			return event.presses;
		}
		case QueuedEventType::Quit:
			name = "quit";
			if (!event.first.empty())
			{
				lua_pushlstring(_state, event.first.data(), event.first.size());
				return 1;
			}
			if (event.flag)
			{
				lua_pushinteger(_state, event.button);
				return 1;
			}
			return 0;
	}
	return -1;
}

int LoveRuntime::pollQueuedEvent(lua_State *state)
{
	while (!_eventQueue.empty())
	{
		QueuedEvent event = std::move(_eventQueue.front());
		_eventQueue.pop_front();
		const int base = lua_gettop(state);
		const char *name = nullptr;
		const int argumentCount = pushQueuedEventArguments(event, name);
		if (argumentCount < 0 || name == nullptr)
		{
			lua_settop(state, base);
			releaseQueuedEvent(event);
			continue;
		}
		lua_pushstring(state, name);
		lua_insert(state, base + 1);
		releaseQueuedEvent(event);
		return argumentCount + 1;
	}
	return 0;
}

void LoveRuntime::queueKeyPressed(std::string key, std::string scancode, bool repeat)
{
	if (repeat && !_keyRepeatEnabled)
		return;
	_eventQueue.push_back({QueuedEventType::KeyPressed, std::move(key), std::move(scancode),
		0.0f, 0.0f, 0.0f, 0.0f, 0, 0, repeat});
}

void LoveRuntime::queueKeyReleased(std::string key, std::string scancode)
{
	_eventQueue.push_back({QueuedEventType::KeyReleased, std::move(key), std::move(scancode)});
}

void LoveRuntime::queueTextInput(std::string text)
{
	_eventQueue.push_back({QueuedEventType::TextInput, std::move(text)});
}

void LoveRuntime::queueTextEdited(std::string text, int start, int length)
{
	QueuedEvent event{QueuedEventType::TextEdited};
	event.first = std::move(text);
	event.button = start;
	event.presses = length;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueMousePressed(float x, float y, int button, bool touch, int presses)
{
	_eventQueue.push_back({QueuedEventType::MousePressed, {}, {}, x, y, 0.0f, 0.0f, button, presses, touch});
}

void LoveRuntime::queueMouseReleased(float x, float y, int button, bool touch, int presses)
{
	_eventQueue.push_back({QueuedEventType::MouseReleased, {}, {}, x, y, 0.0f, 0.0f, button, presses, touch});
}

void LoveRuntime::queueMouseMoved(float x, float y, float deltaX, float deltaY, bool touch)
{
	_eventQueue.push_back({QueuedEventType::MouseMoved, {}, {}, x, y, deltaX, deltaY, 0, 0, touch});
}

void LoveRuntime::queueWheelMoved(float x, float y)
{
	_eventQueue.push_back({QueuedEventType::WheelMoved, {}, {}, x, y});
}

void LoveRuntime::queueTouchPressed(std::uintptr_t id, float x, float y,
	float deltaX, float deltaY, float pressure)
{
	QueuedEvent event{QueuedEventType::TouchPressed};
	event.x = x;
	event.y = y;
	event.deltaX = deltaX;
	event.deltaY = deltaY;
	event.touchId = id;
	event.pressure = pressure;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueTouchReleased(std::uintptr_t id, float x, float y,
	float deltaX, float deltaY, float pressure)
{
	QueuedEvent event{QueuedEventType::TouchReleased};
	event.x = x;
	event.y = y;
	event.deltaX = deltaX;
	event.deltaY = deltaY;
	event.touchId = id;
	event.pressure = pressure;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueTouchMoved(std::uintptr_t id, float x, float y,
	float deltaX, float deltaY, float pressure)
{
	QueuedEvent event{QueuedEventType::TouchMoved};
	event.x = x;
	event.y = y;
	event.deltaX = deltaX;
	event.deltaY = deltaY;
	event.touchId = id;
	event.pressure = pressure;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::pushJoystick(int id)
{
	auto it = _joysticks.find(id);
	if (it == _joysticks.end())
	{
		lua_pushnil(_state);
		return;
	}
	if (it->second.object)
	{
		::love::luax_pushtype(_state, JoystickLoveType,
			static_cast<JoystickUserdata *>(it->second.object.get()));
		return;
	}
	auto *joystick = new JoystickUserdata;
	joystick->runtime = this;
	joystick->id = id;
	it->second.object.set(joystick);
	::love::luax_pushtype(_state, JoystickLoveType, joystick);
	joystick->release();
}

void LoveRuntime::addJoystick(int id, std::string name, bool notify)
{
	auto [it, inserted] = _joysticks.try_emplace(id);
	const bool wasConnected = !inserted && it->second.connected;
	it->second.name = std::move(name);
	if (_joystickBackend)
		it->second.info = _joystickBackend->getJoystickInfo(id);
	else
		it->second.info.instanceId = id;
	it->second.connected = true;
	if (notify && !wasConnected)
	{
		QueuedEvent event{QueuedEventType::JoystickAdded};
		event.controllerId = id;
		_eventQueue.push_back(std::move(event));
	}
}

void LoveRuntime::removeJoystick(int id, bool notify)
{
	auto it = _joysticks.find(id);
	if (it == _joysticks.end() || !it->second.connected)
		return;
	it->second.connected = false;
	it->second.info.instanceId = -1;
	it->second.buttons.clear();
	it->second.axes.clear();
	it->second.vibrationLeft = 0.0f;
	it->second.vibrationRight = 0.0f;
	it->second.vibrationEndTime = 0.0;
	if (notify)
	{
		QueuedEvent event{QueuedEventType::JoystickRemoved};
		event.controllerId = id;
		_eventQueue.push_back(std::move(event));
	}
}

void LoveRuntime::queueJoystickPressed(int id, int button)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end() || !found->second.connected
		|| button < 0 || button >= found->second.info.buttonCount)
		return;
	QueuedEvent event{QueuedEventType::JoystickPressed};
	event.controllerId = id;
	event.button = button;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueJoystickReleased(int id, int button)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end() || !found->second.connected
		|| button < 0 || button >= found->second.info.buttonCount)
		return;
	QueuedEvent event{QueuedEventType::JoystickReleased};
	event.controllerId = id;
	event.button = button;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueJoystickAxis(int id, int axis, float value)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end() || !found->second.connected
		|| axis < 0 || axis >= found->second.info.axisCount)
		return;
	QueuedEvent event{QueuedEventType::JoystickAxis};
	event.controllerId = id;
	event.button = axis;
	event.x = std::clamp(value, -1.0f, 1.0f);
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueJoystickHat(int id, int hat, std::string direction)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end() || !found->second.connected
		|| hat < 0 || hat >= found->second.info.hatCount)
		return;
	static constexpr std::array<std::string_view, 9> directions = {
		"c", "u", "r", "d", "l", "ru", "rd", "lu", "ld"};
	if (std::find(directions.begin(), directions.end(), direction) == directions.end())
		direction = "c";
	QueuedEvent event{QueuedEventType::JoystickHat};
	event.controllerId = id;
	event.button = hat;
	event.first = std::move(direction);
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueGamepadPressed(int id, std::string button)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end())
		addJoystick(id, "Dora Controller " + std::to_string(id), false);
	else if (!found->second.connected)
		return;
	QueuedEvent event{QueuedEventType::GamepadPressed};
	event.controllerId = id;
	event.first = std::move(button);
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueGamepadReleased(int id, std::string button)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end())
		addJoystick(id, "Dora Controller " + std::to_string(id), false);
	else if (!found->second.connected)
		return;
	QueuedEvent event{QueuedEventType::GamepadReleased};
	event.controllerId = id;
	event.first = std::move(button);
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueGamepadAxis(int id, std::string axis, float value)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end())
		addJoystick(id, "Dora Controller " + std::to_string(id), false);
	else if (!found->second.connected)
		return;
	QueuedEvent event{QueuedEventType::GamepadAxis};
	event.controllerId = id;
	event.first = std::move(axis);
	event.x = std::clamp(value, -1.0f, 1.0f);
	_eventQueue.push_back(std::move(event));
}

bool LoveRuntime::completeScreenshot(std::uint64_t requestId, int width, int height,
	std::vector<std::uint8_t> rgba8, std::string &error)
{
	if (!_state)
	{
		error = "LoveRuntime is closed";
		return false;
	}
	auto found = _screenshotRequests.find(requestId);
	if (found == _screenshotRequests.end())
	{
		error = "Love screenshot request is no longer active";
		return false;
	}
	ScreenshotRequest request = std::move(found->second);
	_screenshotRequests.erase(found);
	const std::size_t expected = width > 0 && height > 0
		? static_cast<std::size_t>(width) * static_cast<std::size_t>(height) * 4 : 0;
	if (expected == 0 || rgba8.size() != expected)
	{
		if (request.callbackReference != LUA_NOREF)
			luaL_unref(_state, LUA_REGISTRYINDEX, request.callbackReference);
		return fail("Dora screenshot backend returned invalid RGBA8 dimensions", error);
	}

	if (request.channel)
	{
		ThreadValue value;
		value.type = ThreadValue::Type::ImageData;
		value.width = width;
		value.height = height;
		value.format = "rgba8";
		value.data = std::move(rgba8);
		{
			std::lock_guard<std::recursive_mutex> lock(request.channel->mutex);
			const std::uint64_t id = request.channel->nextId++;
			request.channel->values.emplace_back(id, std::move(value));
		}
		request.channel->changed.notify_all();
		error.clear();
		return true;
	}

	if (!request.filename.empty())
	{
		if (!_imageBackend || !_filesystemBackend)
			return fail("Love screenshot encoding is not attached to Dora image and Content backends", error);
		std::vector<std::uint8_t> encoded;
		if (!_imageBackend->encodeImage("png", width, height, rgba8, encoded, error))
			return fail(error.empty() ? "Dora image backend failed to encode Love screenshot" : error, error);
		if (encoded.empty())
			return fail("Dora image backend returned an empty Love screenshot", error);
		if (!_filesystemBackend->save(request.filename,
			std::string_view(reinterpret_cast<const char *>(encoded.data()), encoded.size()), error))
			return fail(error.empty() ? "Dora Content failed to save Love screenshot" : error, error);
		error.clear();
		return true;
	}

	const int stackBase = lua_gettop(_state);
	lua_pushcfunction(_state, traceback);
	const int errorHandler = stackBase + 1;
	lua_rawgeti(_state, LUA_REGISTRYINDEX, request.callbackReference);
	luaL_unref(_state, LUA_REGISTRYINDEX, request.callbackReference);
	pushImageData(_state, this, width, height, std::move(rgba8));
	if (lua_pcall(_state, 1, 0, errorHandler) != LUA_OK)
	{
		std::string message = lua_tostring(_state, -1);
		lua_settop(_state, stackBase);
		return fail(std::move(message), error);
	}
	lua_settop(_state, stackBase);
	error.clear();
	return true;
}

bool LoveRuntime::setSourceRoot(std::string_view sourceRoot, std::string &error)
{
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before setting its source root";
		return false;
	}
	if (sourceRoot.empty())
	{
		error = "Love source root is empty";
		return false;
	}
	if (!_filesystemBackend)
	{
		error = "Love filesystem backend is not attached";
		return false;
	}

	namespace fs = std::filesystem;
	std::error_code pathError;
	const fs::path root = fs::weakly_canonical(fs::path(sourceRoot), pathError);
	if (pathError || !_filesystemBackend->isFolder(root.string()))
	{
		error = "failed to resolve Love source root: "
			+ (pathError ? pathError.message() : std::string("not a directory"));
		return false;
	}
	_sourceRoot = root.string();
	if (_identity.empty())
	{
		const std::string defaultIdentity = root.filename().string();
		if (!setIdentity(defaultIdentity.empty() ? "love" : defaultIdentity, error))
			return false;
	}

	// Keep only preload and the confined instance searcher. In particular, do
	// not expose the process working directory or native Lua modules to Love.
	lua_getglobal(_state, "package");
	lua_getfield(_state, -1, "searchers");
	lua_newtable(_state);
	lua_geti(_state, -2, 1);
	lua_seti(_state, -2, 1);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, sourceModuleSearcher, 1);
	lua_seti(_state, -2, 2);
	lua_setfield(_state, -3, "searchers");
	lua_getfield(_state, -2, "searchers");
	lua_setfield(_state, -3, "loaders");
	lua_pushliteral(_state, "");
	lua_setfield(_state, -3, "path");
	lua_pushliteral(_state, "");
	lua_setfield(_state, -3, "cpath");
	lua_pop(_state, 2);

	error.clear();
	return true;
}

bool LoveRuntime::setSaveBaseRoot(std::string_view saveBaseRoot, std::string &error)
{
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before setting its save base root";
		return false;
	}
	if (saveBaseRoot.empty())
	{
		error = "Love save base root is empty";
		return false;
	}
	std::error_code pathError;
	const std::filesystem::path absolute = std::filesystem::absolute(
		std::filesystem::path(saveBaseRoot), pathError).lexically_normal();
	if (pathError)
	{
		error = "failed to resolve Love save base root: " + pathError.message();
		return false;
	}
	const std::filesystem::path canonical = std::filesystem::weakly_canonical(absolute, pathError);
	if (pathError)
	{
		error = "failed to canonicalize Love save base root: " + pathError.message();
		return false;
	}
	_saveBaseRoot = canonical.string();
	return refreshSaveRoot(error);
}

bool LoveRuntime::setIdentity(std::string_view identity, std::string &error)
{
	if (identity.empty() || identity.size() > 128 || identity == "." || identity == ".."
		|| identity.find('/') != std::string_view::npos || identity.find('\\') != std::string_view::npos)
	{
		error = "Love filesystem identity must be 1 to 128 characters and cannot contain path separators";
		return false;
	}
	for (const unsigned char character : identity)
	{
		if (character < 0x20 || character == 0x7f)
		{
			error = "Love filesystem identity cannot contain control characters";
			return false;
		}
	}
	_identity.assign(identity);
	return refreshSaveRoot(error);
}

bool LoveRuntime::refreshSaveRoot(std::string &error)
{
	_saveRoot.clear();
	if (_saveBaseRoot.empty() || _identity.empty())
	{
		error.clear();
		return true;
	}
	const std::filesystem::path base(_saveBaseRoot);
	const std::filesystem::path target = (base / _identity).lexically_normal();
	if (!isInsideRoot(base, target))
	{
		error = "Love filesystem identity escapes the save base root";
		return false;
	}
	_saveRoot = target.string();
	error.clear();
	return true;
}

bool LoveRuntime::resolveReadPath(std::string_view filename, std::string &resolvedPath, std::string &error) const
{
	auto accept = [&](const std::filesystem::path &candidate) {
		if (_filesystemBackend && _filesystemBackend->exist(candidate.string())
			&& !_filesystemBackend->isFolder(candidate.string()))
		{
			resolvedPath = candidate.string();
			error.clear();
			return true;
		}
		return false;
	};
	std::filesystem::path candidate;
	std::string candidateError;
	if (resolveEntryWithinRoot(_saveRoot, filename, candidate, false, candidateError) && accept(candidate))
		return true;
	if (!candidateError.empty())
	{
		error = candidateError;
		return false;
	}
	for (const auto &mount : _mountedArchives)
	{
		candidateError.clear();
		if (resolveMountedEntry(mount.root, mount.mountpoint, filename, candidate, false, candidateError)
			&& accept(candidate))
			return true;
		if (!candidateError.empty())
		{
			error = candidateError;
			return false;
		}
	}
	candidateError.clear();
	if (resolveEntryWithinRoot(_sourceRoot, filename, candidate, false, candidateError) && accept(candidate))
		return true;
	if (!candidateError.empty())
	{
		error = candidateError;
		return false;
	}
	error = "Love filesystem file does not exist: " + std::string(filename);
	return false;
}

void LoveRuntime::clearMountedArchives()
{
	for (auto &mount : _mountedArchives)
	{
		if (_filesystemBackend)
			_filesystemBackend->unmountArchive(mount.root);
		if (_state && mount.dataReference != LUA_NOREF)
			luaL_unref(_state, LUA_REGISTRYINDEX, mount.dataReference);
	}
	_mountedArchives.clear();
}

int LoveRuntime::openLoveModule(lua_State *state)
{
	lua_getglobal(state, "love");
	return 1;
}

int LoveRuntime::loveRun(lua_State *)
{
	// Dora owns the application loop. The compatibility entry point must never
	// start Love's standalone loop or present an operating-system window.
	return 0;
}

int LoveRuntime::loveGetVersion(lua_State *state)
{
	lua_pushinteger(state, 11);
	lua_pushinteger(state, 5);
	lua_pushinteger(state, 0);
	lua_pushliteral(state, "Mysterious Mysteries");
	return 4;
}

int LoveRuntime::loveHandler(lua_State *state)
{
	const int argumentCount = lua_gettop(state);
	const char *name = lua_tostring(state, lua_upvalueindex(1));
	lua_getglobal(state, "love");
	lua_getfield(state, -1, name);
	lua_remove(state, -2);
	if (!lua_isfunction(state, -1))
	{
		lua_pop(state, 1);
		return 0;
	}
	lua_insert(state, 1);
	lua_call(state, argumentCount, 0);
	return 0;
}

int LoveRuntime::openLoveGraphicsModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "graphics");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveImageModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "image");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveFontModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "font");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveSoundModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "sound");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveMathModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "math");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveDataModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "data");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveWindowModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "window");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveEventModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "event");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveFilesystemModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "filesystem");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveKeyboardModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "keyboard");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveMouseModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "mouse");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveTouchModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "touch");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveJoystickModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "joystick");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveTimerModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "timer");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveAudioModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "audio");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveVideoModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "video");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveSystemModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "system");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::systemGetOS(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string os = runtime->_systemBackend ? runtime->_systemBackend->getOS() : "Unknown";
	lua_pushlstring(state, os.data(), os.size());
	return 1;
}

int LoveRuntime::systemGetProcessorCount(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int count = runtime->_systemBackend ? runtime->_systemBackend->getProcessorCount() : 1;
	lua_pushinteger(state, std::max(1, count));
	return 1;
}

int LoveRuntime::systemSetClipboardText(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	size_t length = 0;
	const char *text = luaL_checklstring(state, 1, &length);
	if (!runtime->_systemBackend)
		return luaL_error(state, "love.system clipboard backend is unavailable");
	std::string error;
	if (!runtime->_systemBackend->setClipboardText(std::string_view(text, length), error))
		return luaL_error(state, "%s", error.empty() ? "failed to set clipboard text" : error.c_str());
	return 0;
}

int LoveRuntime::systemGetClipboardText(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_systemBackend)
		return luaL_error(state, "love.system clipboard backend is unavailable");
	std::string text;
	std::string error;
	if (!runtime->_systemBackend->getClipboardText(text, error))
		return luaL_error(state, "%s", error.empty() ? "failed to get clipboard text" : error.c_str());
	lua_pushlstring(state, text.data(), text.size());
	return 1;
}

int LoveRuntime::systemGetPowerInfo(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const auto info = runtime->_systemBackend
		? runtime->_systemBackend->getPowerInfo()
		: SystemBackend::PowerInfo{};
	const char *powerState = "unknown";
	switch (info.state)
	{
		case SystemBackend::PowerState::Battery: powerState = "battery"; break;
		case SystemBackend::PowerState::NoBattery: powerState = "nobattery"; break;
		case SystemBackend::PowerState::Charging: powerState = "charging"; break;
		case SystemBackend::PowerState::Charged: powerState = "charged"; break;
		case SystemBackend::PowerState::Unknown: break;
	}
	lua_pushstring(state, powerState);
	if (info.percent >= 0)
		lua_pushinteger(state, std::clamp(info.percent, 0, 100));
	else
		lua_pushnil(state);
	if (info.seconds >= 0)
		lua_pushinteger(state, info.seconds);
	else
		lua_pushnil(state);
	return 3;
}

int LoveRuntime::systemOpenURL(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	size_t length = 0;
	const char *url = luaL_checklstring(state, 1, &length);
	if (!runtime->_systemBackend)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	std::string error;
	lua_pushboolean(state, runtime->_systemBackend->openURL(std::string_view(url, length), error));
	return 1;
}

int LoveRuntime::systemVibrate(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const double seconds = luaL_optnumber(state, 1, 0.5);
	luaL_argcheck(state, std::isfinite(seconds) && seconds >= 0.0, 1,
		"vibration duration must be a finite non-negative number");
	if (runtime->_systemBackend) runtime->_systemBackend->vibrate(seconds);
	return 0;
}

int LoveRuntime::systemHasBackgroundMusic(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime->_systemBackend && runtime->_systemBackend->hasBackgroundMusic());
	return 1;
}

int LoveRuntime::openLoveThreadModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "thread");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::threadNewThread(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_threadContext)
		return luaL_error(state, "Love thread runtime is unavailable");
	std::string code;
	std::string chunkName = "Thread code";
	if (lua_type(state, 1) == LUA_TSTRING)
	{
		std::size_t size = 0;
		const char *text = lua_tolstring(state, 1, &size);
		if (size >= 1024 || std::memchr(text, '\n', size) != nullptr)
			code.assign(text, size);
		else
		{
			const std::string filename(text, size);
			std::string resolved;
			std::string error;
			if (!runtime->resolveReadPath(filename, resolved, error)
				|| !runtime->_filesystemBackend
				|| !runtime->_filesystemBackend->load(resolved, code, error))
				return luaL_error(state, "%s", error.empty()
					? "failed to load Love thread source through Content" : error.c_str());
			chunkName = "@" + filename;
		}
	}
	else if (auto *fileData = testFileData(state, 1))
	{
		code = fileData->data;
		chunkName = "@" + fileData->filename;
	}
	else if (auto *file = luaL_testudata(state, 1, FileLoveType.getName())
		? ::love::luax_checktype<FileUserdata>(state, 1, FileLoveType) : nullptr)
	{
		std::string resolved;
		std::string error;
		if (!runtime->resolveReadPath(file->filename, resolved, error)
			|| !runtime->_filesystemBackend
			|| !runtime->_filesystemBackend->load(resolved, code, error))
			return luaL_error(state, "%s", error.empty()
				? "failed to load Love thread File through Content" : error.c_str());
		chunkName = "@" + file->filename;
	}
	else
	{
		DataSpan span;
		if (!getDataSpan(state, 1, span))
			return luaL_argerror(state, 1, "string, File, or Data expected");
		code.assign(reinterpret_cast<const char *>(span.bytes), span.size);
	}

	auto worker = std::make_shared<ThreadWorker>();
	worker->code = std::move(code);
	worker->chunkName = std::move(chunkName);
	worker->context = runtime->_threadContext;
	worker->filesystem = runtime->_filesystemBackend;
	worker->sourceRoot = runtime->_sourceRoot;
	worker->saveBaseRoot = runtime->_saveBaseRoot;
	worker->identity = runtime->_identity;
	worker->preloadModules = runtime->_preloadModules;
	{
		std::lock_guard lock(runtime->_threadContext->mutex);
		runtime->_threadContext->workers.push_back(worker);
	}
	runtime->_threadWorkers.push_back(worker);
	pushThread(state, worker);
	return 1;
}

int LoveRuntime::threadNewChannel(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_threadContext)
		return luaL_error(state, "Love thread runtime is unavailable");
	auto channel = std::make_shared<ThreadChannel>();
	channel->context = runtime->_threadContext;
	{
		std::lock_guard lock(runtime->_threadContext->mutex);
		runtime->_threadContext->channels.push_back(channel);
	}
	pushChannel(state, channel);
	return 1;
}

int LoveRuntime::threadGetChannel(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_threadContext)
		return luaL_error(state, "Love thread runtime is unavailable");
	std::size_t size = 0;
	const char *name = luaL_checklstring(state, 1, &size);
	std::shared_ptr<ThreadChannel> channel;
	{
		std::lock_guard lock(runtime->_threadContext->mutex);
		auto &slot = runtime->_threadContext->namedChannels[std::string(name, size)];
		if (!slot)
		{
			slot = std::make_shared<ThreadChannel>();
			slot->context = runtime->_threadContext;
			runtime->_threadContext->channels.push_back(slot);
		}
		channel = slot;
	}
	pushChannel(state, channel);
	return 1;
}

int LoveRuntime::threadObjectEqual(lua_State *state)
{
	auto *left = luaL_testudata(state, 1, ThreadLoveType.getName())
		? ::love::luax_checktype<ThreadUserdata>(state, 1, ThreadLoveType) : nullptr;
	auto *right = luaL_testudata(state, 2, ThreadLoveType.getName())
		? ::love::luax_checktype<ThreadUserdata>(state, 2, ThreadLoveType) : nullptr;
	lua_pushboolean(state, left && right && left->worker == right->worker);
	return 1;
}

int LoveRuntime::threadObjectStart(lua_State *state)
{
	auto *thread = checkThread(state, 1);
	if (!thread->worker) { lua_pushboolean(state, false); return 1; }
	auto worker = thread->worker;
	std::vector<ThreadValue> arguments;
	std::string conversionError;
	for (int index = 2; index <= lua_gettop(state); ++index)
	{
		ThreadValue value;
		if (!threadValueFromLua(state, index, value, conversionError))
			return luaL_argerror(state, index, conversionError.c_str());
		arguments.push_back(std::move(value));
	}
	std::unique_lock lock(worker->mutex);
	if (worker->running || (worker->context && worker->context->stopping.load(std::memory_order_acquire)))
	{
		lua_pushboolean(state, false);
		return 1;
	}
	if (worker->worker.joinable())
	{
		lock.unlock();
		worker->worker.join();
		lock.lock();
	}
	worker->arguments = std::move(arguments);
	worker->error.clear();
	worker->started = true;
	worker->running = true;
	worker->worker = std::thread([worker]()
	{
		std::string workerError;
		if (!worker->context || worker->context->stopping.load(std::memory_order_acquire))
			workerError = "Love thread stopped because its runtime is closing";
		else
		{
			LoveRuntime runtime;
			ThreadFilesystemBackend filesystem(worker->context, worker->filesystem);
			runtime._threadContext = worker->context;
			runtime._ownsThreadContext = false;
			runtime._preloadModules = worker->preloadModules;
			runtime.setFilesystemBackend(worker->filesystem ? &filesystem : nullptr);
			if (runtime.open(workerError)
				&& (worker->sourceRoot.empty() || runtime.setSourceRoot(worker->sourceRoot, workerError))
				&& (worker->saveBaseRoot.empty() || runtime.setSaveBaseRoot(worker->saveBaseRoot, workerError))
				&& (worker->identity.empty() || runtime.setIdentity(worker->identity, workerError)))
			{
				lua_State *threadState = runtime._state;
				lua_pushlightuserdata(threadState, worker->context.get());
				lua_setfield(threadState, LUA_REGISTRYINDEX, ThreadContextRegistry);
				lua_sethook(threadState, threadCancellationHook, LUA_MASKCOUNT, 10000);
				lua_pushlightuserdata(threadState, &runtime);
				lua_pushcclosure(threadState, traceback, 1);
				const int errorHandler = lua_gettop(threadState);
				const std::string chunkName = runtime.prepareGeneratedChunk(
					worker->code, worker->chunkName);
				if (loadLoveChunk(threadState, worker->code, chunkName.c_str()) != LUA_OK)
				{
					runtime.rewriteGeneratedErrorOnStack(threadState);
					workerError = lua_tostring(threadState, -1);
				}
				else
				{
					for (const auto &argument : worker->arguments)
						pushThreadValue(threadState, argument);
					if (lua_pcall(threadState, static_cast<int>(worker->arguments.size()), 0,
						errorHandler) != LUA_OK)
						workerError = lua_tostring(threadState, -1);
				}
				lua_sethook(threadState, nullptr, 0, 0);
			}
			runtime.close();
		}
		const bool stopping = worker->context
			&& worker->context->stopping.load(std::memory_order_acquire);
		{
			std::lock_guard workerLock(worker->mutex);
			worker->error = stopping ? std::string{} : workerError;
			worker->running = false;
		}
		if (!workerError.empty() && !stopping && worker->context)
		{
			std::lock_guard errorLock(worker->context->errorMutex);
			worker->context->pendingErrors.emplace_back(worker, std::move(workerError));
		}
	});
	lock.unlock();
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::threadObjectWait(lua_State *state)
{
	auto *thread = checkThread(state, 1);
	if (!thread->worker) return 0;
	for (;;)
	{
		{
			std::lock_guard lock(thread->worker->mutex);
			if (!thread->worker->running) break;
		}
		if (thread->runtime) thread->runtime->drainThreadFilesystemRequests();
		std::this_thread::sleep_for(std::chrono::milliseconds(1));
	}
	std::unique_lock lock(thread->worker->mutex);
	if (thread->worker->worker.joinable())
	{
		lock.unlock();
		thread->worker->worker.join();
	}
	return 0;
}

int LoveRuntime::threadObjectGetError(lua_State *state)
{
	auto *thread = checkThread(state, 1);
	if (!thread->worker) { lua_pushnil(state); return 1; }
	std::lock_guard lock(thread->worker->mutex);
	if (thread->worker->error.empty()) lua_pushnil(state);
	else lua_pushlstring(state, thread->worker->error.data(), thread->worker->error.size());
	return 1;
}

int LoveRuntime::threadObjectIsRunning(lua_State *state)
{
	auto *thread = checkThread(state, 1);
	std::lock_guard lock(thread->worker->mutex);
	lua_pushboolean(state, thread->worker->running);
	return 1;
}

int LoveRuntime::channelEqual(lua_State *state)
{
	auto *left = luaL_testudata(state, 1, ChannelLoveType.getName())
		? ::love::luax_checktype<ChannelUserdata>(state, 1, ChannelLoveType) : nullptr;
	auto *right = luaL_testudata(state, 2, ChannelLoveType.getName())
		? ::love::luax_checktype<ChannelUserdata>(state, 2, ChannelLoveType) : nullptr;
	lua_pushboolean(state, left && right && left->channel == right->channel);
	return 1;
}

int LoveRuntime::channelPush(lua_State *state)
{
	auto channel = checkChannel(state, 1)->channel;
	ThreadValue value;
	std::string error;
	if (!threadValueFromLua(state, 2, value, error))
		return luaL_argerror(state, 2, error.c_str());
	std::lock_guard lock(channel->mutex);
	const std::uint64_t id = channel->nextId++;
	channel->values.push_back({id, std::move(value)});
	channel->changed.notify_all();
	lua_pushnumber(state, static_cast<lua_Number>(id));
	return 1;
}

int LoveRuntime::channelSupply(lua_State *state)
{
	auto *userdata = checkChannel(state, 1);
	auto channel = userdata->channel;
	ThreadValue value;
	std::string error;
	if (!threadValueFromLua(state, 2, value, error))
		return luaL_argerror(state, 2, error.c_str());
	const bool timed = !lua_isnoneornil(state, 3);
	const double timeout = timed ? luaL_checknumber(state, 3) : 0.0;
	luaL_argcheck(state, !timed || std::isfinite(timeout), 3, "timeout must be finite");
	std::unique_lock lock(channel->mutex);
	const std::uint64_t id = channel->nextId++;
	channel->values.push_back({id, std::move(value)});
	channel->changed.notify_all();
	const auto consumed = [&]() { return channel->lastReadId >= id || threadContextStopping(channel); };
	bool result = true;
	const auto deadline = std::chrono::steady_clock::now()
		+ std::chrono::duration_cast<std::chrono::steady_clock::duration>(
			std::chrono::duration<double>(std::max(0.0, timeout)));
	while (!consumed())
	{
		lock.unlock();
		if (userdata->runtime) userdata->runtime->drainThreadFilesystemRequests();
		lock.lock();
		if (consumed()) break;
		if (timed && (timeout < 0.0 || std::chrono::steady_clock::now() >= deadline))
		{
			result = false;
			break;
		}
		const auto slice = std::chrono::milliseconds(1);
		channel->changed.wait_for(lock, slice, consumed);
	}
	if (result) result = channel->lastReadId >= id;
	lua_pushboolean(state, result);
	return 1;
}

int LoveRuntime::channelPop(lua_State *state)
{
	auto channel = checkChannel(state, 1)->channel;
	std::lock_guard lock(channel->mutex);
	if (channel->values.empty()) { lua_pushnil(state); return 1; }
	auto entry = std::move(channel->values.front());
	channel->values.pop_front();
	channel->lastReadId = std::max(channel->lastReadId, entry.id);
	channel->changed.notify_all();
	pushThreadValue(state, entry.value);
	return 1;
}

int LoveRuntime::channelDemand(lua_State *state)
{
	auto *userdata = checkChannel(state, 1);
	auto channel = userdata->channel;
	const bool timed = !lua_isnoneornil(state, 2);
	const double timeout = timed ? luaL_checknumber(state, 2) : 0.0;
	luaL_argcheck(state, !timed || std::isfinite(timeout), 2, "timeout must be finite");
	std::unique_lock lock(channel->mutex);
	const auto available = [&]() { return !channel->values.empty() || threadContextStopping(channel); };
	const auto deadline = std::chrono::steady_clock::now()
		+ std::chrono::duration_cast<std::chrono::steady_clock::duration>(
			std::chrono::duration<double>(std::max(0.0, timeout)));
	while (!available())
	{
		lock.unlock();
		if (userdata->runtime) userdata->runtime->drainThreadFilesystemRequests();
		lock.lock();
		if (available()) break;
		if (timed && (timeout < 0.0 || std::chrono::steady_clock::now() >= deadline))
		{
			lua_pushnil(state);
			return 1;
		}
		channel->changed.wait_for(lock, std::chrono::milliseconds(1), available);
	}
	if (channel->values.empty()) { lua_pushnil(state); return 1; }
	auto entry = std::move(channel->values.front());
	channel->values.pop_front();
	channel->lastReadId = std::max(channel->lastReadId, entry.id);
	channel->changed.notify_all();
	pushThreadValue(state, entry.value);
	return 1;
}

int LoveRuntime::channelPeek(lua_State *state)
{
	auto channel = checkChannel(state, 1)->channel;
	std::lock_guard lock(channel->mutex);
	if (channel->values.empty()) lua_pushnil(state);
	else pushThreadValue(state, channel->values.front().value);
	return 1;
}

int LoveRuntime::channelGetCount(lua_State *state)
{
	auto channel = checkChannel(state, 1)->channel;
	std::lock_guard lock(channel->mutex);
	lua_pushinteger(state, static_cast<lua_Integer>(channel->values.size()));
	return 1;
}

int LoveRuntime::channelHasRead(lua_State *state)
{
	auto channel = checkChannel(state, 1)->channel;
	const auto id = static_cast<std::uint64_t>(luaL_checknumber(state, 2));
	std::lock_guard lock(channel->mutex);
	lua_pushboolean(state, channel->lastReadId >= id);
	return 1;
}

int LoveRuntime::channelClear(lua_State *state)
{
	auto channel = checkChannel(state, 1)->channel;
	std::lock_guard lock(channel->mutex);
	if (!channel->values.empty())
	{
		channel->lastReadId = std::max(channel->lastReadId, channel->values.back().id);
		channel->values.clear();
		channel->changed.notify_all();
	}
	return 0;
}

int LoveRuntime::channelPerformAtomic(lua_State *state)
{
	auto channel = checkChannel(state, 1)->channel;
	luaL_checktype(state, 2, LUA_TFUNCTION);
	lua_pushvalue(state, 1);
	lua_insert(state, 3);
	channel->mutex.lock();
	const int argumentCount = lua_gettop(state) - 2;
	const int result = lua_pcall(state, argumentCount, LUA_MULTRET, 0);
	channel->mutex.unlock();
	if (result != LUA_OK) return lua_error(state);
	return lua_gettop(state) - 1;
}

int LoveRuntime::openLovePhysicsModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "physics");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::physicsSetMeter(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float meter = static_cast<float>(luaL_checknumber(state, 1));
	luaL_argcheck(state, std::isfinite(meter) && meter > 0.0f, 1, "meter must be a finite positive number");
	runtime->_physicsMeter = meter;
	if (runtime->_physicsBackend) runtime->_physicsBackend->setMeter(meter);
	return 0;
}

int LoveRuntime::physicsGetMeter(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime->_physicsMeter);
	return 1;
}

int LoveRuntime::physicsNewWorld(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_argcheck(state, runtime && runtime->_physicsBackend, 1, "Love physics backend is unavailable");
	const float gx = static_cast<float>(luaL_optnumber(state, 1, 0.0));
	const float gy = static_cast<float>(luaL_optnumber(state, 2, 0.0));
	const bool sleep = lua_isnoneornil(state, 3) ? true : lua_toboolean(state, 3);
	luaL_argcheck(state, std::isfinite(gx), 1, "gravity x must be finite");
	luaL_argcheck(state, std::isfinite(gy), 2, "gravity y must be finite");
	std::string error;
	const auto handle = runtime->_physicsBackend->newWorld(gx, gy, sleep, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create physics World" : error.c_str());
	auto *world = new PhysicsWorldUserdata(runtime, handle);
	pushNewDoraHandleObject(state, PhysicsWorldLoveType, world);
	return 1;
}

int LoveRuntime::physicsNewBody(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *world = checkPhysicsWorld(state, 1);
	luaL_argcheck(state, world->runtime == runtime && world->handle != 0, 1, "World is destroyed or belongs to another Love state");
	const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	const char *type = luaL_optstring(state, 4, "static");
	luaL_argcheck(state, std::string_view(type) == "static" || std::string_view(type) == "dynamic"
		|| std::string_view(type) == "kinematic", 4, "expected 'static', 'dynamic', or 'kinematic'");
	std::string error;
	const auto handle = runtime->_physicsBackend->newBody(world->handle, x, y, type, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create physics Body" : error.c_str());
	auto *body = new PhysicsBodyUserdata(runtime, handle, world->handle, type);
	body->worldObject.set(world);
	pushNewDoraHandleObject(state, PhysicsBodyLoveType, body);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	return 1;
}

int LoveRuntime::physicsNewCircleShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float x = 0.0f, y = 0.0f, radius = 0.0f;
	if (lua_gettop(state) == 1) radius = static_cast<float>(luaL_checknumber(state, 1));
	else if (lua_gettop(state) == 3)
	{
		x = static_cast<float>(luaL_checknumber(state, 1));
		y = static_cast<float>(luaL_checknumber(state, 2));
		radius = static_cast<float>(luaL_checknumber(state, 3));
	}
	else return luaL_error(state, "newCircleShape expects radius or x, y, radius");
	luaL_argcheck(state, std::isfinite(radius) && radius > 0.0f, lua_gettop(state), "radius must be finite and positive");
	std::string error;
	const auto handle = runtime->_physicsBackend->newCircleShape(x, y, radius, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create CircleShape" : error.c_str());
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "circle", radius, {x, y});
	pushNewDoraHandleObject(state, PhysicsShapeLoveType, shape);
	return 1;
}

int LoveRuntime::physicsNewRectangleShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float x = 0.0f, y = 0.0f, width = 0.0f, height = 0.0f, angle = 0.0f;
	const int count = lua_gettop(state);
	if (count == 2)
	{
		width = static_cast<float>(luaL_checknumber(state, 1));
		height = static_cast<float>(luaL_checknumber(state, 2));
	}
	else if (count == 4 || count == 5)
	{
		x = static_cast<float>(luaL_checknumber(state, 1));
		y = static_cast<float>(luaL_checknumber(state, 2));
		width = static_cast<float>(luaL_checknumber(state, 3));
		height = static_cast<float>(luaL_checknumber(state, 4));
		angle = static_cast<float>(luaL_optnumber(state, 5, 0.0));
	}
	else return luaL_error(state, "newRectangleShape expects width, height or x, y, width, height, angle");
	luaL_argcheck(state, std::isfinite(width) && width > 0.0f, count == 2 ? 1 : 3, "width must be finite and positive");
	luaL_argcheck(state, std::isfinite(height) && height > 0.0f, count == 2 ? 2 : 4, "height must be finite and positive");
	std::string error;
	const auto handle = runtime->_physicsBackend->newRectangleShape(x, y, width, height, angle, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create PolygonShape" : error.c_str());
	const auto halfWidth = width * 0.5f;
	const auto halfHeight = height * 0.5f;
	const auto cosine = std::cos(angle);
	const auto sine = std::sin(angle);
	std::vector<float> points;
	points.reserve(8);
	for (const auto &[localX, localY] : std::array<std::pair<float, float>, 4>{
		std::pair{-halfWidth, -halfHeight}, std::pair{halfWidth, -halfHeight},
		std::pair{halfWidth, halfHeight}, std::pair{-halfWidth, halfHeight}})
	{
		points.push_back(x + localX * cosine - localY * sine);
		points.push_back(y + localX * sine + localY * cosine);
	}
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "polygon", 0.0f, std::move(points));
	pushNewDoraHandleObject(state, PhysicsShapeLoveType, shape);
	return 1;
}

static std::vector<float> checkPhysicsShapePoints(lua_State *state, int firstArgument,
	const char *shapeName)
{
	const bool table = lua_istable(state, firstArgument);
	const int count = table ? static_cast<int>(lua_rawlen(state, firstArgument))
		: lua_gettop(state) - firstArgument + 1;
	if (count % 2 != 0)
		luaL_error(state, "%s vertex component count must be a multiple of two", shapeName);
	std::vector<float> points;
	points.reserve(static_cast<std::size_t>(count));
	for (int index = 0; index < count; ++index)
	{
		if (table) lua_rawgeti(state, firstArgument, index + 1);
		const float value = static_cast<float>(luaL_checknumber(state,
			table ? -1 : firstArgument + index));
		if (table) lua_pop(state, 1);
		if (!std::isfinite(value)) luaL_error(state, "%s vertices must be finite", shapeName);
		points.push_back(value);
	}
	return points;
}

int LoveRuntime::physicsNewPolygonShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto points = checkPhysicsShapePoints(state, 1, "PolygonShape");
	const auto vertexCount = points.size() / 2;
	luaL_argcheck(state, vertexCount >= 3, 1, "PolygonShape requires at least 3 vertices");
	luaL_argcheck(state, vertexCount <= 8, 1, "PolygonShape supports at most 8 vertices");
	std::string error;
	const auto handle = runtime->_physicsBackend->newPolygonShape(points, error);
	if (!handle) return luaL_error(state, "%s", error.empty() ? "failed to create PolygonShape" : error.c_str());
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "polygon", 0.0f, std::move(points));
	pushNewDoraHandleObject(state, PhysicsShapeLoveType, shape);
	return 1;
}

int LoveRuntime::physicsNewEdgeShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x1 = static_cast<float>(luaL_checknumber(state, 1));
	const float y1 = static_cast<float>(luaL_checknumber(state, 2));
	const float x2 = static_cast<float>(luaL_checknumber(state, 3));
	const float y2 = static_cast<float>(luaL_checknumber(state, 4));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 1, "EdgeShape vertices must be finite");
	luaL_argcheck(state, x1 != x2 || y1 != y2, 1, "EdgeShape vertices must be distinct");
	std::string error;
	const auto handle = runtime->_physicsBackend->newEdgeShape(x1, y1, x2, y2, error);
	if (!handle) return luaL_error(state, "%s", error.empty() ? "failed to create EdgeShape" : error.c_str());
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "edge", 0.0f, {x1, y1, x2, y2});
	pushNewDoraHandleObject(state, PhysicsShapeLoveType, shape);
	return 1;
}

int LoveRuntime::physicsNewChainShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	const bool loop = lua_toboolean(state, 1);
	auto points = checkPhysicsShapePoints(state, 2, "ChainShape");
	const auto vertexCount = points.size() / 2;
	luaL_argcheck(state, vertexCount >= (loop ? 3u : 2u), 2,
		loop ? "looping ChainShape requires at least 3 vertices"
			: "ChainShape requires at least 2 vertices");
	std::string error;
	const auto handle = runtime->_physicsBackend->newChainShape(loop, points, error);
	if (!handle) return luaL_error(state, "%s", error.empty() ? "failed to create ChainShape" : error.c_str());
	if (loop) { points.push_back(points[0]); points.push_back(points[1]); }
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "chain", 0.0f, std::move(points));
	shape->loop = loop;
	if (loop)
	{
		shape->hasPreviousVertex = shape->hasNextVertex = true;
		shape->previousX = shape->points[shape->points.size() - 4];
		shape->previousY = shape->points[shape->points.size() - 3];
		shape->nextX = shape->points[2];
		shape->nextY = shape->points[3];
	}
	pushNewDoraHandleObject(state, PhysicsShapeLoveType, shape);
	return 1;
}

int LoveRuntime::physicsNewFixture(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *body = checkPhysicsBody(state, 1);
	auto *shape = checkPhysicsShape(state, 2);
	luaL_argcheck(state, body->runtime == runtime && shape->runtime == runtime
		&& body->handle != 0 && shape->handle != 0, 1, "Body and Shape must be live and belong to this Love state");
	const float density = static_cast<float>(luaL_optnumber(state, 3, 1.0));
	luaL_argcheck(state, std::isfinite(density) && density >= 0.0f, 3, "density must be finite and non-negative");
	std::string error;
	const auto handle = runtime->_physicsBackend->newFixture(body->handle, shape->handle, density, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create Fixture" : error.c_str());
	auto *fixture = new PhysicsFixtureUserdata(runtime, handle, density);
	fixture->bodyObject.set(body);
	fixture->shapeObject.set(shape);
	pushNewDoraHandleObject(state, PhysicsFixtureLoveType, fixture);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	lua_pushvalue(state, -1);
	runtime->_physicsFixtureReferences[handle] = luaL_ref(state, LUA_REGISTRYINDEX);
	runtime->_physicsFixtureObjects[handle].set(fixture);
	return 1;
}

int LoveRuntime::physicsNewDistanceJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	const float x2 = static_cast<float>(luaL_checknumber(state, 5));
	const float y2 = static_cast<float>(luaL_checknumber(state, 6));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	bool collide = false;
	if (!lua_isnoneornil(state, 7))
	{
		luaL_checktype(state, 7, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 7);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newDistanceJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, collide, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create DistanceJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "distance");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	return 1;
}

int LoveRuntime::physicsNewRevoluteJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1), 3,
		"anchor coordinates must be finite");
	float x2 = x1;
	float y2 = y1;
	bool collide = false;
	bool hasReferenceAngle = false;
	float referenceAngle = 0.0f;
	const int argumentCount = lua_gettop(state);
	if (argumentCount >= 6)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		luaL_argcheck(state, std::isfinite(x2) && std::isfinite(y2), 5,
			"anchor coordinates must be finite");
		if (argumentCount >= 7 && !lua_isnil(state, 7))
		{
			luaL_checktype(state, 7, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 7);
		}
		if (argumentCount >= 8 && !lua_isnil(state, 8))
		{
			hasReferenceAngle = true;
			referenceAngle = static_cast<float>(luaL_checknumber(state, 8));
			luaL_argcheck(state, std::isfinite(referenceAngle), 8,
				"reference angle must be finite");
		}
	}
	else if (argumentCount >= 5 && !lua_isnil(state, 5))
	{
		luaL_checktype(state, 5, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 5);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newRevoluteJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, collide, hasReferenceAngle, referenceAngle, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create RevoluteJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "revolute");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewPrismaticJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	float x2 = x1, y2 = y1, axisX = 0.0f, axisY = 0.0f;
	bool collide = false, hasReferenceAngle = false;
	float referenceAngle = 0.0f;
	const int argumentCount = lua_gettop(state);
	if (argumentCount >= 8)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		axisX = static_cast<float>(luaL_checknumber(state, 7));
		axisY = static_cast<float>(luaL_checknumber(state, 8));
		if (argumentCount >= 9 && !lua_isnil(state, 9))
		{
			luaL_checktype(state, 9, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 9);
		}
		if (argumentCount >= 10 && !lua_isnil(state, 10))
		{
			hasReferenceAngle = true;
			referenceAngle = static_cast<float>(luaL_checknumber(state, 10));
			luaL_argcheck(state, std::isfinite(referenceAngle), 10,
				"reference angle must be finite");
		}
	}
	else
	{
		axisX = static_cast<float>(luaL_checknumber(state, 5));
		axisY = static_cast<float>(luaL_checknumber(state, 6));
		if (argumentCount >= 7 && !lua_isnil(state, 7))
		{
			luaL_checktype(state, 7, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 7);
		}
	}
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	luaL_argcheck(state, std::isfinite(axisX) && std::isfinite(axisY)
		&& axisX * axisX + axisY * axisY > 0.0f, argumentCount >= 8 ? 7 : 5,
		"axis must be finite and non-zero");
	std::string error;
	const auto handle = runtime->_physicsBackend->newPrismaticJoint(
		bodyA->handle, bodyB->handle, x1, y1, x2, y2, axisX, axisY,
		collide, hasReferenceAngle, referenceAngle, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create PrismaticJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "prismatic");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewWeldJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	float x2 = x1, y2 = y1;
	bool collide = false, hasReferenceAngle = false;
	float referenceAngle = 0.0f;
	const int argumentCount = lua_gettop(state);
	if (argumentCount >= 6)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		if (argumentCount >= 7 && !lua_isnil(state, 7))
		{
			luaL_checktype(state, 7, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 7);
		}
		if (argumentCount >= 8 && !lua_isnil(state, 8))
		{
			hasReferenceAngle = true;
			referenceAngle = static_cast<float>(luaL_checknumber(state, 8));
			luaL_argcheck(state, std::isfinite(referenceAngle), 8,
				"reference angle must be finite");
		}
	}
	else if (argumentCount >= 5 && !lua_isnil(state, 5))
	{
		luaL_checktype(state, 5, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 5);
	}
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	std::string error;
	const auto handle = runtime->_physicsBackend->newWeldJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, collide, hasReferenceAngle, referenceAngle, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create WeldJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "weld");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewFrictionJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	float x2 = x1, y2 = y1;
	bool collide = false;
	const int argumentCount = lua_gettop(state);
	if (argumentCount >= 6)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		if (argumentCount >= 7 && !lua_isnil(state, 7))
		{
			luaL_checktype(state, 7, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 7);
		}
	}
	else if (argumentCount >= 5 && !lua_isnil(state, 5))
	{
		luaL_checktype(state, 5, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 5);
	}
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	std::string error;
	const auto handle = runtime->_physicsBackend->newFrictionJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, collide, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create FrictionJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "friction");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewRopeJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	const float x2 = static_cast<float>(luaL_checknumber(state, 5));
	const float y2 = static_cast<float>(luaL_checknumber(state, 6));
	const float maxLength = static_cast<float>(luaL_checknumber(state, 7));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	luaL_argcheck(state, std::isfinite(maxLength) && maxLength >= 0.0f, 7,
		"maximum length must be finite and non-negative");
	bool collide = false;
	if (!lua_isnoneornil(state, 8))
	{
		luaL_checktype(state, 8, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 8);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newRopeJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, maxLength, collide, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create RopeJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "rope");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewPulleyJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	float values[9];
	for (int i = 0; i < 8; ++i)
	{
		values[i] = static_cast<float>(luaL_checknumber(state, i + 3));
		luaL_argcheck(state, std::isfinite(values[i]), i + 3,
			"anchor coordinates must be finite");
	}
	values[8] = static_cast<float>(luaL_optnumber(state, 11, 1.0));
	luaL_argcheck(state, std::isfinite(values[8]) && values[8] > 0.0f, 11,
		"ratio must be finite and positive");
	bool collide = true;
	if (!lua_isnoneornil(state, 12))
	{
		luaL_checktype(state, 12, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 12);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newPulleyJoint(bodyA->handle, bodyB->handle,
		values[0], values[1], values[2], values[3], values[4], values[5],
		values[6], values[7], values[8], collide, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create PulleyJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "pulley");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewWheelJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1); auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	float x2 = x1, y2 = y1, axisX = 0, axisY = 0; bool collide = false;
	if (lua_gettop(state) >= 8)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		axisX = static_cast<float>(luaL_checknumber(state, 7));
		axisY = static_cast<float>(luaL_checknumber(state, 8));
		if (!lua_isnoneornil(state, 9)) { luaL_checktype(state, 9, LUA_TBOOLEAN); collide = lua_toboolean(state, 9); }
	}
	else
	{
		axisX = static_cast<float>(luaL_checknumber(state, 5));
		axisY = static_cast<float>(luaL_checknumber(state, 6));
		if (!lua_isnoneornil(state, 7)) { luaL_checktype(state, 7, LUA_TBOOLEAN); collide = lua_toboolean(state, 7); }
	}
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	luaL_argcheck(state, std::isfinite(axisX) && std::isfinite(axisY)
		&& axisX * axisX + axisY * axisY > 0.0f, 5, "axis must be finite and non-zero");
	std::string error;
	const auto handle = runtime->_physicsBackend->newWheelJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, axisX, axisY, collide, error);
	if (!handle) return luaL_error(state, "%s", error.empty() ? "failed to create WheelJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "wheel");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1); lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3); return 1;
}

int LoveRuntime::physicsNewMouseJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *body = checkPhysicsBody(state, 1);
	luaL_argcheck(state, body->runtime == runtime && body->handle != 0,
		1, "Body must be live and belong to this Love state");
	luaL_argcheck(state, body->type != "kinematic", 1,
		"Cannot create a MouseJoint for a kinematic Body");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2,
		"target coordinates must be finite");
	std::string error;
	const auto handle = runtime->_physicsBackend->newMouseJoint(body->handle, x, y, error);
	if (!handle) return luaL_error(state, "%s",
		error.empty() ? "failed to create MouseJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "mouse");
	joint->bodyAObject.set(body);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushnil(state); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewMotorJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1); auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	float correctionFactor = 0.3f; bool collideConnected = false;
	if (!lua_isnoneornil(state, 3))
	{
		correctionFactor = static_cast<float>(luaL_checknumber(state, 3));
		luaL_argcheck(state, std::isfinite(correctionFactor)
			&& correctionFactor >= 0.0f && correctionFactor <= 1.0f, 3,
			"correction factor must be finite and between 0 and 1");
		if (!lua_isnoneornil(state, 4))
		{
			luaL_checktype(state, 4, LUA_TBOOLEAN);
			collideConnected = lua_toboolean(state, 4);
		}
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newMotorJoint(bodyA->handle, bodyB->handle,
		correctionFactor, collideConnected, error);
	if (!handle) return luaL_error(state, "%s",
		error.empty() ? "failed to create MotorJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "motor");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewGearJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *jointA = checkPhysicsJoint(state, 1); auto *jointB = checkPhysicsJoint(state, 2);
	luaL_argcheck(state, jointA->runtime == runtime && jointB->runtime == runtime
		&& jointA->handle != 0 && jointB->handle != 0
		&& runtime->_physicsBackend->isJointValid(jointA->handle)
		&& runtime->_physicsBackend->isJointValid(jointB->handle), 1,
		"Joints must be live and belong to this Love state");
	luaL_argcheck(state, jointA->handle != jointB->handle, 2,
		"GearJoint requires two distinct source Joints");
	luaL_argcheck(state, jointA->type == "revolute" || jointA->type == "prismatic", 1,
		"GearJoint source must be a RevoluteJoint or PrismaticJoint");
	luaL_argcheck(state, jointB->type == "revolute" || jointB->type == "prismatic", 2,
		"GearJoint source must be a RevoluteJoint or PrismaticJoint");
	const float ratio = static_cast<float>(luaL_optnumber(state, 3, 1.0));
	luaL_argcheck(state, std::isfinite(ratio), 3, "ratio must be finite");
	bool collideConnected = false;
	if (!lua_isnoneornil(state, 4))
	{
		luaL_checktype(state, 4, LUA_TBOOLEAN);
		collideConnected = lua_toboolean(state, 4);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newGearJoint(jointA->handle, jointB->handle,
		ratio, collideConnected, error);
	if (!handle) return luaL_error(state, "%s",
		error.empty() ? "failed to create GearJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "gear");
	joint->jointAObject.set(jointA); joint->jointBObject.set(jointB);
	joint->bodyAObject = jointA->bodyBObject; joint->bodyBObject = jointB->bodyBObject;
	pushNewDoraHandleObject(state, PhysicsJointLoveType, joint);
	lua_getiuservalue(state, 1, 2); lua_setiuservalue(state, -2, 1);
	lua_getiuservalue(state, 2, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 4);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 5);
	return 1;
}

int LoveRuntime::physicsWorldDestroy(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	if (world->runtime && world->handle)
	{
		const auto callbacks = world->runtime->_physicsWorldCallbacks.find(world->handle);
		if (callbacks != world->runtime->_physicsWorldCallbacks.end())
		{
			for (const int reference : {callbacks->second.begin, callbacks->second.end,
				callbacks->second.preSolve, callbacks->second.postSolve})
				if (reference != LUA_NOREF) luaL_unref(state, LUA_REGISTRYINDEX, reference);
			world->runtime->_physicsWorldCallbacks.erase(callbacks);
		}
		for (auto contact = world->runtime->_physicsContactReferences.begin();
			contact != world->runtime->_physicsContactReferences.end();)
		{
			auto object = world->runtime->_physicsContactObjects.find(contact->first);
			auto *userdata = object == world->runtime->_physicsContactObjects.end() ? nullptr
				: static_cast<PhysicsContactUserdata *>(object->second.get());
			const bool belongs = userdata && userdata->world == world->handle;
			if (belongs) userdata->handle = 0;
			if (belongs)
			{
				luaL_unref(state, LUA_REGISTRYINDEX, contact->second);
				world->runtime->_physicsContactObjects.erase(contact->first);
				contact = world->runtime->_physicsContactReferences.erase(contact);
			}
			else ++contact;
		}
	}
	if (world->runtime && world->runtime->_physicsBackend && world->handle)
	{
		world->releaseDoraHandle();
		for (auto fixture = world->runtime->_physicsFixtureReferences.begin();
			fixture != world->runtime->_physicsFixtureReferences.end();)
		{
			if (world->runtime->_physicsBackend->isFixtureValid(fixture->first)) { ++fixture; continue; }
			if (auto object = world->runtime->_physicsFixtureObjects.find(fixture->first);
				object != world->runtime->_physicsFixtureObjects.end())
				static_cast<PhysicsFixtureUserdata *>(object->second.get())->invalidateDoraHandle();
			luaL_unref(state, LUA_REGISTRYINDEX, fixture->second);
			world->runtime->_physicsFixtureObjects.erase(fixture->first);
			fixture = world->runtime->_physicsFixtureReferences.erase(fixture);
		}
	}
	world->invalidateDoraHandle();
	return 0;
}

int LoveRuntime::physicsWorldIsDestroyed(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	lua_pushboolean(state, !world->runtime || !world->runtime->_physicsBackend || !world->handle
		|| !world->runtime->_physicsBackend->isWorldValid(world->handle));
	return 1;
}

int LoveRuntime::physicsWorldUpdate(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	const float dt = static_cast<float>(luaL_checknumber(state, 2));
	const int velocity = static_cast<int>(luaL_optinteger(state, 3, 8));
	const int position = static_cast<int>(luaL_optinteger(state, 4, 3));
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	luaL_argcheck(state, std::isfinite(dt) && dt >= 0.0f, 2, "delta time must be finite and non-negative");
	luaL_argcheck(state, velocity > 0, 3, "velocity iterations must be positive");
	luaL_argcheck(state, position > 0, 4, "position iterations must be positive");
	std::string error;
	auto *runtime = world->runtime;
	const auto worldHandle = world->handle;
	const bool updated = runtime->_physicsBackend->updateWorld(worldHandle, dt, velocity, position, error);
	for (auto fixture = runtime->_physicsFixtureReferences.begin();
		fixture != runtime->_physicsFixtureReferences.end();)
	{
		if (runtime->_physicsBackend->isFixtureValid(fixture->first)) { ++fixture; continue; }
		if (auto object = runtime->_physicsFixtureObjects.find(fixture->first);
			object != runtime->_physicsFixtureObjects.end())
			static_cast<PhysicsFixtureUserdata *>(object->second.get())->invalidateDoraHandle();
		luaL_unref(state, LUA_REGISTRYINDEX, fixture->second);
		runtime->_physicsFixtureObjects.erase(fixture->first);
		fixture = runtime->_physicsFixtureReferences.erase(fixture);
	}
	if (!runtime->_physicsBackend->isWorldValid(worldHandle)) world->invalidateDoraHandle();
	if (!updated)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsWorldSetGravity(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1); float x = static_cast<float>(luaL_checknumber(state, 2));
	float y = static_cast<float>(luaL_checknumber(state, 3)); std::string error;
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	if (!world->runtime->_physicsBackend->setWorldGravity(world->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsWorldGetGravity(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	if (!world->runtime->_physicsBackend->getWorldGravity(world->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsWorldSetSleepingAllowed(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1); std::string error;
	if (!world->runtime || !world->runtime->_physicsBackend || !world->handle) return luaL_error(state, "World is destroyed");
	if (!world->runtime->_physicsBackend->setWorldSleepingAllowed(world->handle, lua_toboolean(state, 2), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsWorldIsSleepingAllowed(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1); bool value = false; std::string error;
	if (!world->runtime || !world->runtime->_physicsBackend || !world->handle) return luaL_error(state, "World is destroyed");
	if (!world->runtime->_physicsBackend->isWorldSleepingAllowed(world->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsWorldQueryBoundingBox(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_checktype(state, 6, LUA_TFUNCTION);
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	const float x1 = static_cast<float>(luaL_checknumber(state, 2));
	const float y1 = static_cast<float>(luaL_checknumber(state, 3));
	const float x2 = static_cast<float>(luaL_checknumber(state, 4));
	const float y2 = static_cast<float>(luaL_checknumber(state, 5));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 2, "query bounds must be finite");
	std::vector<PhysicsBackend::FixtureHandle> fixtures;
	std::string error;
	if (!world->runtime->_physicsBackend->queryWorld(world->handle, x1, y1, x2, y2, fixtures, error))
		return luaL_error(state, "%s", error.c_str());
	for (const auto handle : fixtures)
	{
		const auto found = world->runtime->_physicsFixtureReferences.find(handle);
		if (found == world->runtime->_physicsFixtureReferences.end()) continue;
		lua_pushvalue(state, 6);
		::love::luax_pushtype(state, PhysicsFixtureLoveType,
			static_cast<PhysicsFixtureUserdata *>(world->runtime->_physicsFixtureObjects.at(handle).get()));
		if (lua_pcall(state, 1, 1, 0) != LUA_OK) return lua_error(state);
		const bool keepGoing = lua_toboolean(state, -1);
		lua_pop(state, 1);
		if (!keepGoing) break;
	}
	return 0;
}

int LoveRuntime::physicsWorldRayCast(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_checktype(state, 6, LUA_TFUNCTION);
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	const float x1 = static_cast<float>(luaL_checknumber(state, 2));
	const float y1 = static_cast<float>(luaL_checknumber(state, 3));
	const float x2 = static_cast<float>(luaL_checknumber(state, 4));
	const float y2 = static_cast<float>(luaL_checknumber(state, 5));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 2, "ray endpoints must be finite");
	std::vector<PhysicsBackend::RayHit> hits;
	std::string error;
	if (!world->runtime->_physicsBackend->raycastWorld(world->handle, x1, y1, x2, y2, hits, error))
		return luaL_error(state, "%s", error.c_str());
	float maximumFraction = 1.0f;
	for (const auto &hit : hits)
	{
		if (hit.fraction > maximumFraction) continue;
		const auto found = world->runtime->_physicsFixtureReferences.find(hit.fixture);
		if (found == world->runtime->_physicsFixtureReferences.end()) continue;
		lua_pushvalue(state, 6);
		::love::luax_pushtype(state, PhysicsFixtureLoveType,
			static_cast<PhysicsFixtureUserdata *>(world->runtime->_physicsFixtureObjects.at(hit.fixture).get()));
		lua_pushnumber(state, hit.x); lua_pushnumber(state, hit.y);
		lua_pushnumber(state, hit.normalX); lua_pushnumber(state, hit.normalY);
		lua_pushnumber(state, hit.fraction);
		if (lua_pcall(state, 6, 1, 0) != LUA_OK) return lua_error(state);
		const float result = static_cast<float>(luaL_checknumber(state, -1));
		lua_pop(state, 1);
		if (!std::isfinite(result) || result < -1.0f || result > 1.0f)
			return luaL_error(state, "rayCast callback must return a finite value between -1 and 1");
		if (result == 0.0f) break;
		if (result > 0.0f) maximumFraction = std::min(maximumFraction, result);
	}
	return 0;
}

int LoveRuntime::physicsWorldSetCallbacks(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle,
		1, "World is destroyed");
	for (int index = 2; index <= 5; ++index)
		if (!lua_isnoneornil(state, index)) luaL_checktype(state, index, LUA_TFUNCTION);
	auto *runtime = world->runtime;
	auto &callbacks = runtime->_physicsWorldCallbacks[world->handle];
	for (int *reference : {&callbacks.begin, &callbacks.end, &callbacks.preSolve, &callbacks.postSolve})
	{
		if (*reference != LUA_NOREF) luaL_unref(state, LUA_REGISTRYINDEX, *reference);
		*reference = LUA_NOREF;
	}
	int *references[] = {&callbacks.begin, &callbacks.end, &callbacks.preSolve, &callbacks.postSolve};
	for (int index = 0; index < 4; ++index)
	{
		if (lua_isnoneornil(state, index + 2)) continue;
		lua_pushvalue(state, index + 2);
		*references[index] = luaL_ref(state, LUA_REGISTRYINDEX);
	}
	const auto worldHandle = world->handle;
	std::string error;
	if (!runtime->_physicsBackend->setWorldContactCallback(worldHandle,
		[runtime, worldHandle](const PhysicsBackend::ContactEvent &event, std::string &callbackError) {
			auto callbacksFound = runtime->_physicsWorldCallbacks.find(worldHandle);
			if (callbacksFound == runtime->_physicsWorldCallbacks.end() || !runtime->_state)
			{
				callbackError = "Love physics World callback state is closed";
				return false;
			}
			auto invalidateContact = [&]() {
				const auto contactFound = runtime->_physicsContactReferences.find(event.contact);
				if (contactFound == runtime->_physicsContactReferences.end()) return;
				if (auto object = runtime->_physicsContactObjects.find(event.contact);
					object != runtime->_physicsContactObjects.end())
					static_cast<PhysicsContactUserdata *>(object->second.get())->handle = 0;
				luaL_unref(runtime->_state, LUA_REGISTRYINDEX, contactFound->second);
				runtime->_physicsContactReferences.erase(contactFound);
				runtime->_physicsContactObjects.erase(event.contact);
			};
			const auto &callbacks = callbacksFound->second;
			const int reference = event.phase == PhysicsBackend::ContactPhase::Begin ? callbacks.begin
				: event.phase == PhysicsBackend::ContactPhase::End ? callbacks.end
				: event.phase == PhysicsBackend::ContactPhase::PreSolve ? callbacks.preSolve
				: callbacks.postSolve;
			if (reference == LUA_NOREF)
			{
				if (event.phase == PhysicsBackend::ContactPhase::End) invalidateContact();
				return true;
			}
			const auto fixtureA = runtime->_physicsFixtureReferences.find(event.fixtureA);
			const auto fixtureB = runtime->_physicsFixtureReferences.find(event.fixtureB);
			if (fixtureA == runtime->_physicsFixtureReferences.end()
				|| fixtureB == runtime->_physicsFixtureReferences.end())
			{
				callbackError = "Love physics contact references a closed Fixture";
				if (event.phase == PhysicsBackend::ContactPhase::End) invalidateContact();
				return false;
			}
			lua_rawgeti(runtime->_state, LUA_REGISTRYINDEX, reference);
			::love::luax_pushtype(runtime->_state, PhysicsFixtureLoveType,
				static_cast<PhysicsFixtureUserdata *>(runtime->_physicsFixtureObjects.at(event.fixtureA).get()));
			::love::luax_pushtype(runtime->_state, PhysicsFixtureLoveType,
				static_cast<PhysicsFixtureUserdata *>(runtime->_physicsFixtureObjects.at(event.fixtureB).get()));
			auto contactFound = runtime->_physicsContactReferences.find(event.contact);
			if (contactFound == runtime->_physicsContactReferences.end())
			{
				auto *contact = new PhysicsContactUserdata(runtime, event.contact, worldHandle,
					event.fixtureA, event.fixtureB, event.childA, event.childB);
				contact->fixtureAObject.set(static_cast<PhysicsFixtureUserdata *>(
					runtime->_physicsFixtureObjects.at(event.fixtureA).get()));
				contact->fixtureBObject.set(static_cast<PhysicsFixtureUserdata *>(
					runtime->_physicsFixtureObjects.at(event.fixtureB).get()));
				::love::luax_pushtype(runtime->_state, PhysicsContactLoveType, contact);
				contact->release();
				lua_pushvalue(runtime->_state, -1);
				const int contactReference = luaL_ref(runtime->_state, LUA_REGISTRYINDEX);
				runtime->_physicsContactReferences.emplace(event.contact, contactReference);
				runtime->_physicsContactObjects[event.contact].set(contact);
			}
			else
			{
				if (auto object = runtime->_physicsContactObjects.find(event.contact);
					object != runtime->_physicsContactObjects.end())
				{
					auto *contact = static_cast<PhysicsContactUserdata *>(object->second.get());
					contact->fixtureA = event.fixtureA;
					contact->fixtureB = event.fixtureB;
					contact->childA = event.childA;
					contact->childB = event.childB;
					::love::luax_pushtype(runtime->_state, PhysicsContactLoveType, contact);
				}
			}
			for (const float impulse : event.impulses) lua_pushnumber(runtime->_state, impulse);
			const int argumentCount = 3 + static_cast<int>(event.impulses.size());
			if (lua_pcall(runtime->_state, argumentCount, 0, 0) != LUA_OK)
			{
				const char *message = lua_tostring(runtime->_state, -1);
				callbackError = message ? message : "Love physics contact callback failed";
				lua_pop(runtime->_state, 1);
				if (event.phase == PhysicsBackend::ContactPhase::End) invalidateContact();
				return false;
			}
			if (event.phase == PhysicsBackend::ContactPhase::End) invalidateContact();
			callbackError.clear();
			return true;
		}, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsWorldGetCallbacks(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_argcheck(state, world->runtime && world->handle, 1, "World is destroyed");
	const auto found = world->runtime->_physicsWorldCallbacks.find(world->handle);
	const PhysicsWorldCallbacks empty;
	const auto &callbacks = found == world->runtime->_physicsWorldCallbacks.end() ? empty : found->second;
	for (const int reference : {callbacks.begin, callbacks.end, callbacks.preSolve, callbacks.postSolve})
	{
		if (reference == LUA_NOREF) lua_pushnil(state);
		else lua_rawgeti(state, LUA_REGISTRYINDEX, reference);
	}
	return 4;
}

int LoveRuntime::physicsBodyDestroy(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1);
	if (body->runtime && body->runtime->_physicsBackend && body->handle) body->releaseDoraHandle();
	if (body->runtime && body->runtime->_physicsBackend)
	{
		for (auto fixture = body->runtime->_physicsFixtureReferences.begin();
			fixture != body->runtime->_physicsFixtureReferences.end();)
		{
			if (body->runtime->_physicsBackend->isFixtureValid(fixture->first)) { ++fixture; continue; }
			if (auto object = body->runtime->_physicsFixtureObjects.find(fixture->first);
				object != body->runtime->_physicsFixtureObjects.end())
				static_cast<PhysicsFixtureUserdata *>(object->second.get())->invalidateDoraHandle();
			luaL_unref(state, LUA_REGISTRYINDEX, fixture->second);
			body->runtime->_physicsFixtureObjects.erase(fixture->first);
			fixture = body->runtime->_physicsFixtureReferences.erase(fixture);
		}
	}
	body->invalidateDoraHandle(); return 0;
}

int LoveRuntime::physicsBodyIsDestroyed(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1);
	lua_pushboolean(state, !body->runtime || !body->runtime->_physicsBackend || !body->handle
		|| !body->runtime->_physicsBackend->isBodyValid(body->handle));
	return 1;
}

int LoveRuntime::physicsBodyGetPosition(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	luaL_argcheck(state, body->runtime && body->runtime->_physicsBackend && body->handle, 1, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyPosition(body->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsBodySetPosition(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyPosition(body->handle, static_cast<float>(luaL_checknumber(state, 2)),
		static_cast<float>(luaL_checknumber(state, 3)), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetX(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyPosition(body->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); return 1;
}

int LoveRuntime::physicsBodySetX(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float x = static_cast<float>(luaL_checknumber(state, 2)), oldX = 0.0f, y = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	luaL_argcheck(state, std::isfinite(x), 2, "x must be finite");
	if (!body->runtime->_physicsBackend->getBodyPosition(body->handle, oldX, y, error)
		|| !body->runtime->_physicsBackend->setBodyPosition(body->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetY(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyPosition(body->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, y); return 1;
}

int LoveRuntime::physicsBodySetY(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float y = static_cast<float>(luaL_checknumber(state, 2)), x = 0.0f, oldY = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	luaL_argcheck(state, std::isfinite(y), 2, "y must be finite");
	if (!body->runtime->_physicsBackend->getBodyPosition(body->handle, x, oldY, error)
		|| !body->runtime->_physicsBackend->setBodyPosition(body->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetTransform(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float x = 0.0f, y = 0.0f, angle = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyPosition(body->handle, x, y, error)
		|| !body->runtime->_physicsBackend->getBodyAngle(body->handle, angle, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); lua_pushnumber(state, angle); return 3;
}

int LoveRuntime::physicsBodySetTransform(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float angle = static_cast<float>(luaL_checknumber(state, 4));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y) && std::isfinite(angle), 2, "transform must be finite");
	if (!body->runtime->_physicsBackend->setBodyPosition(body->handle, x, y, error)
		|| !body->runtime->_physicsBackend->setBodyAngle(body->handle, angle, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetAngle(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float value = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyAngle(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsBodySetAngle(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyAngle(body->handle, static_cast<float>(luaL_checknumber(state, 2)), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetLinearVelocity(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyLinearVelocity(body->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsBodySetLinearVelocity(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyLinearVelocity(body->handle, static_cast<float>(luaL_checknumber(state, 2)),
		static_cast<float>(luaL_checknumber(state, 3)), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetAngularVelocity(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float value = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyAngularVelocity(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsBodySetAngularVelocity(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "angular velocity must be finite");
	if (!body->runtime->_physicsBackend->setBodyAngularVelocity(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetLinearDamping(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float value = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyLinearDamping(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsBodySetLinearDamping(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2, "linear damping must be finite and non-negative");
	if (!body->runtime->_physicsBackend->setBodyLinearDamping(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetAngularDamping(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float value = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyAngularDamping(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsBodySetAngularDamping(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2, "angular damping must be finite and non-negative");
	if (!body->runtime->_physicsBackend->setBodyAngularDamping(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetMass(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float value = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyMass(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsBodyGetInertia(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float value = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyInertia(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsBodyGetMassData(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1);
	float x = 0.0f, y = 0.0f, mass = 0.0f, inertia = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle)
		return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyMassData(
		body->handle, x, y, mass, inertia, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y);
	lua_pushnumber(state, mass); lua_pushnumber(state, inertia); return 4;
}

int LoveRuntime::physicsBodySetMassData(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle)
		return luaL_error(state, "Body is destroyed");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float mass = static_cast<float>(luaL_checknumber(state, 4));
	const float inertia = static_cast<float>(luaL_checknumber(state, 5));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y)
		&& std::isfinite(mass) && std::isfinite(inertia), 2, "mass data must be finite");
	if (!body->runtime->_physicsBackend->setBodyMassData(
		body->handle, x, y, mass, inertia, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyResetMassData(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle)
		return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->resetBodyMassData(body->handle, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodySetMass(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "mass must be finite");
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle)
		return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyMass(body->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodySetInertia(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "inertia must be finite");
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle)
		return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyInertia(body->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetGravityScale(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float value = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle)
		return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyGravityScale(body->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsBodySetGravityScale(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "gravity scale must be finite");
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle)
		return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyGravityScale(body->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetLocalCenter(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyCenter(body->handle, false, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsBodyGetWorldCenter(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->getBodyCenter(body->handle, true, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsBodyIsFixedRotation(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); bool value = false; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->isBodyFixedRotation(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsBodySetFixedRotation(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyFixedRotation(body->handle, lua_toboolean(state, 2), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyIsAwake(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); bool value = false; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->isBodyAwake(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsBodySetAwake(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyAwake(body->handle, lua_toboolean(state, 2), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyIsSleepingAllowed(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); bool value = false; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->isBodySleepingAllowed(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsBodySetSleepingAllowed(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodySleepingAllowed(body->handle, lua_toboolean(state, 2), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyIsActive(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); bool value = false; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->isBodyActive(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsBodySetActive(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyActive(body->handle, lua_toboolean(state, 2), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyIsBullet(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); bool value = false; std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->isBodyBullet(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsBodySetBullet(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	if (!body->runtime->_physicsBackend->setBodyBullet(body->handle, lua_toboolean(state, 2), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyApplyLinearImpulse(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	float px = 0.0f, py = 0.0f;
	if (lua_gettop(state) >= 5) { px = static_cast<float>(luaL_checknumber(state, 4)); py = static_cast<float>(luaL_checknumber(state, 5)); }
	else if (!body->runtime->_physicsBackend->getBodyPosition(body->handle, px, py, error)) return luaL_error(state, "%s", error.c_str());
	if (!body->runtime->_physicsBackend->applyBodyLinearImpulse(body->handle,
		static_cast<float>(luaL_checknumber(state, 2)), static_cast<float>(luaL_checknumber(state, 3)), px, py, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyApplyAngularImpulse(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "angular impulse must be finite");
	if (!body->runtime->_physicsBackend->applyBodyAngularImpulse(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyApplyForce(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2, "force must be finite");
	float px = 0.0f, py = 0.0f;
	if (lua_gettop(state) >= 5)
	{
		px = static_cast<float>(luaL_checknumber(state, 4));
		py = static_cast<float>(luaL_checknumber(state, 5));
		luaL_argcheck(state, std::isfinite(px) && std::isfinite(py), 4, "force point must be finite");
	}
	else if (!body->runtime->_physicsBackend->getBodyCenter(body->handle, true, px, py, error))
		return luaL_error(state, "%s", error.c_str());
	if (!body->runtime->_physicsBackend->applyBodyForce(body->handle, x, y, px, py, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyApplyTorque(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "torque must be finite");
	if (!body->runtime->_physicsBackend->applyBodyTorque(body->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsBodyGetType(lua_State *state) { auto *body = checkPhysicsBody(state, 1); luaL_argcheck(state, body->runtime && body->runtime->_physicsBackend && body->handle && body->runtime->_physicsBackend->isBodyValid(body->handle), 1, "Body is destroyed"); lua_pushlstring(state, body->type.data(), body->type.size()); return 1; }

int LoveRuntime::physicsBodySetType(lua_State *state)
{
	auto *body = checkPhysicsBody(state, 1); std::string error;
	if (!body->runtime || !body->runtime->_physicsBackend || !body->handle) return luaL_error(state, "Body is destroyed");
	const char *type = luaL_checkstring(state, 2);
	luaL_argcheck(state, std::string_view(type) == "static" || std::string_view(type) == "dynamic"
		|| std::string_view(type) == "kinematic", 2, "expected 'static', 'dynamic', or 'kinematic'");
	if (!body->runtime->_physicsBackend->setBodyType(body->handle, type, error)) return luaL_error(state, "%s", error.c_str());
	body->type = type; return 0;
}

static int transformPhysicsBodyArguments(lua_State *state, PhysicsBodyUserdata *body,
	PhysicsBackend *backend, bool toWorld, bool vector, bool multiple)
{
	if (!body->runtime || !backend || !body->handle) return luaL_error(state, "Body is destroyed");
	const int count = lua_gettop(state) - 1;
	luaL_argcheck(state, count >= 2 && count % 2 == 0, 2, "expected one or more x, y pairs");
	if (!multiple) luaL_argcheck(state, count == 2, 2, "expected exactly one x, y pair");
	std::string error;
	for (int index = 2; index <= count + 1; index += 2)
	{
		const float x = static_cast<float>(luaL_checknumber(state, index));
		const float y = static_cast<float>(luaL_checknumber(state, index + 1));
		luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), index, "coordinates must be finite");
		float outX = 0.0f, outY = 0.0f;
		if (!backend->transformBodyPoint(
			body->handle, toWorld, vector, x, y, outX, outY, error))
			return luaL_error(state, "%s", error.c_str());
		lua_pushnumber(state, outX); lua_pushnumber(state, outY);
	}
	return count;
}

int LoveRuntime::physicsBodyGetWorldPoint(lua_State *state) { auto *body = checkPhysicsBody(state, 1); return transformPhysicsBodyArguments(state, body, body->runtime ? body->runtime->_physicsBackend : nullptr, true, false, false); }
int LoveRuntime::physicsBodyGetWorldVector(lua_State *state) { auto *body = checkPhysicsBody(state, 1); return transformPhysicsBodyArguments(state, body, body->runtime ? body->runtime->_physicsBackend : nullptr, true, true, false); }
int LoveRuntime::physicsBodyGetWorldPoints(lua_State *state) { auto *body = checkPhysicsBody(state, 1); return transformPhysicsBodyArguments(state, body, body->runtime ? body->runtime->_physicsBackend : nullptr, true, false, true); }
int LoveRuntime::physicsBodyGetLocalPoint(lua_State *state) { auto *body = checkPhysicsBody(state, 1); return transformPhysicsBodyArguments(state, body, body->runtime ? body->runtime->_physicsBackend : nullptr, false, false, false); }
int LoveRuntime::physicsBodyGetLocalVector(lua_State *state) { auto *body = checkPhysicsBody(state, 1); return transformPhysicsBodyArguments(state, body, body->runtime ? body->runtime->_physicsBackend : nullptr, false, true, false); }
int LoveRuntime::physicsBodyGetLocalPoints(lua_State *state) { auto *body = checkPhysicsBody(state, 1); return transformPhysicsBodyArguments(state, body, body->runtime ? body->runtime->_physicsBackend : nullptr, false, false, true); }

static int getPhysicsBodyPointVelocity(lua_State *state, PhysicsBodyUserdata *body,
	PhysicsBackend *backend, bool local)
{
	if (!body->runtime || !backend || !body->handle) return luaL_error(state, "Body is destroyed");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2, "point must be finite");
	float outX = 0.0f, outY = 0.0f; std::string error;
	if (!backend->getBodyPointVelocity(
		body->handle, local, x, y, outX, outY, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, outX); lua_pushnumber(state, outY); return 2;
}

int LoveRuntime::physicsBodyGetLinearVelocityFromWorldPoint(lua_State *state) { auto *body = checkPhysicsBody(state, 1); return getPhysicsBodyPointVelocity(state, body, body->runtime ? body->runtime->_physicsBackend : nullptr, false); }
int LoveRuntime::physicsBodyGetLinearVelocityFromLocalPoint(lua_State *state) { auto *body = checkPhysicsBody(state, 1); return getPhysicsBodyPointVelocity(state, body, body->runtime ? body->runtime->_physicsBackend : nullptr, true); }

int LoveRuntime::physicsShapeGetType(lua_State *state) { auto *s = checkPhysicsShape(state, 1); lua_pushlstring(state, s->type.data(), s->type.size()); return 1; }
int LoveRuntime::physicsShapeGetRadius(lua_State *state) { lua_pushnumber(state, checkPhysicsShape(state, 1)->radius); return 1; }
int LoveRuntime::physicsShapeGetPoints(lua_State *state) { auto *s = checkPhysicsShape(state, 1); for (float v : s->points) lua_pushnumber(state, v); return static_cast<int>(s->points.size()); }
int LoveRuntime::physicsShapeValidate(lua_State *state) { auto *s = checkPhysicsShape(state, 1); luaL_argcheck(state, s->type == "polygon", 1, "expected PolygonShape"); lua_pushboolean(state, true); return 1; }
int LoveRuntime::physicsShapeGetVertexCount(lua_State *state) { auto *s = checkPhysicsShape(state, 1); luaL_argcheck(state, s->type == "chain", 1, "expected ChainShape"); lua_pushinteger(state, static_cast<lua_Integer>(s->points.size() / 2)); return 1; }
int LoveRuntime::physicsShapeGetPoint(lua_State *state) { auto *s = checkPhysicsShape(state, 1); luaL_argcheck(state, s->type == "chain", 1, "expected ChainShape"); const lua_Integer index = luaL_checkinteger(state, 2); const auto count = static_cast<lua_Integer>(s->points.size() / 2); luaL_argcheck(state, index >= 1 && index <= count, 2, "ChainShape point index is out of bounds"); lua_pushnumber(state, s->points[static_cast<std::size_t>(index - 1) * 2]); lua_pushnumber(state, s->points[static_cast<std::size_t>(index - 1) * 2 + 1]); return 2; }

int LoveRuntime::physicsShapeGetChildEdge(lua_State *state)
{
	auto *chain = checkPhysicsShape(state, 1);
	luaL_argcheck(state, chain->type == "chain", 1, "expected ChainShape");
	const lua_Integer index = luaL_checkinteger(state, 2) - 1;
	const auto vertexCount = static_cast<lua_Integer>(chain->points.size() / 2);
	const auto childCount = vertexCount > 0 ? vertexCount - 1 : 0;
	luaL_argcheck(state, index >= 0 && index < childCount, 2,
		"ChainShape child edge index is out of bounds");
	const auto first = static_cast<std::size_t>(index) * 2;
	const float x1 = chain->points[first], y1 = chain->points[first + 1];
	const float x2 = chain->points[first + 2], y2 = chain->points[first + 3];
	std::string error;
	const auto handle = chain->runtime->_physicsBackend->newEdgeShape(x1, y1, x2, y2, error);
	if (!handle) return luaL_error(state, "%s",
		error.empty() ? "failed to create ChainShape child EdgeShape" : error.c_str());
	auto *edge = new PhysicsShapeUserdata(chain->runtime, handle, "edge", 0.0f,
		{x1, y1, x2, y2});
	pushNewDoraHandleObject(state, PhysicsShapeLoveType, edge);
	if (index > 0)
	{
		edge->hasPreviousVertex = true;
		edge->previousX = chain->points[first - 2];
		edge->previousY = chain->points[first - 1];
	}
	else if (chain->loop)
	{
		edge->hasPreviousVertex = true;
		edge->previousX = chain->points[chain->points.size() - 4];
		edge->previousY = chain->points[chain->points.size() - 3];
	}
	else if (chain->hasPreviousVertex)
	{
		edge->hasPreviousVertex = true;
		edge->previousX = chain->previousX;
		edge->previousY = chain->previousY;
	}
	if (index + 2 < vertexCount)
	{
		edge->hasNextVertex = true;
		edge->nextX = chain->points[first + 4];
		edge->nextY = chain->points[first + 5];
	}
	else if (chain->loop)
	{
		edge->hasNextVertex = true;
		edge->nextX = chain->points[2];
		edge->nextY = chain->points[3];
	}
	else if (chain->hasNextVertex)
	{
		edge->hasNextVertex = true;
		edge->nextX = chain->nextX;
		edge->nextY = chain->nextY;
	}
	if (edge->hasPreviousVertex && !chain->runtime->_physicsBackend->setShapePreviousVertex(
		handle, true, edge->previousX, edge->previousY, error))
	{
		edge->releaseDoraHandle();
		return luaL_error(state, "%s", error.empty()
			? "failed to set child EdgeShape previous vertex" : error.c_str());
	}
	if (edge->hasNextVertex && !chain->runtime->_physicsBackend->setShapeNextVertex(
		handle, true, edge->nextX, edge->nextY, error))
	{
		edge->releaseDoraHandle();
		return luaL_error(state, "%s", error.empty()
			? "failed to set child EdgeShape next vertex" : error.c_str());
	}
	return 1;
}

int LoveRuntime::physicsShapeGetPreviousVertex(lua_State *state)
{
	auto *shape = checkPhysicsShape(state, 1);
	luaL_argcheck(state, shape->type == "edge" || shape->type == "chain", 1,
		"expected EdgeShape or ChainShape");
	if (!shape->hasPreviousVertex) return 0;
	lua_pushnumber(state, shape->previousX); lua_pushnumber(state, shape->previousY); return 2;
}

int LoveRuntime::physicsShapeGetNextVertex(lua_State *state)
{
	auto *shape = checkPhysicsShape(state, 1);
	luaL_argcheck(state, shape->type == "edge" || shape->type == "chain", 1,
		"expected EdgeShape or ChainShape");
	if (!shape->hasNextVertex) return 0;
	lua_pushnumber(state, shape->nextX); lua_pushnumber(state, shape->nextY); return 2;
}

int LoveRuntime::physicsShapeSetPreviousVertex(lua_State *state)
{
	auto *shape = checkPhysicsShape(state, 1);
	luaL_argcheck(state, shape->type == "edge" || shape->type == "chain", 1,
		"expected EdgeShape or ChainShape");
	const bool hasVertex = !lua_isnoneornil(state, 2);
	float x = 0.0f, y = 0.0f;
	if (hasVertex)
	{
		x = static_cast<float>(luaL_checknumber(state, 2));
		y = static_cast<float>(luaL_checknumber(state, 3));
		luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2,
			"previous vertex must be finite");
	}
	std::string error;
	if (!shape->runtime->_physicsBackend->setShapePreviousVertex(
		shape->handle, hasVertex, x, y, error))
		return luaL_error(state, "%s", error.empty()
			? "failed to set previous vertex" : error.c_str());
	shape->hasPreviousVertex = hasVertex;
	shape->previousX = x;
	shape->previousY = y;
	return 0;
}

int LoveRuntime::physicsShapeSetNextVertex(lua_State *state)
{
	auto *shape = checkPhysicsShape(state, 1);
	luaL_argcheck(state, shape->type == "edge" || shape->type == "chain", 1,
		"expected EdgeShape or ChainShape");
	const bool hasVertex = !lua_isnoneornil(state, 2);
	float x = 0.0f, y = 0.0f;
	if (hasVertex)
	{
		x = static_cast<float>(luaL_checknumber(state, 2));
		y = static_cast<float>(luaL_checknumber(state, 3));
		luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2,
			"next vertex must be finite");
	}
	std::string error;
	if (!shape->runtime->_physicsBackend->setShapeNextVertex(
		shape->handle, hasVertex, x, y, error))
		return luaL_error(state, "%s", error.empty()
			? "failed to set next vertex" : error.c_str());
	shape->hasNextVertex = hasVertex;
	shape->nextX = x;
	shape->nextY = y;
	return 0;
}

int LoveRuntime::physicsFixtureDestroy(lua_State *state)
{
	auto *fixture = checkPhysicsFixture(state, 1);
	if (fixture->runtime && fixture->handle)
	{
		const auto handle = fixture->handle;
		if (fixture->runtime->_physicsBackend) fixture->releaseDoraHandle();
		if (!fixture->runtime->_physicsBackend
			|| !fixture->runtime->_physicsBackend->isFixtureValid(handle))
		{
			const auto reference = fixture->runtime->_physicsFixtureReferences.find(handle);
			if (reference != fixture->runtime->_physicsFixtureReferences.end())
			{
				luaL_unref(state, LUA_REGISTRYINDEX, reference->second);
				fixture->runtime->_physicsFixtureReferences.erase(reference);
				fixture->runtime->_physicsFixtureObjects.erase(handle);
			}
		}
	}
	fixture->invalidateDoraHandle(); return 0;
}

int LoveRuntime::physicsFixtureIsDestroyed(lua_State *state)
{
	auto *fixture = checkPhysicsFixture(state, 1);
	lua_pushboolean(state, !fixture->runtime || !fixture->runtime->_physicsBackend || !fixture->handle
		|| !fixture->runtime->_physicsBackend->isFixtureValid(fixture->handle));
	return 1;
}

int LoveRuntime::physicsFixtureSetFriction(lua_State *state) { auto *f = checkPhysicsFixture(state, 1); float v = static_cast<float>(luaL_checknumber(state, 2)); std::string e; luaL_argcheck(state, f->runtime && f->runtime->_physicsBackend && f->handle && f->runtime->_physicsBackend->isFixtureValid(f->handle), 1, "Fixture is destroyed"); luaL_argcheck(state, std::isfinite(v) && v >= 0.0f, 2, "friction must be non-negative"); if (!f->runtime->_physicsBackend->setFixtureFriction(f->handle, v, e)) return luaL_error(state, "%s", e.c_str()); f->friction = v; return 0; }
int LoveRuntime::physicsFixtureGetFriction(lua_State *state) { auto *f = checkPhysicsFixture(state, 1); luaL_argcheck(state, f->runtime && f->runtime->_physicsBackend && f->handle && f->runtime->_physicsBackend->isFixtureValid(f->handle), 1, "Fixture is destroyed"); lua_pushnumber(state, f->friction); return 1; }
int LoveRuntime::physicsFixtureSetRestitution(lua_State *state) { auto *f = checkPhysicsFixture(state, 1); float v = static_cast<float>(luaL_checknumber(state, 2)); std::string e; luaL_argcheck(state, f->runtime && f->runtime->_physicsBackend && f->handle && f->runtime->_physicsBackend->isFixtureValid(f->handle), 1, "Fixture is destroyed"); luaL_argcheck(state, std::isfinite(v) && v >= 0.0f, 2, "restitution must be non-negative"); if (!f->runtime->_physicsBackend->setFixtureRestitution(f->handle, v, e)) return luaL_error(state, "%s", e.c_str()); f->restitution = v; return 0; }
int LoveRuntime::physicsFixtureGetRestitution(lua_State *state) { auto *f = checkPhysicsFixture(state, 1); luaL_argcheck(state, f->runtime && f->runtime->_physicsBackend && f->handle && f->runtime->_physicsBackend->isFixtureValid(f->handle), 1, "Fixture is destroyed"); lua_pushnumber(state, f->restitution); return 1; }
int LoveRuntime::physicsFixtureSetSensor(lua_State *state) { auto *f = checkPhysicsFixture(state, 1); luaL_checktype(state, 2, LUA_TBOOLEAN); bool v = lua_toboolean(state, 2); std::string e; luaL_argcheck(state, f->runtime && f->runtime->_physicsBackend && f->handle && f->runtime->_physicsBackend->isFixtureValid(f->handle), 1, "Fixture is destroyed"); if (!f->runtime->_physicsBackend->setFixtureSensor(f->handle, v, e)) return luaL_error(state, "%s", e.c_str()); f->sensor = v; return 0; }
int LoveRuntime::physicsFixtureIsSensor(lua_State *state) { auto *f = checkPhysicsFixture(state, 1); luaL_argcheck(state, f->runtime && f->runtime->_physicsBackend && f->handle && f->runtime->_physicsBackend->isFixtureValid(f->handle), 1, "Fixture is destroyed"); lua_pushboolean(state, f->sensor); return 1; }

namespace
{
PhysicsFixtureUserdata *checkLivePhysicsFixture(lua_State *state)
{
	auto *fixture = checkPhysicsFixture(state, 1);
	luaL_argcheck(state, fixture->runtime && fixture->handle, 1, "Fixture is destroyed");
	return fixture;
}

std::uint16_t fixtureBitsFromLua(lua_State *state, int first)
{
	std::uint16_t bits = 0;
	const bool table = lua_istable(state, first);
	const lua_Integer count = table ? static_cast<lua_Integer>(lua_rawlen(state, first))
		: static_cast<lua_Integer>(lua_gettop(state) - first + 1);
	for (lua_Integer index = 1; index <= count; ++index)
	{
		lua_Integer category = 0;
		if (table)
		{
			lua_rawgeti(state, first, index);
			if (!lua_isinteger(state, -1))
				return static_cast<std::uint16_t>(luaL_error(state,
					"Fixture category values must be integers in range 1-16"));
			category = lua_tointeger(state, -1);
			lua_pop(state, 1);
		}
		else category = luaL_checkinteger(state, first + static_cast<int>(index) - 1);
		if (category < 1 || category > 16)
			return static_cast<std::uint16_t>(luaL_error(state,
				"Fixture category values must be integers in range 1-16"));
		bits |= static_cast<std::uint16_t>(1u << (category - 1));
	}
	return bits;
}

int pushFixtureBits(lua_State *state, std::uint16_t bits)
{
	int count = 0;
	for (int index = 0; index < 16; ++index)
		if ((bits & static_cast<std::uint16_t>(1u << index)) != 0)
		{ lua_pushinteger(state, index + 1); ++count; }
	return count;
}
}

int LoveRuntime::physicsFixtureGetType(lua_State *state)
{
	checkLivePhysicsFixture(state);
	lua_getiuservalue(state, 1, 2);
	auto *shape = checkPhysicsShape(state, -1);
	lua_pushlstring(state, shape->type.data(), shape->type.size());
	return 1;
}

int LoveRuntime::physicsFixtureSetDensity(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2,
		"density must be finite and non-negative");
	std::string error;
	if (!fixture->runtime->_physicsBackend->setFixtureDensity(fixture->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	fixture->density = value;
	return 0;
}

int LoveRuntime::physicsFixtureGetDensity(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	lua_pushnumber(state, fixture->density);
	return 1;
}

int LoveRuntime::physicsFixtureGetBody(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	::love::luax_pushtype(state, PhysicsBodyLoveType, fixture->bodyObject.get());
	return 1;
}

int LoveRuntime::physicsFixtureGetShape(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	::love::luax_pushtype(state, PhysicsShapeLoveType, fixture->shapeObject.get());
	return 1;
}

int LoveRuntime::physicsFixtureTestPoint(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2,
		"point must be finite");
	bool value = false; std::string error;
	if (!fixture->runtime->_physicsBackend->testFixturePoint(
		fixture->handle, x, y, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsFixtureRayCast(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	const float x1 = static_cast<float>(luaL_checknumber(state, 2));
	const float y1 = static_cast<float>(luaL_checknumber(state, 3));
	const float x2 = static_cast<float>(luaL_checknumber(state, 4));
	const float y2 = static_cast<float>(luaL_checknumber(state, 5));
	const float maximum = static_cast<float>(luaL_checknumber(state, 6));
	const lua_Integer child = luaL_optinteger(state, 7, 1);
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 2, "ray points must be finite");
	luaL_argcheck(state, std::isfinite(maximum) && maximum >= 0.0f && maximum <= 1.0f,
		6, "maximum fraction must be in range 0-1");
	luaL_argcheck(state, child >= 1 && child <= 65536, 7,
		"child index must be a positive integer");
	bool hit = false; float nx = 0.0f, ny = 0.0f, fraction = 0.0f; std::string error;
	if (!fixture->runtime->_physicsBackend->rayCastFixture(fixture->handle,
		x1, y1, x2, y2, maximum, static_cast<std::uint16_t>(child - 1),
		hit, nx, ny, fraction, error))
		return luaL_error(state, "%s", error.c_str());
	if (!hit) return 0;
	lua_pushnumber(state, nx); lua_pushnumber(state, ny); lua_pushnumber(state, fraction);
	return 3;
}

int LoveRuntime::physicsFixtureSetFilterData(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	const auto category = static_cast<std::uint16_t>(luaL_checkinteger(state, 2));
	const auto mask = static_cast<std::uint16_t>(luaL_checkinteger(state, 3));
	const lua_Integer group = luaL_checkinteger(state, 4);
	luaL_argcheck(state, group >= -32768 && group <= 32767, 4,
		"group index must be in signed 16-bit range");
	std::string error;
	if (!fixture->runtime->_physicsBackend->setFixtureFilterData(fixture->handle,
		category, mask, static_cast<std::int16_t>(group), error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsFixtureGetFilterData(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	std::uint16_t category = 0, mask = 0; std::int16_t group = 0; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureFilterData(
		fixture->handle, category, mask, group, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushinteger(state, category); lua_pushinteger(state, mask); lua_pushinteger(state, group);
	return 3;
}

int LoveRuntime::physicsFixtureSetCategory(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	const auto category = fixtureBitsFromLua(state, 2);
	std::uint16_t oldCategory = 0, mask = 0; std::int16_t group = 0; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureFilterData(
		fixture->handle, oldCategory, mask, group, error)
		|| !fixture->runtime->_physicsBackend->setFixtureFilterData(
			fixture->handle, category, mask, group, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsFixtureGetCategory(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	std::uint16_t category = 0, mask = 0; std::int16_t group = 0; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureFilterData(
		fixture->handle, category, mask, group, error))
		return luaL_error(state, "%s", error.c_str());
	return pushFixtureBits(state, category);
}

int LoveRuntime::physicsFixtureSetMask(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	const auto excluded = fixtureBitsFromLua(state, 2);
	std::uint16_t category = 0, oldMask = 0; std::int16_t group = 0; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureFilterData(
		fixture->handle, category, oldMask, group, error)
		|| !fixture->runtime->_physicsBackend->setFixtureFilterData(
			fixture->handle, category, static_cast<std::uint16_t>(~excluded), group, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsFixtureGetMask(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	std::uint16_t category = 0, mask = 0; std::int16_t group = 0; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureFilterData(
		fixture->handle, category, mask, group, error))
		return luaL_error(state, "%s", error.c_str());
	return pushFixtureBits(state, static_cast<std::uint16_t>(~mask));
}

int LoveRuntime::physicsFixtureSetUserData(lua_State *state)
{
	checkLivePhysicsFixture(state); luaL_checkany(state, 2);
	lua_pushvalue(state, 2); lua_setiuservalue(state, 1, 3); return 0;
}

int LoveRuntime::physicsFixtureGetUserData(lua_State *state)
{
	checkLivePhysicsFixture(state); lua_getiuservalue(state, 1, 3); return 1;
}

int LoveRuntime::physicsFixtureGetBoundingBox(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	const lua_Integer child = luaL_optinteger(state, 2, 1);
	luaL_argcheck(state, child >= 1 && child <= 65536, 2,
		"child index must be a positive integer");
	float x1 = 0.0f, y1 = 0.0f, x2 = 0.0f, y2 = 0.0f; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureBoundingBox(fixture->handle,
		static_cast<std::uint16_t>(child - 1), x1, y1, x2, y2, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x1); lua_pushnumber(state, y1);
	lua_pushnumber(state, x2); lua_pushnumber(state, y2); return 4;
}

int LoveRuntime::physicsFixtureGetMassData(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	float x = 0.0f, y = 0.0f, mass = 0.0f, inertia = 0.0f; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureMassData(
		fixture->handle, x, y, mass, inertia, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y);
	lua_pushnumber(state, mass); lua_pushnumber(state, inertia); return 4;
}

int LoveRuntime::physicsFixtureGetGroupIndex(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	std::uint16_t category = 0, mask = 0; std::int16_t group = 0; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureFilterData(
		fixture->handle, category, mask, group, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushinteger(state, group); return 1;
}

int LoveRuntime::physicsFixtureSetGroupIndex(lua_State *state)
{
	auto *fixture = checkLivePhysicsFixture(state);
	const lua_Integer value = luaL_checkinteger(state, 2);
	luaL_argcheck(state, value >= -32768 && value <= 32767, 2,
		"group index must be in signed 16-bit range");
	std::uint16_t category = 0, mask = 0; std::int16_t group = 0; std::string error;
	if (!fixture->runtime->_physicsBackend->getFixtureFilterData(
		fixture->handle, category, mask, group, error)
		|| !fixture->runtime->_physicsBackend->setFixtureFilterData(
			fixture->handle, category, mask, static_cast<std::int16_t>(value), error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsJointDestroy(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1);
	if (joint->runtime && joint->runtime->_physicsBackend && joint->handle)
		joint->releaseDoraHandle();
	joint->invalidateDoraHandle(); return 0;
}

int LoveRuntime::physicsJointIsDestroyed(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1);
	lua_pushboolean(state, !joint->runtime || !joint->runtime->_physicsBackend || !joint->handle
		|| !joint->runtime->_physicsBackend->isJointValid(joint->handle));
	return 1;
}

int LoveRuntime::physicsJointGetType(lua_State *state) { auto *j = checkPhysicsJoint(state, 1); luaL_argcheck(state, j->runtime && j->runtime->_physicsBackend && j->handle && j->runtime->_physicsBackend->isJointValid(j->handle), 1, "Joint is destroyed"); lua_pushlstring(state, j->type.data(), j->type.size()); return 1; }
int LoveRuntime::physicsJointGetBodies(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1);
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	::love::luax_pushtype(state, PhysicsBodyLoveType, joint->bodyAObject.get());
	::love::luax_pushtype(state, PhysicsBodyLoveType, joint->bodyBObject.get());
	return 2;
}

int LoveRuntime::physicsJointGetAnchors(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float x1 = 0, y1 = 0, x2 = 0, y2 = 0; std::string error;
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getJointAnchors(joint->handle, x1, y1, x2, y2, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x1); lua_pushnumber(state, y1);
	lua_pushnumber(state, x2); lua_pushnumber(state, y2); return 4;
}

int LoveRuntime::physicsJointGetReactionForce(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float x = 0, y = 0;
	const float inverseDeltaTime = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(inverseDeltaTime) && inverseDeltaTime >= 0, 2,
		"inverse delta time must be finite and non-negative");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getJointReactionForce(
		joint->handle, inverseDeltaTime, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsJointGetReactionTorque(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float value = 0;
	const float inverseDeltaTime = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(inverseDeltaTime) && inverseDeltaTime >= 0, 2,
		"inverse delta time must be finite and non-negative");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getJointReactionTorque(
		joint->handle, inverseDeltaTime, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsJointGetCollideConnected(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; bool value = false;
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getJointCollideConnected(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsJointSetUserData(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1);
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	lua_settop(state, 2); lua_setiuservalue(state, 1, 3); return 0;
}

int LoveRuntime::physicsJointGetUserData(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1);
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	lua_getiuservalue(state, 1, 3); return 1;
}

int LoveRuntime::physicsDistanceJointGetLength(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float value = 0;
	luaL_argcheck(state, joint->type == "distance", 1, "DistanceJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getDistanceJointLength(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsDistanceJointSetLength(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_argcheck(state, joint->type == "distance", 1, "DistanceJoint expected");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0, 2, "length must be finite and non-negative");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setDistanceJointLength(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsDistanceJointGetFrequency(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float value = 0;
	luaL_argcheck(state, joint->type == "distance" || joint->type == "weld"
		|| joint->type == "mouse", 1, "DistanceJoint, WeldJoint, or MouseJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "distance"
		? joint->runtime->_physicsBackend->getDistanceJointFrequency(joint->handle, value, error)
		: joint->type == "weld"
			? joint->runtime->_physicsBackend->getWeldJointFrequency(joint->handle, value, error)
			: joint->runtime->_physicsBackend->getMouseJointFrequency(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsDistanceJointSetFrequency(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_argcheck(state, joint->type == "distance" || joint->type == "weld"
		|| joint->type == "mouse", 1, "DistanceJoint, WeldJoint, or MouseJoint expected");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && (joint->type == "mouse" ? value > 0 : value >= 0),
		2, joint->type == "mouse" ? "frequency must be finite and positive"
			: "frequency must be finite and non-negative");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "distance"
		? joint->runtime->_physicsBackend->setDistanceJointFrequency(joint->handle, value, error)
		: joint->type == "weld"
			? joint->runtime->_physicsBackend->setWeldJointFrequency(joint->handle, value, error)
			: joint->runtime->_physicsBackend->setMouseJointFrequency(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsDistanceJointGetDampingRatio(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float value = 0;
	luaL_argcheck(state, joint->type == "distance" || joint->type == "weld"
		|| joint->type == "mouse", 1, "DistanceJoint, WeldJoint, or MouseJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "distance"
		? joint->runtime->_physicsBackend->getDistanceJointDampingRatio(joint->handle, value, error)
		: joint->type == "weld"
			? joint->runtime->_physicsBackend->getWeldJointDampingRatio(joint->handle, value, error)
			: joint->runtime->_physicsBackend->getMouseJointDampingRatio(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsDistanceJointSetDampingRatio(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_argcheck(state, joint->type == "distance" || joint->type == "weld"
		|| joint->type == "mouse", 1, "DistanceJoint, WeldJoint, or MouseJoint expected");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0, 2,
		"damping ratio must be finite and non-negative");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "distance"
		? joint->runtime->_physicsBackend->setDistanceJointDampingRatio(joint->handle, value, error)
		: joint->type == "weld"
			? joint->runtime->_physicsBackend->setWeldJointDampingRatio(joint->handle, value, error)
			: joint->runtime->_physicsBackend->setMouseJointDampingRatio(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsRevoluteJointGetJointAngle(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "revolute", 1, "RevoluteJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getRevoluteJointAngle(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsRevoluteJointGetJointSpeed(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic" || joint->type == "wheel", 1,
		"RevoluteJoint, PrismaticJoint, or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointSpeed(joint->handle, value, error)
		: joint->type == "prismatic"
			? joint->runtime->_physicsBackend->getPrismaticJointSpeed(joint->handle, value, error)
			: joint->runtime->_physicsBackend->getWheelJointSpeed(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsRevoluteJointSetMotorEnabled(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_checktype(state, 2, LUA_TBOOLEAN);
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic" || joint->type == "wheel", 1,
		"RevoluteJoint, PrismaticJoint, or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->setRevoluteJointMotorEnabled(
			joint->handle, lua_toboolean(state, 2), error)
		: joint->type == "prismatic"
			? joint->runtime->_physicsBackend->setPrismaticJointMotorEnabled(
				joint->handle, lua_toboolean(state, 2), error)
			: joint->runtime->_physicsBackend->setWheelJointMotorEnabled(
				joint->handle, lua_toboolean(state, 2), error);
	if (!success) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsRevoluteJointIsMotorEnabled(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); bool value = false; std::string error;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic" || joint->type == "wheel", 1,
		"RevoluteJoint, PrismaticJoint, or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->isRevoluteJointMotorEnabled(joint->handle, value, error)
		: joint->type == "prismatic"
			? joint->runtime->_physicsBackend->isPrismaticJointMotorEnabled(joint->handle, value, error)
			: joint->runtime->_physicsBackend->isWheelJointMotorEnabled(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsRevoluteJointSetMaxMotorTorque(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2,
		"maximum motor torque must be finite and non-negative");
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "wheel", 1,
		"RevoluteJoint or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->setRevoluteJointMaxMotorTorque(joint->handle, value, error)
		: joint->runtime->_physicsBackend->setWheelJointMaxMotorTorque(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsRevoluteJointGetMaxMotorTorque(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "wheel", 1,
		"RevoluteJoint or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointMaxMotorTorque(joint->handle, value, error)
		: joint->runtime->_physicsBackend->getWheelJointMaxMotorTorque(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsRevoluteJointSetMotorSpeed(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "motor speed must be finite");
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic" || joint->type == "wheel", 1,
		"RevoluteJoint, PrismaticJoint, or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->setRevoluteJointMotorSpeed(joint->handle, value, error)
		: joint->type == "prismatic"
			? joint->runtime->_physicsBackend->setPrismaticJointMotorSpeed(joint->handle, value, error)
			: joint->runtime->_physicsBackend->setWheelJointMotorSpeed(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsRevoluteJointGetMotorSpeed(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic" || joint->type == "wheel", 1,
		"RevoluteJoint, PrismaticJoint, or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointMotorSpeed(joint->handle, value, error)
		: joint->type == "prismatic"
			? joint->runtime->_physicsBackend->getPrismaticJointMotorSpeed(joint->handle, value, error)
			: joint->runtime->_physicsBackend->getWheelJointMotorSpeed(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsRevoluteJointGetMotorTorque(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	const float inverseDeltaTime = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(inverseDeltaTime) && inverseDeltaTime >= 0.0f, 2,
		"inverse delta time must be finite and non-negative");
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "wheel", 1,
		"RevoluteJoint or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointMotorTorque(
			joint->handle, inverseDeltaTime, value, error)
		: joint->runtime->_physicsBackend->getWheelJointMotorTorque(
			joint->handle, inverseDeltaTime, value, error);
	if (!success) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsRevoluteJointSetLimitsEnabled(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_checktype(state, 2, LUA_TBOOLEAN);
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic", 1,
		"RevoluteJoint or PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->setRevoluteJointLimitsEnabled(
			joint->handle, lua_toboolean(state, 2), error)
		: joint->runtime->_physicsBackend->setPrismaticJointLimitsEnabled(
			joint->handle, lua_toboolean(state, 2), error);
	if (!success) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsRevoluteJointAreLimitsEnabled(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); bool value = false; std::string error;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic", 1,
		"RevoluteJoint or PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->areRevoluteJointLimitsEnabled(joint->handle, value, error)
		: joint->runtime->_physicsBackend->arePrismaticJointLimitsEnabled(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsRevoluteJointSetLimits(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float lower = static_cast<float>(luaL_checknumber(state, 2));
	const float upper = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(lower) && std::isfinite(upper) && lower <= upper, 2,
		"limits must be finite and lower must not exceed upper");
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic", 1,
		"RevoluteJoint or PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->setRevoluteJointLimits(joint->handle, lower, upper, error)
		: joint->runtime->_physicsBackend->setPrismaticJointLimits(joint->handle, lower, upper, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsRevoluteJointSetUpperLimit(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float lower = 0.0f, upper = 0.0f;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "upper limit must be finite");
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic", 1,
		"RevoluteJoint or PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool gotLimits = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointLimits(joint->handle, lower, upper, error)
		: joint->runtime->_physicsBackend->getPrismaticJointLimits(joint->handle, lower, upper, error);
	if (!gotLimits)
		return luaL_error(state, "%s", error.c_str());
	luaL_argcheck(state, lower <= value, 2, "upper limit must not be below lower limit");
	const bool setLimits = joint->type == "revolute"
		? joint->runtime->_physicsBackend->setRevoluteJointLimits(joint->handle, lower, value, error)
		: joint->runtime->_physicsBackend->setPrismaticJointLimits(joint->handle, lower, value, error);
	if (!setLimits)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsRevoluteJointSetLowerLimit(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float lower = 0.0f, upper = 0.0f;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "lower limit must be finite");
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic", 1,
		"RevoluteJoint or PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool gotLimits = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointLimits(joint->handle, lower, upper, error)
		: joint->runtime->_physicsBackend->getPrismaticJointLimits(joint->handle, lower, upper, error);
	if (!gotLimits)
		return luaL_error(state, "%s", error.c_str());
	luaL_argcheck(state, value <= upper, 2, "lower limit must not exceed upper limit");
	const bool setLimits = joint->type == "revolute"
		? joint->runtime->_physicsBackend->setRevoluteJointLimits(joint->handle, value, upper, error)
		: joint->runtime->_physicsBackend->setPrismaticJointLimits(joint->handle, value, upper, error);
	if (!setLimits)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsRevoluteJointGetUpperLimit(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float lower = 0.0f, upper = 0.0f;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic", 1,
		"RevoluteJoint or PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointLimits(joint->handle, lower, upper, error)
		: joint->runtime->_physicsBackend->getPrismaticJointLimits(joint->handle, lower, upper, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, upper); return 1;
}

int LoveRuntime::physicsRevoluteJointGetLowerLimit(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float lower = 0.0f, upper = 0.0f;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic", 1,
		"RevoluteJoint or PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointLimits(joint->handle, lower, upper, error)
		: joint->runtime->_physicsBackend->getPrismaticJointLimits(joint->handle, lower, upper, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, lower); return 1;
}

int LoveRuntime::physicsRevoluteJointGetLimits(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error; float lower = 0.0f, upper = 0.0f;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic", 1,
		"RevoluteJoint or PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointLimits(joint->handle, lower, upper, error)
		: joint->runtime->_physicsBackend->getPrismaticJointLimits(joint->handle, lower, upper, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, lower); lua_pushnumber(state, upper); return 2;
}

int LoveRuntime::physicsRevoluteJointGetReferenceAngle(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "revolute" || joint->type == "prismatic"
		|| joint->type == "weld", 1, "RevoluteJoint, PrismaticJoint, or WeldJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "revolute"
		? joint->runtime->_physicsBackend->getRevoluteJointReferenceAngle(joint->handle, value, error)
		: joint->type == "prismatic"
			? joint->runtime->_physicsBackend->getPrismaticJointReferenceAngle(joint->handle, value, error)
			: joint->runtime->_physicsBackend->getWeldJointReferenceAngle(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsPrismaticJointGetJointTranslation(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "prismatic" || joint->type == "wheel", 1,
		"PrismaticJoint or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "prismatic"
		? joint->runtime->_physicsBackend->getPrismaticJointTranslation(joint->handle, value, error)
		: joint->runtime->_physicsBackend->getWheelJointTranslation(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsPrismaticJointSetMaxMotorForce(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2,
		"maximum motor force must be finite and non-negative");
	luaL_argcheck(state, joint->type == "prismatic", 1, "PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setPrismaticJointMaxMotorForce(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsPrismaticJointGetMaxMotorForce(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "prismatic", 1, "PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getPrismaticJointMaxMotorForce(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsPrismaticJointGetMotorForce(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	const float inverseDeltaTime = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(inverseDeltaTime) && inverseDeltaTime >= 0.0f, 2,
		"inverse delta time must be finite and non-negative");
	luaL_argcheck(state, joint->type == "prismatic", 1, "PrismaticJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getPrismaticJointMotorForce(
		joint->handle, inverseDeltaTime, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsPrismaticJointGetAxis(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "prismatic" || joint->type == "wheel", 1,
		"PrismaticJoint or WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "prismatic"
		? joint->runtime->_physicsBackend->getPrismaticJointAxis(joint->handle, x, y, error)
		: joint->runtime->_physicsBackend->getWheelJointAxis(joint->handle, x, y, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsFrictionJointSetMaxForce(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2,
		"maximum force must be finite and non-negative");
	luaL_argcheck(state, joint->type == "friction" || joint->type == "mouse"
		|| joint->type == "motor", 1, "FrictionJoint, MouseJoint or MotorJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "friction"
		? joint->runtime->_physicsBackend->setFrictionJointMaxForce(joint->handle, value, error)
		: joint->type == "mouse"
			? joint->runtime->_physicsBackend->setMouseJointMaxForce(joint->handle, value, error)
			: joint->runtime->_physicsBackend->setMotorJointMaxForce(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsFrictionJointGetMaxForce(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "friction" || joint->type == "mouse"
		|| joint->type == "motor", 1, "FrictionJoint, MouseJoint or MotorJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "friction"
		? joint->runtime->_physicsBackend->getFrictionJointMaxForce(joint->handle, value, error)
		: joint->type == "mouse"
			? joint->runtime->_physicsBackend->getMouseJointMaxForce(joint->handle, value, error)
			: joint->runtime->_physicsBackend->getMotorJointMaxForce(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsFrictionJointSetMaxTorque(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2,
		"maximum torque must be finite and non-negative");
	luaL_argcheck(state, joint->type == "friction" || joint->type == "motor", 1,
		"FrictionJoint or MotorJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "friction"
		? joint->runtime->_physicsBackend->setFrictionJointMaxTorque(joint->handle, value, error)
		: joint->runtime->_physicsBackend->setMotorJointMaxTorque(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsFrictionJointGetMaxTorque(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "friction" || joint->type == "motor", 1,
		"FrictionJoint or MotorJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "friction"
		? joint->runtime->_physicsBackend->getFrictionJointMaxTorque(joint->handle, value, error)
		: joint->runtime->_physicsBackend->getMotorJointMaxTorque(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsRopeJointGetMaxLength(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0.0f; std::string error;
	luaL_argcheck(state, joint->type == "rope", 1, "RopeJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getRopeJointMaxLength(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsRopeJointSetMaxLength(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2,
		"maximum length must be finite and non-negative");
	luaL_argcheck(state, joint->type == "rope", 1, "RopeJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setRopeJointMaxLength(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsPulleyJointGetGroundAnchors(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float x1 = 0, y1 = 0, x2 = 0, y2 = 0;
	std::string error;
	luaL_argcheck(state, joint->type == "pulley", 1, "PulleyJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getPulleyJointGroundAnchors(
		joint->handle, x1, y1, x2, y2, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x1); lua_pushnumber(state, y1);
	lua_pushnumber(state, x2); lua_pushnumber(state, y2); return 4;
}

int LoveRuntime::physicsPulleyJointGetLengthA(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0; std::string error;
	luaL_argcheck(state, joint->type == "pulley", 1, "PulleyJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getPulleyJointLengthA(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsPulleyJointGetLengthB(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0; std::string error;
	luaL_argcheck(state, joint->type == "pulley", 1, "PulleyJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getPulleyJointLengthB(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsPulleyJointGetRatio(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0; std::string error;
	luaL_argcheck(state, joint->type == "pulley" || joint->type == "gear", 1,
		"PulleyJoint or GearJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	const bool success = joint->type == "gear"
		? joint->runtime->_physicsBackend->getGearJointRatio(joint->handle, value, error)
		: joint->runtime->_physicsBackend->getPulleyJointRatio(joint->handle, value, error);
	if (!success)
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsWheelJointSetSpringFrequency(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0, 2,
		"spring frequency must be finite and non-negative");
	luaL_argcheck(state, joint->type == "wheel", 1, "WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setWheelJointSpringFrequency(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str()); return 0;
}

int LoveRuntime::physicsWheelJointGetSpringFrequency(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0; std::string error;
	luaL_argcheck(state, joint->type == "wheel", 1, "WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getWheelJointSpringFrequency(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str()); lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsWheelJointSetSpringDampingRatio(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0, 2,
		"spring damping ratio must be finite and non-negative");
	luaL_argcheck(state, joint->type == "wheel", 1, "WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setWheelJointSpringDampingRatio(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str()); return 0;
}

int LoveRuntime::physicsWheelJointGetSpringDampingRatio(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0; std::string error;
	luaL_argcheck(state, joint->type == "wheel", 1, "WheelJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getWheelJointSpringDampingRatio(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str()); lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsMouseJointSetTarget(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_argcheck(state, joint->type == "mouse", 1, "MouseJoint expected");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2,
		"target coordinates must be finite");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setMouseJointTarget(joint->handle, x, y, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsMouseJointGetTarget(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float x = 0, y = 0; std::string error;
	luaL_argcheck(state, joint->type == "mouse", 1, "MouseJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getMouseJointTarget(joint->handle, x, y, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsMotorJointSetLinearOffset(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_argcheck(state, joint->type == "motor", 1, "MotorJoint expected");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2,
		"linear offset must be finite");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setMotorJointLinearOffset(joint->handle, x, y, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsMotorJointGetLinearOffset(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float x = 0, y = 0; std::string error;
	luaL_argcheck(state, joint->type == "motor", 1, "MotorJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getMotorJointLinearOffset(joint->handle, x, y, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsMotorJointSetAngularOffset(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_argcheck(state, joint->type == "motor", 1, "MotorJoint expected");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "angular offset must be finite");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setMotorJointAngularOffset(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsMotorJointGetAngularOffset(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0; std::string error;
	luaL_argcheck(state, joint->type == "motor", 1, "MotorJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getMotorJointAngularOffset(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsMotorJointSetCorrectionFactor(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_argcheck(state, joint->type == "motor", 1, "MotorJoint expected");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f && value <= 1.0f, 2,
		"correction factor must be finite and between 0 and 1");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setMotorJointCorrectionFactor(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsMotorJointGetCorrectionFactor(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); float value = 0; std::string error;
	luaL_argcheck(state, joint->type == "motor", 1, "MotorJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->getMotorJointCorrectionFactor(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsGearJointSetRatio(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1); std::string error;
	luaL_argcheck(state, joint->type == "gear", 1, "GearJoint expected");
	const float value = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(value), 2, "ratio must be finite");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	if (!joint->runtime->_physicsBackend->setGearJointRatio(joint->handle, value, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsGearJointGetJoints(lua_State *state)
{
	auto *joint = checkPhysicsJoint(state, 1);
	luaL_argcheck(state, joint->type == "gear", 1, "GearJoint expected");
	luaL_argcheck(state, joint->runtime && joint->runtime->_physicsBackend && joint->handle
		&& joint->runtime->_physicsBackend->isJointValid(joint->handle), 1, "Joint is destroyed");
	::love::luax_pushtype(state, PhysicsJointLoveType, joint->jointAObject.get());
	::love::luax_pushtype(state, PhysicsJointLoveType, joint->jointBObject.get());
	return 2;
}

int LoveRuntime::physicsContactIsValid(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1);
	lua_pushboolean(state, contact->runtime && contact->runtime->_physicsBackend && contact->handle
		&& contact->runtime->_physicsBackend->isContactValid(contact->handle));
	return 1;
}

int LoveRuntime::physicsContactGetFixtures(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1);
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->isContactValid(contact->handle))
		return luaL_error(state, "Contact is invalid");
	const auto fixtureA = contact->runtime->_physicsFixtureReferences.find(contact->fixtureA);
	const auto fixtureB = contact->runtime->_physicsFixtureReferences.find(contact->fixtureB);
	if (fixtureA == contact->runtime->_physicsFixtureReferences.end()
		|| fixtureB == contact->runtime->_physicsFixtureReferences.end())
		return luaL_error(state, "Contact references a closed Fixture");
	::love::luax_pushtype(state, PhysicsFixtureLoveType,
		static_cast<PhysicsFixtureUserdata *>(contact->fixtureAObject.get()));
	::love::luax_pushtype(state, PhysicsFixtureLoveType,
		static_cast<PhysicsFixtureUserdata *>(contact->fixtureBObject.get()));
	return 2;
}

int LoveRuntime::physicsContactGetChildren(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1);
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->isContactValid(contact->handle))
		return luaL_error(state, "Contact is invalid");
	// Love exposes Box2D's zero-based child indices as one-based Lua indices.
	lua_pushinteger(state, contact->childA + 1);
	lua_pushinteger(state, contact->childB + 1);
	return 2;
}

int LoveRuntime::physicsContactGetPositions(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); std::vector<float> positions; std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->getContactPositions(contact->handle, positions, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	for (const float value : positions) lua_pushnumber(state, value);
	return static_cast<int>(positions.size());
}

int LoveRuntime::physicsContactGetNormal(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->getContactNormal(contact->handle, x, y, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsContactGetFriction(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); float value = 0.0f; std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->getContactFriction(contact->handle, value, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsContactSetFriction(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1);
	const float value = static_cast<float>(luaL_checknumber(state, 2)); std::string error;
	luaL_argcheck(state, std::isfinite(value) && value >= 0.0f, 2,
		"friction must be finite and non-negative");
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->setContactFriction(contact->handle, value, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	return 0;
}

int LoveRuntime::physicsContactResetFriction(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->resetContactFriction(contact->handle, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	return 0;
}

int LoveRuntime::physicsContactGetRestitution(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); float value = 0.0f; std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->getContactRestitution(contact->handle, value, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsContactSetRestitution(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1);
	const float value = static_cast<float>(luaL_checknumber(state, 2)); std::string error;
	luaL_argcheck(state, std::isfinite(value), 2, "restitution must be finite");
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->setContactRestitution(contact->handle, value, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	return 0;
}

int LoveRuntime::physicsContactResetRestitution(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->resetContactRestitution(contact->handle, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	return 0;
}

int LoveRuntime::physicsContactIsEnabled(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); bool value = false; std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->isContactEnabled(contact->handle, value, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsContactSetEnabled(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->setContactEnabled(contact->handle,
			lua_toboolean(state, 2), error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	return 0;
}

int LoveRuntime::physicsContactIsTouching(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); bool value = false; std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->isContactTouching(contact->handle, value, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsContactGetTangentSpeed(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1); float value = 0.0f; std::string error;
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->getContactTangentSpeed(contact->handle, value, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	lua_pushnumber(state, value); return 1;
}

int LoveRuntime::physicsContactSetTangentSpeed(lua_State *state)
{
	auto *contact = checkPhysicsContact(state, 1);
	const float value = static_cast<float>(luaL_checknumber(state, 2)); std::string error;
	luaL_argcheck(state, std::isfinite(value), 2, "tangent speed must be finite");
	if (!contact->runtime || !contact->runtime->_physicsBackend || !contact->handle
		|| !contact->runtime->_physicsBackend->setContactTangentSpeed(contact->handle, value, error))
		return luaL_error(state, "%s", error.empty() ? "Contact is invalid" : error.c_str());
	return 0;
}

int LoveRuntime::timerStep(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime->_timerDelta);
	return 1;
}

int LoveRuntime::timerGetDelta(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime->_timerDelta);
	return 1;
}

int LoveRuntime::timerGetFPS(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushinteger(state, runtime->_timerFPS);
	return 1;
}

int LoveRuntime::timerGetAverageDelta(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime->_timerAverageDelta);
	return 1;
}

int LoveRuntime::timerSleep(lua_State *state)
{
	const double seconds = luaL_checknumber(state, 1);
	if (!std::isfinite(seconds))
		return luaL_argerror(state, 1, "sleep duration must be finite");
	if (seconds > 0.0)
		std::this_thread::sleep_for(std::chrono::duration<double>(seconds));
	return 0;
}

int LoveRuntime::timerGetTime(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, steadySeconds() - runtime->_timerOrigin);
	return 1;
}

int LoveRuntime::audioNewSource(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (auto *soundData = testSoundData(state, 1))
	{
		if (runtime == nullptr || runtime->_audioBackend == nullptr)
			return luaL_error(state, "Love audio is not attached to Dora SoLoud");
		std::string error;
		const auto handle = runtime->_audioBackend->newSourceFromSoundData(
			{reinterpret_cast<const char *>(soundData->samples.data()), soundData->samples.size()},
			soundData->sampleRate, soundData->bitDepth, soundData->channels, error);
		if (handle == 0)
			return luaL_error(state, "Love audio Source from SoundData creation failed: %s",
				error.empty() ? "failed to create Dora SoLoud source" : error.c_str());
		pushAudioSource(state, runtime, handle, false);
		return 1;
	}
	const std::string filename = luaL_checkstring(state, 1);
	const std::string_view sourceType = luaL_optstring(state, 2, "static");
	if (sourceType != "static" && sourceType != "stream")
		return luaL_argerror(state, 2, "expected 'static' or 'stream'");
	if (runtime == nullptr || runtime->_audioBackend == nullptr)
		return luaL_error(state, "Love audio is not attached to Dora SoLoud");
	std::string resolvedPath;
	std::string error;
	if (!runtime->resolveReadPath(filename, resolvedPath, error))
		return luaL_error(state, "Love audio Source '%s' (%s) resolution failed: %s",
			filename.c_str(), std::string(sourceType).c_str(), error.c_str());
	const auto handle = runtime->_audioBackend->newSource(resolvedPath, sourceType, error);
	if (handle == 0)
		return luaL_error(state, "Love audio Source '%s' (%s) creation failed: %s",
			filename.c_str(), std::string(sourceType).c_str(),
			error.empty() ? "failed to create Dora SoLoud source" : error.c_str());
	pushAudioSource(state, runtime, handle, sourceType == "stream");
	return 1;
}

int LoveRuntime::audioNewQueueableSource(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const lua_Integer sampleRate = luaL_checkinteger(state, 1);
	const lua_Integer bitDepth = luaL_checkinteger(state, 2);
	const lua_Integer channels = luaL_checkinteger(state, 3);
	const lua_Integer buffers = luaL_optinteger(state, 4, 0);
	luaL_argcheck(state, sampleRate > 0 && sampleRate <= std::numeric_limits<int>::max(), 1,
		"sample rate must be a positive integer");
	luaL_argcheck(state, bitDepth == 8 || bitDepth == 16, 2,
		"bit depth must be 8 or 16");
	luaL_argcheck(state, channels == 1 || channels == 2, 3,
		"channel count must be 1 or 2");
	luaL_argcheck(state, buffers >= std::numeric_limits<int>::min()
		&& buffers <= std::numeric_limits<int>::max(), 4, "buffer count is out of range");
	if (runtime == nullptr || runtime->_audioBackend == nullptr)
		return luaL_error(state, "Love audio is not attached to Dora SoLoud");
	std::string error;
	const auto handle = runtime->_audioBackend->newQueueableSource(
		static_cast<int>(sampleRate), static_cast<int>(bitDepth),
		static_cast<int>(channels), static_cast<int>(buffers), error);
	if (handle == 0)
		return luaL_error(state, "Love queueable Source creation failed: %s",
			error.empty() ? "failed to create Dora SoLoud PCM queue" : error.c_str());
	pushAudioSource(state, runtime, handle, false, true);
	return 1;
}

int LoveRuntime::audioPlay(lua_State *state)
{
	const int count = lua_gettop(state);
	luaL_argcheck(state, count > 0, 1, "expected at least one Source");
	bool played = true;
	const bool tableInput = lua_istable(state, 1);
	const int sourceCount = tableInput ? static_cast<int>(lua_rawlen(state, 1)) : count;
	for (int index = 1; index <= sourceCount; ++index)
	{
		if (tableInput) lua_rawgeti(state, 1, index);
		auto *source = checkAudioSource(state, tableInput ? -1 : index);
		luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
			&& source->runtime->_audioHandles.contains(source->handle),
			tableInput ? 1 : index, "closed Source");
		played = source->runtime->_audioBackend->playSource(source->handle) && played;
		if (tableInput) lua_pop(state, 1);
	}
	lua_pushboolean(state, played);
	return 1;
}

int LoveRuntime::audioPause(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int count = lua_gettop(state);
	if (count == 0)
	{
		lua_createtable(state, runtime ? static_cast<int>(runtime->_audioHandles.size()) : 0, 0);
		int pausedCount = 0;
		if (runtime && runtime->_audioBackend)
		{
			for (const auto handle : runtime->_audioHandles)
			{
				if (!runtime->_audioBackend->isSourcePlaying(handle)) continue;
				runtime->_audioBackend->pauseSource(handle, true);
				if (pushAudioSourceByHandle(state, handle))
					lua_rawseti(state, -2, ++pausedCount);
			}
		}
		return 1;
	}
	const bool tableInput = lua_istable(state, 1);
	const int sourceCount = tableInput ? static_cast<int>(lua_rawlen(state, 1)) : count;
	for (int index = 1; index <= sourceCount; ++index)
	{
		if (tableInput) lua_rawgeti(state, 1, index);
		auto *source = checkAudioSource(state, tableInput ? -1 : index);
		luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
			&& source->runtime->_audioHandles.contains(source->handle),
			tableInput ? 1 : index, "closed Source");
		source->runtime->_audioBackend->pauseSource(source->handle, true);
		if (tableInput) lua_pop(state, 1);
	}
	return 0;
}

int LoveRuntime::audioStop(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int count = lua_gettop(state);
	if (count == 0)
	{
		if (runtime && runtime->_audioBackend)
			for (const auto handle : runtime->_audioHandles)
				runtime->_audioBackend->stopSource(handle);
		return 0;
	}
	const bool tableInput = lua_istable(state, 1);
	const int sourceCount = tableInput ? static_cast<int>(lua_rawlen(state, 1)) : count;
	for (int index = 1; index <= sourceCount; ++index)
	{
		if (tableInput) lua_rawgeti(state, 1, index);
		auto *source = checkAudioSource(state, tableInput ? -1 : index);
		luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
			&& source->runtime->_audioHandles.contains(source->handle),
			tableInput ? 1 : index, "closed Source");
		source->runtime->_audioBackend->stopSource(source->handle);
		if (tableInput) lua_pop(state, 1);
	}
	return 0;
}

int LoveRuntime::audioSetVolume(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float volume = static_cast<float>(luaL_checknumber(state, 1));
	luaL_argcheck(state, std::isfinite(volume) && volume >= 0.0f && volume <= 1.0f, 1,
		"volume must be between 0 and 1");
	runtime->_audioVolume = volume;
	if (runtime->_audioBackend)
		runtime->_audioBackend->setInstanceVolume(volume);
	return 0;
}

int LoveRuntime::audioGetActiveSourceCount(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_Integer count = 0;
	if (runtime && runtime->_audioBackend)
	{
		for (const auto handle : runtime->_audioHandles)
		{
			if (runtime->_audioBackend->isSourcePlaying(handle)
				|| runtime->_audioBackend->isSourcePaused(handle))
				++count;
		}
	}
	lua_pushinteger(state, count);
	return 1;
}

int LoveRuntime::audioGetVolume(lua_State *state)
{
	lua_pushnumber(state, runtimeFromUpvalue(state)->_audioVolume);
	return 1;
}

int LoveRuntime::audioSetMixWithSystem(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	lua_pushboolean(state, runtime && runtime->_audioBackend
		&& runtime->_audioBackend->setMixWithSystem(lua_toboolean(state, 1) != 0));
	return 1;
}

int LoveRuntime::audioSetPosition(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	const float z = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	luaL_argcheck(state, std::isfinite(x), 1, "listener x must be finite");
	luaL_argcheck(state, std::isfinite(y), 2, "listener y must be finite");
	luaL_argcheck(state, std::isfinite(z), 3, "listener z must be finite");
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->setListenerPosition(x, y, z);
	return 0;
}

int LoveRuntime::audioGetPosition(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float x = 0.0f, y = 0.0f, z = 0.0f;
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->getListenerPosition(x, y, z);
	lua_pushnumber(state, x);
	lua_pushnumber(state, y);
	lua_pushnumber(state, z);
	return 3;
}

int LoveRuntime::audioSetOrientation(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float values[6];
	for (int index = 0; index < 6; ++index)
	{
		values[index] = static_cast<float>(luaL_checknumber(state, index + 1));
		luaL_argcheck(state, std::isfinite(values[index]), index + 1,
			"listener orientation values must be finite");
	}
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->setListenerOrientation(values[0], values[1], values[2],
			values[3], values[4], values[5]);
	return 0;
}

int LoveRuntime::audioGetOrientation(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float forwardX = 0.0f, forwardY = 0.0f, forwardZ = 1.0f;
	float upX = 0.0f, upY = 1.0f, upZ = 0.0f;
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->getListenerOrientation(forwardX, forwardY, forwardZ,
			upX, upY, upZ);
	lua_pushnumber(state, forwardX);
	lua_pushnumber(state, forwardY);
	lua_pushnumber(state, forwardZ);
	lua_pushnumber(state, upX);
	lua_pushnumber(state, upY);
	lua_pushnumber(state, upZ);
	return 6;
}

int LoveRuntime::audioSetVelocity(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	const float z = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	luaL_argcheck(state, std::isfinite(x), 1, "listener velocity x must be finite");
	luaL_argcheck(state, std::isfinite(y), 2, "listener velocity y must be finite");
	luaL_argcheck(state, std::isfinite(z), 3, "listener velocity z must be finite");
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->setListenerVelocity(x, y, z);
	return 0;
}

int LoveRuntime::audioGetVelocity(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float x = 0.0f, y = 0.0f, z = 0.0f;
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->getListenerVelocity(x, y, z);
	lua_pushnumber(state, x);
	lua_pushnumber(state, y);
	lua_pushnumber(state, z);
	return 3;
}

int LoveRuntime::audioSetDopplerScale(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float scale = static_cast<float>(luaL_checknumber(state, 1));
	// Love's OpenAL backend silently ignores values below zero. Keep that
	// observable behavior and also reject non-finite values at the backend edge.
	if (runtime && runtime->_audioBackend && std::isfinite(scale) && scale >= 0.0f)
		runtime->_audioBackend->setDopplerScale(scale);
	return 0;
}

int LoveRuntime::audioGetDopplerScale(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime && runtime->_audioBackend
		? runtime->_audioBackend->getDopplerScale() : 1.0f);
	return 1;
}

int LoveRuntime::audioSetDistanceModel(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view model = luaL_checkstring(state, 1);
	if (model != "none" && model != "inverse" && model != "inverseclamped"
		&& model != "linear" && model != "linearclamped"
		&& model != "exponent" && model != "exponentclamped")
	{
		return luaL_argerror(state, 1,
			"expected 'none', 'inverse', 'inverseclamped', 'linear', "
			"'linearclamped', 'exponent', or 'exponentclamped'");
	}
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->setDistanceModel(model);
	return 0;
}

int LoveRuntime::audioGetDistanceModel(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string model = runtime && runtime->_audioBackend
		? runtime->_audioBackend->getDistanceModel() : "inverseclamped";
	lua_pushlstring(state, model.data(), model.size());
	return 1;
}

namespace
{
enum class AudioParameterKind { Invalid, Number, Boolean, Waveform };

bool hasAudioParameter(std::string_view key, std::initializer_list<std::string_view> parameters)
{
	return std::find(parameters.begin(), parameters.end(), key) != parameters.end();
}

AudioParameterKind effectParameterKind(std::string_view type, std::string_view key)
{
	if (key == "volume") return AudioParameterKind::Number;
	if ((type == "reverb" && hasAudioParameter(key, {"gain", "highgain", "density", "diffusion",
		"decaytime", "decayhighratio", "earlygain", "earlydelay", "lategain", "latedelay",
		"roomrolloff", "airabsorption"}))
		|| ((type == "chorus" || type == "flanger") && hasAudioParameter(key,
			{"phase", "rate", "depth", "feedback", "delay"}))
		|| (type == "distortion" && hasAudioParameter(key,
			{"gain", "edge", "lowcut", "center", "bandwidth"}))
		|| (type == "echo" && hasAudioParameter(key,
			{"delay", "tapdelay", "damping", "feedback", "spread"}))
		|| (type == "ringmodulator" && hasAudioParameter(key, {"frequency", "highcut"}))
		|| (type == "equalizer" && hasAudioParameter(key,
			{"lowgain", "lowcut", "lowmidgain", "lowmidfrequency", "lowmidbandwidth",
				"highmidgain", "highmidfrequency", "highmidbandwidth", "highgain", "highcut"})))
		return AudioParameterKind::Number;
	if ((type == "reverb" && key == "highlimit") || (type == "compressor" && key == "enable"))
		return AudioParameterKind::Boolean;
	if ((type == "chorus" || type == "flanger" || type == "ringmodulator") && key == "waveform")
		return AudioParameterKind::Waveform;
	return AudioParameterKind::Invalid;
}

bool validEffectType(std::string_view type)
{
	return hasAudioParameter(type, {"reverb", "chorus", "distortion", "echo", "flanger",
		"ringmodulator", "compressor", "equalizer"});
}

AudioParameterKind filterParameterKind(std::string_view type, std::string_view key)
{
	if (key == "volume") return AudioParameterKind::Number;
	if ((type == "lowpass" && key == "highgain") || (type == "highpass" && key == "lowgain")
		|| (type == "bandpass" && (key == "lowgain" || key == "highgain")))
		return AudioParameterKind::Number;
	return AudioParameterKind::Invalid;
}

float waveformValue(lua_State *state, int index)
{
	const std::string_view waveform = luaL_checkstring(state, index);
	if (waveform == "sine") return 0.0f;
	if (waveform == "triangle") return 1.0f;
	if (waveform == "sawtooth") return 2.0f;
	if (waveform == "square") return 3.0f;
	luaL_error(state, "invalid audio effect waveform '%s'", std::string(waveform).c_str());
	return 0.0f;
}

const char *waveformName(float value)
{
	switch (static_cast<int>(value))
	{
		case 1: return "triangle";
		case 2: return "sawtooth";
		case 3: return "square";
		default: return "sine";
	}
}

template <class Settings, class ParameterKind>
Settings readAudioSettings(lua_State *state, int index, bool effect, ParameterKind parameterKind)
{
	index = lua_absindex(state, index);
	luaL_checktype(state, index, LUA_TTABLE);
	lua_getfield(state, index, "type");
	if (!lua_isstring(state, -1)) luaL_error(state, "%s type not specified", effect ? "Effect" : "Filter");
	Settings settings;
	settings.type = lua_tostring(state, -1);
	lua_pop(state, 1);
	if ((effect && !validEffectType(settings.type))
		|| (!effect && settings.type != "lowpass" && settings.type != "highpass" && settings.type != "bandpass"))
		luaL_error(state, "invalid %s type '%s'", effect ? "effect" : "filter", settings.type.c_str());
	lua_pushnil(state);
	while (lua_next(state, index) != 0)
	{
		if (!lua_isstring(state, -2)) luaL_error(state, "%s parameter names must be strings",
			effect ? "Effect" : "Filter");
		const std::string key = lua_tostring(state, -2);
		if (key != "type")
		{
			const AudioParameterKind kind = parameterKind(settings.type, key);
			if (kind == AudioParameterKind::Invalid)
				luaL_error(state, "invalid '%s' %s parameter: %s", settings.type.c_str(),
					effect ? "Effect" : "Filter", key.c_str());
			float value = 0.0f;
			if (kind == AudioParameterKind::Number)
			{
				value = static_cast<float>(luaL_checknumber(state, -1));
				if (!std::isfinite(value)) luaL_error(state, "%s parameter '%s' must be finite",
					effect ? "Effect" : "Filter", key.c_str());
			}
			else if (kind == AudioParameterKind::Boolean)
			{
				if (!lua_isboolean(state, -1)) luaL_error(state, "%s parameter '%s' must be boolean",
					effect ? "Effect" : "Filter", key.c_str());
				value = lua_toboolean(state, -1) ? 1.0f : 0.0f;
			}
			else value = waveformValue(state, -1);
			settings.parameters[key] = value;
		}
		lua_pop(state, 1);
	}
	return settings;
}

void pushAudioSettings(lua_State *state, int target,
	const std::string &type, const std::map<std::string, float> &parameters, bool effect)
{
	if (target > 0 && lua_istable(state, target)) lua_pushvalue(state, target);
	else lua_createtable(state, 0, static_cast<int>(parameters.size() + 1));
	lua_pushlstring(state, type.data(), type.size());
	lua_setfield(state, -2, "type");
	for (const auto &[key, value] : parameters)
	{
		const auto kind = effect ? effectParameterKind(type, key) : filterParameterKind(type, key);
		if (kind == AudioParameterKind::Boolean) lua_pushboolean(state, value > 0.5f);
		else if (kind == AudioParameterKind::Waveform) lua_pushstring(state, waveformName(value));
		else lua_pushnumber(state, value);
		lua_setfield(state, -2, key.c_str());
	}
}
}

int LoveRuntime::audioSetEffect(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string name = luaL_checkstring(state, 1);
	const bool remove = lua_isnoneornil(state, 2)
		|| (lua_isboolean(state, 2) && lua_toboolean(state, 2) == 0);
	std::string error;
	if (!runtime || !runtime->_audioBackend)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	if (remove)
	{
		const bool existed = runtime->_audioEffects.erase(name) != 0;
		for (auto &[_, effects] : runtime->_audioSourceEffects) effects.erase(name);
		if (!runtime->_audioBackend->setEffect(name, nullptr, error) && !error.empty())
			return luaL_error(state, "%s", error.c_str());
		lua_pushboolean(state, existed);
		return 1;
	}
	auto settings = readAudioSettings<AudioBackend::EffectSettings>(state, 2, true, effectParameterKind);
	if (!runtime->_audioBackend->setEffect(name, &settings, error))
	{
		if (!error.empty()) return luaL_error(state, "%s", error.c_str());
		lua_pushboolean(state, false);
		return 1;
	}
	runtime->_audioEffects[name] = std::move(settings);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::audioGetEffect(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string name = luaL_checkstring(state, 1);
	if (!runtime) return 0;
	const auto found = runtime->_audioEffects.find(name);
	if (found == runtime->_audioEffects.end()) return 0;
	pushAudioSettings(state, 2, found->second.type, found->second.parameters, true);
	return 1;
}

int LoveRuntime::audioGetActiveEffects(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_createtable(state, runtime ? static_cast<int>(runtime->_audioEffects.size()) : 0, 0);
	int index = 1;
	if (runtime) for (const auto &[name, _] : runtime->_audioEffects)
	{
		lua_pushlstring(state, name.data(), name.size());
		lua_rawseti(state, -2, index++);
	}
	return 1;
}

int LoveRuntime::audioGetMaxSceneEffects(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime && runtime->_audioBackend
		? runtime->_audioBackend->getMaxSceneEffects() : 0);
	return 1;
}

int LoveRuntime::audioGetMaxSourceEffects(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime && runtime->_audioBackend
		? runtime->_audioBackend->getMaxSourceEffects() : 0);
	return 1;
}

int LoveRuntime::audioGetRecordingDevices(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_newtable(state);
	if (!runtime || !runtime->_audioBackend) return 1;
	const auto names = runtime->_audioBackend->getRecordingDeviceNames();
	int index = 1;
	for (const auto &name : names)
	{
		pushRecordingDevice(state, runtime, name);
		lua_rawseti(state, -2, index++);
	}
	return 1;
}

int LoveRuntime::recordingDeviceEqual(lua_State *state)
{
	lua_pushboolean(state, checkRecordingDevice(state, 1) == checkRecordingDevice(state, 2));
	return 1;
}

int LoveRuntime::recordingDeviceStart(lua_State *state)
{
	auto *device = checkRecordingDevice(state, 1);
	auto *backend = device->runtime ? device->runtime->_audioBackend : nullptr;
	if (!backend)
	{
		lua_pushboolean(state, false);
		return 1;
	}

	int maxSamples = device->maxSamples;
	int sampleRate = device->sampleRate;
	int bitDepth = device->bitDepth;
	int channels = device->channels;
	if (lua_gettop(state) > 1)
	{
		const lua_Integer requestedSamples = luaL_checkinteger(state, 2);
		const lua_Integer requestedRate = luaL_optinteger(state, 3, 8000);
		const lua_Integer requestedDepth = luaL_optinteger(state, 4, 16);
		const lua_Integer requestedChannels = luaL_optinteger(state, 5, 1);
		luaL_argcheck(state, requestedSamples > 0 && requestedSamples <= std::numeric_limits<int>::max(),
			2, "number of samples must be a positive 32-bit integer");
		luaL_argcheck(state, requestedRate > 0 && requestedRate <= std::numeric_limits<int>::max(),
			3, "sample rate must be a positive 32-bit integer");
		luaL_argcheck(state, requestedDepth == 8 || requestedDepth == 16, 4,
			"bit depth must be 8 or 16");
		luaL_argcheck(state, requestedChannels == 1 || requestedChannels == 2, 5,
			"channel count must be 1 or 2");
		maxSamples = static_cast<int>(requestedSamples);
		sampleRate = static_cast<int>(requestedRate);
		bitDepth = static_cast<int>(requestedDepth);
		channels = static_cast<int>(requestedChannels);
		const std::size_t bytesPerFrame = static_cast<std::size_t>(bitDepth / 8 * channels);
		luaL_argcheck(state, static_cast<std::size_t>(maxSamples) <= MaximumSoundDataBytes / bytesPerFrame,
			2, "recording buffer cannot exceed 256 MiB");
	}

	if (device->handle != 0) device->releaseDoraHandle();
	std::string error;
	const auto handle = backend->startRecording(device->name, maxSamples,
		sampleRate, bitDepth, channels, error);
	if (!error.empty()) return luaL_error(state, "Love RecordingDevice start failed: %s", error.c_str());
	if (handle != 0)
	{
		device->replaceDoraHandle(handle);
		device->maxSamples = maxSamples;
		device->sampleRate = sampleRate;
		device->bitDepth = bitDepth;
		device->channels = channels;
	}
	lua_pushboolean(state, handle != 0);
	return 1;
}

int LoveRuntime::recordingDeviceGetData(lua_State *state)
{
	auto *device = checkRecordingDevice(state, 1);
	auto *backend = device->runtime ? device->runtime->_audioBackend : nullptr;
	if (!backend || device->handle == 0)
	{
		lua_pushnil(state);
		return 1;
	}
	std::vector<std::uint8_t> pcm;
	std::string error;
	if (!backend->getRecordingData(device->handle, pcm, error))
		return luaL_error(state, "Love RecordingDevice read failed: %s", error.c_str());
	if (pcm.empty())
	{
		lua_pushnil(state);
		return 1;
	}
	const std::size_t bytesPerFrame = static_cast<std::size_t>(device->bitDepth / 8 * device->channels);
	pushSoundData(state, device->sampleRate, device->bitDepth, device->channels,
		static_cast<int>(pcm.size() / bytesPerFrame), std::move(pcm));
	return 1;
}

int LoveRuntime::recordingDeviceStop(lua_State *state)
{
	auto *device = checkRecordingDevice(state, 1);
	recordingDeviceGetData(state);
	if (device->handle != 0 && device->runtime && device->runtime->_audioBackend)
		device->releaseDoraHandle();
	device->invalidateDoraHandle();
	return 1;
}

int LoveRuntime::recordingDeviceGetSampleCount(lua_State *state)
{
	auto *device = checkRecordingDevice(state, 1);
	const int count = device->handle != 0 && device->runtime && device->runtime->_audioBackend
		? device->runtime->_audioBackend->getRecordingSampleCount(device->handle) : 0;
	lua_pushinteger(state, count);
	return 1;
}

int LoveRuntime::recordingDeviceGetSampleRate(lua_State *state)
{
	lua_pushinteger(state, checkRecordingDevice(state, 1)->sampleRate);
	return 1;
}

int LoveRuntime::recordingDeviceGetBitDepth(lua_State *state)
{
	lua_pushinteger(state, checkRecordingDevice(state, 1)->bitDepth);
	return 1;
}

int LoveRuntime::recordingDeviceGetChannelCount(lua_State *state)
{
	lua_pushinteger(state, checkRecordingDevice(state, 1)->channels);
	return 1;
}

int LoveRuntime::recordingDeviceGetName(lua_State *state)
{
	const auto &name = checkRecordingDevice(state, 1)->name;
	lua_pushlstring(state, name.data(), name.size());
	return 1;
}

int LoveRuntime::recordingDeviceIsRecording(lua_State *state)
{
	lua_pushboolean(state, checkRecordingDevice(state, 1)->handle != 0);
	return 1;
}

int LoveRuntime::audioIsEffectsSupported(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime && runtime->_audioBackend
		&& runtime->_audioBackend->isEffectsSupported());
	return 1;
}

int LoveRuntime::audioSourceEqual(lua_State *state)
{
	auto *left = testAudioSource(state, 1);
	auto *right = testAudioSource(state, 2);
	lua_pushboolean(state, left && right && left->runtime == right->runtime && left->handle == right->handle);
	return 1;
}

int LoveRuntime::audioSourceClone(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	std::string error;
	const auto handle = source->runtime->_audioBackend->cloneSource(source->handle, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "Could not clone Source." : error.c_str());
	if (const auto found = source->runtime->_audioSourceFilters.find(source->handle);
		found != source->runtime->_audioSourceFilters.end())
		source->runtime->_audioSourceFilters[handle] = found->second;
	if (const auto found = source->runtime->_audioSourceEffects.find(source->handle);
		found != source->runtime->_audioSourceEffects.end())
		source->runtime->_audioSourceEffects[handle] = found->second;
	pushAudioSource(state, source->runtime, handle, source->stream, source->queue);
	return 1;
}

int LoveRuntime::audioSourcePlay(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushboolean(state, source->runtime->_audioBackend->playSource(source->handle));
	return 1;
}

int LoveRuntime::audioSourcePause(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	source->runtime->_audioBackend->pauseSource(source->handle, true);
	return 0;
}

int LoveRuntime::audioSourceStop(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	source->runtime->_audioBackend->stopSource(source->handle);
	return 0;
}

int LoveRuntime::audioSourceIsPlaying(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushboolean(state, source->runtime->_audioBackend->isSourcePlaying(source->handle));
	return 1;
}

int LoveRuntime::audioSourceIsStopped(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushboolean(state, !source->runtime->_audioBackend->isSourcePlaying(source->handle)
		&& !source->runtime->_audioBackend->isSourcePaused(source->handle));
	return 1;
}

int LoveRuntime::audioSourceIsPaused(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushboolean(state, source->runtime->_audioBackend->isSourcePaused(source->handle));
	return 1;
}

int LoveRuntime::audioSourceSetLooping(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	if (source->queue)
		return luaL_error(state, "Queueable Sources can not be looped.");
	source->runtime->_audioBackend->setSourceLooping(source->handle, lua_toboolean(state, 2));
	return 0;
}

int LoveRuntime::audioSourceIsLooping(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushboolean(state, source->runtime->_audioBackend->isSourceLooping(source->handle));
	return 1;
}

int LoveRuntime::audioSourceSetVolume(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	const float volume = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(volume) && volume >= 0.0f && volume <= 1.0f, 2,
		"volume must be between 0 and 1");
	source->runtime->_audioBackend->setSourceVolume(source->handle, volume);
	return 0;
}

int LoveRuntime::audioSourceGetVolume(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushnumber(state, source->runtime->_audioBackend->getSourceVolume(source->handle));
	return 1;
}

int LoveRuntime::audioSourceSetPitch(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	const float pitch = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(pitch) && pitch > 0.0f, 2, "pitch must be positive and finite");
	source->runtime->_audioBackend->setSourcePitch(source->handle, pitch);
	return 0;
}

int LoveRuntime::audioSourceGetPitch(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushnumber(state, source->runtime->_audioBackend->getSourcePitch(source->handle));
	return 1;
}

int LoveRuntime::audioSourceSeek(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	const double offset = luaL_checknumber(state, 2);
	const std::string_view unit = luaL_optstring(state, 3, "seconds");
	luaL_argcheck(state, std::isfinite(offset) && offset >= 0.0, 2, "seek offset must be non-negative and finite");
	double seconds = offset;
	if (unit == "samples")
	{
		const double sampleRate = source->runtime->_audioBackend->getSourceSampleRate(source->handle);
		if (sampleRate <= 0.0) return luaL_error(state, "Source sample rate is unavailable.");
		seconds /= sampleRate;
	}
	else if (unit != "seconds")
		return luaL_argerror(state, 3, "time unit must be 'seconds' or 'samples'");
	source->runtime->_audioBackend->seekSource(source->handle, seconds);
	return 0;
}

int LoveRuntime::audioSourceTell(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	const std::string_view unit = luaL_optstring(state, 2, "seconds");
	double position = source->runtime->_audioBackend->tellSource(source->handle);
	if (unit == "samples")
		position *= source->runtime->_audioBackend->getSourceSampleRate(source->handle);
	else if (unit != "seconds")
		return luaL_argerror(state, 2, "time unit must be 'seconds' or 'samples'");
	lua_pushnumber(state, position);
	return 1;
}

int LoveRuntime::audioSourceGetDuration(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	const std::string_view unit = luaL_optstring(state, 2, "seconds");
	double duration = source->runtime->_audioBackend->getSourceDuration(source->handle);
	if (unit == "samples")
		duration = source->runtime->_audioBackend->getSourceSampleCount(source->handle);
	else if (unit != "seconds")
		return luaL_argerror(state, 2, "time unit must be 'seconds' or 'samples'");
	lua_pushnumber(state, duration);
	return 1;
}

int LoveRuntime::audioSourceGetChannelCount(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	const int channels = source->runtime->_audioBackend->getSourceChannelCount(source->handle);
	if (channels <= 0)
		return luaL_error(state, "Source channel count is unavailable.");
	lua_pushinteger(state, channels);
	return 1;
}

int LoveRuntime::audioSourceGetFreeBufferCount(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushinteger(state,
		source->runtime->_audioBackend->getSourceFreeBufferCount(source->handle));
	return 1;
}

int LoveRuntime::audioSourceQueue(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	if (!source->queue)
		return luaL_error(state, "Only queueable Sources can be queued with sound data.");
	auto *soundData = checkSoundData(state, 2);
	const auto dataSize = soundData->samples.size();
	size_t offset = 0;
	size_t length = dataSize;
	if (lua_gettop(state) >= 3)
	{
		const lua_Number first = luaL_checknumber(state, 3);
		luaL_argcheck(state, std::isfinite(first) && first >= 0.0
			&& first <= static_cast<lua_Number>(std::numeric_limits<size_t>::max()), 3,
			"Data region out of bounds");
		if (lua_gettop(state) == 3)
			length = static_cast<size_t>(first);
		else
		{
			offset = static_cast<size_t>(first);
			const lua_Number second = luaL_checknumber(state, 4);
			luaL_argcheck(state, std::isfinite(second) && second >= 0.0
				&& second <= static_cast<lua_Number>(std::numeric_limits<size_t>::max()), 4,
				"Data region out of bounds");
			length = static_cast<size_t>(second);
		}
	}
	luaL_argcheck(state, offset <= dataSize && length <= dataSize - offset,
		lua_gettop(state) >= 4 ? 4 : 3, "Data region out of bounds");
	std::string error;
	const char *queuedData = length == 0 ? ""
		: reinterpret_cast<const char *>(soundData->samples.data() + offset);
	const bool queued = source->runtime->_audioBackend->queueSource(source->handle,
		{queuedData, length},
		soundData->sampleRate, soundData->bitDepth, soundData->channels, error);
	if (!queued && !error.empty())
		return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, queued);
	return 1;
}

int LoveRuntime::audioSourceSetPosition(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float z = static_cast<float>(luaL_optnumber(state, 4, 0.0));
	luaL_argcheck(state, std::isfinite(x), 2, "source x must be finite");
	luaL_argcheck(state, std::isfinite(y), 3, "source y must be finite");
	luaL_argcheck(state, std::isfinite(z), 4, "source z must be finite");
	source->runtime->_audioBackend->setSourcePosition(source->handle, x, y, z);
	return 0;
}

int LoveRuntime::audioSourceGetPosition(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	float x = 0.0f, y = 0.0f, z = 0.0f;
	source->runtime->_audioBackend->getSourcePosition(source->handle, x, y, z);
	lua_pushnumber(state, x); lua_pushnumber(state, y); lua_pushnumber(state, z);
	return 3;
}

int LoveRuntime::audioSourceSetVelocity(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float z = static_cast<float>(luaL_optnumber(state, 4, 0.0));
	luaL_argcheck(state, std::isfinite(x), 2, "source velocity x must be finite");
	luaL_argcheck(state, std::isfinite(y), 3, "source velocity y must be finite");
	luaL_argcheck(state, std::isfinite(z), 4, "source velocity z must be finite");
	source->runtime->_audioBackend->setSourceVelocity(source->handle, x, y, z);
	return 0;
}

int LoveRuntime::audioSourceGetVelocity(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	float x = 0.0f, y = 0.0f, z = 0.0f;
	source->runtime->_audioBackend->getSourceVelocity(source->handle, x, y, z);
	lua_pushnumber(state, x); lua_pushnumber(state, y); lua_pushnumber(state, z);
	return 3;
}

int LoveRuntime::audioSourceSetDirection(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float z = static_cast<float>(luaL_optnumber(state, 4, 0.0));
	luaL_argcheck(state, std::isfinite(x), 2, "source direction x must be finite");
	luaL_argcheck(state, std::isfinite(y), 3, "source direction y must be finite");
	luaL_argcheck(state, std::isfinite(z), 4, "source direction z must be finite");
	source->runtime->_audioBackend->setSourceDirection(source->handle, x, y, z);
	return 0;
}

int LoveRuntime::audioSourceGetDirection(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	float x = 0.0f, y = 0.0f, z = 0.0f;
	source->runtime->_audioBackend->getSourceDirection(source->handle, x, y, z);
	lua_pushnumber(state, x); lua_pushnumber(state, y); lua_pushnumber(state, z);
	return 3;
}

int LoveRuntime::audioSourceSetCone(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	const double innerInput = luaL_checknumber(state, 2);
	const double outerInput = luaL_checknumber(state, 3);
	const float outerVolume = static_cast<float>(luaL_optnumber(state, 4, 0.0));
	const float outerHighGain = static_cast<float>(luaL_optnumber(state, 5, 1.0));
	luaL_argcheck(state, std::isfinite(innerInput) && innerInput >= 0.0
		&& innerInput <= 6.28318530717958647692, 2,
		"inner cone angle must be between 0 and 2*pi");
	luaL_argcheck(state, std::isfinite(outerInput) && outerInput >= 0.0
		&& outerInput <= 6.28318530717958647692, 3,
		"outer cone angle must be between 0 and 2*pi");
	luaL_argcheck(state, std::isfinite(outerVolume) && outerVolume >= 0.0f && outerVolume <= 1.0f,
		4, "outer cone volume must be between 0 and 1");
	luaL_argcheck(state, std::isfinite(outerHighGain) && outerHighGain >= 0.0f && outerHighGain <= 1.0f,
		5, "outer cone high-frequency gain must be between 0 and 1");
	// Love 11.5's OpenAL backend stores the angles as integral degrees.
	constexpr double RadToDeg = 57.2957795130823208768;
	constexpr double DegToRad = 0.0174532925199432957692;
	const float innerAngle = static_cast<float>(static_cast<int>(innerInput * RadToDeg) * DegToRad);
	const float outerAngle = static_cast<float>(static_cast<int>(outerInput * RadToDeg) * DegToRad);
	source->runtime->_audioBackend->setSourceCone(source->handle, innerAngle, outerAngle,
		outerVolume, outerHighGain);
	return 0;
}

int LoveRuntime::audioSourceGetCone(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	float innerAngle = 0.0f, outerAngle = 0.0f, outerVolume = 0.0f, outerHighGain = 1.0f;
	source->runtime->_audioBackend->getSourceCone(source->handle, innerAngle, outerAngle,
		outerVolume, outerHighGain);
	lua_pushnumber(state, innerAngle); lua_pushnumber(state, outerAngle);
	lua_pushnumber(state, outerVolume); lua_pushnumber(state, outerHighGain);
	return 4;
}

int LoveRuntime::audioSourceSetAirAbsorption(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	const float factor = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(factor) && factor >= 0.0f, 2,
		"air absorption factor must be finite and non-negative");
	source->runtime->_audioBackend->setSourceAirAbsorption(source->handle, factor);
	return 0;
}

int LoveRuntime::audioSourceGetAirAbsorption(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	lua_pushnumber(state, source->runtime->_audioBackend->getSourceAirAbsorption(source->handle));
	return 1;
}

int LoveRuntime::audioSourceSetVolumeLimits(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	const float minVolume = static_cast<float>(luaL_checknumber(state, 2));
	const float maxVolume = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(minVolume) && minVolume >= 0.0f && minVolume <= 1.0f,
		2, "minimum volume must be between 0 and 1");
	luaL_argcheck(state, std::isfinite(maxVolume) && maxVolume >= 0.0f && maxVolume <= 1.0f,
		3, "maximum volume must be between 0 and 1");
	source->runtime->_audioBackend->setSourceVolumeLimits(source->handle, minVolume, maxVolume);
	return 0;
}

int LoveRuntime::audioSourceGetVolumeLimits(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	float minVolume = 0.0f, maxVolume = 1.0f;
	source->runtime->_audioBackend->getSourceVolumeLimits(source->handle, minVolume, maxVolume);
	lua_pushnumber(state, minVolume); lua_pushnumber(state, maxVolume);
	return 2;
}

int LoveRuntime::audioSourceSetRelative(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	luaL_checktype(state, 2, LUA_TBOOLEAN);
	source->runtime->_audioBackend->setSourceRelative(source->handle, lua_toboolean(state, 2) != 0);
	return 0;
}

int LoveRuntime::audioSourceIsRelative(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	lua_pushboolean(state, source->runtime->_audioBackend->isSourceRelative(source->handle));
	return 1;
}

int LoveRuntime::audioSourceSetAttenuationDistances(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	const float referenceDistance = static_cast<float>(luaL_checknumber(state, 2));
	const float maxDistance = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(referenceDistance) && referenceDistance >= 0.0f,
		2, "reference distance must be finite and non-negative");
	luaL_argcheck(state, std::isfinite(maxDistance) && maxDistance >= 0.0f,
		3, "maximum distance must be finite and non-negative");
	source->runtime->_audioBackend->setSourceAttenuationDistances(source->handle,
		referenceDistance, maxDistance);
	return 0;
}

int LoveRuntime::audioSourceGetAttenuationDistances(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	float referenceDistance = 1.0f, maxDistance = 1000000.0f;
	source->runtime->_audioBackend->getSourceAttenuationDistances(source->handle,
		referenceDistance, maxDistance);
	lua_pushnumber(state, referenceDistance); lua_pushnumber(state, maxDistance);
	return 2;
}

int LoveRuntime::audioSourceSetRolloff(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	const float rolloff = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(rolloff) && rolloff >= 0.0f, 2,
		"rolloff must be finite and non-negative");
	source->runtime->_audioBackend->setSourceRolloff(source->handle, rolloff);
	return 0;
}

int LoveRuntime::audioSourceGetRolloff(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	luaL_argcheck(state, source->runtime->_audioBackend->getSourceChannelCount(source->handle) == 1,
		1, "spatial audio functionality is only available for mono Sources");
	lua_pushnumber(state, source->runtime->_audioBackend->getSourceRolloff(source->handle));
	return 1;
}

int LoveRuntime::audioSourceSetFilter(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	std::string error;
	if (lua_isnoneornil(state, 2))
	{
		if (!source->runtime->_audioBackend->setSourceFilter(source->handle, nullptr, error))
		{
			if (!error.empty()) return luaL_error(state, "%s", error.c_str());
			lua_pushboolean(state, false); return 1;
		}
		source->runtime->_audioSourceFilters.erase(source->handle);
		lua_pushboolean(state, true);
		return 1;
	}
	auto settings = readAudioSettings<AudioBackend::FilterSettings>(state, 2, false, filterParameterKind);
	if (!source->runtime->_audioBackend->setSourceFilter(source->handle, &settings, error))
	{
		if (!error.empty()) return luaL_error(state, "%s", error.c_str());
		lua_pushboolean(state, false); return 1;
	}
	source->runtime->_audioSourceFilters[source->handle] = std::move(settings);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::audioSourceGetFilter(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioHandles.contains(source->handle),
		1, "closed Source");
	const auto found = source->runtime->_audioSourceFilters.find(source->handle);
	if (found == source->runtime->_audioSourceFilters.end()) return 0;
	pushAudioSettings(state, 2, found->second.type, found->second.parameters, false);
	return 1;
}

int LoveRuntime::audioSourceSetEffect(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
		&& source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	const std::string name = luaL_checkstring(state, 2);
	const bool boolean = lua_isboolean(state, 3);
	const bool enabled = !boolean || lua_toboolean(state, 3) != 0;
	std::optional<AudioBackend::FilterSettings> filter;
	if (enabled && !boolean && !lua_isnoneornil(state, 3))
		filter = readAudioSettings<AudioBackend::FilterSettings>(state, 3, false, filterParameterKind);
	std::string error;
	if (!source->runtime->_audioBackend->setSourceEffect(source->handle, name,
		filter ? &*filter : nullptr, enabled, error))
	{
		if (!error.empty()) return luaL_error(state, "%s", error.c_str());
		lua_pushboolean(state, false); return 1;
	}
	auto &effects = source->runtime->_audioSourceEffects[source->handle];
	if (enabled) effects[name] = std::move(filter);
	else effects.erase(name);
	if (effects.empty()) source->runtime->_audioSourceEffects.erase(source->handle);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::audioSourceGetEffect(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioHandles.contains(source->handle),
		1, "closed Source");
	const std::string name = luaL_checkstring(state, 2);
	const auto sourceEffects = source->runtime->_audioSourceEffects.find(source->handle);
	if (sourceEffects == source->runtime->_audioSourceEffects.end())
	{
		lua_pushboolean(state, false); return 1;
	}
	const auto found = sourceEffects->second.find(name);
	if (found == sourceEffects->second.end())
	{
		lua_pushboolean(state, false); return 1;
	}
	lua_pushboolean(state, true);
	if (!found->second) return 1;
	pushAudioSettings(state, 3, found->second->type, found->second->parameters, false);
	return 2;
}

int LoveRuntime::audioSourceGetActiveEffects(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioHandles.contains(source->handle),
		1, "closed Source");
	const auto found = source->runtime->_audioSourceEffects.find(source->handle);
	lua_createtable(state, found == source->runtime->_audioSourceEffects.end()
		? 0 : static_cast<int>(found->second.size()), 0);
	if (found != source->runtime->_audioSourceEffects.end())
	{
		int index = 1;
		for (const auto &[name, _] : found->second)
		{
			lua_pushlstring(state, name.data(), name.size());
			lua_rawseti(state, -2, index++);
		}
	}
	return 1;
}

int LoveRuntime::audioSourceGetType(lua_State *state)
{
	auto *source = checkAudioSource(state, 1);
	luaL_argcheck(state, source->runtime && source->runtime->_audioHandles.contains(source->handle), 1, "closed Source");
	lua_pushstring(state, source->queue ? "queue" : (source->stream ? "stream" : "static"));
	return 1;
}

int LoveRuntime::eventPump(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime == nullptr)
		return luaL_error(state, "Love runtime is unavailable");
	runtime->drainThreadErrors();
	// Dora owns the platform event pump and forwards events to each LoveNode.
	return 0;
}

int LoveRuntime::eventPollIterator(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime == nullptr)
		return 0;
	return runtime->pollQueuedEvent(state);
}

int LoveRuntime::eventPoll(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime == nullptr)
		return luaL_error(state, "Love runtime is unavailable");
	runtime->drainThreadErrors();
	lua_pushlightuserdata(state, runtime);
	lua_pushcclosure(state, eventPollIterator, 1);
	return 1;
}

int LoveRuntime::eventWait(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime == nullptr)
		return luaL_error(state, "Love runtime is unavailable");
	runtime->drainThreadErrors();
	// Waiting for Dora-delivered input on the application thread would deadlock
	// the host pump. Return immediately when this instance queue is empty.
	return runtime->pollQueuedEvent(state);
}

int LoveRuntime::eventPush(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime == nullptr)
		return luaL_error(state, "Love runtime is unavailable");
	size_t nameSize = 0;
	const char *name = luaL_checklstring(state, 1, &nameSize);
	if (std::char_traits<char>::length(name) != nameSize)
		return luaL_argerror(state, 1, "event name cannot contain NUL bytes");

	const int top = lua_gettop(state);
	int argumentCount = 0;
	for (int index = 2; index <= top; ++index)
	{
		const int type = lua_type(state, index);
		if (type == LUA_TNIL)
			break;
		if (type != LUA_TBOOLEAN && type != LUA_TNUMBER && type != LUA_TSTRING
			&& type != LUA_TUSERDATA && type != LUA_TLIGHTUSERDATA)
			return luaL_argerror(state, index,
				"event arguments must be boolean, number, string, userdata, or nil");
		++argumentCount;
	}

	lua_createtable(state, argumentCount, 0);
	const int arguments = lua_gettop(state);
	for (int index = 0; index < argumentCount; ++index)
	{
		lua_pushvalue(state, index + 2);
		lua_rawseti(state, arguments, index + 1);
	}
	QueuedEvent event{QueuedEventType::Custom};
	event.first.assign(name, nameSize);
	event.presses = argumentCount;
	event.registryReference = luaL_ref(state, LUA_REGISTRYINDEX);
	runtime->_eventQueue.push_back(std::move(event));
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::eventClear(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime == nullptr)
		return luaL_error(state, "Love runtime is unavailable");
	runtime->clearQueuedEvents();
	return 0;
}

int LoveRuntime::eventQuit(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime == nullptr)
		return luaL_error(state, "Love runtime is unavailable");
	if (lua_type(state, 1) == LUA_TSTRING)
	{
		const std::string_view reason = lua_tostring(state, 1);
		if (reason != "restart")
			return luaL_argerror(state, 1, "expected 'restart'");
		QueuedEvent event{QueuedEventType::Quit};
		event.first = "restart";
		runtime->_eventQueue.push_back(std::move(event));
		lua_pushboolean(state, true);
		return 1;
	}
	QueuedEvent event{QueuedEventType::Quit};
	if (!lua_isnoneornil(state, 1))
	{
		event.button = static_cast<int>(luaL_checkinteger(state, 1));
		event.flag = true;
	}
	runtime->_eventQueue.push_back(std::move(event));
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::filesystemSetIdentity(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view identity = luaL_checkstring(state, 1);
	(void) lua_toboolean(state, 2); // appendToPath is accepted; save remains first in the embedded search order.
	std::string error;
	if (runtime == nullptr || !runtime->setIdentity(identity, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::filesystemGetIdentity(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushlstring(state, runtime->_identity.data(), runtime->_identity.size());
	return 1;
}

int LoveRuntime::filesystemGetSource(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushlstring(state, runtime->_sourceRoot.data(), runtime->_sourceRoot.size());
	return 1;
}

int LoveRuntime::filesystemGetSaveDirectory(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushlstring(state, runtime->_saveRoot.data(), runtime->_saveRoot.size());
	return 1;
}

int LoveRuntime::filesystemGetWorkingDirectory(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	// A LoveNode has no process-owned cwd. Its confined source root is the
	// equivalent working directory for all relative game paths.
	lua_pushlstring(state, runtime->_sourceRoot.data(), runtime->_sourceRoot.size());
	return 1;
}

int LoveRuntime::filesystemGetUserDirectory(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string directory = runtime->_saveBaseRoot.empty() ? std::string()
		: std::filesystem::path(runtime->_saveBaseRoot).parent_path().string();
	lua_pushlstring(state, directory.data(), directory.size());
	return 1;
}

int LoveRuntime::filesystemGetAppdataDirectory(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	// Dora's Love save base is the appdata boundary from which identities are
	// derived, regardless of the host platform's physical directory layout.
	lua_pushlstring(state, runtime->_saveBaseRoot.data(), runtime->_saveBaseRoot.size());
	return 1;
}

int LoveRuntime::filesystemGetSourceBaseDirectory(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string directory = runtime->_sourceRoot.empty() ? std::string()
		: std::filesystem::path(runtime->_sourceRoot).parent_path().string();
	lua_pushlstring(state, directory.data(), directory.size());
	return 1;
}

int LoveRuntime::filesystemGetExecutablePath(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime == nullptr || runtime->_filesystemBackend == nullptr)
		return luaL_error(state, "Love filesystem backend is not attached");
	const std::string path = runtime->_filesystemBackend->getExecutablePath();
	lua_pushlstring(state, path.data(), path.size());
	return 1;
}

int LoveRuntime::filesystemGetRealDirectory(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	if (!isSafeVirtualPath(filename))
		return pushFilesystemFailure(state,
			"Love filesystem path must be relative and confined: " + filename);
	auto exists = [&](const std::filesystem::path &candidate) {
		return runtime->_filesystemBackend && runtime->_filesystemBackend->exist(candidate.string());
	};
	std::filesystem::path candidate;
	std::string error;
	if (resolveEntryWithinRoot(runtime->_saveRoot, filename, candidate, true, error) && exists(candidate))
	{
		lua_pushlstring(state, runtime->_saveRoot.data(), runtime->_saveRoot.size());
		return 1;
	}
	for (const auto &mount : runtime->_mountedArchives)
	{
		const bool ancestor = !mount.mountpoint.empty() && filename.size() < mount.mountpoint.size()
			&& mount.mountpoint.starts_with(filename + "/");
		error.clear();
		if (ancestor || (resolveMountedEntry(mount.root, mount.mountpoint, filename,
			candidate, true, error) && exists(candidate)))
		{
			lua_pushlstring(state, mount.root.data(), mount.root.size());
			return 1;
		}
	}
	error.clear();
	if (resolveEntryWithinRoot(runtime->_sourceRoot, filename, candidate, true, error) && exists(candidate))
	{
		lua_pushlstring(state, runtime->_sourceRoot.data(), runtime->_sourceRoot.size());
		return 1;
	}
	return pushFilesystemFailure(state, "Love filesystem entry does not exist: " + filename);
}

int LoveRuntime::filesystemMount(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_filesystemBackend)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	std::string archiveName;
	std::string archiveData;
	const void *dataIdentity = nullptr;
	int mountpointIndex = 2;
	if (auto *fileData = testFileData(state, 1))
	{
		archiveName = fileData->filename;
		archiveData = fileData->data;
		dataIdentity = fileData;
	}
	else
	{
		archiveName = luaL_checkstring(state, 1);
		std::string resolved;
		std::string error;
		if (!runtime->resolveReadPath(archiveName, resolved, error)
			|| !runtime->_filesystemBackend->load(resolved, archiveData, error))
		{
			lua_pushboolean(state, false);
			return 1;
		}
	}
	const std::string mountpoint = luaL_checkstring(state, mountpointIndex);
	const bool append = lua_toboolean(state, mountpointIndex + 1);
	if (!isSafeVirtualPath(mountpoint, true) || archiveData.empty())
	{
		lua_pushboolean(state, false);
		return 1;
	}
	for (const auto &mount : runtime->_mountedArchives)
	{
		if ((dataIdentity && mount.dataIdentity == dataIdentity)
			|| (!dataIdentity && !mount.dataIdentity && mount.archiveName == archiveName))
		{
			lua_pushboolean(state, false);
			return 1;
		}
	}
	std::string root;
	std::string error;
	if (!runtime->_filesystemBackend->mountArchive(archiveName, archiveData, root, error))
	{
		lua_pushboolean(state, false);
		return 1;
	}
	MountedArchive mounted{archiveName, mountpoint, root, dataIdentity, LUA_NOREF};
	if (dataIdentity)
	{
		lua_pushvalue(state, 1);
		mounted.dataReference = luaL_ref(state, LUA_REGISTRYINDEX);
	}
	if (append)
		runtime->_mountedArchives.push_back(std::move(mounted));
	else
		runtime->_mountedArchives.insert(runtime->_mountedArchives.begin(), std::move(mounted));
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::filesystemUnmount(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const void *dataIdentity = testFileData(state, 1);
	std::string archiveName;
	if (!dataIdentity)
		archiveName = luaL_checkstring(state, 1);
	auto found = std::find_if(runtime->_mountedArchives.begin(), runtime->_mountedArchives.end(),
		[&](const MountedArchive &mount) {
			return dataIdentity ? mount.dataIdentity == dataIdentity
				: !mount.dataIdentity && mount.archiveName == archiveName;
		});
	if (found == runtime->_mountedArchives.end())
	{
		lua_pushboolean(state, false);
		return 1;
	}
	if (runtime->_filesystemBackend)
		runtime->_filesystemBackend->unmountArchive(found->root);
	if (found->dataReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX, found->dataReference);
	runtime->_mountedArchives.erase(found);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::filesystemIsFused(lua_State *state)
{
	lua_pushboolean(state, false);
	return 1;
}

int LoveRuntime::filesystemRead(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	bool returnData = false;
	int filenameIndex = 1;
	if (lua_type(state, 1) == LUA_TSTRING && lua_type(state, 2) == LUA_TSTRING)
	{
		const std::string_view container = lua_tostring(state, 1);
		if (container == "string" || container == "data")
		{
			returnData = container == "data";
			filenameIndex = 2;
		}
	}
	const std::string filename = luaL_checkstring(state, filenameIndex);
	std::string resolved;
	std::string error;
	if (!runtime->resolveReadPath(filename, resolved, error))
		return pushFilesystemFailure(state, error);
	std::string data;
	if (!runtime->_filesystemBackend || !runtime->_filesystemBackend->load(resolved, data, error))
		return pushFilesystemFailure(state, error.empty()
			? "failed to open Love filesystem file for reading: " + filename : error);
	const int sizeIndex = filenameIndex + 1;
	if (!lua_isnoneornil(state, sizeIndex))
	{
		const lua_Integer requested = luaL_checkinteger(state, sizeIndex);
		if (requested < 0)
			return luaL_argerror(state, sizeIndex, "read size cannot be negative");
		data.resize(std::min<std::size_t>(data.size(), static_cast<std::size_t>(requested)));
	}
	const std::size_t resultSize = data.size();
	if (returnData)
		pushFileData(state, filename, std::move(data));
	else
		lua_pushlstring(state, data.data(), data.size());
	lua_pushinteger(state, static_cast<lua_Integer>(resultSize));
	return 2;
}

int LoveRuntime::filesystemNewFile(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	if (!isSafeVirtualPath(filename))
		return luaL_argerror(state, 1, "File path must be relative and confined to the Love instance");
	const bool hasMode = !lua_isnoneornil(state, 2);
	FileMode mode = FileMode::Closed;
	if (hasMode)
	{
		const std::string_view modeName = luaL_checkstring(state, 2);
		if (!parseFileMode(modeName, mode) || mode == FileMode::Closed)
			return luaL_argerror(state, 2, "expected file mode 'r', 'w', or 'a'");
	}
	pushFile(state, runtime, filename);
	if (!hasMode)
		return 1;
	std::string error;
	if (!openFile(checkFile(state, -1), mode, error))
		return pushFilesystemFailure(state, error);
	return 1;
}

int LoveRuntime::filesystemNewFileData(lua_State *state)
{
	if (lua_gettop(state) == 1)
	{
		std::string filename;
		std::string data;
		if (lua_type(state, 1) == LUA_TSTRING)
		{
			auto *runtime = runtimeFromUpvalue(state);
			filename = lua_tostring(state, 1);
			std::string resolved;
			std::string error;
			if (!runtime->resolveReadPath(filename, resolved, error)
				|| !runtime->_filesystemBackend || !runtime->_filesystemBackend->load(resolved, data, error))
				return pushFilesystemFailure(state, error.empty() ? "failed to read FileData: " + filename : error);
		}
		else
		{
			auto *file = checkFile(state, 1);
			filename = file->filename;
			bool closeAfter = false;
			std::string error;
			if (file->mode == FileMode::Closed)
			{
				if (!openFile(file, FileMode::Read, error))
					return pushFilesystemFailure(state, error);
				closeAfter = true;
			}
			if (file->mode != FileMode::Read)
				return pushFilesystemFailure(state, "File must be open in read mode");
			data.assign(file->data.data() + file->position, file->data.size() - file->position);
			file->position = file->data.size();
			if (closeAfter) file->mode = FileMode::Closed;
		}
		pushFileData(state, std::move(filename), std::move(data));
		return 1;
	}
	std::size_t size = 0;
	const char *bytes = luaL_checklstring(state, 1, &size);
	const std::string filename = luaL_checkstring(state, 2);
	pushFileData(state, filename, std::string(bytes, size));
	return 1;
}

int LoveRuntime::fileOpen(lua_State *state)
{
	auto *file = checkFile(state, 1);
	FileMode mode;
	const std::string_view modeName = luaL_checkstring(state, 2);
	if (!parseFileMode(modeName, mode) || mode == FileMode::Closed)
		return luaL_argerror(state, 2, "expected file mode 'r', 'w', or 'a'");
	std::string error;
	if (!openFile(file, mode, error))
		return pushFilesystemFailure(state, error);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::fileClose(lua_State *state)
{
	auto *file = checkFile(state, 1);
	file->mode = FileMode::Closed;
	file->position = 0;
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::fileIsOpen(lua_State *state)
{
	lua_pushboolean(state, checkFile(state, 1)->mode != FileMode::Closed);
	return 1;
}

int LoveRuntime::fileGetSize(lua_State *state)
{
	auto *file = checkFile(state, 1);
	if (file->mode != FileMode::Closed)
	{
		lua_pushnumber(state, static_cast<lua_Number>(file->data.size()));
		return 1;
	}
	std::string resolved;
	std::string error;
	if (!file->runtime->resolveReadPath(file->filename, resolved, error))
		return pushFilesystemFailure(state, error);
	const auto size = file->runtime->getFilesystemBackend()->getFileSize(resolved);
	if (!size)
		return pushFilesystemFailure(state, "Could not determine file size");
	lua_pushnumber(state, static_cast<lua_Number>(*size));
	return 1;
}

int LoveRuntime::fileRead(lua_State *state)
{
	auto *file = checkFile(state, 1);
	bool closeAfter = false;
	std::string error;
	if (file->mode == FileMode::Closed)
	{
		if (!openFile(file, FileMode::Read, error))
			return pushFilesystemFailure(state, error);
		closeAfter = true;
	}
	if (file->mode != FileMode::Read)
		return pushFilesystemFailure(state, "File must be open in read mode");
	bool returnData = false;
	int sizeIndex = 2;
	if (lua_type(state, 2) == LUA_TSTRING)
	{
		const std::string_view container = lua_tostring(state, 2);
		if (container != "string" && container != "data")
			return luaL_argerror(state, 2, "expected 'string' or 'data'");
		returnData = container == "data";
		sizeIndex = 3;
	}
	std::size_t count = file->data.size() - file->position;
	if (!lua_isnoneornil(state, sizeIndex))
	{
		const lua_Integer requested = luaL_checkinteger(state, sizeIndex);
		if (requested < 0) return luaL_argerror(state, sizeIndex, "read size cannot be negative");
		count = std::min(count, static_cast<std::size_t>(requested));
	}
	std::string result(file->data.data() + file->position, count);
	file->position += count;
	if (returnData) pushFileData(state, file->filename, std::move(result));
	else lua_pushlstring(state, result.data(), result.size());
	lua_pushinteger(state, static_cast<lua_Integer>(count));
	if (closeAfter) file->mode = FileMode::Closed;
	return 2;
}

int LoveRuntime::fileWrite(lua_State *state)
{
	auto *file = checkFile(state, 1);
	if (file->mode != FileMode::Write && file->mode != FileMode::Append)
		return pushFilesystemFailure(state, "File must be open in write or append mode");
	const char *bytes = nullptr;
	std::size_t size = 0;
	if (auto *data = testFileData(state, 2))
	{
		bytes = data->data.data();
		size = data->data.size();
	}
	else
		bytes = luaL_checklstring(state, 2, &size);
	if (!lua_isnoneornil(state, 3))
	{
		const lua_Integer requested = luaL_checkinteger(state, 3);
		if (requested < 0 || static_cast<std::size_t>(requested) > size)
			return luaL_argerror(state, 3, "write size must be within the input data");
		size = static_cast<std::size_t>(requested);
	}
	if (file->mode == FileMode::Append) file->position = file->data.size();
	if (file->position > file->data.size()) file->data.resize(file->position, '\0');
	const std::size_t overwritten = std::min(size, file->data.size() - file->position);
	file->data.replace(file->position, overwritten, bytes, size);
	file->position += size;
	std::string error;
	if (!flushFile(file, error)) return pushFilesystemFailure(state, error);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::fileFlush(lua_State *state)
{
	std::string error;
	if (!flushFile(checkFile(state, 1), error)) return pushFilesystemFailure(state, error);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::fileIsEOF(lua_State *state)
{
	auto *file = checkFile(state, 1);
	lua_pushboolean(state, file->mode == FileMode::Read && file->position >= file->data.size());
	return 1;
}

int LoveRuntime::fileTell(lua_State *state)
{
	auto *file = checkFile(state, 1);
	if (file->mode == FileMode::Closed) return pushFilesystemFailure(state, "Invalid position");
	lua_pushnumber(state, static_cast<lua_Number>(file->position));
	return 1;
}

int LoveRuntime::fileSeek(lua_State *state)
{
	auto *file = checkFile(state, 1);
	const lua_Number requested = luaL_checknumber(state, 2);
	const bool valid = file->mode != FileMode::Closed && std::isfinite(requested)
		&& requested >= 0 && requested <= static_cast<lua_Number>(file->data.size());
	if (valid) file->position = static_cast<std::size_t>(requested);
	lua_pushboolean(state, valid);
	return 1;
}

int LoveRuntime::fileLinesIterator(lua_State *state)
{
	auto *file = checkFile(state, lua_upvalueindex(1));
	const bool closeAfter = lua_toboolean(state, lua_upvalueindex(2)) != 0;
	if (file->mode != FileMode::Read) return luaL_error(state, "File needs to stay in read mode");
	if (file->position >= file->data.size())
	{
		if (closeAfter) file->mode = FileMode::Closed;
		return 0;
	}
	std::size_t end = file->position;
	while (end < file->data.size() && file->data[end] != '\n' && file->data[end] != '\r') ++end;
	lua_pushlstring(state, file->data.data() + file->position, end - file->position);
	if (end < file->data.size())
	{
		const char first = file->data[end++];
		if (first == '\r' && end < file->data.size() && file->data[end] == '\n') ++end;
	}
	file->position = end;
	return 1;
}

int LoveRuntime::fileLines(lua_State *state)
{
	auto *file = checkFile(state, 1);
	bool closeAfter = false;
	std::string error;
	if (file->mode == FileMode::Closed)
	{
		if (!openFile(file, FileMode::Read, error)) return luaL_error(state, "%s", error.c_str());
		closeAfter = true;
	}
	if (file->mode != FileMode::Read) return luaL_error(state, "File needs to stay in read mode");
	lua_pushvalue(state, 1);
	lua_pushboolean(state, closeAfter);
	lua_pushcclosure(state, fileLinesIterator, 2);
	return 1;
}

int LoveRuntime::fileSetBuffer(lua_State *state)
{
	auto *file = checkFile(state, 1);
	const std::string mode = luaL_checkstring(state, 2);
	if (mode != "none" && mode != "line" && mode != "full")
		return luaL_argerror(state, 2, "expected buffer mode 'none', 'line', or 'full'");
	const lua_Integer size = luaL_optinteger(state, 3, 0);
	if (size < 0) return luaL_argerror(state, 3, "buffer size cannot be negative");
	file->bufferMode = mode;
	file->bufferSize = static_cast<std::size_t>(size);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::fileGetBuffer(lua_State *state)
{
	auto *file = checkFile(state, 1);
	lua_pushlstring(state, file->bufferMode.data(), file->bufferMode.size());
	lua_pushnumber(state, static_cast<lua_Number>(file->bufferSize));
	return 2;
}

int LoveRuntime::fileGetMode(lua_State *state)
{
	lua_pushstring(state, fileModeName(checkFile(state, 1)->mode));
	return 1;
}

int LoveRuntime::fileGetFilename(lua_State *state)
{
	auto *file = checkFile(state, 1);
	lua_pushlstring(state, file->filename.data(), file->filename.size());
	return 1;
}

int LoveRuntime::fileGetExtension(lua_State *state)
{
	const std::string extension = fileExtension(checkFile(state, 1)->filename);
	lua_pushlstring(state, extension.data(), extension.size());
	return 1;
}

int LoveRuntime::fileDataClone(lua_State *state)
{
	auto *data = checkFileData(state, 1);
	pushFileData(state, data->filename, data->data);
	return 1;
}

int LoveRuntime::fileDataGetFilename(lua_State *state)
{
	auto *data = checkFileData(state, 1);
	lua_pushlstring(state, data->filename.data(), data->filename.size());
	return 1;
}

int LoveRuntime::fileDataGetExtension(lua_State *state)
{
	const std::string extension = fileExtension(checkFileData(state, 1)->filename);
	lua_pushlstring(state, extension.data(), extension.size());
	return 1;
}

int LoveRuntime::dataGetString(lua_State *state)
{
	auto *data = checkFileData(state, 1);
	lua_pushlstring(state, data->data.data(), data->data.size());
	return 1;
}

int LoveRuntime::dataGetSize(lua_State *state)
{
	lua_pushnumber(state, static_cast<lua_Number>(checkFileData(state, 1)->data.size()));
	return 1;
}

int LoveRuntime::dataGetPointer(lua_State *state)
{
	lua_pushlightuserdata(state, checkFileData(state, 1)->data.data());
	return 1;
}

int LoveRuntime::dataGetFFIPointer(lua_State *state)
{
	(void) checkFileData(state, 1);
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::filesystemLoad(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	std::string resolved;
	std::string error;
	if (!runtime->resolveReadPath(filename, resolved, error))
		return pushFilesystemFailure(state, error);
	std::string code;
	if (!runtime->_filesystemBackend || !runtime->_filesystemBackend->load(resolved, code, error))
		return pushFilesystemFailure(state, error.empty()
			? "failed to open Love filesystem file for loading: " + filename : error);
	const std::string chunkName = runtime->prepareGeneratedChunk(code, "@" + resolved);
	if (loadLoveChunk(state, code, chunkName.c_str()) != LUA_OK)
	{
		runtime->rewriteGeneratedErrorOnStack(state);
		lua_pushnil(state);
		lua_insert(state, -2);
		return 2;
	}
	return 1;
}

int LoveRuntime::filesystemLinesIterator(lua_State *state)
{
	std::size_t size = 0;
	const char *data = lua_tolstring(state, lua_upvalueindex(1), &size);
	std::size_t offset = static_cast<std::size_t>(lua_tointeger(state, lua_upvalueindex(2)));
	if (!data || offset >= size)
		return 0;
	std::size_t end = offset;
	while (end < size && data[end] != '\n' && data[end] != '\r')
		++end;
	lua_pushlstring(state, data + offset, end - offset);
	if (end < size)
	{
		const char first = data[end++];
		if (first == '\r' && end < size && data[end] == '\n')
			++end;
	}
	lua_pushinteger(state, static_cast<lua_Integer>(end));
	lua_copy(state, -1, lua_upvalueindex(2));
	lua_pop(state, 1);
	return 1;
}

int LoveRuntime::filesystemLines(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	std::string resolved;
	std::string error;
	if (!runtime->resolveReadPath(filename, resolved, error))
		return luaL_error(state, "%s", error.c_str());
	std::string data;
	if (!runtime->_filesystemBackend || !runtime->_filesystemBackend->load(resolved, data, error))
		return luaL_error(state, "%s", error.empty()
			? ("failed to open Love filesystem file for lines: " + filename).c_str() : error.c_str());
	lua_pushlstring(state, data.data(), data.size());
	lua_pushinteger(state, 0);
	lua_pushcclosure(state, filesystemLinesIterator, 2);
	return 1;
}

int filesystemWriteOrAppend(lua_State *state, bool append)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	std::size_t dataSize = 0;
	const char *data = nullptr;
	if (auto *fileData = testFileData(state, 2))
	{
		data = fileData->data.data();
		dataSize = fileData->data.size();
	}
	else
		data = luaL_checklstring(state, 2, &dataSize);
	if (!lua_isnoneornil(state, 3))
	{
		const lua_Integer requested = luaL_checkinteger(state, 3);
		if (requested < 0 || static_cast<std::size_t>(requested) > dataSize)
			return luaL_argerror(state, 3, "write size must be within the input string");
		dataSize = static_cast<std::size_t>(requested);
	}
	std::filesystem::path target;
	std::string error;
	if (!resolveWritableEntry(runtime, filename, target, false, error))
	{
		lua_pushboolean(state, false);
		lua_pushlstring(state, error.data(), error.size());
		return 2;
	}
	auto *backend = runtime->getFilesystemBackend();
	if (!backend || !backend->isFolder(target.parent_path().string()))
	{
		const std::string message = "Love filesystem parent directory does not exist: " + filename;
		lua_pushboolean(state, false);
		lua_pushlstring(state, message.data(), message.size());
		return 2;
	}
	std::string outputData;
	if (append && backend->exist(target.string()) && !backend->load(target.string(), outputData, error))
	{
		lua_pushboolean(state, false);
		lua_pushlstring(state, error.data(), error.size());
		return 2;
	}
	outputData.append(data, dataSize);
	if (!backend->save(target.string(), outputData, error))
	{
		const std::string message = error.empty() ? "failed to write Love filesystem file: " + filename : error;
		lua_pushboolean(state, false);
		lua_pushlstring(state, message.data(), message.size());
		return 2;
	}
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::filesystemWrite(lua_State *state)
{
	return filesystemWriteOrAppend(state, false);
}

int LoveRuntime::filesystemAppend(lua_State *state)
{
	return filesystemWriteOrAppend(state, true);
}

int LoveRuntime::filesystemGetInfo(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	const char *filter = luaL_optstring(state, 2, nullptr);
	if (filter && std::string_view(filter) != "file" && std::string_view(filter) != "directory")
		return luaL_argerror(state, 2, "expected 'file' or 'directory'");
	if (!isSafeVirtualPath(filename, true))
		return luaL_error(state, "Love filesystem path must be relative and confined: %s", filename.c_str());
	auto pushInfo = [&](const std::filesystem::path &candidate, bool virtualDirectory) -> bool
	{
		if (!virtualDirectory && (!runtime->_filesystemBackend
			|| !runtime->_filesystemBackend->exist(candidate.string())))
			return false;
		const char *type = virtualDirectory || runtime->_filesystemBackend->isFolder(candidate.string())
			? "directory" : "file";
		if (type == nullptr || (filter && std::string_view(filter) != type))
			return false;
		lua_createtable(state, 0, 2);
		lua_pushstring(state, type);
		lua_setfield(state, -2, "type");
		if (!virtualDirectory && std::string_view(type) == "file")
		{
			const auto size = runtime->_filesystemBackend->getFileSize(candidate.string());
			if (size)
			{
				lua_pushnumber(state, static_cast<lua_Number>(*size));
				lua_setfield(state, -2, "size");
			}
		}
		return true;
	};
	std::filesystem::path candidate;
	std::string error;
	if (resolveEntryWithinRoot(runtime->_saveRoot, filename, candidate, true, error)
		&& pushInfo(candidate, false))
		return 1;
	for (const auto &mount : runtime->_mountedArchives)
	{
		const bool ancestor = !mount.mountpoint.empty() && filename.size() < mount.mountpoint.size()
			&& mount.mountpoint.starts_with(filename.empty() ? "" : filename + "/");
		if (ancestor && pushInfo({}, true))
			return 1;
		error.clear();
		if (resolveMountedEntry(mount.root, mount.mountpoint, filename, candidate, true, error)
			&& pushInfo(candidate, false))
			return 1;
	}
	error.clear();
	if (resolveEntryWithinRoot(runtime->_sourceRoot, filename, candidate, true, error)
		&& pushInfo(candidate, false))
		return 1;
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::filesystemExists(lua_State *state)
{
	lua_settop(state, 1);
	filesystemGetInfo(state);
	const bool exists = !lua_isnil(state, -1);
	lua_pushboolean(state, exists);
	return 1;
}

int LoveRuntime::filesystemIsDirectory(lua_State *state)
{
	lua_settop(state, 1);
	lua_pushliteral(state, "directory");
	filesystemGetInfo(state);
	const bool isDirectory = !lua_isnil(state, -1);
	lua_pushboolean(state, isDirectory);
	return 1;
}

int LoveRuntime::filesystemIsFile(lua_State *state)
{
	lua_settop(state, 1);
	lua_pushliteral(state, "file");
	filesystemGetInfo(state);
	const bool isFile = !lua_isnil(state, -1);
	lua_pushboolean(state, isFile);
	return 1;
}

int LoveRuntime::filesystemIsSymlink(lua_State *state)
{
	// Calling getInfo preserves the same confined Content path validation. Dora
	// Love sources and mounted archives reject symlink entries, so no resolved
	// virtual entry can report the upstream symlink type.
	lua_settop(state, 1);
	filesystemGetInfo(state);
	lua_pushboolean(state, false);
	return 1;
}

int LoveRuntime::filesystemGetLastModified(lua_State *state)
{
	lua_settop(state, 1);
	filesystemGetInfo(state);
	if (lua_isnil(state, -1))
	{
		lua_pushnil(state);
		lua_pushliteral(state, "File does not exist");
		return 2;
	}
	lua_getfield(state, -1, "modtime");
	if (lua_isnumber(state, -1))
		return 1;
	lua_pushnil(state);
	lua_pushliteral(state, "Could not determine file modification date.");
	return 2;
}

int LoveRuntime::filesystemGetSize(lua_State *state)
{
	lua_settop(state, 1);
	lua_pushliteral(state, "file");
	filesystemGetInfo(state);
	if (lua_isnil(state, -1))
	{
		lua_pushnil(state);
		lua_pushliteral(state, "File does not exist");
		return 2;
	}
	lua_getfield(state, -1, "size");
	if (lua_isnumber(state, -1))
		return 1;
	lua_pushnil(state);
	lua_pushliteral(state, "Could not determine file size.");
	return 2;
}

int LoveRuntime::filesystemCreateDirectory(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::filesystem::path target;
	std::string error;
	if (!resolveWritableEntry(runtime, luaL_checkstring(state, 1), target, false, error))
	{
		lua_pushboolean(state, false);
		lua_pushlstring(state, error.data(), error.size());
		return 2;
	}
	const bool success = runtime->_filesystemBackend->createFolder(target.string(), error);
	lua_pushboolean(state, success);
	if (!success)
	{
		const std::string message = error.empty() ? "failed to create Love filesystem directory" : error;
		lua_pushlstring(state, message.data(), message.size());
		return 2;
	}
	return 1;
}

int LoveRuntime::filesystemRemove(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::filesystem::path target;
	std::string error;
	if (!resolveWritableEntry(runtime, luaL_checkstring(state, 1), target, false, error))
	{
		lua_pushboolean(state, false);
		lua_pushlstring(state, error.data(), error.size());
		return 2;
	}
	const bool success = runtime->_filesystemBackend->remove(target.string(), error);
	lua_pushboolean(state, success);
	if (!success)
	{
		const std::string message = error.empty() ? "Love filesystem entry does not exist" : error;
		lua_pushlstring(state, message.data(), message.size());
		return 2;
	}
	return 1;
}

int LoveRuntime::filesystemGetDirectoryItems(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string directory = luaL_optstring(state, 1, "");
	if (!isSafeVirtualPath(directory, true))
		return luaL_error(state, "Love filesystem path must be relative and confined: %s", directory.c_str());
	std::set<std::string> items;
	auto collect = [&](const std::string &root, std::string_view relative)
	{
		std::filesystem::path candidate;
		std::string error;
		if (!resolveEntryWithinRoot(root, relative, candidate, true, error))
			return;
		if (!runtime->_filesystemBackend || !runtime->_filesystemBackend->isFolder(candidate.string()))
			return;
		for (const auto &item : runtime->_filesystemBackend->getDirectoryItems(candidate.string()))
			items.insert(item);
	};
	collect(runtime->_saveRoot, directory);
	for (const auto &mount : runtime->_mountedArchives)
	{
		if (!mount.mountpoint.empty()
			&& (directory.empty() || (mount.mountpoint.size() > directory.size()
				&& mount.mountpoint.starts_with(directory + "/"))))
		{
			const std::size_t start = directory.empty() ? 0 : directory.size() + 1;
			const std::size_t slash = mount.mountpoint.find('/', start);
			items.insert(mount.mountpoint.substr(start, slash - start));
		}
		std::filesystem::path mapped;
		std::string error;
		if (resolveMountedEntry(mount.root, mount.mountpoint, directory, mapped, true, error)
			&& runtime->_filesystemBackend && runtime->_filesystemBackend->isFolder(mapped.string()))
		{
			for (const auto &item : runtime->_filesystemBackend->getDirectoryItems(mapped.string()))
				items.insert(item);
		}
	}
	collect(runtime->_sourceRoot, directory);
	lua_createtable(state, static_cast<int>(items.size()), 0);
	int index = 1;
	for (const auto &item : items)
	{
		lua_pushlstring(state, item.data(), item.size());
		lua_seti(state, -2, index++);
	}
	return 1;
}

int LoveRuntime::sourceModuleSearcher(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::size_t moduleNameSize = 0;
	const char *moduleNameData = luaL_checklstring(state, 1, &moduleNameSize);
	const std::string moduleName(moduleNameData, moduleNameSize);
	if (runtime == nullptr || runtime->_sourceRoot.empty())
	{
		lua_pushliteral(state, "\n\tLove source root is not configured");
		return 1;
	}
	std::string modulePath;
	if (!normalizeLoveModulePath(moduleName, modulePath))
	{
		lua_pushfstring(state, "\n\tinvalid Love module name '%s'", moduleName.c_str());
		return 1;
	}
	std::string searched;
	for (const std::string &pattern : runtime->_requirePath)
	{
		if (pattern.empty())
			continue;
		std::string virtualPath = pattern;
		std::size_t offset = 0;
		while ((offset = virtualPath.find('?', offset)) != std::string::npos)
		{
			virtualPath.replace(offset, 1, modulePath);
			offset += modulePath.size();
		}
		std::string resolvedPath;
		std::string resolveError;
		searched += "\n\tno Love module file '" + virtualPath + "'";
		if (!runtime->resolveReadPath(virtualPath, resolvedPath, resolveError))
			continue;
		std::string code;
		std::string loadError;
		if (!runtime->_filesystemBackend->load(resolvedPath, code, loadError))
			continue;
		const std::string chunkName = runtime->prepareGeneratedChunk(code, "@" + resolvedPath);
		if (loadLoveChunk(state, code, chunkName.c_str()) != LUA_OK)
		{
			runtime->rewriteGeneratedErrorOnStack(state);
			return 1;
		}
		lua_pushlstring(state, resolvedPath.data(), resolvedPath.size());
		return 2;
	}
	lua_pushlstring(state, searched.data(), searched.size());
	return 1;
}

int LoveRuntime::filesystemGetRequirePath(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::string path;
	bool separator = false;
	for (const auto &pattern : runtime->_requirePath)
	{
		if (separator)
			path += ';';
		else
			separator = true;
		path += pattern;
	}
	lua_pushlstring(state, path.data(), path.size());
	return 1;
}

int LoveRuntime::filesystemSetRequirePath(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::size_t pathSize = 0;
	const char *pathData = luaL_checklstring(state, 1, &pathSize);
	static constexpr std::size_t MaximumRequirePathSize = 4096;
	static constexpr std::size_t MaximumRequirePathPatterns = 32;
	if (pathSize > MaximumRequirePathSize)
		return luaL_argerror(state, 1, "Love require path is too long");

	std::vector<std::string> patterns;
	std::string path(pathData, pathSize);
	std::size_t start = 0;
	while (start < path.size())
	{
		const std::size_t separator = path.find(';', start);
		const std::size_t end = separator == std::string::npos ? path.size() : separator;
		std::string pattern = path.substr(start, end - start);
		if (patterns.size() >= MaximumRequirePathPatterns)
			return luaL_argerror(state, 1, "Love require path has too many patterns");
		if (!pattern.empty())
		{
			if (pattern.starts_with('/') || pattern.find(':') != std::string::npos
				|| pattern.find('\0') != std::string::npos)
				return luaL_argerror(state, 1, "Love require path patterns must be relative and confined");
			std::string probe = pattern;
			std::size_t offset = 0;
			while ((offset = probe.find('?', offset)) != std::string::npos)
			{
				probe.replace(offset, 1, "module");
				offset += 6;
			}
			if (!isSafeVirtualPath(probe, false))
				return luaL_argerror(state, 1, "Love require path patterns must be relative and confined");
		}
		patterns.push_back(std::move(pattern));
		if (separator == std::string::npos)
			break;
		start = separator + 1;
	}
	runtime->_requirePath = std::move(patterns);
	return 0;
}

int LoveRuntime::graphicsClear(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	GraphicsBackend::ClearRequest request;
	request.colors.clear();
	int startIndex = -1;
	const int firstType = lua_type(state, 1);
	if (firstType == LUA_TTABLE)
	{
		request.colorsPerAttachment = true;
		const int argumentCount = lua_gettop(state);
		for (int index = 1; index <= argumentCount; ++index)
		{
			const int type = lua_type(state, index);
			if (type == LUA_TNUMBER || type == LUA_TBOOLEAN)
			{
				startIndex = index;
				break;
			}
			GraphicsBackend::ClearColor color;
			if (type == LUA_TNIL || type == LUA_TNONE
				|| (type == LUA_TTABLE && lua_rawlen(state, index) == 0))
			{
				color.enabled = false;
				request.colors.push_back(color);
				continue;
			}
			luaL_checktype(state, index, LUA_TTABLE);
			for (int component = 1; component <= 4; ++component)
				lua_rawgeti(state, index, component);
			color.red = colorComponent(state, -4, 0.0f);
			color.green = colorComponent(state, -3, 0.0f);
			color.blue = colorComponent(state, -2, 0.0f);
			color.alpha = colorComponent(state, -1, 1.0f);
			lua_pop(state, 4);
			request.colors.push_back(color);
		}
	}
	else if (firstType == LUA_TBOOLEAN)
	{
		GraphicsBackend::ClearColor color;
		color.enabled = lua_toboolean(state, 1) != 0;
		request.colors.push_back(color);
		startIndex = 2;
	}
	else if (firstType != LUA_TNONE && firstType != LUA_TNIL)
	{
		GraphicsBackend::ClearColor color;
		color.red = colorComponent(state, 1, 0.0f);
		color.green = colorComponent(state, 2, 0.0f);
		color.blue = colorComponent(state, 3, 0.0f);
		color.alpha = colorComponent(state, 4, 1.0f);
		request.colors.push_back(color);
		startIndex = 5;
	}
	else
		request.colors.push_back(GraphicsBackend::ClearColor{});

	if (startIndex >= 0)
	{
		const int stencilType = lua_type(state, startIndex);
		if (stencilType == LUA_TBOOLEAN)
			request.clearStencil = lua_toboolean(state, startIndex) != 0;
		else if (stencilType == LUA_TNUMBER)
			request.stencil = static_cast<int>(luaL_checkinteger(state, startIndex));
		const int depthType = lua_type(state, startIndex + 1);
		if (depthType == LUA_TBOOLEAN)
			request.clearDepth = lua_toboolean(state, startIndex + 1) != 0;
		else if (depthType == LUA_TNUMBER)
			request.depth = static_cast<float>(luaL_checknumber(state, startIndex + 1));
	}

	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (!runtime->_graphicsBackend->clear(request, error))
			return luaL_error(state, "%s", error.empty()
				? "Dora graphics backend rejected love.graphics.clear" : error.c_str());
	}
	return 0;
}

int LoveRuntime::graphicsDiscard(lua_State *state)
{
	// Love defines discard as an optional framebuffer invalidation hint. LoveNode
	// keeps no transient attachment contents of its own, so retaining them is a
	// valid implementation of the undefined post-discard contents.
	if (lua_istable(state, 1))
	{
		const lua_Integer count = static_cast<lua_Integer>(lua_rawlen(state, 1));
		for (lua_Integer index = 1; index <= count; ++index)
		{
			lua_rawgeti(state, 1, index);
			// Match luax_optboolean: non-boolean entries use the default true.
			(void)(lua_isboolean(state, -1) ? lua_toboolean(state, -1) != 0 : true);
			lua_pop(state, 1);
		}
	}
	else
	{
		(void)(lua_isboolean(state, 1) ? lua_toboolean(state, 1) != 0 : true);
	}
	(void)(lua_isboolean(state, 2) ? lua_toboolean(state, 2) != 0 : true);
	return 0;
}

int LoveRuntime::graphicsFlushBatch(lua_State *)
{
	// LoveNode records each draw as an ordered Dora render command with its state
	// captured at submission time, rather than accumulating Love stream batches.
	return 0;
}

int LoveRuntime::graphicsSetBackgroundColor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (lua_istable(state, 1))
	{
		for (int index = 1; index <= 4; ++index)
			lua_rawgeti(state, 1, index);
		runtime->_graphicsBackgroundColor[0] = colorComponent(state, -4, 1.0f);
		runtime->_graphicsBackgroundColor[1] = colorComponent(state, -3, 1.0f);
		runtime->_graphicsBackgroundColor[2] = colorComponent(state, -2, 1.0f);
		runtime->_graphicsBackgroundColor[3] = colorComponent(state, -1, 1.0f);
		lua_pop(state, 4);
	}
	else
	{
		runtime->_graphicsBackgroundColor[0] = colorComponent(state, 1, 1.0f);
		runtime->_graphicsBackgroundColor[1] = colorComponent(state, 2, 1.0f);
		runtime->_graphicsBackgroundColor[2] = colorComponent(state, 3, 1.0f);
		runtime->_graphicsBackgroundColor[3] = colorComponent(state, 4, 1.0f);
	}
	return 0;
}

int LoveRuntime::graphicsGetBackgroundColor(lua_State *state)
{
	for (float component : runtimeFromUpvalue(state)->_graphicsBackgroundColor)
		lua_pushnumber(state, component);
	return 4;
}

int LoveRuntime::graphicsSetDefaultFilter(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view min = luaL_checkstring(state, 1);
	const std::string_view mag = luaL_optstring(state, 2, min.data());
	if (min != "linear" && min != "nearest")
		return luaL_argerror(state, 1, "expected 'linear' or 'nearest'");
	if (mag != "linear" && mag != "nearest")
		return luaL_argerror(state, 2, "expected 'linear' or 'nearest'");
	if (min != mag)
		return luaL_error(state,
			"embedded Dora textures require matching minification and magnification filters");
	const float anisotropy = static_cast<float>(luaL_optnumber(state, 3, 1.0));
	luaL_argcheck(state, std::isfinite(anisotropy) && anisotropy >= 1.0f, 3,
		"anisotropy must be a finite number greater than or equal to 1");
	runtime->_graphicsDefaultFilter = min == "nearest" ? GraphicsBackend::TextureFilter::Nearest
		: anisotropy > 1.0f ? GraphicsBackend::TextureFilter::Anisotropic
		: GraphicsBackend::TextureFilter::Linear;
	runtime->_graphicsDefaultAnisotropy = anisotropy;
	return 0;
}

int LoveRuntime::graphicsGetDefaultFilter(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const char *mode = runtime->_graphicsDefaultFilter == GraphicsBackend::TextureFilter::Nearest
		? "nearest" : "linear";
	lua_pushstring(state, mode);
	lua_pushstring(state, mode);
	lua_pushnumber(state, runtime->_graphicsDefaultAnisotropy);
	return 3;
}

int LoveRuntime::graphicsSetDefaultMipmapFilter(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (lua_isnoneornil(state, 1))
		runtime->_graphicsDefaultMipmapFilter.reset();
	else
	{
		const std::string_view mode = luaL_checkstring(state, 1);
		if (mode != "linear" && mode != "nearest")
			return luaL_argerror(state, 1, "expected 'linear', 'nearest', or nil");
		runtime->_graphicsDefaultMipmapFilter = mode == "nearest"
			? GraphicsBackend::TextureFilter::Nearest : GraphicsBackend::TextureFilter::Linear;
	}
	const float sharpness = static_cast<float>(luaL_optnumber(state, 2, 0.0));
	luaL_argcheck(state, std::isfinite(sharpness), 2, "mipmap sharpness must be finite");
	runtime->_graphicsDefaultMipmapSharpness = sharpness;
	return 0;
}

int LoveRuntime::graphicsGetDefaultMipmapFilter(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsDefaultMipmapFilter)
		lua_pushnil(state);
	else
		lua_pushstring(state, *runtime->_graphicsDefaultMipmapFilter
			== GraphicsBackend::TextureFilter::Nearest ? "nearest" : "linear");
	lua_pushnumber(state, runtime->_graphicsDefaultMipmapSharpness);
	return 2;
}

int LoveRuntime::graphicsSetColor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (lua_istable(state, 1))
	{
		for (int index = 1; index <= 4; ++index)
			lua_rawgeti(state, 1, index);
		runtime->_graphicsColor[0] = colorComponent(state, -4, 1.0f);
		runtime->_graphicsColor[1] = colorComponent(state, -3, 1.0f);
		runtime->_graphicsColor[2] = colorComponent(state, -2, 1.0f);
		runtime->_graphicsColor[3] = colorComponent(state, -1, 1.0f);
		lua_pop(state, 4);
	}
	else
	{
		runtime->_graphicsColor[0] = colorComponent(state, 1, 1.0f);
		runtime->_graphicsColor[1] = colorComponent(state, 2, 1.0f);
		runtime->_graphicsColor[2] = colorComponent(state, 3, 1.0f);
		runtime->_graphicsColor[3] = colorComponent(state, 4, 1.0f);
	}
	return 0;
}

int LoveRuntime::graphicsGetColor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	for (float component : runtime->_graphicsColor)
		lua_pushnumber(state, component);
	return 4;
}

int LoveRuntime::graphicsSetLineWidth(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	runtime->_graphicsLineWidth = std::max(0.0f, static_cast<float>(luaL_checknumber(state, 1)));
	return 0;
}

int LoveRuntime::graphicsGetLineWidth(lua_State *state)
{
	lua_pushnumber(state, runtimeFromUpvalue(state)->_graphicsLineWidth);
	return 1;
}

int LoveRuntime::graphicsSetLineStyle(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view style = luaL_checkstring(state, 1);
	if (style == "rough") runtime->_graphicsLineStyle = GraphicsBackend::LineStyle::Rough;
	else if (style == "smooth") runtime->_graphicsLineStyle = GraphicsBackend::LineStyle::Smooth;
	else return luaL_argerror(state, 1, "invalid line style");
	return 0;
}

int LoveRuntime::graphicsGetLineStyle(lua_State *state)
{
	lua_pushstring(state, runtimeFromUpvalue(state)->_graphicsLineStyle
		== GraphicsBackend::LineStyle::Smooth ? "smooth" : "rough");
	return 1;
}

int LoveRuntime::graphicsSetLineJoin(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view join = luaL_checkstring(state, 1);
	if (join == "none") runtime->_graphicsLineJoin = GraphicsBackend::LineJoin::None;
	else if (join == "miter") runtime->_graphicsLineJoin = GraphicsBackend::LineJoin::Miter;
	else if (join == "bevel") runtime->_graphicsLineJoin = GraphicsBackend::LineJoin::Bevel;
	else return luaL_argerror(state, 1, "invalid line join");
	return 0;
}

int LoveRuntime::graphicsGetLineJoin(lua_State *state)
{
	switch (runtimeFromUpvalue(state)->_graphicsLineJoin)
	{
		case GraphicsBackend::LineJoin::None: lua_pushliteral(state, "none"); break;
		case GraphicsBackend::LineJoin::Bevel: lua_pushliteral(state, "bevel"); break;
		case GraphicsBackend::LineJoin::Miter: lua_pushliteral(state, "miter"); break;
	}
	return 1;
}

int LoveRuntime::graphicsSetWireframe(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool enabled = lua_toboolean(state, 1) != 0;
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	runtime->_graphicsWireframe = enabled;
	if (runtime->_graphicsBackend)
		runtime->_graphicsBackend->setWireframe(enabled);
	return 0;
}

int LoveRuntime::graphicsIsWireframe(lua_State *state)
{
	lua_pushboolean(state, runtimeFromUpvalue(state)->_graphicsWireframe);
	return 1;
}

int LoveRuntime::graphicsSetPointSize(lua_State *state)
{
	const float size = static_cast<float>(luaL_checknumber(state, 1));
	luaL_argcheck(state, std::isfinite(size) && size > 0.0f, 1,
		"point size must be a finite number greater than zero");
	runtimeFromUpvalue(state)->_graphicsPointSize = size;
	return 0;
}

int LoveRuntime::graphicsGetPointSize(lua_State *state)
{
	lua_pushnumber(state, runtimeFromUpvalue(state)->_graphicsPointSize);
	return 1;
}

int LoveRuntime::graphicsGetDimensions(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushinteger(state, runtime->_graphicsBackend
		? runtime->_graphicsBackend->getPixelWidth() : runtime->_configuredWidth);
	lua_pushinteger(state, runtime->_graphicsBackend
		? runtime->_graphicsBackend->getPixelHeight() : runtime->_configuredHeight);
	return 2;
}

int LoveRuntime::graphicsGetWidth(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushinteger(state, runtime->_graphicsBackend
		? runtime->_graphicsBackend->getPixelWidth() : runtime->_configuredWidth);
	return 1;
}

int LoveRuntime::graphicsGetHeight(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushinteger(state, runtime->_graphicsBackend
		? runtime->_graphicsBackend->getPixelHeight() : runtime->_configuredHeight);
	return 1;
}

int LoveRuntime::graphicsGetPixelDimensions(lua_State *state)
{
	// An embedded Love surface has no independent operating-system DPI scale:
	// one logical unit always addresses one RenderTarget pixel.
	return graphicsGetDimensions(state);
}

int LoveRuntime::graphicsGetPixelWidth(lua_State *state)
{
	return graphicsGetWidth(state);
}

int LoveRuntime::graphicsGetPixelHeight(lua_State *state)
{
	return graphicsGetHeight(state);
}

int LoveRuntime::graphicsGetDPIScale(lua_State *state)
{
	lua_pushnumber(state, 1.0);
	return 1;
}

int LoveRuntime::graphicsGetSupported(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	const auto capabilities = runtime->_graphicsBackend->getCapabilities();
	if (lua_istable(state, 1))
		lua_pushvalue(state, 1);
	else
		lua_createtable(state, 0, 8);
	const std::pair<const char *, bool> fields[] = {
		{"multicanvasformats", capabilities.multiCanvasFormats},
		{"clampzero", capabilities.clampZero},
		{"lighten", capabilities.lighten},
		{"fullnpot", capabilities.fullNPOT},
		{"pixelshaderhighp", capabilities.pixelShaderHighp},
		{"shaderderivatives", capabilities.shaderDerivatives},
		{"glsl3", capabilities.glsl3},
		{"instancing", capabilities.instancing},
	};
	for (const auto &[name, value] : fields)
	{
		lua_pushboolean(state, value);
		lua_setfield(state, -2, name);
	}
	return 1;
}

int LoveRuntime::graphicsGetTextureTypes(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	const auto types = runtime->_graphicsBackend->getTextureTypes();
	if (lua_istable(state, 1))
		lua_pushvalue(state, 1);
	else
		lua_createtable(state, 0, 4);
	const std::pair<const char *, bool> fields[] = {
		{"2d", types.texture2D}, {"array", types.array},
		{"cube", types.cube}, {"volume", types.volume},
	};
	for (const auto &[name, value] : fields)
	{
		lua_pushboolean(state, value);
		lua_setfield(state, -2, name);
	}
	return 1;
}

int LoveRuntime::graphicsGetImageFormats(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	if (lua_istable(state, 1))
		lua_pushvalue(state, 1);
	else
		lua_createtable(state, 0, 53);
	// Love 11.5 exposes ImageData-compatible uncompressed formats and all
	// compressed PixelFormat names. Canvas aliases, sRGBA and depth formats are
	// intentionally absent, matching wrap_Graphics.cpp::w_getImageFormats.
	static constexpr std::string_view formats[] = {
		"r8", "rg8", "rgba8", "r16", "rg16", "rgba16", "r16f", "rg16f",
		"rgba16f", "r32f", "rg32f", "rgba32f", "rgba4", "rgb5a1", "rgb565",
		"rgb10a2", "rg11b10f",
		"DXT1", "DXT3", "DXT5", "BC4", "BC4s", "BC5", "BC5s", "BC6h",
		"BC6hs", "BC7", "PVR1rgb2", "PVR1rgb4", "PVR1rgba2", "PVR1rgba4",
		"ETC1", "ETC2rgb", "ETC2rgba", "ETC2rgba1", "EACr", "EACrs", "EACrg",
		"EACrgs", "ASTC4x4", "ASTC5x4", "ASTC5x5", "ASTC6x5", "ASTC6x6",
		"ASTC8x5", "ASTC8x6", "ASTC8x8", "ASTC10x5", "ASTC10x6", "ASTC10x8",
		"ASTC10x10", "ASTC12x10", "ASTC12x12",
	};
	for (const auto format : formats)
	{
		lua_pushboolean(state, runtime->_graphicsBackend->isImageFormatSupported(format));
		lua_setfield(state, -2, format.data());
	}
	return 1;
}

int LoveRuntime::graphicsGetRendererInfo(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	const auto info = runtime->_graphicsBackend->getRendererInfo();
	lua_pushlstring(state, info.name.data(), info.name.size());
	lua_pushlstring(state, info.version.data(), info.version.size());
	lua_pushlstring(state, info.vendor.data(), info.vendor.size());
	lua_pushlstring(state, info.device.data(), info.device.size());
	return 4;
}

int LoveRuntime::graphicsGetSystemLimits(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const auto limits = runtime->_graphicsBackend
		? runtime->_graphicsBackend->getSystemLimits() : GraphicsBackend::SystemLimits{};
	if (lua_istable(state, 1))
		lua_pushvalue(state, 1);
	else
		lua_createtable(state, 0, 8);
	const std::pair<const char *, double> fields[] = {
		{"pointsize", limits.pointSize},
		{"texturesize", limits.textureSize},
		{"volumetexturesize", limits.volumeTextureSize},
		{"cubetexturesize", limits.cubeTextureSize},
		{"texturelayers", limits.textureLayers},
		{"multicanvas", limits.multiCanvas},
		{"canvasmsaa", limits.canvasMSAA},
		{"anisotropy", limits.anisotropy},
	};
	for (const auto &[name, value] : fields)
	{
		lua_pushnumber(state, value);
		lua_setfield(state, -2, name);
	}
	return 1;
}

int LoveRuntime::graphicsGetStats(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const auto stats = runtime->_graphicsBackend
		? runtime->_graphicsBackend->getStats() : GraphicsBackend::Stats{};
	if (lua_istable(state, 1)) lua_pushvalue(state, 1);
	else lua_createtable(state, 0, 8);
	auto setInteger = [&](const char *name, std::uint64_t value) {
		lua_pushinteger(state, static_cast<lua_Integer>(std::min<std::uint64_t>(value,
			static_cast<std::uint64_t>(std::numeric_limits<lua_Integer>::max()))));
		lua_setfield(state, -2, name);
	};
	setInteger("drawcalls", stats.drawCalls);
	setInteger("drawcallsbatched", stats.drawCallsBatched);
	setInteger("canvasswitches", stats.canvasSwitches);
	setInteger("shaderswitches", stats.shaderSwitches);
	setInteger("canvases", stats.canvases);
	setInteger("images", stats.images);
	setInteger("fonts", stats.fonts);
	setInteger("texturememory", stats.textureMemory);
	return 1;
}

int LoveRuntime::graphicsCaptureScreenshot(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora screenshot backend");

	ScreenshotRequest request;
	if (lua_type(state, 1) == LUA_TSTRING)
	{
		const std::string filename = lua_tostring(state, 1);
		std::string extension = std::filesystem::path(filename).extension().string();
		std::transform(extension.begin(), extension.end(), extension.begin(),
			[](unsigned char value) { return static_cast<char>(std::tolower(value)); });
		if (extension != ".png")
			return luaL_argerror(state, 1, "embedded Dora screenshots currently support only PNG filenames");
		std::filesystem::path target;
		std::string error;
		if (!resolveWritableEntry(runtime, filename, target, false, error))
			return luaL_error(state, "Love screenshot '%s' path failed: %s", filename.c_str(), error.c_str());
		request.filename = target.string();
	}
	else if (lua_type(state, 1) == LUA_TFUNCTION)
	{
		lua_pushvalue(state, 1);
		request.callbackReference = luaL_ref(state, LUA_REGISTRYINDEX);
	}
	else if (auto *channel = luaL_testudata(state, 1, ChannelLoveType.getName())
		? ::love::luax_checktype<ChannelUserdata>(state, 1, ChannelLoveType) : nullptr;
		channel && channel->channel)
	{
		request.channel = channel->channel;
	}
	else
		return luaL_argerror(state, 1, "expected a PNG filename, screenshot callback function, or Channel");

	const std::uint64_t requestId = runtime->_nextScreenshotRequest++;
	runtime->_screenshotRequests.emplace(requestId, std::move(request));
	std::string error;
	if (!runtime->_graphicsBackend->requestScreenshot(requestId, error))
	{
		auto found = runtime->_screenshotRequests.find(requestId);
		if (found != runtime->_screenshotRequests.end())
		{
			if (found->second.callbackReference != LUA_NOREF)
				luaL_unref(state, LUA_REGISTRYINDEX, found->second.callbackReference);
			runtime->_screenshotRequests.erase(found);
		}
		return luaL_error(state, "Love screenshot request failed: %s",
			error.empty() ? "Dora renderer rejected the capture" : error.c_str());
	}
	return 0;
}

int LoveRuntime::windowGetMode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int width = runtime->_graphicsBackend
		? runtime->_graphicsBackend->getPixelWidth() : runtime->_configuredWidth;
	const int height = runtime->_graphicsBackend
		? runtime->_graphicsBackend->getPixelHeight() : runtime->_configuredHeight;
	lua_pushinteger(state, width);
	lua_pushinteger(state, height);
	lua_newtable(state);
	lua_pushboolean(state, false);
	lua_setfield(state, -2, "fullscreen");
	lua_pushinteger(state, 1);
	lua_setfield(state, -2, "display");
	lua_pushboolean(state, false);
	lua_setfield(state, -2, "highdpi");
	lua_pushboolean(state, runtime->_windowResizable);
	lua_setfield(state, -2, "resizable");
	return 3;
}

namespace
{
void checkLoveVirtualDisplay(lua_State *state, int argument)
{
	const lua_Integer display = luaL_optinteger(state, argument, 1);
	luaL_argcheck(state, display == 1, argument,
		"embedded LoveNode exposes only virtual display 1");
}

std::pair<int, int> getLoveVirtualWindowDimensions(LoveRuntime *runtime)
{
	return {
		runtime->getGraphicsBackend()
			? runtime->getGraphicsBackend()->getPixelWidth() : runtime->getConfiguredWidth(),
		runtime->getGraphicsBackend()
			? runtime->getGraphicsBackend()->getPixelHeight() : runtime->getConfiguredHeight(),
	};
}
}

int LoveRuntime::windowGetDesktopDimensions(lua_State *state)
{
	checkLoveVirtualDisplay(state, 1);
	const auto [width, height] = getLoveVirtualWindowDimensions(runtimeFromUpvalue(state));
	lua_pushinteger(state, width);
	lua_pushinteger(state, height);
	return 2;
}

int LoveRuntime::windowGetDisplayCount(lua_State *state)
{
	lua_pushinteger(state, 1);
	return 1;
}

int LoveRuntime::windowGetDisplayName(lua_State *state)
{
	checkLoveVirtualDisplay(state, 1);
	lua_pushliteral(state, "Dora LoveNode");
	return 1;
}

int LoveRuntime::windowGetDisplayOrientation(lua_State *state)
{
	checkLoveVirtualDisplay(state, 1);
	const auto [width, height] = getLoveVirtualWindowDimensions(runtimeFromUpvalue(state));
	if (width > height) lua_pushliteral(state, "landscape");
	else if (height > width) lua_pushliteral(state, "portrait");
	else lua_pushliteral(state, "unknown");
	return 1;
}

int LoveRuntime::windowGetFullscreenModes(lua_State *state)
{
	checkLoveVirtualDisplay(state, 1);
	// A LoveNode has a resizable RenderTarget but owns no host fullscreen mode.
	lua_newtable(state);
	return 1;
}

int LoveRuntime::windowSetFullscreen(lua_State *state)
{
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	if (!lua_isnoneornil(state, 2))
	{
		const std::string_view type = luaL_checkstring(state, 2);
		luaL_argcheck(state, type == "desktop" || type == "exclusive", 2,
			"expected 'desktop' or 'exclusive'");
	}
	// Disabling fullscreen is already true for the embedded surface. Enabling
	// it would transfer host-window ownership and is intentionally rejected.
	lua_pushboolean(state, !lua_toboolean(state, 1));
	return 1;
}

int LoveRuntime::windowGetFullscreen(lua_State *state)
{
	lua_pushboolean(state, false);
	lua_pushliteral(state, "desktop");
	return 2;
}

int LoveRuntime::windowIsOpen(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool open = runtime && runtime->getGraphicsBackend()
		&& runtime->_status != Status::Closed && runtime->_status != Status::Faulted
		&& runtime->_status != Status::Stopped;
	lua_pushboolean(state, open);
	return 1;
}

int LoveRuntime::windowGetIcon(lua_State *state)
{
	// The virtual surface has no independent application icon.
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::windowSetIcon(lua_State *state)
{
	auto *icon = checkImageData(state, 1);
	luaL_argcheck(state, icon->width > 0 && icon->height > 0, 1,
		"window icon ImageData must have positive dimensions");
	// LoveNode does not own Dora's host window icon. Accept the virtual-window
	// request as a no-op so portable games do not fail during love.load.
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::windowGetPosition(lua_State *state)
{
	lua_pushinteger(state, 0);
	lua_pushinteger(state, 0);
	lua_pushinteger(state, 1);
	return 3;
}

int LoveRuntime::windowGetSafeArea(lua_State *state)
{
	const auto [width, height] = getLoveVirtualWindowDimensions(runtimeFromUpvalue(state));
	lua_pushnumber(state, 0.0);
	lua_pushnumber(state, 0.0);
	lua_pushnumber(state, width);
	lua_pushnumber(state, height);
	return 4;
}

int LoveRuntime::windowSetTitle(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::size_t size = 0;
	const char *title = luaL_checklstring(state, 1, &size);
	runtime->_windowTitle.assign(title, size);
	return 0;
}

int LoveRuntime::windowGetTitle(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushlstring(state, runtime->_windowTitle.data(), runtime->_windowTitle.size());
	return 1;
}

int LoveRuntime::windowSetVSync(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_Integer value = 0;
	if (lua_isboolean(state, 1)) value = lua_toboolean(state, 1) ? 1 : 0;
	else value = luaL_checkinteger(state, 1);
	luaL_argcheck(state, value >= -1 && value <= 1, 1,
		"virtual VSync mode must be -1, 0, or 1");
	runtime->_windowVSync = static_cast<int>(value);
	return 0;
}

int LoveRuntime::windowGetVSync(lua_State *state)
{
	lua_pushinteger(state, runtimeFromUpvalue(state)->_windowVSync);
	return 1;
}

int LoveRuntime::windowSetDisplaySleepEnabled(lua_State *state)
{
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	runtimeFromUpvalue(state)->_windowDisplaySleepEnabled = lua_toboolean(state, 1) != 0;
	return 0;
}

int LoveRuntime::windowIsDisplaySleepEnabled(lua_State *state)
{
	lua_pushboolean(state, runtimeFromUpvalue(state)->_windowDisplaySleepEnabled);
	return 1;
}

int LoveRuntime::windowHasFocus(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime->_graphicsBackend
		&& runtime->_graphicsBackend->hasWindowFocus());
	return 1;
}

int LoveRuntime::windowHasMouseFocus(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime->_graphicsBackend
		&& runtime->_graphicsBackend->hasWindowMouseFocus());
	return 1;
}

int LoveRuntime::windowIsVisible(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime->_graphicsBackend
		&& runtime->_graphicsBackend->isWindowVisible());
	return 1;
}

int LoveRuntime::windowIsMaximized(lua_State *state)
{
	lua_pushboolean(state, false);
	return 1;
}

int LoveRuntime::windowIsMinimized(lua_State *state)
{
	lua_pushboolean(state, false);
	return 1;
}

int LoveRuntime::windowSetMode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const lua_Integer width = luaL_checkinteger(state, 1);
	const lua_Integer height = luaL_checkinteger(state, 2);
	if (width < 1 || width > MaximumWindowDimension || height < 1 || height > MaximumWindowDimension)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	auto *graphics = runtime->getGraphicsBackend();
	if (!graphics)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	bool resizable = runtime->_windowResizable;
	if (!lua_isnoneornil(state, 3))
	{
		luaL_checktype(state, 3, LUA_TTABLE);
		auto readBoolean = [state](const char *field, bool &value) {
			lua_getfield(state, 3, field);
			if (!lua_isnil(state, -1))
			{
				if (!lua_isboolean(state, -1))
					luaL_error(state, "love.window.setMode setting '%s' must be a boolean", field);
				value = lua_toboolean(state, -1);
			}
			lua_pop(state, 1);
		};
		bool fullscreen = false;
		bool highdpi = false;
		readBoolean("fullscreen", fullscreen);
		readBoolean("highdpi", highdpi);
		readBoolean("resizable", resizable);
		lua_getfield(state, 3, "display");
		lua_Integer display = 1;
		if (!lua_isnil(state, -1))
		{
			int isInteger = 0;
			display = lua_tointegerx(state, -1, &isInteger);
			if (!isInteger)
				return luaL_error(state, "love.window.setMode setting 'display' must be an integer");
		}
		lua_pop(state, 1);
		if (fullscreen || highdpi || display != 1)
		{
			lua_pushboolean(state, false);
			return 1;
		}
	}
	std::string error;
	if (!runtime->_graphicsBackend->setMode(static_cast<int>(width), static_cast<int>(height), error))
	{
		lua_pushboolean(state, false);
		return 1;
	}
	runtime->_configuredWidth = static_cast<int>(width);
	runtime->_configuredHeight = static_cast<int>(height);
	runtime->_windowResizable = resizable;
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::windowUpdateMode(lua_State *state)
{
	if (lua_gettop(state) == 0)
		return luaL_error(state, "love.window.updateMode expected at least one argument");
	if (lua_type(state, 1) == LUA_TNUMBER)
		return windowSetMode(state);
	if (!lua_isnoneornil(state, 1))
		luaL_checktype(state, 1, LUA_TTABLE);
	auto *runtime = runtimeFromUpvalue(state);
	const int width = runtime->_graphicsBackend
		? runtime->_graphicsBackend->getPixelWidth() : runtime->_configuredWidth;
	const int height = runtime->_graphicsBackend
		? runtime->_graphicsBackend->getPixelHeight() : runtime->_configuredHeight;
	lua_pushinteger(state, width);
	lua_pushinteger(state, height);
	lua_rotate(state, 1, 2);
	return windowSetMode(state);
}

int LoveRuntime::windowGetDPIScale(lua_State *state)
{
	// The current embedded surface maps one Love logical unit to one RenderTarget pixel.
	lua_pushnumber(state, 1.0);
	return 1;
}

int LoveRuntime::windowGetNativeDPIScale(lua_State *state)
{
	// The virtual surface itself is the native pixel target. Host-window scale
	// is deliberately outside this embedded Love window's coordinate system.
	lua_pushnumber(state, 1.0);
	return 1;
}

int LoveRuntime::windowToPixels(lua_State *state)
{
	const double x = luaL_checknumber(state, 1);
	if (lua_isnoneornil(state, 2))
	{
		lua_pushnumber(state, x);
		return 1;
	}
	const double y = luaL_checknumber(state, 2);
	lua_pushnumber(state, x);
	lua_pushnumber(state, y);
	return 2;
}

int LoveRuntime::windowFromPixels(lua_State *state)
{
	// Keep the same overload and validation behavior as Love 11.5. Since the
	// embedded surface DPI scale is one, this is the inverse identity mapping.
	return windowToPixels(state);
}

int LoveRuntime::keyboardIsDown(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool table = lua_istable(state, 1);
	const int count = table ? static_cast<int>(lua_rawlen(state, 1)) : lua_gettop(state);
	for (int index = 1; index <= count; ++index)
	{
		if (table) lua_rawgeti(state, 1, index);
		const int valueIndex = table ? -1 : index;
		const std::string key = luaL_checkstring(state, valueIndex);
		love::keyboard::Keyboard::Key constant;
		if (!love::keyboard::Keyboard::getConstant(key.c_str(), constant))
			return luaL_error(state, "Invalid key constant: %s", key.c_str());
		if (runtime->_pressedKeys.contains(key))
		{
			if (table) lua_pop(state, 1);
			lua_pushboolean(state, true);
			return 1;
		}
		if (table) lua_pop(state, 1);
	}
	lua_pushboolean(state, false);
	return 1;
}

int LoveRuntime::keyboardIsScancodeDown(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool table = lua_istable(state, 1);
	const int count = table ? static_cast<int>(lua_rawlen(state, 1)) : lua_gettop(state);
	for (int index = 1; index <= count; ++index)
	{
		if (table) lua_rawgeti(state, 1, index);
		const int valueIndex = table ? -1 : index;
		const std::string scancode = luaL_checkstring(state, valueIndex);
		love::keyboard::Keyboard::Scancode constant;
		if (!love::keyboard::Keyboard::getConstant(scancode.c_str(), constant))
			return luaL_error(state, "Invalid scancode: %s", scancode.c_str());
		if (runtime->_pressedScancodes.contains(scancode))
		{
			if (table) lua_pop(state, 1);
			lua_pushboolean(state, true);
			return 1;
		}
		if (table) lua_pop(state, 1);
	}
	lua_pushboolean(state, false);
	return 1;
}

int LoveRuntime::keyboardSetKeyRepeat(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	runtime->_keyRepeatEnabled = lua_toboolean(state, 1) != 0;
	return 0;
}

int LoveRuntime::keyboardHasKeyRepeat(lua_State *state)
{
	lua_pushboolean(state, runtimeFromUpvalue(state)->_keyRepeatEnabled);
	return 1;
}

int LoveRuntime::keyboardGetScancodeFromKey(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string key = luaL_checkstring(state, 1);
	love::keyboard::Keyboard::Key constant;
	if (!love::keyboard::Keyboard::getConstant(key.c_str(), constant))
		return luaL_error(state, "Invalid key constant: %s", key.c_str());
	std::string scancode = runtime->_keyboardBackend
		? runtime->_keyboardBackend->getScancodeFromKey(key) : "unknown";
	love::keyboard::Keyboard::Scancode scanConstant;
	if (!love::keyboard::Keyboard::getConstant(scancode.c_str(), scanConstant))
		scancode = "unknown";
	lua_pushlstring(state, scancode.data(), scancode.size());
	return 1;
}

int LoveRuntime::keyboardGetKeyFromScancode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string scancode = luaL_checkstring(state, 1);
	love::keyboard::Keyboard::Scancode constant;
	if (!love::keyboard::Keyboard::getConstant(scancode.c_str(), constant))
		return luaL_error(state, "Invalid scancode: %s", scancode.c_str());
	std::string key = runtime->_keyboardBackend
		? runtime->_keyboardBackend->getKeyFromScancode(scancode) : "unknown";
	love::keyboard::Keyboard::Key keyConstant;
	if (!love::keyboard::Keyboard::getConstant(key.c_str(), keyConstant))
		key = "unknown";
	lua_pushlstring(state, key.data(), key.size());
	return 1;
}

int LoveRuntime::keyboardSetTextInput(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	const bool enabled = lua_toboolean(state, 1) != 0;
	const bool hasRectangle = lua_gettop(state) > 1;
	float x = 0.0f;
	float y = 0.0f;
	float width = 0.0f;
	float height = 0.0f;
	if (hasRectangle)
	{
		x = static_cast<float>(luaL_checknumber(state, 2));
		y = static_cast<float>(luaL_checknumber(state, 3));
		width = static_cast<float>(luaL_checknumber(state, 4));
		height = static_cast<float>(luaL_checknumber(state, 5));
		luaL_argcheck(state, std::isfinite(x) && std::isfinite(y)
			&& std::isfinite(width) && std::isfinite(height), 2, "text input rectangle must be finite");
	}
	runtime->_textInputEnabled = enabled;
	if (runtime->_keyboardBackend)
		runtime->_keyboardBackend->setTextInput(enabled, hasRectangle, x, y, width, height);
	return 0;
}

int LoveRuntime::keyboardHasTextInput(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime->_textInputEnabled);
	return 1;
}

int LoveRuntime::keyboardHasScreenKeyboard(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime->_keyboardBackend
		&& runtime->_keyboardBackend->hasScreenKeyboard());
	return 1;
}

int LoveRuntime::mouseGetPosition(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime->_mouseX);
	lua_pushnumber(state, runtime->_mouseY);
	return 2;
}

int LoveRuntime::mouseGetX(lua_State *state)
{
	lua_pushnumber(state, runtimeFromUpvalue(state)->_mouseX);
	return 1;
}

int LoveRuntime::mouseGetY(lua_State *state)
{
	lua_pushnumber(state, runtimeFromUpvalue(state)->_mouseY);
	return 1;
}

int LoveRuntime::mouseSetPosition(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	luaL_argcheck(state, std::isfinite(x), 1, "mouse x must be finite");
	luaL_argcheck(state, std::isfinite(y), 2, "mouse y must be finite");
	runtime->_mouseX = x;
	runtime->_mouseY = y;
	if (runtime->_mouseBackend) runtime->_mouseBackend->setMousePosition(x, y);
	return 0;
}

int LoveRuntime::mouseSetX(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	luaL_argcheck(state, std::isfinite(x), 1, "mouse x must be finite");
	runtime->_mouseX = x;
	if (runtime->_mouseBackend) runtime->_mouseBackend->setMousePosition(x, runtime->_mouseY);
	return 0;
}

int LoveRuntime::mouseSetY(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float y = static_cast<float>(luaL_checknumber(state, 1));
	luaL_argcheck(state, std::isfinite(y), 1, "mouse y must be finite");
	runtime->_mouseY = y;
	if (runtime->_mouseBackend) runtime->_mouseBackend->setMousePosition(runtime->_mouseX, y);
	return 0;
}

int LoveRuntime::mouseIsDown(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool table = lua_istable(state, 1);
	const int count = table ? static_cast<int>(lua_rawlen(state, 1)) : lua_gettop(state);
	for (int index = 1; index <= count; ++index)
	{
		if (table) lua_rawgeti(state, 1, index);
		const int valueIndex = table ? -1 : index;
		const int button = static_cast<int>(luaL_checkinteger(state, valueIndex));
		if (runtime->_pressedMouseButtons.contains(button))
		{
			if (table) lua_pop(state, 1);
			lua_pushboolean(state, true);
			return 1;
		}
		if (table) lua_pop(state, 1);
	}
	lua_pushboolean(state, false);
	return 1;
}

int LoveRuntime::mouseSetVisible(lua_State *state)
{
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	auto *runtime = runtimeFromUpvalue(state);
	runtime->_mouseVisible = lua_toboolean(state, 1) != 0;
	if (runtime->_mouseBackend) runtime->_mouseBackend->setMouseVisible(runtime->_mouseVisible);
	return 0;
}

int LoveRuntime::mouseIsVisible(lua_State *state)
{
	lua_pushboolean(state, runtimeFromUpvalue(state)->_mouseVisible);
	return 1;
}

int LoveRuntime::mouseSetGrabbed(lua_State *state)
{
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	auto *runtime = runtimeFromUpvalue(state);
	runtime->_mouseGrabbed = lua_toboolean(state, 1) != 0;
	if (runtime->_mouseBackend) runtime->_mouseBackend->setMouseGrabbed(runtime->_mouseGrabbed);
	return 0;
}

int LoveRuntime::mouseIsGrabbed(lua_State *state)
{
	lua_pushboolean(state, runtimeFromUpvalue(state)->_mouseGrabbed);
	return 1;
}

int LoveRuntime::mouseSetRelativeMode(lua_State *state)
{
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	auto *runtime = runtimeFromUpvalue(state);
	const bool relative = lua_toboolean(state, 1) != 0;
	const bool accepted = !runtime->_mouseBackend
		|| runtime->_mouseBackend->setMouseRelativeMode(relative);
	if (accepted) runtime->_mouseRelativeMode = relative;
	lua_pushboolean(state, accepted);
	return 1;
}

int LoveRuntime::mouseGetRelativeMode(lua_State *state)
{
	lua_pushboolean(state, runtimeFromUpvalue(state)->_mouseRelativeMode);
	return 1;
}

int LoveRuntime::mouseNewCursor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_mouseBackend)
		return luaL_error(state, "love.mouse cursor creation is not attached to a Dora mouse backend");
	const lua_Integer hotX = luaL_optinteger(state, 2, 0);
	const lua_Integer hotY = luaL_optinteger(state, 3, 0);
	ImageDataUserdata *image = testImageData(state, 1);
	bool temporaryImage = false;
	if (!image)
	{
		imageNewImageData(state);
		image = checkImageData(state, -1);
		temporaryImage = true;
	}
	luaL_argcheck(state, image->runtime == runtime, 1,
		"ImageData belongs to another LoveRuntime");
	luaL_argcheck(state, hotX >= 0 && hotX < image->width, 2,
		"cursor hotspot x must be inside the image");
	luaL_argcheck(state, hotY >= 0 && hotY < image->height, 3,
		"cursor hotspot y must be inside the image");
	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*image, rgba8);
	std::string error;
	const auto handle = runtime->_mouseBackend->createImageCursor(image->width, image->height,
		rgba8, static_cast<int>(hotX), static_cast<int>(hotY), error);
	if (temporaryImage) lua_pop(state, 1);
	if (handle == 0)
		return luaL_error(state, "Love image cursor creation failed: %s",
			error.empty() ? "Dora mouse backend rejected the cursor" : error.c_str());
	pushCursor(state, runtime, handle, "image");
	return 1;
}

int LoveRuntime::mouseGetSystemCursor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string type = luaL_checkstring(state, 1);
	static constexpr std::array<std::string_view, 12> SystemCursorTypes = {
		"arrow", "ibeam", "wait", "crosshair", "waitarrow", "sizenwse",
		"sizenesw", "sizewe", "sizens", "sizeall", "no", "hand",
	};
	luaL_argcheck(state, std::find(SystemCursorTypes.begin(), SystemCursorTypes.end(), type)
		!= SystemCursorTypes.end(), 1, "invalid system cursor type");
	if (const auto found = runtime->_systemCursorReferences.find(type);
		found != runtime->_systemCursorReferences.end())
	{
		::love::luax_pushtype(state, CursorUserdata::type,
			static_cast<CursorUserdata *>(runtime->_systemCursorObjects.at(type).get()));
		return 1;
	}
	if (!runtime->_mouseBackend)
		return luaL_error(state, "love.mouse cursor creation is not attached to a Dora mouse backend");
	std::string error;
	const auto handle = runtime->_mouseBackend->createSystemCursor(type, error);
	if (handle == 0)
		return luaL_error(state, "Love system cursor creation failed: %s",
			error.empty() ? "Dora mouse backend rejected the cursor" : error.c_str());
	pushCursor(state, runtime, handle, type);
	runtime->_systemCursorObjects.emplace(type,
		::love::StrongRef<::love::Object>(checkCursor(state, -1)));
	lua_pushvalue(state, -1);
	runtime->_systemCursorReferences.emplace(type, luaL_ref(state, LUA_REGISTRYINDEX));
	return 1;
}

int LoveRuntime::mouseSetCursor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	MouseBackend::CursorHandle handle = 0;
	CursorUserdata *cursorObject = nullptr;
	if (!lua_isnoneornil(state, 1))
	{
		auto *cursor = checkCursor(state, 1);
		luaL_argcheck(state, cursor->runtime == runtime && cursor->handle != 0
			&& runtime->_mouseCursorHandles.contains(cursor->handle), 1,
			"Cursor belongs to another or closed LoveRuntime");
		handle = cursor->handle;
		cursorObject = cursor;
	}
	if (runtime->_mouseCursorReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX, runtime->_mouseCursorReference);
	runtime->_mouseCursorReference = LUA_NOREF;
	runtime->_mouseCursor = handle;
	runtime->_mouseCursorObject.set(cursorObject);
	if (handle != 0)
	{
		lua_pushvalue(state, 1);
		runtime->_mouseCursorReference = luaL_ref(state, LUA_REGISTRYINDEX);
	}
	if (runtime->_mouseBackend) runtime->_mouseBackend->setMouseCursor(handle);
	return 0;
}

int LoveRuntime::mouseGetCursor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime->_mouseCursor == 0 || !runtime->_mouseCursorObject)
	{
		lua_pushnil(state);
		return 1;
	}
	::love::luax_pushtype(state, CursorUserdata::type,
		static_cast<CursorUserdata *>(runtime->_mouseCursorObject.get()));
	return 1;
}

int LoveRuntime::mouseIsCursorSupported(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime->_mouseBackend
		&& runtime->_mouseBackend->isMouseCursorSupported());
	return 1;
}

int LoveRuntime::cursorEqual(lua_State *state)
{
	auto *left = testCursor(state, 1);
	auto *right = testCursor(state, 2);
	lua_pushboolean(state, left && right && left->runtime == right->runtime
		&& left->handle != 0 && left->handle == right->handle);
	return 1;
}

int LoveRuntime::cursorGetType(lua_State *state)
{
	auto *cursor = checkCursor(state, 1);
	luaL_argcheck(state, cursor->runtime && cursor->handle != 0
		&& cursor->runtime->_mouseCursorHandles.contains(cursor->handle), 1, "closed Cursor");
	lua_pushlstring(state, cursor->cursorType.data(), cursor->cursorType.size());
	return 1;
}

int LoveRuntime::touchGetTouches(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_createtable(state, static_cast<int>(runtime->_touches.size()), 0);
	lua_Integer index = 1;
	for (const auto &[id, touch] : runtime->_touches)
	{
		(void)touch;
		lua_pushlightuserdata(state, reinterpret_cast<void *>(id));
		lua_seti(state, -2, index++);
	}
	return 1;
}

int LoveRuntime::touchGetPosition(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_argcheck(state, lua_islightuserdata(state, 1), 1, "touch id expected");
	const auto id = reinterpret_cast<std::uintptr_t>(lua_touserdata(state, 1));
	// Lua argument errors use longjmp. Do not keep an MSVC debug iterator alive
	// across that boundary, or the container retains a dangling iterator proxy.
	luaL_argcheck(state, runtime->_touches.contains(id), 1, "invalid touch id");
	const auto &touch = runtime->_touches.at(id);
	lua_pushnumber(state, touch.x);
	lua_pushnumber(state, touch.y);
	return 2;
}

int LoveRuntime::touchGetPressure(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_argcheck(state, lua_islightuserdata(state, 1), 1, "touch id expected");
	const auto id = reinterpret_cast<std::uintptr_t>(lua_touserdata(state, 1));
	luaL_argcheck(state, runtime->_touches.contains(id), 1, "invalid touch id");
	lua_pushnumber(state, runtime->_touches.at(id).pressure);
	return 1;
}

int LoveRuntime::joystickGetJoysticks(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	int count = 0;
	for (const auto &[id, joystick] : runtime->_joysticks)
		if (joystick.connected)
			++count;
	lua_createtable(state, count, 0);
	lua_Integer index = 1;
	for (const auto &[id, joystick] : runtime->_joysticks)
	{
		if (!joystick.connected)
			continue;
		runtime->pushJoystick(id);
		lua_seti(state, -2, index++);
	}
	return 1;
}

int LoveRuntime::joystickGetJoystickCount(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	int count = 0;
	for (const auto &[id, joystick] : runtime->_joysticks)
	{
		(void)id;
		if (joystick.connected)
			++count;
	}
	lua_pushinteger(state, count);
	return 1;
}

int LoveRuntime::joystickSetGamepadMapping(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view guid = luaL_checkstring(state, 1);
	const std::string_view gamepadInput = luaL_checkstring(state, 2);
	luaL_argcheck(state, isGamepadAxisName(gamepadInput) || isGamepadButtonName(gamepadInput),
		2, "invalid gamepad axis/button");
	const std::string_view inputType = luaL_checkstring(state, 3);
	luaL_argcheck(state, inputType == "axis" || inputType == "button" || inputType == "hat",
		3, "invalid joystick input type");
	const int index = static_cast<int>(luaL_checkinteger(state, 4)) - 1;
	std::string_view hat;
	if (inputType == "hat")
	{
		hat = luaL_checkstring(state, 5);
		static constexpr std::array<std::string_view, 9> hats = {
			"c", "u", "r", "d", "l", "ru", "rd", "lu", "ld"};
		luaL_argcheck(state, std::find(hats.begin(), hats.end(), hat) != hats.end(),
			5, "invalid joystick hat");
	}
	std::string error;
	if (!runtime || !runtime->_joystickBackend)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	const bool success = runtime->_joystickBackend->setGamepadMapping(
		guid, gamepadInput, inputType, index, hat, error);
	if (!success && !error.empty()) return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, success);
	return 1;
}

int LoveRuntime::joystickLoadGamepadMappings(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	size_t size = 0;
	const char *input = luaL_checklstring(state, 1, &size);
	std::string mappings(input, size);
	if (runtime && runtime->_filesystemBackend)
	{
		std::string resolved;
		std::string ignored;
		if (runtime->resolveReadPath(mappings, resolved, ignored))
		{
			std::string error;
			if (!runtime->_filesystemBackend->load(resolved, mappings, error))
				return luaL_error(state, "%s", error.c_str());
		}
	}
	if (!runtime || !runtime->_joystickBackend)
		return luaL_error(state, "love.joystick is not attached to a Dora Controller backend");
	std::string error;
	if (!runtime->_joystickBackend->loadGamepadMappings(mappings, error))
		return luaL_error(state, "%s", error.empty() ? "Invalid gamepad mappings" : error.c_str());
	return 0;
}

int LoveRuntime::joystickSaveGamepadMappings(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string mappings = runtime && runtime->_joystickBackend
		? runtime->_joystickBackend->saveGamepadMappings() : std::string{};
	if (!lua_isnoneornil(state, 1) && runtime && runtime->_filesystemBackend)
	{
		const std::string filename = luaL_checkstring(state, 1);
		std::filesystem::path target;
		std::string error;
		if (resolveWritableEntry(runtime, filename, target, false, error)
			&& runtime->_filesystemBackend->isFolder(target.parent_path().string()))
			runtime->_filesystemBackend->save(target.string(), mappings, error);
	}
	lua_pushlstring(state, mappings.data(), mappings.size());
	return 1;
}

int LoveRuntime::joystickGetGamepadMappingString(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view guid = luaL_checkstring(state, 1);
	const std::string mapping = runtime && runtime->_joystickBackend
		? runtime->_joystickBackend->getGamepadMappingString(guid) : std::string{};
	if (mapping.empty()) lua_pushnil(state);
	else lua_pushlstring(state, mapping.data(), mapping.size());
	return 1;
}

int LoveRuntime::joystickEqual(lua_State *state)
{
	auto *left = luaL_testudata(state, 1, JoystickLoveType.getName())
		? ::love::luax_checktype<JoystickUserdata>(state, 1, JoystickLoveType) : nullptr;
	auto *right = luaL_testudata(state, 2, JoystickLoveType.getName())
		? ::love::luax_checktype<JoystickUserdata>(state, 2, JoystickLoveType) : nullptr;
	lua_pushboolean(state, left && right && left->runtime == right->runtime && left->id == right->id);
	return 1;
}

int LoveRuntime::joystickIsConnected(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	lua_pushboolean(state, found != joystick->runtime->_joysticks.end() && found->second.connected);
	return 1;
}

int LoveRuntime::joystickGetName(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	lua_pushlstring(state, found->second.name.data(), found->second.name.size());
	return 1;
}

int LoveRuntime::joystickGetID(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	// Love exposes both identifiers as 1-based values to Lua, but the second is
	// SDL's connection instance ID and becomes nil after disconnection.
	lua_pushinteger(state, joystick->id + 1);
	if (found->second.connected && found->second.info.instanceId >= 0)
		lua_pushinteger(state, found->second.info.instanceId + 1);
	else
		lua_pushnil(state);
	return 2;
}

int LoveRuntime::joystickGetGUID(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	lua_pushlstring(state, found->second.info.guid.data(), found->second.info.guid.size());
	return 1;
}

int LoveRuntime::joystickGetDeviceInfo(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	lua_pushinteger(state, found->second.info.vendorId);
	lua_pushinteger(state, found->second.info.productId);
	lua_pushinteger(state, found->second.info.productVersion);
	return 3;
}

int LoveRuntime::joystickGetAxisCount(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	lua_pushinteger(state, found->second.info.axisCount);
	return 1;
}

int LoveRuntime::joystickGetButtonCount(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	lua_pushinteger(state, found->second.info.buttonCount);
	return 1;
}

int LoveRuntime::joystickGetHatCount(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	lua_pushinteger(state, found->second.info.hatCount);
	return 1;
}

int LoveRuntime::joystickGetAxis(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const int axis = static_cast<int>(luaL_checkinteger(state, 2)) - 1;
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	float value = 0.0f;
	if (found->second.connected && axis >= 0 && axis < found->second.info.axisCount)
	{
		if (joystick->runtime->_joystickBackend)
			value = joystick->runtime->_joystickBackend->getJoystickAxis(joystick->id, axis);
		else
		{
			static constexpr std::array<std::string_view, 6> axes = {
				"leftx", "lefty", "rightx", "righty", "triggerleft", "triggerright"};
			if (axis < static_cast<int>(axes.size()))
			{
				const auto item = found->second.axes.find(std::string(axes[axis]));
				if (item != found->second.axes.end()) value = item->second;
			}
		}
	}
	lua_pushnumber(state, value);
	return 1;
}

int LoveRuntime::joystickGetAxes(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	static constexpr std::array<std::string_view, 6> axes = {
		"leftx", "lefty", "rightx", "righty", "triggerleft", "triggerright"};
	for (int axis = 0; axis < found->second.info.axisCount; ++axis)
	{
		float value = 0.0f;
		if (found->second.connected)
		{
			if (joystick->runtime->_joystickBackend)
				value = joystick->runtime->_joystickBackend->getJoystickAxis(joystick->id, axis);
			else if (axis < static_cast<int>(axes.size()))
			{
				const auto item = found->second.axes.find(std::string(axes[axis]));
				if (item != found->second.axes.end()) value = item->second;
			}
		}
		lua_pushnumber(state, value);
	}
	return found->second.info.axisCount;
}

int LoveRuntime::joystickGetHat(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const int hat = static_cast<int>(luaL_checkinteger(state, 2)) - 1;
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	int value = 0;
	if (found->second.connected && joystick->runtime->_joystickBackend
		&& hat >= 0 && hat < found->second.info.hatCount)
		value = joystick->runtime->_joystickBackend->getJoystickHat(joystick->id, hat);
	const char *direction = "c";
	switch (value)
	{
		case 1: direction = "u"; break;
		case 2: direction = "r"; break;
		case 4: direction = "d"; break;
		case 8: direction = "l"; break;
		case 3: direction = "ru"; break;
		case 6: direction = "rd"; break;
		case 9: direction = "lu"; break;
		case 12: direction = "ld"; break;
		default: break;
	}
	lua_pushstring(state, direction);
	return 1;
}

int LoveRuntime::joystickIsDown(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	const bool table = lua_istable(state, 2);
	const int count = table ? static_cast<int>(lua_rawlen(state, 2)) : lua_gettop(state) - 1;
	luaL_argcheck(state, count > 0, 2, "joystick button expected");
	static constexpr std::array<std::string_view, 15> buttons = {
		"a", "b", "x", "y", "back", "guide", "start", "leftstick", "rightstick",
		"leftshoulder", "rightshoulder", "dpup", "dpdown", "dpleft", "dpright"};
	bool down = false;
	for (int index = 0; index < count; ++index)
	{
		if (table) lua_geti(state, 2, index + 1);
		const int argument = table ? -1 : index + 2;
		if (table && !lua_isinteger(state, -1))
			return luaL_argerror(state, 2, "joystick button table must contain integers");
		const int button = static_cast<int>(table
			? lua_tointeger(state, -1) : luaL_checkinteger(state, argument)) - 1;
		if (table) lua_pop(state, 1);
		if (!found->second.connected || button < 0 || button >= found->second.info.buttonCount)
			continue;
		if (joystick->runtime->_joystickBackend)
			down = down || joystick->runtime->_joystickBackend->isJoystickButtonDown(joystick->id, button);
		else if (button < static_cast<int>(buttons.size()))
			down = down || found->second.buttons.contains(std::string(buttons[button]));
	}
	lua_pushboolean(state, down);
	return 1;
}

int LoveRuntime::joystickIsGamepad(lua_State *state)
{
	(void)checkJoystick(state, 1);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::joystickIsGamepadDown(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	const bool table = lua_istable(state, 2);
	const int count = table ? static_cast<int>(lua_rawlen(state, 2)) : lua_gettop(state) - 1;
	luaL_argcheck(state, count > 0, 2, "gamepad button expected");
	bool down = false;
	for (int index = 0; index < count; ++index)
	{
		if (table) lua_geti(state, 2, index + 1);
		const int argument = table ? -1 : index + 2;
		if (table && !lua_isstring(state, -1))
			return luaL_argerror(state, 2, "gamepad button table must contain strings");
		const std::string_view button = table
			? lua_tostring(state, -1) : luaL_checkstring(state, argument);
		luaL_argcheck(state, isGamepadButtonName(button), table ? 2 : argument, "invalid gamepad button");
		down = down || found->second.buttons.contains(std::string(button));
		if (table) lua_pop(state, 1);
	}
	lua_pushboolean(state, down);
	return 1;
}

int LoveRuntime::joystickGetGamepadAxis(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const std::string_view axis = luaL_checkstring(state, 2);
	luaL_argcheck(state, isGamepadAxisName(axis), 2, "invalid gamepad axis");
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	const auto value = found->second.axes.find(std::string(axis));
	lua_pushnumber(state, value == found->second.axes.end() ? 0.0f : value->second);
	return 1;
}

int LoveRuntime::joystickGetGamepadMapping(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const std::string_view gamepadInput = luaL_checkstring(state, 2);
	luaL_argcheck(state, isGamepadAxisName(gamepadInput) || isGamepadButtonName(gamepadInput),
		2, "invalid gamepad axis/button");
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	if (!found->second.connected || !joystick->runtime->_joystickBackend) return 0;
	const auto mapping = joystick->runtime->_joystickBackend->getJoystickGamepadMapping(
		joystick->id, gamepadInput);
	if (!mapping) return 0;
	lua_pushlstring(state, mapping->inputType.data(), mapping->inputType.size());
	lua_pushinteger(state, mapping->index + 1);
	if (mapping->inputType == "hat")
	{
		lua_pushlstring(state, mapping->hat.data(), mapping->hat.size());
		return 3;
	}
	return 2;
}

int LoveRuntime::joystickGetOwnGamepadMappingString(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	const std::string mapping = found->second.connected && joystick->runtime->_joystickBackend
		? joystick->runtime->_joystickBackend->getJoystickGamepadMappingString(joystick->id)
		: std::string{};
	if (mapping.empty()) lua_pushnil(state);
	else lua_pushlstring(state, mapping.data(), mapping.size());
	return 1;
}

int LoveRuntime::joystickIsVibrationSupported(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	const auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	lua_pushboolean(state, found->second.connected && found->second.info.vibrationSupported);
	return 1;
}

int LoveRuntime::joystickSetVibration(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	float left = 0.0f;
	float right = 0.0f;
	double duration = 0.0;
	if (!lua_isnoneornil(state, 2))
	{
		left = static_cast<float>(luaL_checknumber(state, 2));
		right = static_cast<float>(luaL_optnumber(state, 3, left));
		duration = luaL_optnumber(state, 4, -1.0);
		luaL_argcheck(state, std::isfinite(left), 2, "vibration strength must be finite");
		luaL_argcheck(state, std::isfinite(right), 3, "vibration strength must be finite");
		luaL_argcheck(state, std::isfinite(duration), 4, "vibration duration must be finite");
		left = std::clamp(left, 0.0f, 1.0f);
		right = std::clamp(right, 0.0f, 1.0f);
	}
	const bool success = found->second.connected && found->second.info.vibrationSupported
		&& joystick->runtime->_joystickBackend
		&& joystick->runtime->_joystickBackend->setJoystickVibration(
			joystick->id, left, right, duration);
	if (success)
	{
		found->second.vibrationLeft = left;
		found->second.vibrationRight = right;
		found->second.vibrationEndTime = duration < 0.0 ? -1.0 : steadySeconds() + duration;
	}
	lua_pushboolean(state, success);
	return 1;
}

int LoveRuntime::joystickGetVibration(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	auto found = joystick->runtime->_joysticks.find(joystick->id);
	luaL_argcheck(state, found != joystick->runtime->_joysticks.end(), 1, "invalid Joystick");
	if (found->second.vibrationEndTime > 0.0 && steadySeconds() >= found->second.vibrationEndTime)
	{
		found->second.vibrationLeft = 0.0f;
		found->second.vibrationRight = 0.0f;
		found->second.vibrationEndTime = 0.0;
	}
	lua_pushnumber(state, found->second.vibrationLeft);
	lua_pushnumber(state, found->second.vibrationRight);
	return 2;
}

int LoveRuntime::joystickGetConnectedIndex(lua_State *state)
{
	auto *joystick = checkJoystick(state, 1);
	lua_Integer index = 1;
	for (const auto &[id, value] : joystick->runtime->_joysticks)
	{
		if (!value.connected) continue;
		if (id == joystick->id)
		{
			lua_pushinteger(state, index);
			return 1;
		}
		++index;
	}
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::graphicsRectangle(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool fill = drawMode(state, 1);
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float width = static_cast<float>(luaL_checknumber(state, 4));
	const float height = static_cast<float>(luaL_checknumber(state, 5));
	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (!runtime->_graphicsBackend->validateShaderDraw(error))
			return luaL_error(state, "%s", error.c_str());
		if (runtime->isGraphicsTransformIdentity())
		{
			if (!runtime->_graphicsBackend->rectangle(fill, x, y, width, height,
				runtime->_graphicsLineWidth, runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
				runtime->_graphicsColor[0], runtime->_graphicsColor[1],
				runtime->_graphicsColor[2], runtime->_graphicsColor[3], error))
				return luaL_error(state, "%s", error.c_str());
		}
		else
		{
			if (!runtime->_graphicsBackend->polygon(fill,
				{x, y, x + width, y, x + width, y + height, x, y + height},
				runtime->_graphicsTransform,
				runtime->_graphicsLineWidth, runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
				runtime->_graphicsColor[0], runtime->_graphicsColor[1],
				runtime->_graphicsColor[2], runtime->_graphicsColor[3], error))
				return luaL_error(state, "%s", error.c_str());
		}
	}
	return 0;
}

int LoveRuntime::graphicsCircle(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool fill = drawMode(state, 1);
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float radius = static_cast<float>(luaL_checknumber(state, 4));
	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (!runtime->_graphicsBackend->validateShaderDraw(error))
			return luaL_error(state, "%s", error.c_str());
		if (runtime->isGraphicsTransformIdentity())
		{
			if (!runtime->_graphicsBackend->circle(fill, x, y, radius, runtime->_graphicsLineWidth,
				runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
				runtime->_graphicsColor[0], runtime->_graphicsColor[1], runtime->_graphicsColor[2],
				runtime->_graphicsColor[3], error))
				return luaL_error(state, "%s", error.c_str());
		}
		else
		{
			std::vector<float> vertices;
			vertices.reserve(96);
			for (int i = 0; i < 48; ++i)
			{
				const float angle = static_cast<float>(i) * 2.0f * std::numbers::pi_v<float> / 48.0f;
				vertices.push_back(x + std::cos(angle) * radius);
				vertices.push_back(y + std::sin(angle) * radius);
			}
			if (!runtime->_graphicsBackend->polygon(fill, vertices, runtime->_graphicsTransform,
				runtime->_graphicsLineWidth, runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
				runtime->_graphicsColor[0], runtime->_graphicsColor[1],
				runtime->_graphicsColor[2], runtime->_graphicsColor[3], error))
				return luaL_error(state, "%s", error.c_str());
		}
	}
	return 0;
}

int LoveRuntime::graphicsArc(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool fill = drawMode(state, 1);
	int start = 2;
	std::string_view arcMode = "pie";
	if (lua_type(state, 2) == LUA_TSTRING)
	{
		arcMode = lua_tostring(state, 2);
		if (arcMode != "open" && arcMode != "closed" && arcMode != "pie")
			return luaL_argerror(state, 2, "invalid arc mode");
		start = 3;
	}
	const float x = static_cast<float>(luaL_checknumber(state, start));
	const float y = static_cast<float>(luaL_checknumber(state, start + 1));
	const float radius = static_cast<float>(luaL_checknumber(state, start + 2));
	const float angle1 = static_cast<float>(luaL_checknumber(state, start + 3));
	const float angle2 = static_cast<float>(luaL_checknumber(state, start + 4));
	for (const float value : {x, y, radius, angle1, angle2})
		luaL_argcheck(state, std::isfinite(value), start, "arc arguments must be finite");

	constexpr float tau = 2.0f * std::numbers::pi_v<float>;
	const float angle = std::abs(angle2 - angle1);
	int segments = 0;
	if (lua_isnoneornil(state, start + 5))
	{
		const float scale = std::max(runtime->_graphicsTransform.pixelScale, 0.000001f);
		float points = std::max(std::sqrt(std::abs(radius) * 20.0f * scale), 8.0f);
		if (angle < tau)
			points *= angle / tau;
		segments = static_cast<int>(points + 0.5f);
	}
	else
		segments = static_cast<int>(luaL_checkinteger(state, start + 5));
	if (segments <= 0 || angle1 == angle2)
		return 0;

	if (!runtime->_graphicsBackend)
		return 0;
	std::string error;
	if (!runtime->_graphicsBackend->validateShaderDraw(error))
		return luaL_error(state, "%s", error.c_str());

	std::vector<float> vertices;
	if (angle >= tau)
	{
		vertices.reserve(static_cast<std::size_t>(segments + (fill ? 0 : 1)) * 2);
		for (int index = 0; index < segments; ++index)
		{
			const float phi = static_cast<float>(index) * tau / static_cast<float>(segments);
			vertices.push_back(x + radius * std::cos(phi));
			vertices.push_back(y + radius * std::sin(phi));
		}
		if (!fill)
		{
			vertices.push_back(vertices[0]);
			vertices.push_back(vertices[1]);
		}
	}
	else
	{
		if (!fill && arcMode == "closed" && angle < 4.0f * std::numbers::pi_v<float> / 180.0f)
			arcMode = "open";
		if (fill && arcMode == "open")
			arcMode = "closed";
		vertices.reserve(static_cast<std::size_t>(segments + 3) * 2);
		if (arcMode == "pie")
		{
			vertices.push_back(x);
			vertices.push_back(y);
		}
		const float shift = (angle2 - angle1) / static_cast<float>(segments);
		if (shift == 0.0f)
			return 0;
		for (int index = 0; index <= segments; ++index)
		{
			const float phi = angle1 + static_cast<float>(index) * shift;
			vertices.push_back(x + radius * std::cos(phi));
			vertices.push_back(y + radius * std::sin(phi));
		}
		if (!fill && arcMode == "pie")
		{
			vertices.push_back(x);
			vertices.push_back(y);
		}
		else if (!fill && arcMode == "closed")
		{
			vertices.push_back(vertices[0]);
			vertices.push_back(vertices[1]);
		}
	}

	const bool submitted = fill
		? runtime->_graphicsBackend->polygon(true, vertices, runtime->_graphicsTransform,
			runtime->_graphicsLineWidth, runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1], runtime->_graphicsColor[2],
			runtime->_graphicsColor[3], error)
		: runtime->_graphicsBackend->line(vertices, runtime->_graphicsTransform,
			runtime->_graphicsLineWidth, runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1], runtime->_graphicsColor[2],
			runtime->_graphicsColor[3], error);
	if (!submitted)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::graphicsLine(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int count = lua_gettop(state);
	luaL_argcheck(state, count >= 4 && count % 2 == 0, 1, "expected at least two x/y points");
	std::vector<float> points;
	points.reserve(count);
	for (int i = 1; i <= count; ++i)
		points.push_back(static_cast<float>(luaL_checknumber(state, i)));
	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (!runtime->_graphicsBackend->validateShaderDraw(error))
			return luaL_error(state, "%s", error.c_str());
		if (!runtime->_graphicsBackend->line(points, runtime->_graphicsTransform, runtime->_graphicsLineWidth,
			runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1], runtime->_graphicsColor[2],
			runtime->_graphicsColor[3], error))
			return luaL_error(state, "%s", error.c_str());
	}
	return 0;
}

int LoveRuntime::graphicsEllipse(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool fill = drawMode(state, 1);
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float radiusX = static_cast<float>(luaL_checknumber(state, 4));
	const float radiusY = static_cast<float>(luaL_checknumber(state, 5));
	const int segments = std::max(3, static_cast<int>(luaL_optinteger(state, 6, 48)));
	std::vector<float> vertices;
	vertices.reserve(static_cast<std::size_t>(segments) * 2);
	for (int i = 0; i < segments; ++i)
	{
		const float angle = static_cast<float>(i) * 2.0f * std::numbers::pi_v<float> / static_cast<float>(segments);
		vertices.push_back(x + std::cos(angle) * radiusX);
		vertices.push_back(y + std::sin(angle) * radiusY);
	}
	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (!runtime->_graphicsBackend->validateShaderDraw(error))
			return luaL_error(state, "%s", error.c_str());
		if (!runtime->_graphicsBackend->polygon(fill, vertices, runtime->_graphicsTransform,
			runtime->_graphicsLineWidth, runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3], error))
			return luaL_error(state, "%s", error.c_str());
	}
	return 0;
}

int LoveRuntime::graphicsPolygon(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool fill = drawMode(state, 1);
	const int count = lua_gettop(state) - 1;
	luaL_argcheck(state, count >= 6 && count % 2 == 0, 2, "expected at least three x/y points");
	std::vector<float> vertices;
	vertices.reserve(count);
	for (int i = 2; i <= count + 1; ++i)
		vertices.push_back(static_cast<float>(luaL_checknumber(state, i)));
	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (!runtime->_graphicsBackend->validateShaderDraw(error))
			return luaL_error(state, "%s", error.c_str());
		if (!runtime->_graphicsBackend->polygon(fill, vertices, runtime->_graphicsTransform,
			runtime->_graphicsLineWidth, runtime->_graphicsLineStyle, runtime->_graphicsLineJoin,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3], error))
			return luaL_error(state, "%s", error.c_str());
	}
	return 0;
}

int LoveRuntime::graphicsPoints(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int count = lua_gettop(state);
	luaL_argcheck(state, count >= 2 && count % 2 == 0, 1, "expected one or more x/y points");
	std::vector<float> points;
	points.reserve(count);
	for (int i = 1; i <= count; ++i)
		points.push_back(static_cast<float>(luaL_checknumber(state, i)));
	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (!runtime->_graphicsBackend->validateShaderDraw(error))
			return luaL_error(state, "%s", error.c_str());
		if (!runtime->_graphicsBackend->points(runtime->transformGraphicsPoints(points), runtime->_graphicsPointSize,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1], runtime->_graphicsColor[2],
			runtime->_graphicsColor[3], error))
			return luaL_error(state, "%s", error.c_str());
	}
	return 0;
}

int LoveRuntime::graphicsPresent(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsFrameActive)
		return luaL_error(state,
			"love.graphics.present is only available during the Dora-driven love.draw frame");
	// The embedded host owns the RenderTarget pass boundary. LoveRuntime::draw closes it
	// exactly once after the callback returns, so explicit present calls are compatible
	// barriers without swapping the Dora window or submitting the same pass twice.
	return 0;
}

int LoveRuntime::graphicsPush(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	bool saveAll = false;
	if (!lua_isnoneornil(state, 1))
	{
		const std::string_view stackType = luaL_checkstring(state, 1);
		luaL_argcheck(state, stackType == "transform" || stackType == "all", 1, "expected 'transform' or 'all'");
		saveAll = stackType == "all";
	}
	GraphicsState saved;
	saved.transform = runtime->_graphicsTransform;
	saved.all = saveAll;
	if (saveAll)
	{
		std::copy(std::begin(runtime->_graphicsColor), std::end(runtime->_graphicsColor), saved.color);
		std::copy(std::begin(runtime->_graphicsBackgroundColor),
			std::end(runtime->_graphicsBackgroundColor), saved.backgroundColor);
		saved.defaultFilter = runtime->_graphicsDefaultFilter;
		saved.defaultAnisotropy = runtime->_graphicsDefaultAnisotropy;
		saved.lineWidth = runtime->_graphicsLineWidth;
		saved.lineStyle = runtime->_graphicsLineStyle;
		saved.lineJoin = runtime->_graphicsLineJoin;
		saved.pointSize = runtime->_graphicsPointSize;
		saved.blendMode = runtime->_graphicsBlendMode;
		saved.blendAlphaMode = runtime->_graphicsBlendAlphaMode;
		saved.scissorEnabled = runtime->_graphicsScissorEnabled;
		std::copy(std::begin(runtime->_graphicsScissor), std::end(runtime->_graphicsScissor), saved.scissor);
		std::copy(std::begin(runtime->_graphicsColorMask), std::end(runtime->_graphicsColorMask), saved.colorMask);
		saved.depthCompare = runtime->_graphicsDepthCompare;
		saved.depthWrite = runtime->_graphicsDepthWrite;
		saved.meshCullMode = runtime->_graphicsMeshCullMode;
		saved.frontFaceWinding = runtime->_graphicsFrontFaceWinding;
		saved.wireframe = runtime->_graphicsWireframe;
		saved.canvases = runtime->_graphicsCanvases;
		saved.canvasTargets = runtime->_graphicsCanvasTargets;
		saved.canvasObjects = runtime->_graphicsCanvasObjects;
		saved.canvasDepthStencil = runtime->_graphicsCanvasDepthStencil;
		saved.canvasDepthStencilTarget = runtime->_graphicsCanvasDepthStencilTarget;
		saved.canvasDepthStencilObject = runtime->_graphicsCanvasDepthStencilObject;
		saved.canvasDepth = runtime->_graphicsCanvasDepth;
		saved.canvasStencil = runtime->_graphicsCanvasStencil;
		saved.stencilTestEnabled = runtime->_graphicsStencilTestEnabled;
		saved.stencilCompare = runtime->_graphicsStencilCompare;
		saved.stencilValue = runtime->_graphicsStencilValue;
		saved.shader = runtime->_graphicsShader;
		saved.shaderObject = runtime->_graphicsShaderObject;
		saved.font = runtime->_currentFont;
		saved.fontObject = runtime->_graphicsFontObject;
		if (runtime->_graphicsShaderReference != LUA_NOREF)
		{
			lua_rawgeti(state, LUA_REGISTRYINDEX, runtime->_graphicsShaderReference);
			saved.shaderReference = luaL_ref(state, LUA_REGISTRYINDEX);
		}
		for (const int reference : runtime->_graphicsCanvasReferences)
		{
			lua_rawgeti(state, LUA_REGISTRYINDEX, reference);
			saved.canvasReferences.push_back(luaL_ref(state, LUA_REGISTRYINDEX));
		}
		if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
		{
			lua_rawgeti(state, LUA_REGISTRYINDEX,
				runtime->_graphicsCanvasDepthStencilReference);
			saved.canvasDepthStencilReference = luaL_ref(state, LUA_REGISTRYINDEX);
		}
	}
	runtime->_graphicsStateStack.push_back(saved);
	return 0;
}

int LoveRuntime::graphicsPop(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime->_graphicsStateStack.empty())
		return luaL_error(state, "too many love.graphics.pop calls");
	GraphicsState saved = std::move(runtime->_graphicsStateStack.back());
	runtime->_graphicsStateStack.pop_back();
	runtime->_graphicsTransform = saved.transform;
	if (saved.all)
	{
		std::copy(std::begin(saved.color), std::end(saved.color), runtime->_graphicsColor);
		std::copy(std::begin(saved.backgroundColor), std::end(saved.backgroundColor),
			runtime->_graphicsBackgroundColor);
		runtime->_graphicsDefaultFilter = saved.defaultFilter;
		runtime->_graphicsDefaultAnisotropy = saved.defaultAnisotropy;
		runtime->_graphicsLineWidth = saved.lineWidth;
		runtime->_graphicsLineStyle = saved.lineStyle;
		runtime->_graphicsLineJoin = saved.lineJoin;
		runtime->_graphicsPointSize = saved.pointSize;
		runtime->_graphicsBlendMode = saved.blendMode;
		runtime->_graphicsBlendAlphaMode = saved.blendAlphaMode;
		runtime->_graphicsScissorEnabled = saved.scissorEnabled;
		std::copy(std::begin(saved.scissor), std::end(saved.scissor), runtime->_graphicsScissor);
		std::copy(std::begin(saved.colorMask), std::end(saved.colorMask), runtime->_graphicsColorMask);
		runtime->_graphicsDepthCompare = saved.depthCompare;
		runtime->_graphicsDepthWrite = saved.depthWrite;
		runtime->_graphicsMeshCullMode = saved.meshCullMode;
		runtime->_graphicsFrontFaceWinding = saved.frontFaceWinding;
		runtime->_graphicsWireframe = saved.wireframe;
		if (runtime->_graphicsBackend)
		{
			std::string error;
			if ((saved.canvasTargets != runtime->_graphicsCanvasTargets
				|| saved.canvasDepthStencil != runtime->_graphicsCanvasDepthStencil
				|| saved.canvasDepth != runtime->_graphicsCanvasDepth
				|| saved.canvasStencil != runtime->_graphicsCanvasStencil)
				&& !runtime->_graphicsBackend->setCanvasTargets(saved.canvasTargets,
					saved.canvasDepthStencil != 0 ? &saved.canvasDepthStencilTarget : nullptr,
					saved.canvasDepth, saved.canvasStencil, error))
				return luaL_error(state, "%s", error.c_str());
			if (!runtime->_graphicsBackend->setBlendMode(saved.blendMode, saved.blendAlphaMode, error))
				return luaL_error(state, "%s", error.c_str());
			runtime->_graphicsBackend->setScissor(saved.scissorEnabled,
				saved.scissor[0], saved.scissor[1], saved.scissor[2], saved.scissor[3]);
			runtime->_graphicsBackend->setColorMask(saved.colorMask[0], saved.colorMask[1],
				saved.colorMask[2], saved.colorMask[3]);
			runtime->_graphicsBackend->setDepthMode(saved.depthCompare, saved.depthWrite);
			runtime->_graphicsBackend->setMeshCullMode(saved.meshCullMode, saved.frontFaceWinding);
			runtime->_graphicsBackend->setWireframe(saved.wireframe);
			runtime->_graphicsBackend->setStencilTest(saved.stencilCompare, saved.stencilValue);
			if (saved.shader != runtime->_graphicsShader
				&& !runtime->_graphicsBackend->setShader(saved.shader, error))
				return luaL_error(state, "%s", error.c_str());
		}
		for (const int reference : runtime->_graphicsCanvasReferences)
			luaL_unref(state, LUA_REGISTRYINDEX, reference);
		if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
			luaL_unref(state, LUA_REGISTRYINDEX,
				runtime->_graphicsCanvasDepthStencilReference);
		runtime->_graphicsCanvases = std::move(saved.canvases);
		runtime->_graphicsCanvasTargets = std::move(saved.canvasTargets);
		runtime->_graphicsCanvasObjects = std::move(saved.canvasObjects);
		runtime->_graphicsCanvasReferences = std::move(saved.canvasReferences);
		runtime->_graphicsCanvasDepthStencil = saved.canvasDepthStencil;
		runtime->_graphicsCanvasDepthStencilTarget = saved.canvasDepthStencilTarget;
		runtime->_graphicsCanvasDepthStencilObject = std::move(saved.canvasDepthStencilObject);
		runtime->_graphicsCanvasDepthStencilReference = saved.canvasDepthStencilReference;
		runtime->_graphicsCanvasDepth = saved.canvasDepth;
		runtime->_graphicsCanvasStencil = saved.canvasStencil;
		runtime->_graphicsStencilTestEnabled = saved.stencilTestEnabled;
		runtime->_graphicsStencilCompare = std::move(saved.stencilCompare);
		runtime->_graphicsStencilValue = saved.stencilValue;
		if (runtime->_graphicsShaderReference != LUA_NOREF)
			luaL_unref(state, LUA_REGISTRYINDEX, runtime->_graphicsShaderReference);
		runtime->_graphicsShader = saved.shader;
		runtime->_graphicsShaderObject = std::move(saved.shaderObject);
		runtime->_graphicsShaderReference = saved.shaderReference;
		runtime->_currentFont = saved.font;
		runtime->_graphicsFontObject = std::move(saved.fontObject);
	}
	return 0;
}

int LoveRuntime::graphicsGetStackDepth(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(runtimeFromUpvalue(state)->_graphicsStateStack.size()));
	return 1;
}

int LoveRuntime::graphicsOrigin(lua_State *state)
{
	runtimeFromUpvalue(state)->resetGraphicsTransform();
	return 0;
}

int LoveRuntime::graphicsTranslate(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	runtime->multiplyGraphicsTransform(1.0f, 0.0f, 0.0f, 1.0f,
		static_cast<float>(luaL_checknumber(state, 1)), static_cast<float>(luaL_checknumber(state, 2)));
	return 0;
}

int LoveRuntime::graphicsRotate(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float angle = static_cast<float>(luaL_checknumber(state, 1));
	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	runtime->multiplyGraphicsTransform(cosine, sine, -sine, cosine, 0.0f, 0.0f);
	return 0;
}

int LoveRuntime::graphicsScale(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float scaleX = static_cast<float>(luaL_checknumber(state, 1));
	const float scaleY = static_cast<float>(luaL_optnumber(state, 2, scaleX));
	runtime->multiplyGraphicsTransform(scaleX, 0.0f, 0.0f, scaleY, 0.0f, 0.0f);
	runtime->_graphicsTransform.pixelScale *= (std::abs(scaleX) + std::abs(scaleY)) * 0.5f;
	return 0;
}

int LoveRuntime::graphicsShear(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float shearX = static_cast<float>(luaL_checknumber(state, 1));
	const float shearY = static_cast<float>(luaL_checknumber(state, 2));
	runtime->multiplyGraphicsTransform(1.0f, shearY, shearX, 1.0f, 0.0f, 0.0f);
	return 0;
}

int LoveRuntime::graphicsApplyTransform(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const auto *transform = checkTransform(state, 1);
	luaL_argcheck(state, isAffine2DTransform(*transform), 1,
		"embedded Dora graphics currently requires an affine 2D Transform");
	runtime->multiplyGraphicsTransform(transform->elements[0], transform->elements[1],
		transform->elements[4], transform->elements[5],
		transform->elements[12], transform->elements[13]);
	runtime->_graphicsTransform.pixelScale = (std::hypot(runtime->_graphicsTransform.a,
		runtime->_graphicsTransform.b) + std::hypot(runtime->_graphicsTransform.c,
		runtime->_graphicsTransform.d)) * 0.5f;
	return 0;
}

int LoveRuntime::graphicsReplaceTransform(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const auto *transform = checkTransform(state, 1);
	luaL_argcheck(state, isAffine2DTransform(*transform), 1,
		"embedded Dora graphics currently requires an affine 2D Transform");
	runtime->_graphicsTransform = {transform->elements[0], transform->elements[1],
		transform->elements[4], transform->elements[5],
		transform->elements[12], transform->elements[13]};
	runtime->_graphicsTransform.pixelScale = (std::hypot(runtime->_graphicsTransform.a,
		runtime->_graphicsTransform.b) + std::hypot(runtime->_graphicsTransform.c,
		runtime->_graphicsTransform.d)) * 0.5f;
	return 0;
}

int LoveRuntime::graphicsTransformPoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	lua_pushnumber(state, runtime->_graphicsTransform.a * x
		+ runtime->_graphicsTransform.c * y + runtime->_graphicsTransform.tx);
	lua_pushnumber(state, runtime->_graphicsTransform.b * x
		+ runtime->_graphicsTransform.d * y + runtime->_graphicsTransform.ty);
	return 2;
}

int LoveRuntime::graphicsInverseTransformPoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1)) - runtime->_graphicsTransform.tx;
	const float y = static_cast<float>(luaL_checknumber(state, 2)) - runtime->_graphicsTransform.ty;
	const float determinant = runtime->_graphicsTransform.a * runtime->_graphicsTransform.d
		- runtime->_graphicsTransform.b * runtime->_graphicsTransform.c;
	if (determinant == 0.0f)
		return luaL_error(state, "Cannot invert the current singular graphics Transform.");
	lua_pushnumber(state, (runtime->_graphicsTransform.d * x - runtime->_graphicsTransform.c * y)
		/ determinant);
	lua_pushnumber(state, (-runtime->_graphicsTransform.b * x + runtime->_graphicsTransform.a * y)
		/ determinant);
	return 2;
}

int LoveRuntime::graphicsIsActive(lua_State *state)
{
	lua_pushboolean(state, runtimeFromUpvalue(state)->_graphicsBackend != nullptr);
	return 1;
}

int LoveRuntime::graphicsIsCreated(lua_State *state)
{
	lua_pushboolean(state, runtimeFromUpvalue(state)->_graphicsBackend != nullptr);
	return 1;
}

int LoveRuntime::graphicsIsGammaCorrect(lua_State *state)
{
	lua_pushboolean(state, false);
	return 1;
}

int LoveRuntime::graphicsReset(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (runtime->_graphicsStencilWriting)
			runtime->_graphicsBackend->endStencilWrite();
		if (!runtime->_graphicsBackend->setCanvases({}, 0, false, false, error))
			return luaL_error(state, "%s", error.c_str());
		if (!runtime->_graphicsBackend->setShader(0, error))
			return luaL_error(state, "%s", error.c_str());
		if (!runtime->_graphicsBackend->setBlendMode("alpha", "alphamultiply", error))
			return luaL_error(state, "%s", error.c_str());
		runtime->_graphicsBackend->setScissor(false, 0.0f, 0.0f, 0.0f, 0.0f);
		runtime->_graphicsBackend->setColorMask(true, true, true, true);
		runtime->_graphicsBackend->setDepthMode("always", false);
		runtime->_graphicsBackend->setMeshCullMode("none", "ccw");
		runtime->_graphicsBackend->setWireframe(false);
		runtime->_graphicsBackend->setStencilTest("always", 0);
	}
	for (const int reference : runtime->_graphicsCanvasReferences)
		luaL_unref(state, LUA_REGISTRYINDEX, reference);
	runtime->_graphicsCanvasReferences.clear();
	runtime->_graphicsCanvasObjects.clear();
	runtime->_graphicsCanvases.clear();
	runtime->_graphicsCanvasTargets.clear();
	if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX,
			runtime->_graphicsCanvasDepthStencilReference);
	runtime->_graphicsCanvasDepthStencil = 0;
	runtime->_graphicsCanvasDepthStencilTarget = {};
	runtime->_graphicsCanvasDepthStencilObject.set(nullptr);
	runtime->_graphicsCanvasDepthStencilReference = LUA_NOREF;
	runtime->_graphicsCanvasDepth = false;
	runtime->_graphicsCanvasStencil = false;
	if (runtime->_graphicsShaderReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX, runtime->_graphicsShaderReference);
	runtime->_graphicsShaderReference = LUA_NOREF;
	runtime->_graphicsShader = 0;
	runtime->_graphicsShaderObject.set(nullptr);
	runtime->_graphicsStencilWriting = false;
	runtime->_graphicsStencilTestEnabled = false;
	runtime->_graphicsStencilCompare = "always";
	runtime->_graphicsStencilValue = 0;
	runtime->_graphicsColor[0] = runtime->_graphicsColor[1]
		= runtime->_graphicsColor[2] = runtime->_graphicsColor[3] = 1.0f;
	runtime->_graphicsBackgroundColor[0] = runtime->_graphicsBackgroundColor[1]
		= runtime->_graphicsBackgroundColor[2] = 0.0f;
	runtime->_graphicsBackgroundColor[3] = 1.0f;
	runtime->_graphicsDefaultFilter = GraphicsBackend::TextureFilter::Linear;
	runtime->_graphicsDefaultAnisotropy = 1.0f;
	runtime->_graphicsDefaultMipmapFilter.reset();
	runtime->_graphicsDefaultMipmapSharpness = 0.0f;
	runtime->_graphicsLineWidth = 1.0f;
	runtime->_graphicsLineStyle = GraphicsBackend::LineStyle::Smooth;
	runtime->_graphicsLineJoin = GraphicsBackend::LineJoin::Miter;
	runtime->_graphicsPointSize = 1.0f;
	runtime->_graphicsBlendMode = "alpha";
	runtime->_graphicsBlendAlphaMode = "alphamultiply";
	runtime->_graphicsScissorEnabled = false;
	std::fill(std::begin(runtime->_graphicsScissor), std::end(runtime->_graphicsScissor), 0.0f);
	std::fill(std::begin(runtime->_graphicsColorMask), std::end(runtime->_graphicsColorMask), true);
	runtime->_graphicsDepthCompare = "always";
	runtime->_graphicsDepthWrite = false;
	runtime->_graphicsMeshCullMode = "none";
	runtime->_graphicsFrontFaceWinding = "ccw";
	runtime->_graphicsWireframe = false;
	runtime->_currentFont = 0;
	runtime->_graphicsFontObject.set(nullptr);
	runtime->resetGraphicsTransform();
	return 0;
}

int LoveRuntime::graphicsNewImage(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	std::string error;
	GraphicsBackend::ImageHandle handle = 0;
	std::string filename;
	int createdMipmapCount = 1;
	std::string createdFormat = "rgba8";
	bool createdCompressed = false;
	bool createdLinear = true;
	float createdDPIScale = 1.0f;
	bool dpiScaleSet = false;
	bool mipmaps = false;
	if (lua_istable(state, 2))
	{
		lua_getfield(state, 2, "mipmaps");
		if (!lua_isnil(state, -1))
		{
			luaL_argcheck(state, lua_isboolean(state, -1), 2,
				"Image mipmaps setting must be a boolean");
			mipmaps = lua_toboolean(state, -1);
		}
		lua_pop(state, 1);
		lua_getfield(state, 2, "linear");
		if (!lua_isnil(state, -1))
		{
			luaL_argcheck(state, lua_isboolean(state, -1), 2, "Image linear setting must be a boolean");
			createdLinear = lua_toboolean(state, -1);
		}
		lua_pop(state, 1);
		lua_getfield(state, 2, "dpiscale");
		if (!lua_isnil(state, -1))
		{
			createdDPIScale = static_cast<float>(luaL_checknumber(state, -1));
			luaL_argcheck(state, std::isfinite(createdDPIScale) && createdDPIScale > 0.0f, 2,
				"Image dpiscale must be positive and finite");
			dpiScaleSet = true;
		}
		lua_pop(state, 1);
	}
	else if (!lua_isnoneornil(state, 2))
		luaL_checktype(state, 2, LUA_TTABLE);
	auto applyFilenameDPIScale = [&](std::string_view sourceName) {
		if (dpiScaleSet) return;
		if (const auto inferred = imageDPIScaleFromFilename(sourceName))
			createdDPIScale = *inferred;
	};
	if (lua_istable(state, 1))
	{
		const int levelCount = static_cast<int>(lua_rawlen(state, 1));
		luaL_argcheck(state, levelCount > 0, 1, "Image mipmap table must not be empty");
		std::vector<GraphicsBackend::ImageLevel> levels;
		levels.reserve(static_cast<std::size_t>(levelCount));
		int baseWidth = 0;
		int baseHeight = 0;
		for (int mip = 0; mip < levelCount; ++mip)
		{
			lua_rawgeti(state, 1, mip + 1);
			int width = 0;
			int height = 0;
			std::vector<std::uint8_t> rgba8;
			std::string sourceName;
			std::string decodeError;
			if (!decodeUncompressedImageSource(state, -1, runtime, width, height,
				rgba8, sourceName, decodeError))
				return luaL_error(state, "Image mipmap level %d decode failed: %s",
					mip + 1, decodeError.c_str());
			if (mip == 0) applyFilenameDPIScale(sourceName);
			if (mip == 0)
			{
				baseWidth = width;
				baseHeight = height;
				luaL_argcheck(state, levelCount == 1
					|| levelCount == totalImageMipmapCount(baseWidth, baseHeight), 1,
					"Image must provide either only the base level or a complete mipmap chain");
			}
			luaL_argcheck(state, width == std::max(1, baseWidth >> mip)
				&& height == std::max(1, baseHeight >> mip), 1,
				"Image mipmap dimensions must halve at each level");
			GraphicsBackend::ImageLevel level;
			level.width = width;
			level.height = height;
			level.slices = 1;
			level.rgba8 = std::move(rgba8);
			levels.push_back(std::move(level));
			lua_pop(state, 1);
		}
		if (mipmaps) generateImageMipmaps(levels, GraphicsBackend::TextureType::Texture2D);
		createdMipmapCount = static_cast<int>(levels.size());
		handle = runtime->_graphicsBackend->newImage(GraphicsBackend::TextureType::Texture2D,
			levels, error);
	}
	else if (auto *data = testImageData(state, 1))
	{
		luaL_argcheck(state, data->runtime == runtime, 1,
			"ImageData belongs to another LoveRuntime");
		std::vector<std::uint8_t> rgba8;
		imageDataToRGBA8(*data, rgba8);
		GraphicsBackend::ImageLevel level{data->width, data->height, 1, std::move(rgba8)};
		std::vector<GraphicsBackend::ImageLevel> levels{std::move(level)};
		if (mipmaps) generateImageMipmaps(levels, GraphicsBackend::TextureType::Texture2D);
		createdMipmapCount = static_cast<int>(levels.size());
		handle = runtime->_graphicsBackend->newImage(GraphicsBackend::TextureType::Texture2D,
			levels, error);
	}
	else if (auto *data = testCompressedImageData(state, 1))
	{
		luaL_argcheck(state, !data->image.levels.empty(), 1,
			"CompressedImageData has no mipmap levels");
		const auto &base = data->image.levels.front();
		const int mipmapCount = mipmaps ? static_cast<int>(data->image.levels.size()) : 1;
		createdMipmapCount = mipmapCount;
		createdFormat = data->image.format;
		createdCompressed = true;
		std::span<const std::uint8_t> bytes = mipmaps
			? std::span<const std::uint8_t>(data->bytes)
			: std::span<const std::uint8_t>(base.bytes);
		handle = runtime->_graphicsBackend->newCompressedImage(data->image.format,
			base.width, base.height, mipmapCount, bytes, error);
		if (handle == 0)
			filename = "CompressedImageData(" + data->image.format + ")";
	}
	else if (DataSpan encoded; getDataSpan(state, 1, encoded))
	{
		if (!runtime->_imageBackend)
			return luaL_error(state, "Love Image Data input requires the Dora image backend");
		if (auto *fileData = testFileData(state, 1))
		{
			filename = fileData->filename;
			applyFilenameDPIScale(fileData->filename);
		}
		else filename = "Data";
		const char *encodedBytes = encoded.size == 0
			? "" : reinterpret_cast<const char *>(encoded.bytes);
		const std::string_view bytes(encodedBytes, encoded.size);
		ImageBackend::CompressedImage compressed;
		std::string compressedError;
		const bool isCompressed = runtime->_imageBackend->decodeCompressedImage(
			bytes, compressed, compressedError) && !compressed.format.empty()
			&& !compressed.levels.empty() && compressed.levels.front().width > 0
			&& compressed.levels.front().height > 0;
		if (isCompressed)
		{
			const int mipmapCount = mipmaps ? static_cast<int>(compressed.levels.size()) : 1;
			std::vector<std::uint8_t> compressedBytes;
			for (int index = 0; index < mipmapCount; ++index)
			{
				luaL_argcheck(state, !compressed.levels[static_cast<std::size_t>(index)].bytes.empty(), 1,
					"compressed Image Data contains an empty mipmap level");
				const auto &level = compressed.levels[static_cast<std::size_t>(index)].bytes;
				compressedBytes.insert(compressedBytes.end(), level.begin(), level.end());
			}
			const auto &base = compressed.levels.front();
			handle = runtime->_graphicsBackend->newCompressedImage(compressed.format,
				base.width, base.height, mipmapCount, compressedBytes, error);
			createdMipmapCount = mipmapCount;
			createdFormat = compressed.format;
			createdCompressed = true;
		}
		else
		{
			int width = 0;
			int height = 0;
			std::vector<std::uint8_t> rgba8;
			if (!runtime->_imageBackend->decodeImage(bytes, width, height, rgba8, error))
				return luaL_error(state, "Love Image '%s' decode failed: %s", filename.c_str(),
					error.empty() ? compressedError.c_str() : error.c_str());
			GraphicsBackend::ImageLevel level{width, height, 1, std::move(rgba8)};
			std::vector<GraphicsBackend::ImageLevel> levels{std::move(level)};
			if (mipmaps) generateImageMipmaps(levels, GraphicsBackend::TextureType::Texture2D);
			createdMipmapCount = static_cast<int>(levels.size());
			handle = runtime->_graphicsBackend->newImage(GraphicsBackend::TextureType::Texture2D,
				levels, error);
		}
	}
	else
	{
		filename = luaL_checkstring(state, 1);
		applyFilenameDPIScale(filename);
		if (!mipmaps)
			handle = runtime->_graphicsBackend->newImage(filename, error);
		else
		{
			if (!runtime->_imageBackend || !runtime->_filesystemBackend)
				return luaL_error(state, "Love filename Image mipmaps require Dora image and filesystem backends");
			std::string resolved;
			std::string encoded;
			if (!runtime->resolveReadPath(filename, resolved, error)
				|| !runtime->_filesystemBackend->load(resolved, encoded, error))
				return luaL_error(state, "Love Image '%s' load failed: %s", filename.c_str(), error.c_str());
			int width = 0;
			int height = 0;
			std::vector<std::uint8_t> rgba8;
			if (!runtime->_imageBackend->decodeImage(encoded, width, height, rgba8, error))
				return luaL_error(state, "Love Image '%s' decode failed: %s", filename.c_str(), error.c_str());
			GraphicsBackend::ImageLevel level{width, height, 1, std::move(rgba8)};
			std::vector<GraphicsBackend::ImageLevel> levels{std::move(level)};
			generateImageMipmaps(levels, GraphicsBackend::TextureType::Texture2D);
			createdMipmapCount = static_cast<int>(levels.size());
			handle = runtime->_graphicsBackend->newImage(GraphicsBackend::TextureType::Texture2D,
				levels, error);
		}
	}
	if (handle == 0)
	{
		if (filename.empty())
			return luaL_error(state, "Love Image creation failed: %s",
				error.empty() ? "failed to create Love Image" : error.c_str());
		return luaL_error(state, "Love Image '%s' creation failed: %s", filename.c_str(),
			error.empty() ? "failed to create Love Image" : error.c_str());
	}
	auto *image = new ImageUserdata(runtime, handle, GraphicsBackend::TextureType::Texture2D, 1);
	image->filter = runtime->_graphicsDefaultFilter;
	image->magFilter = runtime->_graphicsDefaultFilter;
	image->anisotropy = runtime->_graphicsDefaultAnisotropy;
	image->mipmapCount = createdMipmapCount;
	image->format = std::move(createdFormat);
	image->compressed = createdCompressed;
	image->linear = createdLinear;
	image->dpiScale = createdDPIScale;
	if (image->mipmapCount > 1)
	{
		image->mipmapFilter = runtime->_graphicsDefaultMipmapFilter;
		image->mipmapSharpness = runtime->_graphicsDefaultMipmapSharpness;
	}
	pushNewDoraHandleObject(state, ImageUserdata::type, image);
	return 1;
}

int newLayeredImage(lua_State *state, LoveRuntime *runtime,
	GraphicsBackend::TextureType type, const char *label)
{
	auto *graphics = runtime->getGraphicsBackend();
	if (!graphics)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	const bool sourceIsTable = lua_istable(state, 1);
	const int count = sourceIsTable ? static_cast<int>(lua_rawlen(state, 1)) : 1;
	if (sourceIsTable)
		luaL_argcheck(state, count > 0, 1, "Image data table must not be empty");
	bool linear = true;
	float dpiScale = 1.0f;
	bool mipmapsRequested = false;
	bool dpiScaleResolved = false;
	if (!lua_isnoneornil(state, 2))
	{
		luaL_checktype(state, 2, LUA_TTABLE);
		lua_getfield(state, 2, "mipmaps");
		if (!lua_isnil(state, -1))
		{
			luaL_argcheck(state, lua_isboolean(state, -1), 2,
				"Image mipmaps setting must be a boolean");
			mipmapsRequested = lua_toboolean(state, -1);
		}
		lua_pop(state, 1);
		lua_getfield(state, 2, "linear");
		if (!lua_isnil(state, -1))
		{
			luaL_argcheck(state, lua_isboolean(state, -1), 2,
				"Image linear setting must be a boolean");
			linear = lua_toboolean(state, -1);
		}
		lua_pop(state, 1);
		lua_getfield(state, 2, "dpiscale");
		if (!lua_isnil(state, -1))
		{
			dpiScale = static_cast<float>(luaL_checknumber(state, -1));
			luaL_argcheck(state, std::isfinite(dpiScale) && dpiScale > 0.0f, 2,
				"Image dpiscale must be positive and finite");
			dpiScaleResolved = true;
		}
		lua_pop(state, 1);
	}
	auto isCompressedLeaf = [&]() {
		if (!sourceIsTable) return testCompressedImageData(state, 1) != nullptr;
		lua_rawgeti(state, 1, 1);
		if (lua_istable(state, -1)) lua_rawgeti(state, -1, 1);
		const bool compressed = testCompressedImageData(state, -1) != nullptr;
		lua_settop(state, 2);
		return compressed;
	};
	if (isCompressedLeaf())
	{
		std::vector<GraphicsBackend::CompressedImageLevel> compressedLevels;
		std::string compressedFormat;
		auto resizeCompressedLevels = [&](int count) {
			compressedLevels.resize(static_cast<std::size_t>(count));
			for (auto &level : compressedLevels) level.slices = 0;
		};
		auto appendCompressed = [&](CompressedImageDataUserdata *data, int sourceMip,
			GraphicsBackend::CompressedImageLevel &level) {
			luaL_argcheck(state, data != nullptr, 1,
				"compressed and uncompressed Image data cannot be mixed");
			luaL_argcheck(state, sourceMip >= 0
				&& sourceMip < static_cast<int>(data->image.levels.size()), 1,
				"CompressedImageData mipmap level is missing");
			if (compressedFormat.empty()) compressedFormat = data->image.format;
			luaL_argcheck(state, data->image.format == compressedFormat, 1,
				"all compressed Image slices must use the same format");
			const auto &source = data->image.levels[static_cast<std::size_t>(sourceMip)];
			if (level.width == 0) { level.width = source.width; level.height = source.height; }
			luaL_argcheck(state, level.width == source.width && level.height == source.height, 1,
				"all compressed Image slices in a mipmap level must have identical dimensions");
			level.bytes.insert(level.bytes.end(), source.bytes.begin(), source.bytes.end());
			++level.slices;
		};
		if (!sourceIsTable)
		{
			auto *data = testCompressedImageData(state, 1);
			const int mipCount = mipmapsRequested
				? static_cast<int>(data->image.levels.size()) : 1;
			resizeCompressedLevels(mipCount);
			for (int mip = 0; mip < mipCount; ++mip)
				appendCompressed(data, mip, compressedLevels[static_cast<std::size_t>(mip)]);
		}
		else
		{
			lua_rawgeti(state, 1, 1);
			const bool compressedNested = lua_istable(state, -1);
			lua_pop(state, 1);
			if (!compressedNested)
			{
				if (type == GraphicsBackend::TextureType::Cube)
					luaL_argcheck(state, count == 6, 1, "CubeImage requires exactly six faces");
				int mipCount = 1;
				if (mipmapsRequested)
				{
					lua_rawgeti(state, 1, 1);
					mipCount = static_cast<int>(checkCompressedImageData(state, -1)->image.levels.size());
					lua_pop(state, 1);
				}
				resizeCompressedLevels(mipCount);
				for (int slice = 1; slice <= count; ++slice)
				{
					lua_rawgeti(state, 1, slice);
					auto *data = testCompressedImageData(state, -1);
					luaL_argcheck(state, data && (!mipmapsRequested
						|| static_cast<int>(data->image.levels.size()) == mipCount), 1,
						"all compressed Image slices must have the same mipmap count");
					for (int mip = 0; mip < mipCount; ++mip)
						appendCompressed(data, mip, compressedLevels[static_cast<std::size_t>(mip)]);
					lua_pop(state, 1);
				}
			}
			else if (type == GraphicsBackend::TextureType::Volume)
			{
				resizeCompressedLevels(count);
				for (int mip = 1; mip <= count; ++mip)
				{
					lua_rawgeti(state, 1, mip);
					const int slices = static_cast<int>(lua_rawlen(state, -1));
					for (int slice = 1; slice <= slices; ++slice)
					{
						lua_rawgeti(state, -1, slice);
						appendCompressed(testCompressedImageData(state, -1), 0,
							compressedLevels[static_cast<std::size_t>(mip - 1)]);
						lua_pop(state, 1);
					}
					lua_pop(state, 1);
				}
			}
			else
			{
				if (type == GraphicsBackend::TextureType::Cube)
					luaL_argcheck(state, count == 6, 1, "CubeImage requires exactly six faces");
				int mipCount = 0;
				for (int slice = 1; slice <= count; ++slice)
				{
					lua_rawgeti(state, 1, slice);
					const int sliceMipCount = static_cast<int>(lua_rawlen(state, -1));
					if (slice == 1)
					{
						mipCount = sliceMipCount;
						resizeCompressedLevels(mipCount);
					}
					luaL_argcheck(state, sliceMipCount == mipCount && mipCount > 0, 1,
						"all compressed Image slices must have the same mipmap count");
					for (int mip = 1; mip <= mipCount; ++mip)
					{
						lua_rawgeti(state, -1, mip);
						appendCompressed(testCompressedImageData(state, -1), 0,
							compressedLevels[static_cast<std::size_t>(mip - 1)]);
						lua_pop(state, 1);
					}
					lua_pop(state, 1);
				}
			}
		}
		const int slices = compressedLevels.front().slices;
		if (type == GraphicsBackend::TextureType::Cube)
			luaL_argcheck(state, slices == 6, 1, "CubeImage requires exactly six faces");
		std::string error;
		const auto handle = graphics->newCompressedImage(type, compressedFormat,
			compressedLevels, error);
		if (handle == 0)
			return luaL_error(state, "%s creation failed: %s", label,
				error.empty() ? "failed to create compressed non-2D Image" : error.c_str());
		auto *image = new ImageUserdata(runtime, handle, type, slices);
		image->filter = runtime->getGraphicsDefaultFilter();
		image->magFilter = runtime->getGraphicsDefaultFilter();
		image->anisotropy = runtime->getGraphicsDefaultAnisotropy();
		image->mipmapCount = static_cast<int>(compressedLevels.size());
		image->format = compressedFormat;
		image->compressed = true;
		image->linear = linear;
		image->dpiScale = dpiScale;
		if (image->mipmapCount > 1)
		{
			image->mipmapFilter = runtime->getGraphicsDefaultMipmapFilter();
			image->mipmapSharpness = runtime->getGraphicsDefaultMipmapSharpness();
		}
		pushNewDoraHandleObject(state, ImageUserdata::type, image);
		return 1;
	}
	auto appendData = [&](int stackIndex, GraphicsBackend::ImageLevel &level,
		int expectedWidth, int expectedHeight) {
		int width = 0;
		int height = 0;
		std::vector<std::uint8_t> rgba8;
		std::string sourceName;
		std::string decodeError;
		if (!decodeUncompressedImageSource(state, stackIndex, runtime, width, height,
			rgba8, sourceName, decodeError))
			luaL_error(state, "non-2D Image data decode failed: %s", decodeError.c_str());
		if (!dpiScaleResolved)
			if (const auto inferred = imageDPIScaleFromFilename(sourceName))
			{
				dpiScale = *inferred;
				dpiScaleResolved = true;
			}
		if (expectedWidth > 0)
			luaL_argcheck(state, width == expectedWidth && height == expectedHeight, 1,
				"non-2D Image data has inconsistent dimensions");
		if (level.width == 0)
		{
			level.width = width;
			level.height = height;
		}
		else luaL_argcheck(state, width == level.width && height == level.height, 1,
			"all slices in an Image mipmap level must have identical dimensions");
		level.rgba8.insert(level.rgba8.end(), rgba8.begin(), rgba8.end());
		++level.slices;
	};
	std::vector<GraphicsBackend::ImageLevel> levels;
	bool nested = false;
	if (sourceIsTable)
	{
		lua_rawgeti(state, 1, 1);
		nested = lua_istable(state, -1);
		lua_pop(state, 1);
	}
	if (!sourceIsTable)
	{
		GraphicsBackend::ImageLevel source;
		source.slices = 0;
		appendData(1, source, 0, 0);
		GraphicsBackend::ImageLevel split;
		std::string splitError;
		if (type == GraphicsBackend::TextureType::Cube)
		{
			if (!splitCubeImage(source, split, splitError))
				return luaL_error(state, "%s", splitError.c_str());
			levels.push_back(std::move(split));
		}
		else if (type == GraphicsBackend::TextureType::Volume)
		{
			if (!splitVolumeImage(source, split, splitError))
				return luaL_error(state, "%s", splitError.c_str());
			levels.push_back(std::move(split));
		}
		else levels.push_back(std::move(source));
	}
	else if (!nested)
	{
		if (type == GraphicsBackend::TextureType::Cube)
			luaL_argcheck(state, count == 6, 1, "CubeImage requires exactly six faces");
		GraphicsBackend::ImageLevel level;
		level.slices = 0;
		for (int index = 1; index <= count; ++index)
		{
			lua_rawgeti(state, 1, index);
			appendData(-1, level, 0, 0);
			lua_pop(state, 1);
		}
		levels.push_back(std::move(level));
	}
	else if (type == GraphicsBackend::TextureType::Volume)
	{
		int baseWidth = 0;
		int baseHeight = 0;
		int baseDepth = 0;
		for (int mip = 0; mip < count; ++mip)
		{
			lua_rawgeti(state, 1, mip + 1);
			const int slices = static_cast<int>(lua_rawlen(state, -1));
			if (mip == 0) baseDepth = slices;
			luaL_argcheck(state, slices == std::max(1, baseDepth >> mip), 1,
				"VolumeImage depth must halve at each mipmap level");
			GraphicsBackend::ImageLevel level;
			level.slices = 0;
			for (int slice = 1; slice <= slices; ++slice)
			{
				lua_rawgeti(state, -1, slice);
				appendData(-1, level, mip == 0 ? 0 : std::max(1, baseWidth >> mip),
					mip == 0 ? 0 : std::max(1, baseHeight >> mip));
				lua_pop(state, 1);
			}
			if (mip == 0)
			{
				baseWidth = level.width;
				baseHeight = level.height;
			}
			levels.push_back(std::move(level));
			lua_pop(state, 1);
		}
	}
	else
	{
		const int slices = count;
		if (type == GraphicsBackend::TextureType::Cube)
			luaL_argcheck(state, slices == 6, 1, "CubeImage requires exactly six faces");
		int mipCount = 0;
		int baseWidth = 0;
		int baseHeight = 0;
		for (int slice = 1; slice <= slices; ++slice)
		{
			lua_rawgeti(state, 1, slice);
			const int sliceMipCount = static_cast<int>(lua_rawlen(state, -1));
			if (slice == 1)
			{
				mipCount = sliceMipCount;
				luaL_argcheck(state, mipCount > 0, 1, "Image mipmap table must not be empty");
				levels.resize(static_cast<std::size_t>(mipCount));
				for (auto &level : levels) level.slices = 0;
			}
			else luaL_argcheck(state, sliceMipCount == mipCount, 1,
				"all Image slices must have the same mipmap count");
			for (int mip = 0; mip < mipCount; ++mip)
			{
				lua_rawgeti(state, -1, mip + 1);
				appendData(-1, levels[static_cast<std::size_t>(mip)],
					mip == 0 || baseWidth == 0 ? 0 : std::max(1, baseWidth >> mip),
					mip == 0 || baseHeight == 0 ? 0 : std::max(1, baseHeight >> mip));
				if (slice == 1 && mip == 0)
				{
					baseWidth = levels.front().width;
					baseHeight = levels.front().height;
				}
				lua_pop(state, 1);
			}
			lua_pop(state, 1);
		}
	}
	if (mipmapsRequested) generateImageMipmaps(levels, type);
	const int width = levels.front().width;
	const int height = levels.front().height;
	const int slices = levels.front().slices;
	luaL_argcheck(state, levels.size() == 1
		|| static_cast<int>(levels.size()) == totalImageMipmapCount(width, height,
			type == GraphicsBackend::TextureType::Volume ? slices : 1), 1,
		"Image must provide either only the base level or a complete mipmap chain");
	if (type == GraphicsBackend::TextureType::Cube)
		luaL_argcheck(state, width == height, 1, "CubeImage faces must be square");
	std::string error;
	const auto handle = graphics->newImage(type, levels, error);
	if (handle == 0)
		return luaL_error(state, "%s creation failed: %s", label,
			error.empty() ? "failed to create non-2D Image" : error.c_str());
	auto *image = new ImageUserdata(runtime, handle, type, slices);
	image->filter = runtime->getGraphicsDefaultFilter();
	image->magFilter = runtime->getGraphicsDefaultFilter();
	image->anisotropy = runtime->getGraphicsDefaultAnisotropy();
	image->mipmapCount = static_cast<int>(levels.size());
	image->linear = linear;
	image->dpiScale = dpiScale;
	if (image->mipmapCount > 1)
	{
		image->mipmapFilter = runtime->getGraphicsDefaultMipmapFilter();
		image->mipmapSharpness = runtime->getGraphicsDefaultMipmapSharpness();
	}
	pushNewDoraHandleObject(state, ImageUserdata::type, image);
	return 1;
}

int LoveRuntime::graphicsNewArrayImage(lua_State *state)
{
	return newLayeredImage(state, runtimeFromUpvalue(state), GraphicsBackend::TextureType::Array, "Love ArrayImage");
}

int LoveRuntime::graphicsNewCubeImage(lua_State *state)
{
	return newLayeredImage(state, runtimeFromUpvalue(state), GraphicsBackend::TextureType::Cube, "Love CubeImage");
}

int LoveRuntime::graphicsNewVolumeImage(lua_State *state)
{
	return newLayeredImage(state, runtimeFromUpvalue(state), GraphicsBackend::TextureType::Volume, "Love VolumeImage");
}

int LoveRuntime::graphicsNewCanvas(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	const int defaultWidth = runtime->_graphicsBackend->getPixelWidth();
	const int defaultHeight = runtime->_graphicsBackend->getPixelHeight();
	const int width = static_cast<int>(luaL_optinteger(state, 1, defaultWidth));
	const int height = static_cast<int>(luaL_optinteger(state, 2, defaultHeight));
	luaL_argcheck(state, width > 0 && width <= MaximumWindowDimension, 1,
		"Canvas width must be between 1 and 8192 pixels");
	luaL_argcheck(state, height > 0 && height <= MaximumWindowDimension, 2,
		"Canvas height must be between 1 and 8192 pixels");
	GraphicsBackend::CanvasSettings settings;
	const char *formatName = "rgba8";
	int settingsIndex = 3;
	if (lua_isnumber(state, 3))
	{
		settings.slices = static_cast<int>(luaL_checkinteger(state, 3));
		luaL_argcheck(state, settings.slices > 0, 3, "Canvas layers must be positive");
		settings.type = GraphicsBackend::TextureType::Array;
		settingsIndex = 4;
	}
	if (!lua_isnoneornil(state, settingsIndex))
	{
		luaL_checktype(state, settingsIndex, LUA_TTABLE);
		lua_getfield(state, settingsIndex, "dpiscale");
		if (!lua_isnil(state, -1))
		{
			settings.dpiScale = static_cast<float>(luaL_checknumber(state, -1));
			luaL_argcheck(state, std::isfinite(settings.dpiScale) && settings.dpiScale > 0.0f,
				settingsIndex, "Canvas dpiscale must be positive and finite");
		}
		lua_pop(state, 1);
		lua_getfield(state, settingsIndex, "msaa");
		if (!lua_isnil(state, -1))
		{
			settings.msaa = static_cast<int>(luaL_checkinteger(state, -1));
			luaL_argcheck(state, settings.msaa == 0 || settings.msaa == 2 || settings.msaa == 4
				|| settings.msaa == 8 || settings.msaa == 16, settingsIndex,
				"Canvas msaa must be 0, 2, 4, 8, or 16");
		}
		lua_pop(state, 1);
		lua_getfield(state, settingsIndex, "format");
		if (!lua_isnil(state, -1))
		{
			const std::string_view format = luaL_checkstring(state, -1);
			static constexpr std::string_view supportedFormats[] = {
				"normal", "hdr", "r8", "rg8", "rgba8", "srgba8",
				"r16", "rg16", "rgba16", "r16f", "rg16f", "rgba16f",
				"r32f", "rg32f", "rgba32f", "rgba4", "rgb5a1", "rgb565",
				"rgb10a2", "rg11b10f", "stencil8", "depth16", "depth24",
				"depth32f", "depth24stencil8", "depth32fstencil8"};
			const auto found = std::find(std::begin(supportedFormats), std::end(supportedFormats), format);
			luaL_argcheck(state, found != std::end(supportedFormats), settingsIndex,
				"Canvas format is not supported by the embedded Dora renderer");
			settings.format = format == "normal" ? std::string_view("rgba8")
				: format == "hdr" ? std::string_view("rgba16f") : *found;
			formatName = settings.format.data();
		}
		lua_pop(state, 1);
		lua_getfield(state, settingsIndex, "type");
		if (!lua_isnil(state, -1))
		{
			const std::string_view type = luaL_checkstring(state, -1);
			if (type == "2d") settings.type = GraphicsBackend::TextureType::Texture2D;
			else if (type == "array") settings.type = GraphicsBackend::TextureType::Array;
			else if (type == "cube") settings.type = GraphicsBackend::TextureType::Cube;
			else if (type == "volume") settings.type = GraphicsBackend::TextureType::Volume;
			else luaL_argerror(state, settingsIndex,
				"Canvas type must be '2d', 'array', 'cube', or 'volume'");
		}
		lua_pop(state, 1);
		lua_getfield(state, settingsIndex, "readable");
		if (!lua_isnil(state, -1))
		{
			luaL_argcheck(state, lua_isboolean(state, -1), settingsIndex,
				"Canvas readable setting must be a boolean");
			settings.readable = lua_toboolean(state, -1);
		}
		lua_pop(state, 1);
		lua_getfield(state, settingsIndex, "mipmaps");
		if (!lua_isnil(state, -1))
		{
			settings.mipmapMode = luaL_checkstring(state, -1);
			luaL_argcheck(state, settings.mipmapMode == "none" || settings.mipmapMode == "manual"
				|| settings.mipmapMode == "auto", settingsIndex,
				"Canvas mipmaps must be 'none', 'manual', or 'auto'");
		}
		lua_pop(state, 1);
	}
	if (settings.type == GraphicsBackend::TextureType::Texture2D)
		luaL_argcheck(state, settings.slices == 1, 3,
			"2D Canvas cannot have multiple layers");
	else if (settings.type == GraphicsBackend::TextureType::Cube)
	{
		settings.slices = 6;
		luaL_argcheck(state, width == height, 1, "cube Canvas must be square");
	}
	std::string error;
	const auto handle = runtime->_graphicsBackend->newCanvas(width, height, settings, error);
	if (handle == 0)
		return luaL_error(state, "Love Canvas %dx%d creation failed: %s", width, height,
			error.empty() ? "failed to create Dora RenderTarget" : error.c_str());
	auto *canvas = new CanvasUserdata(runtime, handle, formatName, settings.msaa, settings.readable);
	canvas->filter = runtime->_graphicsDefaultFilter;
	canvas->anisotropy = runtime->_graphicsDefaultAnisotropy;
	canvas->textureType = settings.type;
	canvas->slices = settings.slices;
	canvas->dpiScale = settings.dpiScale;
	canvas->mipmapMode = std::string(settings.mipmapMode);
	canvas->mipmapCount = settings.mipmapMode == "none" ? 1
		: totalImageMipmapCount(width, height,
			settings.type == GraphicsBackend::TextureType::Volume ? settings.slices : 1);
	if (canvas->mipmapCount > 1)
	{
		canvas->mipmapFilter = runtime->_graphicsDefaultMipmapFilter;
		canvas->mipmapSharpness = runtime->_graphicsDefaultMipmapSharpness;
	}
	pushNewDoraHandleObject(state, CanvasUserdata::type, canvas);
	return 1;
}

int LoveRuntime::graphicsGetCanvasFormats(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	bool readable = true;
	int tableIndex = 1;
	if (lua_type(state, 1) == LUA_TBOOLEAN)
	{
		readable = lua_toboolean(state, 1);
		tableIndex = 2;
	}
	if (lua_istable(state, tableIndex))
		lua_pushvalue(state, tableIndex);
	else
		lua_createtable(state, 0, 27);
	static constexpr std::string_view formats[] = {
		"normal", "hdr", "r8", "rg8", "rgba8", "srgba8", "r16", "rg16",
		"rgba16", "r16f", "rg16f", "rgba16f", "r32f", "rg32f", "rgba32f",
		"la8", "rgba4", "rgb5a1", "rgb565", "rgb10a2", "rg11b10f",
		"stencil8", "depth16", "depth24", "depth32f", "depth24stencil8",
		"depth32fstencil8"};
	for (const auto format : formats)
	{
		lua_pushboolean(state, runtime->_graphicsBackend->isCanvasFormatSupported(format, readable));
		lua_setfield(state, -2, format.data());
	}
	return 1;
}

int LoveRuntime::graphicsSetCanvas(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	if (runtime->_graphicsStencilWriting)
	{
		runtime->_graphicsBackend->endStencilWrite();
		runtime->_graphicsStencilWriting = false;
	}
	std::vector<GraphicsBackend::CanvasHandle> handles;
	std::vector<GraphicsBackend::CanvasTarget> targets;
	std::vector<int> argumentIndices;
	std::vector<::love::StrongRef<::love::Object>> canvasObjects;
	GraphicsBackend::CanvasHandle depthStencil = 0;
	GraphicsBackend::CanvasTarget depthStencilTarget;
	::love::StrongRef<::love::Object> depthStencilObject;
	bool depth = false;
	bool stencil = false;
	auto makeTarget = [&](CanvasUserdata *canvas, int slice, int mipmap, int argument) {
		luaL_argcheck(state, mipmap >= 0 && mipmap < canvas->mipmapCount, argument,
			"Canvas target mipmap is outside the available range");
		int slices = canvas->textureType == GraphicsBackend::TextureType::Volume
			? std::max(1, canvas->slices >> mipmap) : canvas->slices;
		if (canvas->textureType == GraphicsBackend::TextureType::Texture2D) slice = 0;
		luaL_argcheck(state, slice >= 0 && slice < slices, argument,
			"Canvas target layer, face, or volume slice is outside the available range");
		return GraphicsBackend::CanvasTarget{canvas->handle, slice, mipmap};
	};
	auto readTableTarget = [&](int tableIndex, int argument) {
		tableIndex = lua_absindex(state, tableIndex);
		lua_rawgeti(state, tableIndex, 1);
		auto *canvas = checkCanvas(state, -1);
		luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
			&& runtime->_canvasHandles.contains(canvas->handle), argument,
			"Canvas belongs to another or closed LoveRuntime");
		int slice = 0;
		if (canvas->textureType == GraphicsBackend::TextureType::Array
			|| canvas->textureType == GraphicsBackend::TextureType::Volume)
		{
			lua_getfield(state, tableIndex, "layer");
			slice = static_cast<int>(luaL_checkinteger(state, -1)) - 1;
			lua_pop(state, 1);
		}
		else if (canvas->textureType == GraphicsBackend::TextureType::Cube)
		{
			lua_getfield(state, tableIndex, "face");
			slice = static_cast<int>(luaL_checkinteger(state, -1)) - 1;
			lua_pop(state, 1);
		}
		lua_getfield(state, tableIndex, "mipmap");
		const int mipmap = static_cast<int>(luaL_optinteger(state, -1, 1)) - 1;
		lua_pop(state, 1);
		const auto target = makeTarget(canvas, slice, mipmap, argument);
		lua_pop(state, 1);
		return std::pair{target, canvas};
	};
	if (!lua_isnoneornil(state, 1))
	{
		if (lua_istable(state, 1))
		{
			lua_getfield(state, 1, "depthstencil");
			if (lua_isboolean(state, -1))
			{
				depth = lua_toboolean(state, -1);
				stencil = depth;
			}
			else if (lua_istable(state, -1))
			{
				auto [target, canvas] = readTableTarget(-1, 1);
				luaL_argcheck(state, isDepthStencilCanvasFormat(canvas->format), 1,
					"depthstencil field requires a depth/stencil format Canvas");
				depthStencil = canvas->handle;
				depthStencilTarget = target;
				depthStencilObject.set(canvas);
				depth = canvasFormatHasDepth(canvas->format);
				stencil = canvasFormatHasStencil(canvas->format);
			}
			else if (!lua_isnil(state, -1))
			{
				auto *canvas = checkCanvas(state, -1);
				luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
					&& runtime->_canvasHandles.contains(canvas->handle), 1,
					"depthstencil Canvas belongs to another or closed LoveRuntime");
				luaL_argcheck(state, isDepthStencilCanvasFormat(canvas->format), 1,
					"depthstencil field requires a depth/stencil format Canvas");
				depthStencil = canvas->handle;
				depthStencilTarget = makeTarget(canvas, 0, 0, 1);
				depthStencilObject.set(canvas);
				depth = canvasFormatHasDepth(canvas->format);
				stencil = canvasFormatHasStencil(canvas->format);
			}
			lua_pop(state, 1);
			if (depthStencil == 0)
			{
				lua_getfield(state, 1, "depth");
				if (!lua_isnil(state, -1) && !lua_isboolean(state, -1))
					return luaL_error(state, "Canvas setup depth field must be a boolean");
				depth = depth || lua_toboolean(state, -1);
				lua_pop(state, 1);
				lua_getfield(state, 1, "stencil");
				if (!lua_isnil(state, -1) && !lua_isboolean(state, -1))
					return luaL_error(state, "Canvas setup stencil field must be a boolean");
				stencil = stencil || lua_toboolean(state, -1);
				lua_pop(state, 1);
			}
			const int count = static_cast<int>(lua_rawlen(state, 1));
			lua_rawgeti(state, 1, 1);
			const bool tableOfTargets = lua_istable(state, -1);
			lua_pop(state, 1);
			for (int index = 1; index <= count; ++index)
			{
				lua_rawgeti(state, 1, index);
				CanvasUserdata *canvas = nullptr;
				GraphicsBackend::CanvasTarget target;
				if (tableOfTargets)
				{
					auto parsed = readTableTarget(-1, 1);
					target = parsed.first;
					canvas = parsed.second;
				}
				else
				{
					canvas = checkCanvas(state, -1);
					luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
						&& runtime->_canvasHandles.contains(canvas->handle), 1,
						"Canvas belongs to another or closed LoveRuntime");
					luaL_argcheck(state, canvas->textureType == GraphicsBackend::TextureType::Texture2D,
						1, "non-2D Canvases require the table-of-targets setCanvas form");
					target = makeTarget(canvas, 0, 0, 1);
				}
				handles.push_back(target.canvas);
				targets.push_back(target);
				canvasObjects.emplace_back(canvas);
				argumentIndices.push_back(lua_gettop(state));
			}
		}
		else
		{
			const int count = lua_gettop(state);
			for (int index = 1; index <= count; ++index)
			{
				auto *canvas = checkCanvas(state, index);
				luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
					&& runtime->_canvasHandles.contains(canvas->handle), index,
					"Canvas belongs to another or closed LoveRuntime");
				int slice = 0;
				int mipmap = 0;
				if (canvas->textureType != GraphicsBackend::TextureType::Texture2D)
				{
					luaL_argcheck(state, index == 1, index,
						"this setCanvas form supports only one non-2D Canvas");
					slice = static_cast<int>(luaL_checkinteger(state, index + 1)) - 1;
					mipmap = static_cast<int>(luaL_optinteger(state, index + 2, 1)) - 1;
				}
				else if (index == 1 && lua_isnumber(state, index + 1))
					mipmap = static_cast<int>(luaL_checkinteger(state, index + 1)) - 1;
				const auto target = makeTarget(canvas, slice, mipmap, index);
				handles.push_back(canvas->handle);
				targets.push_back(target);
				canvasObjects.emplace_back(canvas);
				argumentIndices.push_back(index);
				if (canvas->textureType != GraphicsBackend::TextureType::Texture2D
					|| (index == 1 && lua_isnumber(state, index + 1))) break;
			}
		}
	}
	if ((depth || stencil) && handles.empty() && depthStencil == 0)
		return luaL_error(state, "temporary Canvas depth/stencil requires at least one color Canvas");
	if (!handles.empty() || depthStencil != 0)
	{
		const auto firstTarget = targets.empty() ? depthStencilTarget : targets.front();
		const int width = std::max(1,
			runtime->_graphicsBackend->getCanvasWidth(firstTarget.canvas) >> firstTarget.mipmap);
		const int height = std::max(1,
			runtime->_graphicsBackend->getCanvasHeight(firstTarget.canvas) >> firstTarget.mipmap);
		std::unordered_set<GraphicsBackend::CanvasHandle> uniqueHandles;
		for (const auto &target : targets)
		{
			const auto handle = target.canvas;
			if (!uniqueHandles.insert(handle).second)
				return luaL_error(state, "the same Love Canvas cannot be bound to multiple color attachments");
			if (std::max(1, runtime->_graphicsBackend->getCanvasWidth(handle) >> target.mipmap) != width
				|| std::max(1, runtime->_graphicsBackend->getCanvasHeight(handle) >> target.mipmap) != height)
				return luaL_error(state, "simultaneous Love Canvas targets must have identical dimensions");
		}
		if (depthStencil != 0)
		{
			if (uniqueHandles.contains(depthStencil))
				return luaL_error(state, "a depthstencil Canvas cannot also be a color attachment");
			if (std::max(1, runtime->_graphicsBackend->getCanvasWidth(depthStencil)
					>> depthStencilTarget.mipmap) != width
				|| std::max(1, runtime->_graphicsBackend->getCanvasHeight(depthStencil)
					>> depthStencilTarget.mipmap) != height)
				return luaL_error(state, "depthstencil and color Canvases must have identical dimensions");
		}
	}
	std::string error;
	if (!runtime->_graphicsBackend->setCanvasTargets(targets,
		depthStencil != 0 ? &depthStencilTarget : nullptr, depth, stencil, error))
		return luaL_error(state, "%s", error.empty() ? "failed to switch Dora Canvas target" : error.c_str());
	for (const int reference : runtime->_graphicsCanvasReferences)
		luaL_unref(state, LUA_REGISTRYINDEX, reference);
	runtime->_graphicsCanvasReferences.clear();
	runtime->_graphicsCanvasObjects.clear();
	if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX, runtime->_graphicsCanvasDepthStencilReference);
	runtime->_graphicsCanvasDepthStencilReference = LUA_NOREF;
	runtime->_graphicsCanvases = handles;
	runtime->_graphicsCanvasTargets = targets;
	runtime->_graphicsCanvasObjects = std::move(canvasObjects);
	runtime->_graphicsCanvasDepthStencil = depthStencil;
	runtime->_graphicsCanvasDepthStencilTarget = depthStencilTarget;
	runtime->_graphicsCanvasDepthStencilObject = std::move(depthStencilObject);
	runtime->_graphicsCanvasDepth = depth;
	runtime->_graphicsCanvasStencil = stencil;
	for (const int index : argumentIndices)
	{
		lua_pushvalue(state, index);
		runtime->_graphicsCanvasReferences.push_back(luaL_ref(state, LUA_REGISTRYINDEX));
	}
	if (depthStencil != 0)
	{
		lua_getfield(state, 1, "depthstencil");
		runtime->_graphicsCanvasDepthStencilReference = luaL_ref(state, LUA_REGISTRYINDEX);
	}
	return 0;
}

int LoveRuntime::graphicsGetCanvas(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (runtime->_graphicsCanvasObjects.empty()
		&& !runtime->_graphicsCanvasDepthStencilObject)
	{
		lua_pushnil(state);
		return 1;
	}
	auto pushTarget = [&](CanvasUserdata *canvas, const GraphicsBackend::CanvasTarget &target) {
		lua_createtable(state, 1, 2);
		::love::luax_pushtype(state, CanvasUserdata::type, canvas);
		lua_rawseti(state, -2, 1);
		if (canvas->textureType == GraphicsBackend::TextureType::Array
			|| canvas->textureType == GraphicsBackend::TextureType::Volume)
		{
			lua_pushinteger(state, target.slice + 1);
			lua_setfield(state, -2, "layer");
		}
		else if (canvas->textureType == GraphicsBackend::TextureType::Cube)
		{
			lua_pushinteger(state, target.slice + 1);
			lua_setfield(state, -2, "face");
		}
		lua_pushinteger(state, target.mipmap + 1);
		lua_setfield(state, -2, "mipmap");
	};
	bool tableVariant = static_cast<bool>(runtime->_graphicsCanvasDepthStencilObject);
	for (std::size_t index = 0; index < runtime->_graphicsCanvasObjects.size(); ++index)
	{
		auto *canvas = static_cast<CanvasUserdata *>(runtime->_graphicsCanvasObjects[index].get());
		tableVariant = tableVariant || canvas->textureType != GraphicsBackend::TextureType::Texture2D
			|| runtime->_graphicsCanvasTargets[index].mipmap != 0;
	}
	if (tableVariant)
	{
		lua_createtable(state, static_cast<int>(runtime->_graphicsCanvasObjects.size()), 1);
		for (std::size_t index = 0; index < runtime->_graphicsCanvasObjects.size(); ++index)
		{
			pushTarget(static_cast<CanvasUserdata *>(runtime->_graphicsCanvasObjects[index].get()),
				runtime->_graphicsCanvasTargets[index]);
			lua_rawseti(state, -2, static_cast<lua_Integer>(index + 1));
		}
		if (runtime->_graphicsCanvasDepthStencilObject)
		{
			pushTarget(static_cast<CanvasUserdata *>(runtime->_graphicsCanvasDepthStencilObject.get()),
				runtime->_graphicsCanvasDepthStencilTarget);
			lua_setfield(state, -2, "depthstencil");
		}
		return 1;
	}
	for (const auto &object : runtime->_graphicsCanvasObjects)
		::love::luax_pushtype(state, CanvasUserdata::type,
			static_cast<CanvasUserdata *>(object.get()));
	return static_cast<int>(runtime->_graphicsCanvasObjects.size());
}

int LoveRuntime::graphicsStencil(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_checktype(state, 1, LUA_TFUNCTION);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	if (runtime->_graphicsStencilWriting)
		return luaL_error(state, "nested love.graphics.stencil callbacks are not supported");
	static constexpr std::string_view actions[] = {
		"replace", "increment", "decrement", "incrementwrap", "decrementwrap", "invert"};
	const std::string_view action = luaL_optstring(state, 2, "replace");
	if (std::find(std::begin(actions), std::end(actions), action) == std::end(actions))
		return luaL_argerror(state, 2, "invalid stencil action");
	const int value = static_cast<int>(luaL_optinteger(state, 3, 1));
	bool shouldClear = true;
	int clearValue = 0;
	if (!lua_isnoneornil(state, 4))
	{
		if (lua_isboolean(state, 4))
			shouldClear = !lua_toboolean(state, 4);
		else if (lua_isnumber(state, 4))
			clearValue = static_cast<int>(luaL_checkinteger(state, 4));
		else
			return luaL_argerror(state, 4, "expected boolean or integer stencil clear value");
	}
	std::string error;
	if (shouldClear && !runtime->_graphicsBackend->clearStencil(clearValue, error))
		return luaL_error(state, "%s", error.c_str());
	if (!runtime->_graphicsBackend->beginStencilWrite(action, value, error))
		return luaL_error(state, "%s", error.c_str());
	runtime->_graphicsStencilWriting = true;
	lua_pushvalue(state, 1);
	const int status = lua_pcall(state, 0, 0, 0);
	if (runtime->_graphicsStencilWriting)
	{
		runtime->_graphicsBackend->endStencilWrite();
		runtime->_graphicsStencilWriting = false;
	}
	if (status != LUA_OK)
		return lua_error(state);
	return 0;
}

int LoveRuntime::graphicsSetStencilTest(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool enabled = !lua_isnoneornil(state, 1);
	std::string_view compare = "always";
	int value = 0;
	if (enabled)
	{
		compare = luaL_checkstring(state, 1);
		static constexpr std::string_view compares[] = {
			"less", "lequal", "equal", "gequal", "greater", "notequal", "always", "never"};
		if (std::find(std::begin(compares), std::end(compares), compare) == std::end(compares))
			return luaL_argerror(state, 1, "invalid stencil compare mode");
		value = static_cast<int>(luaL_checkinteger(state, 2));
	}
	runtime->_graphicsStencilTestEnabled = enabled;
	runtime->_graphicsStencilCompare.assign(compare);
	runtime->_graphicsStencilValue = value;
	if (runtime->_graphicsBackend)
		runtime->_graphicsBackend->setStencilTest(compare, value);
	return 0;
}

int LoveRuntime::graphicsGetStencilTest(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsStencilTestEnabled)
	{
		lua_pushnil(state);
		return 1;
	}
	lua_pushlstring(state, runtime->_graphicsStencilCompare.data(), runtime->_graphicsStencilCompare.size());
	lua_pushinteger(state, runtime->_graphicsStencilValue);
	return 2;
}

int LoveRuntime::graphicsNewQuad(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	const float width = static_cast<float>(luaL_checknumber(state, 3));
	const float height = static_cast<float>(luaL_checknumber(state, 4));
	float textureWidth = 0.0f;
	float textureHeight = 0.0f;
	if (auto *image = testImage(state, 5))
	{
		luaL_argcheck(state, image->runtime == runtime && image->handle != 0, 5,
			"Image belongs to another or closed LoveRuntime");
		luaL_argcheck(state, runtime->_graphicsBackend != nullptr, 5, "Dora graphics backend is unavailable");
		textureWidth = static_cast<float>(runtime->_graphicsBackend->getImageWidth(image->handle));
		textureHeight = static_cast<float>(runtime->_graphicsBackend->getImageHeight(image->handle));
	}
	else if (auto *canvas = testCanvas(state, 5))
	{
		luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
			&& runtime->_canvasHandles.contains(canvas->handle), 5,
			"Canvas belongs to another or closed LoveRuntime");
		luaL_argcheck(state, runtime->_graphicsBackend != nullptr, 5, "Dora graphics backend is unavailable");
		textureWidth = static_cast<float>(runtime->_graphicsBackend->getCanvasWidth(canvas->handle));
		textureHeight = static_cast<float>(runtime->_graphicsBackend->getCanvasHeight(canvas->handle));
	}
	else
	{
		textureWidth = static_cast<float>(luaL_checknumber(state, 5));
		textureHeight = static_cast<float>(luaL_checknumber(state, 6));
	}
	const bool finite = std::isfinite(x) && std::isfinite(y) && std::isfinite(width)
		&& std::isfinite(height) && std::isfinite(textureWidth) && std::isfinite(textureHeight);
	luaL_argcheck(state, finite && width != 0.0f && height != 0.0f, 3,
		"Quad viewport values must be finite and width/height must be non-zero");
	luaL_argcheck(state, textureWidth > 0.0f && textureHeight > 0.0f, 5,
		"Quad texture dimensions must be positive and finite");
	auto *quad = new QuadUserdata;
	quad->runtime = runtime;
	quad->x = x;
	quad->y = y;
	quad->width = width;
	quad->height = height;
	quad->textureWidth = textureWidth;
	quad->textureHeight = textureHeight;
	quad->layer = 1;
	::love::luax_pushtype(state, QuadLoveType, quad);
	quad->release();
	return 1;
}

int LoveRuntime::graphicsNewMesh(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_argcheck(state, lua_istable(state, 1) || lua_isnumber(state, 1), 1,
		"expected a table or vertex count");
	const bool custom = lua_istable(state, 1)
		&& (lua_istable(state, 2) || lua_isnumber(state, 2) || lua_isuserdata(state, 2));
	const int verticesIndex = custom ? 2 : 1;
	const int modeIndex = custom ? 3 : 2;
	const int usageIndex = custom ? 4 : 3;
	const std::string drawModeValue = luaL_optstring(state, modeIndex, "fan");
	const std::string usageValue = luaL_optstring(state, usageIndex, "dynamic");
	luaL_argcheck(state, isMeshDrawMode(drawModeValue), modeIndex,
		"expected 'fan', 'strip', 'triangles', or 'points'");
	luaL_argcheck(state, isMeshUsage(usageValue), usageIndex,
		"expected 'stream', 'dynamic', or 'static'");

	auto *mesh = new MeshUserdata;
	mesh->runtime = runtime;
	mesh->drawMode = drawModeValue;
	mesh->usage = usageValue;
	::love::luax_pushtype(state, MeshLoveType, mesh);

	if (custom)
	{
		const std::size_t formatCount = lua_rawlen(state, 1);
		luaL_argcheck(state, formatCount > 0, 1, "Mesh vertex format must not be empty");
		std::set<std::string> names;
		for (std::size_t index = 0; index < formatCount; ++index)
		{
			lua_rawgeti(state, 1, static_cast<lua_Integer>(index + 1));
			luaL_checktype(state, -1, LUA_TTABLE);
			lua_rawgeti(state, -1, 1);
			lua_rawgeti(state, -2, 2);
			lua_rawgeti(state, -3, 3);
			MeshAttribute attribute;
			attribute.name = luaL_checkstring(state, -3);
			attribute.type = luaL_checkstring(state, -2);
			attribute.components = static_cast<int>(luaL_checkinteger(state, -1));
			attribute.offset = mesh->componentCount;
			luaL_argcheck(state, !attribute.name.empty() && names.insert(attribute.name).second, 1,
				"Mesh attribute names must be non-empty and unique");
			luaL_argcheck(state, isMeshAttributeType(attribute.type), 1,
				"Mesh attribute type must be 'float', 'byte', or 'unorm16'");
			luaL_argcheck(state, attribute.components >= 1 && attribute.components <= 4, 1,
				"Mesh attribute components must be between 1 and 4");
			attribute.byteOffset = mesh->vertexStride;
			attribute.byteSize = meshAttributeByteSize(attribute.type, attribute.components);
			luaL_argcheck(state, attribute.byteSize % 4 == 0, 1,
				"Mesh vertex attributes must occupy a multiple of 4 bytes");
			mesh->componentCount += static_cast<std::size_t>(attribute.components);
			mesh->vertexStride += attribute.byteSize;
			mesh->format.push_back(std::move(attribute));
			lua_pop(state, 4);
		}
	}
	else
	{
		mesh->format = {
			{"VertexPosition", "float", 2, 0, 0, 8, true},
			{"VertexTexCoord", "float", 2, 2, 8, 8, true},
			{"VertexColor", "byte", 4, 4, 16, 4, true},
		};
		mesh->componentCount = 8;
		mesh->vertexStride = 20;
	}

	if (lua_isnumber(state, verticesIndex))
	{
		const lua_Integer count = luaL_checkinteger(state, verticesIndex);
		luaL_argcheck(state, count > 0, verticesIndex, "vertex count must be greater than 0");
		mesh->vertexCount = static_cast<std::size_t>(count);
		mesh->values.assign(mesh->vertexCount * mesh->componentCount, 0.0f);
		mesh->bytes.assign(mesh->vertexCount * mesh->vertexStride, 0);
	}
	else if (isMeshData(state, verticesIndex))
	{
		const auto data = meshDataBytes(state, verticesIndex);
		mesh->vertexCount = data.size() / mesh->vertexStride;
		luaL_argcheck(state, mesh->vertexCount > 0, verticesIndex,
			"Data size is too small for the specified Mesh vertex format");
		mesh->bytes.assign(data.begin(), data.begin() + mesh->vertexCount * mesh->vertexStride);
		luaL_argcheck(state, decodeMeshStorage(*mesh, mesh->bytes, mesh->values), verticesIndex,
			"Mesh Data contains a non-finite float vertex component");
	}
	else
	{
		luaL_checktype(state, verticesIndex, LUA_TTABLE);
		mesh->vertexCount = lua_rawlen(state, verticesIndex);
		luaL_argcheck(state, mesh->vertexCount > 0, verticesIndex, "Mesh vertices must not be empty");
		mesh->values.resize(mesh->vertexCount * mesh->componentCount);
		for (std::size_t index = 0; index < mesh->vertexCount; ++index)
		{
			lua_rawgeti(state, verticesIndex, static_cast<lua_Integer>(index + 1));
			luaL_checktype(state, -1, LUA_TTABLE);
			readMeshVertex(state, -1, *mesh,
				std::span<float>(mesh->values).subspan(index * mesh->componentCount, mesh->componentCount));
			lua_pop(state, 1);
		}
		encodeMeshStorage(*mesh);
	}
	mesh->release();
	return 1;
}

int LoveRuntime::graphicsNewSpriteBatch(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	auto *image = testImage(state, 1);
	auto *canvas = testCanvas(state, 1);
	if (!image && !canvas)
		return luaL_argerror(state, 1, "expected an Image or Canvas");
	if (image)
	{
		luaL_argcheck(state, image->runtime == runtime && image->handle != 0, 1,
			"Image belongs to another or closed LoveRuntime");
		luaL_argcheck(state, image->textureType == GraphicsBackend::TextureType::Texture2D
			|| image->textureType == GraphicsBackend::TextureType::Array, 1,
			"SpriteBatch requires a 2D Image, ArrayImage, or Canvas");
	}
	else
	{
		luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
			&& runtime->_canvasHandles.contains(canvas->handle), 1,
			"Canvas belongs to another or closed LoveRuntime");
		luaL_argcheck(state, canvas->readable, 1,
			"cannot create a SpriteBatch with a non-readable Canvas");
	}
	const lua_Integer capacity = luaL_optinteger(state, 2, 1000);
	luaL_argcheck(state, capacity >= 1 && capacity <= 1000000, 2,
		"SpriteBatch size must be between 1 and 1000000");
	const std::string usage = luaL_optstring(state, 3, "dynamic");
	luaL_argcheck(state, isMeshUsage(usage), 3,
		"expected SpriteBatch usage 'stream', 'dynamic', or 'static'");
	auto *batch = new SpriteBatchUserdata;
	batch->runtime = runtime;
	batch->image = image ? image->handle : 0;
	batch->canvas = canvas ? canvas->handle : 0;
	batch->textureObject.set(image ? static_cast<::love::Object *>(image)
		: static_cast<::love::Object *>(canvas));
	batch->textureType = image ? image->textureType : GraphicsBackend::TextureType::Texture2D;
	batch->layerCount = image ? image->slices : 1;
	batch->bufferSize = static_cast<std::size_t>(capacity);
	batch->sprites.resize(batch->bufferSize);
	batch->usage = usage;
	::love::luax_pushtype(state, SpriteBatchLoveType, batch);
	lua_pushvalue(state, 1);
	lua_setiuservalue(state, -2, 1);
	lua_newtable(state);
	lua_setiuservalue(state, -2, 2);
	batch->release();
	return 1;
}

int LoveRuntime::graphicsNewParticleSystem(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	auto *image = testImage(state, 1);
	auto *canvas = testCanvas(state, 1);
	if (!image && !canvas) return luaL_argerror(state, 1, "expected a 2D Image or Canvas");
	int width = 0;
	int height = 0;
	if (image)
	{
		luaL_argcheck(state, image->runtime == runtime && image->handle != 0, 1,
			"Image belongs to another or closed LoveRuntime");
		luaL_argcheck(state, image->textureType == GraphicsBackend::TextureType::Texture2D, 1,
			"ParticleSystem supports only 2D textures");
		width = runtime->_graphicsBackend->getImageWidth(image->handle);
		height = runtime->_graphicsBackend->getImageHeight(image->handle);
	}
	else
	{
		luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
			&& runtime->_canvasHandles.contains(canvas->handle), 1,
			"Canvas belongs to another or closed LoveRuntime");
		luaL_argcheck(state, canvas->readable, 1,
			"cannot create a ParticleSystem with a non-readable Canvas");
		width = runtime->_graphicsBackend->getCanvasWidth(canvas->handle);
		height = runtime->_graphicsBackend->getCanvasHeight(canvas->handle);
	}
	const lua_Integer capacity = luaL_optinteger(state, 2, 1000);
	luaL_argcheck(state, capacity >= 1 && capacity <= 1000000, 2,
		"ParticleSystem size must be between 1 and 1000000");
	auto *system = new ParticleSystemUserdata;
	system->runtime = runtime;
	system->image = image ? image->handle : 0;
	system->canvas = canvas ? canvas->handle : 0;
	system->textureObject.set(image ? static_cast<::love::Object *>(image)
		: static_cast<::love::Object *>(canvas));
	system->bufferSize = static_cast<std::size_t>(capacity);
	system->particles.reserve(system->bufferSize);
	system->offsetX = static_cast<float>(width) * 0.5f;
	system->offsetY = static_cast<float>(height) * 0.5f;
	system->randomState ^= static_cast<std::uint64_t>(reinterpret_cast<std::uintptr_t>(system));
	::love::luax_pushtype(state, ParticleSystemLoveType, system);
	lua_pushvalue(state, 1);
	lua_setiuservalue(state, -2, 1);
	lua_newtable(state);
	lua_setiuservalue(state, -2, 2);
	system->release();
	return 1;
}

namespace
{
std::vector<TextFragment> readTextFragments(lua_State *state, int index)
{
	std::vector<TextFragment> fragments;
	TextFragment current;
	if (!lua_istable(state, index))
	{
		size_t size = 0;
		const char *text = luaL_checklstring(state, index, &size);
		current.text.assign(text, size);
		fragments.push_back(std::move(current));
		return fragments;
	}
	const int table = lua_absindex(state, index);
	const std::size_t count = lua_rawlen(state, table);
	for (std::size_t item = 0; item < count; ++item)
	{
		lua_rawgeti(state, table, static_cast<lua_Integer>(item + 1));
		if (lua_istable(state, -1))
		{
			for (int component = 0; component < 4; ++component)
			{
				lua_rawgeti(state, -1, component + 1);
				const float value = static_cast<float>(luaL_optnumber(state, -1, 1.0));
				luaL_argcheck(state, std::isfinite(value), index, "Text color must be finite");
				current.color[component] = std::clamp(value, 0.0f, 1.0f);
				lua_pop(state, 1);
			}
		}
		else
		{
			size_t size = 0;
			const char *text = luaL_checklstring(state, -1, &size);
			current.text.assign(text, size);
			fragments.push_back(current);
		}
		lua_pop(state, 1);
	}
	return fragments;
}

void layoutTextEntry(TextEntry &entry, GraphicsBackend &graphics,
	GraphicsBackend::FontHandle font)
{
	entry.runs.clear(); entry.width = 0.0f; entry.height = 0.0f;
	std::string flattened;
	std::vector<std::pair<std::size_t, std::size_t>> fragmentRanges;
	for (const auto &fragment : entry.fragments)
	{
		const std::size_t start = flattened.size(); flattened += fragment.text;
		fragmentRanges.emplace_back(start, flattened.size());
	}
	if (flattened.empty()) return;
	struct LineRange { std::size_t start = 0; std::size_t end = 0; std::string text; };
	std::vector<LineRange> lines;
	if (entry.wrap >= 0.0f)
	{
		std::vector<std::string> wrapped;
		graphics.getFontWrap(font, flattened, entry.wrap, wrapped);
		std::size_t cursor = 0;
		for (const auto &line : wrapped)
		{
			while (cursor < flattened.size() && (flattened[cursor] == '\n'
				|| flattened[cursor] == ' ' || flattened[cursor] == '\t')) ++cursor;
			std::size_t start = line.empty() ? cursor : flattened.find(line, cursor);
			if (start == std::string::npos) start = cursor;
			const std::size_t end = std::min(flattened.size(), start + line.size());
			lines.push_back({start, end, line}); cursor = end;
		}
	}
	else
	{
		std::size_t start = 0;
		while (start <= flattened.size())
		{
			const std::size_t newline = flattened.find('\n', start);
			const std::size_t end = newline == std::string::npos ? flattened.size() : newline;
			lines.push_back({start, end, flattened.substr(start, end - start)});
			if (newline == std::string::npos) break;
			start = newline + 1;
		}
	}
	const float lineAdvance = graphics.getFontHeight(font) * graphics.getFontLineHeight(font);
	for (std::size_t lineIndex = 0; lineIndex < lines.size(); ++lineIndex)
	{
		const auto &line = lines[lineIndex];
		const float lineWidth = graphics.getFontWidth(font, line.text);
		entry.width = std::max(entry.width, lineWidth);
		const float offsetX = entry.align == "center" ? std::floor((entry.wrap - lineWidth) * 0.5f)
			: entry.align == "right" ? std::floor(entry.wrap - lineWidth) : 0.0f;
		const std::size_t spaces = entry.align == "justify"
			? static_cast<std::size_t>(std::count(line.text.begin(), line.text.end(), ' ')) : 0;
		const float extraSpacing = spaces > 0 && lineWidth < entry.wrap
			? (entry.wrap - lineWidth) / static_cast<float>(spaces) : 0.0f;
		for (std::size_t fragmentIndex = 0; fragmentIndex < entry.fragments.size(); ++fragmentIndex)
		{
			const auto [fragmentStart, fragmentEnd] = fragmentRanges[fragmentIndex];
			const std::size_t begin = std::max(line.start, fragmentStart);
			const std::size_t end = std::min(line.end, fragmentEnd);
			if (begin >= end) continue;
			std::size_t runStart = begin;
			do
			{
				std::size_t runEnd = end;
				if (entry.align == "justify")
				{
					const std::size_t space = flattened.find(' ', runStart);
					if (space < end) runEnd = space + 1;
				}
				TextLayoutRun run;
				run.text = flattened.substr(runStart, runEnd - runStart);
				const auto prefix = std::string_view(flattened).substr(line.start, runStart - line.start);
				run.x = offsetX + graphics.getFontWidth(font, prefix)
					+ extraSpacing * static_cast<float>(std::count(prefix.begin(), prefix.end(), ' '));
				run.y = static_cast<float>(lineIndex) * lineAdvance;
				std::copy(std::begin(entry.fragments[fragmentIndex].color),
					std::end(entry.fragments[fragmentIndex].color), std::begin(run.color));
				entry.runs.push_back(std::move(run));
				runStart = runEnd;
			} while (runStart < end);
		}
	}
	entry.height = lines.empty() ? 0.0f
		: graphics.getFontHeight(font) + static_cast<float>(lines.size() - 1) * lineAdvance;
}

void drawTextEntry(GraphicsBackend &graphics, GraphicsBackend::FontHandle font,
	TextEntry &entry, float currentA, float currentB, float currentC, float currentD,
	float currentTx, float currentTy, const float *currentColor,
	float x, float y, float angle, float scaleX, float scaleY,
	float originX, float originY, float shearX, float shearY)
{
	layoutTextEntry(entry, graphics, font);
	TransformUserdata local;
	setTransform(local, x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY);
	TransformUserdata outer;
	setTransformIdentity(outer);
	outer.elements[0] = currentA;
	outer.elements[1] = currentB;
	outer.elements[4] = currentC;
	outer.elements[5] = currentD;
	outer.elements[12] = currentTx;
	outer.elements[13] = currentTy;
	TransformUserdata combined;
	multiplyTransforms(outer, local, combined);
	for (const auto &run : entry.runs)
	{
		const float tx = combined.elements[12] + combined.elements[0] * run.x
			+ combined.elements[4] * run.y;
		const float ty = combined.elements[13] + combined.elements[1] * run.x
			+ combined.elements[5] * run.y;
		graphics.drawText(font, run.text, -1.0f, "left",
			combined.elements[0], combined.elements[1], combined.elements[4], combined.elements[5],
			tx, ty, 0.0f, 0.0f, run.color[0] * currentColor[0],
			run.color[1] * currentColor[1], run.color[2] * currentColor[2],
			run.color[3] * currentColor[3]);
	}
}

void readTextTransform(lua_State *state, int index, TransformUserdata &transform)
{
	if (auto *provided = luaL_testudata(state, index, TransformLoveType.getName())
		? ::love::luax_checktype<TransformUserdata>(state, index, TransformLoveType) : nullptr)
	{
		transform = *provided;
		return;
	}
	const float x = static_cast<float>(luaL_optnumber(state, index, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, index + 1, 0.0));
	const float angle = static_cast<float>(luaL_optnumber(state, index + 2, 0.0));
	const float sx = static_cast<float>(luaL_optnumber(state, index + 3, 1.0));
	const float sy = static_cast<float>(luaL_optnumber(state, index + 4, sx));
	const float ox = static_cast<float>(luaL_optnumber(state, index + 5, 0.0));
	const float oy = static_cast<float>(luaL_optnumber(state, index + 6, 0.0));
	const float kx = static_cast<float>(luaL_optnumber(state, index + 7, 0.0));
	const float ky = static_cast<float>(luaL_optnumber(state, index + 8, 0.0));
	const float values[] = {x, y, angle, sx, sy, ox, oy, kx, ky};
	for (const float value : values)
		luaL_argcheck(state, std::isfinite(value), index, "Text transform values must be finite");
	setTransform(transform, x, y, angle, sx, sy, ox, oy, kx, ky);
}
}

int LoveRuntime::graphicsNewText(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime == runtime && runtime->_fontHandles.contains(font->handle), 1,
		"Font belongs to another or closed LoveRuntime");
	const bool hasInitialText = !lua_isnoneornil(state, 2);
	auto *text = new TextUserdata;
	text->runtime = runtime;
	text->font = font->handle;
	text->fontObject.set(font);
	::love::luax_pushtype(state, TextLoveType, text);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	if (hasInitialText)
	{
		TextEntry entry; entry.fragments = readTextFragments(state, 2);
		setTransformIdentity(entry.transform);
		bool empty = true; for (const auto &fragment : entry.fragments) empty &= fragment.text.empty();
		if (!empty)
		{
			layoutTextEntry(entry, *runtime->_graphicsBackend, text->font);
			text->entries.push_back(std::move(entry));
		}
	}
	text->release();
	return 1;
}

int LoveRuntime::graphicsNewShader(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	const int count = lua_isnoneornil(state, 2) ? 1 : 2;
	std::vector<std::string> arguments(static_cast<std::size_t>(count));
	std::string error;
	for (int index = 0; index < count; ++index)
		if (!loadShaderArgument(state, index + 1, runtime, arguments[static_cast<std::size_t>(index)], error))
			return luaL_argerror(state, index + 1, error.c_str());
	std::string vertex;
	std::string pixel;
	if (!classifyShaderSources(arguments, vertex, pixel, error))
		return luaL_error(state, "%s", error.c_str());
	std::string warnings;
	const auto handle = runtime->_graphicsBackend->newShader(vertex, pixel, warnings, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.c_str());
	auto *shader = new ShaderUserdata(runtime, handle, std::move(warnings));
	pushNewDoraHandleObject(state, ShaderUserdata::type, shader);
	lua_newtable(state);
	lua_setiuservalue(state, -2, 1);
	return 1;
}

int LoveRuntime::graphicsValidateShader(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	if (!runtime->_graphicsBackend)
	{
		lua_pushboolean(state, false);
		lua_pushliteral(state, "love.graphics is not attached to a Dora graphics backend");
		return 2;
	}
	const int count = lua_isnoneornil(state, 3) ? 1 : 2;
	std::vector<std::string> arguments(static_cast<std::size_t>(count));
	std::string error;
	for (int index = 0; index < count; ++index)
	{
		if (!loadShaderArgument(state, index + 2, runtime, arguments[static_cast<std::size_t>(index)], error))
		{
			lua_pushboolean(state, false);
			lua_pushlstring(state, error.data(), error.size());
			return 2;
		}
	}
	std::string vertex;
	std::string pixel;
	if (!classifyShaderSources(arguments, vertex, pixel, error)
		|| !runtime->_graphicsBackend->validateShader(vertex, pixel, error))
	{
		lua_pushboolean(state, false);
		lua_pushlstring(state, error.data(), error.size());
		return 2;
	}
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::graphicsSetShader(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	GraphicsBackend::ShaderHandle handle = 0;
	ShaderUserdata *shaderObject = nullptr;
	if (!lua_isnoneornil(state, 1))
	{
		auto *shader = checkShader(state, 1);
		luaL_argcheck(state, shader->runtime == runtime && shader->handle != 0
			&& runtime->_shaderHandles.contains(shader->handle), 1,
			"Shader belongs to another or closed LoveRuntime");
		handle = shader->handle;
		shaderObject = shader;
	}
	std::string error;
	if (runtime->_graphicsBackend && !runtime->_graphicsBackend->setShader(handle, error))
		return luaL_error(state, "%s", error.c_str());
	if (runtime->_graphicsShaderReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX, runtime->_graphicsShaderReference);
	runtime->_graphicsShaderReference = LUA_NOREF;
	runtime->_graphicsShader = handle;
	runtime->_graphicsShaderObject.set(shaderObject);
	if (handle != 0)
	{
		lua_pushvalue(state, 1);
		runtime->_graphicsShaderReference = luaL_ref(state, LUA_REGISTRYINDEX);
	}
	return 0;
}

int LoveRuntime::graphicsGetShader(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsShaderObject)
		lua_pushnil(state);
	else
		::love::luax_pushtype(state, ShaderUserdata::type,
			static_cast<ShaderUserdata *>(runtime->_graphicsShaderObject.get()));
	return 1;
}

int LoveRuntime::graphicsDraw(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	const bool instanced = lua_type(state, lua_upvalueindex(2)) == LUA_TBOOLEAN
		&& lua_toboolean(state, lua_upvalueindex(2));
	if (instanced && !luaL_testudata(state, 1, MeshLoveType.getName()))
		return luaL_argerror(state, 1, "expected a Mesh");
	if (auto *video = testVideo(state, 1))
	{
		luaL_argcheck(state, video->runtime == runtime && video->handle != 0, 1,
			"Video belongs to another or closed LoveRuntime");
		if (video->state->stream->swapBuffers())
		{
			const auto *frame = static_cast<const ::love::video::VideoStream::Frame *>(
				video->state->stream->getFrontBuffer());
			auto rgba = convertVideoFrame(*frame);
			std::string error;
			if (!runtime->_graphicsBackend->updateImage(video->handle, frame->yw, frame->yh,
				rgba, error))
				return luaL_error(state, "Love Video frame upload failed: %s", error.c_str());
		}
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError))
			return luaL_error(state, "%s", shaderError.c_str());
		const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
		const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
		const float angle = static_cast<float>(luaL_optnumber(state, 4, 0.0));
		const float scaleX = static_cast<float>(luaL_optnumber(state, 5, 1.0));
		const float scaleY = static_cast<float>(luaL_optnumber(state, 6, scaleX));
		const float originX = static_cast<float>(luaL_optnumber(state, 7, 0.0));
		const float originY = static_cast<float>(luaL_optnumber(state, 8, 0.0));
		const float shearX = static_cast<float>(luaL_optnumber(state, 9, 0.0));
		const float shearY = static_cast<float>(luaL_optnumber(state, 10, 0.0));
		const float values[] = {x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY};
		for (const float value : values)
			luaL_argcheck(state, std::isfinite(value), 2, "Video draw transform values must be finite");
		const float cosine = std::cos(angle), sine = std::sin(angle);
		const float localA = cosine * scaleX - sine * scaleY * shearY;
		const float localB = sine * scaleX + cosine * scaleY * shearY;
		const float localC = cosine * scaleX * shearX - sine * scaleY;
		const float localD = sine * scaleX * shearX + cosine * scaleY;
		const GraphicsTransform current = runtime->_graphicsTransform;
		const float a = current.a * localA + current.c * localB;
		const float b = current.b * localA + current.d * localB;
		const float c = current.a * localC + current.c * localD;
		const float d = current.b * localC + current.d * localD;
		const float tx = current.a * x + current.c * y + current.tx;
		const float ty = current.b * x + current.d * y + current.ty;
		const float width = static_cast<float>(video->state->stream->getWidth());
		const float height = static_cast<float>(video->state->stream->getHeight());
		runtime->_graphicsBackend->drawImage(video->handle, 0.0f, 0.0f, width, height,
			a, b, c, d, tx, ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			video->filter, GraphicsBackend::TextureWrap::Clamp,
			GraphicsBackend::TextureWrap::Clamp);
		return 0;
	}
	auto *text = luaL_testudata(state, 1, TextLoveType.getName())
		? ::love::luax_checktype<TextUserdata>(state, 1, TextLoveType) : nullptr;
	if (text)
	{
		luaL_argcheck(state, text->runtime == runtime && runtime->_fontHandles.contains(text->font), 1,
			"Text belongs to another or closed LoveRuntime");
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError))
			return luaL_error(state, "%s", shaderError.c_str());
		auto *font = static_cast<FontUserdata *>(text->fontObject.get());
		luaL_argcheck(state, font && font->runtime == runtime && font->handle == text->font, 1,
			"Text Font reference is missing or closed");
		const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
		const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
		const float angle = static_cast<float>(luaL_optnumber(state, 4, 0.0));
		const float scaleX = static_cast<float>(luaL_optnumber(state, 5, 1.0));
		const float scaleY = static_cast<float>(luaL_optnumber(state, 6, scaleX));
		const float originX = static_cast<float>(luaL_optnumber(state, 7, 0.0));
		const float originY = static_cast<float>(luaL_optnumber(state, 8, 0.0));
		const float shearX = static_cast<float>(luaL_optnumber(state, 9, 0.0));
		const float shearY = static_cast<float>(luaL_optnumber(state, 10, 0.0));
		const float parameters[] = {x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY};
		for (const float value : parameters)
			luaL_argcheck(state, std::isfinite(value), 2, "Text draw transform values must be finite");
		TransformUserdata local; setTransform(local, x, y, angle,
			scaleX, scaleY, originX, originY, shearX, shearY);
		TransformUserdata current; setTransformIdentity(current);
		current.elements[0] = runtime->_graphicsTransform.a;
		current.elements[1] = runtime->_graphicsTransform.b;
		current.elements[4] = runtime->_graphicsTransform.c;
		current.elements[5] = runtime->_graphicsTransform.d;
		current.elements[12] = runtime->_graphicsTransform.tx;
		current.elements[13] = runtime->_graphicsTransform.ty;
		TransformUserdata outer; multiplyTransforms(current, local, outer);
		for (const auto &entry : text->entries)
		{
			TransformUserdata combined; multiplyTransforms(outer, entry.transform, combined);
			for (const auto &run : entry.runs)
			{
				const float tx = combined.elements[12] + combined.elements[0] * run.x
					+ combined.elements[4] * run.y;
				const float ty = combined.elements[13] + combined.elements[1] * run.x
					+ combined.elements[5] * run.y;
				runtime->_graphicsBackend->drawText(text->font, run.text, -1.0f, "left",
					combined.elements[0], combined.elements[1], combined.elements[4], combined.elements[5],
					tx, ty, 0.0f, 0.0f,
					run.color[0] * runtime->_graphicsColor[0], run.color[1] * runtime->_graphicsColor[1],
					run.color[2] * runtime->_graphicsColor[2], run.color[3] * runtime->_graphicsColor[3]);
			}
		}
		return 0;
	}
	auto *particleSystem = luaL_testudata(state, 1, ParticleSystemLoveType.getName())
		? ::love::luax_checktype<ParticleSystemUserdata>(state, 1, ParticleSystemLoveType) : nullptr;
	if (particleSystem)
	{
		luaL_argcheck(state, particleSystem->runtime == runtime, 1,
			"ParticleSystem belongs to another LoveRuntime");
		if (particleSystem->particles.empty()) return 0;
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError))
			return luaL_error(state, "%s", shaderError.c_str());
		const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
		const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
		const float angle = static_cast<float>(luaL_optnumber(state, 4, 0.0));
		const float scaleX = static_cast<float>(luaL_optnumber(state, 5, 1.0));
		const float scaleY = static_cast<float>(luaL_optnumber(state, 6, scaleX));
		const float originX = static_cast<float>(luaL_optnumber(state, 7, 0.0));
		const float originY = static_cast<float>(luaL_optnumber(state, 8, 0.0));
		const float shearX = static_cast<float>(luaL_optnumber(state, 9, 0.0));
		const float shearY = static_cast<float>(luaL_optnumber(state, 10, 0.0));
		const float parameters[] = {x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY};
		for (const float value : parameters)
			luaL_argcheck(state, std::isfinite(value), 2,
				"ParticleSystem draw transform values must be finite");
		const float cosine = std::cos(angle), sine = std::sin(angle);
		const float localA = cosine * scaleX - sine * scaleY * shearY;
		const float localB = sine * scaleX + cosine * scaleY * shearY;
		const float localC = cosine * scaleX * shearX - sine * scaleY;
		const float localD = sine * scaleX * shearX + cosine * scaleY;
		const GraphicsTransform current = runtime->_graphicsTransform;
		const float a = current.a * localA + current.c * localB;
		const float b = current.b * localA + current.d * localB;
		const float c = current.a * localC + current.c * localD;
		const float d = current.b * localC + current.d * localD;
		const float tx = current.a * x + current.c * y + current.tx - a * originX - c * originY;
		const float ty = current.b * x + current.d * y + current.ty - b * originX - d * originY;
		GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
		GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
		GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
		int textureWidth = 0, textureHeight = 0;
		if (particleSystem->image != 0)
		{
			auto *texture = static_cast<ImageUserdata *>(particleSystem->textureObject.get());
			luaL_argcheck(state, texture->runtime == runtime && texture->handle == particleSystem->image,
				1, "ParticleSystem Image texture is closed");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
			textureWidth = runtime->_graphicsBackend->getImageWidth(texture->handle);
			textureHeight = runtime->_graphicsBackend->getImageHeight(texture->handle);
		}
		else if (particleSystem->canvas != 0)
		{
			auto *texture = static_cast<CanvasUserdata *>(particleSystem->textureObject.get());
			luaL_argcheck(state, texture->runtime == runtime && texture->handle == particleSystem->canvas
				&& runtime->_canvasHandles.contains(texture->handle), 1,
				"ParticleSystem Canvas texture is closed");
			luaL_argcheck(state, texture->readable, 1,
				"cannot draw a ParticleSystem with a non-readable Canvas texture");
			luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(),
				runtime->_graphicsCanvases.end(), texture->handle) == runtime->_graphicsCanvases.end()
				&& texture->handle != runtime->_graphicsCanvasDepthStencil, 1,
				"cannot draw a ParticleSystem Canvas to itself");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
			textureWidth = runtime->_graphicsBackend->getCanvasWidth(texture->handle);
			textureHeight = runtime->_graphicsBackend->getCanvasHeight(texture->handle);
		}
		else return luaL_error(state, "ParticleSystem texture reference is missing");
		std::vector<GraphicsBackend::MeshVertex> vertices;
		std::vector<std::uint32_t> indices;
		vertices.reserve(particleSystem->particles.size() * 4);
		indices.reserve(particleSystem->particles.size() * 6);
		for (const auto &particle : particleSystem->particles)
		{
			float sourceX = 0.0f, sourceY = 0.0f;
			float sourceWidth = static_cast<float>(textureWidth);
			float sourceHeight = static_cast<float>(textureHeight);
			float uvWidth = sourceWidth, uvHeight = sourceHeight;
			if (!particleSystem->quads.empty())
			{
				const auto &quad = particleSystem->quads[std::min(particle.quadIndex,
					particleSystem->quads.size() - 1)];
				sourceX = quad.x; sourceY = quad.y; sourceWidth = quad.width; sourceHeight = quad.height;
				uvWidth = quad.textureWidth; uvHeight = quad.textureHeight;
			}
			const float pc = std::cos(particle.angle) * particle.size;
			const float ps = std::sin(particle.angle) * particle.size;
			const float ptx = particle.x - pc * particleSystem->offsetX + ps * particleSystem->offsetY;
			const float pty = particle.y - ps * particleSystem->offsetX - pc * particleSystem->offsetY;
			const float positions[4][2] = {{0.0f, 0.0f}, {sourceWidth, 0.0f},
				{sourceWidth, sourceHeight}, {0.0f, sourceHeight}};
			const float texcoords[4][2] = {{sourceX / uvWidth, sourceY / uvHeight},
				{(sourceX + sourceWidth) / uvWidth, sourceY / uvHeight},
				{(sourceX + sourceWidth) / uvWidth, (sourceY + sourceHeight) / uvHeight},
				{sourceX / uvWidth, (sourceY + sourceHeight) / uvHeight}};
			const std::uint32_t base = static_cast<std::uint32_t>(vertices.size());
			for (int vertexIndex = 0; vertexIndex < 4; ++vertexIndex)
			{
				const float px = positions[vertexIndex][0], py = positions[vertexIndex][1];
				const float localX = pc * px - ps * py + ptx;
				const float localY = ps * px + pc * py + pty;
				GraphicsBackend::MeshVertex vertex;
				vertex.x = a * localX + c * localY + tx;
				vertex.y = b * localX + d * localY + ty;
				vertex.u = texcoords[vertexIndex][0]; vertex.v = texcoords[vertexIndex][1];
				vertex.red = particle.color.red * runtime->_graphicsColor[0];
				vertex.green = particle.color.green * runtime->_graphicsColor[1];
				vertex.blue = particle.color.blue * runtime->_graphicsColor[2];
				vertex.alpha = particle.color.alpha * runtime->_graphicsColor[3];
				vertices.push_back(vertex);
			}
			indices.insert(indices.end(), {base, base + 1, base + 2, base, base + 2, base + 3});
		}
		std::string error;
		if (!runtime->_graphicsBackend->drawMesh(vertices, {}, indices, "triangles",
			particleSystem->image, particleSystem->canvas, runtime->_graphicsPointSize,
			filter, wrapU, wrapV, error))
			return luaL_error(state, "%s", error.c_str());
		return 0;
	}
	auto *batch = luaL_testudata(state, 1, SpriteBatchLoveType.getName())
		? ::love::luax_checktype<SpriteBatchUserdata>(state, 1, SpriteBatchLoveType) : nullptr;
	if (batch)
	{
		luaL_argcheck(state, batch->runtime == runtime, 1,
			"SpriteBatch belongs to another LoveRuntime");
		if (batch->count == 0) return 0;
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError, batch->textureType))
			return luaL_error(state, "%s", shaderError.c_str());
		const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
		const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
		const float angle = static_cast<float>(luaL_optnumber(state, 4, 0.0));
		const float scaleX = static_cast<float>(luaL_optnumber(state, 5, 1.0));
		const float scaleY = static_cast<float>(luaL_optnumber(state, 6, scaleX));
		const float originX = static_cast<float>(luaL_optnumber(state, 7, 0.0));
		const float originY = static_cast<float>(luaL_optnumber(state, 8, 0.0));
		const float shearX = static_cast<float>(luaL_optnumber(state, 9, 0.0));
		const float shearY = static_cast<float>(luaL_optnumber(state, 10, 0.0));
		const float parameters[] = {x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY};
		for (const float value : parameters)
			luaL_argcheck(state, std::isfinite(value), 2,
				"SpriteBatch draw transform values must be finite");
		const float cosine = std::cos(angle);
		const float sine = std::sin(angle);
		const float localA = cosine * scaleX - sine * scaleY * shearY;
		const float localB = sine * scaleX + cosine * scaleY * shearY;
		const float localC = cosine * scaleX * shearX - sine * scaleY;
		const float localD = sine * scaleX * shearX + cosine * scaleY;
		const GraphicsTransform current = runtime->_graphicsTransform;
		const float a = current.a * localA + current.c * localB;
		const float b = current.b * localA + current.d * localB;
		const float c = current.a * localC + current.c * localD;
		const float d = current.b * localC + current.d * localD;
		const float tx = current.a * x + current.c * y + current.tx - a * originX - c * originY;
		const float ty = current.b * x + current.d * y + current.ty - b * originX - d * originY;
		const std::size_t start = batch->drawStart < 0 ? 0
			: std::min(static_cast<std::size_t>(batch->drawStart), batch->count - 1);
		const std::size_t requested = batch->drawCount > 0
			? static_cast<std::size_t>(batch->drawCount) : batch->count;
		const std::size_t count = std::min(requested, batch->count - start);
		for (const auto &[name, attachment] : batch->attachments)
		{
			luaL_argcheck(state, attachment.mesh && attachment.mesh->runtime == runtime
				&& attachment.attributeIndex < attachment.mesh->format.size(), 1,
				"SpriteBatch attached Mesh is closed");
			luaL_argcheck(state, batch->count <= std::numeric_limits<std::size_t>::max() / 4
				&& attachment.mesh->vertexCount >= batch->count * 4, 1,
				("Mesh with attribute '" + name
					+ "' attached to this SpriteBatch has too few vertices").c_str());
		}
		const auto attachmentFor = [batch](std::string_view name) -> const SpriteBatchAttachment * {
			const auto found = batch->attachments.find(std::string(name));
			return found == batch->attachments.end() ? nullptr : &found->second;
		};
		const auto attachmentValues = [](const SpriteBatchAttachment &attachment,
			std::size_t vertexIndex) -> const float * {
			const auto *mesh = attachment.mesh;
			const auto &attribute = mesh->format[attachment.attributeIndex];
			return mesh->values.data() + vertexIndex * mesh->componentCount + attribute.offset;
		};
		const auto *positionAttachment = attachmentFor("VertexPosition");
		const auto *texcoordAttachment = attachmentFor("VertexTexCoord");
		const auto *colorAttachment = attachmentFor("VertexColor");
		if (positionAttachment)
		{
			const auto &attribute = positionAttachment->mesh->format[positionAttachment->attributeIndex];
			luaL_argcheck(state, attribute.type == "float" && attribute.components >= 2, 1,
				"SpriteBatch VertexPosition attachment must be a float attribute with at least 2 components");
		}
		if (texcoordAttachment)
		{
			const auto &attribute = texcoordAttachment->mesh->format[texcoordAttachment->attributeIndex];
			luaL_argcheck(state, attribute.components >= 2, 1,
				"SpriteBatch VertexTexCoord attachment must have at least 2 components");
		}
		if (colorAttachment)
		{
			const auto &attribute = colorAttachment->mesh->format[colorAttachment->attributeIndex];
			luaL_argcheck(state, attribute.components >= 1, 1,
				"SpriteBatch VertexColor attachment must have at least 1 component");
		}
		std::vector<GraphicsBackend::MeshVertex> vertices;
		std::vector<std::uint32_t> indices;
		vertices.reserve(count * 4);
		indices.reserve(count * 6);
		for (std::size_t spriteIndex = 0; spriteIndex < count; ++spriteIndex)
		{
			const auto &sprite = batch->sprites[start + spriteIndex];
			const std::uint32_t base = static_cast<std::uint32_t>(vertices.size());
			for (std::size_t localVertex = 0; localVertex < 4; ++localVertex)
			{
				const auto &source = sprite.vertices[localVertex];
				auto vertex = source;
				const std::size_t sourceVertex = (start + spriteIndex) * 4 + localVertex;
				if (positionAttachment)
				{
					const auto &attribute = positionAttachment->mesh->format[positionAttachment->attributeIndex];
					const float *values = attachmentValues(*positionAttachment, sourceVertex);
					vertex.x = values[0]; vertex.y = values[1];
					if (attribute.components >= 3) vertex.z = values[2];
					if (attribute.components >= 4) vertex.w = values[3];
				}
				if (texcoordAttachment)
				{
					const auto &attribute = texcoordAttachment->mesh->format[texcoordAttachment->attributeIndex];
					const float *values = attachmentValues(*texcoordAttachment, sourceVertex);
					vertex.u = values[0]; vertex.v = values[1];
					if (batch->textureType == GraphicsBackend::TextureType::Array)
						vertex.textureLayer = attribute.components >= 3 ? values[2] : 0.0f;
				}
				if (colorAttachment)
				{
					const auto &attribute = colorAttachment->mesh->format[colorAttachment->attributeIndex];
					const float *values = attachmentValues(*colorAttachment, sourceVertex);
					vertex.red = values[0];
					vertex.green = attribute.components >= 2 ? values[1] : 0.0f;
					vertex.blue = attribute.components >= 3 ? values[2] : 0.0f;
					vertex.alpha = attribute.components >= 4 ? values[3] : 1.0f;
				}
				const float localX = vertex.x, localY = vertex.y;
				vertex.x = a * localX + c * localY + tx;
				vertex.y = b * localX + d * localY + ty;
				vertex.red *= runtime->_graphicsColor[0];
				vertex.green *= runtime->_graphicsColor[1];
				vertex.blue *= runtime->_graphicsColor[2];
				vertex.alpha *= runtime->_graphicsColor[3];
				vertices.push_back(vertex);
			}
			indices.insert(indices.end(), {base, base + 1, base + 2, base, base + 2, base + 3});
		}
		std::vector<GraphicsBackend::MeshAttributeData> customAttributes;
		customAttributes.reserve(batch->attachments.size());
		for (const auto &[name, attachment] : batch->attachments)
		{
			if (name == "VertexPosition" || name == "VertexTexCoord" || name == "VertexColor")
				continue;
			const auto &attribute = attachment.mesh->format[attachment.attributeIndex];
			GraphicsBackend::MeshAttributeData data;
			data.name = name;
			data.components = attribute.components;
			data.values.reserve(count * 4 * static_cast<std::size_t>(attribute.components));
			for (std::size_t spriteIndex = 0; spriteIndex < count; ++spriteIndex)
			for (std::size_t localVertex = 0; localVertex < 4; ++localVertex)
			{
				const std::size_t sourceVertex = (start + spriteIndex) * 4 + localVertex;
				const float *values = attachmentValues(attachment, sourceVertex);
				data.values.insert(data.values.end(), values, values + attribute.components);
			}
			customAttributes.push_back(std::move(data));
		}
		GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
		GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
		GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
		if (batch->image != 0)
		{
			auto *texture = static_cast<ImageUserdata *>(batch->textureObject.get());
			luaL_argcheck(state, texture->runtime == runtime && texture->handle == batch->image
				&& texture->textureType == batch->textureType, 1,
				"SpriteBatch Image texture is closed");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
		}
		else if (batch->canvas != 0)
		{
			auto *texture = static_cast<CanvasUserdata *>(batch->textureObject.get());
			luaL_argcheck(state, texture->runtime == runtime && texture->handle == batch->canvas
				&& runtime->_canvasHandles.contains(texture->handle), 1,
				"SpriteBatch Canvas texture is closed");
			luaL_argcheck(state, texture->readable, 1,
				"cannot draw a SpriteBatch with a non-readable Canvas texture");
			luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(),
				runtime->_graphicsCanvases.end(), texture->handle) == runtime->_graphicsCanvases.end()
				&& texture->handle != runtime->_graphicsCanvasDepthStencil, 1,
				"cannot draw a SpriteBatch Canvas to itself");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
		}
		else return luaL_error(state, "SpriteBatch texture reference is missing");
		std::string error;
		if (!runtime->_graphicsBackend->drawMesh(vertices, customAttributes, indices, "triangles",
			batch->image, batch->canvas, runtime->_graphicsPointSize,
			filter, wrapU, wrapV, error))
			return luaL_error(state, "%s", error.c_str());
		return 0;
	}
	auto *mesh = luaL_testudata(state, 1, MeshLoveType.getName())
		? ::love::luax_checktype<MeshUserdata>(state, 1, MeshLoveType) : nullptr;
	if (mesh)
	{
		luaL_argcheck(state, mesh->runtime == runtime, 1, "Mesh belongs to another LoveRuntime");
		const int instanceCount = instanced ? static_cast<int>(luaL_checkinteger(state, 2)) : 1;
		const int transformStart = instanced ? 3 : 2;
		const float x = static_cast<float>(luaL_optnumber(state, transformStart, 0.0));
		const float y = static_cast<float>(luaL_optnumber(state, transformStart + 1, 0.0));
		const float angle = static_cast<float>(luaL_optnumber(state, transformStart + 2, 0.0));
		const float scaleX = static_cast<float>(luaL_optnumber(state, transformStart + 3, 1.0));
		const float scaleY = static_cast<float>(luaL_optnumber(state, transformStart + 4, scaleX));
		const float originX = static_cast<float>(luaL_optnumber(state, transformStart + 5, 0.0));
		const float originY = static_cast<float>(luaL_optnumber(state, transformStart + 6, 0.0));
		const float shearX = static_cast<float>(luaL_optnumber(state, transformStart + 7, 0.0));
		const float shearY = static_cast<float>(luaL_optnumber(state, transformStart + 8, 0.0));
		const float parameters[] = {x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY};
		for (const float value : parameters)
			luaL_argcheck(state, std::isfinite(value), transformStart,
				"Mesh draw transform values must be finite");
		if (instanceCount <= 0) return 0;
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError))
			return luaL_error(state, "%s", shaderError.c_str());
		const float cosine = std::cos(angle);
		const float sine = std::sin(angle);
		const float localA = cosine * scaleX - sine * scaleY * shearY;
		const float localB = sine * scaleX + cosine * scaleY * shearY;
		const float localC = cosine * scaleX * shearX - sine * scaleY;
		const float localD = sine * scaleX * shearX + cosine * scaleY;
		const GraphicsTransform current = runtime->_graphicsTransform;
		const float a = current.a * localA + current.c * localB;
		const float b = current.b * localA + current.d * localB;
		const float c = current.a * localC + current.c * localD;
		const float d = current.b * localC + current.d * localD;
		const float tx = current.a * x + current.c * y + current.tx - a * originX - c * originY;
		const float ty = current.b * x + current.d * y + current.ty - b * originX - d * originY;
		std::size_t perInstanceAttributeCount = 0;
		if (instanced && instanceCount > 1 && runtime->_graphicsShader != 0)
		{
			for (const auto &[name, attachment] : mesh->attachments)
			{
				(void)name;
				if (attachment.enabled && attachment.step == "perinstance")
					++perInstanceAttributeCount;
			}
		}
		const bool hardwareInstancing = instanced && instanceCount > 1
			&& runtime->_graphicsShader != 0
			&& runtime->_graphicsBackend->supportsMeshInstancing(
				runtime->_graphicsShader, perInstanceAttributeCount);
		if (instanced && instanceCount > 1 && runtime->_graphicsShader != 0
			&& !hardwareInstancing
			&& runtime->_graphicsBackend->requiresMeshInstancing(runtime->_graphicsShader))
			return luaL_error(state,
				"active Shader uses love_InstanceID but hardware Mesh instancing is unavailable");
		const std::size_t expandedInstances = hardwareInstancing ? 1
			: static_cast<std::size_t>(instanceCount);
		luaL_argcheck(state, expandedInstances
			<= std::numeric_limits<std::size_t>::max() / mesh->vertexCount, 2,
			"Mesh instance count is too large");
		const std::size_t expandedVertexCount = mesh->vertexCount
			* expandedInstances;
		luaL_argcheck(state, expandedVertexCount <= std::numeric_limits<std::uint32_t>::max(), 2,
			"instanced Mesh exceeds Dora/bgfx's 32-bit vertex limit");
		std::vector<GraphicsBackend::MeshVertex> vertices(expandedVertexCount);
		struct ResolvedAttribute
		{
			const MeshUserdata *mesh = nullptr;
			const MeshAttribute *attribute = nullptr;
			bool perInstance = false;
		};
		const auto resolveAttribute = [mesh](std::string_view name) -> ResolvedAttribute {
			if (const auto attached = mesh->attachments.find(std::string(name));
				attached != mesh->attachments.end())
			{
				if (!attached->second.enabled) return {};
				const auto *source = attached->second.mesh;
				return {source, &source->format[attached->second.attributeIndex],
					attached->second.step == "perinstance"};
			}
			const std::size_t index = meshAttributeIndex(*mesh, name);
			if (index == mesh->format.size() || !mesh->format[index].enabled) return {};
			return {mesh, &mesh->format[index], false};
		};
		const auto position = resolveAttribute("VertexPosition");
		const auto texcoord = resolveAttribute("VertexTexCoord");
		const auto color = resolveAttribute("VertexColor");
		luaL_argcheck(state, position.attribute && position.attribute->type == "float"
			&& position.attribute->components >= 2, 1,
			"Mesh drawing requires a float VertexPosition attribute with at least 2 components");
		const auto attributeValues = [state](const ResolvedAttribute &resolved,
			std::size_t targetIndex, std::size_t instanceIndex) -> const float * {
			if (!resolved.attribute) return nullptr;
			const std::size_t sourceIndex = resolved.perInstance ? instanceIndex : targetIndex;
			luaL_argcheck(state, sourceIndex < resolved.mesh->vertexCount, 1,
				"attached Mesh attribute does not contain enough vertices");
			return resolved.mesh->values.data() + sourceIndex * resolved.mesh->componentCount
				+ resolved.attribute->offset;
		};
		for (std::size_t instanceIndex = 0; instanceIndex < expandedInstances;
			++instanceIndex)
		for (std::size_t index = 0; index < mesh->vertexCount; ++index)
		{
			auto &vertex = vertices[instanceIndex * mesh->vertexCount + index];
			const float *positionValues = attributeValues(position, index, instanceIndex);
			const float px = positionValues[0];
			const float py = positionValues[1];
			vertex.x = a * px + c * py + tx;
			vertex.y = b * px + d * py + ty;
			if (position.attribute->components >= 3) vertex.z = positionValues[2];
			if (position.attribute->components >= 4) vertex.w = positionValues[3];
			if (texcoord.attribute && texcoord.attribute->components >= 2)
			{
				const float *texcoordValues = attributeValues(texcoord, index, instanceIndex);
				vertex.u = texcoordValues[0];
				vertex.v = texcoordValues[1];
			}
			if (color.attribute)
			{
				const float *colorValues = attributeValues(color, index, instanceIndex);
				if (color.attribute->components >= 1) vertex.red = colorValues[0];
				if (color.attribute->components >= 2) vertex.green = colorValues[1];
				if (color.attribute->components >= 3) vertex.blue = colorValues[2];
				if (color.attribute->components >= 4) vertex.alpha = colorValues[3];
			}
			vertex.red *= runtime->_graphicsColor[0];
			vertex.green *= runtime->_graphicsColor[1];
			vertex.blue *= runtime->_graphicsColor[2];
			vertex.alpha *= runtime->_graphicsColor[3];
		}
		std::vector<GraphicsBackend::MeshAttributeData> customAttributes;
		std::unordered_set<std::string> customNames;
		const auto appendCustomAttribute = [&](std::string_view name) {
			if (name == "VertexPosition" || name == "VertexTexCoord" || name == "VertexColor"
				|| !customNames.emplace(name).second)
				return;
			const auto resolved = resolveAttribute(name);
			if (!resolved.attribute) return;
			GraphicsBackend::MeshAttributeData data;
			data.name = name;
			data.components = resolved.attribute->components;
			data.perInstance = hardwareInstancing && resolved.perInstance;
			const std::size_t valueRows = data.perInstance
				? static_cast<std::size_t>(instanceCount) : expandedVertexCount;
			data.values.reserve(valueRows * static_cast<std::size_t>(data.components));
			const std::size_t attributeInstances = data.perInstance
				? static_cast<std::size_t>(instanceCount) : expandedInstances;
			const std::size_t verticesPerAttributeInstance = data.perInstance ? 1 : mesh->vertexCount;
			for (std::size_t instanceIndex = 0; instanceIndex < attributeInstances; ++instanceIndex)
			for (std::size_t vertexIndex = 0;
				vertexIndex < verticesPerAttributeInstance; ++vertexIndex)
			{
				const float *values = attributeValues(resolved, vertexIndex, instanceIndex);
				data.values.insert(data.values.end(), values, values + data.components);
			}
			customAttributes.push_back(std::move(data));
		};
		for (const auto &attribute : mesh->format)
			appendCustomAttribute(attribute.name);
		for (const auto &[name, attachment] : mesh->attachments)
		{
			(void)attachment;
			appendCustomAttribute(name);
		}
		if (runtime->_graphicsShader != 0
			&& runtime->_graphicsBackend->requiresMeshVertexID(runtime->_graphicsShader))
		{
			GraphicsBackend::MeshAttributeData vertexIDs;
			vertexIDs.name = "__DoraLoveVertexID";
			vertexIDs.components = 1;
			vertexIDs.values.reserve(expandedVertexCount);
			for (std::size_t instanceIndex = 0; instanceIndex < expandedInstances; ++instanceIndex)
				for (std::size_t vertexIndex = 0; vertexIndex < mesh->vertexCount; ++vertexIndex)
					vertexIDs.values.push_back(static_cast<float>(vertexIndex));
			customAttributes.push_back(std::move(vertexIDs));
		}
		if (hardwareInstancing)
		{
			const auto appendBuiltinInstanceAttribute = [&](std::string_view name,
				const ResolvedAttribute &resolved) {
				if (!resolved.attribute || !resolved.perInstance) return;
				GraphicsBackend::MeshAttributeData data;
				data.name = name;
				data.components = resolved.attribute->components;
				data.perInstance = true;
				data.values.reserve(static_cast<std::size_t>(instanceCount)
					* static_cast<std::size_t>(data.components));
				for (std::size_t instanceIndex = 0;
					instanceIndex < static_cast<std::size_t>(instanceCount); ++instanceIndex)
				{
					const float *values = attributeValues(resolved, 0, instanceIndex);
					data.values.insert(data.values.end(), values, values + data.components);
				}
				customAttributes.push_back(std::move(data));
			};
			appendBuiltinInstanceAttribute("VertexPosition", position);
			appendBuiltinInstanceAttribute("VertexTexCoord", texcoord);
			appendBuiltinInstanceAttribute("VertexColor", color);
		}
		std::vector<std::uint32_t> indices;
		if (!mesh->useVertexMap)
		{
			indices.resize(mesh->vertexCount);
			for (std::size_t index = 0; index < mesh->vertexCount; ++index)
				indices[index] = static_cast<std::uint32_t>(index);
		}
		else indices = mesh->vertexMap;
		if (mesh->drawStart >= 0)
		{
			const std::size_t start = static_cast<std::size_t>(mesh->drawStart);
			const std::size_t count = static_cast<std::size_t>(mesh->drawCount);
			luaL_argcheck(state, start <= indices.size() && count <= indices.size() - start, 1,
				"Mesh draw range exceeds its current vertex map");
			indices = std::vector<std::uint32_t>(indices.begin() + start, indices.begin() + start + count);
		}
		std::string submittedDrawMode = mesh->drawMode;
		if (!hardwareInstancing && instanceCount > 1
			&& (mesh->drawMode == "fan" || mesh->drawMode == "strip"))
		{
			std::vector<std::uint32_t> triangles;
			if (indices.size() >= 3)
			{
				triangles.reserve((indices.size() - 2) * 3);
				if (mesh->drawMode == "fan")
				{
					for (std::size_t index = 1; index + 1 < indices.size(); ++index)
						triangles.insert(triangles.end(), {indices[0], indices[index], indices[index + 1]});
				}
				else
				{
					for (std::size_t index = 0; index + 2 < indices.size(); ++index)
					{
						if ((index & 1) == 0)
							triangles.insert(triangles.end(), {indices[index], indices[index + 1], indices[index + 2]});
						else
							triangles.insert(triangles.end(), {indices[index + 1], indices[index], indices[index + 2]});
					}
				}
			}
			indices = std::move(triangles);
			submittedDrawMode = "triangles";
		}
		if (!hardwareInstancing && instanceCount > 1)
		{
			const auto baseIndices = indices;
			luaL_argcheck(state, baseIndices.empty()
				|| static_cast<std::size_t>(instanceCount)
					<= std::numeric_limits<std::size_t>::max() / baseIndices.size(), 2,
				"Mesh instance count is too large");
			indices.clear();
			indices.reserve(baseIndices.size() * static_cast<std::size_t>(instanceCount));
			for (std::size_t instanceIndex = 0;
				instanceIndex < static_cast<std::size_t>(instanceCount); ++instanceIndex)
			{
				const std::uint32_t offset = static_cast<std::uint32_t>(instanceIndex * mesh->vertexCount);
				for (const auto index : baseIndices) indices.push_back(index + offset);
			}
		}
		GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
		GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
		GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
		if (mesh->image != 0)
		{
			auto *texture = static_cast<ImageUserdata *>(mesh->textureObject.get());
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
		}
		else if (mesh->canvas != 0)
		{
			auto *texture = static_cast<CanvasUserdata *>(mesh->textureObject.get());
			luaL_argcheck(state, texture->readable, 1, "cannot draw a Mesh with a non-readable Canvas texture");
			luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(), runtime->_graphicsCanvases.end(),
				texture->handle) == runtime->_graphicsCanvases.end()
				&& texture->handle != runtime->_graphicsCanvasDepthStencil, 1,
				"cannot draw a Canvas to itself");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
		}
		std::string error;
		if (!runtime->_graphicsBackend->drawMesh(vertices, customAttributes, indices, submittedDrawMode,
			mesh->image, mesh->canvas, runtime->_graphicsPointSize, filter, wrapU, wrapV, error,
			hardwareInstancing ? instanceCount : 1))
			return luaL_error(state, "%s", error.c_str());
		return 0;
	}
	auto *image = testImage(state, 1);
	auto *canvas = testCanvas(state, 1);
	if (!image && !canvas)
		return luaL_argerror(state, 1, "expected an Image, Canvas, Mesh, SpriteBatch, ParticleSystem, or Text");
	if (image)
		luaL_argcheck(state, image->runtime == runtime && image->handle != 0, 1,
			"Image belongs to another or closed LoveRuntime");
	else
		luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
			&& runtime->_canvasHandles.contains(canvas->handle), 1,
			"Canvas belongs to another or closed LoveRuntime");
	if (canvas)
		luaL_argcheck(state, canvas->readable, 1, "cannot draw a non-readable Canvas");
	if (canvas)
		luaL_argcheck(state, canvas->textureType == GraphicsBackend::TextureType::Texture2D, 1,
			"non-2D Canvas textures must be drawn with a compatible layered API");
	if (canvas)
		luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(), runtime->_graphicsCanvases.end(),
			canvas->handle) == runtime->_graphicsCanvases.end()
			&& canvas->handle != runtime->_graphicsCanvasDepthStencil, 1,
			"cannot draw a Canvas to itself");
	std::string shaderError;
	if (!runtime->_graphicsBackend->validateShaderDraw(shaderError,
		image ? image->textureType : GraphicsBackend::TextureType::Texture2D))
		return luaL_error(state, "%s", shaderError.c_str());
	float sourceX = 0.0f;
	float sourceY = 0.0f;
	const float imageWidth = static_cast<float>(image
		? runtime->_graphicsBackend->getImageWidth(image->handle)
		: runtime->_graphicsBackend->getCanvasWidth(canvas->handle));
	const float imageHeight = static_cast<float>(image
		? runtime->_graphicsBackend->getImageHeight(image->handle)
		: runtime->_graphicsBackend->getCanvasHeight(canvas->handle));
	float sourceWidth = imageWidth;
	float sourceHeight = imageHeight;
	int imageLayer = 0;
	int startIndex = 2;
	if (auto *quad = luaL_testudata(state, 2, QuadLoveType.getName())
		? ::love::luax_checktype<QuadUserdata>(state, 2, QuadLoveType) : nullptr)
	{
		luaL_argcheck(state, quad->runtime == runtime, 2, "Quad belongs to another LoveRuntime");
		if (image && image->textureType == GraphicsBackend::TextureType::Array)
		{
			luaL_argcheck(state, quad->layer <= image->slices, 2,
				"Quad layer exceeds the ArrayImage layer count");
			imageLayer = quad->layer - 1;
		}
		else luaL_argcheck(state, quad->layer == 1, 2,
			"non-array embedded Dora Images support only Quad layer 1");
		sourceX = quad->x * imageWidth / quad->textureWidth;
		sourceY = quad->y * imageHeight / quad->textureHeight;
		sourceWidth = quad->width * imageWidth / quad->textureWidth;
		sourceHeight = quad->height * imageHeight / quad->textureHeight;
		startIndex = 3;
	}
	const float x = static_cast<float>(luaL_optnumber(state, startIndex, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, startIndex + 1, 0.0));
	const float angle = static_cast<float>(luaL_optnumber(state, startIndex + 2, 0.0));
	const float scaleX = static_cast<float>(luaL_optnumber(state, startIndex + 3, 1.0));
	const float scaleY = static_cast<float>(luaL_optnumber(state, startIndex + 4, scaleX));
	const float originX = static_cast<float>(luaL_optnumber(state, startIndex + 5, 0.0));
	const float originY = static_cast<float>(luaL_optnumber(state, startIndex + 6, 0.0));
	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	const GraphicsTransform current = runtime->_graphicsTransform;
	const float localA = cosine * scaleX;
	const float localB = sine * scaleX;
	const float localC = -sine * scaleY;
	const float localD = cosine * scaleY;
	const float a = current.a * localA + current.c * localB;
	const float b = current.b * localA + current.d * localB;
	const float c = current.a * localC + current.c * localD;
	const float d = current.b * localC + current.d * localD;
	const float tx = current.a * x + current.c * y + current.tx;
	const float ty = current.b * x + current.d * y + current.ty;
	if (image && image->textureType == GraphicsBackend::TextureType::Array)
	{
		std::string error;
		if (!runtime->_graphicsBackend->drawImageLayer(image->handle, imageLayer,
			sourceX, sourceY, sourceWidth, sourceHeight, a, b, c, d, tx, ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			image->filter, image->wrapU, image->wrapV, error))
			return luaL_error(state, "%s", error.c_str());
	}
	else if (image)
		runtime->_graphicsBackend->drawImage(image->handle,
			sourceX, sourceY, sourceWidth, sourceHeight, a, b, c, d, tx, ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			image->filter, image->wrapU, image->wrapV);
	else
		runtime->_graphicsBackend->drawCanvas(canvas->handle,
			sourceX, sourceY, sourceWidth, sourceHeight, a, b, c, d, tx, ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			canvas->filter, canvas->wrapU, canvas->wrapV);
	return 0;
}

int LoveRuntime::graphicsDrawLayer(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	auto *image = testImage(state, 1);
	auto *canvas = testCanvas(state, 1);
	luaL_argcheck(state, image || canvas, 1, "drawLayer requires an ArrayImage or array Canvas");
	if (image)
		luaL_argcheck(state, image->runtime == runtime && image->handle != 0
			&& image->textureType == GraphicsBackend::TextureType::Array, 1,
			"drawLayer requires an open ArrayImage from this LoveRuntime");
	else
		luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
			&& runtime->_canvasHandles.contains(canvas->handle)
			&& canvas->textureType == GraphicsBackend::TextureType::Array, 1,
			"drawLayer requires an open array Canvas from this LoveRuntime");
	const int sliceCount = image ? image->slices : canvas->slices;
	const lua_Integer requestedLayer = luaL_checkinteger(state, 2);
	luaL_argcheck(state, requestedLayer >= 1 && requestedLayer <= sliceCount, 2,
		"array texture layer is outside the available range");
	std::string shaderError;
	if (!runtime->_graphicsBackend->validateShaderDraw(
		shaderError, GraphicsBackend::TextureType::Array))
		return luaL_error(state, "%s", shaderError.c_str());
	const float imageWidth = static_cast<float>(image
		? runtime->_graphicsBackend->getImageWidth(image->handle)
		: runtime->_graphicsBackend->getCanvasWidth(canvas->handle));
	const float imageHeight = static_cast<float>(image
		? runtime->_graphicsBackend->getImageHeight(image->handle)
		: runtime->_graphicsBackend->getCanvasHeight(canvas->handle));
	float sourceX = 0.0f, sourceY = 0.0f;
	float sourceWidth = imageWidth, sourceHeight = imageHeight;
	int startIndex = 3;
	if (auto *quad = luaL_testudata(state, 3, QuadLoveType.getName())
		? ::love::luax_checktype<QuadUserdata>(state, 3, QuadLoveType) : nullptr)
	{
		luaL_argcheck(state, quad->runtime == runtime, 3, "Quad belongs to another LoveRuntime");
		sourceX = quad->x * imageWidth / quad->textureWidth;
		sourceY = quad->y * imageHeight / quad->textureHeight;
		sourceWidth = quad->width * imageWidth / quad->textureWidth;
		sourceHeight = quad->height * imageHeight / quad->textureHeight;
		startIndex = 4;
	}
	else if (lua_isnil(state, 3) && !lua_isnoneornil(state, 4))
		return luaL_argerror(state, 3, "expected a Quad or a numeric x coordinate");
	const float x = static_cast<float>(luaL_optnumber(state, startIndex, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, startIndex + 1, 0.0));
	const float angle = static_cast<float>(luaL_optnumber(state, startIndex + 2, 0.0));
	const float scaleX = static_cast<float>(luaL_optnumber(state, startIndex + 3, 1.0));
	const float scaleY = static_cast<float>(luaL_optnumber(state, startIndex + 4, scaleX));
	const float originX = static_cast<float>(luaL_optnumber(state, startIndex + 5, 0.0));
	const float originY = static_cast<float>(luaL_optnumber(state, startIndex + 6, 0.0));
	const float parameters[] = {x, y, angle, scaleX, scaleY, originX, originY};
	for (const float value : parameters)
		luaL_argcheck(state, std::isfinite(value), startIndex,
			"drawLayer transform values must be finite");
	const float cosine = std::cos(angle), sine = std::sin(angle);
	const GraphicsTransform current = runtime->_graphicsTransform;
	const float localA = cosine * scaleX, localB = sine * scaleX;
	const float localC = -sine * scaleY, localD = cosine * scaleY;
	const float a = current.a * localA + current.c * localB;
	const float b = current.b * localA + current.d * localB;
	const float c = current.a * localC + current.c * localD;
	const float d = current.b * localC + current.d * localD;
	const float tx = current.a * x + current.c * y + current.tx;
	const float ty = current.b * x + current.d * y + current.ty;
	std::string error;
	const bool drawn = image ? runtime->_graphicsBackend->drawImageLayer(image->handle,
		static_cast<int>(requestedLayer - 1), sourceX, sourceY, sourceWidth, sourceHeight,
		a, b, c, d, tx, ty, originX, originY,
		runtime->_graphicsColor[0], runtime->_graphicsColor[1],
		runtime->_graphicsColor[2], runtime->_graphicsColor[3],
		image->filter, image->wrapU, image->wrapV, error)
		: runtime->_graphicsBackend->drawCanvasLayer(canvas->handle,
			static_cast<int>(requestedLayer - 1), sourceX, sourceY, sourceWidth, sourceHeight,
			a, b, c, d, tx, ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			canvas->filter, canvas->wrapU, canvas->wrapV, error);
	if (!drawn)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::quadSetViewport(lua_State *state)
{
	auto *quad = checkQuad(state, 1);
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	const float width = static_cast<float>(luaL_checknumber(state, 4));
	const float height = static_cast<float>(luaL_checknumber(state, 5));
	float textureWidth = quad->textureWidth;
	float textureHeight = quad->textureHeight;
	if (!lua_isnoneornil(state, 6))
	{
		textureWidth = static_cast<float>(luaL_checknumber(state, 6));
		textureHeight = static_cast<float>(luaL_checknumber(state, 7));
	}
	const bool finite = std::isfinite(x) && std::isfinite(y) && std::isfinite(width)
		&& std::isfinite(height) && std::isfinite(textureWidth) && std::isfinite(textureHeight);
	luaL_argcheck(state, finite && width != 0.0f && height != 0.0f, 4,
		"Quad viewport values must be finite and width/height must be non-zero");
	luaL_argcheck(state, textureWidth > 0.0f && textureHeight > 0.0f, 6,
		"Quad texture dimensions must be positive and finite");
	quad->x = x;
	quad->y = y;
	quad->width = width;
	quad->height = height;
	quad->textureWidth = textureWidth;
	quad->textureHeight = textureHeight;
	return 0;
}

int LoveRuntime::quadGetViewport(lua_State *state)
{
	auto *quad = checkQuad(state, 1);
	lua_pushnumber(state, quad->x);
	lua_pushnumber(state, quad->y);
	lua_pushnumber(state, quad->width);
	lua_pushnumber(state, quad->height);
	return 4;
}

int LoveRuntime::quadGetTextureDimensions(lua_State *state)
{
	auto *quad = checkQuad(state, 1);
	lua_pushnumber(state, quad->textureWidth);
	lua_pushnumber(state, quad->textureHeight);
	return 2;
}

int LoveRuntime::quadSetLayer(lua_State *state)
{
	auto *quad = checkQuad(state, 1);
	const int layer = static_cast<int>(luaL_checkinteger(state, 2));
	luaL_argcheck(state, layer >= 1, 2, "Quad layer must be at least 1");
	quad->layer = layer;
	return 0;
}

int LoveRuntime::quadGetLayer(lua_State *state)
{
	lua_pushinteger(state, checkQuad(state, 1)->layer);
	return 1;
}

int LoveRuntime::quadEqual(lua_State *state)
{
	auto *left = luaL_testudata(state, 1, QuadLoveType.getName())
		? ::love::luax_checktype<QuadUserdata>(state, 1, QuadLoveType) : nullptr;
	auto *right = luaL_testudata(state, 2, QuadLoveType.getName())
		? ::love::luax_checktype<QuadUserdata>(state, 2, QuadLoveType) : nullptr;
	lua_pushboolean(state, left && right && left == right);
	return 1;
}

GraphicsBackend::FontHandle LoveRuntime::ensureDefaultFont(std::string &error)
{
	if (_currentFont != 0)
		return _currentFont;
	if (!_graphicsBackend)
	{
		error = "love.graphics Font is not attached to a Dora graphics backend";
		return 0;
	}
	const auto handle = _graphicsBackend->newFont({}, 12, error);
	if (handle != 0)
	{
		_currentFont = handle;
		auto *font = new FontUserdata(this, handle);
		font->filter = _graphicsDefaultFilter;
		font->anisotropy = _graphicsDefaultAnisotropy;
		_graphicsFontObject.set(font, ::love::Acquire::NORETAIN);
	}
	return handle;
}

int LoveRuntime::graphicsNewFont(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (luaL_testudata(state, 1, RasterizerLoveType.getName()))
	{
		auto *rasterizer = ::love::luax_checktype<RasterizerUserdata>(state, 1, RasterizerLoveType);
		luaL_argcheck(state, rasterizer->runtime == runtime, 1,
			"Rasterizer belongs to another LoveRuntime");
		if (rasterizer->kind == RasterizerUserdata::Kind::BMFont)
			return graphicsNewImageFont(state);
		return luaL_argerror(state, 1,
			"newFont currently accepts a BMFont Rasterizer, filename, or font size");
	}
	std::string filename;
	int size = 12;
	if (lua_type(state, 1) == LUA_TNUMBER)
		size = static_cast<int>(luaL_checkinteger(state, 1));
	else if (!lua_isnoneornil(state, 1))
	{
		const std::string requested = luaL_checkstring(state, 1);
		std::string error;
		if (!runtime->resolveReadPath(requested, filename, error))
			return luaL_error(state, "Love Font '%s' resolution failed: %s", requested.c_str(), error.c_str());
		size = static_cast<int>(luaL_optinteger(state, 2, 12));
		const auto extension = std::filesystem::path(filename).extension();
		if (extension == ".fnt" || extension == ".FNT")
		{
			luaL_argcheck(state, lua_isnoneornil(state, 2), 2,
				"BMFont creation does not accept a font size; pass page images to love.font.newBMFontRasterizer instead");
			lua_settop(state, 1);
			fontNewBMFontRasterizer(state);
			lua_replace(state, 1);
			return graphicsNewImageFont(state);
		}
	}
	luaL_argcheck(state, size > 0 && size <= 4096, lua_type(state, 1) == LUA_TNUMBER ? 1 : 2,
		"Font size must be between 1 and 4096");
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics Font is not attached to a Dora graphics backend");
	std::string error;
	const auto handle = runtime->_graphicsBackend->newFont(filename, size, error);
	if (handle == 0)
		return luaL_error(state, "Love Font '%s' at size %d creation failed: %s",
			filename.empty() ? "<default>" : filename.c_str(), size,
			error.empty() ? "failed to create Love Font" : error.c_str());
	pushFont(state, runtime, handle);
	return 1;
}

int LoveRuntime::graphicsSetNewFont(lua_State *state)
{
	const int results = graphicsNewFont(state);
	auto *font = checkFont(state, -1);
	font->runtime->_currentFont = font->handle;
	font->runtime->_graphicsFontObject.set(font);
	return results;
}

int LoveRuntime::graphicsNewImageFont(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics ImageFont is not attached to a Dora graphics backend");

	RasterizerUserdata generated;
	RasterizerUserdata *rasterizer = luaL_testudata(state, 1, RasterizerLoveType.getName())
		? ::love::luax_checktype<RasterizerUserdata>(state, 1, RasterizerLoveType) : nullptr;
	ImageDataUserdata decoded;
	ImageDataUserdata *image = nullptr;
	if (rasterizer)
	{
		luaL_argcheck(state, rasterizer->runtime == runtime, 1,
			"Rasterizer belongs to another LoveRuntime");
		if (rasterizer->kind == RasterizerUserdata::Kind::BMFont)
		{
			std::vector<std::vector<std::uint8_t>> pixels;
			std::vector<GraphicsBackend::BMFontPage> pages;
			pixels.reserve(rasterizer->sourceObjects.size());
			pages.reserve(rasterizer->sourceObjects.size());
			for (const auto &source : rasterizer->sourceObjects)
			{
				auto *page = static_cast<ImageDataUserdata *>(source.get());
				if (!page || page->runtime != runtime || std::string_view(page->format) != "rgba8")
					return luaL_error(state, "BMFont Rasterizer has an invalid page ImageData");
				pixels.emplace_back();
				imageDataToRGBA8(*page, pixels.back());
				pages.push_back({page->width, page->height, pixels.back()});
			}
			std::vector<GraphicsBackend::BMFontGlyph> glyphs;
			glyphs.reserve(rasterizer->bmGlyphs.size());
			for (const auto &[codepoint, glyph] : rasterizer->bmGlyphs)
				glyphs.push_back({codepoint, glyph.page, glyph.x, glyph.y, glyph.width, glyph.height,
					glyph.advance, glyph.bearingX, glyph.bearingY});
			std::string error;
			const auto handle = runtime->_graphicsBackend->newBMFont(pages, glyphs,
				rasterizer->height, rasterizer->ascent, rasterizer->dpiScale,
				runtime->_graphicsDefaultFilter, error);
			if (handle == 0)
				return luaL_error(state, "Love BMFont creation failed: %s",
					error.empty() ? "Dora graphics backend rejected the BMFont" : error.c_str());
			pushFont(state, runtime, handle);
			return 1;
		}
		luaL_argcheck(state, rasterizer->kind == RasterizerUserdata::Kind::Image, 1,
			"newImageFont currently requires an Image Rasterizer");
		image = rasterizer->sourceObjects.empty() ? nullptr
			: static_cast<ImageDataUserdata *>(rasterizer->sourceObjects.front().get());
		luaL_argcheck(state, image && image->runtime == runtime, 1,
			"Image Rasterizer source is missing or belongs to another LoveRuntime");
	}
	else
	{
		image = testImageData(state, 1);
		if (image)
			luaL_argcheck(state, image->runtime == runtime, 1,
				"ImageData belongs to another LoveRuntime");
		else
		{
			std::string encoded;
			std::string description;
			if (lua_type(state, 1) == LUA_TSTRING)
			{
				const std::string filename = lua_tostring(state, 1);
				std::string resolved, error;
				if (!runtime->resolveReadPath(filename, resolved, error)
					|| !runtime->_filesystemBackend
					|| !runtime->_filesystemBackend->load(resolved, encoded, error))
					return luaL_error(state, "Love ImageFont '%s' resolution failed: %s",
						filename.c_str(), error.empty() ? "Dora Content load failed" : error.c_str());
				description = filename;
			}
			else if (auto *fileData = testFileData(state, 1))
			{
				encoded = fileData->data;
				description = fileData->filename;
			}
			else return luaL_argerror(state, 1,
				"expected ImageData, Image Rasterizer, filename, or FileData");
			if (!runtime->_imageBackend)
				return luaL_error(state, "love.graphics ImageFont is not attached to a Dora image decoder");
			std::string error;
			if (!runtime->_imageBackend->decodeImage(encoded, decoded.width, decoded.height,
				decoded.pixels, error) || decoded.width <= 0 || decoded.height <= 0
				|| decoded.width > MaximumWindowDimension || decoded.height > MaximumWindowDimension
				|| decoded.pixels.size() != static_cast<std::size_t>(decoded.width) * decoded.height * 4)
				return luaL_error(state, "Love ImageFont '%s' decode failed: %s", description.c_str(),
					error.empty() ? "Dora image decoder returned invalid RGBA8 data" : error.c_str());
			decoded.runtime = runtime;
			decoded.format = "rgba8";
			image = &decoded;
		}

		luaL_argcheck(state, std::string_view(image->format) == "rgba8", 1,
			"ImageFont requires an rgba8 ImageData source");
		std::size_t glyphTextSize = 0;
		const char *glyphText = luaL_checklstring(state, 2, &glyphTextSize);
		const lua_Integer extraSpacing = luaL_optinteger(state, 3, 0);
		const lua_Number dpiScale = luaL_optnumber(state, 4, 1.0);
		luaL_argcheck(state, extraSpacing >= std::numeric_limits<int>::min()
			&& extraSpacing <= std::numeric_limits<int>::max(), 3,
			"extra spacing is outside the integer range");
		luaL_argcheck(state, std::isfinite(dpiScale) && dpiScale > 0.0, 4,
			"DPI scale must be a positive finite number");
		generated.runtime = runtime;
		generated.kind = RasterizerUserdata::Kind::Image;
		generated.height = image->height;
		generated.lineHeight = image->height;
		generated.extraSpacing = static_cast<int>(extraSpacing);
		generated.dpiScale = static_cast<float>(dpiScale);
		std::string error;
		if (!decodeUtf8({glyphText, glyphTextSize}, generated.glyphs, error))
			return luaL_argerror(state, 2, error.c_str());
		luaL_argcheck(state, !generated.glyphs.empty(), 2, "glyph string must not be empty");
		std::vector<std::uint8_t> source;
		imageDataToRGBA8(*image, source);
		std::copy_n(source.begin(), 4, generated.spacer.begin());
		int end = 0;
		for (const auto codepoint : generated.glyphs)
		{
			int start = end;
			while (start < image->width && std::equal(generated.spacer.begin(), generated.spacer.end(),
				source.begin() + static_cast<std::ptrdiff_t>(start) * 4)) ++start;
			end = start;
			while (end < image->width && !std::equal(generated.spacer.begin(), generated.spacer.end(),
				source.begin() + static_cast<std::ptrdiff_t>(end) * 4)) ++end;
			if (start >= end) break;
			if (auto found = std::find_if(generated.imageGlyphs.begin(), generated.imageGlyphs.end(),
				[codepoint](const ImageRasterizerGlyph &glyph) { return glyph.codepoint == codepoint; });
				found != generated.imageGlyphs.end())
				*found = {codepoint, start, end - start};
			else generated.imageGlyphs.push_back({codepoint, start, end - start});
		}
		rasterizer = &generated;
	}

	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*image, rgba8);
	for (std::size_t offset = 0; offset < rgba8.size(); offset += 4)
		if (std::equal(rasterizer->spacer.begin(), rasterizer->spacer.end(),
			rgba8.begin() + static_cast<std::ptrdiff_t>(offset)))
			std::fill_n(rgba8.begin() + static_cast<std::ptrdiff_t>(offset), 4, 0);
	std::vector<GraphicsBackend::ImageFontGlyph> glyphs;
	glyphs.reserve(rasterizer->imageGlyphs.size());
	for (const auto &glyph : rasterizer->imageGlyphs)
		glyphs.push_back({glyph.codepoint, glyph.x, glyph.width,
			glyph.width + rasterizer->extraSpacing});
	std::string error;
	const auto handle = runtime->_graphicsBackend->newImageFont(image->width, image->height,
		rgba8, glyphs, rasterizer->dpiScale, runtime->_graphicsDefaultFilter, error);
	if (handle == 0)
		return luaL_error(state, "Love ImageFont creation failed: %s",
			error.empty() ? "Dora graphics backend rejected the ImageFont" : error.c_str());
	pushFont(state, runtime, handle);
	return 1;
}

int LoveRuntime::graphicsSetFont(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime == runtime && runtime->_fontHandles.contains(font->handle), 1,
		"Font belongs to another or closed LoveRuntime");
	runtime->_currentFont = font->handle;
	runtime->_graphicsFontObject.set(font);
	return 0;
}

int LoveRuntime::graphicsGetFont(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::string error;
	const auto handle = runtime->ensureDefaultFont(error);
	if (handle == 0)
		return luaL_error(state, "%s", error.c_str());
	::love::luax_pushtype(state, FontUserdata::type,
		static_cast<FontUserdata *>(runtime->_graphicsFontObject.get()));
	return 1;
}

int LoveRuntime::graphicsPrint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::string error;
	if (!runtime->_graphicsBackend->validateShaderDraw(error))
		return luaL_error(state, "%s", error.c_str());
	const auto font = runtime->ensureDefaultFont(error);
	if (font == 0)
		return luaL_error(state, "%s", error.c_str());
	const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	const float angle = static_cast<float>(luaL_optnumber(state, 4, 0.0));
	const float scaleX = static_cast<float>(luaL_optnumber(state, 5, 1.0));
	const float scaleY = static_cast<float>(luaL_optnumber(state, 6, scaleX));
	const float originX = static_cast<float>(luaL_optnumber(state, 7, 0.0));
	const float originY = static_cast<float>(luaL_optnumber(state, 8, 0.0));
	const float shearX = static_cast<float>(luaL_optnumber(state, 9, 0.0));
	const float shearY = static_cast<float>(luaL_optnumber(state, 10, 0.0));
	if (lua_istable(state, 1))
	{
		TextEntry entry;
		entry.fragments = readTextFragments(state, 1);
		entry.wrap = -1.0f;
		entry.align = "left";
		drawTextEntry(*runtime->_graphicsBackend, font, entry,
			runtime->_graphicsTransform.a, runtime->_graphicsTransform.b,
			runtime->_graphicsTransform.c, runtime->_graphicsTransform.d,
			runtime->_graphicsTransform.tx, runtime->_graphicsTransform.ty,
			runtime->_graphicsColor, x, y, angle, scaleX, scaleY,
			originX, originY, shearX, shearY);
		return 0;
	}
	std::size_t textSize = 0;
	const char *text = luaL_checklstring(state, 1, &textSize);
	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	const float localA = scaleX * (cosine - sine * shearY);
	const float localB = scaleX * (sine + cosine * shearY);
	const float localC = scaleY * (cosine * shearX - sine);
	const float localD = scaleY * (sine * shearX + cosine);
	const GraphicsTransform current = runtime->_graphicsTransform;
	runtime->_graphicsBackend->drawText(font, {text, textSize}, -1.0f, "left",
		current.a * localA + current.c * localB, current.b * localA + current.d * localB,
		current.a * localC + current.c * localD, current.b * localC + current.d * localD,
		current.a * x + current.c * y + current.tx, current.b * x + current.d * y + current.ty,
		originX, originY, runtime->_graphicsColor[0], runtime->_graphicsColor[1],
		runtime->_graphicsColor[2], runtime->_graphicsColor[3]);
	return 0;
}

int LoveRuntime::graphicsPrintf(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::string error;
	if (!runtime->_graphicsBackend->validateShaderDraw(error))
		return luaL_error(state, "%s", error.c_str());
	const auto font = runtime->ensureDefaultFont(error);
	if (font == 0)
		return luaL_error(state, "%s", error.c_str());
	const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	const float limit = static_cast<float>(luaL_checknumber(state, 4));
	const std::string align = luaL_optstring(state, 5, "left");
	luaL_argcheck(state, limit >= 0.0f, 4, "printf wrap limit cannot be negative");
	luaL_argcheck(state, align == "left" || align == "center" || align == "right"
		|| align == "justify", 5,
		"supported alignments are 'left', 'center', 'right', and 'justify'");
	const float angle = static_cast<float>(luaL_optnumber(state, 6, 0.0));
	const float scaleX = static_cast<float>(luaL_optnumber(state, 7, 1.0));
	const float scaleY = static_cast<float>(luaL_optnumber(state, 8, scaleX));
	const float originX = static_cast<float>(luaL_optnumber(state, 9, 0.0));
	const float originY = static_cast<float>(luaL_optnumber(state, 10, 0.0));
	const float shearX = static_cast<float>(luaL_optnumber(state, 11, 0.0));
	const float shearY = static_cast<float>(luaL_optnumber(state, 12, 0.0));
	if (lua_istable(state, 1))
	{
		TextEntry entry;
		entry.fragments = readTextFragments(state, 1);
		entry.wrap = limit;
		entry.align = align;
		drawTextEntry(*runtime->_graphicsBackend, font, entry,
			runtime->_graphicsTransform.a, runtime->_graphicsTransform.b,
			runtime->_graphicsTransform.c, runtime->_graphicsTransform.d,
			runtime->_graphicsTransform.tx, runtime->_graphicsTransform.ty,
			runtime->_graphicsColor, x, y, angle, scaleX, scaleY,
			originX, originY, shearX, shearY);
		return 0;
	}
	std::size_t textSize = 0;
	const char *text = luaL_checklstring(state, 1, &textSize);
	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	const float localA = scaleX * (cosine - sine * shearY);
	const float localB = scaleX * (sine + cosine * shearY);
	const float localC = scaleY * (cosine * shearX - sine);
	const float localD = scaleY * (sine * shearX + cosine);
	const GraphicsTransform current = runtime->_graphicsTransform;
	runtime->_graphicsBackend->drawText(font, {text, textSize}, limit, align,
		current.a * localA + current.c * localB, current.b * localA + current.d * localB,
		current.a * localC + current.c * localD, current.b * localC + current.d * localD,
		current.a * x + current.c * y + current.tx, current.b * x + current.d * y + current.ty,
		originX, originY, runtime->_graphicsColor[0], runtime->_graphicsColor[1],
		runtime->_graphicsColor[2], runtime->_graphicsColor[3]);
	return 0;
}

int LoveRuntime::graphicsSetBlendMode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string mode = luaL_checkstring(state, 1);
	const std::string alphaMode = luaL_optstring(state, 2, "alphamultiply");
	if (mode != "alpha" && mode != "add" && mode != "subtract" && mode != "multiply"
		&& mode != "replace" && mode != "screen")
		return luaL_argerror(state, 1,
			"supported modes are 'alpha', 'add', 'subtract', 'multiply', 'replace', and 'screen'");
	if (alphaMode != "alphamultiply" && alphaMode != "premultiplied")
		return luaL_argerror(state, 2, "expected 'alphamultiply' or 'premultiplied'");
	if (mode == "multiply" && alphaMode != "premultiplied")
		return luaL_error(state, "the 'multiply' blend mode must be used with premultiplied alpha");
	std::string error;
	if (runtime->_graphicsBackend && !runtime->_graphicsBackend->setBlendMode(mode, alphaMode, error))
		return luaL_error(state, "%s", error.c_str());
	runtime->_graphicsBlendMode = mode;
	runtime->_graphicsBlendAlphaMode = alphaMode;
	return 0;
}

int LoveRuntime::graphicsGetBlendMode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushlstring(state, runtime->_graphicsBlendMode.data(), runtime->_graphicsBlendMode.size());
	lua_pushlstring(state, runtime->_graphicsBlendAlphaMode.data(), runtime->_graphicsBlendAlphaMode.size());
	return 2;
}

int LoveRuntime::graphicsSetScissor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (lua_gettop(state) == 0)
	{
		runtime->_graphicsScissorEnabled = false;
		std::fill(std::begin(runtime->_graphicsScissor), std::end(runtime->_graphicsScissor), 0.0f);
		if (runtime->_graphicsBackend)
			runtime->_graphicsBackend->setScissor(false, 0.0f, 0.0f, 0.0f, 0.0f);
		return 0;
	}
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	const float width = static_cast<float>(luaL_checknumber(state, 3));
	const float height = static_cast<float>(luaL_checknumber(state, 4));
	luaL_argcheck(state, width >= 0.0f, 3, "scissor width cannot be negative");
	luaL_argcheck(state, height >= 0.0f, 4, "scissor height cannot be negative");
	runtime->_graphicsScissorEnabled = true;
	runtime->_graphicsScissor[0] = x;
	runtime->_graphicsScissor[1] = y;
	runtime->_graphicsScissor[2] = width;
	runtime->_graphicsScissor[3] = height;
	if (runtime->_graphicsBackend)
		runtime->_graphicsBackend->setScissor(true, x, y, width, height);
	return 0;
}

int LoveRuntime::graphicsGetScissor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime->_graphicsScissorEnabled)
		return 0;
	for (float value : runtime->_graphicsScissor)
		lua_pushnumber(state, value);
	return 4;
}

int LoveRuntime::graphicsIntersectScissor(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	const float width = static_cast<float>(luaL_checknumber(state, 3));
	const float height = static_cast<float>(luaL_checknumber(state, 4));
	luaL_argcheck(state, width >= 0.0f, 3, "scissor width cannot be negative");
	luaL_argcheck(state, height >= 0.0f, 4, "scissor height cannot be negative");
	float left = x;
	float top = y;
	float right = x + width;
	float bottom = y + height;
	if (runtime->_graphicsScissorEnabled)
	{
		left = std::max(left, runtime->_graphicsScissor[0]);
		top = std::max(top, runtime->_graphicsScissor[1]);
		right = std::min(right, runtime->_graphicsScissor[0] + runtime->_graphicsScissor[2]);
		bottom = std::min(bottom, runtime->_graphicsScissor[1] + runtime->_graphicsScissor[3]);
	}
	runtime->_graphicsScissorEnabled = true;
	runtime->_graphicsScissor[0] = left;
	runtime->_graphicsScissor[1] = top;
	runtime->_graphicsScissor[2] = std::max(0.0f, right - left);
	runtime->_graphicsScissor[3] = std::max(0.0f, bottom - top);
	if (runtime->_graphicsBackend)
		runtime->_graphicsBackend->setScissor(true, runtime->_graphicsScissor[0],
			runtime->_graphicsScissor[1], runtime->_graphicsScissor[2], runtime->_graphicsScissor[3]);
	return 0;
}

int LoveRuntime::graphicsSetColorMask(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	bool mask[4] = {true, true, true, true};
	if (lua_gettop(state) <= 1 && lua_isnoneornil(state, 1))
		std::fill(std::begin(mask), std::end(mask), true);
	else
	{
		for (int index = 1; index <= 4; ++index)
		{
			luaL_checktype(state, index, LUA_TBOOLEAN);
			mask[index - 1] = lua_toboolean(state, index);
		}
	}
	std::copy(std::begin(mask), std::end(mask), runtime->_graphicsColorMask);
	if (runtime->_graphicsBackend)
		runtime->_graphicsBackend->setColorMask(runtime->_graphicsColorMask[0],
			runtime->_graphicsColorMask[1], runtime->_graphicsColorMask[2], runtime->_graphicsColorMask[3]);
	return 0;
}

int LoveRuntime::graphicsGetColorMask(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	for (const bool enabled : runtime->_graphicsColorMask)
		lua_pushboolean(state, enabled);
	return 4;
}

int LoveRuntime::graphicsSetDepthMode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::string compare = "always";
	bool write = false;
	if (!(lua_isnoneornil(state, 1) && lua_isnoneornil(state, 2)))
	{
		compare = luaL_checkstring(state, 1);
		static const std::set<std::string_view> modes = {
			"equal", "notequal", "less", "lequal", "greater", "gequal", "never", "always"};
		luaL_argcheck(state, modes.contains(compare), 1, "invalid depth compare mode");
		luaL_checktype(state, 2, LUA_TBOOLEAN);
		write = lua_toboolean(state, 2);
	}
	runtime->_graphicsDepthCompare = compare;
	runtime->_graphicsDepthWrite = write;
	if (runtime->_graphicsBackend)
		runtime->_graphicsBackend->setDepthMode(compare, write);
	return 0;
}

int LoveRuntime::graphicsGetDepthMode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushlstring(state, runtime->_graphicsDepthCompare.data(), runtime->_graphicsDepthCompare.size());
	lua_pushboolean(state, runtime->_graphicsDepthWrite);
	return 2;
}

int LoveRuntime::graphicsSetMeshCullMode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string mode = luaL_checkstring(state, 1);
	luaL_argcheck(state, mode == "none" || mode == "back" || mode == "front", 1,
		"expected 'none', 'back', or 'front'");
	runtime->_graphicsMeshCullMode = mode;
	if (runtime->_graphicsBackend)
		runtime->_graphicsBackend->setMeshCullMode(mode, runtime->_graphicsFrontFaceWinding);
	return 0;
}

int LoveRuntime::graphicsGetMeshCullMode(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushlstring(state, runtime->_graphicsMeshCullMode.data(), runtime->_graphicsMeshCullMode.size());
	return 1;
}

int LoveRuntime::graphicsSetFrontFaceWinding(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string winding = luaL_checkstring(state, 1);
	luaL_argcheck(state, winding == "cw" || winding == "ccw", 1, "expected 'cw' or 'ccw'");
	runtime->_graphicsFrontFaceWinding = winding;
	if (runtime->_graphicsBackend)
		runtime->_graphicsBackend->setMeshCullMode(runtime->_graphicsMeshCullMode, winding);
	return 0;
}

int LoveRuntime::graphicsGetFrontFaceWinding(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushlstring(state, runtime->_graphicsFrontFaceWinding.data(), runtime->_graphicsFrontFaceWinding.size());
	return 1;
}

int LoveRuntime::shaderGetWarnings(lua_State *state)
{
	const auto *shader = checkShader(state, 1);
	lua_pushlstring(state, shader->warnings.data(), shader->warnings.size());
	return 1;
}

int LoveRuntime::shaderHasUniform(lua_State *state)
{
	auto *shader = checkShader(state, 1);
	const std::string_view name = luaL_checkstring(state, 2);
	luaL_argcheck(state, shader->runtime && shader->handle != 0
		&& shader->runtime->_shaderHandles.contains(shader->handle), 1,
		"Shader belongs to a closed LoveRuntime");
	lua_pushboolean(state, shader->runtime->_graphicsBackend
		&& shader->runtime->_graphicsBackend->hasShaderUniform(shader->handle, name));
	return 1;
}

int LoveRuntime::shaderSendValues(lua_State *state, bool colors)
{
	auto *shader = checkShader(state, 1);
	const std::string_view name = luaL_checkstring(state, 2);
	luaL_argcheck(state, shader->runtime && shader->handle != 0
		&& shader->runtime->_shaderHandles.contains(shader->handle), 1,
		"Shader belongs to a closed LoveRuntime");
	luaL_argcheck(state, shader->runtime->_graphicsBackend != nullptr, 1,
		"Dora graphics backend is unavailable");
	luaL_argcheck(state, shader->runtime->_graphicsBackend->hasShaderUniform(shader->handle, name), 2,
		"Shader uniform does not exist or is not active");
	GraphicsBackend::ShaderUniformInfo info;
	luaL_argcheck(state, shader->runtime->_graphicsBackend->getShaderUniformInfo(
		shader->handle, name, info), 2, "Shader uniform metadata is unavailable");
	int dataArgument = 0;
	int dataOptions = 0;
	bool dataMatrixColumnMajor = false;
	if (isMeshData(state, 3))
	{
		dataArgument = 3;
		dataOptions = 4;
		if (info.type == GraphicsBackend::ShaderUniformType::Matrix
			&& lua_type(state, 4) == LUA_TSTRING)
		{
			const std::string_view layout = lua_tostring(state, 4);
			luaL_argcheck(state, layout == "row" || layout == "column", 4,
				"matrix layout must be 'row' or 'column'");
			dataMatrixColumnMajor = layout == "column";
			dataOptions = 5;
		}
	}
	else if (info.type == GraphicsBackend::ShaderUniformType::Matrix
		&& lua_type(state, 3) == LUA_TSTRING && isMeshData(state, 4))
	{
		const std::string_view layout = lua_tostring(state, 3);
		luaL_argcheck(state, layout == "row" || layout == "column", 3,
			"matrix layout must be 'row' or 'column'");
		dataMatrixColumnMajor = layout == "column";
		dataArgument = 4;
		dataOptions = 5;
	}
	if (dataArgument != 0)
	{
		luaL_argcheck(state, info.type != GraphicsBackend::ShaderUniformType::Sampler,
			dataArgument, "Image Shader uniforms cannot receive Data");
		if (colors)
			luaL_argcheck(state, info.type == GraphicsBackend::ShaderUniformType::Float
				&& info.components >= 3 && info.components <= 4, 2,
				"sendColor can only be used on vec3 or vec4 float uniforms");
		const auto bytes = meshDataBytes(state, dataArgument);
		const lua_Integer offsetValue = luaL_optinteger(state, dataOptions, 0);
		luaL_argcheck(state, offsetValue >= 0, dataOptions, "Data offset cannot be negative");
		const std::size_t offset = static_cast<std::size_t>(offsetValue);
		luaL_argcheck(state, offset < bytes.size(), dataOptions,
			"Data offset must be less than the Data size");
		const std::size_t stride = static_cast<std::size_t>(info.components) * sizeof(std::uint32_t);
		const std::size_t totalSize = stride * static_cast<std::size_t>(info.count);
		std::size_t copySize = 0;
		if (!lua_isnoneornil(state, dataOptions + 1))
		{
			const lua_Integer sizeValue = luaL_checkinteger(state, dataOptions + 1);
			luaL_argcheck(state, sizeValue > 0, dataOptions + 1, "Data size must be greater than zero");
			copySize = static_cast<std::size_t>(sizeValue);
			luaL_argcheck(state, copySize <= bytes.size() - offset, dataOptions + 1,
				"Data size and offset must fit within the Data bounds");
			luaL_argcheck(state, copySize % stride == 0, dataOptions + 1,
				"Data size must be a multiple of the Shader uniform element size");
			luaL_argcheck(state, copySize <= totalSize, dataOptions + 1,
				"Data size must not exceed the Shader uniform total size");
		}
		else
		{
			copySize = std::min(((bytes.size() - offset) / stride) * stride, totalSize);
			luaL_argcheck(state, copySize > 0, dataArgument,
				"Data does not contain a complete Shader uniform value at the requested offset");
		}
		const std::size_t count = copySize / stride;
		std::vector<float> values;
		values.reserve(count * static_cast<std::size_t>(info.components));
		auto readWord = [&](std::size_t byteOffset) {
			std::uint32_t word = 0;
			std::memcpy(&word, bytes.data() + offset + byteOffset, sizeof(word));
			return word;
		};
		for (std::size_t index = 0; index < count; ++index)
		{
			const std::size_t elementOffset = index * stride;
			if (info.type == GraphicsBackend::ShaderUniformType::Matrix && !dataMatrixColumnMajor)
			{
				const int dimension = static_cast<int>(std::lround(std::sqrt(info.components)));
				for (int column = 0; column < dimension; ++column)
					for (int row = 0; row < dimension; ++row)
					{
						const std::size_t component = static_cast<std::size_t>(row * dimension + column);
						values.push_back(std::bit_cast<float>(readWord(
							elementOffset + component * sizeof(std::uint32_t))));
					}
				continue;
			}
			for (int component = 0; component < info.components; ++component)
			{
				const auto word = readWord(elementOffset
					+ static_cast<std::size_t>(component) * sizeof(std::uint32_t));
				if (info.type == GraphicsBackend::ShaderUniformType::Bool)
					values.push_back(std::bit_cast<std::int32_t>(word) != 0 ? 1.0f : 0.0f);
				else values.push_back(std::bit_cast<float>(word));
			}
		}
		std::string error;
		if (!shader->runtime->_graphicsBackend->sendShaderFloats(
			shader->handle, name, values, colors, error))
			return luaL_error(state, "%s", error.c_str());
		return 0;
	}
	if (info.type == GraphicsBackend::ShaderUniformType::Sampler)
	{
		luaL_argcheck(state, !colors, 2, "sendColor cannot be used with an Image uniform");
		luaL_argcheck(state, lua_gettop(state) >= 3, 3, "expected one or more Image or Canvas values");
		const int sentCount = std::min(lua_gettop(state) - 2, info.count);
		std::vector<GraphicsBackend::ShaderTexture> textures;
		std::vector<::love::StrongRef<::love::Object>> textureObjects;
		textures.reserve(static_cast<std::size_t>(sentCount));
		textureObjects.reserve(static_cast<std::size_t>(sentCount));
		for (int index = 0; index < sentCount; ++index)
		{
			const int argument = 3 + index;
			auto *image = testImage(state, argument);
			auto *canvas = testCanvas(state, argument);
			luaL_argcheck(state, image || canvas, argument, "expected an Image or Canvas");
			GraphicsBackend::ShaderTexture texture;
			if (image)
			{
				luaL_argcheck(state, image->runtime == shader->runtime && image->handle != 0, argument,
					"Image belongs to another or closed LoveRuntime");
				texture.image = image->handle;
				texture.filter = image->filter;
				texture.wrapU = image->wrapU;
				texture.wrapV = image->wrapV;
				texture.wrapW = image->wrapW;
				textureObjects.emplace_back(image);
			}
			else
			{
				luaL_argcheck(state, canvas->runtime == shader->runtime && canvas->handle != 0
					&& shader->runtime->_canvasHandles.contains(canvas->handle), argument,
					"Canvas belongs to another or closed LoveRuntime");
				luaL_argcheck(state, canvas->readable, argument, "Shader Canvas must be readable");
				texture.canvas = canvas->handle;
				texture.filter = canvas->filter;
				texture.wrapU = canvas->wrapU;
				texture.wrapV = canvas->wrapV;
				textureObjects.emplace_back(canvas);
			}
			textures.push_back(texture);
		}
		std::string error;
		if (!shader->runtime->_graphicsBackend->sendShaderTextures(shader->handle, name, textures, error))
			return luaL_error(state, "%s", error.c_str());
		shader->samplerObjects[std::string(name)] = std::move(textureObjects);
		lua_getiuservalue(state, 1, 1);
		if (info.count == 1)
		{
			lua_pushvalue(state, 3);
			lua_setfield(state, -2, std::string(name).c_str());
		}
		else
		{
			lua_getfield(state, -1, std::string(name).c_str());
			if (!lua_istable(state, -1))
			{
				lua_pop(state, 1);
				lua_createtable(state, info.count, 0);
			}
			for (int index = 0; index < sentCount; ++index)
			{
				lua_pushvalue(state, 3 + index);
				lua_rawseti(state, -2, index + 1);
			}
			lua_setfield(state, -2, std::string(name).c_str());
		}
		lua_pop(state, 1);
		return 0;
	}
	luaL_argcheck(state, testImage(state, 3) == nullptr
		&& testCanvas(state, 3) == nullptr, 3,
		"numeric Shader uniform cannot receive an Image or Canvas");
	if (colors)
		luaL_argcheck(state, info.type == GraphicsBackend::ShaderUniformType::Float
			&& info.components >= 3 && info.components <= 4, 2,
			"sendColor can only be used on vec3 or vec4 float uniforms");
	int firstArgument = 3;
	bool matrixColumnMajor = false;
	if (info.type == GraphicsBackend::ShaderUniformType::Matrix && lua_type(state, 3) == LUA_TSTRING)
	{
		const std::string_view layout = lua_tostring(state, 3);
		luaL_argcheck(state, layout == "row" || layout == "column", 3,
			"matrix layout must be 'row' or 'column'");
		matrixColumnMajor = layout == "column";
		firstArgument = 4;
	}
	luaL_argcheck(state, lua_gettop(state) >= firstArgument, firstArgument,
		"expected one or more Shader values");
	std::vector<float> values;
	auto appendValue = [&](int argument) {
		switch (info.type)
		{
			case GraphicsBackend::ShaderUniformType::Float:
			case GraphicsBackend::ShaderUniformType::Matrix:
			{
				const float value = static_cast<float>(luaL_checknumber(state, argument));
				luaL_argcheck(state, std::isfinite(value), argument, "Shader values must be finite numbers");
				values.push_back(colors ? std::clamp(value, 0.0f, 1.0f) : value);
				break;
			}
			case GraphicsBackend::ShaderUniformType::Int:
			{
				const lua_Integer value = luaL_checkinteger(state, argument);
				luaL_argcheck(state, value >= std::numeric_limits<std::int32_t>::min()
					&& value <= std::numeric_limits<std::int32_t>::max(), argument,
					"Shader int must fit in 32 bits");
				values.push_back(std::bit_cast<float>(static_cast<std::int32_t>(value)));
				break;
			}
			case GraphicsBackend::ShaderUniformType::UInt:
			{
				const lua_Integer value = luaL_checkinteger(state, argument);
				luaL_argcheck(state, value >= 0
					&& static_cast<std::uint64_t>(value) <= std::numeric_limits<std::uint32_t>::max(), argument,
					"Shader uint must fit in 32 bits");
				values.push_back(std::bit_cast<float>(static_cast<std::uint32_t>(value)));
				break;
			}
			case GraphicsBackend::ShaderUniformType::Bool:
				luaL_checktype(state, argument, LUA_TBOOLEAN);
				values.push_back(lua_toboolean(state, argument) ? 1.0f : 0.0f);
				break;
			case GraphicsBackend::ShaderUniformType::Sampler: break;
		}
	};
	auto appendTable = [&](int argument) {
		luaL_checktype(state, argument, LUA_TTABLE);
		luaL_argcheck(state, lua_rawlen(state, argument) >= static_cast<std::size_t>(info.components),
			argument, "Shader value table has too few components");
		for (int component = 1; component <= info.components; ++component)
		{
			lua_rawgeti(state, argument, component);
			appendValue(lua_gettop(state));
			lua_pop(state, 1);
		}
	};
	auto appendMatrix = [&](int argument) {
		luaL_checktype(state, argument, LUA_TTABLE);
		const int dimension = static_cast<int>(std::lround(std::sqrt(info.components)));
		luaL_argcheck(state, dimension * dimension == info.components, argument,
			"Shader matrix metadata is invalid");
		lua_rawgeti(state, argument, 1);
		const bool nested = lua_istable(state, -1);
		lua_pop(state, 1);
		if (nested)
			luaL_argcheck(state, lua_rawlen(state, argument) >= static_cast<std::size_t>(dimension),
				argument, "Shader matrix table has too few rows or columns");
		else luaL_argcheck(state, lua_rawlen(state, argument) >= static_cast<std::size_t>(info.components),
			argument, "Shader matrix table has too few components");
		for (int column = 0; column < dimension; ++column)
		{
			for (int row = 0; row < dimension; ++row)
			{
				if (nested)
				{
					const int outer = matrixColumnMajor ? column : row;
					const int inner = matrixColumnMajor ? row : column;
					lua_rawgeti(state, argument, outer + 1);
					luaL_argcheck(state, lua_istable(state, -1)
						&& lua_rawlen(state, -1) >= static_cast<std::size_t>(dimension), argument,
						"Shader matrix row or column has too few components");
					lua_rawgeti(state, -1, inner + 1);
					const float value = static_cast<float>(luaL_checknumber(state, -1));
					luaL_argcheck(state, std::isfinite(value), argument,
						"Shader values must be finite numbers");
					values.push_back(value);
					lua_pop(state, 2);
				}
				else
				{
					const int source = matrixColumnMajor
						? column * dimension + row : row * dimension + column;
					lua_rawgeti(state, argument, source + 1);
					const float value = static_cast<float>(luaL_checknumber(state, -1));
					luaL_argcheck(state, std::isfinite(value), argument,
						"Shader values must be finite numbers");
					values.push_back(value);
					lua_pop(state, 1);
				}
			}
		}
	};
	if (info.type == GraphicsBackend::ShaderUniformType::Matrix)
	{
		const int sentCount = std::min(lua_gettop(state) - firstArgument + 1, info.count);
		for (int index = 0; index < sentCount; ++index) appendMatrix(firstArgument + index);
	}
	else if (info.count == 1)
	{
		if (info.components == 1) appendValue(firstArgument);
		else if (lua_istable(state, firstArgument)) appendTable(firstArgument);
		else
		{
			luaL_argcheck(state, lua_gettop(state) >= firstArgument + info.components - 1, firstArgument,
				"Shader vector requires a component table");
			for (int component = 0; component < info.components; ++component)
				appendValue(firstArgument + component);
		}
	}
	else
	{
		const int sentCount = std::min(lua_gettop(state) - firstArgument + 1, info.count);
		for (int index = 0; index < sentCount; ++index)
		{
			const int argument = firstArgument + index;
			if (info.components == 1) appendValue(argument);
			else appendTable(argument);
		}
	}
	std::string error;
	if (!shader->runtime->_graphicsBackend->sendShaderFloats(
		shader->handle, name, values, colors, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::shaderSend(lua_State *state)
{
	return shaderSendValues(state, false);
}

int LoveRuntime::shaderSendColor(lua_State *state)
{
	return shaderSendValues(state, true);
}

int LoveRuntime::meshSetVertices(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	luaL_argcheck(state, mesh->runtime != nullptr, 1, "closed Mesh");
	const lua_Integer startValue = luaL_optinteger(state, 3, 1);
	luaL_argcheck(state, startValue >= 1 && static_cast<std::size_t>(startValue) <= mesh->vertexCount, 3,
		"invalid vertex start index");
	const std::size_t start = static_cast<std::size_t>(startValue - 1);
	if (isMeshData(state, 2))
	{
		const auto data = meshDataBytes(state, 2);
		const lua_Integer countValue = luaL_optinteger(state, 4,
			static_cast<lua_Integer>(mesh->vertexCount - start));
		luaL_argcheck(state, countValue > 0, 4, "vertex count must be greater than 0");
		const std::size_t count = static_cast<std::size_t>(countValue);
		luaL_argcheck(state, count <= mesh->vertexCount - start, 4, "too many vertices");
		auto bytes = mesh->bytes;
		const std::size_t copied = std::min(data.size(), count * mesh->vertexStride);
		if (copied > 0)
			std::memcpy(bytes.data() + start * mesh->vertexStride, data.data(), copied);
		std::vector<float> values;
		luaL_argcheck(state, decodeMeshStorage(*mesh, bytes, values), 2,
			"Mesh Data contains a non-finite float vertex component");
		mesh->bytes = std::move(bytes);
		mesh->values = std::move(values);
		return 0;
	}
	luaL_checktype(state, 2, LUA_TTABLE);
	const std::size_t available = lua_rawlen(state, 2);
	const lua_Integer countValue = luaL_optinteger(state, 4, static_cast<lua_Integer>(available));
	luaL_argcheck(state, countValue > 0, 4, "vertex count must be greater than 0");
	const std::size_t count = std::min<std::size_t>(available, static_cast<std::size_t>(countValue));
	luaL_argcheck(state, count <= mesh->vertexCount - start, 2, "too many vertices");
	for (std::size_t index = 0; index < count; ++index)
	{
		lua_rawgeti(state, 2, static_cast<lua_Integer>(index + 1));
		luaL_checktype(state, -1, LUA_TTABLE);
		readMeshVertex(state, -1, *mesh, std::span<float>(mesh->values).subspan(
			(start + index) * mesh->componentCount, mesh->componentCount));
		lua_pop(state, 1);
		encodeMeshVertex(*mesh, start + index);
	}
	return 0;
}

int LoveRuntime::meshSetVertex(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const lua_Integer indexValue = luaL_checkinteger(state, 2);
	luaL_argcheck(state, mesh->runtime && indexValue >= 1
		&& static_cast<std::size_t>(indexValue) <= mesh->vertexCount, 2, "invalid vertex index");
	auto values = std::span<float>(mesh->values).subspan(
		(static_cast<std::size_t>(indexValue) - 1) * mesh->componentCount, mesh->componentCount);
	if (lua_istable(state, 3)) readMeshVertex(state, 3, *mesh, values);
	else readMeshVertexArguments(state, 3, *mesh, values);
	encodeMeshVertex(*mesh, static_cast<std::size_t>(indexValue) - 1);
	return 0;
}

int LoveRuntime::meshGetVertex(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const lua_Integer indexValue = luaL_checkinteger(state, 2);
	luaL_argcheck(state, mesh->runtime && indexValue >= 1
		&& static_cast<std::size_t>(indexValue) <= mesh->vertexCount, 2, "invalid vertex index");
	const float *values = mesh->values.data()
		+ (static_cast<std::size_t>(indexValue) - 1) * mesh->componentCount;
	for (std::size_t component = 0; component < mesh->componentCount; ++component)
		lua_pushnumber(state, values[component]);
	return static_cast<int>(mesh->componentCount);
}

int LoveRuntime::meshSetVertexAttribute(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const lua_Integer vertexValue = luaL_checkinteger(state, 2);
	const lua_Integer attributeValue = luaL_checkinteger(state, 3);
	luaL_argcheck(state, mesh->runtime && vertexValue >= 1
		&& static_cast<std::size_t>(vertexValue) <= mesh->vertexCount, 2, "invalid vertex index");
	luaL_argcheck(state, attributeValue >= 1
		&& static_cast<std::size_t>(attributeValue) <= mesh->format.size(), 3, "invalid attribute index");
	const auto &attribute = mesh->format[static_cast<std::size_t>(attributeValue) - 1];
	float *values = mesh->values.data()
		+ (static_cast<std::size_t>(vertexValue) - 1) * mesh->componentCount + attribute.offset;
	for (int component = 0; component < attribute.components; ++component)
	{
		float value = static_cast<float>(luaL_optnumber(state, 4 + component, 0.0));
		luaL_argcheck(state, std::isfinite(value), 4 + component, "Mesh attribute values must be finite");
		if (attribute.type != "float") value = std::clamp(value, 0.0f, 1.0f);
		values[component] = value;
	}
	encodeMeshVertex(*mesh, static_cast<std::size_t>(vertexValue) - 1);
	return 0;
}

int LoveRuntime::meshGetVertexAttribute(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const lua_Integer vertexValue = luaL_checkinteger(state, 2);
	const lua_Integer attributeValue = luaL_checkinteger(state, 3);
	luaL_argcheck(state, mesh->runtime && vertexValue >= 1
		&& static_cast<std::size_t>(vertexValue) <= mesh->vertexCount, 2, "invalid vertex index");
	luaL_argcheck(state, attributeValue >= 1
		&& static_cast<std::size_t>(attributeValue) <= mesh->format.size(), 3, "invalid attribute index");
	const auto &attribute = mesh->format[static_cast<std::size_t>(attributeValue) - 1];
	const float *values = mesh->values.data()
		+ (static_cast<std::size_t>(vertexValue) - 1) * mesh->componentCount + attribute.offset;
	for (int component = 0; component < attribute.components; ++component)
		lua_pushnumber(state, values[component]);
	return attribute.components;
}

int LoveRuntime::meshGetVertexCount(lua_State *state)
{
	const auto *mesh = checkMesh(state, 1);
	lua_pushinteger(state, static_cast<lua_Integer>(mesh->vertexCount));
	return 1;
}

int LoveRuntime::meshGetVertexFormat(lua_State *state)
{
	const auto *mesh = checkMesh(state, 1);
	lua_createtable(state, static_cast<int>(mesh->format.size()), 0);
	for (std::size_t index = 0; index < mesh->format.size(); ++index)
	{
		const auto &attribute = mesh->format[index];
		lua_createtable(state, 3, 0);
		lua_pushlstring(state, attribute.name.data(), attribute.name.size()); lua_rawseti(state, -2, 1);
		lua_pushlstring(state, attribute.type.data(), attribute.type.size()); lua_rawseti(state, -2, 2);
		lua_pushinteger(state, attribute.components); lua_rawseti(state, -2, 3);
		lua_rawseti(state, -2, static_cast<lua_Integer>(index + 1));
	}
	return 1;
}

int LoveRuntime::meshSetAttributeEnabled(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const std::string name = luaL_checkstring(state, 2);
	luaL_checktype(state, 3, LUA_TBOOLEAN);
	const bool enabled = lua_toboolean(state, 3);
	if (auto found = mesh->attachments.find(name); found != mesh->attachments.end())
	{
		found->second.enabled = enabled;
		return 0;
	}
	const std::size_t index = meshAttributeIndex(*mesh, name);
	luaL_argcheck(state, index < mesh->format.size(), 2,
		"Mesh does not have an attached vertex attribute with that name");
	mesh->format[index].enabled = enabled;
	return 0;
}

int LoveRuntime::meshIsAttributeEnabled(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const std::string name = luaL_checkstring(state, 2);
	if (const auto found = mesh->attachments.find(name); found != mesh->attachments.end())
	{
		lua_pushboolean(state, found->second.enabled);
		return 1;
	}
	const std::size_t index = meshAttributeIndex(*mesh, name);
	luaL_argcheck(state, index < mesh->format.size(), 2,
		"Mesh does not have an attached vertex attribute with that name");
	lua_pushboolean(state, mesh->format[index].enabled);
	return 1;
}

int LoveRuntime::meshAttachAttribute(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const std::string name = luaL_checkstring(state, 2);
	auto *source = checkMesh(state, 3);
	luaL_argcheck(state, mesh->runtime && source->runtime == mesh->runtime, 3,
		"attached Mesh belongs to another or closed LoveRuntime");
	const std::string step = luaL_optstring(state, 4, "pervertex");
	luaL_argcheck(state, step == "pervertex" || step == "perinstance", 4,
		"expected 'pervertex' or 'perinstance'");
	const std::string sourceName = luaL_optstring(state, 5, name.c_str());
	const std::size_t sourceIndex = meshAttributeIndex(*source, sourceName);
	luaL_argcheck(state, sourceIndex < source->format.size(), 5,
		"the supplied Mesh does not have the requested vertex attribute");
	if (source != mesh)
	{
		bool hasExternalAttachment = false;
		for (const auto &entry : source->attachments)
			if (entry.second.mesh != source) { hasExternalAttachment = true; break; }
		luaL_argcheck(state, !hasExternalAttachment, 3,
			"cannot attach a Mesh which has attached Meshes of its own");
	}

	bool enabled = true;
	if (const auto existing = mesh->attachments.find(name); existing != mesh->attachments.end())
		enabled = existing->second.enabled;
	else
	{
		const std::size_t ownIndex = meshAttributeIndex(*mesh, name);
		if (ownIndex < mesh->format.size()) enabled = mesh->format[ownIndex].enabled;
		else
		{
			std::size_t uniqueCount = mesh->format.size();
			for (const auto &entry : mesh->attachments)
				if (meshAttributeIndex(*mesh, entry.first) == mesh->format.size()) ++uniqueCount;
			luaL_argcheck(state, uniqueCount < 16, 2,
				"a maximum of 16 Mesh attributes can be attached at once");
		}
	}
	mesh->attachments[name] = {source, sourceIndex, step, enabled};
	if (source == mesh) mesh->attachmentObjects.erase(name);
	else mesh->attachmentObjects[name].set(source);

	lua_getiuservalue(state, 1, 2);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		lua_newtable(state);
	}
	if (source == mesh) lua_pushnil(state);
	else lua_pushvalue(state, 3);
	lua_setfield(state, -2, name.c_str());
	lua_setiuservalue(state, 1, 2);
	return 0;
}

int LoveRuntime::meshDetachAttribute(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const std::string name = luaL_checkstring(state, 2);
	const auto found = mesh->attachments.find(name);
	if (found == mesh->attachments.end() || found->second.mesh == mesh)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	mesh->attachments.erase(found);
	mesh->attachmentObjects.erase(name);
	const std::size_t ownIndex = meshAttributeIndex(*mesh, name);
	if (ownIndex < mesh->format.size()) mesh->format[ownIndex].enabled = true;
	lua_getiuservalue(state, 1, 2);
	if (lua_istable(state, -1))
	{
		lua_pushnil(state);
		lua_setfield(state, -2, name.c_str());
		lua_setiuservalue(state, 1, 2);
	}
	else lua_pop(state, 1);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::meshSetVertexMap(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	if (lua_isnoneornil(state, 2))
	{
		mesh->vertexMap.clear();
		mesh->useVertexMap = false;
		return 0;
	}
	std::vector<std::uint32_t> vertexMap;
	if (isMeshData(state, 2))
	{
		const auto data = meshDataBytes(state, 2);
		const std::string type = luaL_checkstring(state, 3);
		luaL_argcheck(state, type == "uint16" || type == "uint32", 3,
			"expected 'uint16' or 'uint32'");
		const std::size_t elementSize = type == "uint16" ? sizeof(std::uint16_t) : sizeof(std::uint32_t);
		const lua_Integer countValue = luaL_optinteger(state, 4,
			static_cast<lua_Integer>(data.size() / elementSize));
		luaL_argcheck(state, countValue >= 1
			&& static_cast<std::size_t>(countValue) <= data.size() / elementSize, 4,
			"invalid Mesh vertex map index count");
		vertexMap.reserve(static_cast<std::size_t>(countValue));
		for (lua_Integer index = 0; index < countValue; ++index)
		{
			std::uint32_t value = 0;
			if (type == "uint16")
			{
				std::uint16_t raw = 0;
				std::memcpy(&raw, data.data() + static_cast<std::size_t>(index) * elementSize, elementSize);
				value = raw;
			}
			else std::memcpy(&value, data.data() + static_cast<std::size_t>(index) * elementSize, elementSize);
			luaL_argcheck(state, value < mesh->vertexCount, 2,
				"vertex map Data index is outside the Mesh");
			vertexMap.push_back(value);
		}
		mesh->vertexMap = std::move(vertexMap);
		mesh->useVertexMap = true;
		return 0;
	}
	const bool table = lua_istable(state, 2);
	const int count = table ? static_cast<int>(lua_rawlen(state, 2)) : lua_gettop(state) - 1;
	vertexMap.reserve(static_cast<std::size_t>(count));
	for (int index = 0; index < count; ++index)
	{
		if (table) lua_rawgeti(state, 2, index + 1);
		const lua_Integer value = luaL_checkinteger(state, table ? -1 : index + 2);
		luaL_argcheck(state, value >= 1 && static_cast<std::size_t>(value) <= mesh->vertexCount,
			table ? 2 : index + 2, "vertex map index is outside the Mesh");
		vertexMap.push_back(static_cast<std::uint32_t>(value - 1));
		if (table) lua_pop(state, 1);
	}
	mesh->vertexMap = std::move(vertexMap);
	mesh->useVertexMap = true;
	return 0;
}

int LoveRuntime::meshGetVertexMap(lua_State *state)
{
	const auto *mesh = checkMesh(state, 1);
	if (!mesh->useVertexMap)
	{
		lua_pushnil(state);
		return 1;
	}
	lua_createtable(state, static_cast<int>(mesh->vertexMap.size()), 0);
	for (std::size_t index = 0; index < mesh->vertexMap.size(); ++index)
	{
		lua_pushinteger(state, static_cast<lua_Integer>(mesh->vertexMap[index]) + 1);
		lua_rawseti(state, -2, static_cast<lua_Integer>(index + 1));
	}
	return 1;
}

int LoveRuntime::meshSetTexture(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	mesh->image = 0;
	mesh->canvas = 0;
	mesh->textureObject.set(nullptr);
	if (lua_isnoneornil(state, 2)) lua_pushnil(state);
	else if (auto *image = testImage(state, 2))
	{
		luaL_argcheck(state, image->runtime == mesh->runtime && image->handle != 0, 2,
			"Image belongs to another or closed LoveRuntime");
		mesh->image = image->handle;
		mesh->textureObject.set(image);
		lua_pushvalue(state, 2);
	}
	else if (auto *canvas = testCanvas(state, 2))
	{
		luaL_argcheck(state, canvas->runtime == mesh->runtime && canvas->handle != 0
			&& mesh->runtime->_canvasHandles.contains(canvas->handle), 2,
			"Canvas belongs to another or closed LoveRuntime");
		mesh->canvas = canvas->handle;
		mesh->textureObject.set(canvas);
		lua_pushvalue(state, 2);
	}
	else return luaL_argerror(state, 2, "expected an Image, Canvas, or nil");
	lua_setiuservalue(state, 1, 1);
	return 0;
}

int LoveRuntime::meshGetTexture(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	if (!mesh->textureObject) return 0;
	if (mesh->image != 0)
		::love::luax_pushtype(state, ImageUserdata::type,
			static_cast<ImageUserdata *>(mesh->textureObject.get()));
	else ::love::luax_pushtype(state, CanvasUserdata::type,
		static_cast<CanvasUserdata *>(mesh->textureObject.get()));
	return 1;
}

int LoveRuntime::meshSetDrawMode(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	const std::string mode = luaL_checkstring(state, 2);
	luaL_argcheck(state, isMeshDrawMode(mode), 2,
		"expected 'fan', 'strip', 'triangles', or 'points'");
	mesh->drawMode = mode;
	return 0;
}

int LoveRuntime::meshGetDrawMode(lua_State *state)
{
	const auto *mesh = checkMesh(state, 1);
	lua_pushlstring(state, mesh->drawMode.data(), mesh->drawMode.size());
	return 1;
}

int LoveRuntime::meshSetDrawRange(lua_State *state)
{
	auto *mesh = checkMesh(state, 1);
	if (lua_isnoneornil(state, 2))
	{
		mesh->drawStart = -1;
		mesh->drawCount = 0;
		return 0;
	}
	const lua_Integer start = luaL_checkinteger(state, 2);
	const lua_Integer count = luaL_checkinteger(state, 3);
	luaL_argcheck(state, start >= 1, 2, "draw range start must be at least 1");
	luaL_argcheck(state, count > 0, 3, "draw range count must be greater than 0");
	mesh->drawStart = static_cast<int>(start - 1);
	mesh->drawCount = static_cast<int>(count);
	return 0;
}

int LoveRuntime::meshGetDrawRange(lua_State *state)
{
	const auto *mesh = checkMesh(state, 1);
	if (mesh->drawStart < 0) return 0;
	lua_pushinteger(state, mesh->drawStart + 1);
	lua_pushinteger(state, mesh->drawCount);
	return 2;
}

int LoveRuntime::meshFlush(lua_State *)
{
	return 0;
}

namespace
{
int writeSpriteBatchSprite(lua_State *state, SpriteBatchUserdata &batch,
	int startIndex, int requestedIndex, int explicitLayer = 0)
{
	auto *graphics = batch.runtime ? batch.runtime->getGraphicsBackend() : nullptr;
	luaL_argcheck(state, graphics != nullptr, 1, "closed SpriteBatch");
	float sourceX = 0.0f;
	float sourceY = 0.0f;
	float sourceWidth = static_cast<float>(batch.image != 0
		? graphics->getImageWidth(batch.image) : graphics->getCanvasWidth(batch.canvas));
	float sourceHeight = static_cast<float>(batch.image != 0
		? graphics->getImageHeight(batch.image) : graphics->getCanvasHeight(batch.canvas));
	float textureWidth = sourceWidth;
	float textureHeight = sourceHeight;
	int quadLayer = 1;
	if (auto *quad = luaL_testudata(state, startIndex, QuadLoveType.getName())
		? ::love::luax_checktype<QuadUserdata>(state, startIndex, QuadLoveType) : nullptr)
	{
		luaL_argcheck(state, quad->runtime == batch.runtime, startIndex,
			"Quad belongs to another LoveRuntime");
		quadLayer = quad->layer;
		sourceX = quad->x;
		sourceY = quad->y;
		sourceWidth = quad->width;
		sourceHeight = quad->height;
		textureWidth = quad->textureWidth;
		textureHeight = quad->textureHeight;
		++startIndex;
	}
	else if (lua_isnil(state, startIndex) && !lua_isnoneornil(state, startIndex + 1))
		return luaL_argerror(state, startIndex, "expected a Quad or transform x coordinate");
	const bool arrayTexture = batch.textureType == GraphicsBackend::TextureType::Array;
	if (explicitLayer != 0)
		luaL_argcheck(state, arrayTexture, startIndex,
			"addLayer/setLayer can only be used with an ArrayImage SpriteBatch");
	const int layer = arrayTexture ? (explicitLayer != 0 ? explicitLayer : quadLayer) : 1;
	luaL_argcheck(state, layer >= 1 && layer <= batch.layerCount, startIndex,
		"SpriteBatch layer is outside its ArrayImage");
	const float x = static_cast<float>(luaL_optnumber(state, startIndex, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, startIndex + 1, 0.0));
	const float angle = static_cast<float>(luaL_optnumber(state, startIndex + 2, 0.0));
	const float scaleX = static_cast<float>(luaL_optnumber(state, startIndex + 3, 1.0));
	const float scaleY = static_cast<float>(luaL_optnumber(state, startIndex + 4, scaleX));
	const float originX = static_cast<float>(luaL_optnumber(state, startIndex + 5, 0.0));
	const float originY = static_cast<float>(luaL_optnumber(state, startIndex + 6, 0.0));
	const float shearX = static_cast<float>(luaL_optnumber(state, startIndex + 7, 0.0));
	const float shearY = static_cast<float>(luaL_optnumber(state, startIndex + 8, 0.0));
	const float values[] = {sourceX, sourceY, sourceWidth, sourceHeight, textureWidth, textureHeight,
		x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY};
	for (const float value : values)
		luaL_argcheck(state, std::isfinite(value), startIndex,
			"SpriteBatch transform and Quad values must be finite");
	luaL_argcheck(state, textureWidth > 0.0f && textureHeight > 0.0f, startIndex,
		"SpriteBatch texture dimensions must be positive");

	std::size_t index = 0;
	if (requestedIndex < 0)
	{
		if (batch.count >= batch.bufferSize)
		{
			luaL_argcheck(state, batch.bufferSize <= 500000, 1,
				"SpriteBatch automatic growth exceeds the 1000000 sprite limit");
			batch.bufferSize *= 2;
			batch.sprites.resize(batch.bufferSize);
		}
		index = batch.count++;
	}
	else
	{
		luaL_argcheck(state, requestedIndex >= 0
			&& static_cast<std::size_t>(requestedIndex) < batch.bufferSize, 2,
			"SpriteBatch sprite index is outside its buffer");
		index = static_cast<std::size_t>(requestedIndex);
	}

	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	const float a = cosine * scaleX - sine * scaleY * shearY;
	const float b = sine * scaleX + cosine * scaleY * shearY;
	const float c = cosine * scaleX * shearX - sine * scaleY;
	const float d = sine * scaleX * shearX + cosine * scaleY;
	const float tx = x - a * originX - c * originY;
	const float ty = y - b * originX - d * originY;
	const float positions[4][2] = {
		{0.0f, 0.0f}, {sourceWidth, 0.0f},
		{sourceWidth, sourceHeight}, {0.0f, sourceHeight}};
	const float u0 = sourceX / textureWidth;
	const float v0 = sourceY / textureHeight;
	const float u1 = (sourceX + sourceWidth) / textureWidth;
	const float v1 = (sourceY + sourceHeight) / textureHeight;
	const float texcoords[4][2] = {{u0, v0}, {u1, v0}, {u1, v1}, {u0, v1}};
	auto &sprite = batch.sprites[index];
	for (int vertexIndex = 0; vertexIndex < 4; ++vertexIndex)
	{
		auto &vertex = sprite.vertices[vertexIndex];
		const float px = positions[vertexIndex][0];
		const float py = positions[vertexIndex][1];
		vertex.x = a * px + c * py + tx;
		vertex.y = b * px + d * py + ty;
		vertex.u = texcoords[vertexIndex][0];
		vertex.v = texcoords[vertexIndex][1];
		vertex.red = batch.colorEnabled ? batch.color[0] : 1.0f;
		vertex.green = batch.colorEnabled ? batch.color[1] : 1.0f;
		vertex.blue = batch.colorEnabled ? batch.color[2] : 1.0f;
		vertex.alpha = batch.colorEnabled ? batch.color[3] : 1.0f;
		vertex.textureLayer = arrayTexture ? static_cast<float>(layer - 1)
			: std::numeric_limits<float>::quiet_NaN();
	}
	return static_cast<int>(index);
}
}

int LoveRuntime::spriteBatchAdd(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	const int index = writeSpriteBatchSprite(state, *batch, 2, -1);
	lua_pushinteger(state, index + 1);
	return 1;
}

int LoveRuntime::spriteBatchSet(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	const lua_Integer index = luaL_checkinteger(state, 2);
	luaL_argcheck(state, index >= 1 && index <= 1000000, 2,
		"SpriteBatch sprite index must be positive");
	writeSpriteBatchSprite(state, *batch, 3, static_cast<int>(index - 1));
	return 0;
}

int LoveRuntime::spriteBatchAddLayer(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	const lua_Integer layer = luaL_checkinteger(state, 2);
	luaL_argcheck(state, layer >= 1 && layer <= std::numeric_limits<int>::max(), 2,
		"SpriteBatch layer must be positive");
	const int index = writeSpriteBatchSprite(state, *batch, 3, -1, static_cast<int>(layer));
	lua_pushinteger(state, index + 1);
	return 1;
}

int LoveRuntime::spriteBatchSetLayer(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	const lua_Integer index = luaL_checkinteger(state, 2);
	const lua_Integer layer = luaL_checkinteger(state, 3);
	luaL_argcheck(state, index >= 1 && index <= 1000000, 2,
		"SpriteBatch sprite index must be positive");
	luaL_argcheck(state, layer >= 1 && layer <= std::numeric_limits<int>::max(), 3,
		"SpriteBatch layer must be positive");
	writeSpriteBatchSprite(state, *batch, 4, static_cast<int>(index - 1), static_cast<int>(layer));
	return 0;
}

int LoveRuntime::spriteBatchClear(lua_State *state)
{
	checkSpriteBatch(state, 1)->count = 0;
	return 0;
}

int LoveRuntime::spriteBatchFlush(lua_State *state)
{
	checkSpriteBatch(state, 1);
	return 0;
}

int LoveRuntime::spriteBatchSetTexture(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	auto *image = testImage(state, 2);
	auto *canvas = testCanvas(state, 2);
	if (!image && !canvas) return luaL_argerror(state, 2, "expected an Image or Canvas");
	if (image)
	{
		luaL_argcheck(state, image->runtime == batch->runtime && image->handle != 0, 2,
			"Image belongs to another or closed LoveRuntime");
		luaL_argcheck(state, image->textureType == batch->textureType, 2,
			"Texture must have the same texture type as the SpriteBatch's previous texture");
		batch->image = image->handle;
		batch->canvas = 0;
		batch->layerCount = image->slices;
		batch->textureObject.set(image);
	}
	else
	{
		luaL_argcheck(state, batch->textureType == GraphicsBackend::TextureType::Texture2D, 2,
			"Texture must have the same texture type as the SpriteBatch's previous texture");
		luaL_argcheck(state, canvas->runtime == batch->runtime && canvas->handle != 0
			&& batch->runtime->_canvasHandles.contains(canvas->handle), 2,
			"Canvas belongs to another or closed LoveRuntime");
		luaL_argcheck(state, canvas->readable, 2,
			"cannot use a non-readable Canvas as a SpriteBatch texture");
		batch->image = 0;
		batch->canvas = canvas->handle;
		batch->layerCount = 1;
		batch->textureObject.set(canvas);
	}
	lua_pushvalue(state, 2);
	lua_setiuservalue(state, 1, 1);
	return 0;
}

int LoveRuntime::spriteBatchGetTexture(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	if (batch->image != 0)
		::love::luax_pushtype(state, ImageUserdata::type,
			static_cast<ImageUserdata *>(batch->textureObject.get()));
	else ::love::luax_pushtype(state, CanvasUserdata::type,
		static_cast<CanvasUserdata *>(batch->textureObject.get()));
	return 1;
}

int LoveRuntime::spriteBatchSetColor(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	if (lua_gettop(state) == 1 || lua_isnoneornil(state, 2))
	{
		batch->colorEnabled = false;
		return 0;
	}
	float color[4]{1.0f, 1.0f, 1.0f, 1.0f};
	if (lua_istable(state, 2))
	{
		for (int index = 0; index < 4; ++index)
		{
			lua_rawgeti(state, 2, index + 1);
			color[index] = static_cast<float>(luaL_optnumber(state, -1, 1.0));
			lua_pop(state, 1);
		}
	}
	else
		for (int index = 0; index < 4; ++index)
			color[index] = static_cast<float>(luaL_optnumber(state, index + 2, 1.0));
	for (const float value : color)
		luaL_argcheck(state, std::isfinite(value), 2, "SpriteBatch color values must be finite");
	std::copy(std::begin(color), std::end(color), batch->color);
	batch->colorEnabled = true;
	return 0;
}

int LoveRuntime::spriteBatchGetColor(lua_State *state)
{
	const auto *batch = checkSpriteBatch(state, 1);
	if (!batch->colorEnabled) return 0;
	for (const float value : batch->color) lua_pushnumber(state, value);
	return 4;
}

int LoveRuntime::spriteBatchGetCount(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(checkSpriteBatch(state, 1)->count));
	return 1;
}

int LoveRuntime::spriteBatchGetBufferSize(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(checkSpriteBatch(state, 1)->bufferSize));
	return 1;
}

int LoveRuntime::spriteBatchAttachAttribute(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	const std::string name = luaL_checkstring(state, 2);
	auto *mesh = checkMesh(state, 3);
	luaL_argcheck(state, batch->runtime && mesh->runtime == batch->runtime, 3,
		"attached Mesh belongs to another or closed LoveRuntime");
	const std::size_t attributeIndex = meshAttributeIndex(*mesh, name);
	luaL_argcheck(state, attributeIndex < mesh->format.size(), 2,
		"the supplied Mesh does not have the requested vertex attribute");
	luaL_argcheck(state, batch->count <= std::numeric_limits<std::size_t>::max() / 4
		&& mesh->vertexCount >= batch->count * 4, 3,
		"Mesh has too few vertices to be attached to this SpriteBatch");
	batch->attachments[name] = {mesh, attributeIndex};
	batch->attachmentObjects[name].set(mesh);
	lua_getiuservalue(state, 1, 2);
	lua_pushvalue(state, 3);
	lua_setfield(state, -2, name.c_str());
	lua_pop(state, 1);
	return 0;
}

int LoveRuntime::spriteBatchSetDrawRange(lua_State *state)
{
	auto *batch = checkSpriteBatch(state, 1);
	if (lua_isnoneornil(state, 2))
	{
		batch->drawStart = -1;
		batch->drawCount = 0;
		return 0;
	}
	const lua_Integer start = luaL_checkinteger(state, 2);
	const lua_Integer count = luaL_checkinteger(state, 3);
	luaL_argcheck(state, start >= 1, 2, "SpriteBatch draw range start must be at least 1");
	luaL_argcheck(state, count > 0, 3, "SpriteBatch draw range count must be positive");
	batch->drawStart = static_cast<int>(start - 1);
	batch->drawCount = static_cast<int>(count);
	return 0;
}

int LoveRuntime::spriteBatchGetDrawRange(lua_State *state)
{
	const auto *batch = checkSpriteBatch(state, 1);
	if (batch->drawStart < 0) return 0;
	lua_pushinteger(state, batch->drawStart + 1);
	lua_pushinteger(state, batch->drawCount);
	return 2;
}

namespace
{
double particleRandom(ParticleSystemUserdata &system)
{
	std::uint64_t value = system.randomState;
	value ^= value >> 12;
	value ^= value << 25;
	value ^= value >> 27;
	system.randomState = value;
	return static_cast<double>((value * 2685821657736338717ULL) >> 11)
		* (1.0 / 9007199254740992.0);
}

float particleRandomRange(ParticleSystemUserdata &system, float minimum, float maximum)
{
	return minimum == maximum ? minimum
		: minimum + static_cast<float>(particleRandom(system)) * (maximum - minimum);
}

float particleRandomNormal(ParticleSystemUserdata &system, float deviation)
{
	const double u1 = std::max(particleRandom(system), std::numeric_limits<double>::min());
	const double u2 = particleRandom(system);
	return deviation * static_cast<float>(std::sqrt(-2.0 * std::log(u1))
		* std::cos(2.0 * std::numbers::pi * u2));
}

ParticleColor interpolateParticleColor(const ParticleColor &first,
	const ParticleColor &second, float amount)
{
	return {
		first.red + (second.red - first.red) * amount,
		first.green + (second.green - first.green) * amount,
		first.blue + (second.blue - first.blue) * amount,
		first.alpha + (second.alpha - first.alpha) * amount,
	};
}

float variedParticleValue(ParticleSystemUserdata &system,
	float value, float alternate, float variation)
{
	return value + (alternate - value) * variation
		* static_cast<float>(particleRandom(system));
}

void resetParticleSystemOffset(ParticleSystemUserdata &system)
{
	if (!system.defaultOffset || !system.runtime || !system.runtime->getGraphicsBackend()) return;
	if (!system.quads.empty())
	{
		system.offsetX = system.quads.front().width * 0.5f;
		system.offsetY = system.quads.front().height * 0.5f;
		return;
	}
	auto *graphics = system.runtime->getGraphicsBackend();
	system.offsetX = static_cast<float>(system.image != 0
		? graphics->getImageWidth(system.image) : graphics->getCanvasWidth(system.canvas)) * 0.5f;
	system.offsetY = static_cast<float>(system.image != 0
		? graphics->getImageHeight(system.image) : graphics->getCanvasHeight(system.canvas)) * 0.5f;
}

void initializeParticle(ParticleSystemUserdata &system, ParticleState &particle, float time)
{
	particle = {};
	particle.life = particleRandomRange(system,
		system.particleLifetimeMin, system.particleLifetimeMax);
	particle.lifetime = particle.life;
	particle.x = system.previousX + (system.positionX - system.previousX) * time;
	particle.y = system.previousY + (system.positionY - system.previousY) * time;
	const float centerX = particle.x, centerY = particle.y;
	float direction = particleRandomRange(system,
		system.direction - system.spread * 0.5f,
		system.direction + system.spread * 0.5f);
	float dx = 0.0f, dy = 0.0f;
	if (system.emissionDistribution == "uniform")
	{
		dx = particleRandomRange(system, -system.emissionX, system.emissionX);
		dy = particleRandomRange(system, -system.emissionY, system.emissionY);
	}
	else if (system.emissionDistribution == "normal")
	{
		dx = particleRandomNormal(system, system.emissionX);
		dy = particleRandomNormal(system, system.emissionY);
	}
	else if (system.emissionDistribution == "ellipse")
	{
		const float rx = particleRandomRange(system, -1.0f, 1.0f);
		const float ry = particleRandomRange(system, -1.0f, 1.0f);
		dx = system.emissionX * rx * std::sqrt(std::max(0.0f, 1.0f - 0.5f * ry * ry));
		dy = system.emissionY * ry * std::sqrt(std::max(0.0f, 1.0f - 0.5f * rx * rx));
	}
	else if (system.emissionDistribution == "borderellipse")
	{
		const float radians = particleRandomRange(system, 0.0f,
			2.0f * std::numbers::pi_v<float>);
		dx = std::cos(radians) * system.emissionX;
		dy = std::sin(radians) * system.emissionY;
	}
	else if (system.emissionDistribution == "borderrectangle")
	{
		const float width = system.emissionX * 2.0f;
		const float height = system.emissionY * 2.0f;
		float point = particleRandomRange(system, 0.0f, 2.0f * (width + height));
		if (point < width) { dx = -system.emissionX + point; dy = -system.emissionY; }
		else if ((point -= width) < height) { dx = system.emissionX; dy = -system.emissionY + point; }
		else if ((point -= height) < width) { dx = system.emissionX - point; dy = system.emissionY; }
		else { point -= width; dx = -system.emissionX; dy = system.emissionY - point; }
	}
	const float areaCosine = std::cos(system.emissionAngle);
	const float areaSine = std::sin(system.emissionAngle);
	particle.x += areaCosine * dx - areaSine * dy;
	particle.y += areaSine * dx + areaCosine * dy;
	if (system.directionRelativeToCenter)
		direction += std::atan2(particle.y - centerY, particle.x - centerX);
	particle.originX = centerX;
	particle.originY = centerY;
	const float speed = particleRandomRange(system, system.speedMin, system.speedMax);
	particle.velocityX = std::cos(direction) * speed;
	particle.velocityY = std::sin(direction) * speed;
	particle.accelerationX = particleRandomRange(system, system.accelerationMinX, system.accelerationMaxX);
	particle.accelerationY = particleRandomRange(system, system.accelerationMinY, system.accelerationMaxY);
	particle.radialAcceleration = particleRandomRange(system, system.radialMin, system.radialMax);
	particle.tangentialAcceleration = particleRandomRange(system, system.tangentialMin, system.tangentialMax);
	particle.linearDamping = particleRandomRange(system, system.dampingMin, system.dampingMax);
	particle.sizeOffset = particleRandomRange(system, 0.0f, system.sizeVariation);
	particle.sizeInterval = 1.0f - particleRandomRange(system, 0.0f, system.sizeVariation)
		- particle.sizeOffset;
	particle.size = system.sizes.front();
	particle.spinStart = variedParticleValue(system,
		system.spinStart, system.spinEnd, system.spinVariation);
	particle.spinEnd = variedParticleValue(system,
		system.spinEnd, system.spinStart, system.spinVariation);
	particle.rotation = particleRandomRange(system, system.rotationMin, system.rotationMax);
	particle.angle = particle.rotation;
	if (system.relativeRotation)
		particle.angle += std::atan2(particle.velocityY, particle.velocityX);
	particle.color = system.colors.front();
}

void addParticle(ParticleSystemUserdata &system, float time)
{
	if (system.particles.size() >= system.bufferSize) return;
	ParticleState particle;
	initializeParticle(system, particle, time);
	if (system.insertMode == "bottom") system.particles.insert(system.particles.begin(), particle);
	else if (system.insertMode == "random")
	{
		const std::size_t index = static_cast<std::size_t>(particleRandom(system)
			* static_cast<double>(system.particles.size() + 1));
		system.particles.insert(system.particles.begin()
			+ static_cast<std::ptrdiff_t>(std::min(index, system.particles.size())), particle);
	}
	else system.particles.push_back(particle);
}

float checkedFiniteFloat(lua_State *state, int index, const char *message)
{
	const float value = static_cast<float>(luaL_checknumber(state, index));
	luaL_argcheck(state, std::isfinite(value), index, message);
	return value;
}
}

int LoveRuntime::particleSystemClone(lua_State *state)
{
	auto *source = checkParticleSystem(state, 1);
	auto *clone = new ParticleSystemUserdata(*source);
	clone->particles.clear();
	clone->particles.reserve(clone->bufferSize);
	clone->emitCounter = 0.0f;
	clone->emitterLife = clone->emitterLifetime;
	::love::luax_pushtype(state, ParticleSystemLoveType, clone);
	for (int uservalue = 1; uservalue <= 2; ++uservalue)
	{
		lua_getiuservalue(state, 1, uservalue);
		lua_setiuservalue(state, -2, uservalue);
	}
	clone->release();
	return 1;
}

int LoveRuntime::particleSystemSetTexture(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	auto *image = testImage(state, 2);
	auto *canvas = testCanvas(state, 2);
	if (!image && !canvas) return luaL_argerror(state, 2, "expected a 2D Image or Canvas");
	if (image)
	{
		luaL_argcheck(state, image->runtime == system->runtime && image->handle != 0, 2,
			"Image belongs to another or closed LoveRuntime");
		luaL_argcheck(state, image->textureType == GraphicsBackend::TextureType::Texture2D, 2,
			"ParticleSystem supports only 2D textures");
		system->image = image->handle; system->canvas = 0;
		system->textureObject.set(image);
	}
	else
	{
		luaL_argcheck(state, canvas->runtime == system->runtime && canvas->handle != 0
			&& system->runtime->_canvasHandles.contains(canvas->handle), 2,
			"Canvas belongs to another or closed LoveRuntime");
		luaL_argcheck(state, canvas->readable, 2,
			"cannot use a non-readable Canvas as a ParticleSystem texture");
		system->image = 0; system->canvas = canvas->handle;
		system->textureObject.set(canvas);
	}
	lua_pushvalue(state, 2); lua_setiuservalue(state, 1, 1);
	resetParticleSystemOffset(*system);
	return 0;
}

int LoveRuntime::particleSystemGetTexture(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	if (system->image != 0)
		::love::luax_pushtype(state, ImageUserdata::type,
			static_cast<ImageUserdata *>(system->textureObject.get()));
	else ::love::luax_pushtype(state, CanvasUserdata::type,
		static_cast<CanvasUserdata *>(system->textureObject.get()));
	return 1;
}

int LoveRuntime::particleSystemSetBufferSize(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	const lua_Integer size = luaL_checkinteger(state, 2);
	luaL_argcheck(state, size >= 1 && size <= 1000000, 2,
		"ParticleSystem buffer size must be between 1 and 1000000");
	system->particles.clear(); system->particles.shrink_to_fit();
	system->bufferSize = static_cast<std::size_t>(size); system->particles.reserve(system->bufferSize);
	system->emitterLife = system->emitterLifetime; system->emitCounter = 0.0f;
	return 0;
}

int LoveRuntime::particleSystemGetBufferSize(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(checkParticleSystem(state, 1)->bufferSize)); return 1;
}

int LoveRuntime::particleSystemSetInsertMode(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1); const std::string mode = luaL_checkstring(state, 2);
	luaL_argcheck(state, mode == "top" || mode == "bottom" || mode == "random", 2,
		"expected insert mode 'top', 'bottom', or 'random'");
	system->insertMode = mode; return 0;
}

int LoveRuntime::particleSystemGetInsertMode(lua_State *state)
{
	const auto &mode = checkParticleSystem(state, 1)->insertMode;
	lua_pushlstring(state, mode.data(), mode.size()); return 1;
}

int LoveRuntime::particleSystemSetEmissionRate(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1); const float rate = checkedFiniteFloat(state, 2, "emission rate must be finite");
	luaL_argcheck(state, rate >= 0.0f, 2, "emission rate must be non-negative");
	system->emissionRate = rate;
	if (rate > 0.0f) system->emitCounter = std::min(system->emitCounter, 1.0f / rate);
	return 0;
}

int LoveRuntime::particleSystemGetEmissionRate(lua_State *state)
{ lua_pushnumber(state, checkParticleSystem(state, 1)->emissionRate); return 1; }

int LoveRuntime::particleSystemSetEmitterLifetime(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	system->emitterLife = system->emitterLifetime = checkedFiniteFloat(state, 2, "emitter lifetime must be finite"); return 0;
}

int LoveRuntime::particleSystemGetEmitterLifetime(lua_State *state)
{ lua_pushnumber(state, checkParticleSystem(state, 1)->emitterLifetime); return 1; }

int LoveRuntime::particleSystemSetParticleLifetime(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	const float minimum = checkedFiniteFloat(state, 2, "particle lifetime must be finite");
	const float maximum = static_cast<float>(luaL_optnumber(state, 3, minimum));
	luaL_argcheck(state, std::isfinite(maximum) && minimum >= 0.0f && maximum >= 0.0f, 3,
		"particle lifetime must be finite and non-negative");
	system->particleLifetimeMin = minimum; system->particleLifetimeMax = maximum; return 0;
}

int LoveRuntime::particleSystemGetParticleLifetime(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	lua_pushnumber(state, system->particleLifetimeMin); lua_pushnumber(state, system->particleLifetimeMax); return 2;
}

int LoveRuntime::particleSystemSetPosition(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	system->positionX = system->previousX = checkedFiniteFloat(state, 2, "position must be finite");
	system->positionY = system->previousY = checkedFiniteFloat(state, 3, "position must be finite"); return 0;
}

int LoveRuntime::particleSystemGetPosition(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	lua_pushnumber(state, system->positionX); lua_pushnumber(state, system->positionY); return 2;
}

int LoveRuntime::particleSystemMoveTo(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	system->positionX = checkedFiniteFloat(state, 2, "position must be finite");
	system->positionY = checkedFiniteFloat(state, 3, "position must be finite"); return 0;
}

int LoveRuntime::particleSystemSetEmissionArea(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	const std::string distribution = lua_isnoneornil(state, 2) ? "none" : luaL_checkstring(state, 2);
	const bool valid = distribution == "none" || distribution == "uniform" || distribution == "normal"
		|| distribution == "ellipse" || distribution == "borderellipse" || distribution == "borderrectangle";
	luaL_argcheck(state, valid, 2, "invalid particle emission area distribution");
	float x = 0.0f, y = 0.0f, angle = 0.0f; bool relative = false;
	if (distribution != "none")
	{
		x = checkedFiniteFloat(state, 3, "emission area must be finite");
		y = checkedFiniteFloat(state, 4, "emission area must be finite");
		angle = static_cast<float>(luaL_optnumber(state, 5, 0.0)); relative = lua_toboolean(state, 6) != 0;
		luaL_argcheck(state, x >= 0.0f && y >= 0.0f && std::isfinite(angle), 3,
			"emission area parameters must be finite and non-negative");
	}
	system->emissionDistribution = distribution; system->emissionX = x; system->emissionY = y;
	system->emissionAngle = angle; system->directionRelativeToCenter = relative; return 0;
}

int LoveRuntime::particleSystemGetEmissionArea(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	lua_pushlstring(state, system->emissionDistribution.data(), system->emissionDistribution.size());
	lua_pushnumber(state, system->emissionX); lua_pushnumber(state, system->emissionY);
	lua_pushnumber(state, system->emissionAngle); lua_pushboolean(state, system->directionRelativeToCenter); return 5;
}

int LoveRuntime::particleSystemSetAreaSpread(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	const std::string distribution = lua_isnoneornil(state, 2) ? "none" : luaL_checkstring(state, 2);
	const bool valid = distribution == "none" || distribution == "uniform" || distribution == "normal"
		|| distribution == "ellipse" || distribution == "borderellipse" || distribution == "borderrectangle";
	luaL_argcheck(state, valid, 2, "invalid particle area spread distribution");
	float x = 0.0f, y = 0.0f;
	if (distribution != "none")
	{
		x = checkedFiniteFloat(state, 3, "area spread must be finite");
		y = checkedFiniteFloat(state, 4, "area spread must be finite");
		luaL_argcheck(state, x >= 0.0f && y >= 0.0f, 3,
			"area spread parameters must be non-negative");
	}
	system->emissionDistribution = distribution; system->emissionX = x; system->emissionY = y;
	system->emissionAngle = 0.0f; system->directionRelativeToCenter = false; return 0;
}

int LoveRuntime::particleSystemGetAreaSpread(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	lua_pushlstring(state, system->emissionDistribution.data(), system->emissionDistribution.size());
	lua_pushnumber(state, system->emissionX); lua_pushnumber(state, system->emissionY); return 3;
}

#define PARTICLE_SCALAR_ACCESSORS(Name, field, message) \
int LoveRuntime::particleSystemSet##Name(lua_State *state) { auto *s = checkParticleSystem(state, 1); s->field = checkedFiniteFloat(state, 2, message); return 0; } \
int LoveRuntime::particleSystemGet##Name(lua_State *state) { lua_pushnumber(state, checkParticleSystem(state, 1)->field); return 1; }
PARTICLE_SCALAR_ACCESSORS(Direction, direction, "direction must be finite")
PARTICLE_SCALAR_ACCESSORS(Spread, spread, "spread must be finite")
PARTICLE_SCALAR_ACCESSORS(SpinVariation, spinVariation, "spin variation must be finite")
#undef PARTICLE_SCALAR_ACCESSORS

int LoveRuntime::particleSystemSetSizeVariation(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	const float variation = checkedFiniteFloat(state, 2, "size variation must be finite");
	luaL_argcheck(state, variation >= 0.0f && variation <= 1.0f, 2,
		"size variation must be between 0 and 1");
	system->sizeVariation = variation; return 0;
}

int LoveRuntime::particleSystemGetSizeVariation(lua_State *state)
{ lua_pushnumber(state, checkParticleSystem(state, 1)->sizeVariation); return 1; }

int LoveRuntime::particleSystemSetSpeed(lua_State *state)
{
	auto *s = checkParticleSystem(state, 1); s->speedMin = checkedFiniteFloat(state, 2, "speed must be finite");
	s->speedMax = static_cast<float>(luaL_optnumber(state, 3, s->speedMin));
	luaL_argcheck(state, std::isfinite(s->speedMax), 3, "speed must be finite"); return 0;
}
int LoveRuntime::particleSystemGetSpeed(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); lua_pushnumber(state, s->speedMin); lua_pushnumber(state, s->speedMax); return 2; }

int LoveRuntime::particleSystemSetLinearAcceleration(lua_State *state)
{
	auto *s = checkParticleSystem(state, 1);
	s->accelerationMinX = checkedFiniteFloat(state, 2, "acceleration must be finite");
	s->accelerationMinY = checkedFiniteFloat(state, 3, "acceleration must be finite");
	s->accelerationMaxX = static_cast<float>(luaL_optnumber(state, 4, s->accelerationMinX));
	s->accelerationMaxY = static_cast<float>(luaL_optnumber(state, 5, s->accelerationMinY));
	luaL_argcheck(state, std::isfinite(s->accelerationMaxX) && std::isfinite(s->accelerationMaxY), 4,
		"acceleration must be finite"); return 0;
}
int LoveRuntime::particleSystemGetLinearAcceleration(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); lua_pushnumber(state, s->accelerationMinX); lua_pushnumber(state, s->accelerationMinY); lua_pushnumber(state, s->accelerationMaxX); lua_pushnumber(state, s->accelerationMaxY); return 4; }

#define PARTICLE_RANGE_ACCESSORS(Name, minfield, maxfield, message) \
int LoveRuntime::particleSystemSet##Name(lua_State *state) { auto *s = checkParticleSystem(state, 1); s->minfield = checkedFiniteFloat(state, 2, message); s->maxfield = static_cast<float>(luaL_optnumber(state, 3, s->minfield)); luaL_argcheck(state, std::isfinite(s->maxfield), 3, message); return 0; } \
int LoveRuntime::particleSystemGet##Name(lua_State *state) { auto *s = checkParticleSystem(state, 1); lua_pushnumber(state, s->minfield); lua_pushnumber(state, s->maxfield); return 2; }
PARTICLE_RANGE_ACCESSORS(RadialAcceleration, radialMin, radialMax, "radial acceleration must be finite")
PARTICLE_RANGE_ACCESSORS(TangentialAcceleration, tangentialMin, tangentialMax, "tangential acceleration must be finite")
PARTICLE_RANGE_ACCESSORS(LinearDamping, dampingMin, dampingMax, "linear damping must be finite")
PARTICLE_RANGE_ACCESSORS(Rotation, rotationMin, rotationMax, "rotation must be finite")
PARTICLE_RANGE_ACCESSORS(Spin, spinStart, spinEnd, "spin must be finite")
#undef PARTICLE_RANGE_ACCESSORS

int LoveRuntime::particleSystemSetSizes(lua_State *state)
{
	auto *s = checkParticleSystem(state, 1); const int count = lua_gettop(state) - 1;
	luaL_argcheck(state, count >= 1 && count <= 8, 2, "ParticleSystem requires between one and eight sizes");
	s->sizes.resize(static_cast<std::size_t>(count));
	for (int index = 0; index < count; ++index)
		s->sizes[static_cast<std::size_t>(index)] = checkedFiniteFloat(state, index + 2, "size must be finite");
	return 0;
}
int LoveRuntime::particleSystemGetSizes(lua_State *state)
{ const auto &v = checkParticleSystem(state, 1)->sizes; for (float n : v) lua_pushnumber(state, n); return static_cast<int>(v.size()); }

int LoveRuntime::particleSystemSetOffset(lua_State *state)
{
	auto *s = checkParticleSystem(state, 1); s->offsetX = checkedFiniteFloat(state, 2, "offset must be finite");
	s->offsetY = checkedFiniteFloat(state, 3, "offset must be finite"); s->defaultOffset = false; return 0;
}
int LoveRuntime::particleSystemGetOffset(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); lua_pushnumber(state, s->offsetX); lua_pushnumber(state, s->offsetY); return 2; }

int LoveRuntime::particleSystemSetColors(lua_State *state)
{
	auto *s = checkParticleSystem(state, 1); std::vector<ParticleColor> colors;
	if (lua_istable(state, 2))
	{
		const int count = lua_gettop(state) - 1; luaL_argcheck(state, count <= 8, 2, "at most eight colors may be used");
		for (int index = 0; index < count; ++index)
		{
			luaL_checktype(state, index + 2, LUA_TTABLE); ParticleColor color;
			for (int component = 0; component < 4; ++component)
			{
				lua_rawgeti(state, index + 2, component + 1);
				const float value = static_cast<float>(luaL_optnumber(state, -1, 1.0)); lua_pop(state, 1);
				luaL_argcheck(state, std::isfinite(value), index + 2, "color must be finite");
				switch (component)
				{
					case 0: color.red = std::clamp(value, 0.0f, 1.0f); break;
					case 1: color.green = std::clamp(value, 0.0f, 1.0f); break;
					case 2: color.blue = std::clamp(value, 0.0f, 1.0f); break;
					default: color.alpha = std::clamp(value, 0.0f, 1.0f); break;
				}
			}
			colors.push_back(color);
		}
	}
	else
	{
		const int components = lua_gettop(state) - 1;
		luaL_argcheck(state, components == 3 || (components >= 4 && components % 4 == 0), 2,
			"expected RGB or groups of RGBA color components");
		const int count = components == 3 ? 1 : components / 4;
		luaL_argcheck(state, count <= 8, 2, "at most eight colors may be used");
		for (int index = 0; index < count; ++index)
		{
			ParticleColor color;
			const float red = checkedFiniteFloat(state, 2 + index * 4, "color must be finite");
			const float green = checkedFiniteFloat(state, 3 + index * 4, "color must be finite");
			const float blue = checkedFiniteFloat(state, 4 + index * 4, "color must be finite");
			const float alpha = components == 3 ? 1.0f
				: checkedFiniteFloat(state, 5 + index * 4, "color must be finite");
			color = {std::clamp(red, 0.0f, 1.0f), std::clamp(green, 0.0f, 1.0f),
				std::clamp(blue, 0.0f, 1.0f), std::clamp(alpha, 0.0f, 1.0f)};
			colors.push_back(color);
		}
	}
	luaL_argcheck(state, !colors.empty(), 2, "at least one color is required"); s->colors = std::move(colors); return 0;
}

int LoveRuntime::particleSystemGetColors(lua_State *state)
{
	const auto &colors = checkParticleSystem(state, 1)->colors;
	for (const auto &color : colors)
	{
		lua_createtable(state, 4, 0); const float values[] = {color.red, color.green, color.blue, color.alpha};
		for (int index = 0; index < 4; ++index) { lua_pushnumber(state, values[index]); lua_rawseti(state, -2, index + 1); }
	}
	return static_cast<int>(colors.size());
}

int LoveRuntime::particleSystemSetQuads(lua_State *state)
{
	auto *s = checkParticleSystem(state, 1); std::vector<ParticleQuad> quads;
	std::vector<::love::StrongRef<::love::Object>> quadObjects;
	lua_newtable(state); const int refs = lua_gettop(state);
	const auto addQuad = [&](int valueIndex, int outputIndex) {
		auto *quad = checkQuad(state, valueIndex);
		luaL_argcheck(state, quad->runtime == s->runtime && quad->layer == 1, valueIndex,
			"ParticleSystem Quad must belong to this LoveRuntime and use layer 1");
		quads.push_back({quad->x, quad->y, quad->width, quad->height,
			quad->textureWidth, quad->textureHeight});
		quadObjects.emplace_back(quad);
		lua_pushvalue(state, valueIndex); lua_rawseti(state, refs, outputIndex);
	};
	if (lua_istable(state, 2))
	{
		const std::size_t count = lua_rawlen(state, 2);
		for (std::size_t index = 0; index < count; ++index)
		{
			lua_rawgeti(state, 2, static_cast<lua_Integer>(index + 1));
			addQuad(-1, static_cast<int>(index + 1)); lua_pop(state, 1);
		}
	}
	else for (int index = 2; index < refs; ++index) addQuad(index, index - 1);
	s->quads = std::move(quads); s->quadObjects = std::move(quadObjects);
	lua_setiuservalue(state, 1, 2); resetParticleSystemOffset(*s); return 0;
}

int LoveRuntime::particleSystemGetQuads(lua_State *state)
{
	auto *system = checkParticleSystem(state, 1);
	lua_createtable(state, static_cast<int>(system->quadObjects.size()), 0);
	for (std::size_t index = 0; index < system->quadObjects.size(); ++index)
	{
		::love::luax_pushtype(state, QuadLoveType,
			static_cast<QuadUserdata *>(system->quadObjects[index].get()));
		lua_rawseti(state, -2, static_cast<lua_Integer>(index + 1));
	}
	return 1;
}

int LoveRuntime::particleSystemSetRelativeRotation(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); luaL_checktype(state, 2, LUA_TBOOLEAN); s->relativeRotation = lua_toboolean(state, 2) != 0; return 0; }
int LoveRuntime::particleSystemHasRelativeRotation(lua_State *state)
{ lua_pushboolean(state, checkParticleSystem(state, 1)->relativeRotation); return 1; }
int LoveRuntime::particleSystemGetCount(lua_State *state)
{ lua_pushinteger(state, static_cast<lua_Integer>(checkParticleSystem(state, 1)->particles.size())); return 1; }
int LoveRuntime::particleSystemStart(lua_State *state)
{ checkParticleSystem(state, 1)->active = true; return 0; }
int LoveRuntime::particleSystemStop(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); s->active = false; s->emitterLife = s->emitterLifetime; s->emitCounter = 0.0f; return 0; }
int LoveRuntime::particleSystemPause(lua_State *state)
{ checkParticleSystem(state, 1)->active = false; return 0; }
int LoveRuntime::particleSystemReset(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); s->particles.clear(); s->emitterLife = s->emitterLifetime; s->emitCounter = 0.0f; return 0; }
int LoveRuntime::particleSystemEmit(lua_State *state)
{
	auto *s = checkParticleSystem(state, 1); const lua_Integer count = luaL_checkinteger(state, 2);
	luaL_argcheck(state, count >= 0, 2, "particle count must be non-negative");
	if (s->active) for (lua_Integer index = 0; index < count && s->particles.size() < s->bufferSize; ++index) addParticle(*s, 1.0f);
	return 0;
}
int LoveRuntime::particleSystemIsActive(lua_State *state)
{ lua_pushboolean(state, checkParticleSystem(state, 1)->active); return 1; }
int LoveRuntime::particleSystemIsPaused(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); lua_pushboolean(state, !s->active && s->emitterLife < s->emitterLifetime); return 1; }
int LoveRuntime::particleSystemIsStopped(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); lua_pushboolean(state, !s->active && s->emitterLife >= s->emitterLifetime); return 1; }
int LoveRuntime::particleSystemIsEmpty(lua_State *state)
{ lua_pushboolean(state, checkParticleSystem(state, 1)->particles.empty()); return 1; }
int LoveRuntime::particleSystemIsFull(lua_State *state)
{ auto *s = checkParticleSystem(state, 1); lua_pushboolean(state, s->particles.size() >= s->bufferSize); return 1; }

int LoveRuntime::particleSystemUpdate(lua_State *state)
{
	auto *s = checkParticleSystem(state, 1); const float dt = checkedFiniteFloat(state, 2, "update time must be finite");
	luaL_argcheck(state, dt >= 0.0f, 2, "update time must be non-negative");
	if (dt == 0.0f) return 0;
	for (std::size_t index = 0; index < s->particles.size();)
	{
		auto &particle = s->particles[index]; particle.life -= dt;
		if (particle.life <= 0.0f) { s->particles.erase(s->particles.begin() + static_cast<std::ptrdiff_t>(index)); continue; }
		float radialX = particle.x - particle.originX, radialY = particle.y - particle.originY;
		const float distance = std::sqrt(radialX * radialX + radialY * radialY);
		if (distance > 0.0f) { radialX /= distance; radialY /= distance; }
		const float tangentX = -radialY * particle.tangentialAcceleration;
		const float tangentY = radialX * particle.tangentialAcceleration;
		particle.velocityX += (radialX * particle.radialAcceleration + tangentX + particle.accelerationX) * dt;
		particle.velocityY += (radialY * particle.radialAcceleration + tangentY + particle.accelerationY) * dt;
		const float damping = 1.0f / (1.0f + particle.linearDamping * dt);
		particle.velocityX *= damping; particle.velocityY *= damping;
		particle.x += particle.velocityX * dt; particle.y += particle.velocityY * dt;
		const float age = particle.lifetime > 0.0f ? 1.0f - particle.life / particle.lifetime : 1.0f;
		particle.rotation += (particle.spinStart * (1.0f - age) + particle.spinEnd * age) * dt;
		particle.angle = particle.rotation + (s->relativeRotation
			? std::atan2(particle.velocityY, particle.velocityX) : 0.0f);
		float progress = std::clamp(particle.sizeOffset + age * particle.sizeInterval, 0.0f, 1.0f)
			* static_cast<float>(s->sizes.size() - 1);
		std::size_t first = std::min(static_cast<std::size_t>(progress), s->sizes.size() - 1);
		std::size_t second = std::min(first + 1, s->sizes.size() - 1);
		particle.size = s->sizes[first] + (s->sizes[second] - s->sizes[first])
			* (progress - static_cast<float>(first));
		progress = std::clamp(age, 0.0f, 1.0f) * static_cast<float>(s->colors.size() - 1);
		first = std::min(static_cast<std::size_t>(progress), s->colors.size() - 1);
		second = std::min(first + 1, s->colors.size() - 1);
		particle.color = interpolateParticleColor(s->colors[first], s->colors[second],
			progress - static_cast<float>(first));
		if (!s->quads.empty()) particle.quadIndex = std::min(static_cast<std::size_t>(
			std::clamp(age, 0.0f, 1.0f) * static_cast<float>(s->quads.size())), s->quads.size() - 1);
		++index;
	}
	if (s->active)
	{
		if (s->emissionRate > 0.0f)
		{
			const float interval = 1.0f / s->emissionRate; s->emitCounter += dt;
			const float total = std::max(s->emitCounter - interval, std::numeric_limits<float>::epsilon());
			while (s->emitCounter > interval && s->particles.size() < s->bufferSize)
			{
				addParticle(*s, std::clamp(1.0f - (s->emitCounter - interval) / total, 0.0f, 1.0f));
				s->emitCounter -= interval;
			}
		}
		s->emitterLife -= dt;
		if (s->emitterLifetime != -1.0f && s->emitterLife < 0.0f)
		{
			s->active = false; s->emitterLife = s->emitterLifetime; s->emitCounter = 0.0f;
		}
	}
	s->previousX = s->positionX; s->previousY = s->positionY; return 0;
}

namespace
{
int addTextEntry(lua_State *state, TextUserdata &text, int textIndex,
	float wrap, std::string align, int transformIndex, bool replace)
{
	luaL_argcheck(state, text.runtime && text.runtime->getGraphicsBackend()
		&& text.runtime->getGraphicsBackend()->getFontHeight(text.font) > 0.0f, 1, "closed Text");
	TextEntry entry;
	entry.fragments = readTextFragments(state, textIndex);
	entry.wrap = wrap;
	entry.align = std::move(align);
	readTextTransform(state, transformIndex, entry.transform);
	layoutTextEntry(entry, *text.runtime->getGraphicsBackend(), text.font);
	if (replace) text.entries.clear();
	text.entries.push_back(std::move(entry));
	return static_cast<int>(text.entries.size() - 1);
}
}

int LoveRuntime::textSet(lua_State *state)
{
	auto *text = checkText(state, 1);
	auto fragments = readTextFragments(state, 2);
	bool empty = true; for (const auto &fragment : fragments) empty &= fragment.text.empty();
	if (empty) { text->entries.clear(); return 0; }
	TextEntry entry; entry.fragments = std::move(fragments); setTransformIdentity(entry.transform);
	layoutTextEntry(entry, *text->runtime->_graphicsBackend, text->font);
	text->entries.clear(); text->entries.push_back(std::move(entry)); return 0;
}

int LoveRuntime::textSetf(lua_State *state)
{
	auto *text = checkText(state, 1);
	const float wrap = checkedFiniteFloat(state, 3, "Text wrap limit must be finite");
	luaL_argcheck(state, wrap >= 0.0f, 3, "Text wrap limit must be non-negative");
	const std::string align = luaL_checkstring(state, 4);
	luaL_argcheck(state, align == "left" || align == "center" || align == "right"
		|| align == "justify", 4,
		"supported Text alignments are 'left', 'center', 'right', and 'justify'");
	auto fragments = readTextFragments(state, 2);
	bool empty = true; for (const auto &fragment : fragments) empty &= fragment.text.empty();
	if (empty) { text->entries.clear(); return 0; }
	TextEntry entry; entry.fragments = std::move(fragments); entry.wrap = wrap; entry.align = align;
	setTransformIdentity(entry.transform); layoutTextEntry(entry, *text->runtime->_graphicsBackend, text->font);
	text->entries.clear(); text->entries.push_back(std::move(entry)); return 0;
}

int LoveRuntime::textAdd(lua_State *state)
{
	auto *text = checkText(state, 1);
	const int index = addTextEntry(state, *text, 2, -1.0f, "left", 3, false);
	lua_pushinteger(state, index + 1); return 1;
}

int LoveRuntime::textAddf(lua_State *state)
{
	auto *text = checkText(state, 1);
	const float wrap = checkedFiniteFloat(state, 3, "Text wrap limit must be finite");
	luaL_argcheck(state, wrap >= 0.0f, 3, "Text wrap limit must be non-negative");
	const std::string align = luaL_checkstring(state, 4);
	luaL_argcheck(state, align == "left" || align == "center" || align == "right"
		|| align == "justify", 4,
		"supported Text alignments are 'left', 'center', 'right', and 'justify'");
	const int index = addTextEntry(state, *text, 2, wrap, align, 5, false);
	lua_pushinteger(state, index + 1); return 1;
}

int LoveRuntime::textClear(lua_State *state)
{ checkText(state, 1)->entries.clear(); return 0; }

int LoveRuntime::textSetFont(lua_State *state)
{
	auto *text = checkText(state, 1); auto *font = checkFont(state, 2);
	luaL_argcheck(state, font->runtime == text->runtime && text->runtime->_fontHandles.contains(font->handle), 2,
		"Font belongs to another or closed LoveRuntime");
	text->font = font->handle;
	text->fontObject.set(font);
	for (auto &entry : text->entries)
		layoutTextEntry(entry, *text->runtime->_graphicsBackend, text->font);
	lua_pushvalue(state, 2); lua_setiuservalue(state, 1, 1); return 0;
}

int LoveRuntime::textGetFont(lua_State *state)
{
	auto *text = checkText(state, 1);
	::love::luax_pushtype(state, FontUserdata::type,
		static_cast<FontUserdata *>(text->fontObject.get()));
	return 1;
}

int LoveRuntime::textGetWidth(lua_State *state)
{
	auto *text = checkText(state, 1); const lua_Integer requested = luaL_optinteger(state, 2, 0);
	std::size_t index = requested <= 0 ? (text->entries.empty() ? 0 : text->entries.size() - 1)
		: static_cast<std::size_t>(requested - 1);
	lua_pushnumber(state, index < text->entries.size() ? text->entries[index].width : 0.0f); return 1;
}

int LoveRuntime::textGetHeight(lua_State *state)
{
	auto *text = checkText(state, 1); const lua_Integer requested = luaL_optinteger(state, 2, 0);
	std::size_t index = requested <= 0 ? (text->entries.empty() ? 0 : text->entries.size() - 1)
		: static_cast<std::size_t>(requested - 1);
	lua_pushnumber(state, index < text->entries.size() ? text->entries[index].height : 0.0f); return 1;
}

int LoveRuntime::textGetDimensions(lua_State *state)
{
	auto *text = checkText(state, 1); const lua_Integer requested = luaL_optinteger(state, 2, 0);
	const std::size_t index = requested <= 0 ? (text->entries.empty() ? 0 : text->entries.size() - 1)
		: static_cast<std::size_t>(requested - 1);
	const bool valid = index < text->entries.size();
	lua_pushnumber(state, valid ? text->entries[index].width : 0.0f);
	lua_pushnumber(state, valid ? text->entries[index].height : 0.0f);
	return 2;
}

int LoveRuntime::imageGetWidth(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < image->mipmapCount, 2, "invalid mipmap index");
	const int pixels = std::max(1, image->runtime->_graphicsBackend->getImageWidth(image->handle) >> mipmap);
	lua_pushnumber(state, pixels / image->dpiScale);
	return 1;
}

int LoveRuntime::imageGetHeight(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < image->mipmapCount, 2, "invalid mipmap index");
	const int pixels = std::max(1, image->runtime->_graphicsBackend->getImageHeight(image->handle) >> mipmap);
	lua_pushnumber(state, pixels / image->dpiScale);
	return 1;
}

int LoveRuntime::imageGetDimensions(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < image->mipmapCount, 2, "invalid mipmap index");
	lua_pushnumber(state, std::max(1, image->runtime->_graphicsBackend->getImageWidth(image->handle) >> mipmap) / image->dpiScale);
	lua_pushnumber(state, std::max(1, image->runtime->_graphicsBackend->getImageHeight(image->handle) >> mipmap) / image->dpiScale);
	return 2;
}

int LoveRuntime::imageGetTextureType(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	const char *name = "2d";
	switch (image->textureType)
	{
		case GraphicsBackend::TextureType::Array: name = "array"; break;
		case GraphicsBackend::TextureType::Cube: name = "cube"; break;
		case GraphicsBackend::TextureType::Volume: name = "volume"; break;
		case GraphicsBackend::TextureType::Texture2D: break;
	}
	lua_pushstring(state, name);
	return 1;
}

int LoveRuntime::imageGetDepth(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < image->mipmapCount, 2, "invalid mipmap index");
	lua_pushinteger(state, image->textureType == GraphicsBackend::TextureType::Volume
		? std::max(1, image->slices >> mipmap) : 1);
	return 1;
}

int LoveRuntime::imageGetLayerCount(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	lua_pushinteger(state, image->textureType == GraphicsBackend::TextureType::Array ? image->slices : 1);
	return 1;
}

int LoveRuntime::imageGetMipmapCount(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	lua_pushinteger(state, image->mipmapCount);
	return 1;
}

int LoveRuntime::imageGetPixelWidth(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < image->mipmapCount, 2, "invalid mipmap index");
	lua_pushinteger(state, std::max(1, image->runtime->_graphicsBackend->getImageWidth(image->handle) >> mipmap));
	return 1;
}

int LoveRuntime::imageGetPixelHeight(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < image->mipmapCount, 2, "invalid mipmap index");
	lua_pushinteger(state, std::max(1, image->runtime->_graphicsBackend->getImageHeight(image->handle) >> mipmap));
	return 1;
}

int LoveRuntime::imageGetPixelDimensions(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < image->mipmapCount, 2, "invalid mipmap index");
	lua_pushinteger(state, std::max(1, image->runtime->_graphicsBackend->getImageWidth(image->handle) >> mipmap));
	lua_pushinteger(state, std::max(1, image->runtime->_graphicsBackend->getImageHeight(image->handle) >> mipmap));
	return 2;
}

int LoveRuntime::imageGetDPIScale(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	lua_pushnumber(state, image->dpiScale);
	return 1;
}

int LoveRuntime::imageSetFilter(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	const std::string_view min = luaL_checkstring(state, 2);
	const std::string_view mag = luaL_optstring(state, 3, min.data());
	if (min != "linear" && min != "nearest")
		return luaL_argerror(state, 2, "expected 'linear' or 'nearest'");
	if (mag != "linear" && mag != "nearest")
		return luaL_argerror(state, 3, "expected 'linear' or 'nearest'");
	const float anisotropy = static_cast<float>(luaL_optnumber(state, 4, 1.0));
	luaL_argcheck(state, std::isfinite(anisotropy) && anisotropy >= 1.0f, 4,
		"anisotropy must be a finite number greater than or equal to 1");
	image->filter = min == "nearest" ? GraphicsBackend::TextureFilter::Nearest
		: anisotropy > 1.0f ? GraphicsBackend::TextureFilter::Anisotropic
		: GraphicsBackend::TextureFilter::Linear;
	image->magFilter = mag == "nearest" ? GraphicsBackend::TextureFilter::Nearest
		: GraphicsBackend::TextureFilter::Linear;
	image->anisotropy = anisotropy;
	return 0;
}

int LoveRuntime::imageGetFilter(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	const char *min = image->filter == GraphicsBackend::TextureFilter::Nearest ? "nearest" : "linear";
	const char *mag = image->magFilter == GraphicsBackend::TextureFilter::Nearest ? "nearest" : "linear";
	lua_pushstring(state, min);
	lua_pushstring(state, mag);
	lua_pushnumber(state, image->anisotropy);
	return 3;
}

int LoveRuntime::imageSetMipmapFilter(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	if (lua_isnoneornil(state, 2)) image->mipmapFilter.reset();
	else
	{
		const std::string_view mode = luaL_checkstring(state, 2);
		if (mode != "linear" && mode != "nearest")
			return luaL_argerror(state, 2, "expected 'linear', 'nearest', or nil");
		luaL_argcheck(state, image->mipmapCount > 1, 2,
			"mipmap filtering requires an Image with mipmaps");
		image->mipmapFilter = mode == "nearest" ? GraphicsBackend::TextureFilter::Nearest
			: GraphicsBackend::TextureFilter::Linear;
	}
	const float sharpness = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	luaL_argcheck(state, std::isfinite(sharpness), 3, "mipmap sharpness must be finite");
	image->mipmapSharpness = sharpness;
	return 0;
}

int LoveRuntime::imageGetMipmapFilter(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	if (!image->mipmapFilter) lua_pushnil(state);
	else lua_pushstring(state, *image->mipmapFilter == GraphicsBackend::TextureFilter::Nearest
		? "nearest" : "linear");
	lua_pushnumber(state, image->mipmapSharpness);
	return 2;
}

int LoveRuntime::imageSetWrap(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	auto parseWrap = [state](int index, const char *fallback) {
		const std::string_view mode = luaL_optstring(state, index, fallback);
		if (mode == "repeat") return GraphicsBackend::TextureWrap::Repeat;
		if (mode == "mirroredrepeat") return GraphicsBackend::TextureWrap::MirroredRepeat;
		if (mode == "clamp") return GraphicsBackend::TextureWrap::Clamp;
		if (mode == "clampzero") return GraphicsBackend::TextureWrap::ClampZero;
		luaL_argerror(state, index, "expected 'clamp', 'clampzero', 'repeat', or 'mirroredrepeat'");
		return GraphicsBackend::TextureWrap::Clamp;
	};
	const char *horizontal = luaL_checkstring(state, 2);
	image->wrapU = parseWrap(2, horizontal);
	image->wrapV = parseWrap(3, horizontal);
	image->wrapW = parseWrap(4, horizontal);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::imageGetWrap(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0 && image->runtime->_graphicsBackend, 1, "closed Image");
	auto pushWrap = [state](GraphicsBackend::TextureWrap wrap) {
		const char *mode = "clamp";
		switch (wrap)
		{
			case GraphicsBackend::TextureWrap::Repeat: mode = "repeat"; break;
			case GraphicsBackend::TextureWrap::MirroredRepeat: mode = "mirroredrepeat"; break;
			case GraphicsBackend::TextureWrap::ClampZero: mode = "clampzero"; break;
			case GraphicsBackend::TextureWrap::Clamp: break;
		}
		lua_pushstring(state, mode);
	};
	pushWrap(image->wrapU);
	pushWrap(image->wrapV);
	pushWrap(image->wrapW);
	return 3;
}

int LoveRuntime::imageGetFormat(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	lua_pushlstring(state, image->format.data(), image->format.size());
	return 1;
}

int LoveRuntime::imageIsReadable(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	lua_pushboolean(state, image->readable);
	return 1;
}

int LoveRuntime::imageSetDepthSampleMode(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	if (lua_isnoneornil(state, 2)) image->depthSampleMode.reset();
	else return luaL_error(state, "depth sample mode is only available for depth textures");
	return 0;
}

int LoveRuntime::imageGetDepthSampleMode(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	if (image->depthSampleMode) lua_pushlstring(state, image->depthSampleMode->data(), image->depthSampleMode->size());
	else lua_pushnil(state);
	return 1;
}

int LoveRuntime::imageIsFormatLinear(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	lua_pushboolean(state, image->linear);
	return 1;
}

int LoveRuntime::graphicsImageIsCompressed(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0, 1, "closed Image");
	lua_pushboolean(state, image->compressed);
	return 1;
}

int LoveRuntime::imageReplacePixels(lua_State *state)
{
	auto *image = checkImage(state, 1);
	luaL_argcheck(state, image->runtime && image->handle != 0
		&& image->runtime->_graphicsBackend, 1, "closed Image");
	auto *data = checkImageData(state, 2);
	luaL_argcheck(state, data->runtime == image->runtime, 2,
		"ImageData belongs to another LoveRuntime");
	luaL_argcheck(state, !image->compressed, 1,
		"replacePixels is unavailable for compressed Images");

	int slice = 0;
	if (image->textureType != GraphicsBackend::TextureType::Texture2D)
	{
		slice = static_cast<int>(luaL_checkinteger(state, 3)) - 1;
		luaL_argcheck(state, slice >= 0 && slice < image->slices, 3,
			"Image slice is outside the available range");
	}
	const int mipmap = static_cast<int>(luaL_optinteger(state, 4, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < image->mipmapCount, 4,
		"invalid mipmap index");
	int x = 0;
	int y = 0;
	if (!lua_isnoneornil(state, 5))
	{
		x = static_cast<int>(luaL_checkinteger(state, 5));
		y = static_cast<int>(luaL_checkinteger(state, 6));
	}
	const int mipWidth = std::max(1,
		image->runtime->_graphicsBackend->getImageWidth(image->handle) >> mipmap);
	const int mipHeight = std::max(1,
		image->runtime->_graphicsBackend->getImageHeight(image->handle) >> mipmap);
	luaL_argcheck(state, x >= 0 && y >= 0 && data->width > 0 && data->height > 0
		&& x <= mipWidth - data->width && y <= mipHeight - data->height, 5,
		"ImageData replacement region is outside the target mipmap");
	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*data, rgba8);
	std::string error;
	if (!image->runtime->_graphicsBackend->replaceImagePixels(image->handle, slice, mipmap,
		x, y, data->width, data->height, rgba8, error))
		return luaL_error(state, "Love Image replacePixels failed: %s",
			error.empty() ? "Dora graphics backend rejected the pixel update" : error.c_str());
	return 0;
}

int LoveRuntime::canvasEqual(lua_State *state)
{
	auto *left = testCanvas(state, 1);
	auto *right = testCanvas(state, 2);
	lua_pushboolean(state, left && right && left->runtime == right->runtime && left->handle == right->handle);
	return 1;
}

int LoveRuntime::canvasGetWidth(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_graphicsBackend
		&& canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < canvas->mipmapCount, 2, "invalid mipmap index");
	lua_pushnumber(state, std::max(1, canvas->runtime->_graphicsBackend->getCanvasWidth(canvas->handle) >> mipmap) / canvas->dpiScale);
	return 1;
}

int LoveRuntime::canvasGetHeight(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_graphicsBackend
		&& canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < canvas->mipmapCount, 2, "invalid mipmap index");
	lua_pushnumber(state, std::max(1, canvas->runtime->_graphicsBackend->getCanvasHeight(canvas->handle) >> mipmap) / canvas->dpiScale);
	return 1;
}

int LoveRuntime::canvasGetDimensions(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_graphicsBackend
		&& canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < canvas->mipmapCount, 2, "invalid mipmap index");
	lua_pushnumber(state, std::max(1, canvas->runtime->_graphicsBackend->getCanvasWidth(canvas->handle) >> mipmap) / canvas->dpiScale);
	lua_pushnumber(state, std::max(1, canvas->runtime->_graphicsBackend->getCanvasHeight(canvas->handle) >> mipmap) / canvas->dpiScale);
	return 2;
}

int LoveRuntime::canvasGetTextureType(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const char *name = "2d";
	if (canvas->textureType == GraphicsBackend::TextureType::Array) name = "array";
	else if (canvas->textureType == GraphicsBackend::TextureType::Cube) name = "cube";
	else if (canvas->textureType == GraphicsBackend::TextureType::Volume) name = "volume";
	lua_pushstring(state, name);
	return 1;
}

int LoveRuntime::canvasGetDepth(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < canvas->mipmapCount, 2, "invalid mipmap index");
	lua_pushinteger(state, canvas->textureType == GraphicsBackend::TextureType::Volume
		? std::max(1, canvas->slices >> mipmap) : 1);
	return 1;
}

int LoveRuntime::canvasGetLayerCount(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	lua_pushinteger(state, canvas->textureType == GraphicsBackend::TextureType::Array ? canvas->slices : 1);
	return 1;
}

int LoveRuntime::canvasGetMipmapCount(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	lua_pushinteger(state, canvas->mipmapCount);
	return 1;
}

int LoveRuntime::canvasGetPixelWidth(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_graphicsBackend
		&& canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < canvas->mipmapCount, 2, "invalid mipmap index");
	lua_pushinteger(state, std::max(1, canvas->runtime->_graphicsBackend->getCanvasWidth(canvas->handle) >> mipmap));
	return 1;
}
int LoveRuntime::canvasGetPixelHeight(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_graphicsBackend
		&& canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < canvas->mipmapCount, 2, "invalid mipmap index");
	lua_pushinteger(state, std::max(1, canvas->runtime->_graphicsBackend->getCanvasHeight(canvas->handle) >> mipmap));
	return 1;
}
int LoveRuntime::canvasGetPixelDimensions(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_graphicsBackend
		&& canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const int mipmap = static_cast<int>(luaL_optinteger(state, 2, 1)) - 1;
	luaL_argcheck(state, mipmap >= 0 && mipmap < canvas->mipmapCount, 2, "invalid mipmap index");
	lua_pushinteger(state, std::max(1, canvas->runtime->_graphicsBackend->getCanvasWidth(canvas->handle) >> mipmap));
	lua_pushinteger(state, std::max(1, canvas->runtime->_graphicsBackend->getCanvasHeight(canvas->handle) >> mipmap));
	return 2;
}

int LoveRuntime::canvasGetDPIScale(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	lua_pushnumber(state, canvas->dpiScale);
	return 1;
}

int LoveRuntime::canvasGetFormat(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	lua_pushstring(state, canvas->format);
	return 1;
}

int LoveRuntime::canvasGetMSAA(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	lua_pushinteger(state, canvas->msaa);
	return 1;
}

int LoveRuntime::canvasIsReadable(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	lua_pushboolean(state, canvas->readable);
	return 1;
}

int LoveRuntime::canvasNewImageData(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	auto *runtime = canvas->runtime;
	luaL_argcheck(state, runtime && runtime->_graphicsBackend
		&& runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	luaL_argcheck(state, canvas->readable, 1,
		"Canvas:newImageData cannot be called on a non-readable Canvas");
	luaL_argcheck(state, !isDepthStencilCanvasFormat(canvas->format), 1,
		"Canvas:newImageData cannot represent a depth/stencil Canvas as ImageData");
	luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(), runtime->_graphicsCanvases.end(),
		canvas->handle) == runtime->_graphicsCanvases.end()
		&& canvas->handle != runtime->_graphicsCanvasDepthStencil, 1,
		"Canvas:newImageData cannot be called while that Canvas is currently active");
	if (runtime->_graphicsFrameActive && !runtime->_graphicsLoadCallbackActive)
		return luaL_error(state,
			"embedded Dora Canvas:newImageData is currently available only outside love.draw");

	// Love keeps the generic Canvas argument positions for every texture type:
	// slice is argument 2 (ignored/defaulted for 2D), mipmap is argument 3.
	const lua_Integer slice = canvas->textureType == GraphicsBackend::TextureType::Texture2D
		? luaL_optinteger(state, 2, 1) : luaL_checkinteger(state, 2);
	const lua_Integer mipmap = luaL_optinteger(state, 3, 1);
	luaL_argcheck(state, mipmap >= 1 && mipmap <= canvas->mipmapCount, 3,
		"invalid Canvas mipmap level");
	const int mipIndex = static_cast<int>(mipmap - 1);
	const int sliceCount = canvas->textureType == GraphicsBackend::TextureType::Volume
		? std::max(1, canvas->slices >> mipIndex) : canvas->slices;
	luaL_argcheck(state, slice >= 1 && slice <= sliceCount, 2,
		"invalid Canvas layer, face, or volume slice");
	const int canvasWidth = std::max(1,
		runtime->_graphicsBackend->getCanvasWidth(canvas->handle) >> mipIndex);
	const int canvasHeight = std::max(1,
		runtime->_graphicsBackend->getCanvasHeight(canvas->handle) >> mipIndex);
	int x = 0;
	int y = 0;
	int width = canvasWidth;
	int height = canvasHeight;
	if (!lua_isnoneornil(state, 4))
	{
		x = static_cast<int>(luaL_checkinteger(state, 4));
		y = static_cast<int>(luaL_checkinteger(state, 5));
		width = static_cast<int>(luaL_checkinteger(state, 6));
		height = static_cast<int>(luaL_checkinteger(state, 7));
	}
	luaL_argcheck(state, x >= 0 && y >= 0 && width > 0 && height > 0
		&& x <= canvasWidth - width && y <= canvasHeight - height, 4,
		"invalid Canvas readback rectangle");
	std::vector<std::uint8_t> pixels;
	std::string error;
	const bool resumeLoadFrame = runtime->_graphicsFrameActive
		&& runtime->_graphicsLoadCallbackActive;
	if (resumeLoadFrame)
	{
		runtime->_graphicsBackend->endFrame();
		runtime->_graphicsFrameActive = false;
	}
	const bool read = runtime->_graphicsBackend->readCanvas(canvas->handle,
		static_cast<int>(slice - 1), mipIndex, x, y, width, height, pixels, error);
	if (resumeLoadFrame)
	{
		runtime->_graphicsBackend->beginFrame();
		runtime->_graphicsFrameActive = true;
	}
	if (!read)
		return luaL_error(state, "Love Canvas readback failed: %s",
			error.empty() ? "Dora graphics backend rejected the readback" : error.c_str());
	const char *format = std::string_view(canvas->format) == "srgba8" ? "rgba8" : canvas->format;
	const auto *formatInfo = imagePixelFormatInfo(format);
	if (!formatInfo)
		return luaL_error(state, "Love Canvas format '%s' cannot be represented as ImageData", format);
	if (pixels.size() != static_cast<std::size_t>(width) * static_cast<std::size_t>(height)
		* formatInfo->bytes)
		return luaL_error(state, "Love Canvas readback returned an invalid '%s' byte count", format);
	pushImageData(state, runtime, width, height, formatInfo->name, std::move(pixels));
	return 1;
}

int LoveRuntime::canvasSetFilter(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_graphicsBackend
		&& canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const std::string_view min = luaL_checkstring(state, 2);
	const std::string_view mag = luaL_optstring(state, 3, min.data());
	if (min != "linear" && min != "nearest")
		return luaL_argerror(state, 2, "expected 'linear' or 'nearest'");
	if (mag != "linear" && mag != "nearest")
		return luaL_argerror(state, 3, "expected 'linear' or 'nearest'");
	if (min != mag)
		return luaL_error(state, "embedded Dora Canvases require matching minification and magnification filters");
	const float anisotropy = static_cast<float>(luaL_optnumber(state, 4, 1.0));
	luaL_argcheck(state, std::isfinite(anisotropy) && anisotropy >= 1.0f, 4,
		"anisotropy must be a finite number greater than or equal to 1");
	canvas->filter = min == "nearest" ? GraphicsBackend::TextureFilter::Nearest
		: anisotropy > 1.0f ? GraphicsBackend::TextureFilter::Anisotropic
		: GraphicsBackend::TextureFilter::Linear;
	canvas->anisotropy = anisotropy;
	return 0;
}

int LoveRuntime::canvasGetFilter(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	const char *mode = canvas->filter == GraphicsBackend::TextureFilter::Nearest ? "nearest" : "linear";
	lua_pushstring(state, mode);
	lua_pushstring(state, mode);
	lua_pushnumber(state, canvas->anisotropy);
	return 3;
}

int LoveRuntime::canvasSetMipmapFilter(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	if (lua_isnoneornil(state, 2)) canvas->mipmapFilter.reset();
	else
	{
		const std::string_view mode = luaL_checkstring(state, 2);
		if (mode != "linear" && mode != "nearest") return luaL_argerror(state, 2, "expected 'linear', 'nearest', or nil");
		luaL_argcheck(state, canvas->mipmapCount > 1, 2, "mipmap filtering requires a Canvas with mipmaps");
		canvas->mipmapFilter = mode == "nearest" ? GraphicsBackend::TextureFilter::Nearest
			: GraphicsBackend::TextureFilter::Linear;
	}
	const float sharpness = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	luaL_argcheck(state, std::isfinite(sharpness), 3, "mipmap sharpness must be finite");
	canvas->mipmapSharpness = sharpness;
	return 0;
}

int LoveRuntime::canvasGetMipmapFilter(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	if (!canvas->mipmapFilter) lua_pushnil(state);
	else lua_pushstring(state, *canvas->mipmapFilter == GraphicsBackend::TextureFilter::Nearest ? "nearest" : "linear");
	lua_pushnumber(state, canvas->mipmapSharpness);
	return 2;
}

int LoveRuntime::canvasSetWrap(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_graphicsBackend
		&& canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	auto parseWrap = [state](int index, const char *fallback) {
		const std::string_view mode = luaL_optstring(state, index, fallback);
		if (mode == "repeat") return GraphicsBackend::TextureWrap::Repeat;
		if (mode == "mirroredrepeat") return GraphicsBackend::TextureWrap::MirroredRepeat;
		if (mode == "clamp") return GraphicsBackend::TextureWrap::Clamp;
		if (mode == "clampzero") return GraphicsBackend::TextureWrap::ClampZero;
		luaL_argerror(state, index, "expected 'clamp', 'clampzero', 'repeat', or 'mirroredrepeat'");
		return GraphicsBackend::TextureWrap::Clamp;
	};
	const char *horizontal = luaL_checkstring(state, 2);
	canvas->wrapU = parseWrap(2, horizontal);
	canvas->wrapV = parseWrap(3, horizontal);
	canvas->wrapW = parseWrap(4, horizontal);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::canvasGetWrap(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	auto pushWrap = [state](GraphicsBackend::TextureWrap wrap) {
		const char *mode = "clamp";
		switch (wrap)
		{
			case GraphicsBackend::TextureWrap::Repeat: mode = "repeat"; break;
			case GraphicsBackend::TextureWrap::MirroredRepeat: mode = "mirroredrepeat"; break;
			case GraphicsBackend::TextureWrap::ClampZero: mode = "clampzero"; break;
			case GraphicsBackend::TextureWrap::Clamp: break;
		}
		lua_pushstring(state, mode);
	};
	pushWrap(canvas->wrapU);
	pushWrap(canvas->wrapV);
	pushWrap(canvas->wrapW);
	return 3;
}

int LoveRuntime::canvasSetDepthSampleMode(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	if (lua_isnoneornil(state, 2)) canvas->depthSampleMode.reset();
	else
	{
		luaL_argcheck(state, canvasFormatHasDepth(canvas->format), 1,
			"depth sample mode is only available for depth Canvas textures");
		const std::string_view mode = luaL_checkstring(state, 2);
		static constexpr std::string_view modes[] = {"equal", "notequal", "less", "lequal", "greater", "gequal", "never", "always"};
		luaL_argcheck(state, std::find(std::begin(modes), std::end(modes), mode) != std::end(modes), 2, "invalid compare mode");
		canvas->depthSampleMode = mode;
	}
	return 0;
}

int LoveRuntime::canvasGetDepthSampleMode(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	if (canvas->depthSampleMode) lua_pushlstring(state, canvas->depthSampleMode->data(), canvas->depthSampleMode->size());
	else lua_pushnil(state);
	return 1;
}

int LoveRuntime::canvasGenerateMipmaps(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	auto *runtime = canvas->runtime;
	luaL_argcheck(state, runtime && runtime->_graphicsBackend
		&& runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	luaL_argcheck(state, canvas->mipmapMode != "none" && canvas->mipmapCount > 1, 1,
		"generateMipmaps can only be called on a Canvas created with mipmaps enabled");
	luaL_argcheck(state, !isDepthStencilCanvasFormat(canvas->format), 1,
		"generateMipmaps cannot be called on a depth/stencil Canvas");
	std::string error;
	if (!runtime->_graphicsBackend->generateCanvasMipmaps(canvas->handle, error))
		return luaL_error(state, "Love Canvas mipmap generation failed: %s",
			error.empty() ? "Dora graphics backend rejected mipmap generation" : error.c_str());
	return 0;
}

int LoveRuntime::canvasGetMipmapMode(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	luaL_argcheck(state, canvas->runtime && canvas->runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	lua_pushlstring(state, canvas->mipmapMode.data(), canvas->mipmapMode.size());
	return 1;
}

int LoveRuntime::canvasRenderTo(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	auto *runtime = canvas->runtime;
	luaL_argcheck(state, runtime && runtime->_graphicsBackend
		&& runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	luaL_checktype(state, 2, LUA_TFUNCTION);
	luaL_argcheck(state, canvas->textureType == GraphicsBackend::TextureType::Texture2D, 1,
		"layered Canvas renderTo is not available until layered Canvas support is enabled");

	auto savedCanvases = std::move(runtime->_graphicsCanvases);
	auto savedTargets = std::move(runtime->_graphicsCanvasTargets);
	auto savedReferences = std::move(runtime->_graphicsCanvasReferences);
	auto savedObjects = std::move(runtime->_graphicsCanvasObjects);
	const auto savedDepthStencil = runtime->_graphicsCanvasDepthStencil;
	const auto savedDepthTarget = runtime->_graphicsCanvasDepthStencilTarget;
	const int savedDepthReference = runtime->_graphicsCanvasDepthStencilReference;
	auto savedDepthObject = std::move(runtime->_graphicsCanvasDepthStencilObject);
	const bool savedDepth = runtime->_graphicsCanvasDepth;
	const bool savedStencil = runtime->_graphicsCanvasStencil;

	std::string error;
	const GraphicsBackend::CanvasTarget renderTarget{canvas->handle, 0, 0};
	if (!runtime->_graphicsBackend->setCanvasTargets({&renderTarget, 1}, nullptr,
		false, false, error))
	{
		runtime->_graphicsCanvases = std::move(savedCanvases);
		runtime->_graphicsCanvasTargets = std::move(savedTargets);
		runtime->_graphicsCanvasReferences = std::move(savedReferences);
		runtime->_graphicsCanvasObjects = std::move(savedObjects);
		runtime->_graphicsCanvasDepthStencilObject = std::move(savedDepthObject);
		return luaL_error(state, "%s", error.c_str());
	}
	runtime->_graphicsCanvases = {canvas->handle};
	runtime->_graphicsCanvasTargets = {renderTarget};
	runtime->_graphicsCanvasObjects = {::love::StrongRef<::love::Object>(canvas)};
	lua_pushvalue(state, 1);
	runtime->_graphicsCanvasReferences = {luaL_ref(state, LUA_REGISTRYINDEX)};
	runtime->_graphicsCanvasDepthStencil = 0;
	runtime->_graphicsCanvasDepthStencilTarget = {};
	runtime->_graphicsCanvasDepthStencilObject.set(nullptr);
	runtime->_graphicsCanvasDepthStencilReference = LUA_NOREF;
	runtime->_graphicsCanvasDepth = false;
	runtime->_graphicsCanvasStencil = false;

	const int argumentCount = lua_gettop(state) - 2;
	lua_pushvalue(state, 2);
	for (int index = 0; index < argumentCount; ++index)
		lua_pushvalue(state, 3 + index);
	const int status = lua_pcall(state, argumentCount, 0, 0);
	std::string callbackError;
	if (status != LUA_OK)
	{
		const char *message = lua_tostring(state, -1);
		callbackError = message ? message : "Canvas:renderTo callback failed";
		lua_pop(state, 1);
	}

	for (const int reference : runtime->_graphicsCanvasReferences)
		luaL_unref(state, LUA_REGISTRYINDEX, reference);
	if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX, runtime->_graphicsCanvasDepthStencilReference);
	if (!runtime->_graphicsBackend->setCanvasTargets(savedTargets,
		savedDepthStencil != 0 ? &savedDepthTarget : nullptr,
		savedDepth, savedStencil, error) && callbackError.empty())
		callbackError = error.empty() ? "failed to restore Canvas after renderTo" : error;
	runtime->_graphicsCanvases = std::move(savedCanvases);
	runtime->_graphicsCanvasTargets = std::move(savedTargets);
	runtime->_graphicsCanvasReferences = std::move(savedReferences);
	runtime->_graphicsCanvasObjects = std::move(savedObjects);
	runtime->_graphicsCanvasDepthStencil = savedDepthStencil;
	runtime->_graphicsCanvasDepthStencilTarget = savedDepthTarget;
	runtime->_graphicsCanvasDepthStencilReference = savedDepthReference;
	runtime->_graphicsCanvasDepthStencilObject = std::move(savedDepthObject);
	runtime->_graphicsCanvasDepth = savedDepth;
	runtime->_graphicsCanvasStencil = savedStencil;
	if (!callbackError.empty()) return luaL_error(state, "%s", callbackError.c_str());
	return 0;
}

int LoveRuntime::imageDataClone(lua_State *state)
{
	auto *data = checkImageData(state, 1);
	pushImageData(state, data->runtime, data->width, data->height, data->format, data->pixels);
	return 1;
}

int LoveRuntime::imageDataGetWidth(lua_State *state)
{
	lua_pushinteger(state, checkImageData(state, 1)->width);
	return 1;
}

int LoveRuntime::imageDataGetHeight(lua_State *state)
{
	lua_pushinteger(state, checkImageData(state, 1)->height);
	return 1;
}

int LoveRuntime::imageDataGetDimensions(lua_State *state)
{
	auto *data = checkImageData(state, 1);
	lua_pushinteger(state, data->width);
	lua_pushinteger(state, data->height);
	return 2;
}

int LoveRuntime::imageDataGetFormat(lua_State *state)
{
	lua_pushstring(state, checkImageData(state, 1)->format);
	return 1;
}

int LoveRuntime::imageDataGetPixel(lua_State *state)
{
	auto *data = checkImageData(state, 1);
	const lua_Integer x = luaL_checkinteger(state, 2);
	const lua_Integer y = luaL_checkinteger(state, 3);
	luaL_argcheck(state, x >= 0 && x < data->width, 2, "pixel x coordinate is outside ImageData");
	luaL_argcheck(state, y >= 0 && y < data->height, 3, "pixel y coordinate is outside ImageData");
	ImagePixelColor color;
	readImagePixel(getImageDataFormat(*data), getImageDataPixel(*data,
		static_cast<int>(x), static_cast<int>(y)), color);
	lua_pushnumber(state, color.red);
	lua_pushnumber(state, color.green);
	lua_pushnumber(state, color.blue);
	lua_pushnumber(state, color.alpha);
	return 4;
}

int LoveRuntime::imageDataSetPixel(lua_State *state)
{
	auto *data = checkImageData(state, 1);
	const lua_Integer x = luaL_checkinteger(state, 2);
	const lua_Integer y = luaL_checkinteger(state, 3);
	luaL_argcheck(state, x >= 0 && x < data->width, 2, "pixel x coordinate is outside ImageData");
	luaL_argcheck(state, y >= 0 && y < data->height, 3, "pixel y coordinate is outside ImageData");
	ImagePixelColor color;
	for (int component = 0; component < 4; ++component)
	{
		const double value = component == 3
			? luaL_optnumber(state, 4 + component, 1.0)
			: luaL_checknumber(state, 4 + component);
		luaL_argcheck(state, std::isfinite(value), 4 + component, "pixel component must be finite");
		switch (component)
		{
			case 0: color.red = static_cast<float>(value); break;
			case 1: color.green = static_cast<float>(value); break;
			case 2: color.blue = static_cast<float>(value); break;
			case 3: color.alpha = static_cast<float>(value); break;
		}
	}
	writeImagePixel(getImageDataFormat(*data), getImageDataPixel(*data,
		static_cast<int>(x), static_cast<int>(y)), color);
	return 0;
}

int LoveRuntime::imageDataMapPixel(lua_State *state)
{
	auto *data = checkImageData(state, 1);
	luaL_checktype(state, 2, LUA_TFUNCTION);
	const lua_Integer startX = luaL_optinteger(state, 3, 0);
	const lua_Integer startY = luaL_optinteger(state, 4, 0);
	const lua_Integer width = luaL_optinteger(state, 5, data->width);
	const lua_Integer height = luaL_optinteger(state, 6, data->height);
	if (startX < 0 || startY < 0 || width <= 0 || height <= 0
		|| startX > data->width || startY > data->height
		|| width > data->width - startX || height > data->height - startY)
		return luaL_error(state, "Invalid rectangle dimensions.");

	for (lua_Integer y = startY; y < startY + height; ++y)
	{
		for (lua_Integer x = startX; x < startX + width; ++x)
		{
			ImagePixelColor color;
			readImagePixel(getImageDataFormat(*data), getImageDataPixel(*data,
				static_cast<int>(x), static_cast<int>(y)), color);
			lua_pushvalue(state, 2);
			lua_pushinteger(state, x);
			lua_pushinteger(state, y);
			lua_pushnumber(state, color.red);
			lua_pushnumber(state, color.green);
			lua_pushnumber(state, color.blue);
			lua_pushnumber(state, color.alpha);
			lua_call(state, 6, 4);
			for (int component = 0; component < 4; ++component)
			{
				const double value = luaL_checknumber(state, -4 + component);
				if (!std::isfinite(value))
					return luaL_error(state, "ImageData mapPixel callback component must be finite");
				switch (component)
				{
					case 0: color.red = static_cast<float>(value); break;
					case 1: color.green = static_cast<float>(value); break;
					case 2: color.blue = static_cast<float>(value); break;
					case 3: color.alpha = static_cast<float>(value); break;
				}
			}
			writeImagePixel(getImageDataFormat(*data), getImageDataPixel(*data,
				static_cast<int>(x), static_cast<int>(y)), color);
			lua_pop(state, 4);
		}
	}
	return 0;
}

int LoveRuntime::imageDataPaste(lua_State *state)
{
	auto *destination = checkImageData(state, 1);
	auto *source = checkImageData(state, 2);
	auto validateInt = [state](int index, lua_Integer value) -> std::int64_t {
		luaL_argcheck(state, value >= std::numeric_limits<int>::min()
			&& value <= std::numeric_limits<int>::max(), index,
			"ImageData paste coordinate or dimension exceeds the supported integer range");
		return static_cast<std::int64_t>(value);
	};
	const std::int64_t destinationX = validateInt(3, luaL_checkinteger(state, 3));
	const std::int64_t destinationY = validateInt(4, luaL_checkinteger(state, 4));
	const std::int64_t sourceX = validateInt(5, luaL_optinteger(state, 5, 0));
	const std::int64_t sourceY = validateInt(6, luaL_optinteger(state, 6, 0));
	const std::int64_t requestedWidth = validateInt(7, luaL_optinteger(state, 7, source->width));
	const std::int64_t requestedHeight = validateInt(8, luaL_optinteger(state, 8, source->height));
	if (requestedWidth <= 0 || requestedHeight <= 0)
		return 0;

	const std::int64_t firstColumn = std::max({std::int64_t{0}, -sourceX, -destinationX});
	const std::int64_t lastColumn = std::min({requestedWidth,
		static_cast<std::int64_t>(source->width) - sourceX,
		static_cast<std::int64_t>(destination->width) - destinationX});
	const std::int64_t firstRow = std::max({std::int64_t{0}, -sourceY, -destinationY});
	const std::int64_t lastRow = std::min({requestedHeight,
		static_cast<std::int64_t>(source->height) - sourceY,
		static_cast<std::int64_t>(destination->height) - destinationY});
	if (firstColumn >= lastColumn || firstRow >= lastRow)
		return 0;

	const auto &sourceFormat = getImageDataFormat(*source);
	const auto &destinationFormat = getImageDataFormat(*destination);
	auto rgbaFamily = [](ImagePixelFormat format) {
		return format == ImagePixelFormat::RGBA8 || format == ImagePixelFormat::RGBA16
			|| format == ImagePixelFormat::RGBA16F || format == ImagePixelFormat::RGBA32F;
	};
	if (sourceFormat.value != destinationFormat.value
		&& (!rgbaFamily(sourceFormat.value) || !rgbaFamily(destinationFormat.value)))
		return luaL_error(state, "ImageData formats '%s' and '%s' are incompatible for paste",
			source->format, destination->format);

	// Snapshot self-pastes so overlapping source and destination rectangles have
	// stable results instead of depending on row copy order.
	const std::vector<std::uint8_t> snapshot = source == destination
		? source->pixels : std::vector<std::uint8_t>{};
	const auto &sourcePixels = source == destination ? snapshot : source->pixels;
	if (sourceFormat.value == destinationFormat.value)
	{
		const std::size_t rowBytes = static_cast<std::size_t>(lastColumn - firstColumn)
			* sourceFormat.bytes;
		for (std::int64_t row = firstRow; row < lastRow; ++row)
		{
			const std::size_t sourceOffset = (static_cast<std::size_t>(sourceY + row)
				* static_cast<std::size_t>(source->width)
				+ static_cast<std::size_t>(sourceX + firstColumn)) * sourceFormat.bytes;
			const std::size_t destinationOffset = (static_cast<std::size_t>(destinationY + row)
				* static_cast<std::size_t>(destination->width)
				+ static_cast<std::size_t>(destinationX + firstColumn)) * destinationFormat.bytes;
			std::copy_n(sourcePixels.data() + sourceOffset, rowBytes,
				destination->pixels.data() + destinationOffset);
		}
	}
	else
	{
		for (std::int64_t row = firstRow; row < lastRow; ++row)
			for (std::int64_t column = firstColumn; column < lastColumn; ++column)
			{
				ImagePixelColor color;
				const auto sourceOffset = (static_cast<std::size_t>(sourceY + row) * source->width
					+ static_cast<std::size_t>(sourceX + column)) * sourceFormat.bytes;
				readImagePixel(sourceFormat, sourcePixels.data() + sourceOffset, color);
				writeImagePixel(destinationFormat, getImageDataPixel(*destination,
					static_cast<int>(destinationX + column), static_cast<int>(destinationY + row)), color);
			}
	}
	return 0;
}

int LoveRuntime::imageDataEncode(lua_State *state)
{
	auto *data = checkImageData(state, 1);
	auto *runtime = data->runtime;
	const std::string format = luaL_checkstring(state, 2);
	if (format != "png" && format != "tga")
		return luaL_argerror(state, 2,
			"invalid encoded image format (expected 'png' or 'tga')");
	if (!runtime || !runtime->_imageBackend)
		return luaL_error(state, "love.image is not attached to a Dora image encoder");
	std::string filename = "Image." + format;
	std::optional<std::filesystem::path> saveTarget;
	std::string error;
	if (!lua_isnoneornil(state, 3))
	{
		filename = luaL_checkstring(state, 3);
		std::filesystem::path target;
		if (!resolveWritableEntry(runtime, filename, target, false, error))
			return luaL_error(state, "Love ImageData '%s' save failed: %s", filename.c_str(), error.c_str());
		saveTarget = std::move(target);
	}

	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*data, rgba8);
	std::vector<std::uint8_t> encoded;
	if (!runtime->_imageBackend->encodeImage(format, data->width, data->height,
		rgba8, encoded, error))
		return luaL_error(state, "Love ImageData encode failed: %s",
			error.empty() ? "Dora image encoder rejected the data" : error.c_str());
	if (encoded.empty())
		return luaL_error(state, "Love ImageData encode failed: Dora image encoder returned empty data");

	if (saveTarget)
	{
		if (!runtime->_filesystemBackend || !runtime->_filesystemBackend->save(saveTarget->string(),
			std::string_view(reinterpret_cast<const char *>(encoded.data()), encoded.size()), error))
			return luaL_error(state, "Love ImageData '%s' save failed: %s", filename.c_str(),
				error.empty() ? "Dora Content rejected the write" : error.c_str());
	}
	pushFileData(state, filename,
		std::string(reinterpret_cast<const char *>(encoded.data()), encoded.size()));
	return 1;
}

int LoveRuntime::imageDataGetString(lua_State *state)
{
	auto *data = checkImageData(state, 1);
	lua_pushlstring(state, reinterpret_cast<const char *>(data->pixels.data()), data->pixels.size());
	return 1;
}

int LoveRuntime::imageDataGetSize(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(checkImageData(state, 1)->pixels.size()));
	return 1;
}

int LoveRuntime::imageDataGetPointer(lua_State *state)
{
	lua_pushlightuserdata(state, checkImageData(state, 1)->pixels.data());
	return 1;
}

int LoveRuntime::imageDataGetFFIPointer(lua_State *state)
{
	checkImageData(state, 1);
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::imageNewImageData(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (lua_type(state, 1) == LUA_TNUMBER)
	{
		const lua_Integer width = luaL_checkinteger(state, 1);
		const lua_Integer height = luaL_checkinteger(state, 2);
		luaL_argcheck(state, width > 0 && width <= MaximumWindowDimension, 1,
			"ImageData width must be between 1 and 8192");
		luaL_argcheck(state, height > 0 && height <= MaximumWindowDimension, 2,
			"ImageData height must be between 1 and 8192");
		const std::string_view format = luaL_optstring(state, 3, "rgba8");
		const auto *formatInfo = imagePixelFormatInfo(format);
		if (!formatInfo)
			return luaL_argerror(state, 3, "unsupported ImageData pixel format");
		const std::size_t byteCount = static_cast<std::size_t>(width)
			* static_cast<std::size_t>(height) * formatInfo->bytes;
		std::vector<std::uint8_t> pixels(byteCount, 0);
		if (!lua_isnoneornil(state, 4))
		{
			const char *bytes = nullptr;
			std::size_t size = 0;
			if (lua_type(state, 4) == LUA_TSTRING)
				bytes = luaL_checklstring(state, 4, &size);
			else if (auto *fileData = testFileData(state, 4))
			{
				bytes = fileData->data.data();
				size = fileData->data.size();
			}
			else
				return luaL_argerror(state, 4, "expected raw string or FileData");
			luaL_argcheck(state, size == byteCount, 4,
				"raw data size does not match ImageData dimensions and pixel format");
			std::copy_n(reinterpret_cast<const std::uint8_t *>(bytes), byteCount, pixels.begin());
		}
		pushImageData(state, runtime, static_cast<int>(width), static_cast<int>(height),
			formatInfo->name, std::move(pixels));
		return 1;
	}

	std::string encoded;
	std::string description;
	if (lua_type(state, 1) == LUA_TSTRING)
	{
		const std::string filename = lua_tostring(state, 1);
		std::string resolved;
		std::string error;
		if (!runtime || !runtime->resolveReadPath(filename, resolved, error)
			|| !runtime->_filesystemBackend || !runtime->_filesystemBackend->load(resolved, encoded, error))
			return luaL_error(state, "Love ImageData '%s' resolution failed: %s", filename.c_str(),
				error.empty() ? "failed to load through Dora Content" : error.c_str());
		description = filename;
	}
	else if (auto *fileData = testFileData(state, 1))
	{
		encoded = fileData->data;
		description = fileData->filename;
	}
	else
		return luaL_argerror(state, 1, "expected filename, FileData, or width");
	if (!runtime || !runtime->_imageBackend)
		return luaL_error(state, "love.image is not attached to a Dora image decoder");
	int width = 0;
	int height = 0;
	std::vector<std::uint8_t> pixels;
	std::string error;
	if (!runtime->_imageBackend->decodeImage(encoded, width, height, pixels, error))
		return luaL_error(state, "Love ImageData '%s' decode failed: %s", description.c_str(),
			error.empty() ? "Dora image decoder rejected the data" : error.c_str());
	const std::size_t expected = static_cast<std::size_t>(width) * static_cast<std::size_t>(height) * 4;
	if (width <= 0 || height <= 0 || width > MaximumWindowDimension || height > MaximumWindowDimension
		|| pixels.size() != expected)
		return luaL_error(state, "Love ImageData '%s' decode failed: Dora image decoder returned invalid rgba8 dimensions", description.c_str());
	pushImageData(state, runtime, width, height, std::move(pixels));
	return 1;
}

int LoveRuntime::soundDataClone(lua_State *state)
{
	auto *data = checkSoundData(state, 1);
	pushSoundData(state, data->sampleRate, data->bitDepth, data->channels,
		data->sampleCount, data->samples);
	return 1;
}

int LoveRuntime::soundDataGetChannelCount(lua_State *state)
{
	lua_pushinteger(state, checkSoundData(state, 1)->channels);
	return 1;
}

int LoveRuntime::soundDataGetChannels(lua_State *state)
{
	return soundDataGetChannelCount(state);
}

int LoveRuntime::soundDataGetBitDepth(lua_State *state)
{
	lua_pushinteger(state, checkSoundData(state, 1)->bitDepth);
	return 1;
}

int LoveRuntime::soundDataGetSampleRate(lua_State *state)
{
	lua_pushinteger(state, checkSoundData(state, 1)->sampleRate);
	return 1;
}

int LoveRuntime::soundDataGetSampleCount(lua_State *state)
{
	lua_pushinteger(state, checkSoundData(state, 1)->sampleCount);
	return 1;
}

int LoveRuntime::soundDataGetDuration(lua_State *state)
{
	auto *data = checkSoundData(state, 1);
	lua_pushnumber(state, static_cast<double>(data->sampleCount) / static_cast<double>(data->sampleRate));
	return 1;
}

int LoveRuntime::soundDataGetSample(lua_State *state)
{
	auto *data = checkSoundData(state, 1);
	const lua_Integer sample = luaL_checkinteger(state, 2);
	lua_Integer linear = sample;
	if (lua_gettop(state) > 2)
	{
		const lua_Integer channel = luaL_checkinteger(state, 3);
		luaL_argcheck(state, sample >= 0 && sample < data->sampleCount, 2, "sample index is outside SoundData");
		luaL_argcheck(state, channel >= 1 && channel <= data->channels, 3, "channel is outside SoundData");
		linear = sample * data->channels + channel - 1;
	}
	const lua_Integer total = static_cast<lua_Integer>(data->sampleCount) * data->channels;
	luaL_argcheck(state, linear >= 0 && linear < total, 2, "sample index is outside SoundData");
	if (data->bitDepth == 8)
		lua_pushnumber(state, (static_cast<double>(data->samples[static_cast<std::size_t>(linear)]) - 128.0) / 127.0);
	else
	{
		const std::size_t offset = static_cast<std::size_t>(linear) * 2;
		const std::uint16_t bits = static_cast<std::uint16_t>(data->samples[offset])
			| static_cast<std::uint16_t>(data->samples[offset + 1]) << 8;
		lua_pushnumber(state, static_cast<double>(static_cast<std::int16_t>(bits)) / 32767.0);
	}
	return 1;
}

int LoveRuntime::soundDataSetSample(lua_State *state)
{
	auto *data = checkSoundData(state, 1);
	const lua_Integer sample = luaL_checkinteger(state, 2);
	lua_Integer linear = sample;
	int valueIndex = 3;
	if (lua_gettop(state) > 3)
	{
		const lua_Integer channel = luaL_checkinteger(state, 3);
		luaL_argcheck(state, sample >= 0 && sample < data->sampleCount, 2, "sample index is outside SoundData");
		luaL_argcheck(state, channel >= 1 && channel <= data->channels, 3, "channel is outside SoundData");
		linear = sample * data->channels + channel - 1;
		valueIndex = 4;
	}
	const lua_Integer total = static_cast<lua_Integer>(data->sampleCount) * data->channels;
	luaL_argcheck(state, linear >= 0 && linear < total, 2, "sample index is outside SoundData");
	const double value = luaL_checknumber(state, valueIndex);
	luaL_argcheck(state, std::isfinite(value), valueIndex, "sample value must be finite");
	const double clamped = std::clamp(value, -1.0, 1.0);
	if (data->bitDepth == 8)
		data->samples[static_cast<std::size_t>(linear)] = static_cast<std::uint8_t>(
			std::clamp(std::lround(clamped * 127.0 + 128.0), 0l, 255l));
	else
	{
		const auto signedValue = static_cast<std::int16_t>(std::lround(clamped * 32767.0));
		const auto bits = static_cast<std::uint16_t>(signedValue);
		const std::size_t offset = static_cast<std::size_t>(linear) * 2;
		data->samples[offset] = static_cast<std::uint8_t>(bits & 0xff);
		data->samples[offset + 1] = static_cast<std::uint8_t>(bits >> 8);
	}
	return 0;
}

int LoveRuntime::soundDataGetString(lua_State *state)
{
	auto *data = checkSoundData(state, 1);
	lua_pushlstring(state, reinterpret_cast<const char *>(data->samples.data()), data->samples.size());
	return 1;
}

int LoveRuntime::soundDataGetSize(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(checkSoundData(state, 1)->samples.size()));
	return 1;
}

int LoveRuntime::soundDataGetPointer(lua_State *state)
{
	lua_pushlightuserdata(state, checkSoundData(state, 1)->samples.data());
	return 1;
}

int LoveRuntime::soundDataGetFFIPointer(lua_State *state)
{
	checkSoundData(state, 1);
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::decoderClone(lua_State *state)
{
	auto *decoder = checkDecoder(state, 1);
	pushDecoder(state, decoder->sampleRate, decoder->channels, decoder->bufferSize, decoder->samples);
	return 1;
}

int LoveRuntime::decoderGetChannelCount(lua_State *state)
{
	lua_pushinteger(state, checkDecoder(state, 1)->channels);
	return 1;
}

int LoveRuntime::decoderGetChannels(lua_State *state)
{
	return decoderGetChannelCount(state);
}

int LoveRuntime::decoderGetBitDepth(lua_State *state)
{
	lua_pushinteger(state, checkDecoder(state, 1)->bitDepth);
	return 1;
}

int LoveRuntime::decoderGetSampleRate(lua_State *state)
{
	lua_pushinteger(state, checkDecoder(state, 1)->sampleRate);
	return 1;
}

int LoveRuntime::decoderGetDuration(lua_State *state)
{
	auto *decoder = checkDecoder(state, 1);
	lua_pushnumber(state, static_cast<double>(decoder->sampleCount)
		/ static_cast<double>(decoder->sampleRate));
	return 1;
}

int LoveRuntime::decoderDecode(lua_State *state)
{
	auto *decoder = checkDecoder(state, 1);
	if (decoder->bytePosition >= decoder->samples.size())
	{
		lua_pushnil(state);
		return 1;
	}
	const std::size_t frameBytes = static_cast<std::size_t>(decoder->channels) * 2;
	const std::size_t framesPerChunk = std::max<std::size_t>(1, decoder->bufferSize / frameBytes);
	const std::size_t byteCount = std::min(framesPerChunk * frameBytes,
		decoder->samples.size() - decoder->bytePosition);
	std::vector<std::uint8_t> samples(byteCount);
	std::copy_n(decoder->samples.begin() + static_cast<std::ptrdiff_t>(decoder->bytePosition),
		static_cast<std::ptrdiff_t>(byteCount), samples.begin());
	decoder->bytePosition += byteCount;
	pushSoundData(state, decoder->sampleRate, decoder->bitDepth, decoder->channels,
		static_cast<int>(byteCount / frameBytes), std::move(samples));
	return 1;
}

int LoveRuntime::decoderSeek(lua_State *state)
{
	auto *decoder = checkDecoder(state, 1);
	const double offset = luaL_checknumber(state, 2);
	luaL_argcheck(state, std::isfinite(offset) && offset >= 0.0, 2,
		"can't seek to a negative or non-finite position");
	const double frame = offset * static_cast<double>(decoder->sampleRate);
	if (frame <= static_cast<double>(decoder->sampleCount))
	{
		const std::size_t frameIndex = std::min<std::size_t>(decoder->sampleCount,
			static_cast<std::size_t>(frame));
		decoder->bytePosition = frameIndex * static_cast<std::size_t>(decoder->channels) * 2;
	}
	return 0;
}

namespace
{
int pushRandomResult(lua_State *state, RandomGeneratorUserdata &generator, int firstArgument)
{
	const double random = randomUnit(generator);
	if (!lua_isnoneornil(state, firstArgument + 1))
	{
		const double lower = luaL_checknumber(state, firstArgument);
		const double upper = luaL_checknumber(state, firstArgument + 1);
		lua_pushnumber(state, std::floor(random * (upper - lower + 1.0)) + lower);
	}
	else if (!lua_isnoneornil(state, firstArgument))
	{
		const double upper = luaL_checknumber(state, firstArgument);
		lua_pushnumber(state, std::floor(random * upper) + 1.0);
	}
	else lua_pushnumber(state, random);
	return 1;
}

int pushRandomNormalResult(lua_State *state, RandomGeneratorUserdata &generator, int firstArgument)
{
	const double standardDeviation = luaL_optnumber(state, firstArgument, 1.0);
	const double mean = luaL_optnumber(state, firstArgument + 1, 0.0);
	lua_pushnumber(state, randomNormalValue(generator, standardDeviation) + mean);
	return 1;
}

RandomGeneratorUserdata *randomGeneratorFromUpvalue(lua_State *state)
{
	return ::love::luax_checktype<RandomGeneratorUserdata>(state,
		lua_upvalueindex(1), RandomGeneratorLoveType);
}

int pushGammaResults(lua_State *state, bool toLinear)
{
	double colors[4]{};
	int count = 0;
	if (lua_istable(state, 1))
	{
		count = std::min(static_cast<int>(lua_rawlen(state, 1)), 4);
		for (int index = 0; index < count; ++index)
		{
			lua_rawgeti(state, 1, index + 1);
			colors[index] = clampUnit(luaL_checknumber(state, -1));
			lua_pop(state, 1);
		}
	}
	else
	{
		count = std::min(lua_gettop(state), 4);
		for (int index = 0; index < count; ++index)
			colors[index] = clampUnit(luaL_checknumber(state, index + 1));
	}
	if (count == 0) luaL_checknumber(state, 1);
	for (int index = 0; index < count; ++index)
	{
		double value = colors[index];
		if (index < 3)
		{
			if (toLinear)
				value = value <= 0.04045 ? value / 12.92
					: std::pow((value + 0.055) / 1.055, 2.4);
			else
				value = value <= 0.0031308 ? value * 12.92
					: 1.055 * std::pow(value, 1.0 / 2.4) - 0.055;
		}
		lua_pushnumber(state, value);
	}
	return count;
}
}

int LoveRuntime::randomGeneratorRandom(lua_State *state)
{
	return pushRandomResult(state, *checkRandomGenerator(state, 1), 2);
}

int LoveRuntime::randomGeneratorRandomNormal(lua_State *state)
{
	return pushRandomNormalResult(state, *checkRandomGenerator(state, 1), 2);
}

int LoveRuntime::randomGeneratorSetSeed(lua_State *state)
{
	setRandomSeed(*checkRandomGenerator(state, 1), checkRandomSeed(state, 2));
	return 0;
}

int LoveRuntime::randomGeneratorGetSeed(lua_State *state)
{
	const std::uint64_t seed = checkRandomGenerator(state, 1)->seed;
	lua_pushnumber(state, static_cast<std::uint32_t>(seed));
	lua_pushnumber(state, static_cast<std::uint32_t>(seed >> 32));
	return 2;
}

int LoveRuntime::randomGeneratorSetState(lua_State *state)
{
	auto *generator = checkRandomGenerator(state, 1);
	std::size_t length = 0;
	const char *text = luaL_checklstring(state, 2, &length);
	if (length < 3 || text[0] != '0' || text[1] != 'x')
		return luaL_error(state, "Invalid random state: %s", text);
	std::uint64_t value = 0;
	const auto result = std::from_chars(text + 2, text + length, value, 16);
	if (result.ec != std::errc{} || result.ptr != text + length)
		return luaL_error(state, "Invalid random state: %s", text);
	generator->state = value;
	generator->cachedNormal = std::numeric_limits<double>::infinity();
	return 0;
}

int LoveRuntime::randomGeneratorGetState(lua_State *state)
{
	std::ostringstream stream;
	stream << "0x" << std::setfill('0') << std::setw(16) << std::hex
		<< checkRandomGenerator(state, 1)->state;
	lua_pushstring(state, stream.str().c_str());
	return 1;
}

int LoveRuntime::mathGetRandomGenerator(lua_State *state)
{
	lua_pushvalue(state, lua_upvalueindex(1));
	return 1;
}

int LoveRuntime::mathNewRandomGenerator(lua_State *state)
{
	std::uint64_t seed = UINT64_C(0x0139408dcbbf7a44);
	if (!lua_isnoneornil(state, 1)) seed = checkRandomSeed(state, 1);
	pushRandomGenerator(state, seed);
	return 1;
}

int LoveRuntime::mathRandom(lua_State *state)
{
	return pushRandomResult(state, *randomGeneratorFromUpvalue(state), 1);
}

int LoveRuntime::mathRandomNormal(lua_State *state)
{
	return pushRandomNormalResult(state, *randomGeneratorFromUpvalue(state), 1);
}

int LoveRuntime::mathSetRandomSeed(lua_State *state)
{
	setRandomSeed(*randomGeneratorFromUpvalue(state), checkRandomSeed(state, 1));
	return 0;
}

int LoveRuntime::mathGetRandomSeed(lua_State *state)
{
	const std::uint64_t seed = randomGeneratorFromUpvalue(state)->seed;
	lua_pushnumber(state, static_cast<std::uint32_t>(seed));
	lua_pushnumber(state, static_cast<std::uint32_t>(seed >> 32));
	return 2;
}

int LoveRuntime::mathSetRandomState(lua_State *state)
{
	lua_pushvalue(state, lua_upvalueindex(1));
	lua_insert(state, 1);
	return randomGeneratorSetState(state);
}

int LoveRuntime::mathGetRandomState(lua_State *state)
{
	lua_pushvalue(state, lua_upvalueindex(1));
	return randomGeneratorGetState(state);
}

int LoveRuntime::mathColorToBytes(lua_State *state)
{
	double colors[4]{};
	bool hasAlpha = false;
	if (lua_istable(state, 1))
	{
		for (int index = 0; index < 4; ++index)
		{
			lua_rawgeti(state, 1, index + 1);
			if (index == 3 && lua_isnil(state, -1)) { lua_pop(state, 1); break; }
			colors[index] = luaL_checknumber(state, -1);
			lua_pop(state, 1);
			if (index == 3) hasAlpha = true;
		}
	}
	else
	{
		for (int index = 0; index < 3; ++index) colors[index] = luaL_checknumber(state, index + 1);
		if (!lua_isnoneornil(state, 4)) { colors[3] = luaL_checknumber(state, 4); hasAlpha = true; }
	}
	for (int index = 0; index < 3; ++index)
		lua_pushinteger(state, static_cast<lua_Integer>(std::floor(clampUnit(colors[index]) * 255.0 + 0.5)));
	if (hasAlpha) lua_pushinteger(state,
		static_cast<lua_Integer>(std::floor(clampUnit(colors[3]) * 255.0 + 0.5)));
	else lua_pushnil(state);
	return 4;
}

int LoveRuntime::mathColorFromBytes(lua_State *state)
{
	double colors[4]{};
	bool hasAlpha = false;
	if (lua_istable(state, 1))
	{
		for (int index = 0; index < 4; ++index)
		{
			lua_rawgeti(state, 1, index + 1);
			if (index == 3 && lua_isnil(state, -1)) { lua_pop(state, 1); break; }
			colors[index] = luaL_checknumber(state, -1);
			lua_pop(state, 1);
			if (index == 3) hasAlpha = true;
		}
	}
	else
	{
		for (int index = 0; index < 3; ++index) colors[index] = luaL_checknumber(state, index + 1);
		if (!lua_isnoneornil(state, 4)) { colors[3] = luaL_checknumber(state, 4); hasAlpha = true; }
	}
	for (int index = 0; index < 3; ++index)
		lua_pushnumber(state, clampUnit(std::floor(colors[index] + 0.5) / 255.0));
	if (hasAlpha) lua_pushnumber(state, clampUnit(std::floor(colors[3] + 0.5) / 255.0));
	else lua_pushnil(state);
	return 4;
}

int LoveRuntime::mathGammaToLinear(lua_State *state)
{
	return pushGammaResults(state, true);
}

int LoveRuntime::mathLinearToGamma(lua_State *state)
{
	return pushGammaResults(state, false);
}

int LoveRuntime::mathIsConvex(lua_State *state)
{
	lua_pushboolean(state, isMathPolygonConvex(checkMathPolygon(state)));
	return 1;
}

int LoveRuntime::mathTriangulate(lua_State *state)
{
	const auto points = checkMathPolygon(state);
	if (points.size() < 3) return luaL_error(state, "Need at least 3 vertices to triangulate");
	std::vector<MathTriangle> triangles;
	if (!triangulateMathPolygon(points, triangles))
		return luaL_error(state, "Cannot triangulate polygon.");
	lua_createtable(state, static_cast<int>(triangles.size()), 0);
	for (std::size_t index = 0; index < triangles.size(); ++index)
	{
		const double values[] = {triangles[index].a.x, triangles[index].a.y,
			triangles[index].b.x, triangles[index].b.y,
			triangles[index].c.x, triangles[index].c.y};
		lua_createtable(state, 6, 0);
		for (int component = 0; component < 6; ++component)
		{
			lua_pushnumber(state, values[component]);
			lua_rawseti(state, -2, component + 1);
		}
		lua_rawseti(state, -2, static_cast<lua_Integer>(index + 1));
	}
	return 1;
}

int LoveRuntime::mathNoise(lua_State *state)
{
	const int count = std::min(std::max(lua_gettop(state), 1), 4);
	float values[4]{};
	for (int index = 0; index < count; ++index)
	{
		const double value = luaL_checknumber(state, index + 1);
		luaL_argcheck(state, std::isfinite(value), index + 1, "noise coordinate must be finite");
		values[index] = static_cast<float>(value);
	}
	float result = 0.0f;
	switch (count)
	{
		case 1: result = SimplexNoise1234::noise(values[0]); break;
		case 2: result = SimplexNoise1234::noise(values[0], values[1]); break;
		case 3: result = Noise1234::noise(values[0], values[1], values[2]); break;
		case 4: result = Noise1234::noise(values[0], values[1], values[2], values[3]); break;
	}
	lua_pushnumber(state, result * 0.5f + 0.5f);
	return 1;
}

int LoveRuntime::mathNewTransform(lua_State *state)
{
	TransformUserdata transform;
	if (lua_isnoneornil(state, 1)) setTransformIdentity(transform);
	else
	{
		const float x = static_cast<float>(luaL_checknumber(state, 1));
		const float y = static_cast<float>(luaL_checknumber(state, 2));
		const float angle = static_cast<float>(luaL_optnumber(state, 3, 0.0));
		const float sx = static_cast<float>(luaL_optnumber(state, 4, 1.0));
		const float sy = static_cast<float>(luaL_optnumber(state, 5, sx));
		const float ox = static_cast<float>(luaL_optnumber(state, 6, 0.0));
		const float oy = static_cast<float>(luaL_optnumber(state, 7, 0.0));
		const float kx = static_cast<float>(luaL_optnumber(state, 8, 0.0));
		const float ky = static_cast<float>(luaL_optnumber(state, 9, 0.0));
		setTransform(transform, x, y, angle, sx, sy, ox, oy, kx, ky);
	}
	pushTransform(state, transform);
	return 1;
}

int LoveRuntime::transformClone(lua_State *state)
{
	pushTransform(state, *checkTransform(state, 1));
	return 1;
}

int LoveRuntime::transformInverse(lua_State *state)
{
	TransformUserdata inverse;
	if (!invertTransform(*checkTransform(state, 1), inverse))
		return luaL_error(state, "Cannot invert a singular Transform.");
	pushTransform(state, inverse);
	return 1;
}

int LoveRuntime::transformApply(lua_State *state)
{
	appendTransform(*checkTransform(state, 1), *checkTransform(state, 2));
	lua_pushvalue(state, 1);
	return 1;
}

int LoveRuntime::transformIsAffine2DTransform(lua_State *state)
{
	lua_pushboolean(state, isAffine2DTransform(*checkTransform(state, 1)));
	return 1;
}

int LoveRuntime::transformTranslate(lua_State *state)
{
	TransformUserdata translation;
	setTransformIdentity(translation);
	translation.elements[12] = static_cast<float>(luaL_checknumber(state, 2));
	translation.elements[13] = static_cast<float>(luaL_checknumber(state, 3));
	appendTransform(*checkTransform(state, 1), translation);
	lua_pushvalue(state, 1);
	return 1;
}

int LoveRuntime::transformRotate(lua_State *state)
{
	TransformUserdata rotation;
	setTransformIdentity(rotation);
	const float angle = static_cast<float>(luaL_checknumber(state, 2));
	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	rotation.elements[0] = cosine;
	rotation.elements[1] = sine;
	rotation.elements[4] = -sine;
	rotation.elements[5] = cosine;
	appendTransform(*checkTransform(state, 1), rotation);
	lua_pushvalue(state, 1);
	return 1;
}

int LoveRuntime::transformScale(lua_State *state)
{
	TransformUserdata scale;
	setTransformIdentity(scale);
	scale.elements[0] = static_cast<float>(luaL_checknumber(state, 2));
	scale.elements[5] = static_cast<float>(luaL_optnumber(state, 3, scale.elements[0]));
	appendTransform(*checkTransform(state, 1), scale);
	lua_pushvalue(state, 1);
	return 1;
}

int LoveRuntime::transformShear(lua_State *state)
{
	TransformUserdata shear;
	setTransformIdentity(shear);
	shear.elements[4] = static_cast<float>(luaL_checknumber(state, 2));
	shear.elements[1] = static_cast<float>(luaL_checknumber(state, 3));
	appendTransform(*checkTransform(state, 1), shear);
	lua_pushvalue(state, 1);
	return 1;
}

int LoveRuntime::transformReset(lua_State *state)
{
	setTransformIdentity(*checkTransform(state, 1));
	lua_pushvalue(state, 1);
	return 1;
}

int LoveRuntime::transformSetTransformation(lua_State *state)
{
	auto *transform = checkTransform(state, 1);
	const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	const float angle = static_cast<float>(luaL_optnumber(state, 4, 0.0));
	const float sx = static_cast<float>(luaL_optnumber(state, 5, 1.0));
	const float sy = static_cast<float>(luaL_optnumber(state, 6, sx));
	const float ox = static_cast<float>(luaL_optnumber(state, 7, 0.0));
	const float oy = static_cast<float>(luaL_optnumber(state, 8, 0.0));
	const float kx = static_cast<float>(luaL_optnumber(state, 9, 0.0));
	const float ky = static_cast<float>(luaL_optnumber(state, 10, 0.0));
	setTransform(*transform, x, y, angle, sx, sy, ox, oy, kx, ky);
	lua_pushvalue(state, 1);
	return 1;
}

int LoveRuntime::transformSetMatrix(lua_State *state)
{
	auto *transform = checkTransform(state, 1);
	bool columnMajor = false;
	int argument = 2;
	if (lua_type(state, argument) == LUA_TSTRING)
	{
		const std::string_view layout = lua_tostring(state, argument++);
		if (layout == "column") columnMajor = true;
		else if (layout != "row") return luaL_argerror(state, 2, "invalid matrix layout");
	}
	const int tableIndex = lua_absindex(state, argument);
	const bool table = lua_istable(state, tableIndex);
	bool nested = false;
	if (table)
	{
		lua_rawgeti(state, tableIndex, 1);
		nested = lua_istable(state, -1);
		lua_pop(state, 1);
	}
	for (int row = 0; row < 4; ++row)
		for (int column = 0; column < 4; ++column)
		{
			const int sourceRow = columnMajor ? column : row;
			const int sourceColumn = columnMajor ? row : column;
			double value = 0.0;
			if (nested)
			{
				lua_rawgeti(state, tableIndex, sourceRow + 1);
				lua_rawgeti(state, -1, sourceColumn + 1);
				value = luaL_checknumber(state, -1);
				lua_pop(state, 2);
			}
			else if (table)
			{
				lua_rawgeti(state, tableIndex, sourceRow * 4 + sourceColumn + 1);
				value = luaL_checknumber(state, -1);
				lua_pop(state, 1);
			}
			else value = luaL_checknumber(state, argument + sourceRow * 4 + sourceColumn);
			transform->elements[column * 4 + row] = static_cast<float>(value);
		}
	lua_pushvalue(state, 1);
	return 1;
}

int LoveRuntime::transformGetMatrix(lua_State *state)
{
	const float *elements = checkTransform(state, 1)->elements;
	for (int row = 0; row < 4; ++row)
		for (int column = 0; column < 4; ++column)
			lua_pushnumber(state, elements[column * 4 + row]);
	return 16;
}

int LoveRuntime::transformTransformPoint(lua_State *state)
{
	const float *elements = checkTransform(state, 1)->elements;
	const double x = luaL_checknumber(state, 2);
	const double y = luaL_checknumber(state, 3);
	lua_pushnumber(state, elements[0] * x + elements[4] * y + elements[12]);
	lua_pushnumber(state, elements[1] * x + elements[5] * y + elements[13]);
	return 2;
}

int LoveRuntime::transformInverseTransformPoint(lua_State *state)
{
	TransformUserdata inverse;
	if (!invertTransform(*checkTransform(state, 1), inverse))
		return luaL_error(state, "Cannot invert a singular Transform.");
	const double x = luaL_checknumber(state, 2);
	const double y = luaL_checknumber(state, 3);
	lua_pushnumber(state, inverse.elements[0] * x + inverse.elements[4] * y + inverse.elements[12]);
	lua_pushnumber(state, inverse.elements[1] * x + inverse.elements[5] * y + inverse.elements[13]);
	return 2;
}

int LoveRuntime::transformMultiply(lua_State *state)
{
	TransformUserdata result;
	multiplyTransforms(*checkTransform(state, 1), *checkTransform(state, 2), result);
	pushTransform(state, result);
	return 1;
}

int LoveRuntime::mathNewBezierCurve(lua_State *state)
{
	const bool table = lua_istable(state, 1);
	const int count = table ? static_cast<int>(lua_rawlen(state, 1)) : lua_gettop(state);
	luaL_argcheck(state, count % 2 == 0, 1, "expected an even number of coordinates");
	luaL_argcheck(state, count <= 2'000'000, 1, "too many control point coordinates");
	std::vector<MathPoint> points;
	points.reserve(static_cast<std::size_t>(count / 2));
	for (int index = 0; index < count; index += 2)
	{
		MathPoint point;
		if (table)
		{
			lua_rawgeti(state, 1, index + 1);
			lua_rawgeti(state, 1, index + 2);
			point.x = luaL_checknumber(state, -2);
			point.y = luaL_checknumber(state, -1);
			lua_pop(state, 2);
		}
		else
		{
			point.x = luaL_checknumber(state, index + 1);
			point.y = luaL_checknumber(state, index + 2);
		}
		luaL_argcheck(state, std::isfinite(point.x) && std::isfinite(point.y), 1,
			"control point coordinates must be finite");
		points.push_back(point);
	}
	pushBezierCurve(state, std::move(points));
	return 1;
}

int LoveRuntime::bezierCurveGetDegree(lua_State *state)
{
	const auto count = checkBezierCurve(state, 1)->controlPoints.size();
	lua_pushinteger(state, count == 0 ? -1 : static_cast<lua_Integer>(count - 1));
	return 1;
}

int LoveRuntime::bezierCurveGetDerivative(lua_State *state)
{
	const auto &points = checkBezierCurve(state, 1)->controlPoints;
	if (points.size() < 2) return luaL_error(state, "Cannot derive a curve of degree < 1.");
	std::vector<MathPoint> derivative(points.size() - 1);
	const double degree = static_cast<double>(points.size() - 1);
	for (std::size_t index = 0; index < derivative.size(); ++index)
		derivative[index] = {(points[index + 1].x - points[index].x) * degree,
			(points[index + 1].y - points[index].y) * degree};
	pushBezierCurve(state, std::move(derivative));
	return 1;
}

int LoveRuntime::bezierCurveGetControlPoint(lua_State *state)
{
	auto *curve = checkBezierCurve(state, 1);
	const auto &point = curve->controlPoints[wrapCurveIndex(state, *curve, luaL_checkinteger(state, 2))];
	lua_pushnumber(state, point.x);
	lua_pushnumber(state, point.y);
	return 2;
}

int LoveRuntime::bezierCurveSetControlPoint(lua_State *state)
{
	auto *curve = checkBezierCurve(state, 1);
	auto &point = curve->controlPoints[wrapCurveIndex(state, *curve, luaL_checkinteger(state, 2))];
	point = {luaL_checknumber(state, 3), luaL_checknumber(state, 4)};
	return 0;
}

int LoveRuntime::bezierCurveInsertControlPoint(lua_State *state)
{
	auto *curve = checkBezierCurve(state, 1);
	const MathPoint point{luaL_checknumber(state, 2), luaL_checknumber(state, 3)};
	std::size_t index = 0;
	if (!curve->controlPoints.empty())
		index = wrapCurveIndex(state, *curve, luaL_optinteger(state, 4, -1), true);
	curve->controlPoints.insert(curve->controlPoints.begin() + static_cast<std::ptrdiff_t>(index), point);
	return 0;
}

int LoveRuntime::bezierCurveRemoveControlPoint(lua_State *state)
{
	auto *curve = checkBezierCurve(state, 1);
	const auto index = wrapCurveIndex(state, *curve, luaL_checkinteger(state, 2));
	curve->controlPoints.erase(curve->controlPoints.begin() + static_cast<std::ptrdiff_t>(index));
	return 0;
}

int LoveRuntime::bezierCurveGetControlPointCount(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(
		checkBezierCurve(state, 1)->controlPoints.size()));
	return 1;
}

int LoveRuntime::bezierCurveTranslate(lua_State *state)
{
	auto &points = checkBezierCurve(state, 1)->controlPoints;
	const double x = luaL_checknumber(state, 2);
	const double y = luaL_checknumber(state, 3);
	for (auto &point : points) { point.x += x; point.y += y; }
	return 0;
}

int LoveRuntime::bezierCurveRotate(lua_State *state)
{
	auto &points = checkBezierCurve(state, 1)->controlPoints;
	const double angle = luaL_checknumber(state, 2);
	const double originX = luaL_optnumber(state, 3, 0.0);
	const double originY = luaL_optnumber(state, 4, 0.0);
	const double cosine = std::cos(angle);
	const double sine = std::sin(angle);
	for (auto &point : points)
	{
		const double x = point.x - originX;
		const double y = point.y - originY;
		point = {cosine * x - sine * y + originX, sine * x + cosine * y + originY};
	}
	return 0;
}

int LoveRuntime::bezierCurveScale(lua_State *state)
{
	auto &points = checkBezierCurve(state, 1)->controlPoints;
	const double scale = luaL_checknumber(state, 2);
	const double originX = luaL_optnumber(state, 3, 0.0);
	const double originY = luaL_optnumber(state, 4, 0.0);
	for (auto &point : points)
		point = {(point.x - originX) * scale + originX,
			(point.y - originY) * scale + originY};
	return 0;
}

int LoveRuntime::bezierCurveEvaluate(lua_State *state)
{
	const auto &points = checkBezierCurve(state, 1)->controlPoints;
	const double time = luaL_checknumber(state, 2);
	if (time < 0.0 || time > 1.0) return luaL_error(state,
		"Invalid evaluation parameter: must be between 0 and 1");
	if (points.size() < 2) return luaL_error(state,
		"Invalid Bezier curve: Not enough control points.");
	const auto point = evaluateBezier(points, time);
	lua_pushnumber(state, point.x);
	lua_pushnumber(state, point.y);
	return 2;
}

int LoveRuntime::bezierCurveGetSegment(lua_State *state)
{
	const auto &controlPoints = checkBezierCurve(state, 1)->controlPoints;
	const double start = luaL_checknumber(state, 2);
	const double end = luaL_checknumber(state, 3);
	if (start < 0.0 || end > 1.0) return luaL_error(state,
		"Invalid segment parameters: must be between 0 and 1");
	if (end <= start) return luaL_error(state,
		"Invalid segment parameters: t1 must be smaller than t2");
	std::vector<MathPoint> points = controlPoints;
	std::vector<MathPoint> left;
	std::vector<MathPoint> right;
	left.reserve(points.size());
	right.reserve(points.size());
	for (std::size_t step = 1; step < points.size(); ++step)
	{
		left.push_back(points.front());
		for (std::size_t index = 0; index < points.size() - step; ++index)
		{
			points[index].x += (points[index + 1].x - points[index].x) * end;
			points[index].y += (points[index + 1].y - points[index].y) * end;
		}
	}
	if (!points.empty()) left.push_back(points.front());
	const double relativeStart = start / end;
	for (std::size_t step = 1; step < left.size(); ++step)
	{
		right.push_back(left[left.size() - step]);
		for (std::size_t index = 0; index < left.size() - step; ++index)
		{
			left[index].x += (left[index + 1].x - left[index].x) * relativeStart;
			left[index].y += (left[index + 1].y - left[index].y) * relativeStart;
		}
	}
	if (!left.empty()) right.push_back(left.front());
	std::reverse(right.begin(), right.end());
	pushBezierCurve(state, std::move(right));
	return 1;
}

int LoveRuntime::bezierCurveRender(lua_State *state)
{
	auto points = checkBezierCurve(state, 1)->controlPoints;
	if (points.size() < 2) return luaL_error(state,
		"Invalid Bezier curve: Not enough control points.");
	const int accuracy = static_cast<int>(luaL_optinteger(state, 2, 5));
	luaL_argcheck(state, accuracy <= 20, 2, "accuracy is too large");
	subdivideBezier(points, accuracy);
	pushBezierPoints(state, points);
	return 1;
}

int LoveRuntime::bezierCurveRenderSegment(lua_State *state)
{
	auto points = checkBezierCurve(state, 1)->controlPoints;
	if (points.size() < 2) return luaL_error(state,
		"Invalid Bezier curve: Not enough control points.");
	const double start = luaL_checknumber(state, 2);
	const double end = luaL_checknumber(state, 3);
	luaL_argcheck(state, start >= 0.0 && start <= 1.0, 2, "segment start must be between 0 and 1");
	luaL_argcheck(state, end >= 0.0 && end <= 1.0, 3, "segment end must be between 0 and 1");
	const int accuracy = static_cast<int>(luaL_optinteger(state, 4, 5));
	luaL_argcheck(state, accuracy <= 20, 4, "accuracy is too large");
	subdivideBezier(points, accuracy);
	std::vector<MathPoint> segment;
	if (start != end)
	{
		const double low = std::min(start, end);
		const double high = std::max(start, end);
		const std::size_t first = std::min(points.size(), static_cast<std::size_t>(low * points.size()));
		const std::size_t last = std::min(points.size(), static_cast<std::size_t>(high * points.size() + 0.5));
		segment.assign(points.begin() + static_cast<std::ptrdiff_t>(first),
			points.begin() + static_cast<std::ptrdiff_t>(last));
		if (start > end) std::reverse(segment.begin(), segment.end());
	}
	pushBezierPoints(state, segment);
	return 1;
}

namespace
{
LoveDataObject *getLoveDataObject(lua_State *state, int index)
{
	if (luaL_testudata(state, index, ByteDataUserdata::type.getName()) != nullptr)
		return ::love::luax_checktype<ByteDataUserdata>(state, index);
	if (luaL_testudata(state, index, DataViewUserdata::type.getName()) != nullptr)
		return ::love::luax_checktype<DataViewUserdata>(state, index);
	if (luaL_testudata(state, index, CompressedDataUserdata::type.getName()) != nullptr)
		return ::love::luax_checktype<CompressedDataUserdata>(state, index);
	if (luaL_testudata(state, index, FileDataUserdata::type.getName()) != nullptr)
		return ::love::luax_checktype<FileDataUserdata>(state, index);
	if (luaL_testudata(state, index, ImageDataUserdata::type.getName()) != nullptr)
		return ::love::luax_checktype<ImageDataUserdata>(state, index);
	if (luaL_testudata(state, index, CompressedImageDataUserdata::type.getName()) != nullptr)
		return ::love::luax_checktype<CompressedImageDataUserdata>(state, index);
	if (luaL_testudata(state, index, SoundDataUserdata::type.getName()) != nullptr)
		return ::love::luax_checktype<SoundDataUserdata>(state, index);
	if (luaL_testudata(state, index, GlyphDataUserdata::type.getName()) != nullptr)
		return ::love::luax_checktype<GlyphDataUserdata>(state, index);
	return nullptr;
}

bool getDataSpan(lua_State *state, int index, DataSpan &span)
{
	index = lua_absindex(state, index);
	if (auto *data = getLoveDataObject(state, index))
		span = data->dataSpan();
	else return false;
	return true;
}

DataSpan checkDataSpan(lua_State *state, int index)
{
	DataSpan span;
	if (!getDataSpan(state, index, span)) luaL_argerror(state, index, "Data expected");
	return span;
}

void pushByteData(lua_State *state, std::vector<std::uint8_t> bytes)
{
	auto *data = new ByteDataUserdata(std::move(bytes));
	::love::luax_pushtype(state, ByteDataUserdata::type, data);
	data->release();
}

void pushThreadData(lua_State *state, const std::vector<std::uint8_t> &bytes)
{
	pushByteData(state, bytes);
}

void pushCompressedData(lua_State *state, std::string format, std::size_t decompressedSize,
	std::vector<std::uint8_t> bytes)
{
	auto *data = new CompressedDataUserdata(std::move(format), decompressedSize, std::move(bytes));
	::love::luax_pushtype(state, CompressedDataUserdata::type, data);
	data->release();
}

bool wantsDataContainer(lua_State *state, int index)
{
	const std::string_view container = luaL_checkstring(state, index);
	if (container == "data") return true;
	if (container == "string") return false;
	luaL_argerror(state, index, "container type must be 'data' or 'string'");
	return false;
}

DataSpan checkStringOrData(lua_State *state, int index)
{
	if (lua_type(state, index) == LUA_TSTRING)
	{
		std::size_t size = 0;
		const char *bytes = lua_tolstring(state, index, &size);
		return {reinterpret_cast<const std::uint8_t *>(bytes), size};
	}
	return checkDataSpan(state, index);
}

std::string encodeHex(DataSpan input)
{
	constexpr char digits[] = "0123456789abcdef";
	std::string output(input.size * 2, '\0');
	for (std::size_t index = 0; index < input.size; ++index)
	{
		output[index * 2] = digits[input.bytes[index] >> 4];
		output[index * 2 + 1] = digits[input.bytes[index] & 15];
	}
	return output;
}

std::vector<std::uint8_t> decodeHex(std::string_view input)
{
	if (input.starts_with("0x") || input.starts_with("0X")) input.remove_prefix(2);
	auto nibble = [](char value) -> std::uint8_t {
		if (value >= '0' && value <= '9') return static_cast<std::uint8_t>(value - '0');
		if (value >= 'a' && value <= 'f') return static_cast<std::uint8_t>(value - 'a' + 10);
		if (value >= 'A' && value <= 'F') return static_cast<std::uint8_t>(value - 'A' + 10);
		return 0;
	};
	std::vector<std::uint8_t> output((input.size() + 1) / 2);
	for (std::size_t index = 0; index < output.size(); ++index)
	{
		output[index] = static_cast<std::uint8_t>(nibble(input[index * 2]) << 4);
		if (index * 2 + 1 < input.size()) output[index] |= nibble(input[index * 2 + 1]);
	}
	return output;
}

std::string encodeBase64(DataSpan input, std::size_t lineLength)
{
	constexpr char alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	std::string output;
	const std::size_t encodedSize = ((input.size + 2) / 3) * 4;
	const std::size_t newlineCount = lineLength == 0 ? 0 : encodedSize / lineLength;
	output.reserve(encodedSize + newlineCount);
	const std::size_t blocksPerLine = lineLength == 0
		? std::numeric_limits<std::size_t>::max()
		: std::max<std::size_t>(1, lineLength / 4);
	std::size_t blocksOut = 0;
	std::size_t newlinesOut = 0;
	for (std::size_t index = 0; index < input.size; index += 3)
	{
		const std::uint32_t first = input.bytes[index];
		const std::uint32_t second = index + 1 < input.size ? input.bytes[index + 1] : 0;
		const std::uint32_t third = index + 2 < input.size ? input.bytes[index + 2] : 0;
		const char encoded[] = {alphabet[first >> 2], alphabet[((first & 3) << 4) | (second >> 4)],
			index + 1 < input.size ? alphabet[((second & 15) << 2) | (third >> 6)] : '=',
			index + 2 < input.size ? alphabet[third & 63] : '='};
		output.append(encoded, sizeof(encoded));
		++blocksOut;
		if (blocksOut >= blocksPerLine && newlinesOut < newlineCount)
		{
			output.push_back('\n');
			blocksOut = 0;
			++newlinesOut;
		}
	}
	return output;
}

std::vector<std::uint8_t> decodeBase64(std::string_view input)
{
	std::vector<std::uint8_t> output;
	std::uint32_t accumulator = 0;
	int bits = 0;
	for (const unsigned char character : input)
	{
		int value = -1;
		if (character >= 'A' && character <= 'Z') value = character - 'A';
		else if (character >= 'a' && character <= 'z') value = character - 'a' + 26;
		else if (character >= '0' && character <= '9') value = character - '0' + 52;
		else if (character == '+') value = 62;
		else if (character == '/') value = 63;
		else if (character == '=') break;
		else continue;
		accumulator = (accumulator << 6) | static_cast<std::uint32_t>(value);
		bits += 6;
		if (bits >= 8)
		{
			bits -= 8;
			output.push_back(static_cast<std::uint8_t>(accumulator >> bits));
			accumulator &= (UINT32_C(1) << bits) - 1;
		}
	}
	return output;
}

bool zlibCompressBytes(std::string_view format, DataSpan input, int level,
	std::vector<std::uint8_t> &output)
{
	if (input.size > std::numeric_limits<uInt>::max()) return false;
	if (level < 0) level = Z_DEFAULT_COMPRESSION;
	else level = std::min(level, 9);
	z_stream stream{};
	int windowBits = 15;
	if (format == "gzip") windowBits += 16;
	else if (format == "deflate") windowBits = -windowBits;
	else if (format != "zlib") return false;
	if (deflateInit2(&stream, level, Z_DEFLATED, windowBits, 8, Z_DEFAULT_STRATEGY) != Z_OK)
		return false;
	output.resize(std::min(MaximumLoveDataBytes,
		input.size + (input.size >> 12) + (input.size >> 14) + (input.size >> 25) + 31));
	stream.next_in = const_cast<Bytef *>(reinterpret_cast<const Bytef *>(input.bytes));
	stream.avail_in = static_cast<uInt>(input.size);
	stream.next_out = output.data();
	stream.avail_out = static_cast<uInt>(output.size());
	const int result = deflate(&stream, Z_FINISH);
	const std::size_t size = stream.total_out;
	deflateEnd(&stream);
	if (result != Z_STREAM_END) return false;
	output.resize(size);
	return true;
}

bool zlibDecompressBytes(std::string_view format, DataSpan input, std::size_t expectedSize,
	std::vector<std::uint8_t> &output)
{
	if (input.size > std::numeric_limits<uInt>::max()) return false;
	std::size_t capacity = expectedSize > 0 ? expectedSize : std::max<std::size_t>(input.size * 2, 64);
	while (capacity <= MaximumLoveDataBytes)
	{
		output.resize(capacity);
		z_stream stream{};
		int windowBits = format == "deflate" ? -15 : 15 + 32;
		if (format != "zlib" && format != "gzip" && format != "deflate") return false;
		if (inflateInit2(&stream, windowBits) != Z_OK) return false;
		stream.next_in = const_cast<Bytef *>(reinterpret_cast<const Bytef *>(input.bytes));
		stream.avail_in = static_cast<uInt>(input.size);
		stream.next_out = output.data();
		stream.avail_out = static_cast<uInt>(output.size());
		const int result = inflate(&stream, Z_FINISH);
		const std::size_t size = stream.total_out;
		inflateEnd(&stream);
		if (result == Z_STREAM_END) { output.resize(size); return true; }
		if (result != Z_BUF_ERROR) return false;
		if (capacity == MaximumLoveDataBytes) return false;
		capacity = std::min(MaximumLoveDataBytes, capacity * 2);
	}
	return false;
}

bool lz4CompressBytes(DataSpan input, int level, std::vector<std::uint8_t> &output)
{
	if (input.size > static_cast<std::size_t>(LZ4_MAX_INPUT_SIZE)) return false;
	constexpr std::size_t HeaderSize = sizeof(std::uint32_t);
	const int bound = LZ4_compressBound(static_cast<int>(input.size));
	if (bound <= 0 || HeaderSize + static_cast<std::size_t>(bound) > MaximumLoveDataBytes)
		return false;
	output.resize(HeaderSize + static_cast<std::size_t>(bound));
	const std::uint32_t rawSize = static_cast<std::uint32_t>(input.size);
	output[0] = static_cast<std::uint8_t>(rawSize);
	output[1] = static_cast<std::uint8_t>(rawSize >> 8);
	output[2] = static_cast<std::uint8_t>(rawSize >> 16);
	output[3] = static_cast<std::uint8_t>(rawSize >> 24);
	char *destination = reinterpret_cast<char *>(output.data() + HeaderSize);
	const char *source = reinterpret_cast<const char *>(input.bytes);
	const int compressedSize = level > 8
		? LZ4_compress_HC(source, destination, static_cast<int>(input.size), bound,
			LZ4HC_CLEVEL_DEFAULT)
		: LZ4_compress_default(source, destination, static_cast<int>(input.size), bound);
	if (compressedSize <= 0) return false;
	output.resize(HeaderSize + static_cast<std::size_t>(compressedSize));
	return true;
}

bool lz4DecompressBytes(DataSpan input, std::vector<std::uint8_t> &output)
{
	constexpr std::size_t HeaderSize = sizeof(std::uint32_t);
	if (input.size < HeaderSize) return false;
	const std::uint32_t rawSize = static_cast<std::uint32_t>(input.bytes[0])
		| static_cast<std::uint32_t>(input.bytes[1]) << 8
		| static_cast<std::uint32_t>(input.bytes[2]) << 16
		| static_cast<std::uint32_t>(input.bytes[3]) << 24;
	if (rawSize > MaximumLoveDataBytes || input.size - HeaderSize > static_cast<std::size_t>(INT_MAX))
		return false;
	output.resize(rawSize);
	std::uint8_t emptyDestination = 0;
	char *destination = reinterpret_cast<char *>(rawSize == 0 ? &emptyDestination : output.data());
	const int result = LZ4_decompress_safe(
		reinterpret_cast<const char *>(input.bytes + HeaderSize), destination,
		static_cast<int>(input.size - HeaderSize), static_cast<int>(rawSize));
	return result >= 0 && static_cast<std::uint32_t>(result) == rawSize;
}
}

int LoveRuntime::byteDataClone(lua_State *state)
{
	pushByteData(state, ::love::luax_checktype<ByteDataUserdata>(state, 1)->bytes);
	return 1;
}

int LoveRuntime::dataViewClone(lua_State *state)
{
	auto *source = ::love::luax_checktype<DataViewUserdata>(state, 1);
	auto *view = new DataViewUserdata(source->parent.get(), source->offset, source->size);
	::love::luax_pushtype(state, DataViewUserdata::type, view);
	view->release();
	return 1;
}

int LoveRuntime::compressedDataClone(lua_State *state)
{
	auto *source = ::love::luax_checktype<CompressedDataUserdata>(state, 1);
	pushCompressedData(state, source->format, source->decompressedSize, source->bytes);
	return 1;
}

int LoveRuntime::compressedDataGetFormat(lua_State *state)
{
	lua_pushstring(state, ::love::luax_checktype<CompressedDataUserdata>(state, 1)->format.c_str());
	return 1;
}

int LoveRuntime::compressedImageDataClone(lua_State *state)
{
	pushCompressedImageData(state, checkCompressedImageData(state, 1)->image);
	return 1;
}

namespace
{
const ImageBackend::CompressedImageLevel &checkCompressedImageLevel(lua_State *state, int index)
{
	auto *data = checkCompressedImageData(state, 1);
	const lua_Integer level = luaL_optinteger(state, index, 1);
	luaL_argcheck(state, level >= 1
		&& static_cast<std::size_t>(level) <= data->image.levels.size(), index,
		"compressed image mipmap level does not exist");
	return data->image.levels[static_cast<std::size_t>(level - 1)];
}

bool loadDataInput(lua_State *state, LoveRuntime *runtime, int index,
	std::vector<std::uint8_t> &encoded, std::string &description, std::string &error)
{
	if (lua_type(state, index) == LUA_TSTRING)
	{
		const std::string filename = lua_tostring(state, index);
		std::string resolved;
		std::string contents;
		if (!runtime || !runtime->resolveReadPath(filename, resolved, error)
			|| !runtime->getFilesystemBackend()
			|| !runtime->getFilesystemBackend()->load(resolved, contents, error))
		{
			error = "resolution failed: " + (error.empty()
				? std::string("failed to load through Dora Content") : error);
			return false;
		}
		encoded.assign(reinterpret_cast<const std::uint8_t *>(contents.data()),
			reinterpret_cast<const std::uint8_t *>(contents.data()) + contents.size());
		description = filename;
		return true;
	}
	DataSpan span;
	if (!getDataSpan(state, index, span))
	{
		error = "expected filename or Data";
		return false;
	}
	if (span.size == 0) encoded.clear();
	else encoded.assign(span.bytes, span.bytes + span.size);
	description = "Data";
	error.clear();
	return true;
}

std::uint16_t readFontU16(const std::uint8_t *bytes)
{
	return static_cast<std::uint16_t>((static_cast<std::uint16_t>(bytes[0]) << 8) | bytes[1]);
}

std::uint32_t readFontU32(const std::uint8_t *bytes)
{
	return (static_cast<std::uint32_t>(bytes[0]) << 24)
		| (static_cast<std::uint32_t>(bytes[1]) << 16)
		| (static_cast<std::uint32_t>(bytes[2]) << 8) | bytes[3];
}

bool fontRange(std::size_t offset, std::size_t length, std::size_t size)
{
	return offset <= size && length <= size - offset;
}

bool validateSfnt(const std::vector<std::uint8_t> &bytes, std::size_t offset)
{
	if (!fontRange(offset, 12, bytes.size())) return false;
	const auto signature = readFontU32(bytes.data() + offset);
	if (signature != 0x00010000 && signature != 0x4f54544f
		&& signature != 0x74727565 && signature != 0x74797031) return false;
	const auto count = readFontU16(bytes.data() + offset + 4);
	if (count == 0 || count > 4096 || !fontRange(offset + 12,
		static_cast<std::size_t>(count) * 16, bytes.size())) return false;
	bool cmap = false, head = false, hhea = false, hmtx = false, maxp = false;
	bool glyf = false, loca = false, cff = false;
	for (std::uint16_t index = 0; index < count; ++index)
	{
		const auto *record = bytes.data() + offset + 12 + static_cast<std::size_t>(index) * 16;
		const auto tag = readFontU32(record);
		const auto tableOffset = readFontU32(record + 8);
		const auto length = readFontU32(record + 12);
		if (!fontRange(tableOffset, length, bytes.size())) return false;
		switch (tag)
		{
			case 0x636d6170: cmap = length >= 4; break;
			case 0x68656164: head = length >= 54; break;
			case 0x68686561: hhea = length >= 36; break;
			case 0x686d7478: hmtx = length >= 4; break;
			case 0x6d617870: maxp = length >= 6; break;
			case 0x676c7966: glyf = length > 0; break;
			case 0x6c6f6361: loca = length >= 4; break;
			case 0x43464620:
			case 0x43464632: cff = length > 0; break;
			default: break;
		}
	}
	return cmap && head && hhea && hmtx && maxp && ((glyf && loca) || cff);
}

bool validateFontData(const std::vector<std::uint8_t> &bytes)
{
	if (bytes.size() < 12) return false;
	if (readFontU32(bytes.data()) != 0x74746366) return validateSfnt(bytes, 0);
	if (!fontRange(0, 16, bytes.size())) return false;
	const auto count = readFontU32(bytes.data() + 8);
	return count > 0 && count <= 4096 && fontRange(12, static_cast<std::size_t>(count) * 4, bytes.size())
		&& validateSfnt(bytes, readFontU32(bytes.data() + 12));
}

struct BMFontLineData
{
	std::string tag;
	std::unordered_map<std::string, std::string> attributes;
};

BMFontLineData parseBMFontLine(std::string_view line)
{
	BMFontLineData result;
	std::size_t position = 0;
	while (position < line.size() && std::isspace(static_cast<unsigned char>(line[position]))) ++position;
	const std::size_t tagStart = position;
	while (position < line.size() && !std::isspace(static_cast<unsigned char>(line[position]))) ++position;
	result.tag.assign(line.substr(tagStart, position - tagStart));
	while (position < line.size())
	{
		while (position < line.size() && std::isspace(static_cast<unsigned char>(line[position]))) ++position;
		const std::size_t keyStart = position;
		while (position < line.size() && line[position] != '='
			&& !std::isspace(static_cast<unsigned char>(line[position]))) ++position;
		if (position >= line.size() || line[position] != '=')
		{
			while (position < line.size() && !std::isspace(static_cast<unsigned char>(line[position]))) ++position;
			continue;
		}
		std::string key(line.substr(keyStart, position - keyStart));
		++position;
		std::string value;
		if (position < line.size() && line[position] == '"')
		{
			++position;
			const std::size_t valueStart = position;
			while (position < line.size() && line[position] != '"') ++position;
			value.assign(line.substr(valueStart, position - valueStart));
			if (position < line.size()) ++position;
		}
		else
		{
			const std::size_t valueStart = position;
			while (position < line.size() && !std::isspace(static_cast<unsigned char>(line[position]))) ++position;
			value.assign(line.substr(valueStart, position - valueStart));
		}
		if (!key.empty()) result.attributes[std::move(key)] = std::move(value);
	}
	return result;
}

bool bmFontInteger(const BMFontLineData &line, std::string_view name, int defaultValue,
	int &value, std::string &error, bool required = false)
{
	const auto found = line.attributes.find(std::string(name));
	if (found == line.attributes.end())
	{
		if (required)
		{
			error = "BMFont " + line.tag + " entry is missing " + std::string(name);
			return false;
		}
		value = defaultValue;
		return true;
	}
	const char *begin = found->second.data();
	const char *end = begin + found->second.size();
	const auto result = std::from_chars(begin, end, value);
	if (result.ec != std::errc{} || result.ptr != end)
	{
		error = "BMFont " + line.tag + " attribute " + std::string(name) + " is not an integer";
		return false;
	}
	return true;
}

bool validateCompressedImage(const ImageBackend::CompressedImage &image)
{
	if (image.format.empty() || image.levels.empty()) return false;
	std::size_t total = 0;
	int previousWidth = MaximumWindowDimension + 1;
	int previousHeight = MaximumWindowDimension + 1;
	for (const auto &level : image.levels)
	{
		if (level.width <= 0 || level.height <= 0
			|| level.width > MaximumWindowDimension || level.height > MaximumWindowDimension
			|| level.width > previousWidth || level.height > previousHeight || level.bytes.empty()
			|| level.bytes.size() > MaximumLoveDataBytes - total)
			return false;
		total += level.bytes.size();
		previousWidth = level.width;
		previousHeight = level.height;
	}
	return total > 0;
}
} // namespace

int LoveRuntime::compressedImageDataGetWidth(lua_State *state)
{
	lua_pushinteger(state, checkCompressedImageLevel(state, 2).width);
	return 1;
}

int LoveRuntime::compressedImageDataGetHeight(lua_State *state)
{
	lua_pushinteger(state, checkCompressedImageLevel(state, 2).height);
	return 1;
}

int LoveRuntime::compressedImageDataGetDimensions(lua_State *state)
{
	const auto &level = checkCompressedImageLevel(state, 2);
	lua_pushinteger(state, level.width);
	lua_pushinteger(state, level.height);
	return 2;
}

int LoveRuntime::compressedImageDataGetMipmapCount(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(
		checkCompressedImageData(state, 1)->image.levels.size()));
	return 1;
}

int LoveRuntime::compressedImageDataGetFormat(lua_State *state)
{
	lua_pushstring(state, checkCompressedImageData(state, 1)->image.format.c_str());
	return 1;
}

int LoveRuntime::compressedImageDataGetString(lua_State *state)
{
	auto *data = checkCompressedImageData(state, 1);
	lua_pushlstring(state, reinterpret_cast<const char *>(data->bytes.data()), data->bytes.size());
	return 1;
}

int LoveRuntime::compressedImageDataGetSize(lua_State *state)
{
	lua_pushinteger(state, static_cast<lua_Integer>(checkCompressedImageData(state, 1)->bytes.size()));
	return 1;
}

int LoveRuntime::compressedImageDataGetPointer(lua_State *state)
{
	lua_pushlightuserdata(state, checkCompressedImageData(state, 1)->bytes.data());
	return 1;
}

int LoveRuntime::compressedImageDataGetFFIPointer(lua_State *state)
{
	checkCompressedImageData(state, 1);
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::imageNewCompressedData(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::vector<std::uint8_t> encoded;
	std::string description;
	std::string error;
	if (!loadDataInput(state, runtime, 1, encoded, description, error))
		return luaL_error(state, "Love CompressedImageData resolution failed: %s", error.c_str());
	if (!runtime || !runtime->_imageBackend)
		return luaL_error(state, "love.image is not attached to a Dora compressed image parser");
	ImageBackend::CompressedImage image;
	if (!runtime->_imageBackend->decodeCompressedImage(
		std::string_view(reinterpret_cast<const char *>(encoded.data()), encoded.size()), image, error))
		return luaL_error(state, "Love CompressedImageData '%s' decode failed: %s",
			description.c_str(), error.empty() ? "Dora image parser rejected the data" : error.c_str());
	if (!validateCompressedImage(image))
		return luaL_error(state, "Love CompressedImageData '%s' decode failed: Dora image parser returned invalid metadata",
			description.c_str());
	pushCompressedImageData(state, std::move(image));
	return 1;
}

int LoveRuntime::imageIsCompressed(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::vector<std::uint8_t> encoded;
	std::string description;
	std::string error;
	if (!loadDataInput(state, runtime, 1, encoded, description, error))
		return luaL_error(state, "Love compressed image probe failed: %s", error.c_str());
	if (!runtime || !runtime->_imageBackend)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	ImageBackend::CompressedImage image;
	const bool compressed = runtime->_imageBackend->decodeCompressedImage(
		std::string_view(reinterpret_cast<const char *>(encoded.data()), encoded.size()), image, error)
		&& validateCompressedImage(image);
	lua_pushboolean(state, compressed);
	return 1;
}

int LoveRuntime::rasterizerGetHeight(lua_State *state)
{
	lua_pushinteger(state, checkRasterizer(state, 1)->height);
	return 1;
}

int LoveRuntime::rasterizerGetAdvance(lua_State *state)
{
	lua_pushinteger(state, checkRasterizer(state, 1)->advance);
	return 1;
}

int LoveRuntime::rasterizerGetAscent(lua_State *state)
{
	lua_pushinteger(state, checkRasterizer(state, 1)->ascent);
	return 1;
}

int LoveRuntime::rasterizerGetDescent(lua_State *state)
{
	lua_pushinteger(state, checkRasterizer(state, 1)->descent);
	return 1;
}

int LoveRuntime::rasterizerGetLineHeight(lua_State *state)
{
	lua_pushinteger(state, checkRasterizer(state, 1)->lineHeight);
	return 1;
}

int LoveRuntime::rasterizerGetGlyphData(lua_State *state)
{
	checkRasterizer(state, 1);
	pushRasterizerGlyphData(state, 1, checkGlyphCodepoint(state, 2));
	return 1;
}

int LoveRuntime::rasterizerGetGlyphCount(lua_State *state)
{
	auto *rasterizer = checkRasterizer(state, 1);
	const lua_Integer count = rasterizer->kind == RasterizerUserdata::Kind::TrueType
		? rasterizer->fontInfo.numGlyphs
		: rasterizer->kind == RasterizerUserdata::Kind::BMFont
			? static_cast<lua_Integer>(rasterizer->bmGlyphs.size())
			: static_cast<lua_Integer>(rasterizer->glyphs.size());
	lua_pushinteger(state, count);
	return 1;
}

int LoveRuntime::rasterizerHasGlyphs(lua_State *state)
{
	auto *rasterizer = checkRasterizer(state, 1);
	const int argumentCount = lua_gettop(state) - 1;
	if (argumentCount < 1)
		return luaL_argerror(state, 2, "expected at least one glyph or UTF-8 string");
	for (int index = 2; index <= argumentCount + 1; ++index)
	{
		std::vector<std::uint32_t> requested;
		if (lua_type(state, index) == LUA_TSTRING)
		{
			size_t length = 0;
			const char *text = lua_tolstring(state, index, &length);
			std::string error;
			if (!decodeUtf8(std::string_view(text, length), requested, error))
				return luaL_argerror(state, index, error.c_str());
			if (requested.empty())
			{
				lua_pushboolean(state, false);
				return 1;
			}
		}
		else
			requested.push_back(checkGlyphCodepoint(state, index));
		for (const auto codepoint : requested)
		{
			const bool found = rasterizer->kind == RasterizerUserdata::Kind::TrueType
				? stbtt_FindGlyphIndex(&rasterizer->fontInfo, static_cast<int>(codepoint)) != 0
				: rasterizer->kind == RasterizerUserdata::Kind::BMFont
					? rasterizer->bmGlyphs.contains(codepoint)
					: std::any_of(rasterizer->imageGlyphs.begin(), rasterizer->imageGlyphs.end(),
						[codepoint](const ImageRasterizerGlyph &glyph) { return glyph.codepoint == codepoint; });
			if (!found)
			{
				lua_pushboolean(state, false);
				return 1;
			}
		}
	}
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::glyphDataClone(lua_State *state)
{
	pushGlyphData(state, *checkGlyphData(state, 1));
	return 1;
}

int LoveRuntime::glyphDataGetWidth(lua_State *state)
{
	lua_pushinteger(state, checkGlyphData(state, 1)->width);
	return 1;
}

int LoveRuntime::glyphDataGetHeight(lua_State *state)
{
	lua_pushinteger(state, checkGlyphData(state, 1)->height);
	return 1;
}

int LoveRuntime::glyphDataGetDimensions(lua_State *state)
{
	auto *data = checkGlyphData(state, 1);
	lua_pushinteger(state, data->width);
	lua_pushinteger(state, data->height);
	return 2;
}

int LoveRuntime::glyphDataGetGlyph(lua_State *state)
{
	lua_pushnumber(state, static_cast<lua_Number>(checkGlyphData(state, 1)->glyph));
	return 1;
}

int LoveRuntime::glyphDataGetGlyphString(lua_State *state)
{
	const std::string glyph = encodeUtf8(checkGlyphData(state, 1)->glyph);
	lua_pushlstring(state, glyph.data(), glyph.size());
	return 1;
}

int LoveRuntime::glyphDataGetAdvance(lua_State *state)
{
	lua_pushinteger(state, checkGlyphData(state, 1)->advance);
	return 1;
}

int LoveRuntime::glyphDataGetBearing(lua_State *state)
{
	auto *data = checkGlyphData(state, 1);
	lua_pushinteger(state, data->bearingX);
	lua_pushinteger(state, data->bearingY);
	return 2;
}

int LoveRuntime::glyphDataGetBoundingBox(lua_State *state)
{
	auto *data = checkGlyphData(state, 1);
	const int minX = data->bearingX;
	const int minY = data->height - data->bearingY;
	const int maxX = data->bearingX + data->width;
	const int maxY = data->bearingY;
	lua_pushinteger(state, minX);
	lua_pushinteger(state, minY);
	lua_pushinteger(state, maxX - minX);
	lua_pushinteger(state, maxY - minY);
	return 4;
}

int LoveRuntime::glyphDataGetFormat(lua_State *state)
{
	lua_pushstring(state, checkGlyphData(state, 1)->format);
	return 1;
}

int LoveRuntime::glyphDataGetString(lua_State *state)
{
	auto *data = checkGlyphData(state, 1);
	lua_pushlstring(state, reinterpret_cast<const char *>(data->pixels.data()), data->pixels.size());
	return 1;
}

int LoveRuntime::glyphDataGetSize(lua_State *state)
{
	lua_pushnumber(state, static_cast<lua_Number>(checkGlyphData(state, 1)->pixels.size()));
	return 1;
}

int LoveRuntime::glyphDataGetPointer(lua_State *state)
{
	lua_pushlightuserdata(state, checkGlyphData(state, 1)->pixels.data());
	return 1;
}

int LoveRuntime::glyphDataGetFFIPointer(lua_State *state)
{
	checkGlyphData(state, 1);
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::fontNewImageRasterizer(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *image = checkImageData(state, 1);
	luaL_argcheck(state, std::string_view(image->format) == "rgba8", 1,
		"Image Rasterizer requires an rgba8 ImageData source");
	size_t glyphTextSize = 0;
	const char *glyphText = luaL_checklstring(state, 2, &glyphTextSize);
	const lua_Integer extraSpacing = luaL_optinteger(state, 3, 0);
	const lua_Number dpiScale = luaL_optnumber(state, 4, 1.0);
	luaL_argcheck(state, extraSpacing >= std::numeric_limits<int>::min()
		&& extraSpacing <= std::numeric_limits<int>::max(), 3, "extra spacing is outside the integer range");
	luaL_argcheck(state, std::isfinite(dpiScale) && dpiScale > 0.0, 4,
		"DPI scale must be a positive finite number");

	RasterizerUserdata rasterizer;
	rasterizer.runtime = runtime;
	rasterizer.height = image->height;
	rasterizer.lineHeight = image->height;
	rasterizer.extraSpacing = static_cast<int>(extraSpacing);
	rasterizer.dpiScale = static_cast<float>(dpiScale);
	std::string error;
	if (!decodeUtf8(std::string_view(glyphText, glyphTextSize), rasterizer.glyphs, error))
		return luaL_argerror(state, 2, error.c_str());
	luaL_argcheck(state, !rasterizer.glyphs.empty(), 2, "glyph string must not be empty");
	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*image, rgba8);
	std::copy_n(rgba8.begin(), 4, rasterizer.spacer.begin());

	int end = 0;
	for (const auto codepoint : rasterizer.glyphs)
	{
		int start = end;
		while (start < image->width && std::equal(rasterizer.spacer.begin(), rasterizer.spacer.end(),
			rgba8.begin() + static_cast<std::ptrdiff_t>(start) * 4))
			++start;
		end = start;
		while (end < image->width && !std::equal(rasterizer.spacer.begin(), rasterizer.spacer.end(),
			rgba8.begin() + static_cast<std::ptrdiff_t>(end) * 4))
			++end;
		if (start >= end)
			break;
		auto found = std::find_if(rasterizer.imageGlyphs.begin(), rasterizer.imageGlyphs.end(),
			[codepoint](const ImageRasterizerGlyph &glyph) { return glyph.codepoint == codepoint; });
		if (found == rasterizer.imageGlyphs.end())
			rasterizer.imageGlyphs.push_back({codepoint, start, end - start});
		else
			*found = {codepoint, start, end - start};
	}
	pushRasterizer(state, std::move(rasterizer), 1);
	return 1;
}

int LoveRuntime::fontNewTrueTypeRasterizer(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const bool defaultFont = lua_isnone(state, 1) || lua_type(state, 1) == LUA_TNUMBER;
	const int sizeIndex = defaultFont ? 1 : 2;
	const int hintIndex = defaultFont ? 2 : 3;
	const int dpiIndex = defaultFont ? 3 : 4;
	const lua_Integer requestedSize = luaL_optinteger(state, sizeIndex, 12);
	luaL_argcheck(state, requestedSize > 0 && requestedSize <= 4096, sizeIndex,
		"TrueType Rasterizer size must be between 1 and 4096");
	const std::string_view hinting = lua_isnoneornil(state, hintIndex)
		? std::string_view("normal") : std::string_view(luaL_checkstring(state, hintIndex));
	if (hinting != "normal" && hinting != "light" && hinting != "mono" && hinting != "none")
		return luaL_argerror(state, hintIndex,
			"hinting mode must be 'normal', 'light', 'mono', or 'none'");
	const lua_Number dpiScale = luaL_optnumber(state, dpiIndex, 1.0);
	luaL_argcheck(state, std::isfinite(dpiScale) && dpiScale > 0.0, dpiIndex,
		"DPI scale must be a positive finite number");
	const double scaledSize = static_cast<double>(requestedSize) * dpiScale;
	luaL_argcheck(state, scaledSize <= 4096.0, dpiIndex,
		"scaled TrueType Rasterizer size must not exceed 4096");

	RasterizerUserdata rasterizer;
	rasterizer.kind = RasterizerUserdata::Kind::TrueType;
	rasterizer.runtime = runtime;
	rasterizer.dpiScale = static_cast<float>(dpiScale);
	rasterizer.monochrome = hinting == "mono";
	try
	{
		if (defaultFont)
		{
			luaL_argcheck(state, !runtime->_defaultFontData.empty(), 1,
				"default TrueType font data is unavailable");
			rasterizer.fontBytes.assign(
				reinterpret_cast<const std::uint8_t *>(runtime->_defaultFontData.data()),
				reinterpret_cast<const std::uint8_t *>(runtime->_defaultFontData.data())
					+ runtime->_defaultFontData.size());
		}
		else
		{
			std::string description;
			std::string error;
			if (!loadDataInput(state, runtime, 1, rasterizer.fontBytes, description, error))
				return luaL_argerror(state, 1, error.c_str());
		}
	}
	catch (const std::bad_alloc &)
	{
		return luaL_error(state, "out of memory while copying TrueType font data");
	}
	auto rejectFont = [&](const char *message) {
		rasterizer.fontBytes.clear();
		rasterizer.fontBytes.shrink_to_fit();
		return luaL_argerror(state, 1, message);
	};
	if (rasterizer.fontBytes.size() > MaximumLoveDataBytes)
		return rejectFont("TrueType font data is too large");
	if (!validateFontData(rasterizer.fontBytes))
		return rejectFont("invalid or truncated TrueType/OpenType font data");
	const int fontOffset = stbtt_GetFontOffsetForIndex(rasterizer.fontBytes.data(), 0);
	if (fontOffset < 0
		|| stbtt_InitFont(&rasterizer.fontInfo, rasterizer.fontBytes.data(), fontOffset) == 0)
		return rejectFont("failed to initialize TrueType/OpenType font data");
	const float pixelSize = static_cast<float>(std::floor(scaledSize + 0.5));
	rasterizer.fontScale = stbtt_ScaleForPixelHeight(&rasterizer.fontInfo, pixelSize);
	int ascent = 0, descent = 0, lineGap = 0;
	stbtt_GetFontVMetrics(&rasterizer.fontInfo, &ascent, &descent, &lineGap);
	rasterizer.ascent = static_cast<int>(std::floor(ascent * rasterizer.fontScale + 0.5f));
	rasterizer.descent = static_cast<int>(std::ceil(descent * rasterizer.fontScale - 0.5f));
	rasterizer.height = static_cast<int>(std::floor((ascent - descent) * rasterizer.fontScale + 0.5f));
	rasterizer.lineHeight = static_cast<int>(std::floor(rasterizer.height * 1.25f));
	int x0 = 0, y0 = 0, x1 = 0, y1 = 0;
	stbtt_GetFontBoundingBox(&rasterizer.fontInfo, &x0, &y0, &x1, &y1);
	rasterizer.advance = static_cast<int>(std::floor((x1 - x0) * rasterizer.fontScale + 0.5f));
	pushRasterizer(state, std::move(rasterizer), 0);
	return 1;
}

int LoveRuntime::fontNewBMFontRasterizer(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::string descriptor;
	std::string descriptorName;
	std::string error;
	if (lua_type(state, 1) == LUA_TSTRING)
	{
		descriptorName = lua_tostring(state, 1);
		std::string resolved;
		if (!runtime->resolveReadPath(descriptorName, resolved, error)
			|| !runtime->_filesystemBackend
			|| !runtime->_filesystemBackend->load(resolved, descriptor, error))
			return luaL_error(state, "BMFont '%s' Content load failed: %s",
				descriptorName.c_str(), error.empty() ? "file does not exist" : error.c_str());
	}
	else if (auto *fileData = testFileData(state, 1))
	{
		descriptor = fileData->data;
		descriptorName = fileData->filename;
	}
	else
		return luaL_argerror(state, 1, "BMFont filename or FileData expected");
	const lua_Number dpiScale = luaL_optnumber(state, 3, 1.0);
	luaL_argcheck(state, std::isfinite(dpiScale) && dpiScale > 0.0, 3,
		"DPI scale must be a positive finite number");
	luaL_argcheck(state, descriptor.size() <= MaximumLoveDataBytes, 1,
		"BMFont descriptor is too large");

	RasterizerUserdata rasterizer;
	rasterizer.kind = RasterizerUserdata::Kind::BMFont;
	rasterizer.runtime = runtime;
	rasterizer.dpiScale = static_cast<float>(dpiScale);
	std::unordered_map<int, std::string> pageFiles;
	bool unicode = false;
	int lineHeight = 0;
	int base = 0;
	std::istringstream input(descriptor);
	std::string textLine;
	while (std::getline(input, textLine))
	{
		if (!textLine.empty() && textLine.back() == '\r') textLine.pop_back();
		const auto line = parseBMFontLine(textLine);
		if (line.tag.empty()) continue;
		if (line.tag == "info")
		{
			int unicodeValue = 0;
			if (!bmFontInteger(line, "unicode", 0, unicodeValue, error))
				return luaL_error(state, "%s", error.c_str());
			unicode = unicodeValue > 0;
		}
		else if (line.tag == "common")
		{
			if (!bmFontInteger(line, "lineHeight", 0, lineHeight, error)
				|| !bmFontInteger(line, "base", 0, base, error))
				return luaL_error(state, "%s", error.c_str());
		}
		else if (line.tag == "page")
		{
			int page = 0;
			if (!bmFontInteger(line, "id", 0, page, error, true))
				return luaL_error(state, "%s", error.c_str());
			const auto filename = line.attributes.find("file");
			if (page < 0 || page > 4095 || filename == line.attributes.end() || filename->second.empty())
				return luaL_error(state, "invalid BMFont page entry");
			pageFiles[page] = filename->second;
		}
		else if (line.tag == "char")
		{
			BMFontGlyph glyph;
			int codepoint = 0;
			if (!bmFontInteger(line, "id", 0, codepoint, error, true)
				|| !bmFontInteger(line, "x", 0, glyph.x, error, true)
				|| !bmFontInteger(line, "y", 0, glyph.y, error, true)
				|| !bmFontInteger(line, "page", 0, glyph.page, error)
				|| !bmFontInteger(line, "width", 0, glyph.width, error, true)
				|| !bmFontInteger(line, "height", 0, glyph.height, error, true)
				|| !bmFontInteger(line, "xadvance", 0, glyph.advance, error)
				|| !bmFontInteger(line, "xoffset", 0, glyph.bearingX, error))
				return luaL_error(state, "%s", error.c_str());
			int yOffset = 0;
			if (!bmFontInteger(line, "yoffset", 0, yOffset, error))
				return luaL_error(state, "%s", error.c_str());
			if (codepoint < 0 || codepoint > 0x10ffff || (codepoint >= 0xd800 && codepoint <= 0xdfff)
				|| glyph.page < 0 || glyph.page > 4095 || glyph.x < 0 || glyph.y < 0
				|| glyph.width < 0 || glyph.height < 0)
				return luaL_error(state, "invalid BMFont character entry");
			glyph.codepoint = static_cast<std::uint32_t>(codepoint);
			glyph.bearingY = -yOffset;
			rasterizer.bmGlyphs[glyph.codepoint] = glyph;
			if (lineHeight == 0) rasterizer.height = std::max(rasterizer.height, glyph.height);
		}
	}
	if (rasterizer.bmGlyphs.empty())
		return luaL_error(state, "invalid BMFont descriptor: no character definitions");
	if (!unicode)
		for (const auto &[codepoint, glyph] : rasterizer.bmGlyphs)
			if (codepoint > 127)
				return luaL_error(state, "invalid non-Unicode BMFont character id %u", codepoint);
	if (lineHeight > 0) rasterizer.height = lineHeight;
	rasterizer.lineHeight = rasterizer.height;
	rasterizer.ascent = base;

	if (!runtime->_imageBackend)
		return luaL_error(state, "love.font BMFont is not attached to the Dora image decoder");
	lua_newtable(state);
	const int retainedPages = lua_absindex(state, -1);
	auto pushPageImage = [&](int valueIndex, std::string_view description) -> bool {
		valueIndex = lua_absindex(state, valueIndex);
		if (auto *image = testImageData(state, valueIndex))
		{
			if (image->runtime != runtime)
			{
				error = "ImageData belongs to another LoveRuntime";
				return false;
			}
			lua_pushvalue(state, valueIndex);
			return true;
		}
		std::string encoded;
		if (lua_type(state, valueIndex) == LUA_TSTRING)
		{
			const std::string filename = lua_tostring(state, valueIndex);
			std::string resolved;
			if (!runtime->resolveReadPath(filename, resolved, error)
				|| !runtime->_filesystemBackend
				|| !runtime->_filesystemBackend->load(resolved, encoded, error))
			{
				error = "Content load failed for BMFont page '" + filename + "': " + error;
				return false;
			}
		}
		else if (auto *data = testFileData(state, valueIndex))
			encoded = data->data;
		else
		{
			error = "BMFont page must be ImageData, filename, or FileData";
			return false;
		}
		int width = 0, height = 0;
		std::vector<std::uint8_t> pixels;
		if (!runtime->_imageBackend->decodeImage(encoded, width, height, pixels, error)
			|| width <= 0 || height <= 0
			|| pixels.size() != static_cast<std::size_t>(width) * height * 4)
		{
			error = "BMFont page decode failed for '" + std::string(description) + "': "
				+ (error.empty() ? "invalid RGBA8 image" : error);
			return false;
		}
		pushImageData(state, runtime, width, height, std::move(pixels));
		return true;
	};

	if (lua_istable(state, 2))
	{
		const lua_Integer count = static_cast<lua_Integer>(lua_rawlen(state, 2));
		for (lua_Integer index = 1; index <= count; ++index)
		{
			lua_geti(state, 2, index);
			if (!pushPageImage(-1, "explicit page"))
			{
				lua_pop(state, 1);
				return luaL_argerror(state, 2, error.c_str());
			}
			lua_seti(state, retainedPages, index);
			lua_pop(state, 1);
		}
	}
	else if (!lua_isnoneornil(state, 2))
	{
		if (!pushPageImage(2, "explicit page"))
			return luaL_argerror(state, 2, error.c_str());
		lua_seti(state, retainedPages, 1);
	}

	const std::filesystem::path descriptorFolder = std::filesystem::path(descriptorName).parent_path();
	for (const auto &[page, filename] : pageFiles)
	{
		lua_geti(state, retainedPages, static_cast<lua_Integer>(page) + 1);
		const bool provided = !lua_isnil(state, -1);
		lua_pop(state, 1);
		if (!provided)
		{
			// BMFont descriptors use Love filesystem paths, not native host paths.
			// std::filesystem::path::string() emits backslashes on Windows, which
			// would then be correctly rejected by the Content-only path sandbox.
			const std::string pagePath = (descriptorFolder / filename).lexically_normal().generic_string();
			lua_pushlstring(state, pagePath.data(), pagePath.size());
			if (!pushPageImage(-1, pagePath))
			{
				lua_pop(state, 1);
				return luaL_error(state, "%s", error.c_str());
			}
			lua_seti(state, retainedPages, static_cast<lua_Integer>(page) + 1);
			lua_pop(state, 1);
		}
	}
	for (const auto &[codepoint, glyph] : rasterizer.bmGlyphs)
	{
		lua_geti(state, retainedPages, static_cast<lua_Integer>(glyph.page) + 1);
		auto *image = testImageData(state, -1);
		if (!image || glyph.x >= image->width || glyph.y >= image->height
			|| glyph.width > image->width - glyph.x || glyph.height > image->height - glyph.y)
		{
			lua_pop(state, 1);
			return luaL_error(state, "BMFont character %u has an invalid page or rectangle", codepoint);
		}
		lua_pop(state, 1);
	}
	pushRasterizer(state, std::move(rasterizer), retainedPages);
	return 1;
}

int LoveRuntime::fontNewRasterizer(lua_State *state)
{
	if (lua_isnone(state, 1) || lua_type(state, 1) == LUA_TNUMBER
		|| lua_type(state, 2) == LUA_TNUMBER)
		return fontNewTrueTypeRasterizer(state);
	if (!lua_isnoneornil(state, 2)) return fontNewBMFontRasterizer(state);
	std::string prefix;
	if (lua_type(state, 1) == LUA_TSTRING)
	{
		std::string resolved, error;
		if (auto *runtime = runtimeFromUpvalue(state); runtime->resolveReadPath(lua_tostring(state, 1), resolved, error)
			&& runtime->_filesystemBackend)
			runtime->_filesystemBackend->load(resolved, prefix, error);
	}
	else if (auto *data = testFileData(state, 1))
		prefix = data->data;
	if (prefix.size() >= 4 && prefix.compare(0, 4, "info") == 0)
		return fontNewBMFontRasterizer(state);
	return fontNewTrueTypeRasterizer(state);
}

int LoveRuntime::fontNewGlyphData(lua_State *state)
{
	checkRasterizer(state, 1);
	pushRasterizerGlyphData(state, 1, checkGlyphCodepoint(state, 2));
	return 1;
}

int LoveRuntime::genericDataGetString(lua_State *state)
{
	const auto span = checkDataSpan(state, 1);
	lua_pushlstring(state, reinterpret_cast<const char *>(span.bytes), span.size);
	return 1;
}

int LoveRuntime::genericDataGetSize(lua_State *state)
{
	lua_pushnumber(state, static_cast<lua_Number>(checkDataSpan(state, 1).size));
	return 1;
}

int LoveRuntime::genericDataGetPointer(lua_State *state)
{
	lua_pushlightuserdata(state, const_cast<std::uint8_t *>(checkDataSpan(state, 1).bytes));
	return 1;
}

int LoveRuntime::genericDataGetFFIPointer(lua_State *state)
{
	checkDataSpan(state, 1);
	lua_pushnil(state);
	return 1;
}

int LoveRuntime::dataNewByteData(lua_State *state)
{
	std::vector<std::uint8_t> bytes;
	DataSpan input;
	if (getDataSpan(state, 1, input))
	{
		const lua_Integer offset = luaL_optinteger(state, 2, 0);
		luaL_argcheck(state, offset >= 0 && static_cast<std::size_t>(offset) <= input.size, 2,
			"offset must fit within the Data's size");
		const lua_Integer defaultSize = static_cast<lua_Integer>(input.size - offset);
		const lua_Integer size = luaL_optinteger(state, 3, defaultSize);
		luaL_argcheck(state, size > 0 && static_cast<std::size_t>(size) <= input.size - offset, 3,
			"size must be positive and fit within the Data's size");
		bytes.assign(input.bytes + offset, input.bytes + offset + size);
	}
	else if (lua_type(state, 1) == LUA_TSTRING)
	{
		std::size_t size = 0;
		const char *data = lua_tolstring(state, 1, &size);
		luaL_argcheck(state, size > 0, 1, "ByteData size must be greater than 0");
		bytes.assign(data, data + size);
	}
	else
	{
		const lua_Integer size = luaL_checkinteger(state, 1);
		luaL_argcheck(state, size > 0 && static_cast<std::size_t>(size) <= MaximumLoveDataBytes, 1,
			"Data size must be a positive supported number");
		bytes.resize(static_cast<std::size_t>(size));
	}
	pushByteData(state, std::move(bytes));
	return 1;
}

int LoveRuntime::dataNewDataView(lua_State *state)
{
	const auto parent = checkDataSpan(state, 1);
	const lua_Integer offset = luaL_checkinteger(state, 2);
	const lua_Integer size = luaL_checkinteger(state, 3);
	luaL_argcheck(state, offset >= 0 && size > 0
		&& static_cast<std::size_t>(offset) <= parent.size
		&& static_cast<std::size_t>(size) <= parent.size - offset, 2,
		"offset and size must fit within the Data's size");
	auto *object = getLoveDataObject(state, 1);
	luaL_argcheck(state, object != nullptr, 1, "Data expected");
	auto *view = new DataViewUserdata(object,
		static_cast<std::size_t>(offset), static_cast<std::size_t>(size));
	::love::luax_pushtype(state, DataViewUserdata::type, view);
	view->release();
	return 1;
}

int LoveRuntime::dataEncode(lua_State *state)
{
	const bool asData = wantsDataContainer(state, 1);
	const std::string_view format = luaL_checkstring(state, 2);
	const auto input = checkStringOrData(state, 3);
	std::string output;
	if (format == "hex") output = encodeHex(input);
	else if (format == "base64")
	{
		const lua_Integer lineLength = luaL_optinteger(state, 4, 0);
		luaL_argcheck(state, lineLength >= 0, 4, "line length must not be negative");
		output = encodeBase64(input, static_cast<std::size_t>(lineLength));
	}
	else return luaL_argerror(state, 2, "encode format must be 'hex' or 'base64'");
	if (asData) pushByteData(state, {output.begin(), output.end()});
	else lua_pushlstring(state, output.data(), output.size());
	return 1;
}

int LoveRuntime::dataDecode(lua_State *state)
{
	const bool asData = wantsDataContainer(state, 1);
	const std::string_view format = luaL_checkstring(state, 2);
	const auto input = checkStringOrData(state, 3);
	const std::string_view encoded(reinterpret_cast<const char *>(input.bytes), input.size);
	std::vector<std::uint8_t> output;
	if (format == "hex") output = decodeHex(encoded);
	else if (format == "base64") output = decodeBase64(encoded);
	else return luaL_argerror(state, 2, "decode format must be 'hex' or 'base64'");
	if (asData) pushByteData(state, std::move(output));
	else lua_pushlstring(state, reinterpret_cast<const char *>(output.data()), output.size());
	return 1;
}

int LoveRuntime::dataCompress(lua_State *state)
{
	const bool asData = wantsDataContainer(state, 1);
	const std::string format = luaL_checkstring(state, 2);
	const auto input = checkStringOrData(state, 3);
	luaL_argcheck(state, input.size <= MaximumLoveDataBytes, 3, "input Data is too large");
	const int level = static_cast<int>(luaL_optinteger(state, 4, -1));
	std::vector<std::uint8_t> output;
	const bool success = format == "lz4"
		? lz4CompressBytes(input, level, output)
		: zlibCompressBytes(format, input, level, output);
	if (!success)
		return luaL_error(state, "Could not %s-compress data.", format.c_str());
	if (asData) pushCompressedData(state, format, input.size, std::move(output));
	else lua_pushlstring(state, reinterpret_cast<const char *>(output.data()), output.size());
	return 1;
}

int LoveRuntime::dataDecompress(lua_State *state)
{
	const bool asData = wantsDataContainer(state, 1);
	std::string format;
	std::size_t expectedSize = 0;
	DataSpan input;
	if (luaL_testudata(state, 2, CompressedDataUserdata::type.getName()) != nullptr)
	{
		auto *compressed = ::love::luax_checktype<CompressedDataUserdata>(state, 2);
		format = compressed->format;
		expectedSize = compressed->decompressedSize;
		input = {compressed->bytes.data(), compressed->bytes.size()};
	}
	else
	{
		format = luaL_checkstring(state, 2);
		input = checkStringOrData(state, 3);
	}
	std::vector<std::uint8_t> output;
	const bool success = format == "lz4"
		? lz4DecompressBytes(input, output)
		: zlibDecompressBytes(format, input, expectedSize, output);
	if (!success)
		return luaL_error(state, "Could not decompress %s-compressed data.", format.c_str());
	if (asData) pushByteData(state, std::move(output));
	else lua_pushlstring(state, reinterpret_cast<const char *>(output.data()), output.size());
	return 1;
}

int LoveRuntime::dataPack(lua_State *state)
{
	const bool asData = wantsDataContainer(state, 1);
	const int originalTop = lua_gettop(state);
	lua_getglobal(state, "string");
	lua_getfield(state, -1, "pack");
	lua_remove(state, -2);
	lua_insert(state, 1);
	lua_remove(state, 2);
	lua_call(state, originalTop - 1, 1);
	if (asData)
	{
		std::size_t size = 0;
		const char *bytes = lua_tolstring(state, -1, &size);
		std::vector<std::uint8_t> output(bytes, bytes + size);
		lua_pop(state, 1);
		pushByteData(state, std::move(output));
	}
	return 1;
}

int LoveRuntime::dataUnpack(lua_State *state)
{
	if (lua_type(state, 2) != LUA_TSTRING)
	{
		const auto input = checkDataSpan(state, 2);
		lua_pushlstring(state, reinterpret_cast<const char *>(input.bytes), input.size);
		lua_replace(state, 2);
	}
	const int arguments = lua_gettop(state);
	lua_getglobal(state, "string");
	lua_getfield(state, -1, "unpack");
	lua_remove(state, -2);
	lua_insert(state, 1);
	lua_call(state, arguments, LUA_MULTRET);
	return lua_gettop(state);
}

int LoveRuntime::dataGetPackedSize(lua_State *state)
{
	lua_getglobal(state, "string");
	lua_getfield(state, -1, "packsize");
	lua_remove(state, -2);
	lua_insert(state, 1);
	lua_call(state, lua_gettop(state) - 1, 1);
	return 1;
}

int LoveRuntime::dataHash(lua_State *state)
{
	using HashFunction = love::data::HashFunction;
	const std::string_view name = luaL_checkstring(state, 1);
	HashFunction::Function function;
	if (name == "md5") function = HashFunction::FUNCTION_MD5;
	else if (name == "sha1") function = HashFunction::FUNCTION_SHA1;
	else if (name == "sha224") function = HashFunction::FUNCTION_SHA224;
	else if (name == "sha256") function = HashFunction::FUNCTION_SHA256;
	else if (name == "sha384") function = HashFunction::FUNCTION_SHA384;
	else if (name == "sha512") function = HashFunction::FUNCTION_SHA512;
	else return luaL_argerror(state, 1,
		"hash function must be 'md5', 'sha1', 'sha224', 'sha256', 'sha384', or 'sha512'");
	const auto input = checkStringOrData(state, 2);
	luaL_argcheck(state, input.size <= MaximumLoveDataBytes, 2, "input Data is too large");
	HashFunction::Value output{};
	try
	{
		HashFunction *hasher = HashFunction::getHashFunction(function);
		if (!hasher) return luaL_error(state, "Hash function is unavailable.");
		hasher->hash(function, reinterpret_cast<const char *>(input.bytes), input.size, output);
	}
	catch (const std::bad_alloc &)
	{
		return luaL_error(state, "Out of memory while hashing data.");
	}
	catch (const std::exception &error)
	{
		return luaL_error(state, "%s", error.what());
	}
	lua_pushlstring(state, output.data, output.size);
	return 1;
}

namespace
{
std::shared_ptr<VideoStreamState> makeVideoStream(lua_State *luaState,
	LoveRuntime *runtime, std::string filename)
{
	if (!runtime || !runtime->getFilesystemBackend())
		luaL_error(luaState, "love.video is not attached to Dora Content");
	std::string resolved;
	std::string bytes;
	std::string error;
	if (!runtime->resolveReadPath(filename, resolved, error)
		|| !runtime->getFilesystemBackend()->load(resolved, bytes, error))
		luaL_error(luaState, "Love VideoStream '%s' load failed through Dora Content: %s",
			filename.c_str(), error.empty() ? "file is unavailable" : error.c_str());
	try
	{
		auto result = std::make_shared<VideoStreamState>();
		result->runtime = runtime;
		result->luaState = luaState;
		result->file.set(new ContentVideoFile(filename, std::move(bytes)), ::love::Acquire::NORETAIN);
		result->stream.set(new ::love::video::theora::TheoraVideoStream(result->file),
			::love::Acquire::NORETAIN);
		result->start();
		return result;
	}
	catch (const ::love::Exception &exception)
	{
		luaL_error(luaState, "Love VideoStream '%s' is not valid Ogg/Theora: %s",
			filename.c_str(), exception.what());
	}
	catch (const std::exception &exception)
	{
		luaL_error(luaState, "Love VideoStream '%s' creation failed: %s",
			filename.c_str(), exception.what());
	}
	return {};
}

void pushVideoStream(lua_State *state, const std::shared_ptr<VideoStreamState> &stream)
{
	auto *userdata = new VideoStreamUserdata;
	userdata->state = stream;
	::love::luax_pushtype(state, VideoStreamLoveType, userdata);
	userdata->release();
}

void setVideoStreamSync(lua_State *state, VideoStreamState &video, int index)
{
	if (video.sourceReference != LUA_NOREF)
	{
		luaL_unref(state, LUA_REGISTRYINDEX, video.sourceReference);
		video.sourceReference = LUA_NOREF;
	}
	video.sourceObject.set(nullptr);
	if (lua_isnoneornil(state, index))
	{
		auto *sync = new ::love::video::VideoStream::DeltaSync();
		video.stream->setSync(sync);
		sync->release();
		return;
	}
	auto *source = checkAudioSource(state, index);
	luaL_argcheck(state, source->runtime == video.runtime && source->handle != 0,
		index, "Source belongs to another or closed LoveRuntime");
	luaL_argcheck(state, video.runtime->getAudioBackend() != nullptr,
		index, "Love audio is not attached to Dora SoLoud");
	lua_pushvalue(state, index);
	video.sourceReference = luaL_ref(state, LUA_REGISTRYINDEX);
	video.sourceObject.set(source);
	auto *sync = new DoraAudioFrameSync(video.runtime->getAudioBackend(), source->handle);
	video.stream->setSync(sync);
	sync->release();
}

std::vector<std::uint8_t> convertVideoFrame(const ::love::video::VideoStream::Frame &frame)
{
	std::vector<std::uint8_t> rgba(static_cast<std::size_t>(frame.yw) * frame.yh * 4);
	for (int y = 0; y < frame.yh; ++y)
	for (int x = 0; x < frame.yw; ++x)
	{
		const int chromaX = x * frame.cw / frame.yw;
		const int chromaY = y * frame.ch / frame.yh;
		const int luminance = static_cast<int>(frame.yplane[y * frame.yw + x]) - 16;
		const int blueDifference = static_cast<int>(frame.cbplane[chromaY * frame.cw + chromaX]) - 128;
		const int redDifference = static_cast<int>(frame.crplane[chromaY * frame.cw + chromaX]) - 128;
		const int scaled = std::max(0, luminance) * 298;
		const auto clampByte = [](int value) {
			return static_cast<std::uint8_t>(std::clamp(value, 0, 255));
		};
		const std::size_t offset = (static_cast<std::size_t>(y) * frame.yw + x) * 4;
		rgba[offset] = clampByte((scaled + 409 * redDifference + 128) >> 8);
		rgba[offset + 1] = clampByte((scaled - 100 * blueDifference - 208 * redDifference + 128) >> 8);
		rgba[offset + 2] = clampByte((scaled + 516 * blueDifference + 128) >> 8);
		rgba[offset + 3] = 255;
	}
	return rgba;
}
} // namespace

int LoveRuntime::videoNewVideoStream(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	pushVideoStream(state, makeVideoStream(state, runtime, filename));
	return 1;
}

int LoveRuntime::videoStreamPlay(lua_State *state) { checkVideoStream(state, 1)->state->stream->play(); return 0; }
int LoveRuntime::videoStreamPause(lua_State *state) { checkVideoStream(state, 1)->state->stream->pause(); return 0; }
int LoveRuntime::videoStreamSeek(lua_State *state)
{
	const double offset = luaL_checknumber(state, 2);
	luaL_argcheck(state, std::isfinite(offset) && offset >= 0.0, 2,
		"seek offset must be a finite non-negative number");
	checkVideoStream(state, 1)->state->stream->seek(offset);
	return 0;
}
int LoveRuntime::videoStreamRewind(lua_State *state) { checkVideoStream(state, 1)->state->stream->seek(0.0); return 0; }
int LoveRuntime::videoStreamTell(lua_State *state) { lua_pushnumber(state, checkVideoStream(state, 1)->state->stream->tell()); return 1; }
int LoveRuntime::videoStreamIsPlaying(lua_State *state) { lua_pushboolean(state, checkVideoStream(state, 1)->state->stream->isPlaying()); return 1; }
int LoveRuntime::videoStreamGetFilename(lua_State *state)
{
	const auto &filename = checkVideoStream(state, 1)->state->stream->getFilename();
	lua_pushlstring(state, filename.data(), filename.size());
	return 1;
}
int LoveRuntime::videoStreamSetSync(lua_State *state)
{
	auto *stream = checkVideoStream(state, 1);
	setVideoStreamSync(state, *stream->state, 2);
	return 0;
}

int LoveRuntime::graphicsNewVideo(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (!runtime || !runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	std::shared_ptr<VideoStreamState> stream;
	if (auto *existing = luaL_testudata(state, 1, VideoStreamLoveType.getName())
		? ::love::luax_checktype<VideoStreamUserdata>(state, 1, VideoStreamLoveType) : nullptr)
		stream = existing->state;
	else
		stream = makeVideoStream(state, runtime, luaL_checkstring(state, 1));
	const int width = stream->stream->getWidth();
	const int height = stream->stream->getHeight();
	std::vector<std::uint8_t> blank(static_cast<std::size_t>(width) * height * 4, 0);
	std::string error;
	const auto image = runtime->_graphicsBackend->newImage(GraphicsBackend::TextureType::Texture2D,
		width, height, 1, blank, error);
	if (image == 0)
		return luaL_error(state, "Love Video texture creation failed: %s", error.c_str());
	auto *video = new VideoUserdata(runtime, stream, image);
	pushNewDoraHandleObject(state, VideoUserdata::type, video);
	bool attachAudio = true;
	bool requireAudio = false;
	if (lua_istable(state, 2))
	{
		lua_getfield(state, 2, "audio");
		if (!lua_isnil(state, -1))
		{
			attachAudio = lua_toboolean(state, -1);
			requireAudio = attachAudio;
		}
		lua_pop(state, 1);
	}
	if (attachAudio && runtime->_audioBackend)
	{
		std::string resolved;
		std::string audioError;
		const std::string &filename = stream->stream->getFilename();
		if (runtime->resolveReadPath(filename, resolved, audioError))
		{
			const auto source = runtime->_audioBackend->newSource(resolved, "stream", audioError);
			if (source != 0)
			{
				pushAudioSource(state, runtime, source, true);
				setVideoStreamSync(state, *stream, -1);
				lua_pop(state, 1);
			}
			else if (requireAudio)
				return luaL_error(state, "Video had no playable audio track: %s", audioError.c_str());
		}
		else if (requireAudio)
			return luaL_error(state, "Video audio path resolution failed: %s", audioError.c_str());
	}
	else if (requireAudio)
		return luaL_error(state, "love.audio was not loaded");
	return 1;
}

int LoveRuntime::videoGetStream(lua_State *state) { pushVideoStream(state, checkVideo(state, 1)->state); return 1; }
int LoveRuntime::videoGetSource(lua_State *state)
{
	auto &stream = *checkVideo(state, 1)->state;
	if (!stream.sourceObject) lua_pushnil(state);
	else ::love::luax_pushtype(state, AudioSourceUserdata::type,
		static_cast<AudioSourceUserdata *>(stream.sourceObject.get()));
	return 1;
}
int LoveRuntime::videoSetSource(lua_State *state)
{
	setVideoStreamSync(state, *checkVideo(state, 1)->state, 2);
	return 0;
}
int LoveRuntime::videoGetWidth(lua_State *state) { lua_pushinteger(state, checkVideo(state, 1)->state->stream->getWidth()); return 1; }
int LoveRuntime::videoGetHeight(lua_State *state) { lua_pushinteger(state, checkVideo(state, 1)->state->stream->getHeight()); return 1; }
int LoveRuntime::videoGetDimensions(lua_State *state)
{
	auto *video = checkVideo(state, 1);
	lua_pushinteger(state, video->state->stream->getWidth());
	lua_pushinteger(state, video->state->stream->getHeight());
	return 2;
}
int LoveRuntime::videoSetFilter(lua_State *state)
{
	auto *video = checkVideo(state, 1);
	const std::string_view min = luaL_checkstring(state, 2);
	const std::string_view mag = luaL_checkstring(state, 3);
	if ((min != "linear" && min != "nearest") || mag != min)
		return luaL_error(state, "embedded Dora Videos require matching 'linear' or 'nearest' filters");
	video->anisotropy = static_cast<float>(luaL_optnumber(state, 4, 1.0));
	luaL_argcheck(state, std::isfinite(video->anisotropy) && video->anisotropy >= 1.0f,
		4, "anisotropy must be a finite number greater than or equal to 1");
	video->filter = min == "nearest" ? GraphicsBackend::TextureFilter::Nearest
		: video->anisotropy > 1.0f ? GraphicsBackend::TextureFilter::Anisotropic
		: GraphicsBackend::TextureFilter::Linear;
	return 0;
}
int LoveRuntime::videoGetFilter(lua_State *state)
{
	auto *video = checkVideo(state, 1);
	const char *mode = video->filter == GraphicsBackend::TextureFilter::Nearest ? "nearest" : "linear";
	lua_pushstring(state, mode); lua_pushstring(state, mode); lua_pushnumber(state, video->anisotropy);
	return 3;
}

bool LoveRuntime::decodeSoundInput(lua_State *state, int index, int &sampleRate, int &channels,
	std::vector<std::uint8_t> &samples, std::string &description, std::string &error)
{
	std::string encoded;
	if (lua_type(state, index) == LUA_TSTRING)
	{
		const std::string filename = lua_tostring(state, index);
		std::string resolved;
		if (!resolveReadPath(filename, resolved, error) || !_filesystemBackend
			|| !_filesystemBackend->load(resolved, encoded, error))
		{
			error = "resolution failed: " + (error.empty()
				? std::string("failed to load through Dora Content") : error);
			return false;
		}
		description = filename;
	}
	else if (auto *fileData = testFileData(state, index))
	{
		encoded = fileData->data;
		description = fileData->filename;
	}
	else
	{
		error = "expected filename or FileData";
		return false;
	}
	if (!_soundBackend)
	{
		error = "love.sound is not attached to the Dora SoLoud decoder";
		return false;
	}
	std::vector<float> decoded;
	if (!_soundBackend->decodeSound(encoded, sampleRate, channels, decoded, error))
	{
		error = "decode failed: " + (error.empty()
			? std::string("Dora SoLoud decoder rejected the data") : error);
		return false;
	}
	if (sampleRate <= 0 || sampleRate > 384000 || channels < 1 || channels > 8
		|| decoded.empty() || decoded.size() % static_cast<std::size_t>(channels) != 0
		|| decoded.size() > MaximumSoundDataBytes / 2)
	{
		error = "decode failed: Dora SoLoud decoder returned invalid sample metadata";
		return false;
	}
	samples.resize(decoded.size() * 2);
	for (std::size_t sample = 0; sample < decoded.size(); ++sample)
	{
		if (!std::isfinite(decoded[sample]))
		{
			error = "decode failed: Dora SoLoud decoder returned a non-finite sample";
			return false;
		}
		const auto signedValue = static_cast<std::int16_t>(std::lround(
			std::clamp(static_cast<double>(decoded[sample]), -1.0, 1.0) * 32767.0));
		const auto bits = static_cast<std::uint16_t>(signedValue);
		samples[sample * 2] = static_cast<std::uint8_t>(bits & 0xff);
		samples[sample * 2 + 1] = static_cast<std::uint8_t>(bits >> 8);
	}
	error.clear();
	return true;
}

int LoveRuntime::soundNewDecoder(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const lua_Integer requestedBufferSize = luaL_optinteger(state, 2, 16384);
	luaL_argcheck(state, requestedBufferSize > 0
		&& static_cast<std::size_t>(requestedBufferSize) <= MaximumSoundDataBytes, 2,
		"Decoder buffer size must be between 1 byte and 256 MiB");
	if (!runtime)
		return luaL_error(state, "love.sound Decoder has no Love runtime");
	int sampleRate = 0;
	int channels = 0;
	std::vector<std::uint8_t> samples;
	std::string description;
	std::string error;
	if (!runtime->decodeSoundInput(state, 1, sampleRate, channels, samples, description, error))
	{
		if (error == "expected filename or FileData")
			return luaL_argerror(state, 1, error.c_str());
		return luaL_error(state, "Love Decoder '%s' %s", description.c_str(), error.c_str());
	}
	pushDecoder(state, sampleRate, channels, static_cast<std::size_t>(requestedBufferSize),
		std::move(samples));
	return 1;
}

int LoveRuntime::soundNewSoundData(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (lua_type(state, 1) == LUA_TNUMBER)
	{
		// Love 11.5 runs on LuaJIT, whose luaL_checkinteger truncates numeric
		// values. Lua 5.5 instead rejects numbers without exact integer
		// representations, while existing generators commonly derive this
		// count from a floating-point duration.
		const double sampleCountValue = luaL_checknumber(state, 1);
		const double sampleRateValue = luaL_optnumber(state, 2, 44100);
		const double bitDepthValue = luaL_optnumber(state, 3, 16);
		const double channelsValue = luaL_optnumber(state, 4, 2);
		luaL_argcheck(state, std::isfinite(sampleCountValue)
			&& sampleCountValue >= 1.0 && sampleCountValue <= 100000000.0, 1,
			"sample count must be between 1 and 100000000");
		luaL_argcheck(state, std::isfinite(sampleRateValue)
			&& sampleRateValue >= 1.0 && sampleRateValue <= 384000.0, 2,
			"sample rate must be between 1 and 384000");
		const lua_Integer sampleCount = static_cast<lua_Integer>(sampleCountValue);
		const lua_Integer sampleRate = static_cast<lua_Integer>(sampleRateValue);
		const lua_Integer bitDepth = static_cast<lua_Integer>(bitDepthValue);
		const lua_Integer channels = static_cast<lua_Integer>(channelsValue);
		luaL_argcheck(state, bitDepth == 8 || bitDepth == 16, 3, "bit depth must be 8 or 16");
		luaL_argcheck(state, channels >= 1 && channels <= 8, 4, "channel count must be between 1 and 8");
		const std::size_t byteCount = static_cast<std::size_t>(sampleCount)
			* static_cast<std::size_t>(channels) * static_cast<std::size_t>(bitDepth / 8);
		luaL_argcheck(state, byteCount <= MaximumSoundDataBytes, 1,
			"SoundData storage cannot exceed 256 MiB");
		std::vector<std::uint8_t> samples(byteCount, bitDepth == 8 ? 128 : 0);
		pushSoundData(state, static_cast<int>(sampleRate), static_cast<int>(bitDepth),
			static_cast<int>(channels), static_cast<int>(sampleCount), std::move(samples));
		return 1;
	}
	if (auto *decoder = luaL_testudata(state, 1, DecoderLoveType.getName())
		? ::love::luax_checktype<DecoderUserdata>(state, 1, DecoderLoveType) : nullptr)
	{
		const std::size_t byteCount = decoder->samples.size() - decoder->bytePosition;
		std::vector<std::uint8_t> samples(byteCount);
		std::copy_n(decoder->samples.begin() + static_cast<std::ptrdiff_t>(decoder->bytePosition),
			static_cast<std::ptrdiff_t>(byteCount), samples.begin());
		decoder->bytePosition = decoder->samples.size();
		const std::size_t frameBytes = static_cast<std::size_t>(decoder->channels) * 2;
		pushSoundData(state, decoder->sampleRate, decoder->bitDepth, decoder->channels,
			static_cast<int>(byteCount / frameBytes), std::move(samples));
		return 1;
	}

	int sampleRate = 0;
	int channels = 0;
	std::vector<std::uint8_t> samples;
	std::string description;
	std::string error;
	if (!runtime || !runtime->decodeSoundInput(state, 1, sampleRate, channels,
		samples, description, error))
	{
		if (error == "expected filename or FileData")
			return luaL_argerror(state, 1, "expected filename, FileData, Decoder, or sample count");
		return luaL_error(state, "Love SoundData '%s' %s", description.c_str(), error.c_str());
	}
	pushSoundData(state, sampleRate, 16, channels,
		static_cast<int>(samples.size() / (static_cast<std::size_t>(channels) * 2)),
		std::move(samples));
	return 1;
}

int LoveRuntime::fontGetWidth(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	std::size_t size = 0;
	const char *text = luaL_checklstring(state, 2, &size);
	lua_pushnumber(state, font->runtime->_graphicsBackend->getFontWidth(font->handle, {text, size}));
	return 1;
}

int LoveRuntime::fontGetHeight(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	lua_pushnumber(state, font->runtime->_graphicsBackend->getFontHeight(font->handle));
	return 1;
}

int LoveRuntime::fontGetBaseline(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	lua_pushnumber(state, font->runtime->_graphicsBackend->getFontBaseline(font->handle));
	return 1;
}

int LoveRuntime::fontGetWrap(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	std::size_t size = 0;
	const char *text = luaL_checklstring(state, 2, &size);
	const float limit = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, limit > 0.0f, 3, "wrap limit must be positive");
	std::vector<std::string> lines;
	const float width = font->runtime->_graphicsBackend->getFontWrap(font->handle, {text, size}, limit, lines);
	lua_pushnumber(state, width);
	lua_createtable(state, static_cast<int>(lines.size()), 0);
	for (std::size_t i = 0; i < lines.size(); ++i)
	{
		lua_pushlstring(state, lines[i].data(), lines[i].size());
		lua_seti(state, -2, static_cast<lua_Integer>(i + 1));
	}
	return 2;
}

int LoveRuntime::fontGetAscent(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	lua_pushnumber(state, font->runtime->_graphicsBackend->getFontAscent(font->handle));
	return 1;
}

int LoveRuntime::fontGetDescent(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	lua_pushnumber(state, font->runtime->_graphicsBackend->getFontDescent(font->handle));
	return 1;
}

int LoveRuntime::fontHasGlyphs(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	if (lua_gettop(state) < 2)
		return luaL_argerror(state, 2, "expected text or codepoint");
	bool hasGlyphs = true;
	for (int index = 2; index <= lua_gettop(state) && hasGlyphs; ++index)
	{
		std::vector<std::uint32_t> codepoints;
		if (lua_type(state, index) == LUA_TSTRING)
		{
			std::size_t size = 0;
			const char *bytes = lua_tolstring(state, index, &size);
			std::string error;
			if (!decodeUtf8({bytes, size}, codepoints, error))
				return luaL_argerror(state, index, error.c_str());
			if (codepoints.empty()) hasGlyphs = false;
		}
		else if (lua_type(state, index) == LUA_TNUMBER)
		{
			const lua_Integer value = luaL_checkinteger(state, index);
			luaL_argcheck(state, value >= 0 && value <= 0x10ffff
				&& !(value >= 0xd800 && value <= 0xdfff), index, "invalid Unicode codepoint");
			codepoints.push_back(static_cast<std::uint32_t>(value));
		}
		else
			return luaL_argerror(state, index, "expected text or Unicode codepoint");
		for (const std::uint32_t codepoint : codepoints)
		{
			if (!font->runtime->_graphicsBackend->hasFontGlyph(font->handle, codepoint))
			{
				hasGlyphs = false;
				break;
			}
		}
	}
	lua_pushboolean(state, hasGlyphs);
	return 1;
}

int LoveRuntime::fontGetKerning(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	auto readCodepoint = [state](int index) -> std::uint32_t {
		if (lua_type(state, index) == LUA_TNUMBER)
		{
			const lua_Integer value = luaL_checkinteger(state, index);
			luaL_argcheck(state, value >= 0 && value <= 0x10ffff
				&& !(value >= 0xd800 && value <= 0xdfff), index, "invalid Unicode codepoint");
			return static_cast<std::uint32_t>(value);
		}
		std::size_t size = 0;
		const char *bytes = luaL_checklstring(state, index, &size);
		std::vector<std::uint32_t> codepoints;
		std::string error;
		if (!decodeUtf8({bytes, size}, codepoints, error) || codepoints.size() != 1)
			luaL_argerror(state, index, codepoints.empty() ? error.c_str() : "expected exactly one Unicode character");
		return codepoints.front();
	};
	const std::uint32_t left = readCodepoint(2);
	const std::uint32_t right = readCodepoint(3);
	lua_pushnumber(state, font->runtime->_graphicsBackend->getFontKerning(font->handle, left, right));
	return 1;
}

int LoveRuntime::fontSetFallbacks(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	std::vector<GraphicsBackend::FontHandle> fallbacks;
	std::vector<::love::StrongRef<::love::Object>> fallbackObjects;
	for (int index = 2; index <= lua_gettop(state); ++index)
	{
		auto *fallback = checkFont(state, index);
		luaL_argcheck(state, fallback->runtime == font->runtime
			&& font->runtime->_fontHandles.contains(fallback->handle), index,
			"fallback Font belongs to another or closed LoveRuntime");
		fallbacks.push_back(fallback->handle);
		fallbackObjects.emplace_back(fallback);
	}
	std::string error;
	if (!font->runtime->_graphicsBackend->setFontFallbacks(font->handle, fallbacks, error))
		return luaL_error(state, "Love Font setFallbacks failed: %s",
			error.empty() ? "Dora font backend rejected fallback fonts" : error.c_str());
	font->fallbackObjects = std::move(fallbackObjects);
	return 0;
}

int LoveRuntime::fontSetLineHeight(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	const double lineHeight = luaL_checknumber(state, 2);
	luaL_argcheck(state, std::isfinite(lineHeight) && lineHeight > 0.0, 2,
		"Font line height must be finite and positive");
	font->runtime->_graphicsBackend->setFontLineHeight(font->handle, static_cast<float>(lineHeight));
	return 0;
}

int LoveRuntime::fontGetLineHeight(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	lua_pushnumber(state, font->runtime->_graphicsBackend->getFontLineHeight(font->handle));
	return 1;
}

int LoveRuntime::fontSetFilter(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_graphicsBackend
		&& font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	const std::string_view min = luaL_checkstring(state, 2);
	const std::string_view mag = luaL_optstring(state, 3, min.data());
	if (min != "linear" && min != "nearest") return luaL_argerror(state, 2, "expected 'linear' or 'nearest'");
	if (mag != "linear" && mag != "nearest") return luaL_argerror(state, 3, "expected 'linear' or 'nearest'");
	if (min != mag) return luaL_error(state, "embedded Dora Fonts require matching minification and magnification filters");
	const float anisotropy = static_cast<float>(luaL_optnumber(state, 4, 1.0));
	luaL_argcheck(state, std::isfinite(anisotropy) && anisotropy >= 1.0f, 4,
		"anisotropy must be a finite number greater than or equal to 1");
	font->filter = min == "nearest" ? GraphicsBackend::TextureFilter::Nearest
		: anisotropy > 1.0f ? GraphicsBackend::TextureFilter::Anisotropic
		: GraphicsBackend::TextureFilter::Linear;
	font->anisotropy = anisotropy;
	return 0;
}

int LoveRuntime::fontGetFilter(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	const char *mode = font->filter == GraphicsBackend::TextureFilter::Nearest ? "nearest" : "linear";
	lua_pushstring(state, mode); lua_pushstring(state, mode); lua_pushnumber(state, font->anisotropy);
	return 3;
}

int LoveRuntime::fontGetDPIScale(lua_State *state)
{
	auto *font = checkFont(state, 1);
	luaL_argcheck(state, font->runtime && font->runtime->_fontHandles.contains(font->handle), 1, "closed Font");
	lua_pushnumber(state, font->dpiScale);
	return 1;
}

int LoveRuntime::fontEqual(lua_State *state)
{
	auto *left = testFont(state, 1);
	auto *right = testFont(state, 2);
	lua_pushboolean(state, left && right && left->runtime == right->runtime && left->handle == right->handle);
	return 1;
}

void LoveRuntime::registerImageType()
{
	::love::luax_register_type(_state, &ImageUserdata::type, nullptr);
	::love::luax_gettypemetatable(_state, ImageUserdata::type);
		lua_pushcfunction(_state, imageGetWidth);
		lua_setfield(_state, -2, "getWidth");
		lua_pushcfunction(_state, imageGetHeight);
		lua_setfield(_state, -2, "getHeight");
		lua_pushcfunction(_state, imageGetDimensions);
		lua_setfield(_state, -2, "getDimensions");
		lua_pushcfunction(_state, imageGetTextureType);
		lua_setfield(_state, -2, "getTextureType");
		lua_pushcfunction(_state, imageGetDepth);
		lua_setfield(_state, -2, "getDepth");
		lua_pushcfunction(_state, imageGetLayerCount);
		lua_setfield(_state, -2, "getLayerCount");
		lua_pushcfunction(_state, imageGetMipmapCount); lua_setfield(_state, -2, "getMipmapCount");
		lua_pushcfunction(_state, imageGetPixelWidth); lua_setfield(_state, -2, "getPixelWidth");
		lua_pushcfunction(_state, imageGetPixelHeight); lua_setfield(_state, -2, "getPixelHeight");
		lua_pushcfunction(_state, imageGetPixelDimensions); lua_setfield(_state, -2, "getPixelDimensions");
		lua_pushcfunction(_state, imageGetDPIScale); lua_setfield(_state, -2, "getDPIScale");
		lua_pushcfunction(_state, imageSetFilter);
		lua_setfield(_state, -2, "setFilter");
		lua_pushcfunction(_state, imageGetFilter);
		lua_setfield(_state, -2, "getFilter");
		lua_pushcfunction(_state, imageSetMipmapFilter); lua_setfield(_state, -2, "setMipmapFilter");
		lua_pushcfunction(_state, imageGetMipmapFilter); lua_setfield(_state, -2, "getMipmapFilter");
		lua_pushcfunction(_state, imageSetWrap);
		lua_setfield(_state, -2, "setWrap");
		lua_pushcfunction(_state, imageGetWrap);
		lua_setfield(_state, -2, "getWrap");
		lua_pushcfunction(_state, imageGetFormat); lua_setfield(_state, -2, "getFormat");
		lua_pushcfunction(_state, imageIsReadable); lua_setfield(_state, -2, "isReadable");
		lua_pushcfunction(_state, imageSetDepthSampleMode); lua_setfield(_state, -2, "setDepthSampleMode");
		lua_pushcfunction(_state, imageGetDepthSampleMode); lua_setfield(_state, -2, "getDepthSampleMode");
			lua_pushcfunction(_state, imageIsFormatLinear); lua_setfield(_state, -2, "isFormatLinear");
			lua_pushcfunction(_state, graphicsImageIsCompressed); lua_setfield(_state, -2, "isCompressed");
			lua_pushcfunction(_state, imageReplacePixels); lua_setfield(_state, -2, "replacePixels");
	lua_pop(_state, 1);
}

void LoveRuntime::registerCanvasType()
{
	static const luaL_Reg functions[] = {
			{"getTextureType", canvasGetTextureType},
			{"getWidth", canvasGetWidth},
			{"getHeight", canvasGetHeight},
			{"getDimensions", canvasGetDimensions},
			{"getDepth", canvasGetDepth},
			{"getLayerCount", canvasGetLayerCount},
			{"getMipmapCount", canvasGetMipmapCount},
			{"getPixelWidth", canvasGetPixelWidth},
			{"getPixelHeight", canvasGetPixelHeight},
			{"getPixelDimensions", canvasGetPixelDimensions},
			{"getDPIScale", canvasGetDPIScale},
			{"getFormat", canvasGetFormat},
			{"getMSAA", canvasGetMSAA},
			{"isReadable", canvasIsReadable},
			{"newImageData", canvasNewImageData},
			{"setFilter", canvasSetFilter},
			{"getFilter", canvasGetFilter},
			{"setMipmapFilter", canvasSetMipmapFilter},
			{"getMipmapFilter", canvasGetMipmapFilter},
			{"setWrap", canvasSetWrap},
			{"getWrap", canvasGetWrap},
			{"setDepthSampleMode", canvasSetDepthSampleMode},
			{"getDepthSampleMode", canvasGetDepthSampleMode},
			{"renderTo", canvasRenderTo},
			{"generateMipmaps", canvasGenerateMipmaps},
			{"getMipmapMode", canvasGetMipmapMode},
			{"__eq", canvasEqual},
			{nullptr, nullptr},
		};
	::love::luax_register_type(_state, &CanvasUserdata::type, functions, nullptr);
	::love::luax_gettypemetatable(_state, CanvasUserdata::type);
	lua_pushcfunction(_state, canvasEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerImageDataType()
{
	static const luaL_Reg functions[] = {
			{"clone", imageDataClone},
			{"getWidth", imageDataGetWidth},
			{"getHeight", imageDataGetHeight},
			{"getDimensions", imageDataGetDimensions},
			{"getFormat", imageDataGetFormat},
			{"getPixel", imageDataGetPixel},
			{"setPixel", imageDataSetPixel},
			{"mapPixel", imageDataMapPixel},
			{"paste", imageDataPaste},
			{"encode", imageDataEncode},
			{"getString", imageDataGetString},
			{"getSize", imageDataGetSize},
			{"getPointer", imageDataGetPointer},
			{"getFFIPointer", imageDataGetFFIPointer}, {nullptr, nullptr},
	};
	::love::luax_register_type(_state, &ImageDataUserdata::type, functions, nullptr);
}

void LoveRuntime::registerCompressedImageDataType()
{
	static const luaL_Reg functions[] = {
			{"clone", compressedImageDataClone},
			{"getWidth", compressedImageDataGetWidth},
			{"getHeight", compressedImageDataGetHeight},
			{"getDimensions", compressedImageDataGetDimensions},
			{"getMipmapCount", compressedImageDataGetMipmapCount},
			{"getFormat", compressedImageDataGetFormat},
			{"getString", compressedImageDataGetString},
			{"getSize", compressedImageDataGetSize},
			{"getPointer", compressedImageDataGetPointer},
			{"getFFIPointer", compressedImageDataGetFFIPointer}, {nullptr, nullptr},
	};
	::love::luax_register_type(_state, &CompressedImageDataUserdata::type, functions, nullptr);
}

void LoveRuntime::registerRasterizerType()
{
	static const luaL_Reg functions[] = {
			{"getHeight", rasterizerGetHeight}, {"getAdvance", rasterizerGetAdvance},
			{"getAscent", rasterizerGetAscent}, {"getDescent", rasterizerGetDescent},
			{"getLineHeight", rasterizerGetLineHeight}, {"getGlyphData", rasterizerGetGlyphData},
			{"getGlyphCount", rasterizerGetGlyphCount}, {"hasGlyphs", rasterizerHasGlyphs},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &RasterizerLoveType, functions, nullptr);
}

void LoveRuntime::registerGlyphDataType()
{
	static const luaL_Reg functions[] = {
			{"clone", glyphDataClone}, {"getWidth", glyphDataGetWidth},
			{"getHeight", glyphDataGetHeight}, {"getDimensions", glyphDataGetDimensions},
			{"getGlyph", glyphDataGetGlyph}, {"getGlyphString", glyphDataGetGlyphString},
			{"getAdvance", glyphDataGetAdvance}, {"getBearing", glyphDataGetBearing},
			{"getBoundingBox", glyphDataGetBoundingBox}, {"getFormat", glyphDataGetFormat},
			{"getString", glyphDataGetString}, {"getSize", glyphDataGetSize},
			{"getPointer", glyphDataGetPointer}, {"getFFIPointer", glyphDataGetFFIPointer},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &GlyphDataUserdata::type, functions, nullptr);
}

void LoveRuntime::registerSoundDataType()
{
	static const luaL_Reg functions[] = {
			{"clone", soundDataClone},
			{"getChannelCount", soundDataGetChannelCount},
			{"getChannels", soundDataGetChannels},
			{"getBitDepth", soundDataGetBitDepth},
			{"getSampleRate", soundDataGetSampleRate},
			{"getSampleCount", soundDataGetSampleCount},
			{"getDuration", soundDataGetDuration},
			{"getSample", soundDataGetSample},
			{"setSample", soundDataSetSample},
			{"getString", soundDataGetString},
			{"getSize", soundDataGetSize},
			{"getPointer", soundDataGetPointer},
			{"getFFIPointer", soundDataGetFFIPointer}, {nullptr, nullptr},
	};
	::love::luax_register_type(_state, &SoundDataUserdata::type, functions, nullptr);
}

void LoveRuntime::registerDecoderType()
{
	static const luaL_Reg functions[] = {
			{"clone", decoderClone},
			{"getChannelCount", decoderGetChannelCount},
			{"getChannels", decoderGetChannels},
			{"getBitDepth", decoderGetBitDepth},
			{"getSampleRate", decoderGetSampleRate},
			{"getDuration", decoderGetDuration},
			{"decode", decoderDecode},
			{"seek", decoderSeek},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &DecoderLoveType, functions, nullptr);
}

void LoveRuntime::registerRandomGeneratorType()
{
	static const luaL_Reg functions[] = {
			{"random", randomGeneratorRandom},
			{"randomNormal", randomGeneratorRandomNormal},
			{"setSeed", randomGeneratorSetSeed},
			{"getSeed", randomGeneratorGetSeed},
			{"setState", randomGeneratorSetState},
			{"getState", randomGeneratorGetState},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &RandomGeneratorLoveType, functions, nullptr);
}

void LoveRuntime::registerTransformType()
{
	static const luaL_Reg functions[] = {
			{"clone", transformClone}, {"inverse", transformInverse},
			{"apply", transformApply}, {"isAffine2DTransform", transformIsAffine2DTransform},
			{"translate", transformTranslate}, {"rotate", transformRotate},
			{"scale", transformScale}, {"shear", transformShear},
			{"reset", transformReset}, {"setTransformation", transformSetTransformation},
			{"setMatrix", transformSetMatrix}, {"getMatrix", transformGetMatrix},
			{"transformPoint", transformTransformPoint},
			{"inverseTransformPoint", transformInverseTransformPoint},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &TransformLoveType, functions, nullptr);
	::love::luax_gettypemetatable(_state, TransformLoveType);
	lua_pushcfunction(_state, transformMultiply);
	lua_setfield(_state, -2, "__mul");
	lua_pop(_state, 1);
}

void LoveRuntime::registerBezierCurveType()
{
	static const luaL_Reg functions[] = {
			{"getDegree", bezierCurveGetDegree}, {"getDerivative", bezierCurveGetDerivative},
			{"getControlPoint", bezierCurveGetControlPoint},
			{"setControlPoint", bezierCurveSetControlPoint},
			{"insertControlPoint", bezierCurveInsertControlPoint},
			{"removeControlPoint", bezierCurveRemoveControlPoint},
			{"getControlPointCount", bezierCurveGetControlPointCount},
			{"translate", bezierCurveTranslate}, {"rotate", bezierCurveRotate},
			{"scale", bezierCurveScale}, {"evaluate", bezierCurveEvaluate},
			{"getSegment", bezierCurveGetSegment}, {"render", bezierCurveRender},
			{"renderSegment", bezierCurveRenderSegment},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &BezierCurveLoveType, functions, nullptr);
}

void LoveRuntime::registerByteDataType()
{
	static const luaL_Reg functions[] = {
		{"clone", byteDataClone}, {"getString", genericDataGetString},
		{"getSize", genericDataGetSize}, {"getPointer", genericDataGetPointer},
		{"getFFIPointer", genericDataGetFFIPointer}, {nullptr, nullptr},
	};
	::love::luax_register_type(_state, &ByteDataUserdata::type, functions, nullptr);
}

void LoveRuntime::registerDataViewType()
{
	static const luaL_Reg functions[] = {
		{"clone", dataViewClone}, {"getString", genericDataGetString},
		{"getSize", genericDataGetSize}, {"getPointer", genericDataGetPointer},
		{"getFFIPointer", genericDataGetFFIPointer}, {nullptr, nullptr},
	};
	::love::luax_register_type(_state, &DataViewUserdata::type, functions, nullptr);
}

void LoveRuntime::registerCompressedDataType()
{
	static const luaL_Reg functions[] = {
		{"clone", compressedDataClone}, {"getFormat", compressedDataGetFormat},
		{"getString", genericDataGetString}, {"getSize", genericDataGetSize},
		{"getPointer", genericDataGetPointer}, {"getFFIPointer", genericDataGetFFIPointer},
		{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &CompressedDataUserdata::type, functions, nullptr);
}

void LoveRuntime::registerQuadType()
{
	static const luaL_Reg functions[] = {
		{"setViewport", quadSetViewport}, {"getViewport", quadGetViewport},
		{"getTextureDimensions", quadGetTextureDimensions},
		{"setLayer", quadSetLayer}, {"getLayer", quadGetLayer}, {nullptr, nullptr},
	};
	::love::luax_register_type(_state, &QuadLoveType, functions, nullptr);
	::love::luax_gettypemetatable(_state, QuadLoveType);
	lua_pushcfunction(_state, quadEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerMeshType()
{
	static const luaL_Reg functions[] = {
			{"setVertices", meshSetVertices},
			{"setVertex", meshSetVertex},
			{"getVertex", meshGetVertex},
			{"setVertexAttribute", meshSetVertexAttribute},
			{"getVertexAttribute", meshGetVertexAttribute},
			{"getVertexCount", meshGetVertexCount},
			{"getVertexFormat", meshGetVertexFormat},
			{"setAttributeEnabled", meshSetAttributeEnabled},
			{"isAttributeEnabled", meshIsAttributeEnabled},
			{"attachAttribute", meshAttachAttribute},
			{"detachAttribute", meshDetachAttribute},
			{"setVertexMap", meshSetVertexMap},
			{"getVertexMap", meshGetVertexMap},
			{"setTexture", meshSetTexture},
			{"getTexture", meshGetTexture},
			{"setDrawMode", meshSetDrawMode},
			{"getDrawMode", meshGetDrawMode},
			{"setDrawRange", meshSetDrawRange},
			{"getDrawRange", meshGetDrawRange},
			{"flush", meshFlush},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &MeshLoveType, functions, nullptr);
}

void LoveRuntime::registerSpriteBatchType()
{
	static const luaL_Reg functions[] = {
			{"add", spriteBatchAdd}, {"set", spriteBatchSet},
			{"addLayer", spriteBatchAddLayer}, {"setLayer", spriteBatchSetLayer},
			{"clear", spriteBatchClear}, {"flush", spriteBatchFlush},
			{"setTexture", spriteBatchSetTexture}, {"getTexture", spriteBatchGetTexture},
			{"setColor", spriteBatchSetColor}, {"getColor", spriteBatchGetColor},
			{"getCount", spriteBatchGetCount}, {"getBufferSize", spriteBatchGetBufferSize},
			{"attachAttribute", spriteBatchAttachAttribute},
			{"setDrawRange", spriteBatchSetDrawRange}, {"getDrawRange", spriteBatchGetDrawRange},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &SpriteBatchLoveType, functions, nullptr);
}

void LoveRuntime::registerParticleSystemType()
{
	static const luaL_Reg functions[] = {
			{"clone", particleSystemClone}, {"setTexture", particleSystemSetTexture},
			{"getTexture", particleSystemGetTexture}, {"setBufferSize", particleSystemSetBufferSize},
			{"getBufferSize", particleSystemGetBufferSize}, {"setInsertMode", particleSystemSetInsertMode},
			{"getInsertMode", particleSystemGetInsertMode}, {"setEmissionRate", particleSystemSetEmissionRate},
			{"getEmissionRate", particleSystemGetEmissionRate}, {"setEmitterLifetime", particleSystemSetEmitterLifetime},
			{"getEmitterLifetime", particleSystemGetEmitterLifetime}, {"setParticleLifetime", particleSystemSetParticleLifetime},
			{"getParticleLifetime", particleSystemGetParticleLifetime}, {"setPosition", particleSystemSetPosition},
			{"getPosition", particleSystemGetPosition}, {"moveTo", particleSystemMoveTo},
			{"setEmissionArea", particleSystemSetEmissionArea}, {"getEmissionArea", particleSystemGetEmissionArea},
			{"setAreaSpread", particleSystemSetAreaSpread}, {"getAreaSpread", particleSystemGetAreaSpread},
			{"setDirection", particleSystemSetDirection}, {"getDirection", particleSystemGetDirection},
			{"setSpread", particleSystemSetSpread}, {"getSpread", particleSystemGetSpread},
			{"setSpeed", particleSystemSetSpeed}, {"getSpeed", particleSystemGetSpeed},
			{"setLinearAcceleration", particleSystemSetLinearAcceleration},
			{"getLinearAcceleration", particleSystemGetLinearAcceleration},
			{"setRadialAcceleration", particleSystemSetRadialAcceleration},
			{"getRadialAcceleration", particleSystemGetRadialAcceleration},
			{"setTangentialAcceleration", particleSystemSetTangentialAcceleration},
			{"getTangentialAcceleration", particleSystemGetTangentialAcceleration},
			{"setLinearDamping", particleSystemSetLinearDamping},
			{"getLinearDamping", particleSystemGetLinearDamping},
			{"setSizes", particleSystemSetSizes}, {"getSizes", particleSystemGetSizes},
			{"setSizeVariation", particleSystemSetSizeVariation}, {"getSizeVariation", particleSystemGetSizeVariation},
			{"setRotation", particleSystemSetRotation}, {"getRotation", particleSystemGetRotation},
			{"setSpin", particleSystemSetSpin}, {"getSpin", particleSystemGetSpin},
			{"setSpinVariation", particleSystemSetSpinVariation}, {"getSpinVariation", particleSystemGetSpinVariation},
			{"setOffset", particleSystemSetOffset}, {"getOffset", particleSystemGetOffset},
			{"setColors", particleSystemSetColors}, {"getColors", particleSystemGetColors},
			{"setQuads", particleSystemSetQuads}, {"getQuads", particleSystemGetQuads},
			{"setRelativeRotation", particleSystemSetRelativeRotation},
			{"hasRelativeRotation", particleSystemHasRelativeRotation}, {"getCount", particleSystemGetCount},
			{"start", particleSystemStart}, {"stop", particleSystemStop}, {"pause", particleSystemPause},
			{"reset", particleSystemReset}, {"emit", particleSystemEmit},
			{"isActive", particleSystemIsActive}, {"isPaused", particleSystemIsPaused},
			{"isStopped", particleSystemIsStopped}, {"isEmpty", particleSystemIsEmpty},
			{"isFull", particleSystemIsFull}, {"update", particleSystemUpdate},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &ParticleSystemLoveType, functions, nullptr);
}

void LoveRuntime::registerTextType()
{
	static const luaL_Reg functions[] = {
			{"set", textSet}, {"setf", textSetf}, {"add", textAdd}, {"addf", textAddf},
			{"clear", textClear}, {"setFont", textSetFont}, {"getFont", textGetFont},
			{"getWidth", textGetWidth}, {"getHeight", textGetHeight},
			{"getDimensions", textGetDimensions},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &TextLoveType, functions, nullptr);
}

void LoveRuntime::registerShaderType()
{
	static const luaL_Reg functions[] = {
			{"getWarnings", shaderGetWarnings},
			{"getExternVariable", shaderHasUniform},
			{"hasUniform", shaderHasUniform},
			{"send", shaderSend},
			{"sendColor", shaderSendColor},
			{nullptr, nullptr},
		};
	::love::luax_register_type(_state, &ShaderUserdata::type, functions, nullptr);
}

void LoveRuntime::registerFontType()
{
	static const luaL_Reg functions[] = {
		{"getWidth", fontGetWidth}, {"getHeight", fontGetHeight},
		{"getBaseline", fontGetBaseline}, {"getWrap", fontGetWrap},
		{"getAscent", fontGetAscent}, {"getDescent", fontGetDescent},
		{"hasGlyphs", fontHasGlyphs}, {"getKerning", fontGetKerning},
		{"setFallbacks", fontSetFallbacks}, {"setLineHeight", fontSetLineHeight},
		{"getLineHeight", fontGetLineHeight}, {"setFilter", fontSetFilter},
		{"getFilter", fontGetFilter}, {"getDPIScale", fontGetDPIScale},
		{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &FontUserdata::type, functions, nullptr);
	::love::luax_gettypemetatable(_state, FontUserdata::type);
	lua_pushcfunction(_state, fontEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerAudioSourceType()
{
	static const luaL_Reg sourceFunctions[] = {
			{"clone", audioSourceClone},
			{"play", audioSourcePlay},
			{"pause", audioSourcePause},
			{"stop", audioSourceStop},
			{"isPlaying", audioSourceIsPlaying},
			{"isStopped", audioSourceIsStopped},
			{"isPaused", audioSourceIsPaused},
			{"setLooping", audioSourceSetLooping},
			{"isLooping", audioSourceIsLooping},
			{"setVolume", audioSourceSetVolume},
			{"getVolume", audioSourceGetVolume},
			{"setPitch", audioSourceSetPitch},
			{"getPitch", audioSourceGetPitch},
			{"seek", audioSourceSeek},
			{"tell", audioSourceTell},
			{"getDuration", audioSourceGetDuration},
			{"getChannelCount", audioSourceGetChannelCount},
			{"getChannels", audioSourceGetChannelCount},
			{"getFreeBufferCount", audioSourceGetFreeBufferCount},
			{"queue", audioSourceQueue},
			{"setPosition", audioSourceSetPosition},
			{"getPosition", audioSourceGetPosition},
			{"setVelocity", audioSourceSetVelocity},
			{"getVelocity", audioSourceGetVelocity},
			{"setDirection", audioSourceSetDirection},
			{"getDirection", audioSourceGetDirection},
			{"setCone", audioSourceSetCone},
			{"getCone", audioSourceGetCone},
			{"setAirAbsorption", audioSourceSetAirAbsorption},
			{"getAirAbsorption", audioSourceGetAirAbsorption},
			{"setVolumeLimits", audioSourceSetVolumeLimits},
			{"getVolumeLimits", audioSourceGetVolumeLimits},
			{"setRelative", audioSourceSetRelative},
			{"isRelative", audioSourceIsRelative},
			{"setAttenuationDistances", audioSourceSetAttenuationDistances},
			{"getAttenuationDistances", audioSourceGetAttenuationDistances},
			{"setRolloff", audioSourceSetRolloff},
			{"getRolloff", audioSourceGetRolloff},
			{"setFilter", audioSourceSetFilter},
			{"getFilter", audioSourceGetFilter},
			{"setEffect", audioSourceSetEffect},
			{"getEffect", audioSourceGetEffect},
			{"getActiveEffects", audioSourceGetActiveEffects},
			{"getType", audioSourceGetType},
			{nullptr, nullptr},
		};
	::love::luax_register_type(_state, &AudioSourceUserdata::type, sourceFunctions, nullptr);
	::love::luax_gettypemetatable(_state, AudioSourceUserdata::type);
	lua_pushcfunction(_state, audioSourceEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerVideoTypes()
{
	static const luaL_Reg streamFunctions[] = {
			{"play", videoStreamPlay}, {"pause", videoStreamPause},
			{"seek", videoStreamSeek}, {"rewind", videoStreamRewind},
			{"tell", videoStreamTell}, {"isPlaying", videoStreamIsPlaying},
			{"getFilename", videoStreamGetFilename}, {"setSync", videoStreamSetSync},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &VideoStreamLoveType, streamFunctions, nullptr);

	static const luaL_Reg videoFunctions[] = {
			{"getStream", videoGetStream}, {"getSource", videoGetSource},
			{"setSource", videoSetSource}, {"getWidth", videoGetWidth},
			{"getHeight", videoGetHeight}, {"getDimensions", videoGetDimensions},
			{"getPixelWidth", videoGetWidth}, {"getPixelHeight", videoGetHeight},
			{"getPixelDimensions", videoGetDimensions},
			{"setFilter", videoSetFilter}, {"getFilter", videoGetFilter},
			{nullptr, nullptr},
		};
	::love::luax_register_type(_state, &VideoUserdata::type, videoFunctions, nullptr);
}

void LoveRuntime::registerRecordingDeviceType()
{
	static const luaL_Reg functions[] = {
			{"start", recordingDeviceStart},
			{"stop", recordingDeviceStop},
			{"getData", recordingDeviceGetData},
			{"getSampleCount", recordingDeviceGetSampleCount},
			{"getSampleRate", recordingDeviceGetSampleRate},
			{"getBitDepth", recordingDeviceGetBitDepth},
			{"getChannelCount", recordingDeviceGetChannelCount},
			{"getName", recordingDeviceGetName},
			{"isRecording", recordingDeviceIsRecording},
			{nullptr, nullptr},
		};
	::love::luax_register_type(_state, &RecordingDeviceUserdata::type, functions, nullptr);
	::love::luax_gettypemetatable(_state, RecordingDeviceUserdata::type);
	lua_pushcfunction(_state, recordingDeviceEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerJoystickType()
{
	static const luaL_Reg joystickFunctions[] = {
			{"isConnected", joystickIsConnected},
			{"getName", joystickGetName},
			{"getID", joystickGetID},
			{"getGUID", joystickGetGUID},
			{"getDeviceInfo", joystickGetDeviceInfo},
			{"getAxisCount", joystickGetAxisCount},
			{"getButtonCount", joystickGetButtonCount},
			{"getHatCount", joystickGetHatCount},
			{"getAxis", joystickGetAxis},
			{"getAxes", joystickGetAxes},
			{"getHat", joystickGetHat},
			{"isDown", joystickIsDown},
			{"isGamepad", joystickIsGamepad},
			{"isGamepadDown", joystickIsGamepadDown},
			{"getGamepadAxis", joystickGetGamepadAxis},
			{"getGamepadMapping", joystickGetGamepadMapping},
			{"getGamepadMappingString", joystickGetOwnGamepadMappingString},
			{"isVibrationSupported", joystickIsVibrationSupported},
			{"setVibration", joystickSetVibration},
			{"getVibration", joystickGetVibration},
			{"getConnectedIndex", joystickGetConnectedIndex},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &JoystickLoveType, joystickFunctions, nullptr);
	::love::luax_gettypemetatable(_state, JoystickLoveType);
	lua_pushcfunction(_state, joystickEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerCursorType()
{
	static const luaL_Reg functions[] = {
		{"getType", cursorGetType}, {nullptr, nullptr},
	};
	::love::luax_register_type(_state, &CursorUserdata::type, functions, nullptr);
	::love::luax_gettypemetatable(_state, CursorUserdata::type);
	lua_pushcfunction(_state, cursorEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerFileType()
{
	static const luaL_Reg functions[] = {
			{"open", fileOpen}, {"close", fileClose}, {"isOpen", fileIsOpen},
			{"getSize", fileGetSize}, {"read", fileRead}, {"write", fileWrite},
			{"flush", fileFlush}, {"isEOF", fileIsEOF}, {"tell", fileTell},
			{"seek", fileSeek}, {"lines", fileLines}, {"setBuffer", fileSetBuffer},
			{"getBuffer", fileGetBuffer}, {"getMode", fileGetMode},
			{"getFilename", fileGetFilename}, {"getExtension", fileGetExtension},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &FileLoveType, functions, nullptr);
}

void LoveRuntime::registerFileDataType()
{
	static const luaL_Reg functions[] = {
		{"clone", fileDataClone}, {"getFilename", fileDataGetFilename},
		{"getExtension", fileDataGetExtension}, {"getString", dataGetString},
		{"getSize", dataGetSize}, {"getPointer", dataGetPointer},
		{"getFFIPointer", dataGetFFIPointer}, {nullptr, nullptr},
	};
	::love::luax_register_type(_state, &FileDataUserdata::type, functions, nullptr);
}

void LoveRuntime::registerThreadTypes()
{
	static const luaL_Reg threadFunctions[] = {
			{"start", threadObjectStart}, {"wait", threadObjectWait},
			{"getError", threadObjectGetError}, {"isRunning", threadObjectIsRunning},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &ThreadLoveType, threadFunctions, nullptr);
	::love::luax_gettypemetatable(_state, ThreadLoveType);
	lua_pushcfunction(_state, threadObjectEqual); lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);

	static const luaL_Reg channelFunctions[] = {
			{"push", channelPush}, {"supply", channelSupply},
			{"pop", channelPop}, {"demand", channelDemand}, {"peek", channelPeek},
			{"getCount", channelGetCount}, {"hasRead", channelHasRead},
			{"clear", channelClear}, {"performAtomic", channelPerformAtomic},
			{nullptr, nullptr},
	};
	::love::luax_register_type(_state, &ChannelLoveType, channelFunctions, nullptr);
	::love::luax_gettypemetatable(_state, ChannelLoveType);
	lua_pushcfunction(_state, channelEqual); lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerPhysicsTypes()
{
	const auto registerType = [this](::love::Type *type,
		std::initializer_list<std::pair<const char *, lua_CFunction>> methods)
	{
		std::vector<luaL_Reg> functions;
		functions.reserve(methods.size() + 1);
		for (const auto &[name, function] : methods) functions.push_back({name, function});
		functions.push_back({nullptr, nullptr});
		::love::luax_register_type(_state, type, functions.data(), nullptr);
	};
	registerType(&PhysicsWorldLoveType, {
		{"destroy", physicsWorldDestroy}, {"isDestroyed", physicsWorldIsDestroyed},
		{"update", physicsWorldUpdate}, {"setGravity", physicsWorldSetGravity},
		{"getGravity", physicsWorldGetGravity},
		{"setSleepingAllowed", physicsWorldSetSleepingAllowed},
		{"isSleepingAllowed", physicsWorldIsSleepingAllowed},
		{"queryBoundingBox", physicsWorldQueryBoundingBox}, {"rayCast", physicsWorldRayCast},
		{"setCallbacks", physicsWorldSetCallbacks}, {"getCallbacks", physicsWorldGetCallbacks},
	});
	registerType(&PhysicsBodyLoveType, {
		{"destroy", physicsBodyDestroy}, {"isDestroyed", physicsBodyIsDestroyed},
		{"getPosition", physicsBodyGetPosition}, {"setPosition", physicsBodySetPosition},
		{"getX", physicsBodyGetX}, {"setX", physicsBodySetX},
		{"getY", physicsBodyGetY}, {"setY", physicsBodySetY},
		{"getTransform", physicsBodyGetTransform}, {"setTransform", physicsBodySetTransform},
		{"getAngle", physicsBodyGetAngle}, {"setAngle", physicsBodySetAngle},
		{"getLinearVelocity", physicsBodyGetLinearVelocity},
		{"setLinearVelocity", physicsBodySetLinearVelocity},
		{"getAngularVelocity", physicsBodyGetAngularVelocity},
		{"setAngularVelocity", physicsBodySetAngularVelocity},
		{"getLinearDamping", physicsBodyGetLinearDamping},
		{"setLinearDamping", physicsBodySetLinearDamping},
		{"getAngularDamping", physicsBodyGetAngularDamping},
		{"setAngularDamping", physicsBodySetAngularDamping},
		{"getMass", physicsBodyGetMass}, {"setMass", physicsBodySetMass},
		{"getInertia", physicsBodyGetInertia}, {"setInertia", physicsBodySetInertia},
		{"getMassData", physicsBodyGetMassData}, {"setMassData", physicsBodySetMassData},
		{"resetMassData", physicsBodyResetMassData},
		{"getGravityScale", physicsBodyGetGravityScale},
		{"setGravityScale", physicsBodySetGravityScale},
		{"getLocalCenter", physicsBodyGetLocalCenter}, {"getWorldCenter", physicsBodyGetWorldCenter},
		{"isFixedRotation", physicsBodyIsFixedRotation},
		{"setFixedRotation", physicsBodySetFixedRotation},
		{"isAwake", physicsBodyIsAwake}, {"setAwake", physicsBodySetAwake},
		{"isSleepingAllowed", physicsBodyIsSleepingAllowed},
		{"setSleepingAllowed", physicsBodySetSleepingAllowed},
		{"isActive", physicsBodyIsActive}, {"setActive", physicsBodySetActive},
		{"isBullet", physicsBodyIsBullet}, {"setBullet", physicsBodySetBullet},
		{"applyLinearImpulse", physicsBodyApplyLinearImpulse},
		{"applyAngularImpulse", physicsBodyApplyAngularImpulse},
		{"applyForce", physicsBodyApplyForce}, {"applyTorque", physicsBodyApplyTorque},
		{"getType", physicsBodyGetType}, {"setType", physicsBodySetType},
		{"getWorldPoint", physicsBodyGetWorldPoint}, {"getWorldVector", physicsBodyGetWorldVector},
		{"getWorldPoints", physicsBodyGetWorldPoints},
		{"getLocalPoint", physicsBodyGetLocalPoint}, {"getLocalVector", physicsBodyGetLocalVector},
		{"getLocalPoints", physicsBodyGetLocalPoints},
		{"getLinearVelocityFromWorldPoint", physicsBodyGetLinearVelocityFromWorldPoint},
		{"getLinearVelocityFromLocalPoint", physicsBodyGetLinearVelocityFromLocalPoint},
	});
	registerType(&PhysicsShapeLoveType, {
		{"getType", physicsShapeGetType}, {"getRadius", physicsShapeGetRadius},
		{"getPoints", physicsShapeGetPoints}, {"validate", physicsShapeValidate},
		{"getVertexCount", physicsShapeGetVertexCount}, {"getPoint", physicsShapeGetPoint},
		{"getChildEdge", physicsShapeGetChildEdge},
		{"getPreviousVertex", physicsShapeGetPreviousVertex},
		{"getNextVertex", physicsShapeGetNextVertex},
		{"setPreviousVertex", physicsShapeSetPreviousVertex},
		{"setNextVertex", physicsShapeSetNextVertex},
	});
	registerType(&PhysicsFixtureLoveType, {
		{"destroy", physicsFixtureDestroy}, {"isDestroyed", physicsFixtureIsDestroyed},
		{"getType", physicsFixtureGetType},
		{"setFriction", physicsFixtureSetFriction}, {"getFriction", physicsFixtureGetFriction},
		{"setRestitution", physicsFixtureSetRestitution}, {"getRestitution", physicsFixtureGetRestitution},
		{"setSensor", physicsFixtureSetSensor}, {"isSensor", physicsFixtureIsSensor},
		{"setDensity", physicsFixtureSetDensity}, {"getDensity", physicsFixtureGetDensity},
		{"getBody", physicsFixtureGetBody}, {"getShape", physicsFixtureGetShape},
		{"testPoint", physicsFixtureTestPoint}, {"rayCast", physicsFixtureRayCast},
		{"setFilterData", physicsFixtureSetFilterData}, {"getFilterData", physicsFixtureGetFilterData},
		{"setCategory", physicsFixtureSetCategory}, {"getCategory", physicsFixtureGetCategory},
		{"setMask", physicsFixtureSetMask}, {"getMask", physicsFixtureGetMask},
		{"setUserData", physicsFixtureSetUserData}, {"getUserData", physicsFixtureGetUserData},
		{"getBoundingBox", physicsFixtureGetBoundingBox}, {"getMassData", physicsFixtureGetMassData},
		{"getGroupIndex", physicsFixtureGetGroupIndex}, {"setGroupIndex", physicsFixtureSetGroupIndex},
	});
	registerType(&PhysicsJointLoveType, {
		{"destroy", physicsJointDestroy}, {"isDestroyed", physicsJointIsDestroyed},
		{"getType", physicsJointGetType}, {"getBodies", physicsJointGetBodies},
		{"getAnchors", physicsJointGetAnchors}, {"getReactionForce", physicsJointGetReactionForce},
		{"getReactionTorque", physicsJointGetReactionTorque},
		{"getCollideConnected", physicsJointGetCollideConnected},
		{"setUserData", physicsJointSetUserData}, {"getUserData", physicsJointGetUserData},
		{"getLength", physicsDistanceJointGetLength}, {"setLength", physicsDistanceJointSetLength},
		{"getFrequency", physicsDistanceJointGetFrequency},
		{"setFrequency", physicsDistanceJointSetFrequency},
		{"getDampingRatio", physicsDistanceJointGetDampingRatio},
		{"setDampingRatio", physicsDistanceJointSetDampingRatio},
		{"getJointAngle", physicsRevoluteJointGetJointAngle},
		{"getJointSpeed", physicsRevoluteJointGetJointSpeed},
		{"setMotorEnabled", physicsRevoluteJointSetMotorEnabled},
		{"isMotorEnabled", physicsRevoluteJointIsMotorEnabled},
		{"setMaxMotorTorque", physicsRevoluteJointSetMaxMotorTorque},
		{"getMaxMotorTorque", physicsRevoluteJointGetMaxMotorTorque},
		{"setMotorSpeed", physicsRevoluteJointSetMotorSpeed},
		{"getMotorSpeed", physicsRevoluteJointGetMotorSpeed},
		{"getMotorTorque", physicsRevoluteJointGetMotorTorque},
		{"setLimitsEnabled", physicsRevoluteJointSetLimitsEnabled},
		{"areLimitsEnabled", physicsRevoluteJointAreLimitsEnabled},
		{"hasLimitsEnabled", physicsRevoluteJointAreLimitsEnabled},
		{"setUpperLimit", physicsRevoluteJointSetUpperLimit},
		{"setLowerLimit", physicsRevoluteJointSetLowerLimit},
		{"setLimits", physicsRevoluteJointSetLimits},
		{"getUpperLimit", physicsRevoluteJointGetUpperLimit},
		{"getLowerLimit", physicsRevoluteJointGetLowerLimit},
		{"getLimits", physicsRevoluteJointGetLimits},
		{"getReferenceAngle", physicsRevoluteJointGetReferenceAngle},
		{"getJointTranslation", physicsPrismaticJointGetJointTranslation},
		{"setMaxMotorForce", physicsPrismaticJointSetMaxMotorForce},
		{"getMaxMotorForce", physicsPrismaticJointGetMaxMotorForce},
		{"getMotorForce", physicsPrismaticJointGetMotorForce},
		{"getAxis", physicsPrismaticJointGetAxis},
		{"setMaxForce", physicsFrictionJointSetMaxForce},
		{"getMaxForce", physicsFrictionJointGetMaxForce},
		{"setMaxTorque", physicsFrictionJointSetMaxTorque},
		{"getMaxTorque", physicsFrictionJointGetMaxTorque},
		{"getMaxLength", physicsRopeJointGetMaxLength},
		{"setMaxLength", physicsRopeJointSetMaxLength},
		{"getGroundAnchors", physicsPulleyJointGetGroundAnchors},
		{"getLengthA", physicsPulleyJointGetLengthA},
		{"getLengthB", physicsPulleyJointGetLengthB},
		{"getRatio", physicsPulleyJointGetRatio},
		{"setSpringFrequency", physicsWheelJointSetSpringFrequency},
		{"getSpringFrequency", physicsWheelJointGetSpringFrequency},
		{"setSpringDampingRatio", physicsWheelJointSetSpringDampingRatio},
		{"getSpringDampingRatio", physicsWheelJointGetSpringDampingRatio},
		{"setTarget", physicsMouseJointSetTarget},
		{"getTarget", physicsMouseJointGetTarget},
		{"setLinearOffset", physicsMotorJointSetLinearOffset},
		{"getLinearOffset", physicsMotorJointGetLinearOffset},
		{"setAngularOffset", physicsMotorJointSetAngularOffset},
		{"getAngularOffset", physicsMotorJointGetAngularOffset},
		{"setCorrectionFactor", physicsMotorJointSetCorrectionFactor},
		{"getCorrectionFactor", physicsMotorJointGetCorrectionFactor},
		{"setRatio", physicsGearJointSetRatio},
		{"getJoints", physicsGearJointGetJoints},
	});
	registerType(&PhysicsContactLoveType, {
		{"isValid", physicsContactIsValid}, {"getFixtures", physicsContactGetFixtures},
		{"getChildren", physicsContactGetChildren}, {"getPositions", physicsContactGetPositions},
		{"getNormal", physicsContactGetNormal},
		{"getFriction", physicsContactGetFriction}, {"setFriction", physicsContactSetFriction},
		{"resetFriction", physicsContactResetFriction},
		{"getRestitution", physicsContactGetRestitution},
		{"setRestitution", physicsContactSetRestitution},
		{"resetRestitution", physicsContactResetRestitution},
		{"isEnabled", physicsContactIsEnabled}, {"setEnabled", physicsContactSetEnabled},
		{"isTouching", physicsContactIsTouching},
		{"getTangentSpeed", physicsContactGetTangentSpeed},
		{"setTangentSpeed", physicsContactSetTangentSpeed},
	});
	struct PhysicsTypeOverride {
		::love::Type *type;
		lua_CFunction typeFunction;
		lua_CFunction typeOfFunction;
	};
	for (const auto &[type, typeFunction, typeOfFunction] : {
		PhysicsTypeOverride{&PhysicsShapeLoveType, physicsShapeObjectType, physicsShapeObjectTypeOf},
		PhysicsTypeOverride{&PhysicsJointLoveType, physicsJointObjectType, physicsJointObjectTypeOf},
	})
	{
		::love::luax_gettypemetatable(_state, *type);
		lua_pushcfunction(_state, typeFunction); lua_setfield(_state, -2, "type");
		lua_pushcfunction(_state, typeOfFunction); lua_setfield(_state, -2, "typeOf");
		lua_pop(_state, 1);
	}
}

void LoveRuntime::resetGraphicsTransform() noexcept
{
	_graphicsTransform = {};
}

void LoveRuntime::multiplyGraphicsTransform(float a, float b, float c, float d, float tx, float ty) noexcept
{
	const GraphicsTransform current = _graphicsTransform;
	_graphicsTransform.a = current.a * a + current.c * b;
	_graphicsTransform.b = current.b * a + current.d * b;
	_graphicsTransform.c = current.a * c + current.c * d;
	_graphicsTransform.d = current.b * c + current.d * d;
	_graphicsTransform.tx = current.a * tx + current.c * ty + current.tx;
	_graphicsTransform.ty = current.b * tx + current.d * ty + current.ty;
}

std::vector<float> LoveRuntime::transformGraphicsPoints(const std::vector<float> &points) const
{
	std::vector<float> transformed;
	transformed.reserve(points.size());
	for (std::size_t i = 0; i < points.size(); i += 2)
	{
		const float x = points[i];
		const float y = points[i + 1];
		transformed.push_back(_graphicsTransform.a * x + _graphicsTransform.c * y + _graphicsTransform.tx);
		transformed.push_back(_graphicsTransform.b * x + _graphicsTransform.d * y + _graphicsTransform.ty);
	}
	return transformed;
}

bool LoveRuntime::isGraphicsTransformIdentity() const noexcept
{
	return _graphicsTransform.a == 1.0f && _graphicsTransform.b == 0.0f
		&& _graphicsTransform.c == 0.0f && _graphicsTransform.d == 1.0f
		&& _graphicsTransform.tx == 0.0f && _graphicsTransform.ty == 0.0f
		&& _graphicsTransform.pixelScale == 1.0f;
}

void LoveRuntime::registerLoveModule()
{
	lua_newtable(_state);
	lua_pushliteral(_state, "11.5");
	lua_setfield(_state, -2, "_version");
	lua_pushinteger(_state, 11);
	lua_setfield(_state, -2, "_version_major");
	lua_pushinteger(_state, 5);
	lua_setfield(_state, -2, "_version_minor");
	lua_pushinteger(_state, 0);
	lua_setfield(_state, -2, "_version_revision");
	lua_pushcfunction(_state, loveRun);
	lua_setfield(_state, -2, "run");
	lua_pushcfunction(_state, loveGetVersion);
	lua_setfield(_state, -2, "getVersion");

	lua_newtable(_state);
	static constexpr std::array<const char *, 31> HandlerNames = {
		"directorydropped", "displayrotated", "filedropped", "focus", "gamepadaxis",
		"gamepadpressed", "gamepadreleased", "joystickadded", "joystickaxis",
		"joystickhat", "joystickpressed", "joystickreleased", "joystickremoved",
		"keypressed", "keyreleased", "lowmemory", "mousefocus", "mousemoved",
		"mousepressed", "mousereleased", "quit", "resize", "textedited", "textinput",
		"threaderror", "touchmoved", "touchpressed", "touchreleased", "visible",
		"wheelmoved", "localechanged"};
	for (const auto *name : HandlerNames)
	{
		lua_pushstring(_state, name);
		lua_pushcclosure(_state, loveHandler, 1);
		lua_setfield(_state, -2, name);
	}
	lua_setfield(_state, -2, "handlers");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} graphicsFunctions[] = {
		{"clear", graphicsClear},
		{"discard", graphicsDiscard},
		{"flushBatch", graphicsFlushBatch},
		{"setBackgroundColor", graphicsSetBackgroundColor},
		{"getBackgroundColor", graphicsGetBackgroundColor},
		{"setDefaultFilter", graphicsSetDefaultFilter},
		{"getDefaultFilter", graphicsGetDefaultFilter},
		{"setDefaultMipmapFilter", graphicsSetDefaultMipmapFilter},
		{"getDefaultMipmapFilter", graphicsGetDefaultMipmapFilter},
		{"setColor", graphicsSetColor},
		{"getColor", graphicsGetColor},
		{"setLineWidth", graphicsSetLineWidth},
		{"getLineWidth", graphicsGetLineWidth},
		{"setLineStyle", graphicsSetLineStyle},
		{"getLineStyle", graphicsGetLineStyle},
		{"setLineJoin", graphicsSetLineJoin},
		{"getLineJoin", graphicsGetLineJoin},
		{"setWireframe", graphicsSetWireframe},
		{"isWireframe", graphicsIsWireframe},
		{"setPointSize", graphicsSetPointSize},
		{"getPointSize", graphicsGetPointSize},
		{"getDimensions", graphicsGetDimensions},
		{"getWidth", graphicsGetWidth},
		{"getHeight", graphicsGetHeight},
		{"getPixelDimensions", graphicsGetPixelDimensions},
		{"getPixelWidth", graphicsGetPixelWidth},
		{"getPixelHeight", graphicsGetPixelHeight},
		{"getDPIScale", graphicsGetDPIScale},
		{"getSupported", graphicsGetSupported},
		{"getTextureTypes", graphicsGetTextureTypes},
		{"getImageFormats", graphicsGetImageFormats},
		{"getRendererInfo", graphicsGetRendererInfo},
		{"getSystemLimits", graphicsGetSystemLimits},
		{"getStats", graphicsGetStats},
		{"captureScreenshot", graphicsCaptureScreenshot},
		{"rectangle", graphicsRectangle},
		{"circle", graphicsCircle},
		{"arc", graphicsArc},
		{"line", graphicsLine},
		{"ellipse", graphicsEllipse},
		{"polygon", graphicsPolygon},
		{"points", graphicsPoints},
		{"present", graphicsPresent},
		{"push", graphicsPush},
		{"pop", graphicsPop},
		{"getStackDepth", graphicsGetStackDepth},
		{"origin", graphicsOrigin},
		{"translate", graphicsTranslate},
		{"rotate", graphicsRotate},
		{"scale", graphicsScale},
		{"shear", graphicsShear},
		{"applyTransform", graphicsApplyTransform},
		{"replaceTransform", graphicsReplaceTransform},
		{"transformPoint", graphicsTransformPoint},
		{"inverseTransformPoint", graphicsInverseTransformPoint},
		{"isActive", graphicsIsActive},
		{"isCreated", graphicsIsCreated},
		{"isGammaCorrect", graphicsIsGammaCorrect},
		{"reset", graphicsReset},
		{"newImage", graphicsNewImage},
		{"newVideo", graphicsNewVideo},
		{"_newVideo", graphicsNewVideo},
		{"newArrayImage", graphicsNewArrayImage},
		{"newCubeImage", graphicsNewCubeImage},
		{"newVolumeImage", graphicsNewVolumeImage},
		{"newCanvas", graphicsNewCanvas},
		{"getCanvasFormats", graphicsGetCanvasFormats},
		{"setCanvas", graphicsSetCanvas},
		{"getCanvas", graphicsGetCanvas},
		{"newQuad", graphicsNewQuad},
		{"newMesh", graphicsNewMesh},
		{"newSpriteBatch", graphicsNewSpriteBatch},
		{"newParticleSystem", graphicsNewParticleSystem},
		{"newText", graphicsNewText},
		{"newShader", graphicsNewShader},
		{"validateShader", graphicsValidateShader},
		{"setShader", graphicsSetShader},
		{"getShader", graphicsGetShader},
		{"draw", graphicsDraw},
		{"drawLayer", graphicsDrawLayer},
		{"newFont", graphicsNewFont},
		{"setNewFont", graphicsSetNewFont},
		{"newImageFont", graphicsNewImageFont},
		{"setFont", graphicsSetFont},
		{"getFont", graphicsGetFont},
		{"print", graphicsPrint},
		{"printf", graphicsPrintf},
		{"setBlendMode", graphicsSetBlendMode},
		{"getBlendMode", graphicsGetBlendMode},
		{"setScissor", graphicsSetScissor},
		{"getScissor", graphicsGetScissor},
		{"intersectScissor", graphicsIntersectScissor},
		{"setColorMask", graphicsSetColorMask},
		{"getColorMask", graphicsGetColorMask},
		{"setDepthMode", graphicsSetDepthMode},
		{"getDepthMode", graphicsGetDepthMode},
		{"setMeshCullMode", graphicsSetMeshCullMode},
		{"getMeshCullMode", graphicsGetMeshCullMode},
		{"setFrontFaceWinding", graphicsSetFrontFaceWinding},
		{"getFrontFaceWinding", graphicsGetFrontFaceWinding},
		{"stencil", graphicsStencil},
		{"setStencilTest", graphicsSetStencilTest},
		{"getStencilTest", graphicsGetStencilTest},
	};
	for (const auto &entry : graphicsFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_pushlightuserdata(_state, this);
	lua_pushboolean(_state, true);
	lua_pushcclosure(_state, graphicsDraw, 2);
	lua_setfield(_state, -2, "drawInstanced");
	lua_setfield(_state, -2, "graphics");

	lua_newtable(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, imageNewImageData, 1);
	lua_setfield(_state, -2, "newImageData");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, imageNewCompressedData, 1);
	lua_setfield(_state, -2, "newCompressedData");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, imageIsCompressed, 1);
	lua_setfield(_state, -2, "isCompressed");
	lua_setfield(_state, -2, "image");

	lua_newtable(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, fontNewImageRasterizer, 1);
	lua_setfield(_state, -2, "newImageRasterizer");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, fontNewTrueTypeRasterizer, 1);
	lua_setfield(_state, -2, "newTrueTypeRasterizer");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, fontNewBMFontRasterizer, 1);
	lua_setfield(_state, -2, "newBMFontRasterizer");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, fontNewRasterizer, 1);
	lua_setfield(_state, -2, "newRasterizer");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, fontNewGlyphData, 1);
	lua_setfield(_state, -2, "newGlyphData");
	lua_setfield(_state, -2, "font");

	lua_newtable(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, soundNewDecoder, 1);
	lua_setfield(_state, -2, "newDecoder");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, soundNewSoundData, 1);
	lua_setfield(_state, -2, "newSoundData");
	lua_setfield(_state, -2, "sound");

	lua_newtable(_state);
	const struct { const char *name; lua_CFunction function; } dataFunctions[] = {
		{"newByteData", dataNewByteData}, {"newDataView", dataNewDataView},
		{"encode", dataEncode}, {"decode", dataDecode},
		{"compress", dataCompress}, {"decompress", dataDecompress},
		{"pack", dataPack}, {"unpack", dataUnpack},
		{"getPackedSize", dataGetPackedSize}, {"hash", dataHash},
	};
	for (const auto &entry : dataFunctions)
	{
		lua_pushcfunction(_state, entry.function);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "data");

	lua_newtable(_state);
	const std::uint64_t initialMathSeed = static_cast<std::uint64_t>(
		std::chrono::high_resolution_clock::now().time_since_epoch().count());
	pushRandomGenerator(_state, initialMathSeed);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} statefulMathFunctions[] = {
		{"_getRandomGenerator", mathGetRandomGenerator},
		{"random", mathRandom},
		{"randomNormal", mathRandomNormal},
		{"setRandomSeed", mathSetRandomSeed},
		{"getRandomSeed", mathGetRandomSeed},
		{"setRandomState", mathSetRandomState},
		{"getRandomState", mathGetRandomState},
	};
	for (const auto &entry : statefulMathFunctions)
	{
		lua_pushvalue(_state, -1);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -3, entry.name);
	}
	lua_pop(_state, 1);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} mathFunctions[] = {
		{"newRandomGenerator", mathNewRandomGenerator},
		{"newTransform", mathNewTransform},
		{"newBezierCurve", mathNewBezierCurve},
		{"noise", mathNoise},
		{"colorToBytes", mathColorToBytes},
		{"colorFromBytes", mathColorFromBytes},
		{"gammaToLinear", mathGammaToLinear},
		{"linearToGamma", mathLinearToGamma},
		{"isConvex", mathIsConvex},
		{"triangulate", mathTriangulate},
		{"compress", dataCompress},
		{"decompress", dataDecompress},
	};
	for (const auto &entry : mathFunctions)
	{
		lua_pushcfunction(_state, entry.function);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "math");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} windowFunctions[] = {
		{"getDesktopDimensions", windowGetDesktopDimensions},
		{"getDisplayCount", windowGetDisplayCount},
		{"getDisplayName", windowGetDisplayName},
		{"getDisplayOrientation", windowGetDisplayOrientation},
		{"getFullscreenModes", windowGetFullscreenModes},
		{"setFullscreen", windowSetFullscreen},
		{"getFullscreen", windowGetFullscreen},
		{"isOpen", windowIsOpen},
		{"getIcon", windowGetIcon},
		{"setIcon", windowSetIcon},
		{"getMode", windowGetMode},
		{"setMode", windowSetMode},
		{"updateMode", windowUpdateMode},
		{"getPosition", windowGetPosition},
		{"getSafeArea", windowGetSafeArea},
		{"setTitle", windowSetTitle},
		{"getTitle", windowGetTitle},
		{"setVSync", windowSetVSync},
		{"getVSync", windowGetVSync},
		{"setDisplaySleepEnabled", windowSetDisplaySleepEnabled},
		{"isDisplaySleepEnabled", windowIsDisplaySleepEnabled},
		{"hasFocus", windowHasFocus},
		{"hasMouseFocus", windowHasMouseFocus},
		{"isVisible", windowIsVisible},
		{"isMaximized", windowIsMaximized},
		{"isMinimized", windowIsMinimized},
		{"getDPIScale", windowGetDPIScale},
		{"getNativeDPIScale", windowGetNativeDPIScale},
		{"toPixels", windowToPixels},
		{"fromPixels", windowFromPixels},
	};
	for (const auto &entry : windowFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "window");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} eventFunctions[] = {
		{"pump", eventPump},
		{"poll", eventPoll},
		{"wait", eventWait},
		{"push", eventPush},
		{"clear", eventClear},
		{"quit", eventQuit},
	};
	for (const auto &entry : eventFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "event");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} filesystemFunctions[] = {
		{"setIdentity", filesystemSetIdentity},
		{"getIdentity", filesystemGetIdentity},
		{"getSource", filesystemGetSource},
		{"getSaveDirectory", filesystemGetSaveDirectory},
		{"getWorkingDirectory", filesystemGetWorkingDirectory},
		{"getUserDirectory", filesystemGetUserDirectory},
		{"getAppdataDirectory", filesystemGetAppdataDirectory},
		{"getSourceBaseDirectory", filesystemGetSourceBaseDirectory},
		{"getExecutablePath", filesystemGetExecutablePath},
		{"getRealDirectory", filesystemGetRealDirectory},
		{"getRequirePath", filesystemGetRequirePath},
		{"setRequirePath", filesystemSetRequirePath},
		{"mount", filesystemMount},
		{"unmount", filesystemUnmount},
		{"isFused", filesystemIsFused},
		{"newFile", filesystemNewFile},
		{"newFileData", filesystemNewFileData},
		{"read", filesystemRead},
		{"load", filesystemLoad},
		{"lines", filesystemLines},
		{"write", filesystemWrite},
		{"append", filesystemAppend},
		{"getInfo", filesystemGetInfo},
		{"exists", filesystemExists},
		{"isDirectory", filesystemIsDirectory},
		{"isFile", filesystemIsFile},
		{"isSymlink", filesystemIsSymlink},
		{"getLastModified", filesystemGetLastModified},
		{"getSize", filesystemGetSize},
		{"createDirectory", filesystemCreateDirectory},
		{"remove", filesystemRemove},
		{"getDirectoryItems", filesystemGetDirectoryItems},
	};
	for (const auto &entry : filesystemFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "filesystem");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} keyboardFunctions[] = {
		{"setKeyRepeat", keyboardSetKeyRepeat},
		{"hasKeyRepeat", keyboardHasKeyRepeat},
		{"isDown", keyboardIsDown},
		{"isScancodeDown", keyboardIsScancodeDown},
		{"getScancodeFromKey", keyboardGetScancodeFromKey},
		{"getKeyFromScancode", keyboardGetKeyFromScancode},
		{"setTextInput", keyboardSetTextInput},
		{"hasTextInput", keyboardHasTextInput},
		{"hasScreenKeyboard", keyboardHasScreenKeyboard},
	};
	for (const auto &entry : keyboardFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "keyboard");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} mouseFunctions[] = {
		{"getPosition", mouseGetPosition},
		{"getX", mouseGetX},
		{"getY", mouseGetY},
		{"setPosition", mouseSetPosition},
		{"setX", mouseSetX},
		{"setY", mouseSetY},
		{"isDown", mouseIsDown},
		{"setVisible", mouseSetVisible},
		{"isVisible", mouseIsVisible},
		{"setGrabbed", mouseSetGrabbed},
		{"isGrabbed", mouseIsGrabbed},
		{"setRelativeMode", mouseSetRelativeMode},
		{"getRelativeMode", mouseGetRelativeMode},
		{"newCursor", mouseNewCursor},
		{"getSystemCursor", mouseGetSystemCursor},
		{"setCursor", mouseSetCursor},
		{"getCursor", mouseGetCursor},
		{"isCursorSupported", mouseIsCursorSupported},
	};
	for (const auto &entry : mouseFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "mouse");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} touchFunctions[] = {
		{"getTouches", touchGetTouches},
		{"getPosition", touchGetPosition},
		{"getPressure", touchGetPressure},
	};
	for (const auto &entry : touchFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "touch");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} joystickModuleFunctions[] = {
		{"getJoysticks", joystickGetJoysticks},
		{"getJoystickCount", joystickGetJoystickCount},
		{"setGamepadMapping", joystickSetGamepadMapping},
		{"loadGamepadMappings", joystickLoadGamepadMappings},
		{"saveGamepadMappings", joystickSaveGamepadMappings},
		{"getGamepadMappingString", joystickGetGamepadMappingString},
	};
	for (const auto &entry : joystickModuleFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "joystick");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} timerFunctions[] = {
		{"step", timerStep},
		{"getDelta", timerGetDelta},
		{"getFPS", timerGetFPS},
		{"getAverageDelta", timerGetAverageDelta},
		{"sleep", timerSleep},
		{"getTime", timerGetTime},
	};
	for (const auto &entry : timerFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "timer");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} audioFunctions[] = {
		{"newSource", audioNewSource},
		{"newQueueableSource", audioNewQueueableSource},
		{"play", audioPlay},
		{"pause", audioPause},
		{"stop", audioStop},
		{"getActiveSourceCount", audioGetActiveSourceCount},
		{"getSourceCount", audioGetActiveSourceCount},
		{"setVolume", audioSetVolume},
		{"getVolume", audioGetVolume},
		{"setMixWithSystem", audioSetMixWithSystem},
		{"setPosition", audioSetPosition},
		{"getPosition", audioGetPosition},
		{"setOrientation", audioSetOrientation},
		{"getOrientation", audioGetOrientation},
		{"setVelocity", audioSetVelocity},
		{"getVelocity", audioGetVelocity},
		{"setDopplerScale", audioSetDopplerScale},
		{"getDopplerScale", audioGetDopplerScale},
		{"setDistanceModel", audioSetDistanceModel},
		{"getDistanceModel", audioGetDistanceModel},
		{"setEffect", audioSetEffect},
		{"getEffect", audioGetEffect},
		{"getActiveEffects", audioGetActiveEffects},
		{"getMaxSceneEffects", audioGetMaxSceneEffects},
		{"getMaxSourceEffects", audioGetMaxSourceEffects},
		{"getRecordingDevices", audioGetRecordingDevices},
		{"isEffectsSupported", audioIsEffectsSupported},
	};
	for (const auto &entry : audioFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "audio");

	lua_newtable(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, videoNewVideoStream, 1);
	lua_setfield(_state, -2, "newVideoStream");
	lua_setfield(_state, -2, "video");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} systemFunctions[] = {
		{"getOS", systemGetOS},
		{"getProcessorCount", systemGetProcessorCount},
		{"setClipboardText", systemSetClipboardText},
		{"getClipboardText", systemGetClipboardText},
		{"getPowerInfo", systemGetPowerInfo},
		{"openURL", systemOpenURL},
		{"vibrate", systemVibrate},
		{"hasBackgroundMusic", systemHasBackgroundMusic},
	};
	for (const auto &entry : systemFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "system");

	lua_newtable(_state);
	const struct { const char *name; lua_CFunction function; } threadFunctions[] = {
		{"newThread", threadNewThread}, {"newChannel", threadNewChannel},
		{"getChannel", threadGetChannel},
	};
	for (const auto &entry : threadFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "thread");

	lua_newtable(_state);
	const struct { const char *name; lua_CFunction function; } physicsFunctions[] = {
		{"setMeter", physicsSetMeter}, {"getMeter", physicsGetMeter},
		{"newWorld", physicsNewWorld}, {"newBody", physicsNewBody},
		{"newFixture", physicsNewFixture}, {"newCircleShape", physicsNewCircleShape},
		{"newRectangleShape", physicsNewRectangleShape}, {"newPolygonShape", physicsNewPolygonShape},
		{"newEdgeShape", physicsNewEdgeShape}, {"newChainShape", physicsNewChainShape},
		{"newDistanceJoint", physicsNewDistanceJoint},
		{"newRevoluteJoint", physicsNewRevoluteJoint},
		{"newPrismaticJoint", physicsNewPrismaticJoint},
		{"newWeldJoint", physicsNewWeldJoint},
		{"newFrictionJoint", physicsNewFrictionJoint},
		{"newRopeJoint", physicsNewRopeJoint},
		{"newPulleyJoint", physicsNewPulleyJoint},
		{"newWheelJoint", physicsNewWheelJoint},
		{"newMouseJoint", physicsNewMouseJoint},
		{"newMotorJoint", physicsNewMotorJoint},
		{"newGearJoint", physicsNewGearJoint},
	};
	for (const auto &entry : physicsFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "physics");
	lua_setglobal(_state, "love");

	luaL_getsubtable(_state, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
	lua_pushcfunction(_state, openLoveModule);
	lua_setfield(_state, -2, "love");
	lua_pushcfunction(_state, openLoveGraphicsModule);
	lua_setfield(_state, -2, "love.graphics");
	lua_pushcfunction(_state, openLoveImageModule);
	lua_setfield(_state, -2, "love.image");
	lua_pushcfunction(_state, openLoveFontModule);
	lua_setfield(_state, -2, "love.font");
	lua_pushcfunction(_state, openLoveSoundModule);
	lua_setfield(_state, -2, "love.sound");
	lua_pushcfunction(_state, openLoveMathModule);
	lua_setfield(_state, -2, "love.math");
	lua_pushcfunction(_state, openLoveDataModule);
	lua_setfield(_state, -2, "love.data");
	lua_pushcfunction(_state, openLoveWindowModule);
	lua_setfield(_state, -2, "love.window");
	lua_pushcfunction(_state, openLoveEventModule);
	lua_setfield(_state, -2, "love.event");
	lua_pushcfunction(_state, openLoveFilesystemModule);
	lua_setfield(_state, -2, "love.filesystem");
	lua_pushcfunction(_state, openLoveKeyboardModule);
	lua_setfield(_state, -2, "love.keyboard");
	lua_pushcfunction(_state, openLoveMouseModule);
	lua_setfield(_state, -2, "love.mouse");
	lua_pushcfunction(_state, openLoveTouchModule);
	lua_setfield(_state, -2, "love.touch");
	lua_pushcfunction(_state, openLoveJoystickModule);
	lua_setfield(_state, -2, "love.joystick");
	lua_pushcfunction(_state, openLoveTimerModule);
	lua_setfield(_state, -2, "love.timer");
	lua_pushcfunction(_state, openLoveAudioModule);
	lua_setfield(_state, -2, "love.audio");
	lua_pushcfunction(_state, openLoveVideoModule);
	lua_setfield(_state, -2, "love.video");
	lua_pushcfunction(_state, openLoveSystemModule);
	lua_setfield(_state, -2, "love.system");
	lua_pushcfunction(_state, openLoveThreadModule);
	lua_setfield(_state, -2, "love.thread");
	lua_pushcfunction(_state, openLovePhysicsModule);
	lua_setfield(_state, -2, "love.physics");
	lua_pop(_state, 1);
}

int LoveRuntime::traceback(lua_State *state)
{
	const char *message = lua_tostring(state, 1);
	if (message == nullptr)
		message = "LoveRuntime error";
	luaL_traceback(state, state, message, 1);
	if (auto *runtime = runtimeFromUpvalue(state))
		runtime->rewriteGeneratedErrorOnStack(state);
	return 1;
}

std::string LoveRuntime::prepareGeneratedChunk(std::string_view code,
	std::string_view chunkName)
{
	const auto firstLineEnd = code.find_first_of("\r\n");
	const auto firstLine = code.substr(0, firstLineEnd);
	if (!firstLine.starts_with("-- ["))
		return std::string(chunkName);
	const auto languageEnd = firstLine.find("]: ", 4);
	if (languageEnd == std::string_view::npos)
		return std::string(chunkName);
	const auto language = firstLine.substr(4, languageEnd - 4);
	if (language != "ts" && language != "tsx" && language != "tl" && language != "yue")
		return std::string(chunkName);
	std::string source(firstLine.substr(languageEnd + 3));
	if (source.empty())
		return std::string(chunkName);
	if (source.front() == '@')
		source.erase(source.begin());

	GeneratedLineMap mapping;
	mapping.source = source;
	mapping.lines.push_back(0); // Lua source lines are one-based.
	int generatedLine = 0;
	int lastSourceLine = 1;
	std::size_t offset = 0;
	while (offset <= code.size())
	{
		const auto lineEnd = code.find('\n', offset);
		auto line = code.substr(offset,
			lineEnd == std::string_view::npos ? code.size() - offset : lineEnd - offset);
		if (!line.empty() && line.back() == '\r')
			line.remove_suffix(1);
		++generatedLine;
		if (generatedLine == 1)
		{
			mapping.lines.push_back(1);
		}
		else if (language == "tl")
		{
			mapping.lines.push_back(generatedLine - 1);
		}
		else
		{
			std::size_t valueEnd = line.size();
			while (valueEnd > 0 && std::isspace(static_cast<unsigned char>(line[valueEnd - 1])))
				--valueEnd;
			const auto marker = line.rfind("-- ", valueEnd);
			if (marker != std::string_view::npos && marker + 3 < valueEnd)
			{
				int sourceLine = 0;
				const auto *begin = line.data() + marker + 3;
				const auto *end = line.data() + valueEnd;
				const auto parsed = std::from_chars(begin, end, sourceLine);
				if (parsed.ec == std::errc{} && parsed.ptr == end && sourceLine > 0)
					lastSourceLine = sourceLine;
			}
			mapping.lines.push_back(lastSourceLine);
		}
		if (lineEnd == std::string_view::npos)
			break;
		offset = lineEnd + 1;
	}
	_generatedLineMaps[source] = std::move(mapping);
	return "@" + source;
}

std::string LoveRuntime::rewriteGeneratedError(std::string message) const
{
	for (const auto &[_, mapping] : _generatedLineMaps)
	{
		std::string displayedSource = mapping.source;
		constexpr std::size_t chunkTail = LUA_IDSIZE - 4;
		if (displayedSource.size() + 1 > LUA_IDSIZE)
			displayedSource = "..." + displayedSource.substr(displayedSource.size() - chunkTail);
		for (std::size_t generatedLine = 1;
			generatedLine < mapping.lines.size(); ++generatedLine)
		{
			const int sourceLine = mapping.lines[generatedLine];
			if (sourceLine <= 0)
				continue;
			const std::string token = displayedSource + ":"
				+ std::to_string(generatedLine) + ":";
			const std::string replacement = mapping.source + ":"
				+ std::to_string(sourceLine) + ":";
			if (token == replacement)
				continue;
			std::size_t position = 0;
			while ((position = message.find(token, position)) != std::string::npos)
			{
				message.replace(position, token.size(), replacement);
				position += replacement.size();
			}
		}
	}
	return message;
}

void LoveRuntime::rewriteGeneratedErrorOnStack(lua_State *state) const
{
	std::size_t size = 0;
	const char *message = lua_tolstring(state, -1, &size);
	if (!message)
		return;
	const std::string rewritten = rewriteGeneratedError(std::string(message, size));
	lua_pop(state, 1);
	lua_pushlstring(state, rewritten.data(), rewritten.size());
}

bool LoveRuntime::execute(std::string_view code, std::string_view chunkName, std::string &error)
{
	if (_state == nullptr)
	{
		error = "LoveRuntime is not open";
		return false;
	}

	const int base = lua_gettop(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, traceback, 1);
	const int errorHandler = lua_gettop(_state);

	std::string chunk = prepareGeneratedChunk(code, chunkName);
	if (loadLoveChunk(_state, code, chunk.c_str()) != LUA_OK)
	{
		const char *loadError = lua_tostring(_state, -1);
		error = rewriteGeneratedError(loadError ? loadError : "LoveRuntime load error");
		lua_settop(_state, base);
		return false;
	}

	if (lua_pcall(_state, 0, 0, errorHandler) != LUA_OK)
	{
		error = lua_tostring(_state, -1);
		lua_settop(_state, base);
		return false;
	}

	lua_settop(_state, base);
	error.clear();
	return true;
}

bool LoveRuntime::fail(std::string message, std::string &error)
{
	_lastError = std::move(message);
	_status = Status::Faulted;
	error = _lastError;
	return false;
}

bool LoveRuntime::callLoveCallback(const char *name, int argumentCount, int resultCount, std::string &error)
{
	const int base = lua_gettop(_state) - argumentCount;
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, traceback, 1);
	lua_insert(_state, base + 1);
	const int errorHandler = base + 1;

	lua_getglobal(_state, "love");
	lua_getfield(_state, -1, name);
	lua_remove(_state, -2);
	if (lua_isnil(_state, -1))
	{
		lua_settop(_state, base);
		error.clear();
		return true;
	}
	if (!lua_isfunction(_state, -1))
	{
		lua_settop(_state, base);
		return fail(std::string("love.") + name + " must be a function", error);
	}

	if (argumentCount > 0)
		lua_insert(_state, base + 2);
	if (lua_pcall(_state, argumentCount, resultCount, errorHandler) != LUA_OK)
	{
		std::string message = lua_tostring(_state, -1);
		lua_settop(_state, base);
		return fail(std::move(message), error);
	}

	lua_remove(_state, errorHandler);
	error.clear();
	return true;
}

bool LoveRuntime::boot(std::string_view code, std::string_view chunkName, std::string &error)
{
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before boot";
		return false;
	}

	_bootCode.assign(code);
	_bootChunkName.assign(chunkName);
	if (!execute(_bootCode, _bootChunkName, error))
		return fail(error, error);
	return start(error);
}

bool LoveRuntime::configure(std::string &error)
{
	error.clear();
	_configurationWarnings.clear();
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before configure";
		return false;
	}

	lua_newtable(_state);
	lua_pushliteral(_state, "11.5");
	lua_setfield(_state, -2, "version");
	lua_pushliteral(_state, "Untitled");
	lua_setfield(_state, -2, "title");
	if (!_identity.empty())
	{
		lua_pushlstring(_state, _identity.data(), _identity.size());
		lua_setfield(_state, -2, "identity");
	}
	else
	{
		lua_pushboolean(_state, false);
		lua_setfield(_state, -2, "identity");
	}
	const auto setBooleanField = [this](const char *field, bool value) {
		lua_pushboolean(_state, value);
		lua_setfield(_state, -2, field);
	};
	setBooleanField("console", false);
	setBooleanField("appendidentity", false);
	setBooleanField("externalstorage", false);
	setBooleanField("accelerometerjoystick", true);
	setBooleanField("gammacorrect", false);
	lua_newtable(_state);
	setBooleanField("mixwithsystem", true);
	setBooleanField("mic", false);
	lua_setfield(_state, -2, "audio");
	lua_newtable(_state);
	static constexpr std::array<const char *, 18> ModuleNames = {
		"data", "event", "keyboard", "mouse", "timer", "joystick", "touch", "image",
		"graphics", "audio", "math", "physics", "sound", "system", "font", "thread",
		"window", "video"};
	for (const auto *module : ModuleNames)
		setBooleanField(module, true);
	lua_setfield(_state, -2, "modules");
	lua_newtable(_state);
	lua_pushinteger(_state, DefaultWindowWidth);
	lua_setfield(_state, -2, "width");
	lua_pushinteger(_state, DefaultWindowHeight);
	lua_setfield(_state, -2, "height");
	lua_pushinteger(_state, 1);
	lua_setfield(_state, -2, "minwidth");
	lua_pushinteger(_state, 1);
	lua_setfield(_state, -2, "minheight");
	setBooleanField("fullscreen", false);
	lua_pushliteral(_state, "desktop");
	lua_setfield(_state, -2, "fullscreentype");
	lua_pushinteger(_state, 1);
	lua_setfield(_state, -2, "display");
	setBooleanField("highdpi", false);
	setBooleanField("usedpiscale", true);
	setBooleanField("resizable", false);
	setBooleanField("borderless", false);
	setBooleanField("centered", true);
	lua_pushinteger(_state, 1);
	lua_setfield(_state, -2, "vsync");
	lua_pushinteger(_state, 0);
	lua_setfield(_state, -2, "msaa");
	lua_setfield(_state, -2, "window");
	lua_pushvalue(_state, -1);
	const int configuration = luaL_ref(_state, LUA_REGISTRYINDEX);
	if (!callLoveCallback("conf", 1, 0, error))
	{
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return false;
	}

	lua_rawgeti(_state, LUA_REGISTRYINDEX, configuration);
	lua_getfield(_state, -1, "window");
	const bool windowDisabled = lua_isnil(_state, -1)
		|| (lua_isboolean(_state, -1) && !lua_toboolean(_state, -1));
	if (!lua_istable(_state, -1) && !windowDisabled)
	{
		lua_pop(_state, 2);
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return fail("love.conf must leave t.window as a table", error);
	}
	if (windowDisabled)
	{
		lua_pop(_state, 1);
		lua_newtable(_state);
		lua_pushinteger(_state, DefaultWindowWidth); lua_setfield(_state, -2, "width");
		lua_pushinteger(_state, DefaultWindowHeight); lua_setfield(_state, -2, "height");
		lua_pushboolean(_state, false); lua_setfield(_state, -2, "fullscreen");
		lua_pushboolean(_state, false); lua_setfield(_state, -2, "highdpi");
		lua_pushboolean(_state, false); lua_setfield(_state, -2, "resizable");
		lua_pushinteger(_state, 1); lua_setfield(_state, -2, "display");
		lua_pushinteger(_state, 1); lua_setfield(_state, -2, "vsync");
		_configurationWarnings = "window module is disabled; LoveNode keeps its virtual surface available";
	}
	const auto appendConfigurationWarning = [this](std::string_view warning) {
		if (!_configurationWarnings.empty()) _configurationWarnings += "; ";
		_configurationWarnings += warning;
	};
	const auto readDimension = [&](const char *field, int &value) {
		lua_getfield(_state, -1, field);
		int isInteger = 0;
		const lua_Integer configuredValue = lua_tointegerx(_state, -1, &isInteger);
		lua_pop(_state, 1);
		if (!isInteger || configuredValue < 1 || configuredValue > MaximumWindowDimension)
		{
			error = std::string("love.conf t.window.") + field
				+ " must be an integer from 1 to " + std::to_string(MaximumWindowDimension);
			return false;
		}
		value = static_cast<int>(configuredValue);
		return true;
	};
	int width = DefaultWindowWidth;
	int height = DefaultWindowHeight;
	bool resizable = false;
	const auto readBoolean = [&](const char *field, bool &value) {
		lua_getfield(_state, -1, field);
		if (!lua_isboolean(_state, -1))
		{
			lua_pop(_state, 1);
			error = std::string("love.conf t.window.") + field + " must be a boolean";
			return false;
		}
		value = lua_toboolean(_state, -1);
		lua_pop(_state, 1);
		return true;
	};
	bool fullscreen = false;
	bool highdpi = false;
	int vsync = 1;
	const bool valid = readDimension("width", width) && readDimension("height", height)
		&& readBoolean("fullscreen", fullscreen) && readBoolean("highdpi", highdpi)
		&& readBoolean("resizable", resizable);
	if (valid)
	{
		lua_getfield(_state, -1, "display");
		int isInteger = 0;
		const lua_Integer display = lua_tointegerx(_state, -1, &isInteger);
		lua_pop(_state, 1);
		if (!isInteger || display < 1)
			error = "love.conf t.window.display must be a positive integer";
		else if (display != 1 || fullscreen || highdpi)
			appendConfigurationWarning("ignoring unsupported embedded window settings; "
				"LoveNode uses t.window.fullscreen=false, highdpi=false, and display=1");
		if (error.empty())
		{
			lua_getfield(_state, -1, "vsync");
			lua_Integer configuredVSync = 0;
			if (lua_isboolean(_state, -1))
			{
				configuredVSync = lua_toboolean(_state, -1) ? 1 : 0;
				isInteger = 1;
			}
			else configuredVSync = lua_tointegerx(_state, -1, &isInteger);
			lua_pop(_state, 1);
			if (!isInteger || configuredVSync < -1 || configuredVSync > 1)
				error = "love.conf t.window.vsync must be -1, 0, or 1";
			else vsync = static_cast<int>(configuredVSync);
		}
	}
	const bool supported = valid && error.empty();
	lua_pop(_state, 2);
	lua_rawgeti(_state, LUA_REGISTRYINDEX, configuration);
	lua_getfield(_state, -1, "title");
	if (!lua_isstring(_state, -1))
	{
		lua_pop(_state, 2);
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return fail("love.conf t.title must be a string", error);
	}
	const std::string configuredTitle = lua_tostring(_state, -1);
	lua_pop(_state, 1);
	lua_getfield(_state, -1, "identity");
	const bool disabledIdentity = lua_isboolean(_state, -1) && !lua_toboolean(_state, -1);
	if (!lua_isnil(_state, -1) && !lua_isstring(_state, -1) && !disabledIdentity)
	{
		lua_pop(_state, 2);
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return fail("love.conf t.identity must be a string, false, or nil", error);
	}
	const std::string configuredIdentity = lua_isstring(_state, -1) ? lua_tostring(_state, -1) : _identity;
	lua_pop(_state, 1);
	lua_getfield(_state, -1, "audio");
	bool applyMixWithSystem = false;
	bool mixWithSystem = true;
	if (lua_istable(_state, -1))
	{
		lua_getfield(_state, -1, "mixwithsystem");
		if (!lua_isnil(_state, -1))
		{
			if (!lua_isboolean(_state, -1))
			{
				lua_pop(_state, 3);
				luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
				return fail("love.conf t.audio.mixwithsystem must be a boolean or nil", error);
			}
			applyMixWithSystem = true;
			mixWithSystem = lua_toboolean(_state, -1) != 0;
		}
		lua_pop(_state, 1);
	}
	else if (!lua_isnil(_state, -1) && !(lua_isboolean(_state, -1) && !lua_toboolean(_state, -1)))
	{
		lua_pop(_state, 2);
		luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
		return fail("love.conf t.audio must be a table, false, or nil", error);
	}
	lua_pop(_state, 2);
	luaL_unref(_state, LUA_REGISTRYINDEX, configuration);
	if (!supported)
		return fail(error, error);
	if (!setIdentity(configuredIdentity.empty() ? "love" : configuredIdentity, error))
		return fail(error, error);
	if (applyMixWithSystem && _audioBackend)
		_audioBackend->setMixWithSystem(mixWithSystem);
	_configuredWidth = width;
	_configuredHeight = height;
	_windowResizable = resizable;
	_windowTitle = configuredTitle;
	_windowVSync = vsync;
	error.clear();
	return true;
}

bool LoveRuntime::start(std::string &error)
{
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before start";
		return false;
	}
	lua_getglobal(_state, "love");
	lua_getfield(_state, -1, "load");
	const bool hasLoadCallback = lua_isfunction(_state, -1);
	lua_pop(_state, 2);
	if (_graphicsBackend && hasLoadCallback)
		_graphicsBackend->beginFrame();
	_graphicsFrameActive = hasLoadCallback;
	_graphicsLoadCallbackActive = hasLoadCallback;
	const bool loaded = callLoveCallback("load", 0, 0, error);
	_graphicsLoadCallbackActive = false;
	_graphicsFrameActive = false;
	if (_graphicsBackend && hasLoadCallback)
		_graphicsBackend->endFrame();
	if (!loaded)
		return false;

	_status = Status::Running;
	return true;
}

bool LoveRuntime::update(double deltaTime, std::string &error)
{
	if (_status != Status::Running)
	{
		error = _lastError.empty() ? "LoveRuntime is not running" : _lastError;
		return false;
	}
	drainThreadFilesystemRequests();
	_timerDelta = std::max(0.0, deltaTime);
	_timerWindow += _timerDelta;
	++_timerFrames;
	if (_timerWindow >= 1.0)
	{
		_timerFPS = static_cast<int>(std::floor(static_cast<double>(_timerFrames) / _timerWindow + 0.5));
		_timerAverageDelta = _timerWindow / static_cast<double>(_timerFrames);
		_timerWindow = 0.0;
		_timerFrames = 0;
	}
	if (!dispatchQueuedEvents(error))
		return false;
	if (_status == Status::Stopped || _status == Status::RestartRequested)
	{
		error.clear();
		return true;
	}
	lua_pushnumber(_state, deltaTime);
	return callLoveCallback("update", 1, 0, error);
}

bool LoveRuntime::dispatchQueuedEvents(std::string &error)
{
	drainThreadErrors();
	while (!_eventQueue.empty())
	{
		QueuedEvent event = std::move(_eventQueue.front());
		_eventQueue.pop_front();
		const char *callback = nullptr;
		int argumentCount = 0;
		switch (event.type)
		{
			case QueuedEventType::KeyPressed:
				_pressedKeys.insert(event.first);
				_pressedScancodes.insert(event.second);
				callback = "keypressed";
				lua_pushlstring(_state, event.first.data(), event.first.size());
				lua_pushlstring(_state, event.second.data(), event.second.size());
				lua_pushboolean(_state, event.flag);
				argumentCount = 3;
				break;
			case QueuedEventType::KeyReleased:
				_pressedKeys.erase(event.first);
				_pressedScancodes.erase(event.second);
				callback = "keyreleased";
				lua_pushlstring(_state, event.first.data(), event.first.size());
				lua_pushlstring(_state, event.second.data(), event.second.size());
				argumentCount = 2;
				break;
			case QueuedEventType::TextInput:
				callback = "textinput";
				lua_pushlstring(_state, event.first.data(), event.first.size());
				argumentCount = 1;
				break;
			case QueuedEventType::TextEdited:
				callback = "textedited";
				lua_pushlstring(_state, event.first.data(), event.first.size());
				lua_pushinteger(_state, event.button);
				lua_pushinteger(_state, event.presses);
				argumentCount = 3;
				break;
			case QueuedEventType::MousePressed:
				_mouseX = event.x;
				_mouseY = event.y;
				_pressedMouseButtons.insert(event.button);
				callback = "mousepressed";
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				lua_pushinteger(_state, event.button);
				lua_pushboolean(_state, event.flag);
				lua_pushinteger(_state, event.presses);
				argumentCount = 5;
				break;
			case QueuedEventType::MouseReleased:
				_mouseX = event.x;
				_mouseY = event.y;
				_pressedMouseButtons.erase(event.button);
				callback = "mousereleased";
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				lua_pushinteger(_state, event.button);
				lua_pushboolean(_state, event.flag);
				lua_pushinteger(_state, event.presses);
				argumentCount = 5;
				break;
			case QueuedEventType::MouseMoved:
				_mouseX = event.x;
				_mouseY = event.y;
				callback = "mousemoved";
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				lua_pushnumber(_state, event.deltaX);
				lua_pushnumber(_state, event.deltaY);
				lua_pushboolean(_state, event.flag);
				argumentCount = 5;
				break;
			case QueuedEventType::WheelMoved:
				callback = "wheelmoved";
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				argumentCount = 2;
				break;
			case QueuedEventType::TouchPressed:
			case QueuedEventType::TouchMoved:
			case QueuedEventType::TouchReleased:
				if (event.type == QueuedEventType::TouchReleased)
					_touches.erase(event.touchId);
				else
					_touches[event.touchId] = {event.x, event.y, event.pressure};
				callback = event.type == QueuedEventType::TouchPressed ? "touchpressed"
					: event.type == QueuedEventType::TouchMoved ? "touchmoved" : "touchreleased";
				lua_pushlightuserdata(_state, reinterpret_cast<void *>(event.touchId));
				lua_pushnumber(_state, event.x);
				lua_pushnumber(_state, event.y);
				lua_pushnumber(_state, event.deltaX);
				lua_pushnumber(_state, event.deltaY);
				lua_pushnumber(_state, event.pressure);
				argumentCount = 6;
				break;
			case QueuedEventType::JoystickAdded:
				callback = "joystickadded";
				pushJoystick(event.controllerId);
				argumentCount = 1;
				break;
			case QueuedEventType::JoystickRemoved:
				callback = "joystickremoved";
				pushJoystick(event.controllerId);
				argumentCount = 1;
				break;
			case QueuedEventType::JoystickPressed:
			case QueuedEventType::JoystickReleased:
				callback = event.type == QueuedEventType::JoystickPressed
					? "joystickpressed" : "joystickreleased";
				pushJoystick(event.controllerId);
				lua_pushinteger(_state, event.button + 1);
				argumentCount = 2;
				break;
			case QueuedEventType::JoystickAxis:
				callback = "joystickaxis";
				pushJoystick(event.controllerId);
				lua_pushinteger(_state, event.button + 1);
				lua_pushnumber(_state, event.x);
				argumentCount = 3;
				break;
			case QueuedEventType::JoystickHat:
				callback = "joystickhat";
				pushJoystick(event.controllerId);
				lua_pushinteger(_state, event.button + 1);
				lua_pushlstring(_state, event.first.data(), event.first.size());
				argumentCount = 3;
				break;
			case QueuedEventType::GamepadPressed:
			{
				auto found = _joysticks.find(event.controllerId);
				if (found == _joysticks.end())
					continue;
				found->second.buttons.insert(event.first);
				callback = "gamepadpressed";
				pushJoystick(event.controllerId);
				lua_pushlstring(_state, event.first.data(), event.first.size());
				argumentCount = 2;
				break;
			}
			case QueuedEventType::GamepadReleased:
			{
				auto found = _joysticks.find(event.controllerId);
				if (found == _joysticks.end())
					continue;
				found->second.buttons.erase(event.first);
				callback = "gamepadreleased";
				pushJoystick(event.controllerId);
				lua_pushlstring(_state, event.first.data(), event.first.size());
				argumentCount = 2;
				break;
			}
			case QueuedEventType::GamepadAxis:
			{
				auto found = _joysticks.find(event.controllerId);
				if (found == _joysticks.end())
					continue;
				found->second.axes[event.first] = event.x;
				callback = "gamepadaxis";
				pushJoystick(event.controllerId);
				lua_pushlstring(_state, event.first.data(), event.first.size());
				lua_pushnumber(_state, event.x);
				argumentCount = 3;
				break;
			}
			case QueuedEventType::Custom:
			{
				if (event.first == "quit")
				{
					bool restart = false;
					if (event.registryReference != LUA_NOREF && event.presses > 0)
					{
						lua_rawgeti(_state, LUA_REGISTRYINDEX, event.registryReference);
						lua_rawgeti(_state, -1, 1);
						restart = lua_type(_state, -1) == LUA_TSTRING
							&& std::string_view(lua_tostring(_state, -1)) == "restart";
						lua_pop(_state, 2);
					}
					const int stackBase = lua_gettop(_state);
					releaseQueuedEvent(event);
					if (!callLoveCallback("quit", 0, 1, error))
					{
						clearQueuedEvents();
						return false;
					}
					const bool cancelled = lua_gettop(_state) > stackBase && lua_toboolean(_state, -1);
					lua_settop(_state, stackBase);
					if (!cancelled)
					{
						_status = restart ? Status::RestartRequested : Status::Stopped;
						clearQueuedEvents();
					}
					continue;
				}
				callback = event.first.c_str();
				if (event.registryReference != LUA_NOREF)
				{
					const int base = lua_gettop(_state);
					lua_rawgeti(_state, LUA_REGISTRYINDEX, event.registryReference);
					for (int index = 1; index <= event.presses; ++index)
						lua_rawgeti(_state, base + 1, index);
					lua_remove(_state, base + 1);
					argumentCount = event.presses;
				}
				break;
			}
			case QueuedEventType::Quit:
			{
				const int stackBase = lua_gettop(_state);
				if (!callLoveCallback("quit", 0, 1, error))
				{
					clearQueuedEvents();
					return false;
				}
				const bool cancelled = lua_gettop(_state) > stackBase && lua_toboolean(_state, -1);
				lua_settop(_state, stackBase);
				if (!cancelled)
				{
					_status = event.first == "restart" ? Status::RestartRequested : Status::Stopped;
					clearQueuedEvents();
				}
				continue;
			}
		}
		if (!callLoveCallback(callback, argumentCount, 0, error))
		{
			releaseQueuedEvent(event);
			clearQueuedEvents();
			return false;
		}
		releaseQueuedEvent(event);
	}
	error.clear();
	return true;
}

bool LoveRuntime::draw(std::string &error)
{
	if (_status != Status::Running)
	{
		error = _lastError.empty() ? "LoveRuntime is not running" : _lastError;
		return false;
	}
	if (_graphicsBackend)
		_graphicsBackend->beginFrame();
	resetGraphicsTransform();
	for (const auto &saved : _graphicsStateStack)
	{
		for (const int reference : saved.canvasReferences)
			luaL_unref(_state, LUA_REGISTRYINDEX, reference);
		if (saved.shaderReference != LUA_NOREF)
			luaL_unref(_state, LUA_REGISTRYINDEX, saved.shaderReference);
	}
	_graphicsStateStack.clear();
	_graphicsFrameActive = true;
	const bool success = callLoveCallback("draw", 0, 0, error);
	_graphicsFrameActive = false;
	if (_graphicsBackend)
		_graphicsBackend->endFrame();
	return success;
}

bool LoveRuntime::stop(std::string &error)
{
	if (_status != Status::Running)
	{
		error = _lastError.empty() ? "LoveRuntime is not running" : _lastError;
		return false;
	}
	if (!callLoveCallback("quit", 0, 0, error))
		return false;
	_status = Status::Stopped;
	return true;
}

bool LoveRuntime::restart(std::string &error)
{
	if (_bootChunkName.empty())
	{
		error = "LoveRuntime has no boot chunk to restart";
		return false;
	}

	const std::string code = _bootCode;
	const std::string chunkName = _bootChunkName;
	const std::string sourceRoot = _sourceRoot;
	const std::string saveBaseRoot = _saveBaseRoot;
	const std::string identity = _identity;
	close();
	if (!open(error))
		return false;
	if (!sourceRoot.empty() && !setSourceRoot(sourceRoot, error))
		return false;
	if (!saveBaseRoot.empty() && !setSaveBaseRoot(saveBaseRoot, error))
		return false;
	if (!identity.empty() && !setIdentity(identity, error))
		return false;
	return boot(code, chunkName, error);
}

} // namespace Dora::Love
