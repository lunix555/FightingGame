extends Node3D
class_name FightingProjectile


var move: MoveDefinition
var owner_fighter: FighterController
var target_fighter: FighterController
var direction := 1.0
var speed := 3.2
var vertical_speed := 0.0
var gravity := 0.0
var radius := 0.24
var lifetime_frames := 120
var active := true

var _mesh_instance: MeshInstance3D
var _core_instance: MeshInstance3D
var _texture_instance: MeshInstance3D
var _trail_segments: Array[MeshInstance3D] = []
var _hit_consumed := false
var _visual_frame := 0
var _texture_base_scale := Vector3.ONE

const GROUND_CONTACT_MARGIN := 0.03
const TRAIL_TEXTURE_PATH := "res://assets/vfx/kenney_particle_full/flame_05.png"


func setup(projectile_move: MoveDefinition, owner: FighterController, target: FighterController, spawn_position: Vector3, travel_direction: float) -> void:
	move = projectile_move
	owner_fighter = owner
	target_fighter = target
	global_position = spawn_position
	direction = signf(travel_direction)
	if direction == 0.0:
		direction = 1.0
	speed = move.projectile_speed
	vertical_speed = move.projectile_vertical_speed
	gravity = move.projectile_gravity
	radius = move.projectile_radius
	lifetime_frames = move.projectile_lifetime_frames
	_build_visual()


func tick() -> bool:
	if not active:
		return false
	lifetime_frames -= 1
	_visual_frame += 1
	global_position.x += direction * speed / 60.0
	if move != null and move.projectile_ground_hug and owner_fighter != null and is_instance_valid(owner_fighter):
		global_position.y = owner_fighter.global_position.y + move.projectile_height
	else:
		vertical_speed -= gravity / 60.0
		global_position.y += vertical_speed / 60.0
	if _touches_ground():
		active = false
		return false
	if lifetime_frames <= 0 or global_position.x < -5.2 or global_position.x > 5.2 or global_position.y < -1.0 or global_position.y > 4.2:
		active = false
		return false
	if not _hit_consumed and _can_touch_target():
		_resolve_target_contact()
		_hit_consumed = true
		active = false
		return false
	_animate_visual()
	return true


func collides_with_projectile(other: FightingProjectile) -> bool:
	if other == null or not active or not other.active:
		return false
	if move != null and not move.projectile_cancelable:
		return false
	if other.move != null and not other.move.projectile_cancelable:
		return false
	if owner_fighter == other.owner_fighter or _same_owner_side(other):
		return false
	var combined_radius := radius + other.radius
	var dx := global_position.x - other.global_position.x
	var dy := global_position.y - other.global_position.y
	if dx * dx + dy * dy > combined_radius * combined_radius:
		return false

	var self_level := clash_level()
	var other_level := other.clash_level()
	if self_level == other_level:
		return true
	if self_level > other_level:
		other.expire()
	else:
		expire()
	return false


func expire() -> void:
	active = false
	queue_free()


func _same_owner_side(other: FightingProjectile) -> bool:
	if owner_fighter == null or other.owner_fighter == null:
		return false
	if not is_instance_valid(owner_fighter) or not is_instance_valid(other.owner_fighter):
		return false
	return owner_fighter.action_prefix == other.owner_fighter.action_prefix


func clash_level() -> int:
	if move == null:
		return 0
	return move.projectile_clash_level


func _impact_sound_key() -> String:
	if owner_fighter != null and owner_fighter.has_method("is_weila_fighter") and owner_fighter.is_weila_fighter():
		return "weila_projectile_hit"
	return "projectile_impact"


func _can_touch_target() -> bool:
	if target_fighter == null or not is_instance_valid(target_fighter):
		return false
	if target_fighter.is_invulnerable_to_hits():
		return false
	var hurt_rect := target_fighter._hurt_rect()
	var projectile_rect := Rect2(Vector2(global_position.x - radius, global_position.y - radius), Vector2(radius * 2.0, radius * 2.0))
	return projectile_rect.intersects(hurt_rect)


func _touches_ground() -> bool:
	if move == null or owner_fighter == null or not is_instance_valid(owner_fighter):
		return false
	if move.projectile_ground_hug or move.effect_style in ["ground_wave", "pillar"]:
		return false
	if vertical_speed >= 0.0 and move.projectile_vertical_speed >= 0.0:
		return false
	var ground_y := owner_fighter.global_position.y
	return global_position.y - radius <= ground_y + GROUND_CONTACT_MARGIN


