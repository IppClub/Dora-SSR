local SDL_VERSION = "2.31.0"
local MACOS_TARGET_MINVER = "11.3"
local IOS_TARGET_MINVER = "13.0"

set_project("sdl2")
set_version(SDL_VERSION)
if is_plat("android") then
    -- Android's hidapi backend contains one genuine C++ translation unit.
    set_languages("c11", "cxx17")
else
    set_languages("c11")
end
add_rules("mode.debug", "mode.release")

local SDL_DIR = os.scriptdir()

rule("sdl2.wayland-protocols")
    on_load(function (target)
        if not target:is_plat("linux") then
            return
        end
        import("lib.detect.find_tool")
        local scanner = find_tool("wayland-scanner")
        assert(scanner, "wayland-scanner is required to build Dora's vendored SDL2 on Linux")
        local output_dir = path.join(os.projectdir(), "build/autogen/SDL2/wayland")
        os.mkdir(output_dir)
        for _, xml in ipairs(os.files(path.join(SDL_DIR, "wayland-protocols/*.xml"))) do
            local basename = path.basename(xml)
            local header = path.join(output_dir, basename .. "-client-protocol.h")
            local source = path.join(output_dir, basename .. "-protocol.c")
            os.execv(scanner.program, {"client-header", xml, header})
            os.execv(scanner.program, {"private-code", xml, source})
            target:add("files", source)
        end
        target:add("includedirs", output_dir)
    end)
rule_end()

local function add_source_includes()
    add_includedirs("include", "src", {public = true})
    for _, dir in ipairs(os.dirs(path.join(SDL_DIR, "src/**"))) do
        add_includedirs(path.relative(dir, SDL_DIR))
    end
end

local function add_common_sources()
    add_files(
        "src/*.c",
        "src/atomic/*.c",
        "src/audio/*.c",
        "src/audio/disk/*.c",
        "src/audio/dummy/*.c",
        "src/cpuinfo/*.c",
        "src/dynapi/*.c",
        "src/events/*.c",
        "src/file/*.c",
        "src/haptic/*.c",
        "src/joystick/*.c",
        "src/joystick/hidapi/*.c",
        "src/joystick/virtual/*.c",
        "src/libm/*.c",
        "src/locale/*.c",
        "src/misc/*.c",
        "src/power/*.c",
        "src/render/*.c",
        "src/render/software/*.c",
        "src/sensor/*.c",
        "src/sensor/dummy/*.c",
        "src/stdlib/*.c",
        "src/thread/*.c",
        "src/timer/*.c",
        "src/video/*.c",
        "src/video/dummy/*.c",
        "src/video/offscreen/*.c",
        "src/video/yuv2rgb/*.c"
    )
end

local function add_apple_common_sources()
    add_files(
        "src/audio/coreaudio/*.m",
        "src/file/cocoa/*.m",
        "src/filesystem/cocoa/*.m",
        "src/hidapi/SDL_hidapi.c",
        "src/joystick/darwin/*.c",
        "src/joystick/iphoneos/*.m",
        "src/loadso/dlopen/*.c",
        "src/power/macosx/*.c",
        "src/render/metal/*.m",
        "src/render/opengl/*.c",
        "src/render/opengles/*.c",
        "src/render/opengles2/*.c",
        "src/sensor/coremotion/*.m",
        "src/thread/pthread/*.c",
        "src/timer/unix/*.c"
    )
    add_frameworks("AudioToolbox", "AVFoundation", "CoreAudio", "CoreFoundation", "CoreGraphics", "CoreHaptics", "CoreVideo", "GameController", "Metal", "QuartzCore")
end

local function add_macos_sources()
    add_apple_common_sources()
    add_files(
        "src/haptic/darwin/*.c",
        "src/hidapi/mac/hid.c",
        "src/locale/macosx/*.m",
        "src/misc/macosx/*.m",
        "src/video/cocoa/*.m"
    )
    add_frameworks("AppKit", "Carbon", "Cocoa", "ForceFeedback", "IOKit")
