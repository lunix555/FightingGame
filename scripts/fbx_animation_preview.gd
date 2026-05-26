extends Node3D

const FBX_SCENES := [
	"res://assets/fbx_anim/Idle_Anim1.FBX",
	"res://assets/fbx_anim/Cross_Punch_Anim1.FBX",
	"res://assets/fbx_anim/Mma_Kick_Anim1.FBX",
	"res://assets/fbx_anim/Jump_Anim1.FBX",
	"res://assets/fbx_anim/Fast_Run_Anim.FBX",
	"res://assets/fbx_anim/Fast_Run__1__Anim1.FBX",
]

const TEXTURE_SETS := {
	"ue_baked": {
		"body": "res://assets/textures/1129/4.png",
		"face": "res://assets/textures/1129/5.png",
		"face_detail": "res://assets/textures/1129/5.png",
		"eye": "res://assets/textures/1129/3.png",
		"hair": "res://assets/textures/1129/1.png",
		"mayu": "res://assets/textures/1129/5.png",
		"tail": "res://assets/textures/1129/2.png",
	},
	"ue_soft": {
		"body": "res://assets/textures/1129/tex_bdy1129_01_diff.png",
		"face": "res://assets/textures/1129/tex_chr1129_01_face_diff.png",
		"face_detail": "res://assets/textures/1129/tex_chr1129_01_face_diff.png",
		"eye": "res://assets/textures/1129/tex_chr1129_01_eye0_all.png",
		"hair": "res://assets/textures/1129/tex_chr1129_01_hair_diff.png",
		"tail": "res://assets/textures/1129/tex_tail0001_00_1129_diff.png",
	},
	"fdggg": {
		"MI_mtl_bdy1129_01": "res://assets/materials/fdggg/Textures/MI_mtl_bdy1129_01_EmissiveColor.exr",
		"MI_mtl_chr1129_01_eye": "res://assets/materials/fdggg/Textures/MI_mtl_chr1129_01_eye_EmissiveColor.exr",
		"MI_mtl_chr1129_01_face": "res://assets/materials/fdggg/Textures/MI_mtl_chr1129_01_face_EmissiveColor.exr",
		"MI_mtl_chr1129_01_face_001": "res://assets/materials/fdggg/Textures/MI_mtl_chr1129_01_face_001_EmissiveColor.exr",
		"MI_mtl_chr1129_01_hair": "res://assets/materials/fdggg/Textures/MI_mtl_chr1129_01_hair_EmissiveColor.exr",
		"MI_mtl_chr1129_01_mayu": "res://assets/materials/fdggg/Textures/MI_mtl_chr1129_01_mayu_EmissiveColor.exr",
		"MI_mtl_tail0001_00": "res://assets/materials/fdggg/Textures/MI_mtl_tail0001_00_EmissiveColor.exr",
	},
	"base": {
		"body": "res://assets/textures/1129/tex_bdy1129_01_base.png",
		"face": "res://assets/textures/1129/tex_chr1129_01_face_base.png",
		"eye": "res://assets/textures/1129/tex_chr1129_01_eye0_all.png",
		"hair": "res://assets/textures/1129/tex_chr1129_01_hair_base.png",
		"tail": "res://assets/textures/1129/tex_tail0001_00_0000_base.png",
	},
	"diff": {
		"body": "res://assets/textures/1129/tex_bdy1129_01_diff.png",
		"face": "res://assets/textures/1129/tex_chr1129_01_face_diff.png",
		"eye": "res://assets/textures/1129/tex_chr1129_01_eye0.png",
		"hair": "res://assets/textures/1129/tex_chr1129_01_hair_diff.png",
		"tail": "res://assets/textures/1129/tex_tail0001_00_1129_diff.png",
	},
}

var current_index := 0
var current_model: Node3D
var current_animation_player: AnimationPlayer
var hud_label: Label
var log_label: Label
var camera_pivot: Node3D
var load_log := ""
var texture_mode := "ue_baked"
var fdggg_emission_enabled := false


func _ready() -> void:
	DisplayServer.window_set_title("FBX Animation Preview")
	_setup_world()
	_setup_hud()
	_load_model(0)


