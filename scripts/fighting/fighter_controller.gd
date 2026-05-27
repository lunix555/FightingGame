extends CharacterBody3D
class_name FighterController

signal state_changed(new_state: String)
signal move_started(move: MoveDefinition)
signal hit_confirmed(move: MoveDefinition)
signal cinematic_requested(move: MoveDefinition, attacker: FighterController, defender: FighterController)
signal combat_event(message: String)
signal projectile_requested(move: MoveDefinition, owner: FighterController, spawn_position: Vector3, direction: float)
signal sound_requested(sound_key: String)

enum FighterState {
	IDLE,
	WALK,
	CROUCH,
	JUMP_START,
	JUMP,
	LAND,
	DASH,
	BLOCK,
	HITSTUN,
	ATTACK,
	KNOCKDOWN,
}

const STATE_NAMES := {
	FighterState.IDLE: "idle",
	FighterState.WALK: "walk",
	FighterState.CROUCH: "crouch",
	FighterState.JUMP_START: "jump_start",
	FighterState.JUMP: "jump",
	FighterState.LAND: "land",
	FighterState.DASH: "dash",
	FighterState.BLOCK: "block",
	FighterState.HITSTUN: "hitstun",
	FighterState.ATTACK: "attack",
	FighterState.KNOCKDOWN: "knockdown",
}

const LOW_ATTACK_EFFECT_Y := 0.62
const STANDING_KICK_EFFECT_Y := 1.42
const THROW_EFFECT_Y := 1.38
const STANDING_ATTACK_EFFECT_Y := 1.82
const STANDING_PROJECTILE_SPAWN_Y := 1.82
const SLASH_EFFECT_Y := 1.78
const KNOCKDOWN_FALL_VISUAL_FRAMES := 42
const KNOCKDOWN_GETUP_VISUAL_FRAMES := 30
const KNOCKDOWN_ANIMATED_MIN_FRAMES := 96

@export var action_prefix := "p1"
@export var character_name := "Prototype"
@export var walk_speed := 2.6
@export var dash_speed := 6.0
@export var jump_speed := 5.2
@export var gravity := 14.0
@export var air_control_speed := 2.35
@export var air_control_acceleration := 0.42
@export var stage_min_x := -3.8
@export var stage_max_x := 3.8
@export var visual_target_height := 1.65
@export var visual_face_right_degrees := 180.0
@export var visual_face_left_degrees := 0.0
@export var use_fbx_visual := true
@export var show_debug_proxy := false
@export_dir var move_resource_folder := "res://data/moves/prototype"
@export var moves: Array[MoveDefinition] = []
@export_file("*.fbx", "*.FBX", "*.glb", "*.GLB", "*.gltf", "*.GLTF") var base_visual_scene := DEFAULT_BASE_VISUAL_SCENE
@export var visual_scene_paths := DEFAULT_VISUAL_SCENES.duplicate()
@export var visual_texture_paths := DEFAULT_TEXTURE_SET.duplicate()
@export var visual_fallback_color := Color(0.8, 0.82, 0.86)
@export var visual_animation_names := {}
@export var move_overrides := {}
@export var animation_slots := {
	"idle": "",
	"walk_forward": "",
	"walk_back": "",
	"crouch": "",
	"jump_start": "",
	"jump": "",
	"land": "",
	"dash_forward": "",
	"dash_back": "",
	"block": "",
	"hit_light": "",
	"hit_medium": "",
	"hit_heavy": "",
	"knockdown": "",
}

var input_buffer := FightingInputBuffer.new()
var opponent: FighterController
var state := FighterState.IDLE
var state_frame := 0
var game_frame := 0
var current_move: MoveDefinition
var facing_right := true
var health := 1000
var meter := 0
var hitstop_frames := 0
var knockdown_total_frames := 1
var last_direction := 5
var last_rejected_move_frame := -9999
var wakeup_invuln_frames := 0
var throw_invuln_frames := 0
var combo_count := 0
var combo_timer := 0
var combo_damage_total := 0

var body_mesh: MeshInstance3D
var state_label: Label3D
var hitbox_area: Area3D
var hurtbox_area: Area3D
var visual_model: Node3D
var visual_animation_player: AnimationPlayer
var visual_key := ""
var visual_cache := {}
var visual_state_override_key := ""
var visual_state_override_frames := 0
var hitstun_visual_key := "hit"
var knockdown_visual_key := "knockdown"
var attack_effect: MeshInstance3D
var attack_effect_material_cache := {}
var impact_flash: MeshInstance3D
var impact_flash_frames := 0
var impact_flash_material_cache := {}
var block_shield: MeshInstance3D
var block_shield_ring: MeshInstance3D
var block_shield_bar_a: MeshInstance3D
var block_shield_bar_b: MeshInstance3D
var block_guard_label: Label3D
var block_shield_frames := 0
var block_shield_material_cache := {}

const METER_STOCK_VALUE := 100
const METER_MAX_STOCKS := 3
const METER_MAX := METER_STOCK_VALUE * METER_MAX_STOCKS
const BLOCK_CHIP_RATIO := 0.12
const MIN_BODY_SPACING := 0.56
const WAKEUP_INVULN_FRAMES := 18
const THROW_INVULN_FRAMES := 12
const COMBO_TIMEOUT_FRAMES := 90
const COMBO_MIN_SCALE := 0.35
const BLOCK_SHIELD_FRAMES := 22
const SHADOW_STEP_BEHIND_OFFSET := 0.68

const DEFAULT_BASE_VISUAL_SCENE := "res://assets/fbx_model/Character_Base.FBX"
const DEFAULT_VISUAL_SCENES := {
	"idle": "res://assets/fbx_anim/Idle_Anim1.FBX",
	"punch": "res://assets/fbx_anim/Cross_Punch_Anim1.FBX",
	"kick": "res://assets/fbx_anim/Mma_Kick_Anim1.FBX",
	"jump": "res://assets/fbx_anim/Jump_Anim1.FBX",
	"run": "res://assets/fbx_anim/Fast_Run_Anim.FBX",
}

const MOVE_VISUALS := {
	"anim_light_punch": "punch",
	"anim_heavy_punch": "punch",
	"anim_forward_heavy": "punch",
	"anim_back_fist": "backstep",
	"anim_fireball": "punch",
	"anim_overdrive": "punch",
	"anim_light_kick": "kick",
	"anim_heavy_kick": "kick",
	"anim_crouch_kick": "crouch_kick",
	"anim_advancing_kick": "hurricane_kick",
	"anim_rising_upper": "jump_alt",
	"anim_dust": "kick",
	"anim_command_throw": "punch",
	"anim_dash": "dash",
}

const DEFAULT_TEXTURE_SET := {
	"body": "res://assets/textures/1129/4.png",
	"face": "res://assets/textures/1129/5.png",
	"face_detail": "res://assets/textures/1129/5.png",
	"eye": "res://assets/textures/1129/3.png",
	"hair": "res://assets/textures/1129/1.png",
	"mayu": "res://assets/textures/1129/5.png",
	"tail": "res://assets/textures/1129/2.png",
}
const TUNABLE_MOVE_PROPERTIES := {
	"startup_frames": true,
	"active_frames": true,
	"recovery_frames": true,
	"hitstun_frames": true,
	"blockstun_frames": true,
	"damage": true,
	"chip_damage": true,
	"meter_cost": true,
	"meter_gain_on_hit": true,
	"meter_gain_on_block": true,
	"hit_range": true,
	"hit_height": true,
	"pushback_on_hit": true,
	"pushback_on_block": true,
	"self_velocity_x": true,
	"hitstop_on_hit": true,
	"hitstop_on_block": true,
	"knockdown_on_hit": true,
	"knockdown_frames": true,
	"projectile_speed": true,
	"projectile_vertical_speed": true,
	"projectile_gravity": true,
	"projectile_lifetime_frames": true,
	"projectile_radius": true,
	"projectile_height": true,
	"animation_key": true,
	"cinematic_enabled": true,
	"cinematic_video_path": true,
	"cinematic_duration_frames": true,
	"cinematic_damage": true,
}


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	if moves.is_empty():
		moves = FakeMoveDatabase.load_moves_from_folder(move_resource_folder)
	if moves.is_empty():
		moves = FakeMoveDatabase.build_default_moves()
	_build_debug_body()
	if use_fbx_visual:
		_set_visual("idle")
	_enter_state(FighterState.IDLE)


func set_opponent(value: FighterController) -> void:
	opponent = value
	refresh_facing_from_opponent()


func apply_character_resources(move_folder: String, base_scene: String, scene_paths: Dictionary, texture_paths: Dictionary, overrides: Dictionary = {}, animation_names: Dictionary = {}) -> void:
	move_resource_folder = move_folder
	base_visual_scene = base_scene
	visual_scene_paths = scene_paths.duplicate(true)
	visual_texture_paths = texture_paths.duplicate(true)
	visual_fallback_color = texture_paths.get("_fallback_color", Color(0.8, 0.82, 0.86)) as Color
	visual_animation_names = animation_names.duplicate(true)
	move_overrides = overrides.duplicate(true)
	moves.clear()
	visual_cache.clear()
	visual_key = ""
	visual_state_override_key = ""
	visual_state_override_frames = 0
	hitstun_visual_key = "hit"
	if visual_model != null:
		visual_model.queue_free()
		visual_model = null
		visual_animation_player = null
	if is_inside_tree():
		moves = FakeMoveDatabase.load_moves_from_folder(move_resource_folder)
		if moves.is_empty():
			moves = FakeMoveDatabase.build_default_moves()
		_apply_move_overrides()
		if use_fbx_visual:
			call_deferred("_set_visual", "idle")


func _apply_move_overrides() -> void:
	if move_overrides.is_empty():
		return
	for move in moves:
		if move == null or not move_overrides.has(move.id):
			continue
		var overrides := move_overrides[move.id] as Dictionary
		for property_name in overrides.keys():
			var property_text := String(property_name)
			if TUNABLE_MOVE_PROPERTIES.has(property_text):
				move.set(property_text, overrides[property_name])


func reset_for_round(spawn_position: Vector3, round_health: int, reset_meter: bool = true) -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	health = round_health
	if reset_meter:
		meter = 0
	hitstop_frames = 0
	last_direction = 5
	current_move = null
	wakeup_invuln_frames = 0
	throw_invuln_frames = 0
	hitstun_visual_key = "hit"
	block_shield_frames = 0
	_hide_block_shield()
	_reset_combo()
	input_buffer.clear()
	_enter_state(FighterState.IDLE)
	_settle_on_floor()
	refresh_facing_from_opponent()


