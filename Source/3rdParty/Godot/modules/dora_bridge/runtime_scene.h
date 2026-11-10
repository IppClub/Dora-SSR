// Static .tscn metadata, parsed by Godot without ResourceLoader or SceneState.
#pragma once
#include "GodotBridgeScene.h"
#include "runtime_diagnostics.h"

#include "core/io/file_access.h"
#include "core/io/json.h"
#include "core/io/resource.h"
#include "core/variant/variant_parser.h"

#include <filesystem>

namespace DoraGodotSceneInspect {
inline std::string result;
inline const char *finish(const Dictionary &value) {
	result = JSON::stringify(value).utf8().get_data();
	return result.c_str();
}
inline const char *failure(const String &file, const String &message, int line = 1) {
	Dictionary value;
	value["success"] = false;
	value["path"] = file;
	value["message"] = message;
	value["line"] = MAX(line, 1);
	return finish(value);
}
inline bool inside(const std::filesystem::path &root, const std::filesystem::path &target) {
	auto r = root.begin(), t = target.begin();
	for (; r != root.end(); ++r, ++t) {
		if (t == target.end() || *r != *t) {
			return false;
		}
	}
	return t != target.end();
}
struct Section {
	String kind;
	Dictionary fields, properties;
	int line = 1;
};
struct Parser {
	Vector<Section> sections;
	HashMap<String, Dictionary> external, internal;
	int values_left = 4096;
	bool truncated = false;
	std::filesystem::path root, scene_directory;
	String limited(const String &text) {
		if (text.length() > 2048) {
			truncated = true;
			return text.substr(0, 2048);
		}
		return text;
	}
	static Error reference(void *, VariantParser::Stream *stream, Ref<Resource> &value, int &line, String &error, const char *kind) {
		VariantParser::Token token;
		Error parsed = VariantParser::get_token(stream, token, line, error);
		if (parsed != OK) {
			return parsed;
		}
		if (token.type != VariantParser::TK_STRING && token.type != VariantParser::TK_NUMBER) {
			error = "Expected resource reference ID or path";
			return ERR_PARSE_ERROR;
		}
		const String id = token.value;
		parsed = VariantParser::get_token(stream, token, line, error);
		if (parsed != OK) {
			return parsed;
		}
		String fallback;
		if (String(kind) == "Resource" && token.type == VariantParser::TK_COMMA) {
			parsed = VariantParser::get_token(stream, token, line, error);
			if (parsed != OK) {
				return parsed;
			}
			if (token.type != VariantParser::TK_STRING) {
				error = "Expected Resource fallback path";
				return ERR_PARSE_ERROR;
			}
			fallback = token.value;
			parsed = VariantParser::get_token(stream, token, line, error);
			if (parsed != OK) {
				return parsed;
			}
		}
		if (token.type != VariantParser::TK_PARENTHESIS_CLOSE) {
			error = "Expected ')' after resource reference";
			return ERR_PARSE_ERROR;
		}
		value.instantiate(); // Plain native Resource, never a script/custom class.
		value->set_meta("dora_reference_kind", String(kind));
		value->set_meta("dora_reference_id", id);
		value->set_meta("dora_reference_fallback", fallback);
		return OK;
	}
	static Error ext(void *self, VariantParser::Stream *stream, Ref<Resource> &value, int &line, String &error) { return reference(self, stream, value, line, error, "ExtResource"); }
	static Error sub(void *self, VariantParser::Stream *stream, Ref<Resource> &value, int &line, String &error) { return reference(self, stream, value, line, error, "SubResource"); }
	static Error direct(void *self, VariantParser::Stream *stream, Ref<Resource> &value, int &line, String &error) { return reference(self, stream, value, line, error, "Resource"); }
	Error parse(const String &source, int &line, String &error) {
		VariantParser::StreamString stream;
		stream.s = source;
		VariantParser::ResourceParser callbacks;
		callbacks.userdata = this;
		callbacks.ext_func = ext;
		callbacks.sub_func = sub;
		callbacks.func = direct;
		callbacks.metadata_only = true;
		VariantParser::Tag tag;
		Error parsed = VariantParser::parse_tag(&stream, line, error, tag, &callbacks);
		if (parsed != OK) {
			return parsed;
		}
		if (tag.name != "gd_scene") {
			error = "Expected [gd_scene] text scene header";
			return ERR_PARSE_ERROR;
		}
		const int version = tag.fields.has("format") ? int(tag.fields["format"]) : 0;
		if (version < 2 || version > 4) {
			error = "Unsupported Godot text scene format (expected 2, 3 or 4)";
			return ERR_PARSE_ERROR;
		}
		Section header;
		header.kind = tag.name;
		header.line = line;
		for (const auto &field : tag.fields) {
			header.fields[field.key] = field.value;
		}
		sections.push_back(header);
		for (;;) {
			String assignment;
			Variant value;
			tag.name = String();
			tag.fields.clear();

			parsed = VariantParser::parse_tag_assign_eof(&stream, line, error, tag, assignment, value, &callbacks);
			if (parsed == ERR_FILE_EOF) {
				return OK;
			}
			if (parsed != OK) {
				return parsed;
			}
			if (!assignment.is_empty()) {
				Section &section = sections.write[sections.size() - 1];
				if (section.kind != "node" && section.kind != "sub_resource") {
					error = "Unexpected property outside a node/sub-resource";
					return ERR_PARSE_ERROR;
				}
				if (section.properties.has(assignment)) {
					error = "Duplicate scene property: " + assignment;
					return ERR_PARSE_ERROR;
				}
				section.properties[assignment] = value;
			} else if (!tag.name.is_empty()) {
				if (tag.name != "ext_resource" && tag.name != "sub_resource" && tag.name != "node" && tag.name != "connection" && tag.name != "editable") {
					error = "Unknown scene section: " + tag.name;
					return ERR_PARSE_ERROR;
				}
				if (sections.size() >= 8192) {
					error = "Scene exceeds 8192 sections";
					return ERR_PARSE_ERROR;
				}
				Section section;
				section.kind = tag.name;
				section.line = line;
				for (const auto &field : tag.fields) {
					section.fields[field.key] = field.value;
				}
				sections.push_back(section);
			}
		}
	}
	Variant encode(const Variant &value, int depth = 0) {
		Dictionary encoded;
		if (depth > 8 || values_left-- <= 0) {
			truncated = true;
			encoded["type"] = "truncated";
			return encoded;
		}
		encoded["type"] = Variant::get_type_name(value.get_type());
		switch (value.get_type()) {
			case Variant::NIL:
			case Variant::BOOL:
			case Variant::INT:
				encoded["value"] = value;
				break;
			case Variant::FLOAT:
				encoded["value"] = Math::is_finite(double(value)) ? value : Variant(String(value));
				break;
			case Variant::STRING:
			case Variant::STRING_NAME:
			case Variant::NODE_PATH:
				encoded["value"] = limited(String(value));
				break;
			case Variant::OBJECT: {
				const Ref<Resource> resource = value;
				if (resource.is_null()) {
					encoded["value"] = Variant();
					break;
				}
				const String kind = resource->get_meta("dora_reference_kind", String());
				const String id = resource->get_meta("dora_reference_id", String());
				encoded["type"] = kind;
				encoded["id"] = limited(id);
				const auto &map = kind == "SubResource" ? internal : external;
				if (kind == "Resource") {
					const String fallback = resource->get_meta("dora_reference_fallback", String());
					encoded["path"] = limited(fallback.is_empty() ? id : fallback);
					encoded["resolved"] = false;
				} else if (const Dictionary *record = map.getptr(id)) {
					encoded["resolved"] = true;
					encoded["resourceType"] = record->get("type", Variant());
					if (record->has("path")) {
						encoded["path"] = limited(record->get("path", String()));
					}
				} else {
					encoded["resolved"] = false;
				}
				break;
			}
			case Variant::ARRAY: {
				const Array array = value;
				Array items;
				for (int i = 0; i < MIN(array.size(), 64); ++i) {
					items.push_back(encode(array[i], depth + 1));
				}
				if (array.size() > 64) {
					truncated = true;
				}
				encoded["items"] = items;
				encoded["count"] = array.size();
				break;
			}
			case Variant::DICTIONARY: {
				const Dictionary dictionary = value;
				Array entries;
				const Array keys = dictionary.keys();
				for (int i = 0; i < MIN(keys.size(), 64); ++i) {
					Dictionary entry;
					entry["key"] = encode(keys[i], depth + 1);
					entry["value"] = encode(dictionary[keys[i]], depth + 1);
					entries.push_back(entry);
				}
				if (keys.size() > 64) {
					truncated = true;
				}
				encoded["entries"] = entries;
				encoded["count"] = keys.size();
				break;
			}
			default: {
				// Godot's writer preserves vectors/colors/transforms/packed arrays.
				// Only pure builtins reach this branch; object values handled above.
				String text;
				VariantWriter::write_to_string(value, text);
				encoded["value"] = limited(text);
				break;
			}
		}
		return encoded;
	}
	Array properties(const Dictionary &values, int limit) {
		Array out;
		const Array names = values.keys();
		for (int i = 0; i < MIN(names.size(), limit); ++i) {
			Dictionary property;
			property["name"] = limited(names[i]);
			property["value"] = encode(values[names[i]]);
			out.push_back(property);
		}
		if (names.size() > limit) {
			truncated = true;
		}
		return out;
	}
	Dictionary fields(const Dictionary &source) {
		Dictionary out;
		const Array names = source.keys();
		for (int i = 0; i < names.size(); ++i) {
			out[limited(names[i])] = encode(source[names[i]]);
		}
		return out;
	}
	bool exists(const String &path) {
		std::filesystem::path candidate;
		if (path.begins_with("res://")) {
			candidate = root / std::filesystem::u8path(path.substr(6).utf8().get_data());
		} else {
			if (path.contains("://")) {
				return false;
			}
			candidate = std::filesystem::u8path(path.utf8().get_data());
			if (!candidate.is_absolute()) {
				candidate = scene_directory / candidate;
			}
		}
		std::error_code error;
		const auto resolved = std::filesystem::weakly_canonical(candidate, error);
		return !error && inside(root, resolved) && std::filesystem::is_regular_file(resolved, error);
	}