func _process(delta: float) -> void:
	if camera_pivot != null:
		camera_pivot.rotation.y += delta * 0.2
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	var key_event := event as InputEventKey
	if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_6:
		_load_model(key_event.keycode - KEY_1)
	elif key_event.keycode == KEY_LEFT:
		_load_model(wrapi(current_index - 1, 0, FBX_SCENES.size()))
	elif key_event.keycode == KEY_RIGHT:
		_load_model(wrapi(current_index + 1, 0, FBX_SCENES.size()))
	elif key_event.keycode == KEY_SPACE and current_animation_player != null:
		if current_animation_player.is_playing():
			current_animation_player.pause()
		else:
			_play_first_animation()
	elif key_event.keycode == KEY_B:
		texture_mode = "base"
		_apply_textures_to_model()
	elif key_event.keycode == KEY_D:
		texture_mode = "diff"
		_apply_textures_to_model()
	elif key_event.keycode == KEY_F:
		texture_mode = "fdggg"
		_apply_textures_to_model()
	elif key_event.keycode == KEY_G:
		texture_mode = "ue_baked"
		_apply_textures_to_model()
	elif key_event.keycode == KEY_H:
		texture_mode = "ue_soft"
		_apply_textures_to_model()
	elif key_event.keycode == KEY_E:
		fdggg_emission_enabled = !fdggg_emission_enabled
		_apply_textures_to_model()


func _setup_world() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.62, 0.64, 0.68)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.9, 0.92, 0.95)
	env.ambient_light_energy = 0.52
	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, 35.0, 0.0)
	sun.light_energy = 0.42
	add_child(sun)

	var fill := OmniLight3D.new()
	fill.position = Vector3(0.0, 2.8, 2.8)
	fill.light_energy = 0.18
	fill.omni_range = 7.0
	add_child(fill)

	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 1.65, 4.5)
	camera.rotation_degrees = Vector3(-8.0, 0.0, 0.0)
	camera.fov = 50.0
	camera.current = true
	camera_pivot.add_child(camera)

	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(6.0, 0.08, 6.0)
	var floor := MeshInstance3D.new()
	floor.name = "PreviewFloor"
	floor.mesh = floor_mesh
	floor.position.y = -0.04
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.52, 0.54, 0.58)
	floor_material.roughness = 0.8
	floor.material_override = floor_material
	add_child(floor)


func _setup_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(16.0, 16.0)
	panel.custom_minimum_size = Vector2(660.0, 160.0)
	layer.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	hud_label = Label.new()
	hud_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hud_label)

	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(log_label)


func _load_model(index: int) -> void:
	current_index = clampi(index, 0, FBX_SCENES.size() - 1)

	if current_model != null:
		current_model.queue_free()
		current_model = null
	current_animation_player = null

	var path := String(FBX_SCENES[current_index])
	var packed_scene := ResourceLoader.load(path) as PackedScene
	if packed_scene == null:
		load_log = "Failed to load PackedScene: %s" % path
		return

	current_model = packed_scene.instantiate() as Node3D
	if current_model == null:
		load_log = "Loaded resource is not a Node3D scene: %s" % path
		return

	current_model.name = "PreviewModel"
	add_child(current_model)
	_normalize_model(current_model)
	_apply_textures_to_model()

	current_animation_player = _find_animation_player(current_model)
	if current_animation_player == null:
		load_log = "Loaded %s, but no AnimationPlayer was found." % path.get_file()
		return

	_play_first_animation()


func _play_first_animation() -> void:
	if current_animation_player == null:
		return

	var animation_names := current_animation_player.get_animation_list()
	if animation_names.is_empty():
		load_log = "AnimationPlayer found, but it has no animations."
		return

	var animation_name := String(animation_names[0])
	var animation := current_animation_player.get_animation(animation_name)
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR
	current_animation_player.play(animation_name)
	load_log = "Playing %s / animation: %s" % [String(FBX_SCENES[current_index]).get_file(), animation_name]


func _apply_textures_to_model() -> void:
	if current_model == null:
		return

	var applied := 0
	var missing := 0
	var stack: Array[Node] = [current_model]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D:
			var mesh_instance := node as MeshInstance3D
			var mesh := mesh_instance.mesh
			if mesh != null:
				for surface_index in range(mesh.get_surface_count()):
					var source_material := mesh.surface_get_material(surface_index)
					if source_material == null:
						source_material = mesh_instance.get_surface_override_material(surface_index)
					var material_name := "" if source_material == null else source_material.resource_name
					var texture_path := _texture_for_material(material_name)
					if texture_path.is_empty():
						missing += 1
						continue
					var texture := ResourceLoader.load(texture_path) as Texture2D
					if texture == null:
						missing += 1
						continue
					mesh_instance.set_surface_override_material(surface_index, _make_preview_material(texture, material_name))
					applied += 1
		for child in node.get_children():
			stack.append(child)

	load_log = "Applied %s texture set: %d surfaces, %d unmatched" % [texture_mode, applied, missing]