func _settle_on_floor() -> void:
	if is_on_floor():
		return
	for _step in range(8):
		velocity = Vector3(0.0, -gravity / 60.0, 0.0)
		move_and_slide()
		if is_on_floor():
			break
	velocity = Vector3.ZERO


func force_knockdown(frames: int) -> void:
	_enter_knockdown(frames)
	_update_visual_state()
	_update_debug_visuals()


func tick() -> void:
	game_frame += 1
	_update_facing()
	_tick_combat_timers()
	_tick_impact_flash()
	_tick_block_shield()
	var was_airborne := is_airborne()

	if hitstop_frames > 0:
		hitstop_frames -= 1
		_update_debug_visuals()
		return

	if state == FighterState.KNOCKDOWN:
		_tick_knockdown()
		_update_visual_state()
		state_frame += 1
		_update_debug_visuals()
		return

	var sample := input_buffer.sample(action_prefix, game_frame, facing_right)
	last_direction = int(sample["direction"])

	if state == FighterState.HITSTUN:
		_tick_hitstun()
	elif state == FighterState.BLOCK:
		_tick_blockstun()
	elif state == FighterState.ATTACK:
		_tick_attack()
	else:
		_tick_movement()

	_update_visual_state()
	if was_airborne and is_on_floor() and state not in [FighterState.KNOCKDOWN, FighterState.HITSTUN]:
		sound_requested.emit("land")
	state_frame += 1
	_update_debug_visuals()


func state_name() -> String:
	return String(STATE_NAMES[state])


func current_move_text() -> String:
	if current_move == null:
		return "-"
	return "%s %s" % [current_move.command_text(), current_move.display_name]


func is_in_control() -> bool:
	return state in [FighterState.IDLE, FighterState.WALK, FighterState.CROUCH, FighterState.JUMP, FighterState.JUMP_START]


func is_airborne() -> bool:
	return not is_on_floor() or state in [FighterState.JUMP, FighterState.JUMP_START]


func is_invulnerable_to_hits() -> bool:
	return wakeup_invuln_frames > 0 or state == FighterState.KNOCKDOWN


func is_throw_invulnerable() -> bool:
	return throw_invuln_frames > 0 or state == FighterState.KNOCKDOWN or not is_on_floor()


func combo_text() -> String:
	if combo_count <= 1:
		return ""
	return "%d Hits / %d" % [combo_count, combo_damage_total]


func is_charging_projectile() -> bool:
	return state == FighterState.ATTACK and current_move != null and current_move.charge_enabled and not bool(current_move.get_meta("charge_released", false))


func _tick_combat_timers() -> void:
	wakeup_invuln_frames = maxi(0, wakeup_invuln_frames - 1)
	throw_invuln_frames = maxi(0, throw_invuln_frames - 1)
	if combo_timer > 0:
		combo_timer -= 1
		if combo_timer <= 0 and state not in [FighterState.HITSTUN, FighterState.KNOCKDOWN]:
			_reset_combo()


func _reset_combo() -> void:
	combo_count = 0
	combo_timer = 0
	combo_damage_total = 0


func _tick_movement() -> void:
	var move := input_buffer.find_move(moves)
	if move != null:
		if _can_start_move(move):
			_start_move(move)
			return
		_report_rejected_move(move)

	if not is_on_floor():
		velocity.y -= gravity / 60.0
		_apply_air_control()
		_enter_state_if_needed(FighterState.JUMP)
		move_and_slide()
		global_position.x = clampf(global_position.x, stage_min_x, stage_max_x)
		return

	if last_direction in [1, 2, 3]:
		velocity.x = 0.0
		_enter_state_if_needed(FighterState.CROUCH)
	elif last_direction in [4, 6]:
		var direction := -1.0 if last_direction == 4 else 1.0
		velocity.x = direction * walk_speed * (1.0 if facing_right else -1.0)
		_enter_state_if_needed(FighterState.WALK)
	elif last_direction in [7, 8, 9]:
		var jump_horizontal := _screen_horizontal_from_direction(last_direction)
		velocity.x = jump_horizontal * air_control_speed
		velocity.y = jump_speed
		_enter_state(FighterState.JUMP_START)
	else:
		velocity.x = move_toward(velocity.x, 0.0, walk_speed / 8.0)
		_enter_state_if_needed(FighterState.IDLE)

	move_and_slide()
	global_position.x = clampf(global_position.x, stage_min_x, stage_max_x)


func _tick_attack() -> void:
	if current_move == null:
		_enter_state(FighterState.IDLE)
		return

	var phase := current_move.phase_at(state_frame)
	if not is_on_floor():
		_apply_air_control()
		velocity.y -= gravity / 60.0
	elif current_move.self_velocity_x > 0.0 and phase in ["startup", "active"]:
		velocity.x = current_move.self_velocity_x * (1.0 if facing_right else -1.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, walk_speed / 12.0)
	move_and_slide()
	global_position.x = clampf(global_position.x, stage_min_x, stage_max_x)

	if current_move.charge_enabled:
		_tick_charge_attack()
		return

	if _try_attack_cancel(phase):
		return
	hitbox_area.monitoring = phase == "active" and not current_move.projectile_enabled
	hitbox_area.visible = hitbox_area.monitoring
	_update_attack_effect(phase)

	if phase == "active":
		if current_move.projectile_enabled:
			_try_request_projectile()
		else:
			_try_hit_opponent()

	if phase == "done":
		hitbox_area.monitoring = false
		_hide_attack_effect()
		_enter_state(FighterState.IDLE)


func _tick_charge_attack() -> void:
	hitbox_area.monitoring = false
	hitbox_area.visible = false

	if state_frame < current_move.startup_frames:
		_update_attack_effect("startup")
		if not _is_charge_button_held(current_move):
			current_move.set_meta("charge_release_pending", true)
		return

	if not bool(current_move.get_meta("charge_released", false)):
		var charge_frames := int(current_move.get_meta("charge_frames", 0))
		charge_frames += 1
		current_move.set_meta("charge_frames", charge_frames)
		_update_attack_effect("active")
		_scale_charge_effect(charge_frames)

		var should_release := bool(current_move.get_meta("charge_release_pending", false))
		should_release = should_release or not _is_charge_button_held(current_move)
		should_release = should_release or charge_frames >= current_move.charge_max_hold_frames
		if should_release and charge_frames >= current_move.charge_min_frames:
			_release_charged_projectile(charge_frames)
		return

	var phase := current_move.phase_at(state_frame)
	_update_attack_effect(phase)
	if phase == "done":
		_hide_attack_effect()
		_enter_state(FighterState.IDLE)


func _is_charge_button_held(move: MoveDefinition) -> bool:
	return move != null and input_buffer.is_button_down(move.button)


func _scale_charge_effect(charge_frames: int) -> void:
	if attack_effect == null or current_move == null:
		return
	var ratio := _charge_ratio(current_move, charge_frames)
	var pulse := 1.0 + sin(float(game_frame) * 0.28) * (0.06 + ratio * 0.08)
	attack_effect.scale = _attack_effect_scale(current_move) * (1.0 + ratio * 0.78) * pulse
	attack_effect.transparency = clampf(0.36 - ratio * 0.18, 0.08, 0.42)


func _release_charged_projectile(charge_frames: int) -> void:
	var projectile_move := _make_charged_projectile_move(current_move, charge_frames)
	_try_request_projectile(projectile_move)
	current_move.set_meta("charge_released", true)
	state_frame = current_move.startup_frames + current_move.active_frames
	combat_event.emit("%s 蓄力发射 %s，蓄力 %dF" % [character_name, current_move.display_name, charge_frames])


func _make_charged_projectile_move(base_move: MoveDefinition, charge_frames: int) -> MoveDefinition:
	var charged := base_move.duplicate(true) as MoveDefinition
	var ratio := _charge_ratio(base_move, charge_frames)
	charged.id = "%s_charge_%03d" % [base_move.id, charge_frames]
	charged.display_name = "%s·蓄力" % base_move.display_name
	charged.damage = base_move.damage + int(round(float(base_move.charge_damage_bonus) * ratio))
	charged.chip_damage = maxi(base_move.chip_damage, int(round(float(charged.damage) * 0.18)))
	charged.projectile_radius = base_move.projectile_radius + base_move.charge_radius_bonus * ratio
	charged.projectile_speed = base_move.projectile_speed + base_move.charge_speed_bonus * ratio
	charged.projectile_lifetime_frames = base_move.projectile_lifetime_frames + int(round(28.0 * ratio))
	charged.projectile_clash_level = 1
	charged.effect_scale = base_move.effect_scale * (1.0 + ratio * 0.62)
	charged.effect_color = _charged_color(base_move.effect_color, ratio)
	charged.effect_impact_color = _charged_color(base_move.effect_impact_color, ratio)
	if ratio >= 0.95:
		charged.knockdown_on_hit = true
		charged.knockdown_frames = maxi(charged.knockdown_frames, 58)
	return charged


func _charge_ratio(move: MoveDefinition, charge_frames: int) -> float:
	if move == null:
		return 0.0
	var span := maxf(1.0, float(move.charge_full_frames - move.charge_min_frames))
	return clampf(float(charge_frames - move.charge_min_frames) / span, 0.0, 1.0)


func _charged_color(color: Color, ratio: float) -> Color:
	var base := color
	if base.a <= 0.0:
		base = Color(1.0, 0.42, 0.12, 0.78)
	return base.lerp(Color(1.0, 0.92, 0.38, maxf(base.a, 0.88)), ratio * 0.75)


func _tick_hitstun() -> void:
	velocity.x = move_toward(velocity.x, 0.0, walk_speed / 18.0)
	if not is_on_floor():
		velocity.y -= gravity / 60.0
	move_and_slide()
	global_position.x = clampf(global_position.x, stage_min_x, stage_max_x)
	if state_frame >= -1 and health > 0:
		_enter_state(FighterState.IDLE)


func _tick_blockstun() -> void:
	velocity.x = move_toward(velocity.x, 0.0, walk_speed / 14.0)
	if not is_on_floor():
		velocity.y -= gravity / 60.0
	move_and_slide()
	global_position.x = clampf(global_position.x, stage_min_x, stage_max_x)
	if state_frame >= -1 and health > 0:
		_enter_state(FighterState.IDLE)


