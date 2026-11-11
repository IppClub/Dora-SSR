#pragma once

#ifdef _WIN32
#include <windows.h>
#include <string>

namespace Dora {

// Do not start the replacement GUI until teardown releases GuiInstance's lock.
// Keep this launcher independent of SDL so the real Windows handoff can be tested.
inline bool launchWindowsUpdateRestart(const std::wstring& executable, const std::wstring& directory, DWORD parentPid) {
	auto literal = [](const std::wstring& value) {
		std::wstring result = L"'";
		for (wchar_t ch : value) {
			result += ch;
			if (ch == L'\'') result += L'\'';
		}
		return result + L"'";
	};
	std::wstring command = L"powershell.exe -NoProfile -NonInteractive -Command \"& { "
		L"$ErrorActionPreference='Stop'; $parent = Get-Process -Id " + std::to_wstring(parentPid)
		+ L" -ErrorAction SilentlyContinue; if ($parent) { $parent.WaitForExit() }; "
		L"Start-Process -FilePath " + literal(executable) + L" -WorkingDirectory " + literal(directory) + L" }\"";
	STARTUPINFOW startup{};
	startup.cb = sizeof(startup);
	PROCESS_INFORMATION process{};
	if (!CreateProcessW(nullptr, command.data(), nullptr, nullptr, FALSE, CREATE_NO_WINDOW,
			nullptr, nullptr, &startup, &process)) return false;
	CloseHandle(process.hThread);
	CloseHandle(process.hProcess);
	return true;
}

} // namespace Dora
#endif
