-- bgfx, bimg, bx, shaderc 构建脚本
-- 用法: xmake build [bx|bimg|bimg_decode|bgfx|shaderc-libs]

-- 设置项目
set_project("bgfx-libs")
set_version("1.0.0")
set_languages("c++20")

-- MSVC 需要此选项来正确报告 C++ 标准版本
if is_plat("windows") then
    add_cxxflags("/Zc:__cplusplus", {force = true})
end

-- 源码路径配置
local BGFX_DIR = os.scriptdir()
local BIMG_DIR = path.join(BGFX_DIR, "../bimg")
local BX_DIR = path.join(BGFX_DIR, "../bx")

-- 通用配置
add_rules("mode.debug", "mode.release")

-- 配置选项
option("with-amalgamated", {default = true, description = "Use amalgamated build"})
option("with-shared", {default = false, description = "Build shared library"})

-- 平台相关链接库
local function add_platform_links()
    if is_plat("linux") then
        add_syslinks("X11", "GL", "pthread", "dl")
    elseif is_plat("macosx") then
        -- GENie 脚本中的完整框架列表
        add_frameworks("Cocoa", "IOKit", "OpenGL", "QuartzCore")
        -- Metal 框架使用 weak linking（旧系统可能没有）
        add_ldflags("-weak_framework", "Metal", "-weak_framework", "MetalKit", {force = true})
    elseif is_plat("windows") then
        add_syslinks("gdi32", "psapi", "dxgi", "d3d11", "d3d12", "opengl32")
    elseif is_plat("android") then
        add_syslinks("EGL", "GLESv3", "android")
    end
end

-- bx 基础库
target("bx")
    set_kind("static")
    
    add_includedirs(path.join(BX_DIR, "include"), {public = true})
    add_includedirs(path.join(BX_DIR, "3rdparty"), {public = true})
    
    -- 平台特定的 compat 头文件目录
    -- xmake 平台名称: macosx, iphoneos, linux, windows, android
    if is_plat("macosx") then
        add_includedirs(path.join(BX_DIR, "include/compat/osx"), {public = true})
    elseif is_plat("iphoneos") then
        add_includedirs(path.join(BX_DIR, "include/compat/ios"), {public = true})
    elseif is_plat("linux") then
        add_includedirs(path.join(BX_DIR, "include/compat/linux"), {public = true})
        add_cxxflags("-fPIC", {force = true})
    elseif is_plat("windows") then
        add_includedirs(path.join(BX_DIR, "include/compat/msvc"), {public = true})
    elseif is_plat("android") then
        -- Android 使用 linux compat 或 NDK 标准头文件
        add_includedirs(path.join(BX_DIR, "include/compat/linux"), {public = true})
    end
    
    if has_config("with-amalgamated") then
        add_files(path.join(BX_DIR, "src/amalgamated.cpp"))
    else
        add_files(path.join(BX_DIR, "src/*.cpp"))
        remove_files(path.join(BX_DIR, "src/amalgamated.cpp"))
    end
    
    -- BX_CONFIG_DEBUG 必须对所有依赖 bx 的代码可见
    if is_mode("debug") then
        add_defines("BX_CONFIG_DEBUG=1", {public = true})
    else
        add_defines("BX_CONFIG_DEBUG=0", {public = true})
    end

-- bimg 图像库核心
target("bimg")
    set_kind("static")
    add_deps("bx")
    
    add_includedirs(path.join(BIMG_DIR, "include"), {public = true})
    add_includedirs(path.join(BIMG_DIR, "3rdparty"), {public = true})
    add_includedirs(path.join(BIMG_DIR, "3rdparty/astc-encoder/include"))
    
    add_files(path.join(BIMG_DIR, "src/image.cpp"))
    add_files(path.join(BIMG_DIR, "src/image_gnf.cpp"))
    add_files(path.join(BIMG_DIR, "3rdparty/astc-encoder/source/*.cpp"))
    
    -- astc-encoder 不支持 FastMath
    set_fpmodels("precise")
    
    if is_plat("linux", "android") then
        add_cxxflags("-fPIC", {force = true})
    end

-- bimg_decode 图像解码库
target("bimg_decode")
    set_kind("static")
    add_deps("bx")
    
    add_includedirs(path.join(BIMG_DIR, "include"), {public = true})
    add_includedirs(path.join(BIMG_DIR, "3rdparty"))
    add_includedirs(path.join(BIMG_DIR, "3rdparty/tinyexr/deps/miniz"))
    
    add_files(path.join(BIMG_DIR, "src/image_decode.cpp"))
    add_files(path.join(BIMG_DIR, "3rdparty/tinyexr/deps/miniz/miniz.c"))
    
    if is_plat("linux", "android") then
        add_cxxflags("-fPIC", {force = true})
    end

