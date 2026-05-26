extends SceneTree


func _init() -> void:
	var path := OS.get_environment("FBX_DIAG_PATH")
	if path.is_empty():
		path = "res://assets/fbx_anim/Idle_Anim1.FBX"

	var packed_scene := ResourceLoader.load(path) as PackedScene
	if packed_scene == null:
		print("%s | failed to load" % path)
		quit(1)
		return

	var root := packed_scene.instantiate()
	var skeleton := _find_skeleton(root)
	var animation_player := _find_animation_player(root)
	if skeleton == null or animation_player == null:
		print("%s | missing skeleton/player" % path)
		root.free()
		quit(1)
		return

	var root_bone := skeleton.find_bone("root")
	var rest_basis := skeleton.get_bone_rest(root_bone).basis
	var rest_quat := rest_basis.get_rotation_quaternion()
	print("anim root rest euler=%s" % str(rest_basis.get_euler() * 180.0 / PI))

	for animation_name in animation_player.get_animation_list():
		var animation := animation_player.get_animation(animation_name)
		for track_index in range(animation.get_track_count()):
			if str(animation.track_get_path(track_index)) != "Skeleton3D:root":
				continue
			if animation.track_get_type(track_index) != Animation.TYPE_ROTATION_3D:
				continue
			var key_quat := animation.track_get_key_value(track_index, 0) as Quaternion
			_print_quat("raw", key_quat)
			_print_quat("rest_inv * raw", rest_quat.inverse() * key_quat)
			_print_quat("raw * rest_inv", key_quat * rest_quat.inverse())
			_print_quat("rest * raw", rest_quat * key_quat)
			_print_quat("raw * rest", key_quat * rest_quat)

	root.free()
	quit()


func _print_quat(label: String, quat: Quaternion) -> void:
	print("%s euler=%s" % [label, Basis(quat).get_euler() * 180.0 / PI])


func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found
	return null


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
