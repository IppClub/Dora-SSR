includes("../LuaSocket/xmake.lua")

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
        "../libopenmpt/libopenmpt/libopenmpt_ext_impl.cpp"
    )
    add_includedirs("../libopenmpt", "../libopenmpt/common", "../libopenmpt/include", "../Zip")
    add_defines("LIBOPENMPT_BUILD", "MPT_BUILD_DORA", "MPT_WITH_MINIZ")

    if is_plat("macosx") then
        set_toolchains("xcode", {target_minver = "11.3"})
    elseif is_plat("iphoneos") then
        set_toolchains("xcode", {target_minver = "13.0"})
    end

    if is_plat("windows", "mingw") then
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

-- LOVE 11.5 ships a locally modified Box2D 2.3.2. Keep it as a separate
-- object target so love.physics uses the exact upstream implementation while
-- Dora's native physics API continues to use PlayRho.
target("love-box2d")
    set_kind("object")
    set_languages("cxx11")
    add_files("src/libraries/Box2D/**/*.cpp")
    add_includedirs("src", "src/libraries")

    if is_plat("macosx") then
        set_toolchains("xcode", {target_minver = "11.3"})
    elseif is_plat("iphoneos") then
        set_toolchains("xcode", {target_minver = "13.0"})
    end

    if is_plat("windows") then
        add_defines("_CRT_SECURE_NO_WARNINGS", "NOMINMAX")
        add_cxxflags("/utf-8", {tools = "cl"})
        if is_mode("debug") then
            set_runtimes("MTd")
            add_defines("_ITERATOR_DEBUG_LEVEL=0")
        else
            set_runtimes("MT")
        end
    elseif is_plat("android") then
        add_cxxflags("-fPIC", {force = true})
    else
        add_cxxflags("-fvisibility=hidden", "-fPIC", {force = true})
    end

