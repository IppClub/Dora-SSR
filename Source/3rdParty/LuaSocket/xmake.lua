set_project("luasocket")
set_version("3.1.0")
set_languages("c11")
add_rules("mode.debug", "mode.release")

local function configure_luasocket_target()
    add_files(
        "src/luasocket.c",
        "src/timeout.c",
        "src/buffer.c",
        "src/io.c",
        "src/auxiliar.c",
        "src/compat.c",
        "src/options.c",
        "src/inet.c",
        "src/except.c",
        "src/select.c",
        "src/tcp.c",
        "src/udp.c",
        "src/mime.c"
    )
    add_includedirs("src", "../Lua", {public = true})
    add_defines("LUASOCKET_NODEBUG")

    if is_plat("windows") then
        add_files("src/wsocket.c")
        add_defines("_CRT_SECURE_NO_WARNINGS", "_WIN32_WINNT=0x0601")
        if is_mode("debug") then
            set_runtimes("MTd")
        else
            set_runtimes("MT")
        end
    else
        add_files("src/usocket.c")
        if is_plat("macosx") then
            set_toolchains("xcode", {target_minver = "11.3"})
            add_defines("UNIX_HAS_SUN_LEN")
        elseif is_plat("iphoneos") then
            set_toolchains("xcode", {target_minver = "13.0"})
            add_defines("UNIX_HAS_SUN_LEN")
        elseif is_plat("android") then
            add_cflags("-fPIC", {force = true})
        else
            add_cflags("-fvisibility=hidden", "-fPIC", {force = true})
        end
    end
end

target("luasocket-objects")
    set_kind("object")
    configure_luasocket_target()

target("luasocket")
    set_kind("static")
    set_basename("luasocket")
    add_deps("luasocket-objects")