end

local function add_ios_sources()
    add_apple_common_sources()
    add_files(
        "src/haptic/dummy/*.c",
        "src/hidapi/ios/hid.m",
        "src/joystick/iphoneos/*.m",
        "src/locale/macosx/*.m",
        "src/main/uikit/*.c",
        "src/misc/ios/*.m",
        "src/power/uikit/*.m",
        "src/video/uikit/*.m"
    )
    add_frameworks("CoreMotion", "Foundation", "UIKit")
end

local function add_android_sources()
    set_kind("shared")
    local ndk = get_config("ndk") or os.getenv("ANDROID_NDK_HOME") or os.getenv("NDK_ROOT")
    if not ndk then
        local home = os.getenv("HOME")
        if home then
            ndk = path.join(home, "Library/Android/sdk/ndk-bundle")
        end
    end
    if ndk then
        local cpufeatures_dir = path.join(ndk, "sources/android/cpufeatures")
        if os.isdir(cpufeatures_dir) then
            add_includedirs(cpufeatures_dir)
            add_files(path.join(cpufeatures_dir, "cpu-features.c"))
        end
    end
    add_files(
        "src/audio/aaudio/*.c",
        "src/audio/android/*.c",
        "src/audio/openslES/*.c",
        "src/core/android/*.c",
        "src/filesystem/android/*.c",
        "src/haptic/android/*.c",
        "src/hidapi/SDL_hidapi.c",
        "src/hidapi/android/hid.cpp",
        "src/joystick/android/*.c",
        "src/locale/android/*.c",
        "src/loadso/dlopen/*.c",
        "src/main/android/*.c",
        "src/misc/android/*.c",
        "src/power/android/*.c",
        "src/render/opengles/*.c",
        "src/render/opengles2/*.c",
        "src/sensor/android/*.c",
        "src/thread/pthread/*.c",
        "src/timer/unix/*.c",
        "src/video/android/*.c"
    )
    add_defines("ANDROID", "DLL_EXPORT")
    add_syslinks("android", "dl", "log", "OpenSLES")
end

local function add_windows_sources()
    add_files(
        "src/audio/directsound/*.c",
        "src/audio/wasapi/*.c",
        "src/audio/winmm/*.c",
        "src/core/windows/*.c",
        "src/filesystem/windows/*.c",
        "src/haptic/windows/*.c",
        "src/hidapi/SDL_hidapi.c",
        "src/hidapi/windows/hid.c",
        "src/joystick/windows/*.c",
        "src/loadso/windows/*.c",
        "src/locale/windows/*.c",
        "src/misc/windows/*.c",
        "src/power/windows/*.c",
        "src/render/direct3d/*.c",
        "src/render/direct3d11/*.c",
        "src/render/direct3d12/*.c",
        "src/sensor/windows/*.c",
        "src/thread/generic/SDL_syscond.c",
        "src/thread/windows/*.c",
        "src/timer/windows/*.c",
        "src/video/windows/*.c"
    )
    add_defines("WIN32", "_WINDOWS", "_CRT_SECURE_NO_WARNINGS", "SDL_MAIN_HANDLED")
    add_cxflags("/utf-8", {tools = "cl", force = true})
    add_syslinks("advapi32", "cfgmgr32", "dinput8", "dxguid", "gdi32", "imm32", "ole32", "oleaut32", "setupapi", "shell32", "user32", "uuid", "version", "winmm")
end

