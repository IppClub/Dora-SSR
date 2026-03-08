-- bgfx, bimg, bx, shaderc 构建脚本
-- 用法: xmake build [bx|bimg|bimg_decode|bgfx|shaderc-libs]

-- 设置项目
set_project("bgfx-libs")
set_version("1.0.0")
set_languages("c++20")

-- MSVC 需要这些选项来正确报告 C++ 标准版本和支持标准预处理器
if is_plat("windows") then
    add_cxxflags("/Zc:__cplusplus", "/Zc:preprocessor", {force = true})
end

-- 源码路径配置
local BGFX_DIR = os.scriptdir()
local BIMG_DIR = path.join(BGFX_DIR, "../bimg")
local BX_DIR = path.join(BGFX_DIR, "../bx")

-- 通用配置
add_rules("mode.debug", "mode.release")

-- 配置选项
option("with-shared", {default = false, description = "Build shared library"})

local function resolve_sources(base_dir, files)
    local resolved = {}
    for _, file in ipairs(files) do
        table.insert(resolved, path.join(base_dir, file))
    end
    return resolved
end

local bx_src = {
    "src/allocator.cpp",
    "src/bounds.cpp",
    "src/bx.cpp",
    "src/commandline.cpp",
    "src/crtnone.cpp",
    "src/debug.cpp",
    "src/dtoa.cpp",
    "src/easing.cpp",
    "src/file.cpp",
    "src/filepath.cpp",
    "src/hash.cpp",
    "src/math.cpp",
    "src/mutex.cpp",
    "src/os.cpp",
    "src/process.cpp",
    "src/semaphore.cpp",
    "src/settings.cpp",
    "src/sort.cpp",
    "src/string.cpp",
    "src/thread.cpp",
    "src/timer.cpp",
    "src/url.cpp",
}

local bimg_src = {
    "src/image.cpp",
    "src/image_gnf.cpp",
}

local bimg_decode_src = {
    "src/image_decode.cpp",
}

local astc_encoder_src = {
    "3rdparty/astc-encoder/source/astcenc_averages_and_directions.cpp",
    "3rdparty/astc-encoder/source/astcenc_block_sizes.cpp",
    "3rdparty/astc-encoder/source/astcenc_color_quantize.cpp",
    "3rdparty/astc-encoder/source/astcenc_color_unquantize.cpp",
    "3rdparty/astc-encoder/source/astcenc_compress_symbolic.cpp",
    "3rdparty/astc-encoder/source/astcenc_compute_variance.cpp",
    "3rdparty/astc-encoder/source/astcenc_decompress_symbolic.cpp",
    "3rdparty/astc-encoder/source/astcenc_diagnostic_trace.cpp",
    "3rdparty/astc-encoder/source/astcenc_entry.cpp",
    "3rdparty/astc-encoder/source/astcenc_find_best_partitioning.cpp",
    "3rdparty/astc-encoder/source/astcenc_ideal_endpoints_and_weights.cpp",
    "3rdparty/astc-encoder/source/astcenc_image.cpp",
    "3rdparty/astc-encoder/source/astcenc_integer_sequence.cpp",
    "3rdparty/astc-encoder/source/astcenc_mathlib.cpp",
    "3rdparty/astc-encoder/source/astcenc_mathlib_softfloat.cpp",
    "3rdparty/astc-encoder/source/astcenc_partition_tables.cpp",
    "3rdparty/astc-encoder/source/astcenc_percentile_tables.cpp",
    "3rdparty/astc-encoder/source/astcenc_pick_best_endpoint_format.cpp",
    "3rdparty/astc-encoder/source/astcenc_quantization.cpp",
    "3rdparty/astc-encoder/source/astcenc_symbolic_physical.cpp",
    "3rdparty/astc-encoder/source/astcenc_weight_align.cpp",
    "3rdparty/astc-encoder/source/astcenc_weight_quant_xfer_tables.cpp",
}

local bgfx_src = {
    "src/bgfx.cpp",
    "src/debug_renderdoc.cpp",
    "src/glcontext_egl.cpp",
    "src/renderer_agc.cpp",
    "src/renderer_d3d11.cpp",
    "src/renderer_d3d12.cpp",
    "src/renderer_gl.cpp",
    "src/renderer_gnm.cpp",
    "src/renderer_noop.cpp",
    "src/renderer_nvn.cpp",
    "src/renderer_vk.cpp",
    "src/shader.cpp",
    "src/shader_dxbc.cpp",
    "src/shader_spirv.cpp",
    "src/topology.cpp",
    "src/vertexlayout.cpp",
}

