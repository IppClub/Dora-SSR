set_project("love")
set_version("11.5")
set_languages("cxx20")
add_rules("mode.debug", "mode.release")

target("openmpt")
    set_kind("object")
    set_languages("c99", "cxx17")
    add_files(
        "../libopenmpt/common/*.cpp",
        "../libopenmpt/soundlib/*.cpp",
        "../libopenmpt/soundlib/plugins/*.cpp",
        "../libopenmpt/soundlib/plugins/dmo/*.cpp",
        "../libopenmpt/sounddsp/*.cpp",
        "../libopenmpt/libopenmpt/libopenmpt_c.cpp",
        "../libopenmpt/libopenmpt/libopenmpt_cxx.cpp",
        "../libopenmpt/libopenmpt/libopenmpt_impl.cpp",
        "../libopenmpt/libopenmpt/libopenmpt_ext_impl.cpp",
        "../libopenmpt/include/miniz/miniz.c"
    )
    add_includedirs("../libopenmpt", "../libopenmpt/common", "../libopenmpt/include")
    add_defines("LIBOPENMPT_BUILD", "MPT_WITH_MINIZ")

    if is_plat("macosx") then
        set_toolchains("xcode", {target_minver = "11.3"})
    elseif is_plat("iphoneos") then
        set_toolchains("xcode", {target_minver = "13.0"})
    end

    if is_plat("windows") then
        add_defines("_CRT_SECURE_NO_WARNINGS", "NOMINMAX", "_USE_MATH_DEFINES")
        add_cxxflags("/utf-8", {tools = "cl"})
        if is_mode("debug") then
            set_runtimes("MTd")
            add_defines("_ITERATOR_DEBUG_LEVEL=0")
        else
            set_runtimes("MT")
        end
    elseif is_plat("android") then
        add_defines("_REENTRANT")
        add_cflags("-fPIC", {force = true})
        add_cxxflags("-fPIC", {force = true})
    else
        add_defines("_REENTRANT")
        add_cflags("-fvisibility=hidden", "-fPIC", {force = true})
        add_cxxflags("-fvisibility=hidden", "-fPIC", {force = true})
    end

-- Dora reuses LOVE's cross-C++/Lua Object and Proxy runtime. Platform modules,
-- the main loop, Box2D, SDL backends, and LOVE's bundled libraries are
-- deliberately not part of this target.
target("love")
    set_kind("static")
    set_basename("love")
    add_deps("openmpt")
    add_files(
        "src/common/Object.cpp",
        "src/common/types.cpp",
        "src/common/Reference.cpp",
        "src/common/Module.cpp",
        "src/common/Exception.cpp",
        "src/common/deprecation.cpp",
        "src/common/runtime.cpp"
    )
    add_files("../soloud/audiosource/openmpt/soloud_openmpt.cpp")
    add_includedirs("src", "src/modules", "../Lua", {public = true})
    add_includedirs("../soloud")
    add_defines("LOVE_PROXY_USERVALUES=5")

    if is_plat("macosx") then
        set_toolchains("xcode", {target_minver = "11.3"})
    elseif is_plat("iphoneos") then
        set_toolchains("xcode", {target_minver = "13.0"})
    end

    if is_plat("windows") then
        add_defines("_CRT_SECURE_NO_WARNINGS", "NOMINMAX", "_USE_MATH_DEFINES")
        add_cxxflags("/utf-8", {tools = "cl"})
        if is_mode("debug") then
            set_runtimes("MTd")
            add_defines("_ITERATOR_DEBUG_LEVEL=0")
        else
            set_runtimes("MT")
        end
    elseif is_plat("android") then
        add_defines("_REENTRANT")
        add_cflags("-fPIC", {force = true})
        add_cxxflags("-fPIC", {force = true})
    else
        add_defines("_REENTRANT")
        add_cflags("-fvisibility=hidden", "-fPIC", {force = true})
        add_cxxflags("-fvisibility=hidden", "-fPIC", {force = true})
    end
