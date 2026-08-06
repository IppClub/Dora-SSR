set_project("theoradec")
set_version("1.2.0")
set_languages("c11")
add_rules("mode.debug", "mode.release")

target("theoradec")
    set_kind("static")
    set_basename("theoradec")
    add_files("TheoraSources.c")
    add_includedirs("include", "lib", "..", {public = true})

    if is_plat("macosx") then
        set_toolchains("xcode", {target_minver = "11.3"})
    elseif is_plat("iphoneos") then
        set_toolchains("xcode", {target_minver = "13.0"})
    end

    if is_plat("windows") then
        add_defines("_CRT_SECURE_NO_WARNINGS")
        if is_mode("debug") then
            set_runtimes("MTd")
        else
            set_runtimes("MT")
        end
    elseif is_plat("android") then
        add_cflags("-fPIC", {force = true})
    else
        add_cflags("-fvisibility=hidden", "-fPIC", {force = true})
    end