local bgfx_windows_src = {
    "src/dxgi.cpp",
    "src/glcontext_wgl.cpp",
    "src/nvapi.cpp",
}

local bgfx_macos_src = {
    "src/renderer_mtl.mm",
}

local spirv_opt_src = {
    "source/opt/aggressive_dead_code_elim_pass.cpp",
    "source/opt/amd_ext_to_khr.cpp",
    "source/opt/analyze_live_input_pass.cpp",
    "source/opt/basic_block.cpp",
    "source/opt/block_merge_pass.cpp",
    "source/opt/block_merge_util.cpp",
    "source/opt/build_module.cpp",
    "source/opt/canonicalize_ids_pass.cpp",
    "source/opt/ccp_pass.cpp",
    "source/opt/cfg.cpp",
    "source/opt/cfg_cleanup_pass.cpp",
    "source/opt/code_sink.cpp",
    "source/opt/combine_access_chains.cpp",
    "source/opt/compact_ids_pass.cpp",
    "source/opt/composite.cpp",
    "source/opt/const_folding_rules.cpp",
    "source/opt/constants.cpp",
    "source/opt/control_dependence.cpp",
    "source/opt/convert_to_half_pass.cpp",
    "source/opt/convert_to_sampled_image_pass.cpp",
    "source/opt/copy_prop_arrays.cpp",
    "source/opt/dataflow.cpp",
    "source/opt/dead_branch_elim_pass.cpp",
    "source/opt/dead_insert_elim_pass.cpp",
    "source/opt/dead_variable_elimination.cpp",
    "source/opt/debug_info_manager.cpp",
    "source/opt/decoration_manager.cpp",
    "source/opt/def_use_manager.cpp",
    "source/opt/desc_sroa.cpp",
    "source/opt/desc_sroa_util.cpp",
    "source/opt/dominator_analysis.cpp",
    "source/opt/dominator_tree.cpp",
    "source/opt/eliminate_dead_constant_pass.cpp",
    "source/opt/eliminate_dead_functions_pass.cpp",
    "source/opt/eliminate_dead_functions_util.cpp",
    "source/opt/eliminate_dead_io_components_pass.cpp",
    "source/opt/eliminate_dead_members_pass.cpp",
    "source/opt/eliminate_dead_output_stores_pass.cpp",
    "source/opt/feature_manager.cpp",
    "source/opt/fix_func_call_arguments.cpp",
    "source/opt/fix_storage_class.cpp",
    "source/opt/flatten_decoration_pass.cpp",
    "source/opt/fold.cpp",
    "source/opt/fold_spec_constant_op_and_composite_pass.cpp",
    "source/opt/folding_rules.cpp",
    "source/opt/freeze_spec_constant_value_pass.cpp",
    "source/opt/function.cpp",
    "source/opt/graphics_robust_access_pass.cpp",
    "source/opt/if_conversion.cpp",
    "source/opt/inline_exhaustive_pass.cpp",
    "source/opt/inline_opaque_pass.cpp",
    "source/opt/inline_pass.cpp",
    "source/opt/instruction.cpp",
    "source/opt/instruction_list.cpp",
    "source/opt/interface_var_sroa.cpp",
    "source/opt/interp_fixup_pass.cpp",
    "source/opt/invocation_interlock_placement_pass.cpp",
    "source/opt/ir_context.cpp",
    "source/opt/ir_loader.cpp",
    "source/opt/licm_pass.cpp",
    "source/opt/liveness.cpp",
    "source/opt/local_access_chain_convert_pass.cpp",
    "source/opt/local_redundancy_elimination.cpp",
    "source/opt/local_single_block_elim_pass.cpp",
    "source/opt/local_single_store_elim_pass.cpp",
    "source/opt/loop_dependence.cpp",
    "source/opt/loop_dependence_helpers.cpp",
    "source/opt/loop_descriptor.cpp",
    "source/opt/loop_fission.cpp",
    "source/opt/loop_fusion.cpp",
    "source/opt/loop_fusion_pass.cpp",
    "source/opt/loop_peeling.cpp",
    "source/opt/loop_unroller.cpp",
    "source/opt/loop_unswitch_pass.cpp",
    "source/opt/loop_utils.cpp",
    "source/opt/mem_pass.cpp",
    "source/opt/merge_return_pass.cpp",
    "source/opt/modify_maximal_reconvergence.cpp",
    "source/opt/module.cpp",
    "source/opt/opextinst_forward_ref_fixup_pass.cpp",
    "source/opt/optimizer.cpp",
    "source/opt/pass.cpp",
    "source/opt/pass_manager.cpp",
    "source/opt/pch_source_opt.cpp",
    "source/opt/private_to_local_pass.cpp",
    "source/opt/propagator.cpp",
    "source/opt/reduce_load_size.cpp",
    "source/opt/redundancy_elimination.cpp",
    "source/opt/register_pressure.cpp",
    "source/opt/relax_float_ops_pass.cpp",
    "source/opt/remove_dontinline_pass.cpp",
    "source/opt/remove_duplicates_pass.cpp",
    "source/opt/remove_unused_interface_variables_pass.cpp",
    "source/opt/replace_desc_array_access_using_var_index.cpp",
    "source/opt/replace_invalid_opc.cpp",
    "source/opt/resolve_binding_conflicts_pass.cpp",
    "source/opt/scalar_analysis.cpp",
    "source/opt/scalar_analysis_simplification.cpp",
    "source/opt/scalar_replacement_pass.cpp",
    "source/opt/set_spec_constant_default_value_pass.cpp",
    "source/opt/simplification_pass.cpp",
    "source/opt/split_combined_image_sampler_pass.cpp",
    "source/opt/spread_volatile_semantics.cpp",
    "source/opt/ssa_rewrite_pass.cpp",
    "source/opt/strength_reduction_pass.cpp",
    "source/opt/strip_debug_info_pass.cpp",
    "source/opt/strip_nonsemantic_info_pass.cpp",
    "source/opt/struct_cfg_analysis.cpp",
    "source/opt/struct_packing_pass.cpp",
    "source/opt/switch_descriptorset_pass.cpp",
    "source/opt/trim_capabilities_pass.cpp",
    "source/opt/type_manager.cpp",
    "source/opt/types.cpp",
    "source/opt/unify_const_pass.cpp",
    "source/opt/upgrade_memory_model.cpp",
    "source/opt/value_number_table.cpp",
    "source/opt/vector_dce.cpp",
    "source/opt/workaround1209.cpp",
    "source/opt/wrap_opkill.cpp",
}

