extends SceneTree

const FighterControllerScript := preload("res://scripts/fighting/fighter_controller.gd")

const OUT_PATH := "res://tmp/character_angle_grid.png"
const CELL_SIZE := Vector2i(220, 300)
const COLUMNS := 6
const ANGLES := [0, 20, 40, 60, 90, 120, 140, 160, 180, 200, 220, 240, 270, 300, 320, 340]

const PROTOTYPE_VISUAL := {
	"base": "res://assets/fbx_model/Character_Base.FBX",
	"animations": {
		"idle": "res://assets/fbx_anim/Idle_Anim1.FBX",
		"punch": "res://assets/fbx_anim/Cross_Punch_Anim1.FBX",
		"kick": "res://assets/fbx_anim/Mma_Kick_Anim1.FBX",
		"jump": "res://assets/fbx_anim/Jump_Anim1.FBX",
		"run": "res://assets/fbx_anim/Fast_Run_Anim.FBX",
	},
	"textures": {
		"body": "res://assets/textures/1129/4.png",
		"face": "res://assets/textures/1129/5.png",
		"face_detail": "res://assets/textures/1129/5.png",
		"eye": "res://assets/textures/1129/3.png",
		"hair": "res://assets/textures/1129/1.png",
		"mayu": "res://assets/textures/1129/5.png",
		"tail": "res://assets/textures/1129/2.png",
	},
	"target_height": 2.05,
}

const DAWN_MAGE_VISUAL := {
	"base": "res://assets/characters/dawn_mage/anime_female_mage.glb",
	"animations": {
		"idle": "res://assets/characters/dawn_mage/anime_female_mage.glb",
		"punch": "res://assets/characters/dawn_mage/anime_female_mage.glb",
		"kick": "res://assets/characters/dawn_mage/anime_female_mage.glb",
		"jump": "res://assets/characters/dawn_mage/anime_female_mage.glb",
		"run": "res://assets/characters/dawn_mage/anime_female_mage.glb",
	},
	"textures": {
		"body": "res://assets/characters/dawn_mage/textures/body_color.png",
		"head": "res://assets/characters/dawn_mage/textures/head_color.png",
		"face": "res://assets/characters/dawn_mage/textures/head_color.png",
		"eye": "res://assets/characters/dawn_mage/textures/eyes_color.png",
		"eyes": "res://assets/characters/dawn_mage/textures/eyes_color.png",
		"hair": "res://assets/characters/dawn_mage/textures/hair_color.png",
		"outfit": "res://assets/characters/dawn_mage/textures/outfit_color.png",
	},
	"animation_names": {
		"idle": "combat_idle_01",
		"punch": "combat_attack_01",
		"kick": "combat_attack_02",
		"jump": "combat_spin_up_01",
		"run": "combat_run_01",
	},
	"target_height": 2.05,
}


func _initialize() -> void:
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp"))
	var proto := await _render_sheet("Prototype", PROTOTYPE_VISUAL)
	var dawn := await _render_sheet("Dawn Mage", DAWN_MAGE_VISUAL)
	var image := Image.create(maxi(proto.get_width(), dawn.get_width()), proto.get_height() + dawn.get_height(), false, Image.FORMAT_RGBA8)
	image.fill(Color(0.05, 0.055, 0.065, 1.0))
	image.blit_rect(proto, Rect2i(Vector2i.ZERO, proto.get_size()), Vector2i.ZERO)
	image.blit_rect(dawn, Rect2i(Vector2i.ZERO, dawn.get_size()), Vector2i(0, proto.get_height()))
	var error := image.save_png(OUT_PATH)
	print("Saved angle grid: %s error=%s" % [ProjectSettings.globalize_path(OUT_PATH), error])
	quit(0 if error == OK else 1)


func _render_sheet(label: String, visual: Dictionary) -> Image:
	var rows := int(ceil(float(ANGLES.size()) / float(COLUMNS)))
	var sheet := Image.create(CELL_SIZE.x * COLUMNS, CELL_SIZE.y * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.05, 0.055, 0.065, 1.0))
	for index in range(ANGLES.size()):
		var angle := float(ANGLES[index])
		var cell := await _render_character(visual, angle)
		var pos := Vector2i((index % COLUMNS) * CELL_SIZE.x, int(index / COLUMNS) * CELL_SIZE.y)
		sheet.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), pos)
		_mark_angle(sheet, pos, int(angle), label)
	return sheet


func _render_character(visual: Dictionary, angle: float) -> Image:
	var viewport := SubViewport.new()
	viewport.size = CELL_SIZE
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
	env.background_color = Color(0.18, 0.2, 0.22, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.88, 0.82)
	env.ambient_light_energy = 0.95
	environment.environment = env
	world.add_child(environment)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35.0, -25.0, 0.0)
	key.light_energy = 0.95
	world.add_child(key)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-8.0, 145.0, 0.0)
	fill.light_energy = 0.35
	world.add_child(fill)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 0.58, 5.2)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 3.15
	camera.current = true
	world.add_child(camera)

	var fighter := FighterControllerScript.new()
	fighter.show_debug_proxy = false
	fighter.use_fbx_visual = true
	fighter.visual_target_height = float(visual.get("target_height", 2.05))
	fighter.facing_right = true
	world.add_child(fighter)
	fighter.apply_character_resources(
		"res://data/moves/prototype",
		String(visual["base"]),
		(visual["animations"] as Dictionary).duplicate(true),
		(visual["textures"] as Dictionary).duplicate(true),
		{},
		(visual.get("animation_names", {}) as Dictionary).duplicate(true)
	)
	fighter.set_visual_facing_angles(angle, angle)
	fighter.position = Vector3(0.0, -0.68, 0.0)
	fighter._set_visual("idle")
	fighter._apply_visual_facing()

	for _i in range(6):
		await process_frame
	var image := viewport.get_texture().get_image()
	viewport.queue_free()
	return image


func _mark_angle(image: Image, pos: Vector2i, angle: int, label: String) -> void:
	var color := Color(0.95, 0.88, 0.18, 1.0)
	for x in range(pos.x + 8, pos.x + 76):
		for y in range(pos.y + 8, pos.y + 28):
			image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.62))
	var tick_count := int(angle / 20)
	for i in range(tick_count):
		var x := pos.x + 10 + i % 56
		var y := pos.y + 10 + int(i / 56) * 4
		if x < pos.x + CELL_SIZE.x and y < pos.y + CELL_SIZE.y:
			image.set_pixel(x, y, color)