func _resolve_target_contact() -> void:
	if owner_fighter != null and is_instance_valid(owner_fighter):
		owner_fighter.sound_requested.emit(_impact_sound_key())
	if target_fighter.can_block_move(move, owner_fighter):
		var chip := target_fighter.receive_block(move, owner_fighter)
		owner_fighter._gain_meter(move.meter_gain_on_block)
		target_fighter._gain_meter(move.meter_gain_on_block)
		owner_fighter.combat_event.emit("%s 防住了 %s，削血 %d" % [target_fighter.character_name, move.display_name, chip])
	else:
		var dealt := target_fighter.receive_unblocked_contact(move, owner_fighter)
		if dealt > 0:
			owner_fighter._gain_meter(move.meter_gain_on_hit)
			owner_fighter.hit_confirmed.emit(move)


func _build_visual() -> void:
	var style := move.effect_style if move != null else "projectile"
	match style:
		"fireball", "heavy_fireball", "magic_bolt", "air_drop":
			_build_textured_projectile_visual()
		"pillar":
			_build_pillar_visual()
			_build_texture_overlay()
		"slash":
			_build_slash_visual()
			_build_texture_overlay()
		"ground_wave":
			_build_ground_wave_visual()
			_build_texture_overlay()
		_:
			_build_orb_visual()
			_build_texture_overlay()


func _build_orb_visual() -> void:
	var orb_radius := maxf(radius * 1.25, 0.24)
	var mesh := SphereMesh.new()
	mesh.radius = orb_radius
	mesh.height = orb_radius * 2.0
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.mesh = mesh
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh_instance.material_override = _make_vfx_material(_effect_tint(), 1.55)
	add_child(_mesh_instance)

	var core_mesh := SphereMesh.new()
	core_mesh.radius = orb_radius * 0.52
	core_mesh.height = orb_radius * 1.04
	_core_instance = MeshInstance3D.new()
	_core_instance.mesh = core_mesh
	_core_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_core_instance.material_override = _make_vfx_material(Color(1.0, 0.96, 0.76, 0.62), 1.85)
	add_child(_core_instance)

	_build_orb_trail(orb_radius)


func _build_orb_trail(orb_radius: float) -> void:
	_trail_segments.clear()
	var tint := _effect_tint()
	for i in range(5):
		var t := float(i + 1) / 5.0
		var trail_mesh := SphereMesh.new()
		trail_mesh.radius = orb_radius * lerpf(0.42, 0.16, t)
		trail_mesh.height = trail_mesh.radius * 2.0
		var trail := MeshInstance3D.new()
		trail.mesh = trail_mesh
		trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		trail.position = Vector3(-direction * orb_radius * (0.75 + t * 2.2), 0.0, 0.02 + t * 0.01)
		trail.material_override = _make_vfx_material(Color(tint.r, tint.g, tint.b, tint.a * lerpf(0.42, 0.14, t)), 1.15)
		add_child(trail)
		_trail_segments.append(trail)


func _build_textured_projectile_visual() -> void:
	_build_texture_overlay()
	if _texture_instance == null:
		_build_orb_visual()
		return

	var core_mesh := SphereMesh.new()
	core_mesh.radius = maxf(radius * 0.46, 0.11)
	core_mesh.height = core_mesh.radius * 1.25
	_core_instance = MeshInstance3D.new()
	_core_instance.mesh = core_mesh
	_core_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_core_instance.scale = Vector3(1.35, 0.78, 0.55)
	_core_instance.material_override = _make_vfx_material(_core_tint(), _texture_overlay_glow() * 0.72)
	add_child(_core_instance)

	_texture_instance.rotation.z = _projectile_texture_angle()
	_texture_base_scale = _texture_overlay_scale()
	_texture_instance.scale = _texture_base_scale
	_build_texture_trail()


func _build_texture_trail() -> void:
	_trail_segments.clear()
	var texture := _load_effect_texture(TRAIL_TEXTURE_PATH)
	if texture == null and move != null:
		texture = _load_effect_texture(move.effect_texture_path)
	if texture == null:
		return

	var tint := _effect_tint()
	var count := 5 if move != null and move.effect_style == "heavy_fireball" else 4
	for i in range(count):
		var t := float(i + 1) / float(count)
		var quad := QuadMesh.new()
		quad.size = _texture_overlay_size() * lerpf(0.72, 0.26, t)
		var trail := MeshInstance3D.new()
		trail.mesh = quad
		trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		trail.material_override = _make_texture_vfx_material(texture, Color(tint.r, tint.g, tint.b, tint.a * lerpf(0.5, 0.16, t)), 1.25)
		trail.position = Vector3(-direction * radius * (1.05 + t * 2.8), -move.projectile_vertical_speed * 0.018 * t if move != null else 0.0, 0.04 + t * 0.01)
		trail.rotation.z = _projectile_texture_angle()
		trail.scale = Vector3.ONE * lerpf(1.0, 0.55, t)
		add_child(trail)
		_trail_segments.append(trail)