local spirv_val_src = {
    "source/val/basic_block.cpp",
    "source/val/construct.cpp",
    "source/val/function.cpp",
    "source/val/instruction.cpp",
    "source/val/validate.cpp",
    "source/val/validate_adjacency.cpp",
    "source/val/validate_annotation.cpp",
    "source/val/validate_arithmetics.cpp",
    "source/val/validate_atomics.cpp",
    "source/val/validate_barriers.cpp",
    "source/val/validate_bitwise.cpp",
    "source/val/validate_builtins.cpp",
    "source/val/validate_capability.cpp",
    "source/val/validate_cfg.cpp",
    "source/val/validate_composites.cpp",
    "source/val/validate_constants.cpp",
    "source/val/validate_conversion.cpp",
    "source/val/validate_debug.cpp",
    "source/val/validate_decorations.cpp",
    "source/val/validate_derivatives.cpp",
    "source/val/validate_execution_limitations.cpp",
    "source/val/validate_extensions.cpp",
    "source/val/validate_function.cpp",
    "source/val/validate_graph.cpp",
    "source/val/validate_id.cpp",
    "source/val/validate_image.cpp",
    "source/val/validate_instruction.cpp",
    "source/val/validate_interfaces.cpp",
    "source/val/validate_invalid_type.cpp",
    "source/val/validate_layout.cpp",
    "source/val/validate_literals.cpp",
    "source/val/validate_logicals.cpp",
    "source/val/validate_memory.cpp",
    "source/val/validate_memory_semantics.cpp",
    "source/val/validate_mesh_shading.cpp",
    "source/val/validate_misc.cpp",
    "source/val/validate_mode_setting.cpp",
    "source/val/validate_non_uniform.cpp",
    "source/val/validate_primitives.cpp",
    "source/val/validate_ray_query.cpp",
    "source/val/validate_ray_tracing.cpp",
    "source/val/validate_ray_tracing_reorder.cpp",
    "source/val/validate_scopes.cpp",
    "source/val/validate_small_type_uses.cpp",
    "source/val/validate_tensor.cpp",
    "source/val/validate_tensor_layout.cpp",
    "source/val/validate_type.cpp",
    "source/val/validation_state.cpp",
}