-- bgfx 渲染库
target("bgfx")
    set_kind("static")
    add_deps("bx", "bimg", "bimg_decode")
    
    add_includedirs(path.join(BGFX_DIR, "include"), {public = true})
    add_includedirs(path.join(BGFX_DIR, "3rdparty"), {public = true})
    add_includedirs(path.join(BGFX_DIR, "3rdparty/renderdoc"), {public = true})
    add_includedirs(path.join(BIMG_DIR, "include"))
    add_includedirs(path.join(BX_DIR, "include"))
    
    if has_config("with-amalgamated") then
        -- macOS/iOS 使用 amalgamated.mm (包含 Metal 渲染器)
        if is_plat("macosx", "iphoneos") then
            add_files(path.join(BGFX_DIR, "src/amalgamated.mm"))
            -- bgfx 使用手动引用计数，需要禁用 ARC
            add_mxxflags("-fno-objc-arc", {force = true})
        else
            add_files(path.join(BGFX_DIR, "src/amalgamated.cpp"))
        end
    else
        add_files(path.join(BGFX_DIR, "src/*.cpp"))
        if is_plat("macosx", "iphoneos") then
            -- GENie 只包含 renderer_*.mm，不是所有 .mm 文件
            add_files(path.join(BGFX_DIR, "src/renderer_*.mm"))
            add_mxxflags("-fno-objc-arc", {force = true})
        end
        remove_files(path.join(BGFX_DIR, "src/amalgamated.*"))
        
        -- 排除 Windows 专用文件（非 Windows 平台）
        if not is_plat("windows") then
            remove_files(path.join(BGFX_DIR, "src/dxgi.cpp"))
            remove_files(path.join(BGFX_DIR, "src/glcontext_wgl.cpp"))
            remove_files(path.join(BGFX_DIR, "src/nvapi.cpp"))
            remove_files(path.join(BGFX_DIR, "src/renderer_d3d11.cpp"))
            remove_files(path.join(BGFX_DIR, "src/renderer_d3d12.cpp"))
        end
        
        -- 排除主机平台专用文件
        remove_files(path.join(BGFX_DIR, "src/renderer_agc.cpp"))   -- PS5
        remove_files(path.join(BGFX_DIR, "src/renderer_gnm.cpp"))   -- PS4
        remove_files(path.join(BGFX_DIR, "src/renderer_nvn.cpp"))   -- Nintendo Switch
        remove_files(path.join(BGFX_DIR, "src/glcontext_html5.cpp")) -- Web/Emscripten
    end
    
    add_includedirs(path.join(BGFX_DIR, "3rdparty/khronos"))
    
    add_platform_links()
    
    if is_plat("linux", "android") then
        add_cxxflags("-fPIC", {force = true})
    end
    
    if is_mode("debug") then
        add_defines("BGFX_CONFIG_DEBUG=1")
    else
        add_defines("BGFX_CONFIG_DEBUG=0")
    end

-- 共享库版本（可选）
if has_config("with-shared") then
    target("bgfx-shared")
        set_kind("shared")
        add_deps("bx", "bimg", "bimg_decode")
        
        add_defines("BGFX_SHARED_LIB_BUILD=1", {public = true})
        
        add_includedirs(path.join(BGFX_DIR, "include"), {public = true})
        add_includedirs(path.join(BGFX_DIR, "3rdparty"), {public = true})
        add_includedirs(path.join(BGFX_DIR, "3rdparty/renderdoc"), {public = true})
        add_includedirs(path.join(BIMG_DIR, "include"))
        add_includedirs(path.join(BX_DIR, "include"))
        
        if has_config("with-amalgamated") then
            if is_plat("macosx", "iphoneos") then
                add_files(path.join(BGFX_DIR, "src/amalgamated.mm"))
                add_mxxflags("-fno-objc-arc", {force = true})
            else
                add_files(path.join(BGFX_DIR, "src/amalgamated.cpp"))
            end
        else
            add_files(path.join(BGFX_DIR, "src/*.cpp"))
            if is_plat("macosx", "iphoneos") then
                add_files(path.join(BGFX_DIR, "src/renderer_*.mm"))
                add_mxxflags("-fno-objc-arc", {force = true})
            end
            remove_files(path.join(BGFX_DIR, "src/amalgamated.*"))
            
            -- 排除 Windows 专用文件（非 Windows 平台）
            if not is_plat("windows") then
                remove_files(path.join(BGFX_DIR, "src/dxgi.cpp"))
                remove_files(path.join(BGFX_DIR, "src/glcontext_wgl.cpp"))
                remove_files(path.join(BGFX_DIR, "src/nvapi.cpp"))
                remove_files(path.join(BGFX_DIR, "src/renderer_d3d11.cpp"))
                remove_files(path.join(BGFX_DIR, "src/renderer_d3d12.cpp"))
            end
            
            -- 排除主机平台专用文件
            remove_files(path.join(BGFX_DIR, "src/renderer_agc.cpp"))
            remove_files(path.join(BGFX_DIR, "src/renderer_gnm.cpp"))
            remove_files(path.join(BGFX_DIR, "src/renderer_nvn.cpp"))
            remove_files(path.join(BGFX_DIR, "src/glcontext_html5.cpp"))
        end
        
        add_platform_links()
        
        if is_plat("linux", "android") then
            add_cxxflags("-fPIC", {force = true})
        end
