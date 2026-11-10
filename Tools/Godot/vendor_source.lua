local C=import("Tools.Godot.common",{rootdir=path.absolute(path.join(os.scriptdir(),"../.."))})
local HEADERS={"GodotBridge.h","GodotBridgeProject.h","GodotBridgeCheck.h","GodotBridgeImport.h","GodotBridgeScene.h","GodotBridgeImport.h","GodotBridgeGL.h","GodotBridgeAudio.h","GodotBridgeGLTargets.h","GodotBridgeD3D12.h","GodotBridgeMetalTargets.h","GodotBridgeViewport.h","GodotBridgeOutput.h","GodotBridgeIME.h","GodotBridgeAndroid.h","GodotAudioQueue.h"}
local COMMON={{"main/main.cpp","// Dora manual render timing"},{"main/main.cpp","// Dora threadless audio shutdown"},{"platform/macos/libgodot_macos.mm","dora-metal"},{"platform/linuxbsd/libgodot_linuxbsd.cpp","dora-gl"},{"platform/windows/libgodot_windows.cpp","dora-gl"},{"drivers/d3d12/rendering_context_driver_d3d12.cpp","// Dora D3D12 WARP validation adapter"},{"servers/rendering/renderer_rd/forward_mobile/render_forward_mobile.cpp","// Dora ARM64 WARP shadow receiver compatibility"},{"scene/resources/particle_process_material.h","// Dora particle-key semantic hashing"},{"drivers/metal/rendering_device_driver_metal.cpp","// Dora embedded Metal: no asynchronous library compilation past shutdown."}}
local function contains(source,records)
    for _,record in ipairs(records) do assert(C.read(path.join(source,record[1])):find(record[2],1,true),"Missing Dora integration marker: "..record[1]) end
end
function verify_common(source)
    source=assert(C.real(source));assert(source==C.real(path.join(C.root(),"Source/3rdParty/Godot")),"LibGodot must use the vendored source")
    local metadata=C.load(path.join(source,"UPSTREAM.json"))
    assert(metadata.upstream_commit=="ed1daf0bf001b61586d9930840f2f1394092c079" and metadata.source_archive_sha256=="e954996374cbd1cb5d72e0e3781cc537408e6ce73b010b12c6c2f308a820690a","Godot provenance mismatch")
    for _,name in ipairs({"LICENSE.txt","COPYRIGHT.txt","modules/dora_bridge/config.py"}) do assert(os.isfile(path.join(source,name)),"Missing vendor input: "..name) end
    for _,name in ipairs(HEADERS) do assert(C.read(path.join(C.root(),"Source/Godot",name))==C.read(path.join(source,"modules/dora_bridge",name)),"Bridge header drift: "..name) end
    contains(source,COMMON);return source
end
function verify_android(source)
    verify_common(source);contains(source,{{"platform/android/detect.py",'"supported": ["mono", "library"]'},{"platform/android/java_godot_lib_jni.cpp","// Dora embedded Android ownership"},{"modules/camera/camera_android.cpp","// Dora embedded orientation"},{"platform/android/os_android.cpp","// Dora host filesystem resources"},{"scene/main/window.cpp","Dora owns offscreen size"}})
end
function verify_ios(source)
    verify_common(source);contains(source,{{"platform/ios/detect.py",'"supported": ["metal", "mono", "library"]'},{"drivers/apple_embedded/os_apple_embedded.mm","Dora GodotInstance has already finalized the loop."},{"servers/rendering/renderer_rd/effects/metal_fx.h","!defined(IOS_SIMULATOR)"}})
end
function verify_web(source)
    verify_common(source);contains(source,{{"platform/web/detect.py",'"supported": ["library"]'},{"platform/web/SCsub","# Dora embedded Web library: the host owns main and all frame scheduling."},{"platform/web/audio_driver_web.cpp","// Dora: unused Web driver."},{"platform/web/js/libs/library_godot_os.js","// Dora embedded user:// persistence."}})
end
