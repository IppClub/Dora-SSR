#!/usr/bin/env python3
"""Prepare only the pinned iOS source copy for host-driven Metal LibGodot."""
from pathlib import Path
import sys
source=Path(sys.argv[1]).resolve()
p=source/'platform/ios/detect.py';s=p.read_text()
old='"supported": ["metal", "mono"],';new='"supported": ["metal", "mono", "library"],'
if old in s:s=s.replace(old,new,1)
else:assert new in s
old='if env["metal"] and env["simulator"]:'
new='if env["metal"] and env["simulator"] and env["library_type"] == "executable":'
if old in s:s=s.replace(old,new,1)
else:assert new in s
p.write_text(s)

# GodotInstance::stop finalizes before Main::cleanup. Native iOS, which has no
# instance lifecycle, finalizes in delete_main_loop instead. Avoid double
# finalization only for Dora's embedded display.
p=source/'drivers/apple_embedded/os_apple_embedded.mm';s=p.read_text()
old="""void OS_AppleEmbedded::delete_main_loop() {
\tif (main_loop) {
\t\tmain_loop->finalize();"""
new="""void OS_AppleEmbedded::delete_main_loop() {
\tif (main_loop) {
        // Dora GodotInstance has already finalized the loop.
        if (!DisplayServer::get_singleton() || DisplayServer::get_singleton()->get_name() != "dora-metal") main_loop->finalize();"""
if old in s:s=s.replace(old,new,1)
else:assert new in s
p.write_text(s)

# The iOS simulator SDK has Metal but no MetalFX framework. Keep real Metal
# rendering and accurately report the optional MetalFX upscalers unavailable.
p=source/'drivers/metal/metal_device_properties.mm';s=p.read_text()
old='#import <MetalFX/MetalFX.h>';new='#if !defined(IOS_SIMULATOR)\n'+old+'\n#endif'
if new not in s:
 assert old in s;s=s.replace(old,new,1)
old='\tif (@available(macOS 13.0, iOS 16.0, tvOS 16.0, *)) {\n\t\tfeatures.metal_fx_spatial'
new='\t#if !defined(IOS_SIMULATOR)\n'+old
if new not in s:
 assert old in s;s=s.replace(old,new,1)
 marker='\t\tfeatures.metal_fx_temporal = false;\n#endif\n\t}\n}'
 assert marker in s;s=s.replace(marker,marker[:-1]+'\t#endif\n}',1)
p.write_text(s)
p=source/'servers/rendering/renderer_rd/effects/metal_fx.h';s=p.read_text()
old='#if defined(METAL_ENABLED) && !defined(VISIONOS_ENABLED)'
new=old+' && !defined(IOS_SIMULATOR)'
if new not in s:
 assert old in s;s=s.replace(old,new,1)
p.write_text(s)
p=source/'servers/rendering/renderer_rd/effects/SCsub';s=p.read_text()
old='if env["metal"]:';new='if env["metal"] and not (env["platform"] == "ios" and env["simulator"]):'
if old in s:s=s.replace(old,new,1)
else:assert new in s
p.write_text(s)
for relative in ('renderer_scene_render_rd.h','renderer_scene_render_rd.cpp','storage_rd/render_scene_buffers_rd.h','storage_rd/render_scene_buffers_rd.cpp'):
 p=source/'servers/rendering/renderer_rd'/relative;s=p.read_text()
 s=s.replace('#ifdef METAL_ENABLED','#if defined(METAL_ENABLED) && !defined(IOS_SIMULATOR)')
 s=s.replace('#if METAL_ENABLED','#if defined(METAL_ENABLED) && !defined(IOS_SIMULATOR)')
 p.write_text(s)

# Simulator MTLCommandBuffer does not expose timed presentation. Dora owns
# presentation; keep the otherwise-unused native surface implementation valid.
p=source/'drivers/metal/rendering_context_driver_metal.mm';s=p.read_text()
old='''		if (vsync_mode != DisplayServer::VSYNC_DISABLED) {
			[p_cmd_buffer->get_command_buffer() presentDrawable:drawable afterMinimumDuration:present_minimum_duration];
		} else {
			[p_cmd_buffer->get_command_buffer() presentDrawable:drawable];
		}'''
new='''#if !defined(IOS_SIMULATOR)
		if (vsync_mode != DisplayServer::VSYNC_DISABLED) {
			[p_cmd_buffer->get_command_buffer() presentDrawable:drawable afterMinimumDuration:present_minimum_duration];
		} else
#endif
        { // Dora simulator: timed presentation is unavailable in the SDK.
			[p_cmd_buffer->get_command_buffer() presentDrawable:drawable];
		}'''
if old in s:s=s.replace(old,new,1)
else:assert new in s
p.write_text(s)
