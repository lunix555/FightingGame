extends SceneTree

const FighterControllerScript := preload("res://scripts/fighting/fighter_controller.gd")

const OUT_PATH := "res://tmp/action_library_check.png"
const CELL := Vector2i(320, 360)
const ANIMATION_NAME := "Unreal Take"

const CHARACTERS := [
	{
		"name": "Kashandella",
		"base": "res://assets/characters/kashandella_qishi/kashandella_qishi.glb",
		"prefix": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_",
		"textures": {
			"default": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_D.jpg",
			"albedo": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_D.jpg",
			"normal": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_N.jpg",
			"metallic": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_M.png",
			"roughness": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_Roughness.png",
			"orm": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_ORM.jpg",
		},
		"face_right": 140.0,
		"face_left": 40.0,
	},
	{
		"name": "Wela",
		"base": "res://assets/characters/wela_fashi/wela_fashi.glb",
		"prefix": "res://assets/characters/wela_fashi/animations/wela_fashi_",
		"textures": {
			"default": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_D.png",
			"albedo": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_D.png",
			"normal": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_N.png",
			"metallic": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_M.png",
			"roughness": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_roughness.png",
		},
		"face_right": 140.0,
		"face_left": 40.0,
	},
]

const KEYS := ["idle", "walk", "punch", "kick", "crouch", "hit", "crouch_hit", "knockdown", "crouch_knockdown", "getup"]


func _initialize() -> void:
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp"))
	var rows := CHARACTERS.size() * 2
	var image := Image.create(CELL.x * KEYS.size(), CELL.y * rows, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.04, 0.045, 0.052, 1.0))

	for row in range(CHARACTERS.size()):
		for direction_index in range(2):
			var facing_right := direction_index == 0
			var output_row := row * 2 + direction_index
			for column in range(KEYS.size()):
				var frame := await _render_cell(CHARACTERS[row], KEYS[column], facing_right)
				var origin := Vector2i(column * CELL.x, output_row * CELL.y)
				image.blit_rect(frame, Rect2i(Vector2i.ZERO, CELL), origin)
				_draw_cell_marker(image, origin, output_row, column)

	var error := image.save_png(OUT_PATH)
	print("Saved check image: %s error=%s" % [ProjectSettings.globalize_path(OUT_PATH), error])
	quit(0 if error == OK else 1)


func _render_cell(character: Dictionary, key: String, facing_right: bool) -> Image:
	var viewport := SubViewport.new()
	viewport.size = CELL
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var world := Node3D.new()
	viewport.add_child(world)

	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.15, 0.17, 0.2, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.88, 0.82)
	env.ambient_light_energy = 1.0
	environment.environment = env
	world.add_child(environment)

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-35.0, -25.0, 0.0)
	key_light.light_energy = 1.15
	world.add_child(key_light)

	var fill_light := DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(-8.0, 145.0, 0.0)
	fill_light.light_energy = 0.45
	world.add_child(fill_light)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 0.74, 5.2)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.25
	camera.current = true
	world.add_child(camera)

	var fighter := FighterControllerScript.new()
	fighter.show_debug_proxy = false
	fighter.use_fbx_visual = true
	fighter.visual_target_height = 2.85
	fighter.facing_right = facing_right
	world.add_child(fighter)
	var animations := _animations_for(character)
	var names := {}
	for animation_key in animations.keys():
		names[animation_key] = ANIMATION_NAME
	fighter.apply_character_resources(
		"res://data/moves/prototype",
		String(character["base"]),
		animations,
		character.get("textures", {}) as Dictionary,
		{},
		names
	)
	fighter.set_visual_facing_angles(float(character["face_right"]), float(character["face_left"]))
	fighter.position = Vector3(0.0, -1.2, 0.0)
	fighter._set_visual(key)
	fighter._apply_visual_facing()
	if fighter.visual_animation_player != null:
		var animation_name := String(fighter.visual_cache.get(key, ""))
		var animation := fighter.visual_animation_player.get_animation(animation_name)
		if animation != null and animation.length > 0.01:
			fighter.visual_animation_player.seek(animation.length * 0.5, true)
			fighter.visual_animation_player.advance(0.0)
	for _i in range(3):
		await process_frame
	var shot := viewport.get_texture().get_image()
	viewport.queue_free()
	return shot


func _animations_for(character: Dictionary) -> Dictionary:
	var prefix := String(character["prefix"])
	return {
		"idle": prefix + "idle.glb",
		"walk": prefix + "walk.glb",
		"run": prefix + "run.glb",
		"jump": prefix + "jump.glb",
		"punch": prefix + "punch.glb",
		"kick": prefix + "kick.glb",
		"crouch": prefix + "crouch.glb",
		"crouch_hit": prefix + "crouch_hit.glb",
		"hit": prefix + "hit.glb",
		"hurricane_kick": prefix + "hurricane_kick.glb",
		"knockdown": prefix + "knockdown.glb",
		"crouch_knockdown": prefix + "crouch_knockdown.glb",
		"getup": prefix + "getup.glb",
	}


func _draw_cell_marker(image: Image, origin: Vector2i, row: int, column: int) -> void:
	var color := Color(0.95, 0.8, 0.12, 1.0)
	for x in range(origin.x + 8, origin.x + 92):
		for y in range(origin.y + 8, origin.y + 30):
			image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.7))
	for i in range((row + 1) * 8 + (column + 1) * 4):
		var x := origin.x + 12 + i % 76
		var y := origin.y + 12 + int(i / 76) * 4
		if x < origin.x + CELL.x and y < origin.y + CELL.y:
			image.set_pixel(x, y, color)
