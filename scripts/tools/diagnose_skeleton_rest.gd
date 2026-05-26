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
	var skeleton := _find_skeleton(root)
	if skeleton == null:
		print("%s | no Skeleton3D" % path)
		root.free()
		quit(1)
		return

	print("%s bones=%d" % [path, skeleton.get_bone_count()])
	for bone_name in ["root", "bone_2", "bone_3", "pelvis", "spine_02"]:
		var index := skeleton.find_bone(bone_name)
		if index < 0:
			print("  %s missing" % bone_name)
			continue
		var rest := skeleton.get_bone_rest(index)
		print("  %s rest_origin=%s rest_euler_deg=%s" % [
			bone_name,
			rest.origin,
			rest.basis.get_euler() * 180.0 / PI,
		])

	root.free()
	quit()


func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found
	return null
