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
	var animation_player := _find_animation_player(root)
	if animation_player == null:
		print("%s | no AnimationPlayer" % path)
		root.free()
		quit(1)
		return

	for animation_name in animation_player.get_animation_list():
		var animation := animation_player.get_animation(animation_name)
		if animation == null:
			continue
		print("Animation %s length=%.3f tracks=%d" % [animation_name, animation.length, animation.get_track_count()])
		for index in range(animation.get_track_count()):
			var track_path := str(animation.track_get_path(index))
			if not track_path.contains(":root") and not track_path.contains(":pelvis"):
				continue
			var key_count := animation.track_get_key_count(index)
			if key_count <= 0:
				continue
			var value = animation.track_get_key_value(index, 0)
			if value is Quaternion:
				var basis := Basis(value as Quaternion)
				print("  track %03d type=%d path=%s first_euler_deg=%s" % [
					index,
					animation.track_get_type(index),
					track_path,
					basis.get_euler() * 180.0 / PI,
				])
			else:
				print("  track %03d type=%d path=%s first=%s" % [
					index,
					animation.track_get_type(index),
					track_path,
					str(value),
				])

	root.free()
	quit()


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
