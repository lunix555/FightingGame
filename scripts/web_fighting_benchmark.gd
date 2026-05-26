extends Node3D

const MESH_LEVELS := [
	{"name": "LOW", "segments": 8, "rings": 3, "extra_parts": 0},
	{"name": "MID", "segments": 16, "rings": 6, "extra_parts": 8},
	{"name": "HIGH", "segments": 32, "rings": 12, "extra_parts": 24},
	{"name": "ULTRA", "segments": 48, "rings": 18, "extra_parts": 48},
]

const VFX_LEVELS := [0, 8, 24, 48]
const SFX_LEVELS := [0, 1, 4, 8]
const MAX_LATENCY_SAMPLES := 80

var mesh_level := 1
var vfx_level := 1
var sfx_level := 1
var auto_attack := true
var auto_timer := 0.0
var attack_flash := 0.0
var manual_attack_queued := false

var fighters: Array[Node3D] = []
var vfx_pool: Array[MeshInstance3D] = []
var sfx_players: Array[AudioStreamPlayer] = []
var fps_samples: Array[float] = []
var frame_ms_samples: Array[float] = []
var latency_samples: Array[float] = []
var pending_input_msec := -1

var fighter_root: Node3D
var vfx_root: Node3D
var hud_label: Label
var status_label: Label


func _ready() -> void:
	DisplayServer.window_set_title("Web 1v1 Fighting Benchmark")
	Engine.max_fps = 0
	_setup_world()
	_setup_hud()
	_rebuild_test()


func _process(delta: float) -> void:
	var time_sec := Time.get_ticks_msec() * 0.001
	if manual_attack_queued:
		manual_attack_queued = false
		_trigger_attack(true)
	_update_fighters(time_sec)
	_update_vfx(delta, time_sec)
	_record_sample(delta)
	_update_hud()

	if auto_attack:
		auto_timer += delta
		if auto_timer >= 0.45:
			auto_timer = 0.0
			_trigger_attack(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pending_input_msec = Time.get_ticks_msec()
		manual_attack_queued = true
	elif event.is_action_pressed("ui_right"):
		mesh_level = wrapi(mesh_level + 1, 0, MESH_LEVELS.size())
		_rebuild_test()
	elif event.is_action_pressed("ui_left"):
		mesh_level = wrapi(mesh_level - 1, 0, MESH_LEVELS.size())
		_rebuild_test()
	elif event.is_action_pressed("ui_up"):
		vfx_level = wrapi(vfx_level + 1, 0, VFX_LEVELS.size())
		_rebuild_vfx_pool()
	elif event.is_action_pressed("ui_down"):
		vfx_level = wrapi(vfx_level - 1, 0, VFX_LEVELS.size())
		_rebuild_vfx_pool()
	elif event.is_action_pressed("ui_page_up") or (event is InputEventKey and event.pressed and event.keycode == KEY_Q):
		sfx_level = wrapi(sfx_level + 1, 0, SFX_LEVELS.size())
		_rebuild_sfx_pool()
	elif event.is_action_pressed("ui_page_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_A):
		sfx_level = wrapi(sfx_level - 1, 0, SFX_LEVELS.size())
		_rebuild_sfx_pool()
	elif event.is_action_pressed("ui_cancel"):
		auto_attack = !auto_attack


func _setup_world() -> void:
	fighter_root = Node3D.new()
	fighter_root.name = "Fighters"
	add_child(fighter_root)

	vfx_root = Node3D.new()
	vfx_root.name = "VFX"
	add_child(vfx_root)

	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.055, 0.065, 0.075)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.74, 0.78)
	env.ambient_light_energy = 0.7
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, 35.0, 0.0)
	sun.light_energy = 1.35
	add_child(sun)

	var rim := OmniLight3D.new()
	rim.position = Vector3(0.0, 3.2, -2.4)
	rim.light_energy = 1.0
	rim.omni_range = 7.0
	add_child(rim)

	var camera := Camera3D.new()
	camera.name = "Camera"
	camera.position = Vector3(0.0, 2.7, 6.0)
	camera.rotation_degrees = Vector3(-17.0, 0.0, 0.0)
	camera.fov = 55.0
	camera.current = true
	add_child(camera)

	var arena_mesh := BoxMesh.new()
	arena_mesh.size = Vector3(7.2, 0.18, 3.8)
	var arena := MeshInstance3D.new()
	arena.name = "Arena"
	arena.mesh = arena_mesh
	arena.position.y = -0.1
	arena.material_override = _make_material(Color(0.17, 0.19, 0.2), 0.7, 0.15)
	add_child(arena)

	for x in [-3.6, 3.6]:
		var post := MeshInstance3D.new()
		var post_mesh := CylinderMesh.new()
		post_mesh.height = 1.5
		post_mesh.top_radius = 0.055
		post_mesh.bottom_radius = 0.055
		post_mesh.radial_segments = 8
		post.mesh = post_mesh
		post.position = Vector3(x, 0.7, -1.9)
		post.material_override = _make_material(Color(0.75, 0.08, 0.08), 0.4, 0.25)
		add_child(post)