local function add_linux_sources()
    add_defines("HAVE_GCC_ATOMICS=1", "HAVE_LINUX_INPUT_H=1")
    add_files(
        "src/audio/alsa/*.c",
        "src/audio/pipewire/*.c",
        "src/audio/pulseaudio/*.c",
        "src/core/unix/*.c",
        "src/core/linux/SDL_dbus.c",
        "src/core/linux/SDL_evdev.c",
        "src/core/linux/SDL_evdev_capabilities.c",
        "src/core/linux/SDL_evdev_kbd.c",
        "src/core/linux/SDL_fcitx.c",
        "src/core/linux/SDL_ime.c",
        "src/core/linux/SDL_sandbox.c",
        "src/core/linux/SDL_threadprio.c",
        "src/filesystem/unix/*.c",
        "src/haptic/linux/*.c",
        "src/hidapi/SDL_hidapi.c",
        "src/joystick/linux/*.c",
        "src/joystick/steam/*.c",
        "src/loadso/dlopen/*.c",
        "src/locale/unix/*.c",
        "src/misc/unix/*.c",
        "src/power/linux/*.c",
        "src/render/opengl/*.c",
        "src/render/opengles/*.c",
        "src/render/opengles2/*.c",
        "src/thread/pthread/*.c",
        "src/timer/unix/*.c",
        "src/video/wayland/*.c",
        "src/video/x11/*.c"
    )
    local linux_triplet = is_arch("arm64", "aarch64") and "aarch64-linux-gnu" or "x86_64-linux-gnu"
    add_includedirs(
        "/usr/include/dbus-1.0",
        "/usr/include/libdecor-0",
        "/usr/include/pipewire-0.3",
        "/usr/include/spa-0.2",
        path.join("/usr/lib", linux_triplet, "dbus-1.0/include")
    )
    add_rules("sdl2.wayland-protocols")
    add_syslinks("dl", "m", "pthread", "rt")
end

local function add_emscripten_sources()
    add_files(
        "src/audio/emscripten/*.c",
        "src/filesystem/emscripten/*.c",
        "src/joystick/emscripten/*.c",
        "src/loadso/dlopen/*.c",
        "src/locale/emscripten/*.c",
        "src/misc/emscripten/*.c",
        "src/power/emscripten/*.c",
        "src/render/opengles2/*.c",
        "src/timer/unix/*.c",
        "src/video/emscripten/*.c"
    )
    if has_config("dora_web_pthreads") then
        add_files("src/thread/pthread/*.c")
        add_cxflags("-pthread", {force = true})
    end
    add_cxflags("-Wno-warn-absolute-paths", {force = true})
end

local function add_platform_sources()
    if is_plat("macosx") then
        add_macos_sources()
    elseif is_plat("iphoneos") then
        add_ios_sources()
    elseif is_plat("android") then
        add_android_sources()
    elseif is_plat("windows") then
        add_windows_sources()
    elseif is_plat("linux") then
        add_linux_sources()
    elseif is_plat("wasm") then
        add_emscripten_sources()
    else
        local plat = get_config("plat")
        if plat then
            assert(false, string.format("Unsupported SDL2 platform for Dora: %s", plat))
        end
    end
end

local function apply_common_settings()
    add_source_includes()
    add_common_sources()
    add_platform_sources()

    add_defines(
        "SDL_BUILD_MAJOR_VERSION=2",
        "SDL_BUILD_MINOR_VERSION=31",
        "SDL_BUILD_MICRO_VERSION=0"
    )

    if not is_plat("android") then
        add_defines("SDL_STATIC_LIB")
    end

    if is_plat("macosx") then
        set_toolchains("xcode", {target_minver = MACOS_TARGET_MINVER})
    elseif is_plat("iphoneos") then
        set_toolchains("xcode", {target_minver = IOS_TARGET_MINVER})
    end

    if is_plat("windows") then
        if is_mode("debug") then
            set_runtimes("MTd")
            add_defines("_ITERATOR_DEBUG_LEVEL=0")
        else
            set_runtimes("MT")
        end
    elseif is_plat("android") then
        add_cxflags("-fPIC", {force = true})
    else
        add_cxflags("-fvisibility=hidden", "-fPIC", {force = true})
    end
end

target("SDL2")
    set_kind("static")
    set_basename("SDL2")
    apply_common_settings()
