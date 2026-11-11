// Shared by every backend. Never use Object::get/call, ScriptInstance::get,
// property-list hooks, Variant stringification or recursive object serialization.
#pragma once
#include "GodotBridgeRuntimeScene.h"
#include "core/io/json.h"
#include "modules/gdscript/gdscript.h"
#include "scene/main/scene_tree.h"
#include "scene/main/window.h"
#include "scene/2d/node_2d.h"
#include "scene/2d/physics/character_body_2d.h"
#include "scene/3d/node_3d.h"
#include "scene/3d/physics/character_body_3d.h"
#include "scene/gui/control.h"
#include "scene/audio/audio_stream_player.h"
#include "scene/2d/audio_stream_player_2d.h"
#include "scene/3d/audio_stream_player_3d.h"
#include <filesystem>

namespace DoraGodotRuntimeScene {
inline std::string result;
inline const char *finish(const Dictionary &value) {
    result=JSON::stringify(value).utf8().get_data();return result.c_str();
}
inline const char *failure(const String &message) {
    Dictionary value;value["success"]=false;value["message"]=message;return finish(value);
}
struct Snapshot {
    bool truncated=false;
    Dictionary value(const Variant &raw) {
        Dictionary out;out["type"]=Variant::get_type_name(raw.get_type());
        switch(raw.get_type()) {
            case Variant::NIL: case Variant::BOOL: case Variant::INT: out["value"]=raw;break;
            case Variant::FLOAT: if(Math::is_finite(double(raw)))out["value"]=raw;else out["unavailable"]="non-finite number";break;
            case Variant::STRING: case Variant::STRING_NAME: {
                String text=raw;if(text.length()>512){text=text.substr(0,512);out["truncated"]=true;truncated=true;}out["value"]=text;break;
            }
            case Variant::VECTOR2: {Vector2 v=raw;if(!v.is_finite())return unavailable("non-finite vector");Array a;a.push_back(v.x);a.push_back(v.y);out["value"]=a;break;}
            case Variant::VECTOR3: {Vector3 v=raw;if(!v.is_finite())return unavailable("non-finite vector");Array a;a.push_back(v.x);a.push_back(v.y);a.push_back(v.z);out["value"]=a;break;}
            default:out["unavailable"]="Only scalar, string and Vector2/Vector3 storage is readable";break;
        }
        return out;
    }
    Dictionary property(Node *node,const String &name) {
        if(name.begins_with("script:")) {
            StringName member=name.substr(7);
            ScriptInstance *base=node->get_script_instance();
            if(!base || base->get_language()!=GDScriptLanguage::get_singleton())return unavailable("No GDScript instance");
            auto *instance=static_cast<GDScriptInstance *>(base);
            Ref<GDScript> script=instance->get_script();
            const auto *info=script->debug_get_member_indices().getptr(member);
            if(!info)return unavailable("No stored instance member (constants/static/computed fields are excluded)");
            if(info->getter!=StringName())return unavailable("Script getter excluded");
            return value(instance->debug_get_member_by_index(info->index));
        }
        // Explicit C++ accessors read native state; script overrides are bypassed.
        if(name=="position") {
            if(auto *n=Object::cast_to<Node2D>(node))return value(n->get_position());
            if(auto *n=Object::cast_to<Node3D>(node))return value(n->get_position());
            if(auto *n=Object::cast_to<Control>(node))return value(n->get_position());
        }
        if(name=="global_position") {
            if(auto *n=Object::cast_to<Node2D>(node))return value(n->get_global_position());
            if(auto *n=Object::cast_to<Node3D>(node))return value(n->get_global_position());
        }
        if(name=="velocity") {
            if(auto *n=Object::cast_to<CharacterBody2D>(node))return value(n->get_velocity());
            if(auto *n=Object::cast_to<CharacterBody3D>(node))return value(n->get_velocity());
        }
        if(name=="visible") {
            if(auto *n=Object::cast_to<CanvasItem>(node))return value(n->is_visible());
            if(auto *n=Object::cast_to<Node3D>(node))return value(n->is_visible());
        }
        if(auto *audio=Object::cast_to<AudioStreamPlayer>(node))return audio_property(audio,name);
        if(auto *audio=Object::cast_to<AudioStreamPlayer2D>(node))return audio_property(audio,name);
        if(auto *audio=Object::cast_to<AudioStreamPlayer3D>(node))return audio_property(audio,name);
        return unavailable("Not an allowed native property for this node type");
    }
    template<class Player>
    Dictionary audio_property(Player *audio,const String &name) {
        if(name=="playing")return value(audio->is_playing());
        if(name=="stream_paused")return value(audio->get_stream_paused());
        if(name=="volume_db")return value(audio->get_volume_db());
        if(name=="stream_path") {Ref<AudioStream> stream=audio->get_stream();return value(stream.is_valid()?stream->get_path():String());}
        return unavailable("Not an allowed native property for this node type");
    }
    static Dictionary unavailable(const String &reason) {Dictionary out;out["unavailable"]=reason;return out;}
};
template<class Runtime>
const char *inspect(Runtime &runtime,const DoraGodotConfig *config,const char *options) {
    if(!config || config->size<sizeof(*config) || !config->project_path)return failure("Invalid live scene configuration");
    if(!runtime.active || !runtime.tree)return failure("No running Godot project; start it and wait for readiness");
    std::error_code error;
    auto expected=std::filesystem::weakly_canonical(std::filesystem::u8path(config->project_path),error);
    if(error)return failure("Cannot resolve requested project");
    auto current=std::filesystem::weakly_canonical(std::filesystem::u8path(runtime.project),error);
    if(error || expected!=current)return failure("The running Godot project does not match the requested project");
    size_t bytes=0;while(options && options[bytes] && bytes<=8192)++bytes;
    if(bytes>8192)return failure("Live scene query exceeds 8 KiB");
    String text=String::utf8(options?options:"{}");
    JSON json;if(json.parse(text)!=OK || json.get_data().get_type()!=Variant::DICTIONARY)return failure("Options must be a JSON object");
    Dictionary opts=json.get_data();
    for(const Variant &key:opts.keys())if(key!=Variant("nodePath") && key!=Variant("maxNodes") && key!=Variant("properties") && key!=Variant("nodeType"))return failure("Unknown live scene option");
    int max_nodes=128;
    if(opts.has("maxNodes")) {
        Variant v=opts["maxNodes"];
        if((v.get_type()!=Variant::INT && v.get_type()!=Variant::FLOAT) || !Math::is_finite(double(v)) || double(v)!=Math::floor(double(v)) || double(v)<1 || double(v)>256)return failure("maxNodes must be an integer from 1 to 256");
        max_nodes=int(v);
    }
    Array properties;
    if(opts.has("properties")) {
        if(opts["properties"].get_type()!=Variant::ARRAY)return failure("properties must be an array");
        properties=opts["properties"];
    } else {properties.push_back("position");properties.push_back("visible");properties.push_back("playing");}
    if(properties.size()>32)return failure("At most 32 property names may be requested");
    for(const Variant &p:properties) {
        if(p.get_type()!=Variant::STRING)return failure("Property names must be strings");
        String name=p;
        if(name.is_empty() || name.length()>128)return failure("Property name length must be 1 to 128");
        if(name.begins_with("script:") && !name.substr(7).is_valid_unicode_identifier())return failure("script: must name one stored identifier, never an expression");
    }
    if(opts.has("nodePath") && opts["nodePath"].get_type()!=Variant::STRING)return failure("nodePath must be a relative node path");
    String path=opts.get("nodePath",".");
    if(path.is_empty() || path.length()>1024 || path.begins_with("/") || path.contains(":") || path.split("/").has(".."))return failure("nodePath must stay inside the running root, without property subpaths");
    String node_type;
    if(opts.has("nodeType")) {
        if(opts["nodeType"].get_type()!=Variant::STRING)return failure("nodeType must be an exact native class name");
        node_type=opts["nodeType"];
        if(node_type.length()>64 || !node_type.is_valid_ascii_identifier())return failure("nodeType must be an exact native class name of at most 64 characters");
    }
    Node *root=runtime.tree->get_root();
    Node *selected=root->get_node_or_null(NodePath(path));
    if(!selected)return failure("Runtime nodePath was not found");
    struct Pending {Node *node;String path;};
    Vector<Pending> pending;pending.push_back({selected,path});
    Array nodes;Snapshot snapshot;int visited=0;
    while(!pending.is_empty() && nodes.size()<max_nodes && visited<4096) {
        Pending item=pending[pending.size()-1];pending.remove_at(pending.size()-1);++visited;
        if(item.path.length()>1024){snapshot.truncated=true;continue;}
        if(node_type.is_empty() || item.node->get_class()==node_type) {
            Dictionary n;n["path"]=item.path;n["name"]=String(item.node->get_name()).substr(0,256);n["type"]=item.node->get_class();
            Dictionary values;for(const Variant &key:properties)values[key]=snapshot.property(item.node,key);
            n["properties"]=values;
            nodes.push_back(n);
            // Enforce a byte bound while constructing, never serialize a large tree.
            if(JSON::stringify(nodes).utf8().length()>120*1024){nodes.remove_at(nodes.size()-1);snapshot.truncated=true;break;}
        }
        int count=item.node->get_child_count();
        for(int i=count-1;i>=0;--i) {
            if(pending.size()+visited>=4096){snapshot.truncated=true;break;}
            Node *child=item.node->get_child(i);
            pending.push_back({child,item.path=="."?String(child->get_name()):item.path+"/"+String(child->get_name())});
        }
    }
    Dictionary out;out["success"]=true;out["nodePath"]=path;out["nodes"]=nodes;out["returnedNodeCount"]=nodes.size();out["visitedNodeCount"]=visited;
    out["truncated"]=snapshot.truncated || !pending.is_empty();out["maxNodes"]=max_nodes;out["maxBytes"]=128*1024;
    return finish(out);
}
}
