extends RefCounted
class_name FakeMoveDatabase


static func build_default_moves() -> Array[MoveDefinition]:
	var moves: Array[MoveDefinition] = [
		_make("5J", "Light Punch", MoveDefinition.MoveType.NORMAL, "", "J", 2, 3, 13, 80, "anim_light_punch", "hit_spark_s", "hit_light"),
		_make("5K", "Light Kick", MoveDefinition.MoveType.NORMAL, "", "K", 3, 4, 13, 90, "anim_light_kick", "hit_spark_s", "hit_light"),
		_make("5U", "Heavy Punch", MoveDefinition.MoveType.NORMAL, "", "U", 8, 5, 22, 150, "anim_heavy_punch", "hit_spark_m", "hit_heavy", 1.15, 1.0, MoveDefinition.AttackLevel.MID, 0, true),
		_make("5I", "Heavy Kick", MoveDefinition.MoveType.NORMAL, "", "I", 10, 6, 24, 170, "anim_heavy_kick", "hit_spark_m", "hit_heavy", 1.15, 1.0, MoveDefinition.AttackLevel.MID, 0, true),
		_make("2K", "Crouch Light Kick", MoveDefinition.MoveType.NORMAL, "2", "K", 6, 4, 15, 85, "anim_crouch_kick", "hit_spark_s", "hit_light", 1.15, 1.0, MoveDefinition.AttackLevel.LOW),
		_make("2I", "Crouch Heavy Kick", MoveDefinition.MoveType.NORMAL, "2", "I", 9, 5, 25, 160, "anim_crouch_kick", "hit_spark_m", "hit_heavy", 1.25, 0.75, MoveDefinition.AttackLevel.LOW, 0, true),
		_make("6U", "Forward Heavy", MoveDefinition.MoveType.COMMAND_NORMAL, "6", "U", 5, 8, 32, 180, "anim_forward_heavy", "hit_spark_l", "hit_heavy", 1.15, 1.0, MoveDefinition.AttackLevel.MID, 0, true),
		_make("5O", "Dust / Launcher", MoveDefinition.MoveType.COMMAND_NORMAL, "", "O", 12, 5, 24, 140, "anim_dust", "hit_spark_l", "hit_heavy", 1.15, 1.0, MoveDefinition.AttackLevel.MID, 0, true),
		_make_projectile("236J", "轻波动拳", "236", "J", 8, 3, 24, 95, 5.1, 0.22),
		_make_projectile("236U", "重波动拳", "236", "U", 12, 3, 30, 155, 3.35, 0.28),
		_make_projectile("623J", "斜上波动拳", "623", "J", 10, 3, 28, 110, 3.7, 0.23, 3.15, 0.0, false, false, false, MoveDefinition.AttackLevel.HIGH, 0.94),
		_make_projectile("236I", "斜下波动拳", "236", "I", 11, 3, 28, 120, 3.75, 0.24, -2.35, 0.0, false, false, false, MoveDefinition.AttackLevel.LOW, 1.05),
		_make_projectile("214J", "空中下波动拳", "214", "J", 8, 3, 24, 115, 3.0, 0.23, -3.45, 3.0, false, true, false, MoveDefinition.AttackLevel.MID, 0.85),
		_make_projectile("236O", "地波", "236", "O", 14, 3, 30, 130, 4.25, 0.26, 0.0, 0.0, true, false, true, MoveDefinition.AttackLevel.MID, 0.2),
		_make("236236J", "普通必杀", MoveDefinition.MoveType.SPECIAL, "236236", "J", 8, 8, 22, 165, "anim_fireball", "muzzle_flash", "special_1", 3.0, 1.0, MoveDefinition.AttackLevel.MID, 100),
		_make("236K", "旋风腿", MoveDefinition.MoveType.SPECIAL, "236", "K", 10, 8, 24, 190, "anim_advancing_kick", "hit_spark_m", "special_2", 2.05, 1.1, MoveDefinition.AttackLevel.MID, 0, true),
		_make("6246K", "Super Kick", MoveDefinition.MoveType.SUPER, "6246", "K", 14, 12, 36, 390, "anim_overdrive", "super_flash", "super", 4.2, 1.35, MoveDefinition.AttackLevel.MID, 200, true, 70),
		_make("214U", "后拳反击", MoveDefinition.MoveType.SPECIAL, "214", "U", 5, 8, 32, 210, "anim_back_fist", "hit_spark_l", "special_1", 1.15, 1.0, MoveDefinition.AttackLevel.MID, 0, true),
		_make("214L", "Shadow Step", MoveDefinition.MoveType.SPECIAL, "214", "L", 5, 0, 16, 0, "anim_dash", "shadow_step", "ui_switch", 0.0, 0.0),
		_make("623I", "升龙拳", MoveDefinition.MoveType.SPECIAL, "623", "I", 8, 5, 27, 220, "rising_upper", "hit_spark_l", "special_2", 0.78, 1.32, MoveDefinition.AttackLevel.MID, 0, true),
		_make("5J+K", "Throw", MoveDefinition.MoveType.THROW, "", "J+K", 6, 6, 29, 190, "anim_command_throw", "throw_flash", "throw", 1.45, 1.0, MoveDefinition.AttackLevel.THROW, 0, true, 55),
		_make("236236O", "Overdrive", MoveDefinition.MoveType.SUPER, "236236", "O", 25, 15, 40, 430, "anim_overdrive", "super_flash", "super", 1.15, 1.0, MoveDefinition.AttackLevel.MID, 200, true, 70),
	]
	for move in moves:
		if move.id in ["236236J", "6246K"]:
			move.cinematic_enabled = true
			move.cinematic_duration_frames = 150 if move.id == "236236J" else 210
			move.cinematic_damage = 140 if move.id == "236236J" else 280
	return moves