end

-- ============================================================
-- shaderc 相关库
-- ============================================================

local GLSLANG_DIR = path.join(BGFX_DIR, "3rdparty/glslang")
local SPIRV_CROSS_DIR = path.join(BGFX_DIR, "3rdparty/spirv-cross")
local SPIRV_HEADERS_DIR = path.join(BGFX_DIR, "3rdparty/spirv-headers")
local SPIRV_TOOLS_DIR = path.join(BGFX_DIR, "3rdparty/spirv-tools")
local GLSL_OPTIMIZER_DIR = path.join(BGFX_DIR, "3rdparty/glsl-optimizer")
local FCPP_DIR = path.join(BGFX_DIR, "3rdparty/fcpp")

-- fcpp - C 预处理器
target("fcpp")
    set_kind("static")
    set_languages("c11")
    
    add_files(
        path.join(FCPP_DIR, "cpp1.c"),
        path.join(FCPP_DIR, "cpp2.c"),
        path.join(FCPP_DIR, "cpp3.c"),
        path.join(FCPP_DIR, "cpp4.c"),
        path.join(FCPP_DIR, "cpp5.c"),
        path.join(FCPP_DIR, "cpp6.c")
    )
    add_includedirs(FCPP_DIR)
    
    add_defines(
        "NINCLUDE=64",
        "NWORK=65536",
        "NBUFF=65536",
        "OLD_PREPROCESSOR=0"
    )
    
    -- C 编译器警告抑制 (GCC/Clang only)
    if not is_plat("windows") then
        add_cflags("-Wno-implicit-fallthrough", "-Wno-incompatible-pointer-types", "-Wno-parentheses-equality", {force = true})
    end

-- spirv-cross
target("spirv-cross")
    set_kind("static")
    
    add_defines("SPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS")
    
    add_includedirs(path.join(SPIRV_CROSS_DIR, "include"))
    add_includedirs(SPIRV_CROSS_DIR)
    
    add_files(
        path.join(SPIRV_CROSS_DIR, "spirv_cfg.cpp"),
        path.join(SPIRV_CROSS_DIR, "spirv_cross.cpp"),
        path.join(SPIRV_CROSS_DIR, "spirv_cross_parsed_ir.cpp"),
        path.join(SPIRV_CROSS_DIR, "spirv_cross_util.cpp"),
        path.join(SPIRV_CROSS_DIR, "spirv_glsl.cpp"),
        path.join(SPIRV_CROSS_DIR, "spirv_hlsl.cpp"),
        path.join(SPIRV_CROSS_DIR, "spirv_msl.cpp"),
        path.join(SPIRV_CROSS_DIR, "spirv_parser.cpp"),
        path.join(SPIRV_CROSS_DIR, "spirv_reflect.cpp")
    )
    
    if not is_plat("windows") then
        add_cxxflags("-Wno-type-limits", {force = true})
    end