func _build_ground_wave_visual() -> void:
	var material := _make_vfx_material(_effect_tint(), 1.35)
	for i in range(4):
		var mesh := SphereMesh.new()
		mesh.radius = maxf(radius * 0.9, 0.18) * (1.0 - i * 0.08)
		mesh.height = mesh.radius * 2.0
		var wave := MeshInstance3D.new()
		wave.mesh = mesh
		wave.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		wave.material_override = material
		wave.scale = Vector3(1.85 - i * 0.22, 0.28 + i * 0.04, 0.18)
		wave.position = Vector3(-direction * i * radius * 0.95, 0.0, 0.02 + i * 0.01)
		add_child(wave)
		if i == 0:
			_mesh_instance = wave


func _build_pillar_visual() -> void:
	var material := _make_vfx_material(_effect_tint(), 1.42)
	for i in range(5):
		var crystal := CylinderMesh.new()
		crystal.bottom_radius = radius * lerpf(0.42, 0.2, float(i) / 4.0)
		crystal.top_radius = radius * 0.04
		crystal.height = maxf(1.05, radius * 5.0) * lerpf(1.0, 0.58, absf(float(i) - 2.0) / 2.0)
		crystal.radial_segments = 5
		var spike := MeshInstance3D.new()
		spike.mesh = crystal
		spike.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		spike.material_override = material
		spike.position = Vector3((float(i) - 2.0) * radius * 0.45, crystal.height * 0.42, 0.0)
		spike.rotation.z = deg_to_rad((float(i) - 2.0) * -8.0)
		add_child(spike)
		if i == 2:
			_mesh_instance = spike


func _build_slash_visual() -> void:
	var material := _make_vfx_material(_effect_tint(), 1.55)
	var count := 7
	for i in range(count):
		var t := float(i) / float(count - 1)
		var slash_mesh := BoxMesh.new()
		slash_mesh.size = Vector3(radius * 0.34, radius * 2.55 * (1.0 - absf(t - 0.5) * 0.55), 0.045)
		var part := MeshInstance3D.new()
		part.mesh = slash_mesh
		part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		part.material_override = material
		var arc := (t - 0.5) * 1.35
		part.position = Vector3(direction * arc * radius * 2.2, sin(t * PI) * radius * 1.1, 0.0)
		part.rotation.z = direction * deg_to_rad(54.0 - t * 108.0)
		add_child(part)
		if i == int(count / 2):
			_mesh_instance = part


func _animate_visual() -> void:
	var pulse := 1.0 + sin(float(_visual_frame) * 0.34) * 0.08
	if _mesh_instance != null:
		_mesh_instance.rotation.y += direction * 0.18
		if move == null or move.effect_style == "projectile":
			_mesh_instance.scale = Vector3.ONE * pulse
	if _texture_instance != null:
		if move != null and move.effect_style in ["fireball", "heavy_fireball", "magic_bolt", "air_drop"]:
			_texture_instance.rotation.z = _projectile_texture_angle() + sin(float(_visual_frame) * 0.28) * 0.05
			_texture_instance.scale = _texture_base_scale * (0.98 + sin(float(_visual_frame) * 0.42) * 0.07)
		else:
			_texture_instance.rotation.z += direction * 0.04
			_texture_instance.scale = _texture_base_scale * (0.94 + sin(float(_visual_frame) * 0.42) * 0.08)
	if _core_instance != null:
		_core_instance.rotation.y -= direction * 0.28
		_core_instance.scale = Vector3.ONE * (1.0 + sin(float(_visual_frame) * 0.51) * 0.12)
	for i in range(_trail_segments.size()):
		var trail := _trail_segments[i]
		if trail == null:
			continue
		var t := float(i + 1) / float(maxi(_trail_segments.size(), 1))
		trail.scale = Vector3.ONE * (0.82 + sin(float(_visual_frame) * 0.4 + t * 4.0) * 0.12)


func _make_vfx_material(color: Color, glow_strength: float) -> StandardMaterial3D:
	var tint := color
	if tint.a <= 0.0:
		tint = Color(0.35, 0.88, 1.0, 0.78)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	material.albedo_color = Color(tint.r * tint.a, tint.g * tint.a, tint.b * tint.a, tint.a)
	material.emission_enabled = true
	material.emission = Color(tint.r, tint.g, tint.b)
	material.emission_energy_multiplier = glow_strength
	return material


func _build_texture_overlay() -> void:
	if move == null or move.effect_texture_path.is_empty():
		return
	var texture := _load_effect_texture(move.effect_texture_path)
	if texture == null:
		return
	_texture_instance = _make_textured_quad("TextureOverlay", texture, _texture_overlay_size(), _effect_tint(), _texture_overlay_glow())
	_texture_instance.position = _texture_overlay_position()
	_texture_base_scale = _texture_overlay_scale()
	_texture_instance.scale = _texture_base_scale
	add_child(_texture_instance)


