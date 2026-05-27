extends SceneTree

const OUT_PATH := "res://tmp/game_material_check.png"
const GAME_SCENE := preload("res://scenes/fighting_state_machine_test.tscn")
const KASHANDELLA_INDEX := 0
const WELA_INDEX := 1


func _initialize() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp"))

	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	game.set("p1_character_index", KASHANDELLA_INDEX)
	game.set("p2_character_index", WELA_INDEX)
	game.call("_load_battle_scene")
	game.call("_apply_selected_characters")
	game.call("_start_round")
	game.call("_start_fighting")

	for _i in range(20):
		await process_frame

	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png(OUT_PATH)
	print("Saved game material image: %s error=%s" % [ProjectSettings.globalize_path(OUT_PATH), error])
	quit(0 if error == OK else 1)