local spirv_reduce_src = {
    "source/reduce/change_operand_reduction_opportunity.cpp",
    "source/reduce/change_operand_to_undef_reduction_opportunity.cpp",
    "source/reduce/conditional_branch_to_simple_conditional_branch_opportunity_finder.cpp",
    "source/reduce/conditional_branch_to_simple_conditional_branch_reduction_opportunity.cpp",
    "source/reduce/merge_blocks_reduction_opportunity.cpp",
    "source/reduce/merge_blocks_reduction_opportunity_finder.cpp",
    "source/reduce/operand_to_const_reduction_opportunity_finder.cpp",
    "source/reduce/operand_to_dominating_id_reduction_opportunity_finder.cpp",
    "source/reduce/operand_to_undef_reduction_opportunity_finder.cpp",
    "source/reduce/pch_source_reduce.cpp",
    "source/reduce/reducer.cpp",
    "source/reduce/reduction_opportunity.cpp",
    "source/reduce/reduction_opportunity_finder.cpp",
    "source/reduce/reduction_pass.cpp",
    "source/reduce/reduction_util.cpp",
    "source/reduce/remove_block_reduction_opportunity.cpp",
    "source/reduce/remove_block_reduction_opportunity_finder.cpp",
    "source/reduce/remove_function_reduction_opportunity.cpp",
    "source/reduce/remove_function_reduction_opportunity_finder.cpp",
    "source/reduce/remove_instruction_reduction_opportunity.cpp",
    "source/reduce/remove_selection_reduction_opportunity.cpp",
    "source/reduce/remove_selection_reduction_opportunity_finder.cpp",
    "source/reduce/remove_struct_member_reduction_opportunity.cpp",
    "source/reduce/remove_unused_instruction_reduction_opportunity_finder.cpp",
    "source/reduce/remove_unused_struct_member_reduction_opportunity_finder.cpp",
    "source/reduce/simple_conditional_branch_to_branch_opportunity_finder.cpp",
    "source/reduce/simple_conditional_branch_to_branch_reduction_opportunity.cpp",
    "source/reduce/structured_construct_to_block_reduction_opportunity.cpp",
    "source/reduce/structured_construct_to_block_reduction_opportunity_finder.cpp",
    "source/reduce/structured_loop_to_selection_reduction_opportunity.cpp",
    "source/reduce/structured_loop_to_selection_reduction_opportunity_finder.cpp",
}

local glslang_generic_codegen_src = {
    "glslang/GenericCodeGen/CodeGen.cpp",
    "glslang/GenericCodeGen/Link.cpp",
}

local glslang_machine_independent_src = {
    "glslang/MachineIndependent/Constant.cpp",
    "glslang/MachineIndependent/InfoSink.cpp",
    "glslang/MachineIndependent/Initialize.cpp",
    "glslang/MachineIndependent/IntermTraverse.cpp",
    "glslang/MachineIndependent/Intermediate.cpp",
    "glslang/MachineIndependent/ParseContextBase.cpp",
    "glslang/MachineIndependent/ParseHelper.cpp",
    "glslang/MachineIndependent/PoolAlloc.cpp",
    "glslang/MachineIndependent/RemoveTree.cpp",
    "glslang/MachineIndependent/Scan.cpp",
    "glslang/MachineIndependent/ShaderLang.cpp",
    "glslang/MachineIndependent/SpirvIntrinsics.cpp",
    "glslang/MachineIndependent/SymbolTable.cpp",
    "glslang/MachineIndependent/Versions.cpp",
    "glslang/MachineIndependent/attribute.cpp",
    "glslang/MachineIndependent/glslang_tab.cpp",
    "glslang/MachineIndependent/intermOut.cpp",
    "glslang/MachineIndependent/iomapper.cpp",
    "glslang/MachineIndependent/limits.cpp",
    "glslang/MachineIndependent/linkValidate.cpp",
    "glslang/MachineIndependent/parseConst.cpp",
    "glslang/MachineIndependent/propagateNoContraction.cpp",
    "glslang/MachineIndependent/reflection.cpp",
}

