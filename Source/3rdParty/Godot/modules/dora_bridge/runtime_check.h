// In-process compiler checks. No executable, game loop, autoload or scene instance.
#pragma once
#include "GodotBridgeCheck.h"
#include "core/io/file_access_memory.h"
#include "core/io/config_file.h"
#include "core/io/json.h"
#include "core/object/script_language.h"
#include "modules/gdscript/gdscript.h"
#include "scene/resources/resource_format_text.h"
#include "servers/rendering/shader_preprocessor.h"
#include "servers/rendering/shader_types.h"
#include <string>

namespace DoraGodotCodeCheck {
inline std::string result;
inline void diagnostic(Array &info,const String &kind,const String &file,int line,int column,const String &message) {
    Array entry;entry.push_back(kind);entry.push_back(file);entry.push_back(MAX(line,1));entry.push_back(MAX(column,0));entry.push_back(message);info.push_back(entry);
}
inline const char *finish(bool success,const Array &info) {
    Dictionary value;value["success"]=success;value["info"]=info;
    result=JSON::stringify(value).utf8().get_data();return result.c_str();
}
inline const char *failure(const char *file,const std::string &message) {
    Array info;diagnostic(info,"tool",String::utf8(file?file:""),1,0,String::utf8(message.c_str()));return finish(false,info);
}
inline void script(const String &file,const String &source,Array &info) {
    List<ScriptLanguage::ScriptError> errors;
    const bool valid=GDScriptLanguage::get_singleton()->validate(source,ProjectSettings::get_singleton()->localize_path(file),nullptr,&errors);
    if(!valid && errors.is_empty()) diagnostic(info,"syntax",file,1,0,"Godot could not validate this GDScript");
    for (const auto &error:errors) {
        diagnostic(info,"syntax",ProjectSettings::get_singleton()->globalize_path(error.path),error.line,error.column,error.message);
    }
}
inline void text_resource(const String &file,const String &source,Array &info) {
    const auto bytes=source.to_utf8_buffer();
    Ref<FileAccessMemory> memory;memory.instantiate();memory->open_custom(bytes.ptr(),bytes.size());
    ResourceLoaderText loader;loader.set_local_path_for_validation(ProjectSettings::get_singleton()->localize_path(file));loader.open(memory);
    HashSet<StringName> classes;
    const Error error=loader.get_classes_used(&classes);
    if(error!=OK) { diagnostic(info,"syntax",file,loader.get_error_line(),0,loader.get_error_text());return; }
    for (const StringName &type:classes) {
        if(type==StringName()) continue;
        if(!ClassDB::class_exists(type) && !ScriptServer::is_global_class(type))
            diagnostic(info,"syntax",file,1,0,"Unknown Godot resource/node type: "+String(type));
    }
    memory->seek(0);
    ResourceLoaderText dependencies;
    dependencies.set_local_path_for_validation(ProjectSettings::get_singleton()->localize_path(file));
    List<String> paths;dependencies.get_dependencies(memory,&paths,false);
    for (String path:paths) {
        // Godot records UID::type::fallback in dependency reports.
        if(path.begins_with("uid://")) path=path.get_slice("::",2);
        if(path.is_empty()) continue;
        if(path.is_relative_path()) path=file.get_base_dir().path_join(path);
        path=ProjectSettings::get_singleton()->globalize_path(path);
        if(!FileAccess::exists(path)) diagnostic(info,"syntax",file,1,0,"Referenced resource does not exist: "+path);
        else if(path.get_extension()=="gd") script(path,FileAccess::get_file_as_string(path),info);
    }
}
// Read only type metadata: do not register global uniforms or load textures on
// the rendering server during static validation (including checks in a game).
inline ShaderLanguage::DataType global_uniform_type(const StringName &name) {
    const Dictionary setting=ProjectSettings::get_singleton()->get_setting("shader_globals/"+String(name),Dictionary());
    String type=setting.get("type",String());
    if(type=="color" || type=="rect2") type="vec4";
    else if(type=="rect2i") type="ivec4";
    else if(type=="transform_2d") type="mat3";
    else if(type=="transform") type="mat4";
    for(int i=0;i<ShaderLanguage::TYPE_MAX;i++) {
        const auto candidate=static_cast<ShaderLanguage::DataType>(i);
        if(ShaderLanguage::get_datatype_name(candidate)==type) return candidate;
    }
    return ShaderLanguage::TYPE_MAX;
}
inline void shader(const String &file,const String &source,bool include,Array &info) {
    const String local=ProjectSettings::get_singleton()->localize_path(file);
    ShaderPreprocessor preprocessor;
    String code,error;
    List<ShaderPreprocessor::FilePosition> positions;
    if(preprocessor.preprocess(source,local,code,&error,&positions,nullptr,nullptr,nullptr,nullptr,nullptr,true)!=OK) {
        const auto *last=positions.back();
        diagnostic(info,"syntax",last?ProjectSettings::get_singleton()->globalize_path(last->get().file):file,last?last->get().line:1,0,error);
        return;
    }
    ShaderLanguage::ShaderCompileInfo options;
    options.is_include=include;
    options.validate_global_uniforms=true;
    options.global_shader_uniform_type_func=global_uniform_type;
    if(!include) {
        const String type=ShaderLanguage::get_shader_type(code);
        RSE::ShaderMode mode=RSE::SHADER_SPATIAL;
        if(type=="canvas_item") mode=RSE::SHADER_CANVAS_ITEM;
        else if(type=="particles") mode=RSE::SHADER_PARTICLES;
        else if(type=="sky") mode=RSE::SHADER_SKY;
        else if(type=="fog") mode=RSE::SHADER_FOG;
        else if(type=="texture_blit") mode=RSE::SHADER_TEXTURE_BLIT;
        auto *types=ShaderTypes::get_singleton();
        options.functions=types->get_functions(mode);
        options.render_modes=types->get_modes(mode);
        options.stencil_modes=types->get_stencil_modes(mode);
        options.shader_types=types->get_types();
    }
    ShaderLanguage language;
    if(language.compile(code,options)!=OK) {
        const auto includes=language.get_include_positions();
        const bool nested=includes.size()>1;
        diagnostic(info,"syntax",nested?ProjectSettings::get_singleton()->globalize_path(includes[includes.size()-1].file):file,
            nested?includes[includes.size()-1].line:language.get_error_line(),0,language.get_error_text());
    }
}
// A renderer backend supplies lazy initialization on its existing owner thread.
// Idle checks temporarily configure settings/languages, but never Main::start.
// An active game is checked only in its own project; it is never stopped/reset.
template<class Runtime,class Boot>
inline const char *check(Runtime &runtime,const DoraGodotConfig *config,const char *file,const char *source,Boot boot) {
    if(!config || config->size<sizeof(*config) || !config->project_path || !file || !source)
        return failure(file,"Invalid embedded Godot check request");
    if(runtime.terminated) return failure(file,"Godot runtime has terminated; restart Dora");
    if(runtime.active && runtime.project!=config->project_path)
        return failure(file,"Stop the running Godot project before checking a different project");
    if(!runtime.instance && !boot(config)) return failure(file,runtime.error);
    const bool isolated=!runtime.active;
    if(isolated && !DoraGodotProject::load(runtime.instance,config->project_path,"",1,1,runtime.error,false)) {
        DoraGodotProject::unload(runtime.instance);return failure(file,runtime.error);
    }
    DoraGodotProject::source_classes("res://");
    Array info;
    const String path=String::utf8(file),code=String::utf8(source);
    const String extension=path.get_extension().to_lower();
    if(extension=="godot") {
        ConfigFile settings;
        if(settings.parse(code)!=OK) diagnostic(info,"syntax",path,1,0,"Invalid project.godot settings");
        else {
            String main=settings.get_value("application","run/main_scene",String());
            if(main.begins_with("uid://")) {
                const auto id=ResourceUID::get_singleton()->text_to_id(main);
                main=ResourceUID::get_singleton()->has_id(id)?ResourceUID::get_singleton()->get_id_path(id):String();
            }
            if(main.is_empty() || !FileAccess::exists(main)) diagnostic(info,"syntax",path,1,0,"Godot project main scene is missing: "+main);
        }
    }
    else if(extension=="gd") script(path,code,info);
    else if(extension=="tscn" || extension=="tres") text_resource(path,code,info);
    else if(extension=="gdshader" || extension=="gdshaderinc") shader(path,code,extension=="gdshaderinc",info);
    else diagnostic(info,"tool",path,1,0,"Embedded code checking supports .gd, .tscn, .tres, .gdshader, .gdshaderinc and project.godot");
    if(isolated) DoraGodotProject::unload(runtime.instance);
    return finish(info.is_empty(),info);
}
}
