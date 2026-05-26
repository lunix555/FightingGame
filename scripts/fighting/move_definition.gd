extends Resource
class_name MoveDefinition

enum MoveType {
	NORMAL,
	COMMAND_NORMAL,
	SPECIAL,
	SUPER,
	THROW,
}

enum AttackLevel {
	MID,
	LOW,
	HIGH,
	THROW,
}

@export var id := ""
@export var display_name := ""
@export var move_type := MoveType.NORMAL
@export var attack_level := AttackLevel.MID
@export var motion := ""
@export var button := ""
@export var startup_frames := 2
@export var active_frames := 3
@export var recovery_frames := 13
@export var hitstun_frames := 14
@export var blockstun_frames := 9
@export var damage := 100
@export var hit_range := 1.15
@export var hit_height := 1.0
@export var hitbox_offset := Vector2.ZERO
@export var hitbox_size := Vector2.ZERO
@export var pushback_on_hit := 0.78
@export var pushback_on_block := 0.46
@export var hitstop_on_hit := 6
@export var hitstop_on_block := 4
@export var launch_velocity := Vector2.ZERO
@export var air_hitstun_frames := 24
@export var throw_range := 0.72
@export var throw_tech_window := 8
@export var cancel_level := -1
@export var meter_cost := 0
@export var chip_damage := 0
@export var meter_gain_on_hit := 8
@export var meter_gain_on_block := 3
@export var knockdown_on_hit := false
@export var knockdown_frames := 45
@export var preserve_launch_on_knockdown := false
@export var cancel_on_hit := true
@export var cancel_on_block := false
@export var air_only := false
@export var ground_only := false
@export var projectile_enabled := false
@export var projectile_speed := 3.2
@export var projectile_vertical_speed := 0.0
@export var projectile_gravity := 0.0
@export var projectile_lifetime_frames := 120
@export var projectile_radius := 0.24
@export var projectile_height := 0.82
@export var projectile_ground_hug := false
@export var projectile_cancelable := true
@export var projectile_clash_level := 0
@export var charge_enabled := false
@export var charge_min_frames := 8
@export var charge_full_frames := 70
@export var charge_max_hold_frames := 130
@export var charge_damage_bonus := 95
@export var charge_radius_bonus := 0.18
@export var charge_speed_bonus := 0.65
@export var effect_style := "projectile"
@export var effect_spawn_mode := "self_front"
@export var effect_texture_path := ""
@export var effect_color := Color(0.28, 1.0, 0.82, 0.72)
@export var effect_impact_color := Color(1.0, 1.0, 1.0, 0.72)
@export var effect_offset_x := 0.62
@export var effect_scale := Vector2(1.0, 1.0)
@export var animation_key := ""
@export var vfx_key := ""
@export var sfx_key := ""
@export var cinematic_enabled := false
@export var cinematic_video_path := ""
@export var cinematic_duration_frames := 180
@export var cinematic_damage := -1


func total_frames() -> int:
	return startup_frames + active_frames + recovery_frames


func phase_at(local_frame: int) -> String:
	if local_frame < startup_frames:
		return "startup"
	if local_frame < startup_frames + active_frames:
		return "active"
	if local_frame < total_frames():
		return "recovery"
	return "done"


func is_active(local_frame: int) -> bool:
	return phase_at(local_frame) == "active"


func command_text() -> String:
	if motion.is_empty():
		return button
	return "%s%s" % [motion, button]