local glslang_preprocessor_src = {
    "glslang/MachineIndependent/preprocessor/Pp.cpp",
    "glslang/MachineIndependent/preprocessor/PpAtom.cpp",
    "glslang/MachineIndependent/preprocessor/PpContext.cpp",
    "glslang/MachineIndependent/preprocessor/PpScanner.cpp",
    "glslang/MachineIndependent/preprocessor/PpTokens.cpp",
}

local glslang_os_windows_src = {
    "glslang/OSDependent/Windows/ossource.cpp",
}

local glslang_os_unix_src = {
    "glslang/OSDependent/Unix/ossource.cpp",
}

local glslang_cinterface_src = {
    "glslang/CInterface/glslang_c_interface.cpp",
}

local glslang_hlsl_src = {
    "glslang/HLSL/hlslAttributes.cpp",
    "glslang/HLSL/hlslGrammar.cpp",
    "glslang/HLSL/hlslOpMap.cpp",
    "glslang/HLSL/hlslParseHelper.cpp",
    "glslang/HLSL/hlslParseables.cpp",
    "glslang/HLSL/hlslScanContext.cpp",
    "glslang/HLSL/hlslTokenStream.cpp",
}

local glslang_spirv_cinterface_src = {
    "SPIRV/CInterface/spirv_c_interface.cpp",
}

local shaderc_src = {
    "tools/shaderc/shaderc.cpp",
    "tools/shaderc/shaderc_glsl.cpp",
    "tools/shaderc/shaderc_hlsl.cpp",
    "tools/shaderc/shaderc_metal.cpp",
    "tools/shaderc/shaderc_pssl.cpp",
    "tools/shaderc/shaderc_spirv.cpp",
}

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
    
    add_files(table.unpack(resolve_sources(BX_DIR, bx_src)))
    
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
    
    add_files(table.unpack(resolve_sources(BIMG_DIR, bimg_src)))
    add_files(table.unpack(resolve_sources(BIMG_DIR, astc_encoder_src)))
    
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
    
    add_files(table.unpack(resolve_sources(BIMG_DIR, bimg_decode_src)))
    add_files(path.join(BIMG_DIR, "3rdparty/tinyexr/deps/miniz/miniz.c"))
    
    if is_plat("linux", "android") then
        add_cxxflags("-fPIC", {force = true})
    end

-- bgfx 渲染库
local function add_bgfx_sources()
    add_files(table.unpack(resolve_sources(BGFX_DIR, bgfx_src)))
    if is_plat("windows") then
        add_files(table.unpack(resolve_sources(BGFX_DIR, bgfx_windows_src)))
    end
    if is_plat("macosx", "iphoneos") then
        add_files(table.unpack(resolve_sources(BGFX_DIR, bgfx_macos_src)))
        add_mxxflags("-fno-objc-arc", {force = true})
    end
end

