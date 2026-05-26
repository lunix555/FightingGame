extends SceneTree

const FBX_SCENES := [
	"res://assets/fbx_anim/Idle_Anim1.FBX",
	"res://assets/fbx_anim/Cross_Punch_Anim1.FBX",
	"res://assets/fbx_anim/Mma_Kick_Anim1.FBX",
	"res://assets/fbx_anim/Jump_Anim1.FBX",
	"res://assets/fbx_anim/Fast_Run_Anim.FBX",
	"res://assets/fbx_anim/Fast_Run__1__Anim1.FBX",
]


func _initialize() -> void:
	for path in FBX_SCENES:
		_print_animation_info(path)
	quit()


func _print_animation_info(path: String) -> void:
	var packed_scene := ResourceLoader.load(path) as PackedScene
	if packed_scene == null:
		print("%s: failed to load" % path)
		return

	var instance := packed_scene.instantiate()
	var animation_player := _find_animation_player(instance)
	if animation_player == null:
		print("%s: no AnimationPlayer" % path)
		instance.free()
		return

	var names := animation_player.get_animation_list()
	print("%s: %d animation(s)" % [path.get_file(), names.size()])
	for animation_name in names:
		var animation := animation_player.get_animation(animation_name)
		if animation == null:
			continue
		print("  %s length=%.3f tracks=%d" % [animation_name, animation.length, animation.get_track_count()])

	instance.free()


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer

	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found

	return null
