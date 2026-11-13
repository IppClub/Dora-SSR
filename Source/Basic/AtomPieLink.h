#pragma once

#include <initializer_list>
#include <string_view>

namespace Dora {

inline constexpr std::string_view AtomPieDesktopLink = "dora-ssr://open?asset=";
inline constexpr std::string_view AtomPieAndroidLink = "https://atompie.osgame.org/open-in-dora/";

inline std::string_view atomPieAssetId(std::string_view link) {
	// Windows Shell adds a slash after the host when launching a protocol handler.
	for (auto prefix : {AtomPieDesktopLink, std::string_view("dora-ssr://open/?asset="), AtomPieAndroidLink}) {
		if (link.compare(0, prefix.size(), prefix) != 0) continue;
		auto id = link.substr(prefix.size());
		if (id.empty() || id.front() == '0' || id.size() > 10
			|| (id.size() == 10 && id > "2147483647")
			|| id.find_first_not_of("0123456789") != std::string_view::npos) return {};
		return id;
	}
	return {};
}

} // namespace Dora
