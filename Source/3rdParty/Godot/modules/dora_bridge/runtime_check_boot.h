// Lazy compiler/import services initialize servers without starting a project.
#pragma once
#include "core/extension/libgodot.h"
#include "main/main.h"

#include <chrono>
#include <filesystem>
#include <fstream>
namespace DoraGodotServiceBoot {
template <class Runtime>
inline bool boot(Runtime &runtime, GDExtensionInitializationFunction extension_init, const char *display, const char *driver, const char *method) {
	std::error_code error;
	const auto previous = std::filesystem::current_path(error);
	if (error) {
		runtime.error = "Cannot preserve host working directory";
		return false;
	}
	const auto temporary = std::filesystem::temp_directory_path(error);
	if (error) {
		runtime.error = "Cannot locate temporary directory";
		return false;
	}
	std::filesystem::path directory;
	for (int attempt = 0; attempt < 32; ++attempt) {
		directory = temporary / ("dora-godot-service-" + std::to_string(std::chrono::steady_clock::now().time_since_epoch().count()) + "-" + std::to_string(attempt));
		if (std::filesystem::create_directory(directory, error)) {
			break;
		}
		directory.clear();
	}
	if (directory.empty()) {
		runtime.error = "Cannot create private Godot service project";
		return false;
	}
	{
		std::ofstream file(directory / "project.godot");
		file << "config_version=5\n[application]\nrun/main_scene=\"res://empty.tscn\"\n";
	}
	{
		std::ofstream file(directory / "empty.tscn");
		file << "[gd_scene format=3]\n[node name=\"Compiler\" type=\"Node\"]\n";
	}
	const auto encoded = directory.u8string();
	char executable[] = "Dora-Godot";
	char *args[] = { executable, (char *)"--path", (char *)encoded.c_str(), (char *)"--display-driver", (char *)display,
		(char *)"--rendering-driver", (char *)driver, (char *)"--rendering-method", (char *)method,
		(char *)"--audio-driver", (char *)"Dummy", (char *)"--accessibility-driver", (char *)"dummy",
		(char *)"--render-thread", (char *)"safe", (char *)"--disable-render-loop", (char *)"--disable-crash-handler" };
	runtime.instance = (GodotInstance *)libgodot_create_godot_instance(sizeof(args) / sizeof(args[0]), args, extension_init);
	const bool created = runtime.instance != nullptr;

	// Renderer caches belong to the process, never the disposable bootstrap or
	// a user project. Set this before setup2 initializes rendering services.
	if (created) {
		String backend = String::utf8(driver);
		if (backend.begins_with("opengl")) {
#ifdef WINDOWS_ENABLED
			backend = "wgl";
#else
			backend = "egl";
#endif
		}
		const String cache = OS::get_singleton()->get_cache_path().path_join("Dora/LibGodot-4.7.2/" + backend);
		if (DirAccess::make_dir_recursive_absolute(cache) == OK) {
			Engine::get_singleton()->set_shader_cache_path(cache);
		}
	}
	const Error setup = created ? Main::setup2(false) : ERR_CANT_CREATE;

	std::filesystem::current_path(previous, error);
	std::error_code cleanup;
	std::filesystem::remove_all(directory, cleanup);
	if (!created || setup != OK || error) {
		runtime.error = "Cannot initialize embedded Godot compiler/import services";
		if (runtime.instance) {
			runtime.terminated = true;
		}
		return false;
	}
	DoraGodotProject::unload(runtime.instance);
	return true;
}
} //namespace DoraGodotServiceBoot