func _tick_knockdown() -> void:
	input_buffer.clear()
	last_direction = 5
	current_move = null
	if hitbox_area != null:
		hitbox_area.monitoring = false
		hitbox_area.visible = false
	velocity.x = move_toward(velocity.x, 0.0, walk_speed / 18.0)
	if not is_on_floor():
		velocity.y -= gravity / 60.0
	move_and_slide()
	global_position.x = clampf(global_position.x, stage_min_x, stage_max_x)
	_apply_knockdown_visual_pose()
	if state_frame >= -1 and health > 0 and is_on_floor():
		_enter_state(FighterState.IDLE)
		wakeup_invuln_frames = WAKEUP_INVULN_FRAMES
		throw_invuln_frames = THROW_INVULN_FRAMES
		_reset_combo()


func _apply_air_control() -> void:
	var horizontal := _screen_horizontal_from_direction(last_direction)
	if horizontal != 0.0:
		velocity.x = move_toward(velocity.x, horizontal * air_control_speed, air_control_acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, air_control_acceleration * 0.35)


func _screen_horizontal_from_direction(direction: int) -> float:
	var relative_horizontal := 0.0
	if direction in [1, 4, 7]:
		relative_horizontal = -1.0
	elif direction in [3, 6, 9]:
		relative_horizontal = 1.0

	if relative_horizontal == 0.0:
		return 0.0
	return relative_horizontal * (1.0 if facing_right else -1.0)


func _perform_shadow_step() -> void:
	if opponent == null or not is_instance_valid(opponent) or not is_on_floor():
		return
	var side := -1.0 if opponent.facing_right else 1.0
	var target_x := opponent.global_position.x + side * SHADOW_STEP_BEHIND_OFFSET
	global_position.x = clampf(target_x, stage_min_x, stage_max_x)
	velocity.x = 0.0
	refresh_facing_from_opponent()
	opponent.refresh_facing_from_opponent()
	_show_impact_flash(current_move, true)


func _start_move(move: MoveDefinition) -> void:
	current_move = move
	current_move.set_meta("already_hit", false)
	current_move.set_meta("projectile_spawned", false)
	current_move.set_meta("charge_frames", 0)
	current_move.set_meta("charge_released", false)
	current_move.set_meta("charge_release_pending", false)
	current_move.set_meta("hit_result", "")
	current_move.set_meta("cancel_used", false)
	if is_on_floor():
		velocity.x = 0.0
	if move.meter_cost > 0:
		meter = maxi(0, meter - move.meter_cost)

	if move.id == "236236J":
		velocity.x = (1.0 if facing_right else -1.0) * 1.0
	elif move.motion == "623":
		velocity.y = jump_speed * 0.55

	_enter_state(FighterState.ATTACK)
	_prepare_attack_effect(move)
	_set_visual_for_move(move)
	var start_sound := _move_start_sound_key(move)
	if not start_sound.is_empty():
		sound_requested.emit(start_sound)
	if move.id == "214L":
		_perform_shadow_step()
	move_started.emit(move)


func _try_request_projectile(projectile_move: MoveDefinition = null) -> void:
	if current_move == null or bool(current_move.get_meta("projectile_spawned", false)):
		return
	if projectile_move == null:
		projectile_move = current_move
	current_move.set_meta("projectile_spawned", true)
	var direction := 1.0 if facing_right else -1.0
	var offset_x := _effect_offset_x(projectile_move)
	var spawn_position := global_position + Vector3(direction * offset_x, _projectile_spawn_y(projectile_move), 0.0)
	if projectile_move.effect_spawn_mode == "target_ground" and opponent != null:
		spawn_position = opponent.global_position + Vector3(0.0, projectile_move.projectile_height, 0.0)
	elif projectile_move.effect_spawn_mode == "owner_ground":
		spawn_position = global_position + Vector3(direction * offset_x, projectile_move.projectile_height, 0.0)
	projectile_requested.emit(projectile_move, self, spawn_position, direction)


func receive_hit(move: MoveDefinition, attacker: FighterController) -> int:
	if move == null or is_invulnerable_to_hits():
		return 0
	var damage := _scaled_damage(move.damage)
	return _apply_unblocked_hit_damage(move, attacker, damage)


func receive_unblocked_contact(move: MoveDefinition, attacker: FighterController) -> int:
	if attacker != null and attacker.should_trigger_cinematic(move):
		var setup_result := receive_cinematic_setup(move, attacker)
		if setup_result > 0:
			attacker.cinematic_requested.emit(move, attacker, self)
		return setup_result
	return receive_hit(move, attacker)


func receive_cinematic_setup(move: MoveDefinition, attacker: FighterController) -> int:
	if move == null or is_invulnerable_to_hits():
		return 0
	_set_hitstun_visual_key(false)
	_show_impact_flash(move, false)
	sound_requested.emit(_hit_sound_key(move))
	velocity = Vector3.ZERO
	_interrupt_current_action()
	_enter_state(FighterState.HITSTUN)
	state_frame = -maxi(1, move.hitstun_frames)
	return 1


func receive_cinematic_damage(move: MoveDefinition, attacker: FighterController, override_damage: int = -1) -> int:
	if move == null:
		return 0
	var damage := override_damage if override_damage >= 0 else _scaled_damage(move.damage)
	return _apply_unblocked_hit_damage(move, attacker, damage)


func should_trigger_cinematic(move: MoveDefinition) -> bool:
	if move == null:
		return false
	return move.cinematic_enabled


func _apply_unblocked_hit_damage(move: MoveDefinition, attacker: FighterController, damage: int) -> int:
	var was_crouching := is_on_floor() and (state == FighterState.CROUCH or last_direction in [1, 2, 3])
	_set_hitstun_visual_key(was_crouching)
	health = max(0, health - damage)
	_register_combo_damage(damage)
	_show_impact_flash(move, false)
	sound_requested.emit(_hit_sound_key(move))
	velocity.x = move.pushback_on_hit * _push_direction_from_attacker(attacker)
	if move.launch_velocity != Vector2.ZERO:
		velocity.x = move.launch_velocity.x * _push_direction_from_attacker(attacker)
		velocity.y = move.launch_velocity.y
	elif not is_on_floor():
		velocity.y = maxf(velocity.y, 1.35)
	_interrupt_current_action()

	var should_knockdown := health <= 0 or move.knockdown_on_hit
	if not is_on_floor() and (move.knockdown_on_hit or move.move_type in [MoveDefinition.MoveType.SPECIAL, MoveDefinition.MoveType.SUPER]):
		should_knockdown = true
	if should_knockdown:
		_enter_knockdown(move.knockdown_frames, move.preserve_launch_on_knockdown, was_crouching)
	else:
		_enter_state(FighterState.HITSTUN)
		state_frame = -maxi(move.hitstun_frames, move.air_hitstun_frames if not is_on_floor() else move.hitstun_frames)
	return damage


func _set_hitstun_visual_key(was_crouching: bool) -> void:
	if was_crouching and visual_scene_paths.has("crouch_hit"):
		hitstun_visual_key = "crouch_hit"
	elif visual_scene_paths.has("hit"):
		hitstun_visual_key = "hit"
	elif visual_scene_paths.has("hit_medium"):
		hitstun_visual_key = "hit_medium"
	else:
		hitstun_visual_key = "idle"


func receive_block(move: MoveDefinition, attacker: FighterController) -> int:
	var chip := move.chip_damage
	if chip <= 0:
		chip = maxi(1, int(round(float(move.damage) * BLOCK_CHIP_RATIO)))
	health = max(0, health - chip)
	_reset_combo()
	_show_impact_flash(move, true)
	_show_block_shield(move, attacker)
	sound_requested.emit("block_success")
	velocity.x = move.pushback_on_block * _push_direction_from_attacker(attacker)
	_interrupt_current_action()
	_enter_state(FighterState.BLOCK)
	state_frame = -maxi(1, move.blockstun_frames)

	if health <= 0:
		var was_crouching := is_on_floor() and (state == FighterState.CROUCH or last_direction in [1, 2, 3])
		_enter_knockdown(move.knockdown_frames, false, was_crouching)
	return chip


func receive_throw(move: MoveDefinition, attacker: FighterController) -> int:
	if move == null or is_throw_invulnerable():
		return 0
	var damage := move.damage
	health = max(0, health - damage)
	_register_combo_damage(damage)
	velocity = Vector3(1.85 * _push_direction_from_attacker(attacker), 0.0, 0.0)
	_interrupt_current_action()
	var was_crouching := is_on_floor() and (state == FighterState.CROUCH or last_direction in [1, 2, 3])
	_enter_knockdown(move.knockdown_frames, false, was_crouching)
	return damage


func _try_hit_opponent() -> void:
	if opponent == null or opponent.is_invulnerable_to_hits():
		return
	if bool(current_move.get_meta("already_hit", false)):
		return

	if _attack_overlaps_opponent(current_move):
		current_move.set_meta("already_hit", true)
		_apply_contact_hitstop(current_move, "hit")
		if current_move.move_type == MoveDefinition.MoveType.THROW:
			if opponent._is_super_threatening():
				combat_event.emit("%s 的投技被 %s 的大招压过" % [character_name, opponent.character_name])
			elif opponent._is_throw_teching():
				_gain_meter(4)
				opponent._gain_meter(4)
				throw_invuln_frames = THROW_INVULN_FRAMES
				opponent.throw_invuln_frames = THROW_INVULN_FRAMES
				current_move.set_meta("hit_result", "block")
				combat_event.emit("%s 的投技被 %s 拆投" % [character_name, opponent.character_name])
			else:
				var throw_damage := opponent.receive_throw(current_move, self)
				if throw_damage > 0:
					current_move.set_meta("hit_result", "hit")
					_gain_meter(current_move.meter_gain_on_hit)
					combat_event.emit("%s 投技命中，伤害 %d" % [character_name, throw_damage])
					hit_confirmed.emit(current_move)
		elif opponent.can_block_move(current_move, self):
			var chip := opponent.receive_block(current_move, self)
			current_move.set_meta("hit_result", "block")
			_apply_contact_hitstop(current_move, "block")
			_gain_meter(current_move.meter_gain_on_block)
			opponent._gain_meter(current_move.meter_gain_on_block)
			combat_event.emit("%s 防住了 %s，削血 %d" % [opponent.character_name, current_move.display_name, chip])
		else:
			var dealt := opponent.receive_unblocked_contact(current_move, self)
			if dealt > 0:
				current_move.set_meta("hit_result", "hit")
				_gain_meter(current_move.meter_gain_on_hit)
				hit_confirmed.emit(current_move)


func _can_start_move(move: MoveDefinition) -> bool:
	if move.meter_cost > 0 and meter < move.meter_cost:
		return false
	if move.air_only and is_on_floor():
		return false
	if move.ground_only and not is_on_floor():
		return false
	return is_in_control()