static func load_moves_from_folder(folder_path: String) -> Array[MoveDefinition]:
	var loaded_moves: Array[MoveDefinition] = []
	var dir := DirAccess.open(folder_path)
	if dir == null:
		return loaded_moves

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource := ResourceLoader.load("%s/%s" % [folder_path, file_name])
			if resource is MoveDefinition:
				loaded_moves.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()

	loaded_moves.sort_custom(_sort_by_id)
	return loaded_moves


static func _make(
	id: String,
	display_name: String,
	move_type: MoveDefinition.MoveType,
	motion: String,
	button: String,
	startup: int,
	active: int,
	recovery: int,
	damage: int,
	animation_key: String,
	vfx_key: String,
	sfx_key: String,
	hit_range: float = 1.15,
	hit_height: float = 1.0,
	attack_level: MoveDefinition.AttackLevel = MoveDefinition.AttackLevel.MID,
	meter_cost: int = 0,
	knockdown_on_hit: bool = false,
	knockdown_frames: int = 45
) -> MoveDefinition:
	var move := MoveDefinition.new()
	move.id = id
	move.display_name = display_name
	move.move_type = move_type
	move.attack_level = attack_level
	move.motion = motion
	move.button = button
	move.startup_frames = startup
	move.active_frames = active
	move.recovery_frames = recovery
	move.damage = damage
	move.hit_range = hit_range
	move.hit_height = hit_height
	move.hitstun_frames = 12 + active
	move.blockstun_frames = 7 + int(active * 0.5)
	move.meter_cost = meter_cost
	move.knockdown_on_hit = knockdown_on_hit
	move.knockdown_frames = knockdown_frames
	if move_type == MoveDefinition.MoveType.THROW:
		move.throw_range = hit_range
	move.cancel_on_block = move_type != MoveDefinition.MoveType.NORMAL
	move.animation_key = animation_key
	move.vfx_key = vfx_key
	move.sfx_key = sfx_key
	return move


static func _make_projectile(
	id: String,
	display_name: String,
	motion: String,
	button: String,
	startup: int,
	active: int,
	recovery: int,
	damage: int,
	projectile_speed: float,
	projectile_radius: float,
	projectile_vertical_speed: float = 0.0,
	projectile_gravity: float = 0.0,
	projectile_ground_hug: bool = false,
	air_only: bool = false,
	ground_only: bool = false,
	attack_level: MoveDefinition.AttackLevel = MoveDefinition.AttackLevel.MID,
	projectile_height: float = 0.74
) -> MoveDefinition:
	var move := _make(
		id,
		display_name,
		MoveDefinition.MoveType.SPECIAL,
		motion,
		button,
		startup,
		active,
		recovery,
		damage,
		"anim_fireball",
		"muzzle_flash",
		"special_1",
		0.8,
		1.0,
		attack_level,
		0,
		false
	)
	move.air_only = air_only
	move.ground_only = ground_only
	move.chip_damage = maxi(1, int(round(float(damage) * 0.12)))
	move.projectile_enabled = true
	move.projectile_speed = projectile_speed
	move.projectile_vertical_speed = projectile_vertical_speed
	move.projectile_gravity = projectile_gravity
	move.projectile_lifetime_frames = 150
	move.projectile_radius = projectile_radius
	move.projectile_height = projectile_height
	move.projectile_ground_hug = projectile_ground_hug
	match id:
		"236J":
			move.effect_style = "fireball"
			move.effect_texture_path = "res://assets/vfx/kenney_particle_full/flame_05.png"
			move.effect_color = Color(1.0, 0.42, 0.12, 0.74)
			move.effect_scale = Vector2(1.25, 1.25)
		"236U":
			move.effect_style = "heavy_fireball"
			move.effect_texture_path = "res://assets/vfx/kenney_particle_full/flame_06.png"
			move.effect_color = Color(1.0, 0.24, 0.05, 0.82)
			move.effect_scale = Vector2(1.45, 1.45)
		"236I":
			move.effect_style = "fireball"
			move.effect_texture_path = "res://assets/vfx/kenney_particle_full/flame_05.png"
			move.effect_color = Color(1.0, 0.58, 0.15, 0.76)
			move.effect_scale = Vector2(1.55, 0.95)
		"623J":
			move.effect_style = "magic_bolt"
			move.effect_texture_path = "res://assets/vfx/kenney_particle_full/trace_03.png"
			move.effect_color = Color(0.45, 0.82, 1.0, 0.76)
			move.effect_scale = Vector2(1.45, 1.0)
		"214J":
			move.effect_style = "air_drop"
			move.effect_texture_path = "res://assets/vfx/kenney_particle_full/twirl_02.png"
			move.effect_color = Color(0.95, 0.28, 0.95, 0.72)
			move.effect_scale = Vector2(1.1, 1.1)
		"236O":
			move.effect_style = "ground_wave"
			move.effect_texture_path = "res://assets/vfx/kenney_particle_full/trace_04.png"
			move.effect_color = Color(1.0, 0.82, 0.18, 0.72)
			move.effect_scale = Vector2(1.45, 0.85)
	if id in ["236J", "236U"]:
		move.charge_enabled = true
		move.charge_min_frames = 8 if id == "236J" else 10
		move.charge_full_frames = 66 if id == "236J" else 78
		move.charge_max_hold_frames = 130 if id == "236J" else 150
		move.charge_damage_bonus = 90 if id == "236J" else 125
		move.charge_radius_bonus = 0.16 if id == "236J" else 0.2
		move.charge_speed_bonus = 0.45 if id == "236J" else 0.3
	return move


static func _sort_by_id(a: MoveDefinition, b: MoveDefinition) -> bool:
	return a.id.naturalnocasecmp_to(b.id) < 0
