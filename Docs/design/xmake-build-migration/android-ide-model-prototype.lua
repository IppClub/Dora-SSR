-- Proof of concept only: export xmake's configured Dora source list for
-- Android Studio's CMake project model. This is not a Native build backend.
-- Run from the repository root: xmake l Docs/design/xmake-build-migration/android-ide-model-prototype.lua
import("core.project.project")
import("core.project.config")

config.load()

local target = assert(project.target("Dora"), "Dora xmake target is unavailable")
local root = os.projectdir()
local output = path.join(root, "build/android-ide-prototype/CMakeLists.txt")
local seen = {}
local sources = {}

for _, file in ipairs(target:sourcefiles()) do
    local absolute = path.normalize(path.absolute(file, root))
    if os.isfile(absolute) and not seen[absolute] then
        seen[absolute] = true
        table.insert(sources, absolute)
    end
end
table.sort(sources)

local lines = {
    "# Generated from the configured xmake Dora target; do not edit.",
    "cmake_minimum_required(VERSION 3.18.1)",
    "project(DoraXmakeIdePrototype LANGUAGES C CXX)",
    "file(WRITE \"${CMAKE_CURRENT_BINARY_DIR}/dora_ide_stub.c\" \"void dora_ide_stub(void) {}\\n\")",
    "add_library(dora_ide_model STATIC EXCLUDE_FROM_ALL \"${CMAKE_CURRENT_BINARY_DIR}/dora_ide_stub.c\")",
    "set(DORA_XMAKE_SOURCES"
}
for _, file in ipairs(sources) do
    table.insert(lines, string.format("    \"%s\"", file:gsub("\\", "/")))
end
table.insert(lines, ")")
table.insert(lines, "target_sources(dora_ide_model PRIVATE ${DORA_XMAKE_SOURCES})")
table.insert(lines, "target_include_directories(dora_ide_model PRIVATE")
for _, directory in ipairs(target:get("includedirs") or {}) do
    table.insert(lines, string.format("    \"%s\"", path.normalize(path.absolute(directory, root))))
end
table.insert(lines, ")")
table.insert(lines, "target_compile_definitions(dora_ide_model PRIVATE")
for _, define in ipairs(target:get("defines") or {}) do
    table.insert(lines, string.format("    \"%s\"", define))
end
table.insert(lines, ")")

os.mkdir(path.directory(output))
io.writefile(output, table.concat(lines, "\n") .. "\n")
print(string.format("generated %s with %d xmake sources", output, #sources))
