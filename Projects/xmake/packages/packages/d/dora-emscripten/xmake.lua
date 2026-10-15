package("dora-emscripten")
    set_kind("toolchain")
    set_homepage("https://emscripten.org/")
    set_description("Emscripten SDK installed with the host Python interpreter.")
    set_license("MIT")

    add_urls("https://github.com/emscripten-core/emsdk/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emscripten-core/emsdk.git")
    add_versions("6.0.0", "85c35c690ff6747243cb439076835c2a870df8cc5e8d304fe0800c69f6f6e265")

    on_check("macosx|arm64", "linux|arm64", function (package)
        local version = package:version()
        if package:is_plat("macosx") and version and version:lt("2.0.21") then
            raise("Emscripten before 2.0.21 does not support macOS arm64")
        end
        if package:is_plat("linux") and version and version:lt("3.1.58") then
            raise("Emscripten before 3.1.58 does not fully support Linux arm64")
        end
    end)

    on_load(function (package)
        package:addenv("PATH", "upstream/emscripten")
        package:addenv("PATH", ".")
        package:addenv("EMSDK", ".")
        package:mark_as_pathenv("EMSDK")
        package:mark_as_pathenv("EMSDK_NODE")
        if package:is_plat("windows") then
            package:mark_as_pathenv("EMSDK_PYTHON")
            package:mark_as_pathenv("JAVA_HOME")
        end
    end)

    on_install("windows|!arm*", "macosx", "linux", function (package)
        import("lib.detect.find_directory")
        import("lib.detect.find_tool")

        os.cp("*", package:installdir())
        local installdir = package:installdir()
        local version = package:version():rawstr()
        local python_name = package:is_plat("windows") and "python" or "python3"
        local python = assert(find_tool(python_name, {force = true}),
            "%s is required to bootstrap Emscripten", python_name)
        local emsdk = path.join(installdir, "emsdk.py")
        os.vrunv(python.program, {emsdk, "install", version})
        os.vrunv(python.program, {emsdk, "activate", version})
        package:addenv("EMSDK_PYTHON", python.program)

        local exe = package:is_plat("windows") and ".exe" or ""
        local node_bindir = find_directory("bin", {path.join(installdir, "node", "**")})
        if node_bindir then
            node_bindir = path.relative(node_bindir, installdir)
            package:addenv("PATH", node_bindir)
            package:addenv("EMSDK_NODE", path.join(node_bindir, "node" .. exe))
        end
        if package:is_plat("windows") then
            local bundled_python = find_directory("*", path.join(installdir, "python"))
            if bundled_python then
                bundled_python = path.relative(bundled_python, installdir)
                package:addenv("EMSDK_PYTHON", path.join(bundled_python, "python" .. exe))
            end
            local java = find_directory("*", path.join(installdir, "java"))
            if java then
                package:addenv("JAVA_HOME", path.relative(java, installdir))
            end
        end
    end)

    on_test(function ()
        local emcc = is_host("windows") and "emcc.bat" or "emcc"
        os.vrunv(emcc, {"--version"})
    end)
package_end()