-- spirv-opt (来自 spirv-tools)
target("spirv-opt")
    set_kind("static")
    
    add_includedirs(
        SPIRV_TOOLS_DIR,
        path.join(SPIRV_TOOLS_DIR, "include"),
        path.join(SPIRV_TOOLS_DIR, "include/generated"),
        path.join(SPIRV_TOOLS_DIR, "source"),
        path.join(SPIRV_HEADERS_DIR, "include")
    )
    
    -- libspirv 核心
    add_files(
        path.join(SPIRV_TOOLS_DIR, "source/assembly_grammar.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/binary.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/diagnostic.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/disassemble.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/ext_inst.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/extensions.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/libspirv.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/name_mapper.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/opcode.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/operand.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/parsed_operand.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/print.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/software_version.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/spirv_endian.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/spirv_optimizer_options.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/spirv_reducer_options.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/spirv_target_env.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/spirv_validator_options.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/table.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/table2.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/text.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/text_handler.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/to_string.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/util/bit_vector.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/util/parse_number.cpp"),
        path.join(SPIRV_TOOLS_DIR, "source/util/string_utils.cpp")
    )
    
    -- opt 优化器
    add_files(path.join(SPIRV_TOOLS_DIR, "source/opt/*.cpp"))
    
    -- val 验证器
    add_files(path.join(SPIRV_TOOLS_DIR, "source/val/*.cpp"))
    
    -- reduce
    add_files(path.join(SPIRV_TOOLS_DIR, "source/reduce/*.cpp"))
    
    if not is_plat("windows") then
        add_cxxflags("-Wno-switch", {force = true})
    end
    if is_plat("linux", "android") then
        add_cxxflags("-fPIC", {force = true})
    end

-- glslang - GLSL/HLSL 解析器
target("glslang")
    set_kind("static")
    add_deps("spirv-opt")
    
    add_defines("ENABLE_OPT=1", "ENABLE_HLSL=1")
    
    add_includedirs(
        GLSLANG_DIR,
        path.join(GLSLANG_DIR, ".."),
        path.join(SPIRV_TOOLS_DIR, "include"),
        path.join(SPIRV_TOOLS_DIR, "source")
    )
    
    -- glslang 核心
    add_files(
        path.join(GLSLANG_DIR, "glslang/GenericCodeGen/*.cpp"),
        path.join(GLSLANG_DIR, "glslang/MachineIndependent/*.cpp"),
        path.join(GLSLANG_DIR, "glslang/MachineIndependent/preprocessor/*.cpp")
    )
    
    -- OSDependent
    if is_plat("windows") then
        add_files(path.join(GLSLANG_DIR, "glslang/OSDependent/Windows/*.cpp"))
    else
        add_files(path.join(GLSLANG_DIR, "glslang/OSDependent/Unix/*.cpp"))
    end
    
    -- CInterface
    add_files(path.join(GLSLANG_DIR, "glslang/CInterface/*.cpp"))
    
    -- HLSL 支持
    add_files(path.join(GLSLANG_DIR, "glslang/HLSL/*.cpp"))
    
    -- SPIRV 输出
    add_files(
        path.join(GLSLANG_DIR, "SPIRV/GlslangToSpv.cpp"),
        path.join(GLSLANG_DIR, "SPIRV/InReadableOrder.cpp"),
        path.join(GLSLANG_DIR, "SPIRV/Logger.cpp"),
        path.join(GLSLANG_DIR, "SPIRV/SPVRemapper.cpp"),
        path.join(GLSLANG_DIR, "SPIRV/SpvPostProcess.cpp"),
        path.join(GLSLANG_DIR, "SPIRV/SpvTools.cpp"),
        path.join(GLSLANG_DIR, "SPIRV/SpvBuilder.cpp"),
        path.join(GLSLANG_DIR, "SPIRV/disassemble.cpp"),
        path.join(GLSLANG_DIR, "SPIRV/doc.cpp")
    )
    
    -- SPIRV CInterface
    add_files(path.join(GLSLANG_DIR, "SPIRV/CInterface/*.cpp"))
    
    if not is_plat("windows") then
        add_cxxflags(
            "-fno-strict-aliasing",
            "-Wno-ignored-qualifiers",
            "-Wno-implicit-fallthrough",
            "-Wno-missing-field-initializers",
            "-Wno-reorder",
            "-Wno-return-type",
            "-Wno-shadow",
            "-Wno-sign-compare",
            "-Wno-switch",
            "-Wno-undef",
            "-Wno-unknown-pragmas",
            "-Wno-unused-function",
            "-Wno-unused-parameter",
            "-Wno-unused-variable",
            {force = true}
        )
    end
    
    if is_plat("macosx") then
        add_cxxflags("-Wno-c++11-extensions", "-Wno-unused-const-variable", "-Wno-deprecated-register", {force = true})
    end
    
    if is_plat("linux", "android") then
        add_cxxflags("-fPIC", {force = true})
    end