func _try_attack_cancel(phase: String) -> bool:
	if current_move == null or phase not in ["active", "recovery"]:
		return false
	if bool(current_move.get_meta("cancel_used", false)):
		return false
	var result := String(current_move.get_meta("hit_result", ""))
	if result == "hit" and not current_move.cancel_on_hit:
		return false
	if result == "block" and not current_move.cancel_on_block:
		return false
	if result.is_empty():
		return false

	var next_move := input_buffer.find_move(moves)
	if next_move == null or next_move == current_move or next_move.id == current_move.id:
		return false
	if not _can_start_cancel_move(current_move, next_move):
		return false
	current_move.set_meta("cancel_used", true)
	_start_move(next_move)
	combat_event.emit("%s 取消到 %s" % [character_name, next_move.display_name])
	return true


func _can_start_cancel_move(from_move: MoveDefinition, next_move: MoveDefinition) -> bool:
	if next_move == null or next_move.move_type == MoveDefinition.MoveType.THROW:
		return false
	if next_move.meter_cost > 0 and meter < next_move.meter_cost:
		return false
	if next_move.air_only and is_on_floor():
		return false
	if next_move.ground_only and not is_on_floor():
		return false
	var from_rank := _cancel_rank(from_move)
	var next_rank := _cancel_rank(next_move)
	if next_move.move_type == MoveDefinition.MoveType.SUPER:
		return next_rank >= from_rank
	return next_rank > from_rank


func _cancel_rank(move: MoveDefinition) -> int:
	if move == null:
		return -1
	if move.cancel_level >= 0:
		return move.cancel_level
	match move.move_type:
		MoveDefinition.MoveType.NORMAL:
			return 0
		MoveDefinition.MoveType.COMMAND_NORMAL:
			return 1
		MoveDefinition.MoveType.SPECIAL:
			return 2
		MoveDefinition.MoveType.SUPER:
			return 3
	return -1


func _attack_overlaps_opponent(move: MoveDefinition) -> bool:
	if move == null or opponent == null:
		return false
	if move.move_type == MoveDefinition.MoveType.THROW and opponent.is_throw_invulnerable():
		return false
	var attack_rect := _attack_rect(move)
	var hurt_rect := opponent._hurt_rect()
	return attack_rect.intersects(hurt_rect)


func _attack_rect(move: MoveDefinition) -> Rect2:
	var size := _move_hitbox_size(move)
	var offset := _move_hitbox_offset(move, size)
	var direction := 1.0 if facing_right else -1.0
	var center_x := global_position.x + direction * offset.x
	var center_y := global_position.y + offset.y
	return Rect2(Vector2(center_x - size.x * 0.5, center_y - size.y * 0.5), size)


func _hurt_rect() -> Rect2:
	var width := 0.54
	var height := 1.78
	var center_y := global_position.y + 0.92
	if state == FighterState.CROUCH or last_direction in [1, 2, 3]:
		height = 1.08
		center_y = global_position.y + 0.54
	elif is_airborne():
		height = 1.46
		center_y = global_position.y + 1.02
	return Rect2(Vector2(global_position.x - width * 0.5, center_y - height * 0.5), Vector2(width, height))


func _move_hitbox_size(move: MoveDefinition) -> Vector2:
	if move.hitbox_size != Vector2.ZERO:
		return move.hitbox_size
	if move.move_type == MoveDefinition.MoveType.THROW:
		return Vector2(maxf(move.throw_range, 0.42), 1.18)
	if move.attack_level == MoveDefinition.AttackLevel.LOW:
		return Vector2(maxf(move.hit_range, 0.58), maxf(move.hit_height, 0.52))
	return Vector2(maxf(move.hit_range, 0.58), maxf(move.hit_height, 0.72))


func _move_hitbox_offset(move: MoveDefinition, size: Vector2) -> Vector2:
	if move.hitbox_offset != Vector2.ZERO:
		return move.hitbox_offset
	var x := size.x * 0.48
	var y := STANDING_ATTACK_EFFECT_Y
	if move.move_type == MoveDefinition.MoveType.THROW:
		x = maxf(move.throw_range * 0.42, 0.28)
		y = THROW_EFFECT_Y
	elif move.attack_level == MoveDefinition.AttackLevel.LOW or move.animation_key == "anim_crouch_kick":
		y = LOW_ATTACK_EFFECT_Y
	elif move.animation_key in ["anim_light_kick", "anim_heavy_kick"]:
		y = STANDING_KICK_EFFECT_Y
	return Vector2(x, y)


func _scaled_damage(base_damage: int) -> int:
	var scale := clampf(1.0 - float(combo_count) * 0.12, COMBO_MIN_SCALE, 1.0)
	return maxi(1, int(round(float(base_damage) * scale)))


func _register_combo_damage(damage: int) -> void:
	if combo_timer > 0 or state == FighterState.HITSTUN or not is_on_floor():
		combo_count += 1
	else:
		combo_count = 1
		combo_damage_total = 0
	combo_damage_total += damage
	combo_timer = COMBO_TIMEOUT_FRAMES


func _interrupt_current_action() -> void:
	current_move = null
	hitbox_area.monitoring = false
	_hide_attack_effect()


func _push_direction_from_attacker(attacker: FighterController) -> float:
	if attacker == null or not is_instance_valid(attacker):
		return -1.0 if facing_right else 1.0
	return -1.0 if attacker.global_position.x > global_position.x else 1.0


func _gain_meter(amount: int) -> void:
	if amount <= 0:
		return
	meter = mini(METER_MAX, meter + amount)


func _apply_contact_hitstop(move: MoveDefinition, result: String) -> void:
	if move == null or opponent == null:
		return
	var frames := move.hitstop_on_block if result == "block" else move.hitstop_on_hit
	frames = maxi(1, frames)
	hitstop_frames = frames
	opponent.hitstop_frames = frames


func _report_rejected_move(move: MoveDefinition) -> void:
	if game_frame - last_rejected_move_frame < 12:
		return
	last_rejected_move_frame = game_frame
	if move.meter_cost > 0 and meter < move.meter_cost:
		combat_event.emit("%s 怒气不足：%s 需要 %d，当前 %d" % [character_name, move.command_text(), move.meter_cost, meter])


func _enter_knockdown(frames: int, preserve_velocity: bool = false, was_crouching: bool = false) -> void:
	if not preserve_velocity:
		velocity.y = 0.0
	knockdown_visual_key = _knockdown_visual_key_for_pose(was_crouching)
	var minimum_frames := KNOCKDOWN_ANIMATED_MIN_FRAMES if _has_animated_knockdown_visuals() else 1
	knockdown_total_frames = maxi(minimum_frames, frames)
	_enter_state(FighterState.KNOCKDOWN)
	state_frame = -knockdown_total_frames
	input_buffer.clear()
	sound_requested.emit("knockdown")


func _knockdown_visual_key_for_pose(was_crouching: bool) -> String:
	if was_crouching and _has_visual_scene("crouch_knockdown"):
		return "crouch_knockdown"
	if _has_visual_scene("knockdown"):
		return "knockdown"
	return "idle"


func can_block_move(move: MoveDefinition, attacker: FighterController) -> bool:
	if not is_on_floor():
		return false
	if move.move_type == MoveDefinition.MoveType.THROW:
		return false

	var level := _effective_attack_level(move, attacker)
	return _is_blocking_level(level)


func _effective_attack_level(move: MoveDefinition, attacker: FighterController) -> int:
	var level := move.attack_level
	if attacker != null and not attacker.is_on_floor() and not move.projectile_enabled and move.move_type != MoveDefinition.MoveType.SUPER:
		return MoveDefinition.AttackLevel.HIGH
	return level


func _is_blocking_level(level: int) -> bool:
	if level == MoveDefinition.AttackLevel.LOW:
		return _is_crouch_blocking()
	if level == MoveDefinition.AttackLevel.HIGH:
		return _is_stand_blocking()
	return _is_stand_blocking() or _is_crouch_blocking()


func _is_stand_blocking() -> bool:
	return last_direction == 4


func _is_crouch_blocking() -> bool:
	return last_direction == 1


func _is_throw_teching() -> bool:
	if input_buffer.was_button_pressed_recently("J+K", 8):
		return true
	if current_move == null or current_move.move_type != MoveDefinition.MoveType.THROW:
		return false
	if state != FighterState.ATTACK:
		return false
	return current_move.phase_at(state_frame) in ["startup", "active"]


func _is_super_threatening() -> bool:
	if current_move == null or current_move.move_type != MoveDefinition.MoveType.SUPER:
		return false
	if state != FighterState.ATTACK:
		return false
	return current_move.phase_at(state_frame) in ["startup", "active"]


func _enter_state_if_needed(next_state: FighterState) -> void:
	if state != next_state:
		_enter_state(next_state)


func _enter_state(next_state: FighterState) -> void:
	var previous_state := state
	state = next_state
	state_frame = 0
	if next_state != FighterState.ATTACK:
		current_move = null
	if hitbox_area != null:
		hitbox_area.monitoring = false
		hitbox_area.visible = false
	_hide_attack_effect()
	_apply_visual_facing()
	_prepare_visual_state_transition(previous_state, next_state)
	if next_state == FighterState.JUMP_START and previous_state != FighterState.JUMP_START:
		sound_requested.emit("jump")
	state_changed.emit(state_name())


func _prepare_visual_state_transition(previous_state: FighterState, next_state: FighterState) -> void:
	visual_state_override_key = ""
	visual_state_override_frames = 0
	if previous_state != FighterState.CROUCH and next_state == FighterState.CROUCH and visual_scene_paths.has("crouch_enter"):
		visual_state_override_key = "crouch_enter"
		visual_state_override_frames = 10
	elif previous_state == FighterState.CROUCH and next_state in [FighterState.IDLE, FighterState.WALK] and visual_scene_paths.has("crouch_exit"):
		visual_state_override_key = "crouch_exit"
		visual_state_override_frames = 10


func _hit_sound_key(move: MoveDefinition) -> String:
	if move == null:
		return "hit_medium"
	if move.move_type == MoveDefinition.MoveType.THROW or move.knockdown_on_hit or move.damage >= 150:
		return "hit_heavy"
	if move.damage <= 95:
		return "hit_light"
	return "hit_medium"


func _move_start_sound_key(move: MoveDefinition) -> String:
	if move == null:
		return ""
	if not move.sfx_key.is_empty():
		return move.sfx_key
	if move.move_type == MoveDefinition.MoveType.THROW:
		return "throw"
	if move.effect_style == "slash":
		return "slash"
	if move.effect_style == "pillar":
		return "ice"
	if move.projectile_enabled:
		if move.charge_enabled:
			return "projectile_charge"
		if move.damage >= 120 or move.projectile_radius >= 0.27:
			return "projectile_heavy"
		return "projectile_light"
	return ""


