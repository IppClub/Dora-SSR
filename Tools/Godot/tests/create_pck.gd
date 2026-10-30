# Build a deterministic source-only test pack with a real Godot PCKPacker.
# This does not perform asset imports; imported projects must bundle their
# Godot-generated .godot/imported files when exported.
extends SceneTree
func _init() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 2:
        push_error("Expected project directory and destination .pck")
        quit(2)
        return
    var pack := PCKPacker.new()
    if pack.pck_start(args[1]) != OK:
        push_error("Cannot create test PCK")
        quit(2)
        return
    for name in ["project.godot", "main.tscn", "main.gd", "state.gd", ".godot/global_script_class_cache.cfg"]:
        if pack.add_file("res://" + name, args[0].path_join(name)) != OK:
            push_error("Cannot add resource: " + name)
            quit(2)
            return
    for directory in ["assets", ".godot/imported"]:
        if _add_directory(pack, args[0], directory) != OK:
            push_error("Cannot pack directory: " + directory)
            quit(2)
            return
    if pack.flush() != OK:
        push_error("Cannot finish test PCK")
        quit(2)
        return
    if FileAccess.file_exists(args[0].path_join("assets/marker.png.import")):
        if not ProjectSettings.load_resource_pack(args[1]):
            push_error("Cannot mount imported test PCK")
            quit(2)
            return
        var texture := load("res://assets/marker.png") as Texture2D
        if texture == null or texture.get_width() != 16 or FileAccess.file_exists("res://assets/marker.png"):
            push_error("Imported test pack must resolve .ctex without its source PNG")
            quit(2)
            return
        print("GODOT_PCK_TEST imported_texture=1 raw_png_present=0")
    print("GODOT_PCK_TEST created=", args[1])
    quit(0)

func _add_directory(pack: PCKPacker, root: String, relative: String) -> int:
    var source := root.path_join(relative)
    if not DirAccess.dir_exists_absolute(source):
        return OK
    var files := DirAccess.get_files_at(source)
    files.sort()
    for name in files:
        # Prove that the runtime uses the imported resource, not the PNG source.
        if name.ends_with(".png") and FileAccess.file_exists(source.path_join(name) + ".import"):
            continue
        var result := pack.add_file("res://" + relative.path_join(name), source.path_join(name))
        if result != OK:
            return result
    var directories := DirAccess.get_directories_at(source)
    directories.sort()
    for name in directories:
        var result := _add_directory(pack, root, relative.path_join(name))
        if result != OK:
            return result
    return OK
