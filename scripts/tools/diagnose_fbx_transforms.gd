extends SceneTree


func _init() -> void:
	var path := OS.get_environment("FBX_DIAG_PATH")
	if path.is_empty():
		path = "res://assets/fbx_model/Character_Base.FBX"
	var packed_scene := ResourceLoader.load(path) as PackedScene
	if packed_scene == null:
		print("failed to load %s" % path)
		quit(1)
		return
	var instance := packed_scene.instantiate()
	_print_transforms(instance, 0)
	instance.free()
	quit()


func _print_transforms(node: Node, depth: int) -> void:
	var indent := "  ".repeat(depth)
	if node is Node3D:
		var node_3d := node as Node3D
		print("%s%s [%s] pos=%s rot=%s scale=%s" % [
			indent,
			node.name,
			node.get_class(),
			node_3d.position,
			node_3d.rotation_degrees,
			node_3d.scale,
		])
		if depth == 1:
			print("%s  axes x=%s y=%s z=%s" % [
				indent,
				node_3d.transform.basis.x,
				node_3d.transform.basis.y,
				node_3d.transform.basis.z,
			])
	else:
		print("%s%s [%s]" % [indent, node.name, node.get_class()])
	for child in node.get_children():
		_print_transforms(child, depth + 1)
