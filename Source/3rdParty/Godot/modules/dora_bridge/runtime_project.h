// Project lifetime boundary. Engine/renderer/device lifetime is unchanged.
#pragma once
#include "core/config/engine.h"
#include "core/core_bind.h"
#include "core/os/os.h"
#include "core/config/project_settings.h"
#include "core/extension/godot_instance.h"
#include "core/extension/gdextension_manager.h"
#include "core/input/input.h"
#include "core/input/input_map.h"
#include "core/io/dir_access.h"
#include "core/io/file_access_pack.h"
#include "core/io/resource_loader.h"
#include "core/io/resource_saver.h"
#include "core/io/resource_uid.h"
#include "core/object/message_queue.h"
#include "core/object/script_language.h"
#include "core/string/translation_server.h"
#include "modules/gdscript/gdscript.h"

#include "main/main.h"
#include "scene/main/scene_tree.h"
#include "scene/theme/theme_db.h"
#include "servers/audio/audio_server.h"
#include <string>

void dora_godot_reset_certificates();

namespace DoraGodotProject {
inline bool supported(std::string &error) {
    for (const String &extension : GDExtensionManager::get_singleton()->get_loaded_extensions()) {
        if (extension != "libgodot://main") {
            error = "project switching does not support native GDExtensions; restart Dora";
            return false;
        }
    }
    if (String(GLOBAL_GET("application/run/main_loop_type")) != "SceneTree") {
        error = "project switching requires the standard SceneTree main loop";
        return false;
    }
    // An imported project records native extensions here. Never load them as
    // part of a project-only reset: their process globals cannot be isolated.
    const String extensions = ProjectSettings::get_singleton()->get_project_data_path().path_join("extension_list.cfg");
    if (FileAccess::exists(extensions) && !FileAccess::get_file_as_string(extensions).strip_edges().is_empty()) {
        error = "project switching does not support native GDExtension sidecars";
        return false;
    }
    bool live_thread=false;
    ObjectDB::debug_objects([](Object *object, void *state) {
        auto *thread=Object::cast_to<CoreBind::Thread>(object);
        if (thread && thread->is_started()) *static_cast<bool *>(state)=true;
    }, &live_thread);
    if (live_thread) {
        error="finish and join all project Thread objects before switching projects";
        return false;
    }
    return true;
}
inline void unload(GodotInstance *instance) {
    // The host has already joined the PCM producer, drained GPU work, removed
    // direct targets and destroyed its output resolver before reaching here.
    Input::get_singleton()->release_pressed_events();
    ResourceLoader::clear_thread_load_tasks();
    MessageQueue::get_singleton()->flush();
    instance->stop(); // finalize deletes root, autoloads, timers and tweens
    Main::delete_embedded_main_loop();
    List<Engine::Singleton> singletons;
    Engine::get_singleton()->get_singletons(&singletons);
    for (const Engine::Singleton &singleton : singletons) {
        if (singleton.user_created) Engine::get_singleton()->remove_singleton(singleton.name);
    }
    MessageQueue::get_singleton()->flush();
    ResourceLoader::remove_custom_loaders();
    ResourceSaver::remove_custom_savers();
    ResourceLoader::clear_translation_remaps();
    TranslationServer::get_singleton()->clear();
    ThemeDB::get_singleton()->set_project_theme(Ref<Theme>());
    ThemeDB::get_singleton()->finalize_theme();
    auto *audio = AudioServer::get_singleton();
    audio->reset_embedded_project();
    RenderingServer::get_singleton()->global_shader_parameters_clear();
    ScriptServer::finish_languages();
    dora_godot_reset_certificates();
    GDScriptLanguage::get_singleton()->reset_embedded_project();
    // The default theme/server resources may outlive a project. Remove path
    // identities rather than clearing ResourceCache's raw pointer map: each
    // Resource's destructor must still be able to unregister itself correctly.
    List<Ref<Resource>> resources;
    ResourceCache::get_cached_resources(&resources);
    for (const Ref<Resource> &resource : resources) {
        if (resource->get_path().begins_with("res://")) resource->set_path(String());
    }
    resources.clear();
    PackedData::get_singleton()->clear();
    ResourceUID::get_singleton()->clear();
    ProjectSettings::get_singleton()->reset_embedded_project();
    RenderingServer::get_singleton()->sync();
    int orphan_nodes=0;
    ObjectDB::debug_objects([](Object *object,void *count) {
        if (Object::cast_to<Node>(object)) ++*static_cast<int *>(count);
    }, &orphan_nodes);
    print_line(vformat("DORA_GODOT_PROJECT_CLEAN objects=%d resources=%d nodes=%d", ObjectDB::get_object_count(), ResourceCache::get_cached_resource_count(), orphan_nodes));
}
inline bool load(GodotInstance *instance, const char *path, const char *scene, int width, int height, std::string &error) {
    auto *settings = ProjectSettings::get_singleton();
    const String project = String::utf8(path);
    const bool directory = DirAccess::dir_exists_absolute(project);
    if (settings->setup(directory ? project : project.get_base_dir(), directory ? String() : project, false, true) != OK) {
        error = "cannot load Godot project settings";
        return false;
    }
    if (!supported(error)) return false;
#ifdef WEB_ENABLED
    // ProjectSettings::setup restores Web's Sample default on every load.
    // The embedded PCM driver needs the mixer, just as on initial startup.
    settings->set("audio/general/default_playback_type", 0);
    settings->set("audio/general/default_playback_type.web", 0);
#endif
    if (scene && *scene) settings->set("application/run/main_scene", String::utf8(scene));
    const String main_scene = GLOBAL_GET("application/run/main_scene");
    if (main_scene.is_empty()) { error = "Godot project has no main scene"; return false; }
    OS::get_singleton()->ensure_user_data_dir();
    OS::get_singleton()->set_exit_code(0);
    ResourceUID::get_singleton()->load_from_cache(true);
    settings->fix_autoload_paths();
    InputMap::get_singleton()->load_from_project_settings();
    auto *engine = Engine::get_singleton();
    engine->set_time_scale(1.0);
    engine->set_user_time_scale(1.0);
    engine->set_physics_ticks_per_second(GLOBAL_GET("physics/common/physics_ticks_per_second"));
    engine->set_max_physics_steps_per_frame(GLOBAL_GET("physics/common/max_physics_steps_per_frame"));
    engine->set_physics_jitter_fix(GLOBAL_GET("physics/common/physics_jitter_fix"));
    engine->set_max_fps(GLOBAL_GET("application/run/max_fps"));
    TranslationServer::get_singleton()->setup();
    TranslationServer::get_singleton()->load_project_translations(TranslationServer::get_singleton()->get_main_domain());
    ResourceLoader::load_translation_remaps();
    ScriptServer::init_languages();
    ThemeDB::get_singleton()->initialize_theme();
    AudioServer::get_singleton()->load_default_bus_layout();
    RenderingServer::get_singleton()->global_shader_parameters_load_settings(true);
    // Main::start creates a fresh SceneTree and uses the normal upstream
    // autoload, stretch and main-scene setup. setup2 is intentionally not run.
    if (!instance->start_embedded_project()) { error = "Godot project startup failed"; return false; }
    auto *tree = Object::cast_to<SceneTree>(OS::get_singleton()->get_main_loop());
    if (!tree) { error = "project does not use SceneTree"; return false; }
    tree->get_root()->set_size(Size2i(width,height));
    print_line(vformat("DORA_GODOT_PROJECT_SWITCH runtime=%d tree=%d project=%s", uint64_t(instance->get_instance_id()), uint64_t(tree->get_instance_id()), project));
    return true;
}
}
