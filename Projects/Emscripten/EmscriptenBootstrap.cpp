#include <emscripten.h>

#include "Const/Header.h"
#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Lua/LuaEngine.h"

#include <exception>
#include <string>

NS_DORA_BEGIN

namespace {

std::string escapeLuaString(const char* value) {
	std::string escaped;
	if (!value) return escaped;
	for (const char* current = value; *current; ++current) {
		switch (*current) {
			case '\\': escaped += "\\\\"; break;
			case '"': escaped += "\\\""; break;
			case '\n': escaped += "\\n"; break;
			case '\r': escaped += "\\r"; break;
			case '\0': return {};
			default: escaped += *current; break;
		}
	}
	return escaped;
}

} // namespace

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_run_project(const char* root) {
	try {
		const auto escapedRoot = escapeLuaString(root);
		if (escapedRoot.empty()) return 0;
		SharedApplication.invokeInLogic([escapedRoot]() {
			try {
				const auto code =
					"local runner = require(\"Script.Dev.WebRunner\"); "
					"local ok = runner.runProject(\"" + escapedRoot + "\"); "
					"return ok == true";
				if (!SharedLuaEngine.executeString(code)) {
					LogError("Web project launch request failed.");
				}
			} catch (const std::exception& e) {
				LogError(std::string("Web project launch failed: ") + e.what());
			} catch (...) {
				LogError("Web project launch failed with an unknown exception.");
			}
		});
		return 1;
	} catch (const std::exception& e) {
		LogError(std::string("Web project launch failed: ") + e.what());
		return 0;
	} catch (...) {
		LogError("Web project launch failed with an unknown exception.");
		return 0;
	}
}

NS_DORA_END

namespace {

void mainLoop() { }

} // namespace

int main() {
	emscripten_set_main_loop(mainLoop, 0, true);
	return 0;
}