func _update_facing() -> void:
	refresh_facing_from_opponent()


func refresh_facing_from_opponent() -> void:
	if opponent == null:
		return
	facing_right = opponent.global_position.x > global_position.x
	rotation.y = 0.0
	_apply_visual_facing()


func set_visual_facing_angles(face_right_degrees: float, face_left_degrees: float) -> void:
	visual_face_right_degrees = face_right_degrees
	visual_face_left_degrees = face_left_degrees
	_apply_visual_facing()


func current_visual_facing_degrees() -> float:
	return visual_face_right_degrees if facing_right else visual_face_left_degrees


func _build_debug_body() -> void:
	var body_shape := CapsuleShape3D.new()
	body_shape.radius = 0.28
	body_shape.height = 1.42
	var collision := CollisionShape3D.new()
	collision.shape = body_shape
	collision.position.y = 0.82
	add_child(collision)

	var capsule := CapsuleMesh.new()
	capsule.radius = 0.26
	capsule.height = 1.18
	capsule.radial_segments = 16
	capsule.rings = 6
	body_mesh = MeshInstance3D.new()
	body_mesh.name = "BodyProxy"
	body_mesh.mesh = capsule
	body_mesh.position.y = 0.86
	body_mesh.visible = show_debug_proxy
	body_mesh.material_override = _make_material(Color(0.18, 0.48, 0.95) if action_prefix == "p1" else Color(0.95, 0.22, 0.18))
	add_child(body_mesh)

	hurtbox_area = Area3D.new()
	hurtbox_area.name = "Hurtbox"
	var hurt_shape := CollisionShape3D.new()
	var hurt_box := BoxShape3D.new()
	hurt_box.size = Vector3(0.62, 1.55, 0.5)
	hurt_shape.shape = hurt_box
	hurt_shape.position.y = 0.84
	hurtbox_area.add_child(hurt_shape)
	add_child(hurtbox_area)

	hitbox_area = Area3D.new()
	hitbox_area.name = "Hitbox"
	hitbox_area.monitoring = false
	hitbox_area.visible = false
	var hit_shape := CollisionShape3D.new()
	var hit_box := BoxShape3D.new()
	hit_box.size = Vector3(0.72, 0.45, 0.5)
	hit_shape.shape = hit_box
	hit_shape.position = Vector3(0.52, 1.0, 0.0)
	hitbox_area.add_child(hit_shape)
	add_child(hitbox_area)

	attack_effect = MeshInstance3D.new()
	attack_effect.name = "AttackEffect"
	attack_effect.visible = false
	add_child(attack_effect)

	impact_flash = MeshInstance3D.new()
	impact_flash.name = "ImpactFlash"
	var flash_mesh := SphereMesh.new()
	flash_mesh.radius = 0.58
	flash_mesh.height = 1.16
	impact_flash.mesh = flash_mesh
	impact_flash.position = Vector3(0.0, 0.92, 0.02)
	impact_flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	impact_flash.visible = false
	add_child(impact_flash)

	block_shield = MeshInstance3D.new()
	block_shield.name = "BlockShield"
	block_shield.mesh = _make_hex_shield_mesh(0.66, 0.78, false)
	block_shield.position = Vector3(0.0, 1.12, 0.09)
	block_shield.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	block_shield.visible = false
	add_child(block_shield)

	block_shield_ring = MeshInstance3D.new()
	block_shield_ring.name = "BlockShieldRing"
	block_shield_ring.mesh = _make_hex_shield_mesh(0.83, 0.94, true)
	block_shield_ring.position = Vector3(0.0, 1.12, 0.085)
	block_shield_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	block_shield_ring.visible = false
	add_child(block_shield_ring)

	var bar_mesh := BoxMesh.new()
	bar_mesh.size = Vector3(1.42, 0.08, 0.045)
	block_shield_bar_a = MeshInstance3D.new()
	block_shield_bar_a.name = "BlockShieldBarA"
	block_shield_bar_a.mesh = bar_mesh
	block_shield_bar_a.position = Vector3(0.0, 1.12, 0.13)
	block_shield_bar_a.rotation.z = deg_to_rad(32.0)
	block_shield_bar_a.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	block_shield_bar_a.visible = false
	add_child(block_shield_bar_a)

	block_shield_bar_b = MeshInstance3D.new()
	block_shield_bar_b.name = "BlockShieldBarB"
	block_shield_bar_b.mesh = bar_mesh
	block_shield_bar_b.position = Vector3(0.0, 1.12, 0.135)
	block_shield_bar_b.rotation.z = deg_to_rad(-32.0)
	block_shield_bar_b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	block_shield_bar_b.visible = false
	add_child(block_shield_bar_b)

	block_guard_label = Label3D.new()
	block_guard_label.name = "GuardLabel"
	block_guard_label.text = "GUARD"
	block_guard_label.position = Vector3(0.0, 1.92, 0.14)
	block_guard_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	block_guard_label.pixel_size = 0.014
	block_guard_label.modulate = Color(0.92, 0.98, 1.0, 1.0)
	block_guard_label.outline_modulate = Color(0.05, 0.45, 1.0, 1.0)
	block_guard_label.outline_size = 10
	block_guard_label.visible = false
	add_child(block_guard_label)

	state_label = Label3D.new()
	state_label.name = "StateLabel"
	state_label.position = Vector3(0.0, 1.9, 0.0)
	state_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	state_label.pixel_size = 0.015
	state_label.visible = show_debug_proxy
	add_child(state_label)


func _update_debug_visuals() -> void:
	if body_mesh == null:
		return

	body_mesh.visible = show_debug_proxy
	if not show_debug_proxy:
		if hitbox_area != null:
			hitbox_area.position.x = 0.0
			hitbox_area.scale.x = 1.0 if facing_right else -1.0
		if state_label != null:
			state_label.visible = false
		return

	var color := Color(0.18, 0.48, 0.95) if action_prefix == "p1" else Color(0.95, 0.22, 0.18)
	if state == FighterState.ATTACK:
		var phase := current_move.phase_at(state_frame) if current_move != null else ""
		if phase == "startup":
			color = Color(1.0, 0.8, 0.18)
		elif phase == "active":
			color = Color(0.2, 1.0, 0.34)
		else:
			color = Color(0.9, 0.36, 0.28)
	elif state == FighterState.HITSTUN:
		color = Color(1.0, 1.0, 1.0)
	elif state == FighterState.BLOCK:
		color = Color(0.25, 0.58, 1.0)
	elif state == FighterState.KNOCKDOWN:
		color = Color(0.5, 0.5, 0.55)
	elif state == FighterState.CROUCH:
		color = color.darkened(0.25)

	body_mesh.material_override = _make_material(color)
	if state == FighterState.KNOCKDOWN:
		body_mesh.scale = Vector3(1.28, 0.34, 1.08)
	elif state == FighterState.CROUCH:
		body_mesh.scale = Vector3(1.08, 0.76, 1.08)
	else:
		body_mesh.scale = Vector3.ONE

	if hitbox_area != null:
		hitbox_area.position.x = 0.0
		hitbox_area.scale.x = 1.0 if facing_right else -1.0

	if state_label != null:
		state_label.visible = show_debug_proxy
		state_label.text = "%s\n%s\nHP %d M %d" % [character_name, state_name(), health, meter]


func _update_visual_state() -> void:
	if not use_fbx_visual or state == FighterState.ATTACK:
		return

	if visual_state_override_frames > 0 and not visual_state_override_key.is_empty():
		_set_visual(visual_state_override_key)
		visual_state_override_frames -= 1
	elif state == FighterState.KNOCKDOWN:
		_update_knockdown_visual_state()
	elif state == FighterState.HITSTUN:
		_set_visual(hitstun_visual_key)
	elif state == FighterState.CROUCH:
		_set_visual("crouch" if visual_scene_paths.has("crouch") else "idle")
	elif state == FighterState.BLOCK and last_direction in [1, 2, 3]:
		_set_visual("crouch" if visual_scene_paths.has("crouch") else "idle")
	elif not is_on_floor() or state in [FighterState.JUMP, FighterState.JUMP_START]:
		_set_visual("jump")
	elif absf(velocity.x) > 0.08:
		_set_visual("walk" if visual_scene_paths.has("walk") else "run")
	else:
		_set_visual("idle")


func _update_knockdown_visual_state() -> void:
	var remaining_frames := -state_frame
	if _has_visual_scene("getup") and remaining_frames <= KNOCKDOWN_GETUP_VISUAL_FRAMES:
		var changed := visual_key != "getup"
		if changed or visual_model == null:
			_set_visual("getup")
		if changed:
			_play_visual_animation_fit_frames(maxi(1, remaining_frames))
		return

	if _has_visual_scene(knockdown_visual_key):
		var changed := visual_key != knockdown_visual_key
		if changed or visual_model == null:
			_set_visual(knockdown_visual_key)
		if changed:
			_play_visual_animation_fit_frames(KNOCKDOWN_FALL_VISUAL_FRAMES)
		if knockdown_total_frames + state_frame >= KNOCKDOWN_FALL_VISUAL_FRAMES:
			_hold_visual_animation_last_frame()
	else:
		_set_visual("idle")
		_apply_knockdown_visual_pose()


func _set_visual_for_move(move: MoveDefinition) -> void:
	if not use_fbx_visual:
		return

	var move_animation_key := String(move.animation_key)
	var key := move_animation_key if visual_scene_paths.has(move_animation_key) else String(MOVE_VISUALS.get(move_animation_key, "punch"))
	if state == FighterState.CROUCH or last_direction in [1, 2, 3]:
		if move_animation_key in ["anim_light_punch", "anim_heavy_punch"] and visual_scene_paths.has("crouch_punch"):
			key = "crouch_punch"
		elif move_animation_key in ["anim_light_kick", "anim_heavy_kick", "anim_crouch_kick"] and visual_scene_paths.has("crouch_kick"):
			key = "crouch_kick"
	if should_trigger_cinematic(move):
		key = "punch"
	_set_visual(key)
	_play_visual_animation_fit_frames(move.total_frames())


func _set_visual(key: String) -> void:
	if visual_key == key and visual_model != null and visual_animation_player != null and visual_animation_player.is_playing():
		return

	if not _ensure_base_visual():
		return

	var animation_name := _ensure_visual_animation(key)
	if animation_name.is_empty():
		return

	visual_key = key
	_apply_visual_facing()
	_play_visual_animation(animation_name, key in ["idle", "walk", "run", "jump", "crouch"])


