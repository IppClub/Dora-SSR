#pragma once

#include <atomic>
#include <string>

struct lua_State;
namespace Dora {
int luaopen_dora_remix_voice(lua_State* L);
#if defined(__APPLE__)
std::string postAppleRemixVoice(const std::string& authorization, const std::string& contentType,
	const std::string& body, const std::atomic_bool& cancelled);
#endif
}
