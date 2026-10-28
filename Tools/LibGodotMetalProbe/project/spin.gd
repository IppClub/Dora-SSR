extends MeshInstance3D

func _process(delta: float) -> void:
    rotate_y(delta * 1.25)
    rotation.x = 0.4 + sin(Time.get_ticks_msec() * 0.001) * 0.18