func _ensure_base_visual() -> bool:
	if visual_model != null and visual_animation_player != null:
		return true

	var packed_scene := ResourceLoader.load(base_visual_scene) as PackedScene
	if packed_scene == null:
		return false
	visual_model = packed_scene.instantiate() as Node3D
	if visual_model == null:
		return false

	visual_model.name = "FbxVisual"
	add_child(visual_model)
	_normalize_visual(visual_model)
	_apply_visual_facing()
	_apply_visual_materials(visual_model)
	visual_animation_player = _find_animation_player(visual_model)
	if visual_animation_player == null:
		visual_animation_player = AnimationPlayer.new()
		visual_animation_player.name = "FallbackAnimationPlayer"
		visual_model.add_child(visual_animation_player)
		_add_visual_animation("base", Animation.new())
		visual_cache["base"] = "base"
	else:
		_register_existing_base_animation("base")
	return true


func _ensure_visual_animation(key: String) -> String:
	if visual_cache.has(key):
		return String(visual_cache[key])
	var embedded_animation := _embedded_animation_name_for_key(key)
	if not embedded_animation.is_empty():
		visual_cache[key] = embedded_animation
		return embedded_animation

	var fallback_scene := String(visual_scene_paths.get("idle", DEFAULT_VISUAL_SCENES["idle"]))
	var scene_path := String(visual_scene_paths.get(key, fallback_scene))
	var packed_scene := ResourceLoader.load(scene_path) as PackedScene
	if packed_scene == null:
		return String(visual_cache.get("base", ""))

	var source_model := packed_scene.instantiate() as Node3D
	if source_model == null:
		return String(visual_cache.get("base", ""))

	var source_player := _find_animation_player(source_model)
	var animation_name := ""
	if source_player != null:
		var source_names := source_player.get_animation_list()
		if not source_names.is_empty():
			var source_animation_name := _source_animation_name_for_key(key, source_player)
			var source_animation := source_player.get_animation(source_animation_name)
			if source_animation != null:
				animation_name = key
				var copied_animation := source_animation.duplicate(true) as Animation
				_retarget_visual_animation(copied_animation, source_model)
				_add_visual_animation(animation_name, copied_animation)
				visual_cache[key] = animation_name
	source_model.free()

	if animation_name.is_empty():
		return String(visual_cache.get("base", ""))
	return animation_name


func _embedded_animation_name_for_key(key: String) -> String:
	if visual_animation_player == null:
		return ""
	if visual_scene_paths.has(key):
		return ""
	var requested_name := String(visual_animation_names.get(key, ""))
	if not requested_name.is_empty() and visual_animation_player.has_animation(requested_name):
		return requested_name
	if visual_animation_player.has_animation(key):
		return key
	return ""


func _source_animation_name_for_key(key: String, source_player: AnimationPlayer) -> String:
	var requested_name := String(visual_animation_names.get(key, ""))
	if not requested_name.is_empty() and source_player.has_animation(requested_name):
		return requested_name
	if source_player.has_animation(key):
		return key
	var source_names := source_player.get_animation_list()
	return String(source_names[0]) if not source_names.is_empty() else ""


func _retarget_visual_animation(animation: Animation, source_model: Node3D) -> void:
	if animation == null or visual_model == null:
		return

	var skeleton := _find_skeleton(visual_model)
	if skeleton == null:
		return

	var target_skeleton_path := str(visual_model.get_path_to(skeleton))
	if target_skeleton_path.is_empty():
		return

	var source_root_rest := Quaternion.IDENTITY
	var source_skeleton := _find_skeleton(source_model)
	var source_skeleton_path := ""
	var source_hips_rest := Transform3D.IDENTITY
	var target_hips_rest := Transform3D.IDENTITY
	var has_hips_rest_pair := false
	if source_skeleton != null:
		source_skeleton_path = str(source_model.get_path_to(source_skeleton))
		var source_root_index := source_skeleton.find_bone("root")
		if source_root_index >= 0:
			source_root_rest = source_skeleton.get_bone_rest(source_root_index).basis.get_rotation_quaternion()
		var source_hips_index := source_skeleton.find_bone("Hips")
		var target_hips_index := skeleton.find_bone("Hips")
		if source_hips_index >= 0 and target_hips_index >= 0:
			source_hips_rest = source_skeleton.get_bone_rest(source_hips_index)
			target_hips_rest = skeleton.get_bone_rest(target_hips_index)
			has_hips_rest_pair = true
	var root_rotation_correction := source_root_rest.inverse()
	var hips_basis_correction := Basis.IDENTITY
	if has_hips_rest_pair:
		hips_basis_correction = target_hips_rest.basis * source_hips_rest.basis.inverse()

	for track_index in range(animation.get_track_count() - 1, -1, -1):
		var path_text := str(animation.track_get_path(track_index))
		var track_type := animation.track_get_type(track_index)
		var bone_path := _animation_bone_path_suffix(path_text, source_skeleton_path)
		if bone_path.is_empty():
			continue
		if bone_path == ":root" and track_type == Animation.TYPE_POSITION_3D:
			animation.remove_track(track_index)
			continue
		if bone_path == ":root" and track_type == Animation.TYPE_ROTATION_3D:
			for key_index in range(animation.track_get_key_count(track_index)):
				var key_value: Variant = animation.track_get_key_value(track_index, key_index)
				if key_value is Quaternion:
					animation.track_set_key_value(track_index, key_index, root_rotation_correction * (key_value as Quaternion))
		if has_hips_rest_pair and bone_path == ":Hips":
			if track_type == Animation.TYPE_POSITION_3D:
				for key_index in range(animation.track_get_key_count(track_index)):
					var key_value: Variant = animation.track_get_key_value(track_index, key_index)
					if key_value is Vector3:
						var source_position := key_value as Vector3
						animation.track_set_key_value(
							track_index,
							key_index,
							target_hips_rest.origin + hips_basis_correction * (source_position - source_hips_rest.origin)
						)
			elif track_type == Animation.TYPE_ROTATION_3D:
				var hips_rotation_correction := target_hips_rest.basis.get_rotation_quaternion() * source_hips_rest.basis.get_rotation_quaternion().inverse()
				for key_index in range(animation.track_get_key_count(track_index)):
					var key_value: Variant = animation.track_get_key_value(track_index, key_index)
					if key_value is Quaternion:
						animation.track_set_key_value(track_index, key_index, hips_rotation_correction * (key_value as Quaternion))
		animation.track_set_path(track_index, NodePath(target_skeleton_path + bone_path))


func _animation_bone_path_suffix(path_text: String, source_skeleton_path: String) -> String:
	if not path_text.contains(":"):
		return ""
	if not source_skeleton_path.is_empty() and path_text.begins_with(source_skeleton_path + ":"):
		return path_text.substr(source_skeleton_path.length())
	var skeleton_marker := "Skeleton3D:"
	var marker_index := path_text.find(skeleton_marker)
	if marker_index >= 0:
		return path_text.substr(marker_index + "Skeleton3D".length())
	return ""


func _register_existing_base_animation(key: String) -> void:
	if visual_animation_player == null or visual_cache.has(key):
		return

	var animation_names := visual_animation_player.get_animation_list()
	if animation_names.is_empty():
		return
	visual_cache[key] = String(animation_names[0])


func _add_visual_animation(animation_name: String, animation: Animation) -> void:
	if visual_animation_player == null or animation == null:
		return

	var library := visual_animation_player.get_animation_library("")
	if library == null:
		library = AnimationLibrary.new()
		visual_animation_player.add_animation_library("", library)
	if library.has_animation(animation_name):
		library.remove_animation(animation_name)
	library.add_animation(animation_name, animation)


func _play_first_visual_animation() -> void:
	if visual_animation_player == null:
		return

	var animation_names := visual_animation_player.get_animation_list()
	if animation_names.is_empty():
		return

	var animation_name := String(animation_names[0])
	var animation := visual_animation_player.get_animation(animation_name)
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR
	visual_animation_player.stop()
	visual_animation_player.play(animation_name)


func _play_visual_animation(animation_name: String, should_loop: bool) -> void:
	if visual_animation_player == null or animation_name.is_empty():
		return

	var animation := visual_animation_player.get_animation(animation_name)
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR if should_loop else Animation.LOOP_NONE
	visual_animation_player.stop()
	visual_animation_player.play(animation_name)


func _hold_visual_animation_last_frame() -> void:
	if visual_animation_player == null:
		return
	var animation_name := String(visual_cache.get(visual_key, ""))
	if animation_name.is_empty():
		return
	var animation := visual_animation_player.get_animation(animation_name)
	if animation == null or animation.length <= 0.001:
		return
	animation.loop_mode = Animation.LOOP_NONE
	visual_animation_player.stop()
	visual_animation_player.seek(maxf(animation.length - 0.001, 0.0), true)
	visual_animation_player.advance(0.0)


func _apply_visual_facing() -> void:
	if visual_model == null:
		return
	var side_angle := current_visual_facing_degrees()
	visual_model.rotation_degrees = Vector3(0.0, side_angle, _knockdown_visual_tilt_degrees())
	visual_model.scale.x = absf(visual_model.scale.x)


func _knockdown_visual_tilt_degrees() -> float:
	if state != FighterState.KNOCKDOWN:
		return 0.0
	if _has_animated_knockdown_visuals():
		return 0.0
	var elapsed := clampf(float(knockdown_total_frames + state_frame), 0.0, 42.0)
	var fall_t := smoothstep(0.0, 1.0, elapsed / 42.0)
	var side := -1.0 if facing_right else 1.0
	return side * lerpf(0.0, 82.0, fall_t)


func _has_animated_knockdown_visuals() -> bool:
	return _has_visual_scene("knockdown") or _has_visual_scene("crouch_knockdown") or _has_visual_scene("getup")


func _has_visual_scene(key: String) -> bool:
	return visual_scene_paths.has(key) and not String(visual_scene_paths.get(key, "")).is_empty()


func _apply_knockdown_visual_pose() -> void:
	if visual_model == null:
		return
	_apply_visual_facing()


