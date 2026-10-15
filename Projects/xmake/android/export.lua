-- Export the configured Android target graph, not compiler/toolchain command
-- lines: Gradle's NDK toolchain owns the ABI, sysroot, STL and output directory.
import("core.project.config")
import("core.project.project")

function main(output)
    config.load()
    assert(config.plat() == "android", "configure xmake for Android before exporting")
    local root = os.projectdir()
    local lines = {"# Generated from xmake targets. Do not edit."}
    local targets, visited = {}, {}
    local preparation = { ["dora-lua-bindings"] = true, ["dora-rust-runtime"] = true }

    local function absolute(value)
        return (path.normalize(path.absolute(value, root)):gsub("\\", "/"))
    end
    local function quote(value)
        return '"' .. tostring(value):gsub("\\", "/"):gsub('"', '\\"'):gsub(";", "\\;") .. '"'
    end
    local function values(target, name)
        local result = {}
        for _, group in ipairs(target:get_from(name, "*")) do
            table.join2(result, table.wrap(group))
        end
        return table.unique(result)
    end
    local binding_outputs = assert(project.target("dora-lua-bindings")):values("dora.binding_outputs")
    local binding_set = {}
    local bindings = {"# Generated binding outputs from the xmake target.", "set(DORA_BINDING_OUTPUTS"}
    for _, file in ipairs(binding_outputs) do
        binding_set[absolute(file)] = true
        table.insert(bindings, "    " .. quote(absolute(file)))
    end
    table.insert(bindings, ")")
    local function emit(command, name, items, scope)
        if #items > 0 then
            table.insert(lines, command .. "(" .. name .. " " .. (scope or "PRIVATE"))
            for _, item in ipairs(items) do table.insert(lines, "    " .. quote(item)) end
            table.insert(lines, ")")
        end
    end
    local function collect(target)
        if visited[target:name()] then return end
        visited[target:name()] = true
        for _, name in ipairs(table.wrap(target:get("deps"))) do
            if not preparation[name] then
                local dependency = assert(project.target(name), "missing dependency: " .. name)
                assert(dependency:plat() == "android", "host target requires an explicit preparation adapter: " .. name)
                collect(dependency)
            end
        end
        assert(target:kind() == "shared" or target:kind() == "static" or target:kind() == "object",
            "unsupported Android CMake target: " .. target:name())
        table.insert(targets, target)
    end
    collect(assert(project.target("Dora")))

    -- Bootstrap bindings from the generator's declared outputs, not per-file
    -- metadata: xmake does not retain always_added in target:fileconfig().
    -- Do not mark source-tree files GENERATED: `ninja clean` must not delete
    -- these shared outputs or subsequent developer edits to them.
    local missing_bindings = false
    for _, file in ipairs(binding_outputs) do
        if not os.isfile(file) then
            missing_bindings = true
            break
        end
    end
    if missing_bindings then
        os.vrunv(os.programfile(), {"build", "dora-lua-bindings"}, {curdir = root})
    end

    for _, target in ipairs(targets) do
        local name = target:name()
        local sources = target:sourcefiles()
        assert(#sources > 0, "target has no sources: " .. name)
        local kind = target:kind() == "object" and "OBJECT" or target:kind():upper()
        table.insert(lines, "add_library(" .. name .. " " .. kind)
        for _, file in ipairs(sources) do
            assert(os.isfile(file), "missing Android native source: " .. file)
            table.insert(lines, "    " .. quote(absolute(file)))
        end
        table.insert(lines, ")")
        table.insert(lines, "set_target_properties(" .. name .. " PROPERTIES POSITION_INDEPENDENT_CODE ON OUTPUT_NAME " .. quote(target:basename()) .. ")")
        table.insert(lines, "add_dependencies(" .. name .. " dora_xmake_prepare)")

        for _, language in ipairs(table.wrap(target:get("languages"))) do
            local standard = language:match("^gnu(%d+)$") or language:match("^c(%d+)$")
            local cxx = language:match("^gnuxx(%d+)$") or language:match("^cxx(%d+)$")
            if standard or cxx then
                local prefix = cxx and "CXX" or "C"
                local extensions = language:startswith("gnu") and "ON" or "OFF"
                table.insert(lines, "set_target_properties(" .. name .. " PROPERTIES " .. prefix .. "_STANDARD " .. (cxx or standard) .. " " .. prefix .. "_STANDARD_REQUIRED ON " .. prefix .. "_EXTENSIONS " .. extensions .. ")")
            end
        end
        for _, field in ipairs({"includedirs", "sysincludedirs"}) do
            local dirs = {}
            for _, dir in ipairs(values(target, field)) do table.insert(dirs, absolute(dir)) end
            emit("target_include_directories", name, dirs, field == "sysincludedirs" and "SYSTEM PRIVATE" or "PRIVATE")
        end
        emit("target_compile_definitions", name, values(target, "defines"))
        for _, exception in ipairs(table.wrap(target:get("exceptions"))) do
            assert(exception == "cxx" or exception == "no-cxx", "unsupported Android exception mode: " .. exception)
            emit("target_compile_options", name, {"$<$<COMPILE_LANGUAGE:CXX>:" .. (exception == "no-cxx" and "-fno-exceptions" or "-fexceptions") .. ">"})
        end
        for _, model in ipairs(table.wrap(target:get("fpmodels"))) do
            local option = ({precise="-ffp-model=precise", fast="-ffp-model=fast", strict="-ffp-model=strict", except="-ftrapping-math", noexcept="-fno-trapping-math"})[model]
            assert(option, "unsupported Android floating point mode: " .. model)
            emit("target_compile_options", name, {option})
        end
        local function flags(info, field, language)
            local result = {}
            for _, flag in ipairs(info) do
                for _, token in ipairs(os.argv(flag)) do
                    table.insert(result, language and ("$<$<COMPILE_LANGUAGE:" .. language .. ">:" .. token .. ">") or token)
                end
            end
            return result
        end
        for _, field in ipairs({"cxflags", "cflags", "cxxflags", "asflags"}) do
            local language = ({cflags = "C", cxxflags = "CXX", asflags = "ASM"})[field]
            emit("target_compile_options", name, flags(values(target, field), field, language))
        end
        emit("target_link_options", name, values(target, "ldflags"))

        for _, file in ipairs(sources) do
            local info = target:fileconfig(file) or {}
            local options, definitions, directories = {}, {}, {}
            for _, field in ipairs({"cxflags", "cflags", "cxxflags", "asflags"}) do
                local raw = table.join(table.wrap(info[field]), table.wrap(info.force and info.force[field]))
                table.join2(options, flags(raw, field, ({cflags="C", cxxflags="CXX", asflags="ASM"})[field]))
            end
            table.join2(definitions, table.wrap(info.defines), table.wrap(info.force and info.force.defines))
            for _, dir in ipairs(table.join(table.wrap(info.includedirs), table.wrap(info.force and info.force.includedirs))) do
                table.insert(directories, absolute(dir))
            end
            local properties = {COMPILE_OPTIONS=options, COMPILE_DEFINITIONS=definitions, INCLUDE_DIRECTORIES=directories}
            for _, property in ipairs({"COMPILE_OPTIONS", "COMPILE_DEFINITIONS", "INCLUDE_DIRECTORIES"}) do
                local items = properties[property]
                if #items > 0 then
                    table.insert(lines, "set_property(SOURCE " .. quote(absolute(file)) .. " APPEND PROPERTY " .. property)
                    for _, item in ipairs(items) do table.insert(lines, "    " .. quote(item)) end
                    table.insert(lines, ")")
                end
            end
            if info.sourcekind then
                local language = ({cc="C", cxx="CXX", as="ASM"})[info.sourcekind]
                assert(language, "unsupported Android source kind: " .. info.sourcekind)
                assert(language ~= "CXX" or path.extension(file):lower() ~= ".c",
                    "C++ sources must use a C++ extension instead of forcing .c to C++: " .. file)
                table.insert(lines, "set_source_files_properties(" .. quote(absolute(file)) .. " PROPERTIES LANGUAGE " .. language .. ")")
            end
            if binding_set[absolute(file)] then
                table.insert(lines, "set_property(SOURCE " .. quote(absolute(file)) .. " APPEND PROPERTY OBJECT_DEPENDS \"${CMAKE_CURRENT_BINARY_DIR}/xmake-bindings.stamp\")")
            end
        end
    end

    -- Define every target before adding edges. CMake expands OBJECT libraries
    -- into their static consumers and carries static link dependencies forward.
    for _, target in ipairs(targets) do
        local links = {}
        for _, name in ipairs(table.wrap(target:get("deps"))) do
            if not preparation[name] then table.insert(links, name) end
        end
        table.join2(links, values(target, "links"), values(target, "syslinks"))
        for _, group in ipairs(table.wrap(target:get("linkgroups"))) do
            table.insert(links, "-Wl,--start-group")
            local function append(library)
                if type(library) == "table" then
                    for _, item in ipairs(library) do append(item) end
                else
                    table.insert(links, library:endswith(".a") and absolute(library) or library)
                end
            end
            append(group)
            table.insert(links, "-Wl,--end-group")
        end
        emit("target_link_libraries", target:name(), links)
    end
    local content = table.concat(lines, "\n") .. "\n"
    os.mkdir(path.directory(output))
    if not os.isfile(output) or io.readfile(output) ~= content then io.writefile(output, content) end
    local manifest = path.join(path.directory(output), "xmake-bindings.cmake")
    local binding_content = table.concat(bindings, "\n") .. "\n"
    if not os.isfile(manifest) or io.readfile(manifest) ~= binding_content then io.writefile(manifest, binding_content) end
    print("exported %d Android C/C++ targets (%s/%s)", #targets, config.arch(), config.mode())
end
