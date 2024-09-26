/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Common/Debug.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Common/Async.h"
#include "Common/Singleton.h"

#include "Lua/LuaEngine.h"
#include "Wasm/WasmRuntime.h"

#include "spdlog/pattern_formatter.h"
#include "spdlog/sinks/callback_sink.h"
#include "spdlog/sinks/rotating_file_sink.h"

#if BX_PLATFORM_ANDROID
#include "spdlog/sinks/android_sink.h"
#else
#include "spdlog/sinks/ansicolor_sink.h"
#endif // BX_PLATFORM_ANDROID

NS_DORA_BEGIN

Acf::Delegate<void(const std::string&)> LogHandler;

const char* getShortFilename(const char* filename) {
	return spdlog::details::short_filename_formatter<spdlog::details::null_scoped_padder>::basename(filename);
}

class Logger : public NonCopyable {
#if !BX_PLATFORM_ANDROID
private:
	struct Mutex {
		using mutex_t = std::mutex;
		static mutex_t& mutex() {
			return *mutexPtr;
		}
		static std::mutex* mutexPtr;
	};
	std::mutex _mutex;
#endif
public:
	Logger() {
		_thread = SharedAsyncThread.newThread();
		_formatter.set_pattern("[%H:%M:%S.%e] [%l] %v"s);
#if BX_PLATFORM_ANDROID
		auto consoleSink = std::make_shared<spdlog::sinks::android_sink_mt>("dora"s);
#else
		Mutex::mutexPtr = &_mutex;
		auto consoleSink = std::make_shared<spdlog::sinks::ansicolor_stdout_sink<Mutex>>();
#endif
		auto doraSink = std::make_shared<spdlog::sinks::callback_sink_mt>([this](const spdlog::details::log_msg& msg) {
			spdlog::memory_buf_t buf;
			_formatter.format(msg, buf);
			auto str = fmt::to_string(buf);
			if (Singleton<Dora::Application>::isInitialized() && SharedApplication.isLogicRunning()) {
				SharedApplication.invokeInLogic([str]() {
					LogHandler(str);
				});
			}
		});
		auto fileSink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(getFilename(), getMaxFileSize(), getMaxFiles());
		_logger = std::make_shared<spdlog::logger>(std::string(), spdlog::sinks_init_list{consoleSink, doraSink, fileSink});
	}

	int getMaxFiles() const {
		return 2;
	}

	std::string getFilename() const {
		return Path::concat({SharedContent.getWritablePath(), "log.txt"sv});
	}

	int getMaxFileSize() const {
		return 1024 * 128; // 128 kb
	}

	virtual ~Logger() { }

	bool saveAs(String filename) {
		_logger->flush();
		_logger->sinks().pop_back();
		std::string logText;
		for (int i = getMaxFiles() - 1; i >= 0; i--) {
			auto logFile = spdlog::sinks::rotating_file_sink_mt::calc_filename(getFilename(), i);
			if (!SharedContent.exist(logFile)) {
				continue;
			}
			auto result = SharedContent.load(logFile);
			if (result.first) {
				if (logText.empty()) {
					logText = std::string(r_cast<const char*>(result.first.get()), result.second);
				} else {
					logText += '\n' + std::string(r_cast<const char*>(result.first.get()), result.second);
				}
			}
		}
		bool result = SharedContent.save(filename, logText);
		_logger->sinks().push_back(std::make_shared<spdlog::sinks::rotating_file_sink_mt>(getFilename(), getMaxFileSize(), getMaxFiles()));
		return result;
	}

	void log(spdlog::level::level_enum level, const std::string& msg) {
		_logger->log(level, msg);
	}

	void logAsync(spdlog::level::level_enum level, const std::string& msg) {
		if (Singleton<AsyncThread>::isDisposed()) {
			_logger->log(level, msg);
		} else {
			_thread->run([this, level, msg]() {
				_logger->log(level, msg);
			});
		}
	}

	spdlog::logger& get() const {
		return *_logger;
	}

private:
	spdlog::pattern_formatter _formatter;
	std::shared_ptr<spdlog::logger> _logger;
	Async* _thread;
	SINGLETON_REF(Logger);
};

#if !BX_PLATFORM_ANDROID
std::mutex* Logger::Mutex::mutexPtr = nullptr;
#endif

#define SharedLogger \
	Singleton<Logger>::shared()

bool LogSaveAs(std::string_view filename) {
	return SharedLogger.saveAs(filename);
}

void LogInfo(const std::string& msg) {
	SharedLogger.log(spdlog::level::info, msg);
}

void LogError(const std::string& msg) {
	SharedLogger.log(spdlog::level::err, msg);
}

void LogThreaded(const std::string& level, const std::string& msg) {
	switch (Switch::hash(level)) {
		case "Info"_hash:
			SharedLogger.logAsync(spdlog::level::info, msg);
			break;
		case "Warn"_hash:
			SharedLogger.logAsync(spdlog::level::warn, msg);
			break;
		case "Error"_hash:
			SharedLogger.logAsync(spdlog::level::err, msg);
			break;
		default:
			SharedLogger.logAsync(spdlog::level::info, msg);
			break;
	}
}

void LogErrorThreaded(const std::string& msg) {
	SharedLogger.logAsync(spdlog::level::err, msg);
}

void LogWarnThreaded(const std::string& msg) {
	SharedLogger.logAsync(spdlog::level::warn, msg);
}

void LogInfoThreaded(const std::string& msg) {
	SharedLogger.logAsync(spdlog::level::info, msg);
}

bool IsInLuaOrWasm() {
	if (LuaEngine::isInLua()) {
		return true;
	}
	if (WasmRuntime::isInWasm()) {
		return true;
	}
	return false;
}

NS_DORA_END