func _play_visual_animation_fit_frames(frame_count: int) -> void:
	if visual_animation_player == null:
		return

	var animation_name := String(visual_cache.get(visual_key, ""))
	if animation_name.is_empty():
		return

	var animation := visual_animation_player.get_animation(animation_name)
	if animation == null or animation.length <= 0.001:
		visual_animation_player.play(animation_name)
		return

	var target_seconds := maxf(float(frame_count) / 60.0, 0.05)
	var speed_scale := clampf(animation.length / target_seconds, 0.25, 8.0)
	animation.loop_mode = Animation.LOOP_NONE
	visual_animation_player.stop()
	visual_animation_player.play(animation_name, -1.0, speed_scale)


func _apply_visual_materials(root: Node) -> void:
	var stack: Array[Node] = [root]
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
					var texture_path := _texture_for_surface(mesh_instance.name, material_name, surface_index)
					if texture_path.is_empty():
						if source_material == null or _should_replace_plain_visual_material(source_material):
							mesh_instance.set_surface_override_material(surface_index, _make_fallback_visual_material())
						continue
					var texture := _load_visual_texture(texture_path)
					if texture != null:
						mesh_instance.set_surface_override_material(surface_index, _make_visual_material(texture))
					elif source_material == null:
						mesh_instance.set_surface_override_material(surface_index, _make_fallback_visual_material())
		for child in node.get_children():
			stack.append(child)


func _texture_for_material(material_name: String) -> String:
	var lower_name := material_name.to_lower()
	if lower_name == "body" or lower_name.contains("bdy"):
		return _texture_path_for_slot("body")
	if lower_name == "eyes" or lower_name.contains("eye"):
		return _texture_path_for_slot("eye")
	if lower_name.contains("hair"):
		return _texture_path_for_slot("hair")
	if lower_name.contains("head"):
		return _texture_path_for_slot("head")
	if lower_name.contains("outfit") or lower_name.contains("cloth") or lower_name.contains("costume") or lower_name.contains("jacket"):
		return _texture_path_for_slot("outfit")
	if lower_name.contains("tail"):
		return _texture_path_for_slot("tail")
	if lower_name.contains("face_001"):
		return _texture_path_for_slot("face_detail")
	if lower_name.contains("mayu"):
		return _texture_path_for_slot("mayu")
	if lower_name.contains("face"):
		return _texture_path_for_slot("face")
	return ""


func _texture_for_surface(mesh_name: String, material_name: String, surface_index: int) -> String:
	var texture_path := _texture_for_material(material_name)
	if not texture_path.is_empty():
		return texture_path
	texture_path = _texture_path_for_slot("default")
	if not texture_path.is_empty():
		return texture_path
	texture_path = _texture_path_for_slot("albedo")
	if not texture_path.is_empty():
		return texture_path
	texture_path = _texture_for_material(mesh_name)
	if not texture_path.is_empty() and mesh_name.to_lower() != "body":
		return texture_path
	if mesh_name.to_lower() == "body":
		match surface_index:
			0:
				return _texture_path_for_slot("head")
			1:
				return _texture_path_for_slot("body")
			2:
				return _texture_path_for_slot("eye")
	return texture_path


func _texture_path_for_slot(slot: String) -> String:
	return String(visual_texture_paths.get(slot, ""))


func _should_replace_plain_visual_material(material: Material) -> bool:
	if not visual_texture_paths.has("_fallback_color"):
		return false
	if not material is StandardMaterial3D:
		return false
	var standard := material as StandardMaterial3D
	if standard.albedo_texture != null:
		return false
	var color := standard.albedo_color
	var white_delta := absf(color.r - 1.0) + absf(color.g - 1.0) + absf(color.b - 1.0)
	return white_delta < 0.35


func _make_visual_material(texture: Texture2D) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.albedo_color = Color.WHITE
	material.roughness = 0.9
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL if _has_visual_pbr_textures() else BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	_apply_optional_visual_pbr_textures(material)
	return material


func _has_visual_pbr_textures() -> bool:
	return visual_texture_paths.has("normal") or visual_texture_paths.has("metallic") or visual_texture_paths.has("roughness") or visual_texture_paths.has("orm")


func _apply_optional_visual_pbr_textures(material: StandardMaterial3D) -> void:
	var normal_texture := _load_visual_texture_slot("normal")
	if normal_texture != null and _has_object_property(material, "normal_texture"):
		material.set("normal_texture", normal_texture)
		if _has_object_property(material, "normal_enabled"):
			material.set("normal_enabled", true)

	var roughness_texture := _load_visual_texture_slot("roughness")
	if roughness_texture != null and _has_object_property(material, "roughness_texture"):
		material.set("roughness_texture", roughness_texture)

	var metallic_texture := _load_visual_texture_slot("metallic")
	if metallic_texture != null and _has_object_property(material, "metallic_texture"):
		material.set("metallic_texture", metallic_texture)
		material.metallic = 1.0

	var orm_texture := _load_visual_texture_slot("orm")
	if orm_texture != null and _has_object_property(material, "orm_texture"):
		material.set("orm_texture", orm_texture)


func _load_visual_texture_slot(slot: String) -> Texture2D:
	var texture_path := _texture_path_for_slot(slot)
	if texture_path.is_empty():
		return null
	return _load_visual_texture(texture_path)


func _load_visual_texture(texture_path: String) -> Texture2D:
	if ResourceLoader.exists(texture_path):
		var texture := ResourceLoader.load(texture_path) as Texture2D
		if texture != null:
			return texture
	var image := Image.new()
	if image.load(ProjectSettings.globalize_path(texture_path)) != OK:
		return null
	return ImageTexture.create_from_image(image)


func _has_object_property(object: Object, property_name: String) -> bool:
	for property in object.get_property_list():
		if String(property.get("name", "")) == property_name:
			return true
	return false


func _make_fallback_visual_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = visual_fallback_color
	material.roughness = 0.9
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer

	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found

	return null


func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D

	for child in node.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found

	return null


func _normalize_visual(model: Node3D) -> void:
	model.position = Vector3.ZERO
	model.rotation = Vector3.ZERO

	var bounds := _calculate_visual_bounds(model)
	if bounds.size == Vector3.ZERO:
		model.scale = Vector3.ONE
		return

	var height := bounds.size.y
	if height <= 0.001:
		height = bounds.size.z
		if height <= 0.001:
			model.scale = Vector3.ONE
			return

	var scale_factor := visual_target_height / height
	model.scale = Vector3.ONE * scale_factor
	model.position.y = -bounds.position.y * scale_factor


func _calculate_visual_bounds(root: Node3D) -> AABB:
	var has_bounds := false
	var combined := AABB()
	var stack: Array[Node] = [root]

	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D:
			var mesh_instance := node as MeshInstance3D
			var mesh_aabb := mesh_instance.get_aabb()
			var local_transform := _get_transform_relative_to_root(mesh_instance, root)
			var local_aabb := local_transform * mesh_aabb
			if not has_bounds:
				combined = local_aabb
				has_bounds = true
			else:
				combined = combined.merge(local_aabb)

		for child in node.get_children():
			stack.append(child)

	return combined if has_bounds else AABB()


func _get_transform_relative_to_root(node: Node3D, root: Node3D) -> Transform3D:
	var result := Transform3D.IDENTITY
	var current: Node = node
	while current != null and current != root:
		if current is Node3D:
			result = (current as Node3D).transform * result
		current = current.get_parent()
	return result


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.55
	return material


func _prepare_attack_effect(move: MoveDefinition) -> void:
	if attack_effect == null:
		return

	match move.effect_style:
		"pillar":
			var pillar := attack_effect.mesh as CylinderMesh
			if pillar == null:
				pillar = CylinderMesh.new()
				attack_effect.mesh = pillar
			pillar.bottom_radius = maxf(move.projectile_radius * 0.42, 0.14)
			pillar.top_radius = 0.02
			pillar.height = maxf(move.hit_height * 1.2, 1.25)
			pillar.radial_segments = 5
		"slash":
			var slash := attack_effect.mesh as BoxMesh
			if slash == null:
				slash = BoxMesh.new()
				attack_effect.mesh = slash
			slash.size = Vector3(maxf(move.hit_range * 0.12, 0.08), maxf(move.hit_height * 1.1, 0.85), 0.045)
		"ground_wave":
			var wave := attack_effect.mesh as SphereMesh
			if wave == null:
				wave = SphereMesh.new()
				attack_effect.mesh = wave
			wave.radius = maxf(move.projectile_radius * 1.05, 0.22)
			wave.height = wave.radius * 2.0
		_:
			var sphere := attack_effect.mesh as SphereMesh
			if sphere == null:
				sphere = SphereMesh.new()
				attack_effect.mesh = sphere
			var orb_radius := maxf(move.projectile_radius * 1.15, 0.24) if move.projectile_enabled else 0.22
			sphere.radius = orb_radius
			sphere.height = orb_radius * 2.0
	attack_effect.material_override = _make_attack_effect_material(move)
	_update_attack_effect("startup")


func _update_attack_effect(phase: String) -> void:
	if attack_effect == null or current_move == null:
		return

	if phase == "done":
		_hide_attack_effect()
		return

	var direction := 1.0 if facing_right else -1.0
	attack_effect.position = _attack_effect_position(current_move, direction)
	if current_move.projectile_enabled:
		var offset_x := _effect_offset_x(current_move)
		attack_effect.position = Vector3(direction * offset_x, _projectile_spawn_y(current_move), -0.02)
	if current_move.effect_style == "slash":
		attack_effect.position = Vector3(direction * current_move.hit_range * 0.55, SLASH_EFFECT_Y, -0.02)
		attack_effect.rotation.z = direction * deg_to_rad(38.0)
	elif current_move.effect_style == "pillar":
		attack_effect.position = Vector3(direction * current_move.hit_range * 0.92, 1.12, -0.02)
		attack_effect.rotation.z = direction * deg_to_rad(-6.0)
	else:
		attack_effect.rotation.z = 0.0
	attack_effect.scale = _attack_effect_scale(current_move)
	attack_effect.visible = phase in ["startup", "active"]
	if phase == "startup":
		attack_effect.transparency = 0.45
	elif phase == "active":
		attack_effect.transparency = 0.0
	else:
		attack_effect.transparency = 0.65


func _hide_attack_effect() -> void:
	if attack_effect != null:
		attack_effect.visible = false


func _show_impact_flash(move: MoveDefinition, blocked: bool) -> void:
	if impact_flash == null or move == null:
		return
	impact_flash.material_override = _get_impact_flash_material(move, blocked)
	impact_flash.scale = Vector3(1.0, 1.0, 1.0) * (0.76 if blocked else 1.0)
	impact_flash.visible = true
	impact_flash_frames = 10 if blocked else 16


