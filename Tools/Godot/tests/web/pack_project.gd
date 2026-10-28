extends SceneTree
func _init() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 2:
        push_error("Expected source directory and output PCK")
        quit(1)
        return
    var pack := PCKPacker.new()
    var result := pack.pck_start(args[1])
    if result != OK:
        quit(result)
        return
    for file in ["project.godot", "main.tscn", "main.gd"]:
        result = pack.add_file("res://" + file, args[0].path_join(file))
        if result != OK:
            quit(result)
            return
    result = pack.add_file("res://.godot/global_script_class_cache.cfg", args[0].path_join("class_cache.cfg"))
    if result != OK:
        quit(result)
        return
    quit(pack.flush())
