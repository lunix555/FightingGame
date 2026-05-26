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

	var instance := packed_scene.instantiate() as Node3D
	_print_bounds(instance, "original")
	for rotation in [
		Vector3(0.0, 0.0, 90.0),
		Vector3(0.0, 0.0, -90.0),
		Vector3(90.0, 0.0, 0.0),
		Vector3(-90.0, 0.0, 0.0),
	]:
		instance.rotation_degrees = rotation
		_print_bounds(instance, "rot %s" % str(rotation))
	instance.queue_free()
	quit()


func _print_bounds(root_node: Node3D, label: String) -> void:
	var bounds := _calculate_bounds(root_node)
	print("%s | pos=%s size=%s" % [label, bounds.position, bounds.size])


func _calculate_bounds(root_node: Node3D) -> AABB:
	var has_bounds := false
	var combined := AABB()
	var stack: Array = [{"node": root_node, "transform": Transform3D.IDENTITY}]

	while not stack.is_empty():
		var item: Dictionary = stack.pop_back()
		var node := item["node"] as Node
		var parent_transform := item["transform"] as Transform3D
		var node_transform := parent_transform
		if node is Node3D:
			node_transform = parent_transform * (node as Node3D).transform
		if node is MeshInstance3D:
			var mesh_instance := node as MeshInstance3D
			var local_aabb := node_transform * mesh_instance.get_aabb()
			if has_bounds:
				combined = combined.merge(local_aabb)
			else:
				combined = local_aabb
				has_bounds = true
		for child in node.get_children():
			stack.append({"node": child, "transform": node_transform})

	return combined if has_bounds else AABB()
