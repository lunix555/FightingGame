extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("Usage: --script res://scripts/tools/validate_character_visual.gd -- <scene_path> <animation>...")
		quit(2)
		return

	var scene_path := String(args[0])
	var expected := args.slice(1)
	var packed_scene := ResourceLoader.load(scene_path) as PackedScene
	if packed_scene == null:
		printerr("Missing scene: %s" % scene_path)
		quit(2)
		return

	var root := packed_scene.instantiate()
	var player := _find_animation_player(root)
	if player == null:
		printerr("No AnimationPlayer: %s" % scene_path)
		root.free()
		quit(2)
		return

	var animations := PackedStringArray(player.get_animation_list())
	print("AnimationPlayer: %s" % player.name)
	print("Animations: %s" % ", ".join(animations))
	var missing: Array[String] = []
	for animation_name in expected:
		if not player.has_animation(String(animation_name)):
			missing.append(String(animation_name))

	root.free()
	if not missing.is_empty():
		printerr("Missing required animations: %s" % ", ".join(missing))
		quit(1)
		return
	print("Character visual validation passed.")
	quit(0)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
