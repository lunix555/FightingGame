extends SceneTree


func _init() -> void:
	var path := OS.get_environment("FBX_DIAG_PATH")
	if path.is_empty():
		print("FBX_DIAG_PATH is empty")
		quit(1)
		return

	var packed_scene := ResourceLoader.load(path) as PackedScene
	if packed_scene == null:
		print("%s | failed to load" % path)
		quit(1)
		return

	var root := packed_scene.instantiate()
	var counts := {
		"mesh_instances": 0,
		"surface_slots": 0,
		"materials": 0,
		"animation_players": 0,
		"animations": 0,
	}
	_walk(root, counts)
	print("%s | meshes=%d surfaces=%d materials=%d anim_players=%d animations=%d" % [
		path.get_file(),
		counts["mesh_instances"],
		counts["surface_slots"],
		counts["materials"],
		counts["animation_players"],
		counts["animations"],
	])
	root.free()
	quit()


func _walk(node: Node, counts: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		counts["mesh_instances"] += 1
		var mesh := mesh_instance.mesh
		if mesh != null:
			for surface_index in range(mesh.get_surface_count()):
				counts["surface_slots"] += 1
				var material := mesh.surface_get_material(surface_index)
				if material == null:
					material = mesh_instance.get_surface_override_material(surface_index)
				if material != null:
					counts["materials"] += 1

	if node is AnimationPlayer:
		var player := node as AnimationPlayer
		counts["animation_players"] += 1
		counts["animations"] += player.get_animation_list().size()

	for child in node.get_children():
		_walk(child, counts)