func _tick_impact_flash() -> void:
	if impact_flash == null or impact_flash_frames <= 0:
		return
	impact_flash_frames -= 1
	var t := float(impact_flash_frames) / 16.0
	impact_flash.scale = Vector3.ONE * maxf(0.2, 0.72 + (1.0 - t) * 0.42)
	impact_flash.transparency = clampf(1.0 - t, 0.0, 0.88)
	if impact_flash_frames <= 0:
		impact_flash.visible = false


func _show_block_shield(move: MoveDefinition, attacker: FighterController) -> void:
	if block_shield == null or block_shield_ring == null:
		return
	block_shield.material_override = _get_block_shield_material(Color(0.08, 0.52, 1.0, 0.78), 2.3)
	block_shield_ring.material_override = _get_block_shield_material(Color(0.9, 1.0, 1.0, 1.0), 3.2)
	var bar_material := _get_block_shield_material(Color(1.0, 0.82, 0.18, 1.0), 3.4)
	if block_shield_bar_a != null:
		block_shield_bar_a.material_override = bar_material
	if block_shield_bar_b != null:
		block_shield_bar_b.material_override = bar_material
	var x_offset := 0.0
	if attacker != null and is_instance_valid(attacker):
		x_offset = 0.32 * (-1.0 if attacker.global_position.x < global_position.x else 1.0)
	block_shield.position = Vector3(x_offset, 1.2, 0.14)
	block_shield_ring.position = Vector3(x_offset, 1.2, 0.135)
	if block_shield_bar_a != null:
		block_shield_bar_a.position = Vector3(x_offset, 1.2, 0.16)
		block_shield_bar_a.rotation.z = deg_to_rad(32.0)
		block_shield_bar_a.visible = true
	if block_shield_bar_b != null:
		block_shield_bar_b.position = Vector3(x_offset, 1.2, 0.165)
		block_shield_bar_b.rotation.z = deg_to_rad(-32.0)
		block_shield_bar_b.visible = true
	if block_guard_label != null:
		block_guard_label.position = Vector3(x_offset, 1.96, 0.18)
		block_guard_label.visible = true
	block_shield.rotation = Vector3.ZERO
	block_shield_ring.rotation = Vector3.ZERO
	block_shield.scale = Vector3(1.28, 1.38, 1.0)
	block_shield_ring.scale = Vector3(1.2, 1.3, 1.0)
	block_shield.transparency = 0.0
	block_shield_ring.transparency = 0.0
	block_shield.visible = true
	block_shield_ring.visible = true
	block_shield_frames = BLOCK_SHIELD_FRAMES


func _tick_block_shield() -> void:
	if block_shield == null or block_shield_frames <= 0:
		return
	block_shield_frames -= 1
	var normalized := float(block_shield_frames) / float(BLOCK_SHIELD_FRAMES)
	var pop := 1.0 + (1.0 - normalized) * 0.42
	var fade := clampf(1.0 - normalized, 0.0, 1.0)
	block_shield.scale = Vector3(1.24, 1.36, 1.0) * (0.94 + pop * 0.16)
	block_shield_ring.scale = Vector3(1.16, 1.28, 1.0) * (1.08 + pop * 0.22)
	block_shield_ring.rotation.z += 0.14
	block_shield.transparency = clampf(fade * 0.48, 0.0, 0.72)
	block_shield_ring.transparency = clampf(fade * 0.5, 0.0, 0.76)
	if block_shield_bar_a != null:
		block_shield_bar_a.scale = Vector3.ONE * (1.0 + (1.0 - normalized) * 0.26)
		block_shield_bar_a.transparency = clampf(fade * 0.42, 0.0, 0.72)
	if block_shield_bar_b != null:
		block_shield_bar_b.scale = Vector3.ONE * (1.0 + (1.0 - normalized) * 0.26)
		block_shield_bar_b.transparency = clampf(fade * 0.42, 0.0, 0.72)
	if block_guard_label != null:
		block_guard_label.modulate.a = clampf(normalized + 0.16, 0.0, 1.0)
	if block_shield_frames <= 0:
		_hide_block_shield()


func _hide_block_shield() -> void:
	if block_shield != null:
		block_shield.visible = false
	if block_shield_ring != null:
		block_shield_ring.visible = false
	if block_shield_bar_a != null:
		block_shield_bar_a.visible = false
	if block_shield_bar_b != null:
		block_shield_bar_b.visible = false
	if block_guard_label != null:
		block_guard_label.visible = false
		block_guard_label.modulate.a = 1.0


func _get_block_shield_material(color: Color, glow_strength: float) -> StandardMaterial3D:
	var key := "hex:%s:%.2f" % [color.to_html(), glow_strength]
	if block_shield_material_cache.has(key):
		return block_shield_material_cache[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b)
	material.emission_energy_multiplier = glow_strength
	block_shield_material_cache[key] = material
	return material


func _make_hex_shield_mesh(width: float, height: float, outline: bool) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var outer := PackedVector2Array([
		Vector2(0.0, -height),
		Vector2(width * 0.86, -height * 0.48),
		Vector2(width * 0.86, height * 0.48),
		Vector2(0.0, height),
		Vector2(-width * 0.86, height * 0.48),
		Vector2(-width * 0.86, -height * 0.48),
	])
	if outline:
		var inner := PackedVector2Array()
		for point in outer:
			inner.append(point * 0.76)
		for point in outer:
			vertices.append(Vector3(point.x, point.y, 0.0))
		for point in inner:
			vertices.append(Vector3(point.x, point.y, 0.0))
		for i in range(6):
			var next := (i + 1) % 6
			indices.append_array(PackedInt32Array([i, next, 6 + next, i, 6 + next, 6 + i]))
	else:
		vertices.append(Vector3.ZERO)
		for point in outer:
			vertices.append(Vector3(point.x, point.y, 0.0))
		for i in range(6):
			indices.append_array(PackedInt32Array([0, 1 + i, 1 + ((i + 1) % 6)]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _make_attack_effect_material(move: MoveDefinition) -> Material:
	if attack_effect_material_cache.has(move.id):
		return attack_effect_material_cache[move.id] as Material

	var material := _make_procedural_vfx_material(_effect_tint(move), _attack_effect_glow(move))
	if move.move_type == MoveDefinition.MoveType.SUPER:
		material.albedo_color = _effect_tint(move, Color(1.0, 0.84, 0.18, 0.52))
	elif move.id == "236236J":
		material.albedo_color = _effect_tint(move, Color(0.25, 0.72, 1.0, 0.45))
	attack_effect_material_cache[move.id] = material
	return material


func _uses_procedural_orb_effect(move: MoveDefinition) -> bool:
	return move != null and move.projectile_enabled and move.effect_style == "projectile"


func _attack_effect_glow(move: MoveDefinition) -> float:
	if move == null:
		return 1.25
	match move.effect_style:
		"slash":
			return 1.7
		"pillar":
			return 1.45
		"ground_wave":
			return 1.35
	return 1.45


func _make_procedural_vfx_material(color: Color, glow_strength: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	var tint := color
	if tint.a <= 0.0:
		tint = Color(0.35, 0.88, 1.0, 0.78)
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


func _effect_tint(move: MoveDefinition, fallback := Color.WHITE) -> Color:
	if move != null and move.effect_color.a > 0.0:
		return move.effect_color
	return fallback


func _effect_offset_x(move: MoveDefinition) -> float:
	if move == null or move.effect_offset_x <= 0.0:
		return 0.62
	return move.effect_offset_x


func _projectile_spawn_y(move: MoveDefinition) -> float:
	if move == null:
		return STANDING_PROJECTILE_SPAWN_Y
	if move.projectile_ground_hug or move.effect_spawn_mode in ["owner_ground", "target_ground"]:
		return move.projectile_height
	if not is_on_floor() or move.air_only:
		return move.projectile_height
	return maxf(move.projectile_height, STANDING_PROJECTILE_SPAWN_Y)


func _attack_effect_size(move: MoveDefinition) -> Vector2:
	if move == null:
		return Vector2(0.62, 0.62)
	var height := maxf(move.hit_height, 0.35)
	match move.effect_style:
		"slash":
			return Vector2(maxf(move.hit_range, 0.85), maxf(height, 0.48)) * move.effect_scale
		"pillar":
			return Vector2(maxf(move.hit_range, 0.44), maxf(height, 1.35)) * move.effect_scale
		"ground_wave":
			return Vector2(maxf(move.hit_range, 0.95), maxf(height * 0.55, 0.28)) * move.effect_scale
	if move.projectile_enabled:
		return Vector2(maxf(move.projectile_radius * 2.6, 0.42), maxf(move.projectile_radius * 2.6, 0.42)) * move.effect_scale
	return Vector2(maxf(move.hit_range, 0.6), height) * move.effect_scale


func _attack_effect_scale(move: MoveDefinition) -> Vector3:
	if move == null:
		return Vector3.ONE
	match move.effect_style:
		"slash":
			return Vector3(move.effect_scale.x, move.effect_scale.y, 1.0)
		"ground_wave":
			return Vector3(maxf(move.effect_scale.x * 1.85, 0.9), maxf(move.effect_scale.y * 0.32, 0.16), 0.18)
		"pillar":
			return Vector3(maxf(move.effect_scale.x, 0.85), maxf(move.effect_scale.y, 0.95), 1.0)
	return Vector3.ONE * maxf(move.effect_scale.x, 1.0)


func _attack_effect_position(move: MoveDefinition, direction: float) -> Vector3:
	if move == null:
		return Vector3.ZERO
	var y := STANDING_ATTACK_EFFECT_Y
	if move.attack_level == MoveDefinition.AttackLevel.LOW or move.animation_key == "anim_crouch_kick":
		y = LOW_ATTACK_EFFECT_Y
	elif move.animation_key in ["anim_light_kick", "anim_heavy_kick"]:
		y = STANDING_KICK_EFFECT_Y
	elif move.move_type == MoveDefinition.MoveType.THROW:
		y = THROW_EFFECT_Y
	return Vector3(direction * move.hit_range * 0.52, y, -0.02)


func _get_impact_flash_material(move: MoveDefinition, blocked: bool) -> StandardMaterial3D:
	var key := "%s:%s" % [move.id, "block" if blocked else "hit"]
	if impact_flash_material_cache.has(key):
		return impact_flash_material_cache[key] as StandardMaterial3D

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var color := move.effect_impact_color
	if color.a <= 0.0:
		color = Color(1.0, 1.0, 1.0, 0.72)
	if blocked:
		color = Color(color.r, color.g, color.b, 0.38)
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b)
	material.emission_energy_multiplier = 1.4 if blocked else 1.9
	impact_flash_material_cache[key] = material
	return material