func _setup_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(16.0, 16.0)
	panel.custom_minimum_size = Vector2(560.0, 188.0)
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
	hud_label.name = "Metrics"
	hud_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hud_label)

	status_label = Label.new()
	status_label.name = "Controls"
	status_label.text = "Enter attack/input latency | Left/Right mesh | Up/Down VFX | PgUp/PgDn SFX | Esc auto attack"
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status_label)


func _rebuild_test() -> void:
	for child in fighter_root.get_children():
		child.queue_free()
	fighters.clear()

	var left := _create_fighter(0, Color(0.14, 0.56, 0.95))
	left.position = Vector3(-0.85, 0.0, 0.0)
	left.rotation.y = -0.25
	fighter_root.add_child(left)
	fighters.append(left)

	var right := _create_fighter(1, Color(0.96, 0.26, 0.2))
	right.position = Vector3(0.85, 0.0, 0.0)
	right.rotation.y = PI + 0.25
	fighter_root.add_child(right)
	fighters.append(right)

	_rebuild_vfx_pool()
	_rebuild_sfx_pool()
	fps_samples.clear()
	frame_ms_samples.clear()
	latency_samples.clear()


func _create_fighter(index: int, body_color: Color) -> Node3D:
	var cfg: Dictionary = MESH_LEVELS[mesh_level]
	var segments := int(cfg["segments"])
	var rings := int(cfg["rings"])
	var extra_parts := int(cfg["extra_parts"])
	var dark_color := body_color.darkened(0.42)

	var root := CharacterBody3D.new()
	root.name = "Fighter_%d" % index
	root.set_meta("phase", float(index) * 1.7)

	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.22
	body_mesh.height = 1.04
	body_mesh.radial_segments = segments
	body_mesh.rings = rings
	var body := _mesh_part("Body", body_mesh, body_color)
	body.position.y = 0.92
	root.add_child(body)

	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.2
	head_mesh.radial_segments = segments
	head_mesh.rings = rings
	var head := _mesh_part("Head", head_mesh, Color(0.98, 0.76, 0.55))
	head.position.y = 1.58
	root.add_child(head)

	_add_limb(root, "Arm_L", Vector3(-0.34, 1.08, 0.0), -18.0, segments, rings, dark_color)
	_add_limb(root, "Arm_R", Vector3(0.34, 1.08, 0.0), 18.0, segments, rings, dark_color)
	_add_limb(root, "Leg_L", Vector3(-0.14, 0.35, 0.0), -5.0, segments, rings, dark_color)
	_add_limb(root, "Leg_R", Vector3(0.14, 0.35, 0.0), 5.0, segments, rings, dark_color)

	for i in range(extra_parts):
		var plate_mesh := BoxMesh.new()
		var scale := 0.055 + float(i % 5) * 0.006
		plate_mesh.size = Vector3(scale, 0.035, 0.018)
		var plate := _mesh_part("Detail_%02d" % i, plate_mesh, body_color.lightened(0.12))
		var angle: float = float(i) * TAU / float(maxi(1, extra_parts))
		plate.position = Vector3(cos(angle) * 0.24, 0.76 + float(i % 9) * 0.075, sin(angle) * 0.12)
		plate.rotation = Vector3(angle * 0.25, angle, 0.0)
		root.add_child(plate)

	var collider := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.25
	shape.height = 1.45
	collider.shape = shape
	collider.position.y = 0.82
	root.add_child(collider)

	var hitbox := Area3D.new()
	hitbox.name = "Hitbox"
	var hit_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.55, 0.42, 0.55)
	hit_shape.shape = box
	hit_shape.position = Vector3(0.0, 1.05, -0.34)
	hitbox.add_child(hit_shape)
	root.add_child(hitbox)

	return root