func _texture_for_material(material_name: String) -> String:
	var texture_set: Dictionary = TEXTURE_SETS[texture_mode]

	if texture_mode == "fdggg":
		return String(texture_set.get(material_name, ""))

	var lower_name := material_name.to_lower()

	if texture_mode == "ue_baked" or texture_mode == "ue_soft":
		if lower_name.contains("bdy"):
			return String(texture_set["body"])
		if lower_name.contains("eye"):
			return String(texture_set["eye"])
		if lower_name.contains("hair"):
			return String(texture_set["hair"])
		if lower_name.contains("tail"):
			return String(texture_set["tail"])
		if lower_name.contains("face_001"):
			return String(texture_set["face_detail"])
		if lower_name.contains("mayu"):
			return String(texture_set.get("mayu", texture_set["face"]))
		if lower_name.contains("face") or lower_name.contains("mayu"):
			return String(texture_set["face"])
		return ""

	if lower_name.contains("bdy"):
		return String(texture_set["body"])
	if lower_name.contains("eye"):
		return String(texture_set["eye"])
	if lower_name.contains("hair"):
		return String(texture_set["hair"])
	if lower_name.contains("tail"):
		return String(texture_set["tail"])
	if lower_name.contains("face") or lower_name.contains("mayu"):
		return String(texture_set["face"])

	return ""


func _make_preview_material(texture: Texture2D, material_name: String) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = "preview_%s_%s" % [texture_mode, material_name]
	material.albedo_color = _tint_for_material(material_name)
	material.albedo_texture = texture
	material.roughness = 0.9 if texture_mode == "ue_baked" or texture_mode == "ue_soft" else 0.72
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if texture_mode == "ue_baked":
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if texture_mode == "fdggg":
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		material.emission_enabled = fdggg_emission_enabled
		if fdggg_emission_enabled:
			material.emission = Color.WHITE
			material.emission_texture = texture
			material.emission_energy_multiplier = 0.18
	else:
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED if texture_mode == "ue_baked" or texture_mode == "ue_soft" else BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _tint_for_material(material_name: String) -> Color:
	if texture_mode == "ue_baked":
		return Color.WHITE
	if texture_mode != "ue_soft":
		return Color.WHITE

	var lower_name := material_name.to_lower()
	if lower_name.contains("bdy"):
		return Color(1.05, 1.05, 1.08, 1.0)
	if lower_name.contains("face") or lower_name.contains("mayu"):
		return Color(1.08, 1.04, 1.02, 1.0)
	if lower_name.contains("hair"):
		return Color(1.02, 0.95, 0.9, 1.0)
	if lower_name.contains("eye"):
		return Color(0.95, 1.02, 1.08, 1.0)
	return Color(1.0, 1.0, 1.0, 1.0)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer

	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found

	return null


func _normalize_model(model: Node3D) -> void:
	model.position = Vector3.ZERO
	model.rotation = Vector3.ZERO

	var bounds := _calculate_bounds(model)
	if bounds.size == Vector3.ZERO:
		model.scale = Vector3.ONE
		return

	var height := bounds.size.y
	if height <= 0.001:
		model.scale = Vector3.ONE
		return

	var target_height := 1.85
	var scale_factor := target_height / height
	model.scale = Vector3.ONE * scale_factor
	model.position.y = -bounds.position.y * scale_factor


func _calculate_bounds(root: Node) -> AABB:
	var has_bounds := false
	var combined := AABB()
	var stack: Array[Node] = [root]

	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D:
			var mesh_instance := node as MeshInstance3D
			var mesh_aabb := mesh_instance.get_aabb()
			var world_aabb := mesh_instance.global_transform * mesh_aabb
			if not has_bounds:
				combined = world_aabb
				has_bounds = true
			else:
				combined = combined.merge(world_aabb)

		for child in node.get_children():
			stack.append(child)

	return combined if has_bounds else AABB()


func _update_hud() -> void:
	if hud_label == null:
		return

	var fps := Performance.get_monitor(Performance.TIME_FPS)
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var objects := Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var animation_info := "none"

	if current_animation_player != null:
		animation_info = "%s playing=%s" % [
			current_animation_player.current_animation,
			"yes" if current_animation_player.is_playing() else "no",
		]

	hud_label.text = "FBX Animation Preview | FPS %.1f | Draw calls %d | Render objects %d\n1-6 switch FBX | Left/Right previous/next | Space pause/play | G UE-baked / H old-soft / F FDGGG / E emission / B base / D diff\nCurrent: %s | Material: %s | Emission: %s | Animation: %s" % [
		fps,
		int(draw_calls),
		int(objects),
		String(FBX_SCENES[current_index]).get_file(),
		texture_mode,
		"on" if fdggg_emission_enabled else "off",
		animation_info,
	]
	log_label.text = load_log
