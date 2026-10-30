extends Node3D

func _ready() -> void:
    var document := GLTFDocument.new()
    var state := GLTFState.new()
    var result := document.append_from_file("res://model.gltf", state)
    assert(result == OK, "Runtime glTF parsing failed")
    var imported := document.generate_scene(state)
    assert(imported != null, "Runtime glTF scene generation failed")
    add_child(imported)
    var mesh := imported as MeshInstance3D
    if mesh == null:
        mesh = imported.find_child("FixtureMesh", true, false) as MeshInstance3D
    assert(mesh != null and mesh.mesh.get_surface_count() == 1)
    var arrays: Array = mesh.mesh.surface_get_arrays(0)
    var vertices: int = arrays[Mesh.ARRAY_VERTEX].size()
    assert(vertices == 24, "Imported glTF vertex count changed")
    var material := ShaderMaterial.new()
    material.shader = load("res://fixture.gdshader")
    assert(material.shader != null, "Runtime spatial shader resource failed")
    mesh.material_override = material
    var animation := imported.find_child("AnimationPlayer", true, false) as AnimationPlayer
    assert(animation != null and animation.has_animation("Spin"), "glTF animation was not imported")
    assert(animation.get_animation("Spin").get_track_count() == 2, "Both glTF animation channels must be imported")
    animation.get_animation("Spin").loop_mode = Animation.LOOP_LINEAR
    animation.play("Spin")
    var camera := Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 3
    camera.position = Vector3(0,2,6)
    add_child(camera)
    camera.look_at(Vector3.ZERO)
    camera.current = true
    print("GODOT_PROJECT_3D gltf_vertices=24 animation=Spin surfaces=1 tracks=2 shader=spatial")
