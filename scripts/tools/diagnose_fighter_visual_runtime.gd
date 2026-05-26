extends SceneTree

const FighterControllerScript := preload("res://scripts/fighting/fighter_controller.gd")


func _init() -> void:
	var fighter := FighterControllerScript.new() as FighterController
	root.add_child(fighter)
	fighter._set_visual("idle")
	_print_active_track(fighter, "idle")
	fighter._set_visual("kick")
	_print_active_track(fighter, "kick")
	fighter.queue_free()
	quit()


func _print_active_track(fighter: FighterController, key: String) -> void:
	var player := fighter.visual_animation_player
	if player == null:
		print("%s | no player" % key)
		return
	var animation_name := String(fighter.visual_cache.get(key, ""))
	var animation := player.get_animation(animation_name)
	if animation == null:
		print("%s | no animation" % key)
		return
	var first_path := "<none>"
	if animation.get_track_count() > 0:
		first_path = str(animation.track_get_path(0))
	print("%s | animation=%s tracks=%d first=%s" % [key, animation_name, animation.get_track_count(), first_path])