func _add_limb(root: Node3D, part_name: String, position: Vector3, z_degrees: float, segments: int, rings: int, color: Color) -> void:
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.065
	mesh.height = 0.62
	mesh.radial_segments = segments
	mesh.rings = rings
	var limb := _mesh_part(part_name, mesh, color)
	limb.position = position
	limb.rotation_degrees.z = z_degrees
	root.add_child(limb)


func _rebuild_vfx_pool() -> void:
	for child in vfx_root.get_children():
		child.queue_free()
	vfx_pool.clear()

	var count: int = int(VFX_LEVELS[vfx_level])
	for i in range(count):
		var mesh := SphereMesh.new()
		mesh.radius = 0.06
		mesh.radial_segments = 12
		mesh.rings = 6
		var spark := MeshInstance3D.new()
		spark.name = "Spark_%02d" % i
		spark.mesh = mesh
		spark.visible = false
		spark.material_override = _make_material(Color(1.0, 0.73, 0.16), 0.28, 0.0)
		spark.set_meta("life", 0.0)
		spark.set_meta("seed", float(i) * 0.61)
		vfx_root.add_child(spark)
		vfx_pool.append(spark)


func _rebuild_sfx_pool() -> void:
	for player in sfx_players:
		player.queue_free()
	sfx_players.clear()

	for i in range(SFX_LEVELS[sfx_level]):
		var player := AudioStreamPlayer.new()
		player.name = "HitSfx_%02d" % i
		player.stream = _make_hit_stream()
		player.set_meta("frequency", 380.0 + float(i) * 34.0)
		player.volume_db = -16.0
		add_child(player)
		sfx_players.append(player)


func _make_hit_stream() -> AudioStreamGenerator:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.08
	return stream


