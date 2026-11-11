// Runtime-only desktop importers: no EditorNode, user scripts or external process.
#pragma once
#include "runtime_diagnostics.h"
#include "GodotBridgeImport.h"

#include "core/io/config_file.h"
#include "core/io/image_loader.h"
#include "core/io/json.h"
#include "core/io/resource_importer.h"
#include "core/io/resource_saver.h"
#include "scene/resources/audio_stream_wav.h"
#include "scene/resources/font.h"
#include "scene/resources/portable_compressed_texture.h"
Ref<ResourceImporter> dora_godot_mp3_importer();
Ref<ResourceImporter> dora_godot_ogg_importer();
#include "scene/resources/packed_scene.h"

#include "modules/gltf/gltf_document.h"
#include "modules/gltf/gltf_state.h"

#include <filesystem>

namespace DoraGodotAssetImport {
inline std::string result;
inline const char *reply(const String &file, const String &status, const String &message, const String &output = String(), const Dictionary &settings = Dictionary()) {
	Dictionary value;
	value["success"] = status != "failed";
	value["path"] = file;
	value["status"] = status;
	value["message"] = message;
	value["output"] = output;
	value["settings"] = settings;
	result = JSON::stringify(value).utf8().get_data();
	return result.c_str();
}
inline bool inside(const std::filesystem::path &root, const std::filesystem::path &file) {
	auto r = root.begin(), f = file.begin();
	for (; r != root.end(); ++r, ++f) {
		if (f == file.end() || *r != *f) {
			return false;
		}
	}
	return f != file.end();
}
inline const char *convert(const char *project, const char *file, const char *options) {
	const String source = String::utf8(file ? file : "");
	std::error_code error;
	const auto root = std::filesystem::canonical(std::filesystem::u8path(project), error);
	if (error) {
		return reply(source, "failed", "Cannot resolve project directory");
	}
	const auto target = std::filesystem::canonical(std::filesystem::u8path(file ? file : ""), error);
	if (error || !inside(root, target) || !std::filesystem::is_regular_file(target, error)) {
		return reply(source, "failed", "Asset must be an existing file inside the project; symlink escapes are rejected");
	}
	const auto cache = std::filesystem::weakly_canonical(root / ".godot" / "imported", error);
	if (error || !inside(root, cache)) {
		return reply(source, "failed", "Import cache escapes the project");
	}
	const auto sidecar = std::filesystem::weakly_canonical(std::filesystem::u8path(std::string(file) + ".import"), error);
	if (error || !inside(root, sidecar)) {
		return reply(source, "failed", "Import metadata escapes the project");
	}
	for (const String &write_path : { source + ".import.pending", ProjectSettings::get_singleton()->globalize_path(ProjectSettings::get_singleton()->get_project_data_path().path_join("uid_cache.bin")) }) {
		const auto destination=std::filesystem::u8path(write_path.utf8().get_data());
		if(std::filesystem::is_symlink(destination,error)) return reply(source,"failed","Import metadata destination is a symlink");
		const auto resolved = std::filesystem::weakly_canonical(destination, error);
		if (error || !inside(root, resolved)) {
			return reply(source, "failed", "Import metadata destination escapes the project");
		}
	}
	JSON request;
	if (request.parse(String::utf8(options ? options : "{}")) != OK || request.get_data().get_type() != Variant::DICTIONARY) {
		return reply(source, "failed", "Import options must be a JSON object");
	}
	const Dictionary opts = request.get_data();
	for (const Variant &key : opts.keys()) {
		if (key != Variant("force") && key != Variant("settings")) return reply(source, "failed", "Unknown import option: " + String(key));
	}
	if (opts.has("force") && opts["force"].get_type() != Variant::BOOL) {
		return reply(source, "failed", "force must be boolean");
	}
	const bool force = opts.get("force", false);
	if (opts.has("settings") && opts["settings"].get_type() != Variant::DICTIONARY) return reply(source, "failed", "settings must be an object");
	const String local = ProjectSettings::get_singleton()->localize_path(source);
	if (!local.begins_with("res://") || local.begins_with("res://.godot/")) {
		return reply(source, "failed", "Invalid source asset path");
	}
	const String ext = source.get_extension().to_lower();
	const bool image = ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "webp" || ext == "svg" || ext == "bmp" || ext == "tga";
	const bool font = ext == "ttf" || ext == "otf" || ext == "woff" || ext == "woff2";
	Ref<ResourceImporter> importer;
	if (ext == "mp3") {
		importer = dora_godot_mp3_importer();
	}
	if (ext == "ogg") {
		importer = dora_godot_ogg_importer();
	}
	const bool model = ext == "gltf" || ext == "glb";

	if (!image && !font && !model && ext != "wav" && importer.is_null()) {
		return reply(source, "failed", "Embedded import currently supports images, WAV/MP3/Ogg audio, fonts and glTF/GLB; this asset format is not supported");
	}
	const String hash = FileAccess::get_sha256(source);
	if (hash.is_empty()) {
		return reply(source, "failed", "Cannot read source asset");
	}
	const String base = "res://.godot/imported/" + local.get_file() + "-" + local.md5_text();
	ConfigFile metadata;
	const bool existing = metadata.load(source + ".import") == OK;
	if (!existing && FileAccess::exists(source + ".import")) {
		return reply(source, "failed", "Existing import metadata is unreadable; it was preserved");
	}

	if (existing && int(metadata.get_value("dora", "import_version", 0)) != 1) {
		return reply(source, "failed", "Existing editor import settings are preserved. Embedded reimport of editor-managed assets is not supported yet");
	}
	// Settings are per source asset, merged with the last Dora-owned settings.
	// Omitting them must not silently reset an earlier non-default import.
	Dictionary defaults;
	if (image) defaults["mipmaps"] = false;
	if (importer.is_valid()) { defaults["loop"] = false; defaults["loopOffsetSeconds"] = 0.0; }
	const Variant saved = metadata.get_value("dora", "settings", Dictionary());
	if (saved.get_type() != Variant::DICTIONARY) return reply(source, "failed", "Stored import settings are invalid; metadata was preserved");
	Dictionary settings = defaults.duplicate();
	settings.merge(saved, true);
	const Dictionary changes = opts.get("settings", Dictionary());
	settings.merge(changes, true);
	for (const Variant &key : settings.keys()) {
		if (key.get_type() != Variant::STRING) return reply(source, "failed", "Import setting names must be strings");
		const String name = key;
		const Variant value = settings[key];
		if (name == "mipmaps" && image) {
			if (value.get_type() != Variant::BOOL) return reply(source, "failed", "mipmaps must be boolean");
		} else if (name == "loop" && (ext == "wav" || importer.is_valid())) {
			if (value.get_type() != Variant::BOOL) return reply(source, "failed", "loop must be boolean");
		} else if (name == "loopOffsetSeconds" && importer.is_valid()) {
			if ((value.get_type() != Variant::FLOAT && value.get_type() != Variant::INT) || !Math::is_finite(double(value)) || !Math::is_finite(float(double(value))) || double(value) < 0)
				return reply(source, "failed", "loopOffsetSeconds must be a finite non-negative number");
			settings[key] = double(value);
		} else return reply(source, "failed", "Unsupported import setting for ." + ext + ": " + name);
	}
	const String settings_hash = JSON::stringify(settings, "", true, true).sha256_text();
	const String defaults_hash = JSON::stringify(defaults, "", true, true).sha256_text();
	const String output = base + "." + (importer.is_valid() ? importer->get_save_extension() : String("res"));
	const auto output_path = std::filesystem::weakly_canonical(std::filesystem::u8path(ProjectSettings::get_singleton()->globalize_path(output).utf8().get_data()), error);
	if (error || !inside(root, output_path)) {
		return reply(source, "failed", "Imported resource destination escapes the project");
	}
	if (!force && !model && existing && String(metadata.get_value("dora", "source_sha256", String())) == hash &&
			String(metadata.get_value("dora", "settings_sha256", defaults_hash)) == settings_hash &&
			String(metadata.get_value("remap", "path", String())) == output && int(metadata.get_value("dora", "import_version", 0)) == 1 && FileAccess::exists(output) &&
			String(metadata.get_value("dora", "output_sha256", String())) == FileAccess::get_sha256(output)) {
		// Restore the UID cache too: a user may have deleted only uid_cache.bin.
		const auto cached_uid = ResourceUID::get_singleton()->text_to_id(metadata.get_value("remap", "uid", String()));
		if (cached_uid != ResourceUID::INVALID_ID) {
			if (ResourceUID::get_singleton()->has_id(cached_uid)) {
				ResourceUID::get_singleton()->set_id(cached_uid, local);
			} else {
				ResourceUID::get_singleton()->add_id(cached_uid, local);
			}
			if (ResourceUID::get_singleton()->save_to_cache() != OK) {
				return reply(source, "failed", "Cannot persist imported resource UID cache");
			}
			return reply(source, "skipped", "Imported asset is up to date", output, settings);
		}
	}
	if (DirAccess::make_dir_recursive_absolute("res://.godot/imported") != OK) {
		return reply(source, "failed", "Cannot create Godot import cache");
	}
	const String temporary = base + "-pending";
	Error imported = ERR_UNAVAILABLE;
	Ref<Resource> resource;
	String type;
	auto uid = existing ? ResourceUID::get_singleton()->text_to_id(metadata.get_value("remap", "uid", String())) : ResourceUID::get_singleton()->create_id();
	if (uid == ResourceUID::INVALID_ID) {
		uid = ResourceUID::get_singleton()->create_id();
	}
	const auto pending_native = std::filesystem::u8path(ProjectSettings::get_singleton()->globalize_path(temporary + "." + output.get_extension()).utf8().get_data());
	if (std::filesystem::is_symlink(pending_native, error)) {
		return reply(source, "failed", "Temporary import destination is a symlink");
	}
	if (importer.is_valid()) {
		List<ResourceImporter::ImportOption> defaults;
		importer->get_import_options(local, &defaults);
		HashMap<StringName, Variant> parameters;
		for (const auto &option : defaults) {
			parameters[option.option.name] = option.default_value;
		}
		parameters["loop"] = settings["loop"];
		parameters["loop_offset"] = settings["loopOffsetSeconds"];
		List<String> variants, generated;
		Variant details;
		imported = importer->import(uid, local, temporary, parameters, &variants, &generated, &details);
		type = importer->get_resource_type();
	} else {
		if (image) {
			Ref<Image> pixels;
			pixels.instantiate();
			imported = ImageLoader::load_image(local, pixels);
			if (imported == OK && bool(settings["mipmaps"])) imported = pixels->generate_mipmaps();
			if (imported == OK && !pixels->is_empty()) {
				Ref<PortableCompressedTexture2D> texture;
				texture.instantiate();
				texture->set_keep_compressed_buffer(true);
				texture->create_from_image(pixels, PortableCompressedTexture2D::COMPRESSION_MODE_LOSSLESS);
				resource = texture;
				type = "PortableCompressedTexture2D";
			}
		} else if (model) {
			Ref<GLTFDocument> document;
			document.instantiate();
			Ref<GLTFState> state;
			state.instantiate();
			state->set_handle_binary_image(GLTFState::HANDLE_BINARY_EMBED_AS_UNCOMPRESSED);
			imported = document->append_from_file(local, state);
			if (imported == OK) {
				Node *scene = document->generate_scene(state);
				if (scene) {
					Ref<PackedScene> packed;
					packed.instantiate();
					imported = packed->pack(scene);
					resource = packed;
					type = "PackedScene";
					memdelete(scene); // Never parent, enter SceneTree or execute scripts.
				} else {
					imported = ERR_CANT_CREATE;
				}
			}
		} else if (font) {
			Ref<FontFile> value;
			value.instantiate();
			imported = value->load_dynamic_font(local);
			resource = value;
			type = "FontFile";
		} else {
			Dictionary parameters;
			if (settings.has("loop")) {
				parameters["edit/loop_mode"] = bool(settings["loop"]) ? 2 : 1;
				parameters["edit/loop_begin"] = 0;
				parameters["edit/loop_end"] = -1;
			}
			resource = AudioStreamWAV::load_from_file(local, parameters);
			type = "AudioStreamWAV";
			imported = resource.is_valid() ? OK : ERR_FILE_CORRUPT;
		}
		if (imported == OK && resource.is_valid()) {
			imported = ResourceSaver::save(resource, temporary + ".res");
		}
	}
	const String pending = temporary + "." + output.get_extension();
	if (imported != OK || !FileAccess::exists(pending)) {
		DirAccess::remove_absolute(pending);
		return reply(source, "failed", String::utf8(DoraGodotDiagnostics::get("Godot importer failed: " + std::to_string(imported))));
	}
	if (importer.is_valid() && bool(settings["loop"])) {
		Ref<AudioStream> stream = ResourceLoader::load(pending, "", ResourceFormatLoader::CACHE_MODE_IGNORE);
		if (stream.is_null() || stream->get_length() <= double(settings["loopOffsetSeconds"])) {
			DirAccess::remove_absolute(pending);
			return reply(source, "failed", "loopOffsetSeconds must be less than the audio duration");
		}
	}
	if (DirAccess::rename_absolute(pending, output) != OK) {
		DirAccess::remove_absolute(pending);
		return reply(source, "failed", "Cannot publish imported asset");
	}
	// Standard importer identities let the official editor reimport originals
	// into its own cache. The Dora marker tracks ownership, never editor options.
	metadata.set_value("remap", "importer", importer.is_valid() ? importer->get_importer_name() : image ? String("texture")
					: font																				? String("font_data_dynamic")
					: model																				? String("scene")
																										: String("wav"));
	metadata.set_value("remap", "type", type);
	metadata.set_value("remap", "uid", ResourceUID::get_singleton()->id_to_text(uid));
	metadata.set_value("remap", "path", output);
	metadata.set_value("deps", "source_file", local);
	metadata.set_value("deps", "dest_files", PackedStringArray({ output }));
	metadata.set_value("dora", "source_sha256", hash);
	metadata.set_value("dora", "import_version", 1);
	metadata.set_value("dora", "output_sha256", FileAccess::get_sha256(output));
	metadata.set_value("dora", "settings", settings);
	metadata.set_value("dora", "settings_sha256", settings_hash);
	if (image) metadata.set_value("params", "mipmaps/generate", settings["mipmaps"]);
	if (importer.is_valid()) {
		metadata.set_value("params", "loop", settings["loop"]);
		metadata.set_value("params", "loop_offset", settings["loopOffsetSeconds"]);
	}
	if (ext == "wav" && settings.has("loop")) {
		metadata.set_value("params", "edit/loop_mode", bool(settings["loop"]) ? 2 : 1);
		metadata.set_value("params", "edit/loop_begin", 0);
		metadata.set_value("params", "edit/loop_end", -1);
	}

	const String pending_metadata = source + ".import.pending";
	if (metadata.save(pending_metadata) != OK || DirAccess::rename_absolute(pending_metadata, source + ".import") != OK) {
		DirAccess::remove_absolute(pending_metadata);
		return reply(source, "failed", "Cannot publish import metadata");
	}
	if (ResourceUID::get_singleton()->has_id(uid)) {
		ResourceUID::get_singleton()->set_id(uid, local);
	} else {
		ResourceUID::get_singleton()->add_id(uid, local);
	}
	if (ResourceUID::get_singleton()->save_to_cache() != OK) {
		return reply(source, "failed", "Cannot persist imported resource UID cache");
	}
	return reply(source, "imported", "Imported with bundled Godot runtime", output, settings);
}
template <class Runtime, class Boot>
inline const char *import_asset(Runtime &runtime, const DoraGodotConfig *config, const char *file, const char *options, Boot boot) {
    DoraGodotDiagnostics::ScopedMetadataQuery diagnostics;
#if defined(MACOS_ENABLED) || defined(WINDOWS_ENABLED) || defined(LINUXBSD_ENABLED)
	if (!config || config->size < sizeof(*config) || !config->project_path || !file) {
		return reply("", "failed", "Invalid import request");
	}
	if (runtime.active) {
		return reply(String::utf8(file), "failed", "Stop the running Godot project before importing assets");
	}
	if (runtime.terminated) {
		return reply(String::utf8(file), "failed", "Godot runtime has terminated; restart Dora");
	}
	if (!runtime.instance && !boot(config)) {
		return reply(String::utf8(file), "failed", String::utf8(runtime.error.c_str()));
	}
	if (!DoraGodotProject::load(runtime.instance, config->project_path, "", 1, 1, runtime.error, false)) {
		DoraGodotProject::unload(runtime.instance);
		return reply(String::utf8(file), "failed", String::utf8(runtime.error.c_str()));
	}
	const char *value = convert(config->project_path, file, options);
	DoraGodotProject::unload(runtime.instance);
	return value;
#else
	return reply(String::utf8(file ? file : ""), "failed", "Embedded asset importing is available on desktop only");
#endif
}
} //namespace DoraGodotAssetImport