func _load_effect_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	return ResourceLoader.load(path) as Texture2D


func _make_textured_quad(node_name: String, texture: Texture2D, size: Vector2, color: Color, glow_strength: float) -> MeshInstance3D:
	var quad := QuadMesh.new()
	quad.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = quad
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.material_override = _make_texture_vfx_material(texture, color, glow_strength)
	return instance


func _make_texture_vfx_material(texture: Texture2D, color: Color, glow_strength: float) -> StandardMaterial3D:
	var tint := color
	if tint.a <= 0.0:
		tint = Color(1.0, 1.0, 1.0, 0.82)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	material.albedo_texture = texture
	material.albedo_color = Color(tint.r, tint.g, tint.b, tint.a)
	material.emission_enabled = true
	material.emission_texture = texture
	material.emission = Color(tint.r, tint.g, tint.b)
	material.emission_energy_multiplier = glow_strength
	return material


func _texture_overlay_size() -> Vector2:
	if move == null:
		return Vector2(radius * 2.6, radius * 2.6)
	match move.effect_style:
		"fireball":
			return Vector2(maxf(radius * 4.4, 0.78), maxf(radius * 2.55, 0.48))
		"heavy_fireball":
			return Vector2(maxf(radius * 5.1, 1.08), maxf(radius * 3.05, 0.64))
		"magic_bolt":
			return Vector2(maxf(radius * 5.4, 1.08), maxf(radius * 1.45, 0.28))
		"air_drop":
			return Vector2(maxf(radius * 3.2, 0.68), maxf(radius * 3.2, 0.68))
		"pillar":
			return Vector2(maxf(radius * 2.1, 0.7), maxf(radius * 5.0, 1.45))
		"slash":
			return Vector2(maxf(radius * 4.2, 1.0), maxf(radius * 2.4, 0.7))
		"ground_wave":
			return Vector2(maxf(radius * 4.6, 1.0), maxf(radius * 1.5, 0.34))
	return Vector2(maxf(radius * 3.2, 0.58), maxf(radius * 3.2, 0.58))


func _texture_overlay_scale() -> Vector3:
	if move == null:
		return Vector3.ONE
	match move.effect_style:
		"fireball":
			return Vector3(move.effect_scale.x, move.effect_scale.y, 1.0)
		"heavy_fireball":
			return Vector3(move.effect_scale.x, move.effect_scale.y, 1.0)
		"magic_bolt":
			return Vector3(move.effect_scale.x, move.effect_scale.y, 1.0)
		"air_drop":
			return Vector3(move.effect_scale.x, move.effect_scale.y, 1.0)
		"ground_wave":
			return Vector3(1.25, 0.7, 1.0)
		"slash":
			return Vector3(1.15, 1.05, 1.0)
		"pillar":
			return Vector3(1.0, 1.05, 1.0)
	return Vector3.ONE * maxf(move.effect_scale.x, 1.0)


func _texture_overlay_position() -> Vector3:
	if move == null:
		return Vector3(0.0, 0.0, -0.035)
	match move.effect_style:
		"fireball", "heavy_fireball", "magic_bolt", "air_drop":
			return Vector3(0.0, 0.0, -0.045)
		"pillar":
			return Vector3(0.0, maxf(radius * 1.35, 0.35), -0.035)
		"ground_wave":
			return Vector3(0.0, -radius * 0.12, -0.035)
	return Vector3(0.0, 0.0, -0.035)


func _texture_overlay_glow() -> float:
	if move == null:
		return 1.8
	match move.effect_style:
		"heavy_fireball":
			return 2.35
		"fireball":
			return 2.0
		"magic_bolt":
			return 2.15
		"air_drop":
			return 2.05
		"pillar":
			return 1.55
		"slash":
			return 1.85
		"ground_wave":
			return 1.45
	return 1.95


func _projectile_texture_angle() -> float:
	if move == null:
		return 0.0
	var motion_angle := atan2(move.projectile_vertical_speed, direction * maxf(move.projectile_speed, 0.01))
	if move.effect_style in ["fireball", "heavy_fireball", "air_drop"]:
		return motion_angle - PI * 0.5
	return motion_angle


func _core_tint() -> Color:
	var tint := _effect_tint()
	return Color(minf(tint.r + 0.28, 1.0), minf(tint.g + 0.28, 1.0), minf(tint.b + 0.28, 1.0), minf(tint.a + 0.12, 0.92))


func _effect_tint() -> Color:
	if move != null and move.effect_color.a > 0.0:
		return move.effect_color
	return Color.WHITE