func _mesh_part(part_name: String, mesh: PrimitiveMesh, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.material_override = _make_material(color, 0.52, 0.35)
	return part


func _make_material(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material


func _trigger_attack(track_latency: bool) -> void:
	attack_flash = 0.12
	_spawn_vfx()
	_play_sfx()
	if track_latency and pending_input_msec >= 0:
		var latency := float(Time.get_ticks_msec() - pending_input_msec)
		latency_samples.append(latency)
		if latency_samples.size() > MAX_LATENCY_SAMPLES:
			latency_samples.pop_front()
		pending_input_msec = -1


func _spawn_vfx() -> void:
	if vfx_pool.is_empty():
		return

	for i in range(vfx_pool.size()):
		var spark := vfx_pool[i]
		var seed := float(spark.get_meta("seed"))
		spark.visible = true
		spark.position = Vector3(sin(seed) * 0.2, 1.18 + cos(seed * 2.0) * 0.2, -0.2 + cos(seed) * 0.18)
		spark.scale = Vector3.ONE * (0.8 + float(i % 5) * 0.12)
		spark.set_meta("life", 0.22 + float(i % 3) * 0.035)


func _play_sfx() -> void:
	for player in sfx_players:
		player.pitch_scale = randf_range(0.92, 1.08)
		player.play()
		var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
		if playback == null:
			continue
		var frequency := float(player.get_meta("frequency"))
		var mix_rate := 22050.0
		var frames := int(mix_rate * 0.045)
		for frame_index in range(frames):
			var t := float(frame_index) / mix_rate
			var envelope := 1.0 - float(frame_index) / float(frames)
			var sample := sin(TAU * frequency * t) * envelope * 0.42
			playback.push_frame(Vector2(sample, sample))


func _update_fighters(time_sec: float) -> void:
	attack_flash = max(0.0, attack_flash - get_process_delta_time())
	for i in range(fighters.size()):
		var fighter := fighters[i]
		var phase := float(fighter.get_meta("phase"))
		var punch: float = maxf(0.0, sin(time_sec * 9.0 + phase))
		var bob: float = sin(time_sec * 5.5 + phase) * 0.035
		var side: float = -1.0 if i == 0 else 1.0

		fighter.position.y = bob
		fighter.position.x = side * (0.85 + sin(time_sec * 2.4 + phase) * 0.08)

		var arm_r := fighter.get_node("Arm_R") as MeshInstance3D
		var arm_l := fighter.get_node("Arm_L") as MeshInstance3D
		var hitbox := fighter.get_node("Hitbox") as Area3D
		arm_r.rotation_degrees.x = -74.0 * punch
		arm_r.position.z = -0.28 * punch
		arm_l.rotation_degrees.x = -28.0 * max(0.0, sin(time_sec * 7.5 + phase + PI))
		hitbox.position.z = -0.34 - 0.34 * punch

		var body := fighter.get_node("Body") as MeshInstance3D
		body.scale = Vector3.ONE * (1.0 + attack_flash * 0.45)


func _update_vfx(delta: float, time_sec: float) -> void:
	for i in range(vfx_pool.size()):
		var spark := vfx_pool[i]
		var life := float(spark.get_meta("life")) - delta
		spark.set_meta("life", life)
		if life <= 0.0:
			spark.visible = false
			continue
		var seed := float(spark.get_meta("seed"))
		spark.position += Vector3(sin(time_sec * 9.0 + seed), cos(time_sec * 7.0 + seed), cos(time_sec * 5.0 + seed)) * delta * 0.65
		spark.scale = Vector3.ONE * max(0.05, life * 5.0)


func _record_sample(delta: float) -> void:
	fps_samples.append(Performance.get_monitor(Performance.TIME_FPS))
	frame_ms_samples.append(delta * 1000.0)

	if fps_samples.size() > 180:
		fps_samples.pop_front()
	if frame_ms_samples.size() > 180:
		frame_ms_samples.pop_front()


func _update_hud() -> void:
	var cfg: Dictionary = MESH_LEVELS[mesh_level]
	var avg_fps := _average(fps_samples)
	var low_fps := _minimum(fps_samples)
	var avg_ms := _average(frame_ms_samples)
	var avg_latency := _average(latency_samples)
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var objects := Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var nodes := Performance.get_monitor(Performance.OBJECT_NODE_COUNT)

	hud_label.text = "Web 1v1 Fighting Benchmark\nMesh: %s (%d seg, %d detail parts/char) | VFX sparks: %d | SFX voices: %d | Auto: %s\nFPS: %.1f avg / %.1f low | Frame: %.2f ms | Input feedback: %.1f ms avg\nDraw calls: %d | Render objects: %d | Nodes: %d" % [
		String(cfg["name"]),
		int(cfg["segments"]),
		int(cfg["extra_parts"]),
		VFX_LEVELS[vfx_level],
		SFX_LEVELS[sfx_level],
		"ON" if auto_attack else "OFF",
		avg_fps,
		low_fps,
		avg_ms,
		avg_latency,
		int(draw_calls),
		int(objects),
		int(nodes),
	]


func _average(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var total := 0.0
	for value in values:
		total += value
	return total / values.size()


func _minimum(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var result := values[0]
	for value in values:
		result = min(result, value)
	return result
