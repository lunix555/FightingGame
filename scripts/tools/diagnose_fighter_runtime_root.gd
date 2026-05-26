extends SceneTree

const FighterControllerScript := preload("res://scripts/fighting/fighter_controller.gd")


func _init() -> void:
	var fighter := FighterControllerScript.new() as FighterController
	root.add_child(fighter)
	fighter._set_visual("idle")
	_print_root_key(fighter, "idle")
	fighter._set_visual("kick")
	_print_root_key(fighter, "kick")
	fighter.queue_free()
	quit()


func _print_root_key(fighter: FighterController, key: String) -> void:
	var player := fighter.visual_animation_player
	if player == null:
		print("%s | no player" % key)
		return
	var animation_name := String(fighter.visual_cache.get(key, ""))
	var animation := player.get_animation(animation_name)
	if animation == null:
		print("%s | no animation" % key)
		return
	for track_index in range(animation.get_track_count()):
		if str(animation.track_get_path(track_index)).ends_with(":root") and animation.track_get_type(track_index) == Animation.TYPE_ROTATION_3D:
			var value: Variant = animation.track_get_key_value(track_index, 0)
			if value is Quaternion:
				print("%s | root euler=%s" % [key, Basis(value as Quaternion).get_euler() * 180.0 / PI])
			return
	print("%s | no root rotation" % key)
