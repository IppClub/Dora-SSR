#pragma once

#include <string>
#include <tuple>
#include <list>

namespace MoonP {

std::pair<std::string,std::string> moonCompile(const std::string& codes);
std::pair<std::string,std::string> moonCompile(const std::string& codes, std::list<std::string>& globals);

} // namespace MoonP
