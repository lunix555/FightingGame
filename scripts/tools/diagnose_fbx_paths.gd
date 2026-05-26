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
	print("--- %s ---" % path)
	_print_tree(root, 0, 3)
	var animation_player := _find_animation_player(root)
	if animation_player == null:
		print("no AnimationPlayer")
		root.free()
		quit()
		return

	print("AnimationPlayer path: %s" % str(animation_player.get_path()))
	for animation_name in animation_player.get_animation_list():
		var animation := animation_player.get_animation(animation_name)
		if animation == null:
			continue
		print("Animation %s length=%.3f tracks=%d" % [animation_name, animation.length, animation.get_track_count()])
		var limit := mini(animation.get_track_count(), 30)
		for index in range(limit):
			print("  track %03d type=%d path=%s" % [
				index,
				animation.track_get_type(index),
				str(animation.track_get_path(index)),
			])
	root.free()
	quit()


func _print_tree(node: Node, depth: int, max_depth: int) -> void:
	if depth > max_depth:
		return
	print("%s%s [%s]" % ["  ".repeat(depth), node.name, node.get_class()])
	for child in node.get_children():
		_print_tree(child, depth + 1, max_depth)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