target("bgfx")
    set_kind("static")
    add_deps("bx", "bimg", "bimg_decode")
    
    add_includedirs(path.join(BGFX_DIR, "include"), {public = true})
    add_includedirs(path.join(BGFX_DIR, "3rdparty"), {public = true})
    add_includedirs(path.join(BGFX_DIR, "3rdparty/renderdoc"), {public = true})
    add_includedirs(path.join(BIMG_DIR, "include"))
    add_includedirs(path.join(BX_DIR, "include"))
    
    add_bgfx_sources()
    
    add_includedirs(path.join(BGFX_DIR, "3rdparty/khronos"))
    
    add_platform_links()
    
    if is_plat("linux", "android") then
        add_cxxflags("-fPIC", {force = true})
    end
    
    -- 禁用 D3D11/D3D12 渲染器（非 Windows 平台）
    if not is_plat("windows") then
        add_defines("BGFX_CONFIG_RENDERER_DIRECT3D11=0")
        add_defines("BGFX_CONFIG_RENDERER_DIRECT3D12=0")
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
        
        -- 禁用 D3D11/D3D12 渲染器（非 Windows 平台）
        if not is_plat("windows") then
            add_defines("BGFX_CONFIG_RENDERER_DIRECT3D11=0")
            add_defines("BGFX_CONFIG_RENDERER_DIRECT3D12=0")
        end
        
        add_includedirs(path.join(BGFX_DIR, "include"), {public = true})
        add_includedirs(path.join(BGFX_DIR, "3rdparty"), {public = true})
        add_includedirs(path.join(BGFX_DIR, "3rdparty/renderdoc"), {public = true})
        add_includedirs(path.join(BIMG_DIR, "include"))
        add_includedirs(path.join(BX_DIR, "include"))
        
        add_bgfx_sources()
        
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
    add_files(table.unpack(resolve_sources(SPIRV_TOOLS_DIR, spirv_opt_src)))
    
    -- val 验证器
    add_files(table.unpack(resolve_sources(SPIRV_TOOLS_DIR, spirv_val_src)))
    
    -- reduce
    add_files(table.unpack(resolve_sources(SPIRV_TOOLS_DIR, spirv_reduce_src)))
    
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
    add_files(table.unpack(resolve_sources(GLSLANG_DIR, glslang_generic_codegen_src)))
    add_files(table.unpack(resolve_sources(GLSLANG_DIR, glslang_machine_independent_src)))
    add_files(table.unpack(resolve_sources(GLSLANG_DIR, glslang_preprocessor_src)))
    
    -- OSDependent
    if is_plat("windows") then
        add_files(table.unpack(resolve_sources(GLSLANG_DIR, glslang_os_windows_src)))
    else
        add_files(table.unpack(resolve_sources(GLSLANG_DIR, glslang_os_unix_src)))
    end
    
    -- CInterface
    add_files(table.unpack(resolve_sources(GLSLANG_DIR, glslang_cinterface_src)))
    
    -- HLSL 支持
    add_files(table.unpack(resolve_sources(GLSLANG_DIR, glslang_hlsl_src)))
    
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
    add_files(table.unpack(resolve_sources(GLSLANG_DIR, glslang_spirv_cinterface_src)))
    
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
target("glsl_optimizer")
    set_kind("static")
    set_languages("c++20")

    add_includedirs(
        path.join(GLSL_OPTIMIZER_DIR, "src"),
        path.join(GLSL_OPTIMIZER_DIR, "include"),
        path.join(GLSL_OPTIMIZER_DIR, "src/mesa"),
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl")
    )

    -- 在 Windows 上所有 C 文件都用 C++ 模式编译
    -- MSVC C 编译器不支持 void* 隐式转换
    if is_plat("windows") then
        -- glcpp 预处理器 (C 文件，用 C++ 编译)
        add_files(
            path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/glcpp-lex.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/glcpp-parse.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/pp.c"),
            {sourcekind = "cxx"}
        )
        -- strtod.c (用 C++ 编译)
        add_files(
            path.join(GLSL_OPTIMIZER_DIR, "src/glsl/strtod.c"),
            {sourcekind = "cxx"}
        )
        -- mesa 支持 (C 文件，用 C++ 编译)
        add_files(
            path.join(GLSL_OPTIMIZER_DIR, "src/mesa/main/imports.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/mesa/program/prog_hash_table.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/mesa/program/symbol_table.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/util/hash_table.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/util/ralloc.c"),
            {sourcekind = "cxx"}
        )
    else
        -- glcpp 预处理器 (C 文件)
        add_files(
            path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/glcpp-lex.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/glcpp-parse.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/glsl/glcpp/pp.c")
        )
        -- strtod.c
        add_files(
            path.join(GLSL_OPTIMIZER_DIR, "src/glsl/strtod.c")
        )
        -- mesa 支持 (C 文件)
        add_files(
            path.join(GLSL_OPTIMIZER_DIR, "src/mesa/main/imports.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/mesa/program/prog_hash_table.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/mesa/program/symbol_table.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/util/hash_table.c"),
            path.join(GLSL_OPTIMIZER_DIR, "src/util/ralloc.c")
        )
    end
    
    -- glsl 优化器核心 (C++ 文件)
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
        path.join(GLSL_OPTIMIZER_DIR, "src/glsl/s_expression.cpp")
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
        add_cflags(
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
        add_cflags("-Wno-deprecated-register", {force = true})
    end

-- shaderc-lib - 着色器编译静态库
target("shaderc-lib")
    set_kind("static")
    add_deps("bx", "fcpp", "glslang", "glsl_optimizer", "spirv-cross")
    
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
    
    add_files(table.unpack(resolve_sources(BGFX_DIR, shaderc_src)))
    add_files(
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