	const char *report(const String &file, const Dictionary &options) {
		int max_nodes = 128, max_properties = 64;
		for (const String &name : { String("maxNodes"), String("maxProperties") }) {
			if (options.has(name) && (options[name].get_type() != Variant::INT && options[name].get_type() != Variant::FLOAT)) {
				return failure(file, name + " must be an integer");
			}
			if (options.has(name) && (!Math::is_finite(double(options[name])) || double(options[name]) < (name == "maxNodes" ? 1 : 0) || double(options[name]) > (name == "maxNodes" ? 512 : 128) || Math::floor(double(options[name])) != double(options[name]))) {
				return failure(file, name + " is outside the supported range");
			}
		}
		if (options.has("maxNodes")) {
			max_nodes = options["maxNodes"];
		}
		if (options.has("maxProperties")) {
			max_properties = options["maxProperties"];
		}
		if (options.has("nodePath") && options["nodePath"].get_type() != Variant::STRING) {
			return failure(file, "nodePath must be a scene-relative string");
		}
		const String filter = options.get("nodePath", String());
		Array nodes, resources, subresources, connections, editable, warnings;
		Dictionary node_paths;
		int total_nodes = 0, total_resources = 0, total_subresources = 0, total_connections = 0, matched = 0;
		for (const Section &section : sections) {
			if (section.kind != "ext_resource" && section.kind != "sub_resource") {
				continue;
			}
			const String id = section.fields.get("id", String()), type = section.fields.get("type", String());
			if (id.is_empty() || type.is_empty()) {
				return failure(file, "Resource section requires id and type", section.line);
			}
			auto &map = section.kind == "ext_resource" ? external : internal;
			if (map.has(id)) {
				return failure(file, "Duplicate resource ID: " + id, section.line);
			}
			map[id] = section.fields;
		}
		for (const Section &section : sections) {
			if (section.kind == "node") {
				++total_nodes;
				const String name = section.fields.get("name", String());
				if (name.is_empty() || name.length() > 256) {
					return failure(file, "Node requires a name of 1 to 256 characters", section.line);
				}
				const bool root_node = !section.fields.has("parent");
				if (total_nodes == 1 && !root_node) {
					return failure(file, "First scene node must be the root", section.line);
				}
				const String parent = section.fields.get("parent", String());
				const String path = root_node ? String(".") : parent == "." ? name
																			: parent.path_join(name);
				if (path.length() > 4096 || node_paths.has(path) || (root_node && total_nodes != 1)) {
					return failure(file, "Invalid or duplicate scene node path: " + path, section.line);
				}
				node_paths[path] = true;
				if (!filter.is_empty() && filter != "." && path != filter && !path.begins_with(filter + "/")) {
					continue;
				}
				++matched;
				if (nodes.size() >= max_nodes) {
					truncated = true;
					continue;
				}
				Dictionary node;
				node["name"] = name;
				node["path"] = path;
				node["parent"] = root_node ? Variant() : Variant(parent);
				node["type"] = section.fields.get("type", Variant());
				node["line"] = section.line;
				node["attributes"] = fields(section.fields);
				node["properties"] = properties(section.properties, max_properties);
				node["propertyCount"] = section.properties.size();
				node["script"] = section.properties.has("script") ? encode(section.properties["script"]) : Variant();
				node["instance"] = section.fields.has("instance") ? encode(section.fields["instance"]) : Variant();
				nodes.push_back(node);
			} else if (section.kind == "ext_resource" || section.kind == "sub_resource") {
				const bool ext = section.kind == "ext_resource";
				if (ext) {
					++total_resources;
				} else {
					++total_subresources;
				}
				Array &output = ext ? resources : subresources;
				if (output.size() >= 128) {
					truncated = true;
					continue;
				}
				Dictionary resource;
				resource["id"] = limited(section.fields.get("id", String()));
				resource["type"] = limited(section.fields.get("type", String()));
				resource["line"] = section.line;
				if (ext) {
					const String path = section.fields.get("path", String());
					resource["path"] = limited(path);
					resource["exists"] = exists(path);
					resource["uid"] = section.fields.get("uid", Variant());
					if (!exists(path)) {
						warnings.push_back("Unresolved or unavailable external resource: " + limited(path));
					}
				} else {
					resource["properties"] = properties(section.properties, max_properties);
					resource["propertyCount"] = section.properties.size();
				}
				output.push_back(resource);
			} else if (section.kind == "connection") {
				++total_connections;
				for (const String &required : { String("signal"), String("from"), String("to"), String("method") }) {
					if (!section.fields.has(required)) {
						return failure(file, "Connection requires " + required, section.line);
					}
				}
				if (connections.size() >= 128) {
					truncated = true;
					continue;
				}
				Dictionary connection;
				connection["signal"] = limited(section.fields["signal"]);
				connection["from"] = limited(section.fields["from"]);
				connection["to"] = limited(section.fields["to"]);
				connection["method"] = limited(section.fields["method"]);
				connection["attributes"] = fields(section.fields);
				connection["line"] = section.line;
				connections.push_back(connection);
			} else if (section.kind == "editable") {
				if (editable.size() < 128) {
					editable.push_back(fields(section.fields));
				} else {
					truncated = true;
				}
			}
		}
		if (total_nodes == 0) {
			return failure(file, "Scene contains no root node");
		}
		if (!filter.is_empty() && filter != "." && matched == 0) {
			return failure(file, "Scene nodePath was not found: " + filter);
		}
		warnings.push_back("Authored metadata only: inherited/instanced scenes are references, not expanded; script exports and runtime defaults are not evaluated.");
		Dictionary out;
		out["success"] = true;
		out["path"] = file;
		out["format"] = sections[0].fields.get("format", Variant());
		out["uid"] = sections[0].fields.get("uid", Variant());
		out["nodes"] = nodes;
		out["resources"] = resources;
		out["subresources"] = subresources;
		out["connections"] = connections;
		out["editableInstances"] = editable;
		out["warnings"] = warnings;
		out["nodeCount"] = total_nodes;
		out["matchedNodeCount"] = matched;
		out["resourceCount"] = total_resources;
		out["subresourceCount"] = total_subresources;
		out["connectionCount"] = total_connections;
		out["truncated"] = truncated;
		finish(out);
		if (result.size() > 262144) {
			return failure(file, "Scene report exceeds 256 KiB; select nodePath or reduce maxNodes/maxProperties");
		}
		return result.c_str();
	}
};
template <class Runtime, class Boot>
inline const char *inspect(Runtime &runtime, const DoraGodotConfig *config, const char *file, const char *options, Boot boot) {
	if (!config || config->size < sizeof(*config) || !config->project_path || !file) {
		return failure("", "Invalid static scene request");
	}
	const String name = String::utf8(file);
	if (runtime.terminated) {
		return failure(name, "Godot runtime has terminated; restart Dora");
	}
	std::error_code error;
	const auto root = std::filesystem::canonical(std::filesystem::u8path(config->project_path), error);
	if (error) {
		return failure(name, "Cannot resolve Godot project directory");
	}
	const auto target = std::filesystem::canonical(std::filesystem::u8path(file), error);
	if (error || !inside(root, target) || !std::filesystem::is_regular_file(target, error)) {
		return failure(name, "Scene must be an existing file inside the Godot project");
	}
	if (name.get_extension().to_lower() != "tscn") {
		return failure(name, "Static scene inspection supports .tscn files; binary .scn is not supported");
	}
	const auto size = std::filesystem::file_size(target, error);
	if (error || size > 2 * 1024 * 1024) {
		return failure(name, "Static scene source exceeds 2 MiB or cannot be read");
	}
	if (!std::filesystem::is_regular_file(root / "project.godot", error)) {
		return failure(name, "Project directory must contain project.godot");
	}
	if (!runtime.instance && !boot(config)) {
		return failure(name, String::utf8(runtime.error.c_str()));
	}
	// No Project::load/unload: queries never change the running project's settings.
	DoraGodotDiagnostics::ScopedMetadataQuery diagnostics;
	JSON request;
	if (request.parse(String::utf8(options ? options : "{}")) != OK || request.get_data().get_type() != Variant::DICTIONARY) {
		return failure(name, "Scene inspection options must be a JSON object");
	}
	Parser parser;
	parser.root = root;
	parser.scene_directory = target.parent_path();
	int line = 1;
	String message;
	const Ref<FileAccess> source = FileAccess::open(name, FileAccess::READ);
	if (source.is_null()) {
		return failure(name, "Cannot read scene source file");
	}
	if (parser.parse(source->get_as_text(), line, message) != OK) {
		return failure(name, message.is_empty() ? String("Unable to parse Godot text scene") : message, line);
	}
	return parser.report(name, request.get_data());
}
} //namespace DoraGodotSceneInspect
