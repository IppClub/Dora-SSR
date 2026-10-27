/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <chrono>
#include <cstring>
#include <string>
#include <thread>

#ifdef _WIN32
#include <windows.h>
#else
#include <cerrno>
#include <fcntl.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#endif

namespace Dora {

// Standalone desktop GUI only. Keep this object alive through engine teardown.
// No SDL dependency: requests received during startup remain pending until the
// window exists. The OS releases ownership even after a crash or forced exit.
class GuiInstance {
public:
	enum class Result { Primary, Notified, Error, Existing };
	explicit GuiInstance(const std::string& name = "dora-ssr-gui")
		: _name(name) { }
	GuiInstance(const GuiInstance&) = delete;
	GuiInstance& operator=(const GuiInstance&) = delete;

	~GuiInstance() {
#ifdef _WIN32
		if (_pid) UnmapViewOfFile(const_cast<LONG*>(_pid));
		if (_mapping) CloseHandle(_mapping);
		if (_event) CloseHandle(_event);
		if (_owned) ReleaseMutex(_mutex);
		if (_mutex) CloseHandle(_mutex);
#else
#if !defined(__linux__)
		if (_requests >= 0) close(_requests);
#endif
		// Never unlink the lock: waiters must all lock the same inode.
		if (_lock >= 0) close(_lock);
#endif
	}

	Result acquire() {
#ifdef _WIN32
		// Local scopes the objects to a Windows login session; include the user so
		// Run As another user does not suppress that user's window.
		wchar_t user[257];
		DWORD size = sizeof(user) / sizeof(user[0]);
		if (!GetUserNameW(user, &size)) return Result::Error;
		std::wstring name = L"Local\\" + std::wstring(_name.begin(), _name.end()) + L"." + user;
		_mutex = CreateMutexW(nullptr, FALSE, (name + L".Lock").c_str());
		if (!_mutex) return Result::Error;
#else
		// A private per-user directory avoids collisions between users and prevents
		// other users from replacing the lock or injecting activation requests.
		const auto directory = "/tmp/" + _name + "-" + std::to_string(geteuid());
		if (mkdir(directory.c_str(), 0700) != 0 && errno != EEXIST) return Result::Error;
		struct stat info{};
		if (lstat(directory.c_str(), &info) != 0 || !S_ISDIR(info.st_mode)
			|| info.st_uid != geteuid() || (info.st_mode & 077) != 0) return Result::Error;
#if !defined(__linux__)
		_path = directory + "/activate";
		_address.sun_family = AF_UNIX;
		if (_path.size() >= sizeof(_address.sun_path)) return Result::Error;
		std::memcpy(_address.sun_path, _path.c_str(), _path.size() + 1);
		_requests = socket(AF_UNIX, SOCK_DGRAM, 0);
		if (_requests < 0 || fcntl(_requests, F_SETFD, FD_CLOEXEC) != 0
			|| fcntl(_requests, F_SETFL, O_NONBLOCK) != 0) return Result::Error;
#endif
		_lock = open((directory + "/lock").c_str(), O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW, 0600);
		if (_lock < 0 || fstat(_lock, &info) != 0 || !S_ISREG(info.st_mode)
			|| info.st_uid != geteuid()) return Result::Error;
#endif
		// A second launch may race the owner's IPC setup. Retry for a bounded time;
		// also retry ownership in case that owner exits or fails during startup.
		const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(3);
		do {
#ifdef _WIN32
			const auto wait = WaitForSingleObject(_mutex, 0);
			if (wait == WAIT_OBJECT_0 || wait == WAIT_ABANDONED) {
				_owned = true;
				_event = CreateEventW(nullptr, FALSE, FALSE, (name + L".Activate").c_str());
				_mapping = CreateFileMappingW(INVALID_HANDLE_VALUE, nullptr, PAGE_READWRITE, 0, sizeof(LONG), (name + L".PID").c_str());
				if (!_event || !_mapping) return Result::Error;
				_pid = static_cast<volatile LONG*>(MapViewOfFile(_mapping, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(LONG)));
				if (!_pid) return Result::Error;
				InterlockedExchange(_pid, static_cast<LONG>(GetCurrentProcessId()));
				return Result::Primary;
			}
			if (wait != WAIT_TIMEOUT) return Result::Error;
			HANDLE event = OpenEventW(EVENT_MODIFY_STATE, FALSE, (name + L".Activate").c_str());
			HANDLE mapping = OpenFileMappingW(FILE_MAP_READ, FALSE, (name + L".PID").c_str());
			bool notified = false;
			if (event && mapping) {
				const auto pid = static_cast<const DWORD*>(MapViewOfFile(mapping, FILE_MAP_READ, 0, 0, sizeof(DWORD)));
				if (pid && *pid != 0) {
					// Transfer foreground permission from the new launch to the existing GUI.
					AllowSetForegroundWindow(*pid);
					notified = SetEvent(event) != FALSE;
				}
				if (pid) UnmapViewOfFile(pid);
			}
			if (mapping) CloseHandle(mapping);
			if (event) CloseHandle(event);
			if (notified) return Result::Notified;
#else
			if (flock(_lock, LOCK_EX | LOCK_NB) == 0) {
#if defined(__linux__)
				return Result::Primary;
#else
				if (unlink(_path.c_str()) != 0 && errno != ENOENT) return Result::Error;
				return bind(_requests, reinterpret_cast<const sockaddr*>(&_address), sizeof(_address)) == 0
					? Result::Primary : Result::Error;
#endif
			}
			if (errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR) return Result::Error;
#if defined(__linux__)
			// Linux deliberately does not activate windows: X11 and Wayland
			// must share one predictable single-instance policy.
			if (errno == EWOULDBLOCK || errno == EAGAIN) return Result::Existing;
#else
			// Queue activation until the owner's window thread can handle it.
			if (sendto(_requests, "A", 1, 0, reinterpret_cast<const sockaddr*>(&_address), sizeof(_address)) == 1)
				return Result::Notified;
#endif
#endif
			std::this_thread::sleep_for(std::chrono::milliseconds(10));
		} while (std::chrono::steady_clock::now() < deadline);
		return Result::Error;
	}

	// Call only on the window thread. Coalesce bursts into one activation.
	bool takeActivationRequest(std::string& activationToken) {
		activationToken.clear();
#ifdef _WIN32
		return _event && WaitForSingleObject(_event, 0) == WAIT_OBJECT_0;
#elif defined(__linux__)
		return false;
#else
		bool requested = false;
		char buffer[4096];
		// Bound each poll so a flood of launches cannot starve the render thread.
		for (int i = 0; i < 16; ++i) {
			const auto size = recv(_requests, buffer, sizeof(buffer), 0);
			if (size <= 0) break;
			if (buffer[0] != 'A') continue;
			requested = true;
		}
		return requested;
#endif
	}

private:
	std::string _name;
#ifdef _WIN32
	HANDLE _mutex = nullptr;
	HANDLE _event = nullptr;
	HANDLE _mapping = nullptr;
	volatile LONG* _pid = nullptr;
	bool _owned = false;
#else
	int _lock = -1;
#if !defined(__linux__)
	int _requests = -1;
	std::string _path;
	sockaddr_un _address{};
#endif
#endif
};

} // namespace Dora
