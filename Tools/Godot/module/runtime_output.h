// Resolve the Window's native content stretch into a physical-size offscreen
// output. SceneTree/Window/input semantics remain upstream Godot semantics.
#pragma once
#include "scene/main/window.h"
#include "servers/rendering/rendering_server.h"
#include "servers/rendering/rendering_server_globals.h"
#include "servers/rendering/renderer_viewport.h"
#include "servers/rendering/storage/texture_storage.h"
class DoraGodotOutput {
    RID viewport,canvas,item,shader,material;
    bool resolving=false,active=false;
public:
    void prepare(Window *root) {
        auto *rs=RenderingServer::get_singleton();
        rs->sync();
        const RID source=root->get_viewport_rid();
        const Size2i physical=root->get_size();
        const Size2i raw=RSG::texture_storage->render_target_get_size(RSG::viewport->viewport_get_render_target(source));
        // The texture already contains stretch/global canvas transforms. Only
        // the outer window transform (scaling/letterbox offset) remains.
        const Transform2D window=root->get_final_transform()*(root->get_stretch_transform()*root->get_global_canvas_transform()).affine_inverse();
        resolving=raw!=physical || window!=Transform2D();
        if (!resolving) {
            rs->viewport_set_parent_viewport(source,RID());
            if (active) { rs->viewport_set_active(viewport,false);active=false; }
            return;
        }
        if (viewport.is_null()) {
            viewport=rs->viewport_create();canvas=rs->canvas_create();item=rs->canvas_item_create();
            shader=rs->shader_create();material=rs->material_create();
            rs->shader_set_code(shader,"shader_type canvas_item; render_mode unshaded, blend_premul_alpha;");
            rs->material_set_shader(material,shader);rs->canvas_item_set_material(item,material);
            rs->canvas_item_set_parent(item,canvas);rs->viewport_attach_canvas(viewport,canvas);
            rs->viewport_set_disable_3d(viewport,true);
            rs->viewport_set_transparent_background(viewport,true);
            rs->viewport_set_clear_mode(viewport,RS::VIEWPORT_CLEAR_ALWAYS);
            rs->viewport_set_update_mode(viewport,RS::VIEWPORT_UPDATE_ALWAYS);
            rs->canvas_item_set_default_texture_filter(item,RS::CANVAS_ITEM_TEXTURE_FILTER_LINEAR);
        }
        rs->viewport_set_size(viewport,physical.x,physical.y);
        if (!active) { rs->viewport_set_active(viewport,true);active=true; }
        rs->viewport_set_parent_viewport(source,viewport);
        rs->canvas_item_clear(item);rs->canvas_item_set_transform(item,window);
        rs->canvas_item_add_texture_rect(item,Rect2(Point2(),raw),rs->viewport_get_texture(source));
    }
    RID texture(Window *root) const {
        return RenderingServer::get_singleton()->viewport_get_texture(resolving?viewport:root->get_viewport_rid());
    }
    void close(Window *root) {
        auto *rs=RenderingServer::get_singleton();
        if (root) rs->viewport_set_parent_viewport(root->get_viewport_rid(),RID());
        for (RID resource:{item,canvas,viewport,material,shader}) if (resource.is_valid()) rs->free_rid(resource);
        viewport=canvas=item=shader=material=RID();resolving=false;active=false;
    }
};
