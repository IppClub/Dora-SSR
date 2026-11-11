// Native regression for the exact handoff used by Application.install.
#include "Basic/GuiInstance.h"
#include "Basic/WindowsUpdate.h"
#include <filesystem>
#include <fstream>
#include <string>

int wmain(int argc, wchar_t** argv) {
	wchar_t path[32768]{};
	if (!GetModuleFileNameW(nullptr, path, 32768)) return 10;
	const auto directory = std::filesystem::path(path).parent_path();
	const auto marker = directory / "restart-result.json";
	Dora::GuiInstance instance("dora-updater-restart-qa");
	const bool primary = instance.acquire() == Dora::GuiInstance::Result::Primary;
	if (GetEnvironmentVariableW(L"DORA_UPDATE_RESTART_CHILD", nullptr, 0)) {
		const bool correctDirectory = std::filesystem::current_path() == directory;
		std::ofstream(marker) << "{\"primary\":" << (primary ? "true" : "false")
			<< ",\"workingDirectoryMatches\":" << (correctDirectory ? "true" : "false") << "}";
		return primary && correctDirectory ? 0 : 11;
	}
	if (!primary) return 12;
	std::filesystem::remove(marker);
	SetEnvironmentVariableW(L"DORA_UPDATE_RESTART_CHILD", L"1");
	const bool old = argc > 1 && std::wstring(argv[1]) == L"--old";
	if (old) {
		std::wstring command = L"\"" + std::wstring(path) + L"\"";
		STARTUPINFOW startup{}; startup.cb = sizeof(startup);
		PROCESS_INFORMATION process{};
		if (!CreateProcessW(nullptr, command.data(), nullptr, nullptr, FALSE, CREATE_NO_WINDOW,
				nullptr, directory.c_str(), &startup, &process)) return 13;
		CloseHandle(process.hThread); CloseHandle(process.hProcess);
	} else if (!Dora::launchWindowsUpdateRestart(path, directory.wstring(), GetCurrentProcessId())) return 14;
	// The replacement must not attempt singleton admission while this owner lives.
	Sleep(3000);
	if (old) return std::filesystem::exists(marker) ? 0 : 15;
	return std::filesystem::exists(marker) ? 16 : 0;
}