-- Dora reuses LOVE's cross-C++/Lua Object and Proxy runtime. Platform modules,
-- the main loop, SDL backends, and unrelated LOVE bundled libraries are
-- deliberately not part of this target. love.physics is the exception: it
-- uses LOVE's original Box2D implementation and wrappers for API fidelity.
target("love")
    set_kind("static")
    set_basename("love")
    set_languages("c99", "cxx20")
    add_deps("openmpt", "luasocket-objects", "love-box2d")
    add_files(
        "src/common/Object.cpp",
        "src/common/types.cpp",
        "src/common/Reference.cpp",
        "src/common/Module.cpp",
        "src/common/Exception.cpp",
        "src/common/deprecation.cpp",
        "src/common/runtime.cpp",
        "src/common/Matrix.cpp",
        "src/common/Data.cpp",
		"src/common/Variant.cpp",
        "src/common/StringMap.cpp",
        "src/common/b64.cpp",
        "src/common/pixelformat.cpp",
        "src/libraries/lz4/lz4.c",
        "src/libraries/lz4/lz4hc.c",
        "src/libraries/noise1234/noise1234.cpp",
        "src/libraries/noise1234/simplexnoise1234.cpp",
        "src/modules/math/BezierCurve.cpp",
        "src/modules/math/wrap_BezierCurve.cpp",
        "src/modules/math/MathModule.cpp",
        "src/modules/math/wrap_Math.cpp",
        "src/modules/math/RandomGenerator.cpp",
        "src/modules/math/wrap_RandomGenerator.cpp",
        "src/modules/math/Transform.cpp",
        "src/modules/math/wrap_Transform.cpp",
        "src/modules/data/ByteData.cpp",
        "src/modules/data/CompressedData.cpp",
        "src/modules/data/Compressor.cpp",
        "src/modules/data/DataModule.cpp",
        "src/modules/data/DataView.cpp",
        "src/modules/data/HashFunction.cpp",
        "src/modules/data/wrap_ByteData.cpp",
        "src/modules/data/wrap_CompressedData.cpp",
        "src/modules/data/wrap_Data.cpp",
        "src/modules/data/wrap_DataModule.cpp",
        "src/modules/data/wrap_DataView.cpp",
		"src/modules/audio/Filter.cpp",
		"src/modules/audio/Source.cpp",
		"src/modules/audio/wrap_Source.cpp",
		"src/modules/event/Event.cpp",
		"src/modules/event/wrap_Event.cpp",
		"src/modules/window/Window.cpp",
		"src/modules/window/wrap_Window.cpp",
		"src/modules/keyboard/Keyboard.cpp",
		"src/modules/keyboard/wrap_Keyboard.cpp",
		"src/modules/mouse/Cursor.cpp",
		"src/modules/mouse/wrap_Cursor.cpp",
		"src/modules/mouse/wrap_Mouse.cpp",
		"src/modules/touch/wrap_Touch.cpp",
		"src/modules/joystick/Joystick.cpp",
		"src/modules/joystick/wrap_Joystick.cpp",
		"src/modules/joystick/wrap_JoystickModule.cpp",
		"src/modules/physics/Body.cpp",
		"src/modules/physics/Shape.cpp",
		"src/modules/physics/Joint.cpp",
		"src/modules/physics/box2d/*.cpp",
        "src/modules/filesystem/File.cpp",
        "src/modules/filesystem/FileData.cpp",
        "src/modules/filesystem/Filesystem.cpp",
        "src/modules/filesystem/wrap_File.cpp",
        "src/modules/filesystem/wrap_FileData.cpp",
        "src/modules/filesystem/wrap_Filesystem.cpp",
        "src/modules/font/GlyphData.cpp",
        "src/modules/font/Rasterizer.cpp",
		"src/modules/font/TrueTypeRasterizer.cpp",
		"src/modules/font/wrap_Font.cpp",
		"src/modules/font/wrap_GlyphData.cpp",
		"src/modules/font/wrap_Rasterizer.cpp",
		"src/modules/graphics/Drawable.cpp",
		"src/modules/graphics/vertex.cpp",
		"src/modules/graphics/Font.cpp",
		"src/modules/graphics/Shader.cpp",
		"src/modules/graphics/Text.cpp",
		"src/modules/graphics/Video.cpp",
		"src/modules/graphics/Mesh.cpp",
		"src/modules/graphics/SpriteBatch.cpp",
		"src/modules/graphics/ParticleSystem.cpp",
		"src/modules/graphics/depthstencil.cpp",
		"src/modules/graphics/Texture.cpp",
		"src/modules/graphics/Canvas.cpp",
		"src/modules/graphics/wrap_Canvas.cpp",
		"src/modules/graphics/wrap_GraphicsCanvasConstructor.cpp",
		"src/modules/graphics/Image.cpp",
		"src/modules/graphics/Quad.cpp",
		"src/modules/graphics/wrap_Texture.cpp",
		"src/modules/graphics/wrap_GraphicsDraw.cpp",
		"src/modules/graphics/wrap_GraphicsDisplayState.cpp",
		"src/modules/graphics/wrap_GraphicsCapabilities.cpp",
		"src/modules/graphics/wrap_GraphicsInfo.cpp",
		"src/modules/graphics/wrap_GraphicsImageConstructor.cpp",
		"src/modules/graphics/wrap_GraphicsScreenshot.cpp",
		"src/modules/graphics/wrap_GraphicsFontState.cpp",
		"src/modules/graphics/wrap_GraphicsFontConstructor.cpp",
		"src/modules/graphics/wrap_GraphicsPrimitives.cpp",
		"src/modules/graphics/wrap_GraphicsPrint.cpp",
		"src/modules/graphics/wrap_GraphicsQuad.cpp",
		"src/modules/graphics/wrap_GraphicsShaderConstructor.cpp",
		"src/modules/graphics/wrap_GraphicsState.cpp",
		"src/modules/graphics/wrap_GraphicsShaderState.cpp",
		"src/modules/graphics/wrap_Image.cpp",
		"src/modules/graphics/wrap_Font.cpp",
		"src/modules/graphics/wrap_Shader.cpp",
		"src/modules/graphics/wrap_Text.cpp",
		"src/modules/graphics/wrap_Video.cpp",
		"src/modules/graphics/wrap_Mesh.cpp",
		"src/modules/graphics/wrap_SpriteBatch.cpp",
		"src/modules/graphics/wrap_ParticleSystem.cpp",
		"src/modules/graphics/wrap_Quad.cpp",
		"src/modules/image/ImageDataBase.cpp",
		"src/modules/image/CompressedSlice.cpp",
		"src/modules/image/CompressedImageData.cpp",
		"src/modules/image/FormatHandler.cpp",
		"src/modules/image/Image.cpp",
		"src/modules/image/ImageData.cpp",
		"src/modules/image/wrap_Image.cpp",
		"src/modules/image/wrap_ImageData.cpp",
		"src/modules/image/wrap_CompressedImageData.cpp",
		"src/modules/sound/Decoder.cpp",
		"src/modules/sound/Sound.cpp",
		"src/modules/sound/SoundData.cpp",
		"src/modules/sound/wrap_Decoder.cpp",
		"src/modules/sound/wrap_Sound.cpp",
		"src/modules/sound/wrap_SoundData.cpp",
		"src/modules/system/System.cpp",
		"src/modules/system/wrap_System.cpp",
		"src/modules/timer/wrap_Timer.cpp",
		"src/modules/thread/Channel.cpp",
		"src/modules/thread/LuaThread.cpp",
		"src/modules/thread/wrap_Channel.cpp",
		"src/modules/thread/wrap_LuaThread.cpp",
		"src/modules/thread/wrap_ThreadModule.cpp",
		"src/modules/video/wrap_VideoStream.cpp"
    )
    add_files("../soloud/audiosource/openmpt/soloud_openmpt.cpp")
    add_includedirs("src", "src/modules", "src/libraries", "../Lua", "../Zip/zlib", {public = true})
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