-- glsl-optimizer
target("glsl-optimizer")
    set_kind("static")
    
    add_includedirs(
        path.join(GLSL_OPTIMIZER_DIR, "src"),
        path.join(GLSL_OPTIMIZER_DIR, "include"),
        path.join(GLSL_OPTIMIZER_DIR, "src/mesa"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl")
    )
    
    -- glcpp 预处理器
    add_files(
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/glcpp-lex.c"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/glcpp-parse.c"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/pp.c")
    )
    
    -- glsl 优化器核心
    add_files(
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ast_array_index.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ast_expr.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ast_function.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ast_to_hir.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ast_type.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/builtin_functions.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/builtin_types.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/builtin_variables.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glsl_lexer.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glsl_optimizer.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glsl_parser.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glsl_parser_extras.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glsl_symbol_table.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glsl_types.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/hir_field_selection.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_basic_block.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_builder.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_clone.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_constant_expression.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_equals.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_expression_flattening.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_function.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_function_can_inline.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_function_detect_recursion.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_hierarchical_visitor.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_hv_accept.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_import_prototypes.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_print_glsl_visitor.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_print_metal_visitor.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_print_visitor.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_rvalue_visitor.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_stats.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_unused_structs.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_validate.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/ir_variable_refcount.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/link_atomics.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/link_functions.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/link_interface_blocks.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/link_uniform_block_active_visitor.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/link_uniform_blocks.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/link_uniform_initializers.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/link_uniforms.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/link_varyings.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/linker.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/loop_analysis.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/loop_controls.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/loop_unroll.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_clip_distance.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_discard.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_discard_flow.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_if_to_cond_assign.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_instructions.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_jumps.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_mat_op_to_vec.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_noise.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_offset_array.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_output_reads.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_packed_varyings.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_packing_builtins.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_ubo_reference.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_variable_index_to_cond_assign.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_vec_index_to_cond_assign.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_vec_index_to_swizzle.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_vector.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_vector_insert.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/lower_vertex_id.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_algebraic.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_array_splitting.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_constant_folding.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_constant_propagation.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_constant_variable.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_copy_propagation.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_copy_propagation_elements.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_cse.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_dead_builtin_variables.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_dead_builtin_varyings.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_dead_code.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_dead_code_local.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_dead_functions.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_flatten_nested_if_blocks.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_flip_matrices.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_function_inlining.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_if_simplification.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_minmax.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_noop_swizzle.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_rebalance_tree.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_redundant_jumps.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_structure_splitting.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_swizzle_swizzle.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_tree_grafting.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/opt_vectorize.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/s_expression.cpp"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/strtod.c")
    )
    
    -- mesa 支持
    add_files(
        path.join(GLSL_OPTIMIZER_DIR, "src/mesa/main/imports.c"),
        path.join(GLSL_OPTIMIZER_DIR, "src/mesa/program/prog_hash_table.c"),
        path.join(GLSL_OPTIMIZER_DIR, "src/mesa/program/symbol_table.c"),
        path.join(GLSL_OPTIMIZER_DIR, "src/util/hash_table.c"),
        path.join(GLSL_OPTIMIZER_DIR, "src/util/ralloc.c")
    )
    
    if not is_plat("windows") then
        add_cxxflags(
            "-fno-strict-aliasing",
            "-Wno-implicit-fallthrough",
            "-Wno-parentheses",
            "-Wno-sign-compare",
            "-Wno-unused-function",
            "-Wno-unused-parameter",
            {force = true}
        )
    end
    
    if is_plat("macosx") then
        add_cxxflags("-Wno-deprecated-register", {force = true})
    end

-- shaderc-lib - 着色器编译静态库
target("shaderc-lib")
    set_kind("static")
    add_deps("bx", "fcpp", "glslang", "glsl-optimizer", "spirv-cross")
    
    add_includedirs(
        path.join(BIMG_DIR, "include"),
        path.join(BGFX_DIR, "include"),
        FCPP_DIR,
        path.join(GLSLANG_DIR, "glslang/Public"),
        path.join(GLSLANG_DIR, "glslang/Include"),
        GLSLANG_DIR,
        path.join(GLSL_OPTIMIZER_DIR, "include"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl"),
        SPIRV_CROSS_DIR,
        path.join(SPIRV_TOOLS_DIR, "include")
    )
    
    -- Windows 特定包含
    if is_plat("windows") then
        add_includedirs(path.join(BGFX_DIR, "3rdparty/dxsdk/include"))
    end
    
    add_files(
        path.join(BGFX_DIR, "tools/shaderc/*.cpp"),
        path.join(BGFX_DIR, "src/vertexlayout.cpp"),
        path.join(BGFX_DIR, "src/shader.cpp"),
        path.join(BGFX_DIR, "src/shader_dxbc.cpp"),
        path.join(BGFX_DIR, "src/shader_spirv.cpp")
    )
    
    if is_plat("macosx") then
        add_frameworks("Cocoa")
    elseif is_plat("linux", "android") then
        add_syslinks("pthread")
        add_cxxflags("-fPIC", {force = true})
    end
