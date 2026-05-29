extends Node3D

const FighterControllerScript := preload("res://scripts/fighting/fighter_controller.gd")
const FightingProjectileScript := preload("res://scripts/fighting/fighting_projectile.gd")
const MusicManagerScript := preload("res://scripts/music_manager.gd")
const PORTRAIT_TEXTURE := preload("res://assets/textures/1129/5.png")
const UI_TEX_BUTTON := "res://assets/ui/kenney_sci_fi/button_rectangle.png"
const UI_TEX_BUTTON_BORDER := "res://assets/ui/kenney_sci_fi/button_rectangle_depth.png"
const UI_TEX_PANEL := "res://assets/ui/kenney_sci_fi/panel_glass_screws.png"
const UI_TEX_HEALTH := "res://assets/ui/kenney/bar_red.png"
const UI_TEX_METER := "res://assets/ui/kenney/bar_yellow.png"
const UI_TEX_STAR := "res://assets/ui/kenney/star_yellow.png"
const UI_OD_BG := Color(0.025, 0.032, 0.052, 1.0)
const UI_OD_PANEL := Color(0.045, 0.052, 0.078, 0.92)
const UI_OD_LINE := Color(0.23, 0.42, 0.56, 0.78)
const UI_OD_CYAN := Color(0.28, 0.9, 1.0, 1.0)
const UI_OD_RED := Color(0.92, 0.17, 0.11, 1.0)
const UI_OD_ORANGE := Color(1.0, 0.42, 0.08, 1.0)
const UI_OD_CREAM := Color(0.96, 0.86, 0.74, 1.0)
const UI_OD_GOLD := Color(1.0, 0.82, 0.25, 1.0)
const SHOW_DEBUG_HUD := false
const SOUND_PATHS := {
	"H-01a": [
		"res://assets/audio/SFX_H/H-01a_hit_light_chain_01.wav",
		"res://assets/audio/SFX_H/H-01a_hit_light_chain_02.wav",
		"res://assets/audio/SFX_H/H-01a_hit_light_chain_03.wav",
	],
	"H-01b": [
		"res://assets/audio/SFX_H/H-01b_hit_light_coffin_01.wav",
		"res://assets/audio/SFX_H/H-01b_hit_light_coffin_02.wav",
		"res://assets/audio/SFX_H/H-01b_hit_light_coffin_03.wav",
	],
	"H-01c": [
		"res://assets/audio/SFX_H/H-01c_hit_light_book_01.wav",
		"res://assets/audio/SFX_H/H-01c_hit_light_book_02.wav",
		"res://assets/audio/SFX_H/H-01c_hit_light_book_03.wav",
	],
	"hit_light": [
		"res://assets/audio/SFX_H/H-08_hit_punch_common_01.wav",
		"res://assets/audio/SFX_H/H-08_hit_punch_common_02.wav",
		"res://assets/audio/SFX_H/H-08_hit_punch_common_03.wav",
		"res://assets/audio/SFX_H/H-08_hit_punch_common_04.wav",
	],
	"hit_light_chain": [
		"res://assets/audio/SFX_H/H-01a_hit_light_chain_01.wav",
		"res://assets/audio/SFX_H/H-01a_hit_light_chain_02.wav",
		"res://assets/audio/SFX_H/H-01a_hit_light_chain_03.wav",
	],
	"hit_light_coffin": [
		"res://assets/audio/SFX_H/H-01b_hit_light_coffin_01.wav",
		"res://assets/audio/SFX_H/H-01b_hit_light_coffin_02.wav",
		"res://assets/audio/SFX_H/H-01b_hit_light_coffin_03.wav",
	],
	"hit_light_book": [
		"res://assets/audio/SFX_H/H-01c_hit_light_book_01.wav",
		"res://assets/audio/SFX_H/H-01c_hit_light_book_02.wav",
		"res://assets/audio/SFX_H/H-01c_hit_light_book_03.wav",
	],
	"hit_medium": [
		"res://assets/audio/SFX_H/H-08_hit_punch_common_01.wav",
		"res://assets/audio/SFX_H/H-08_hit_punch_common_02.wav",
		"res://assets/audio/SFX_H/H-08_hit_punch_common_03.wav",
		"res://assets/audio/SFX_H/H-08_hit_punch_common_04.wav",
	],
	"hit_heavy": [
		"res://assets/audio/SFX_H/H-08_hit_kick_common_01.wav",
		"res://assets/audio/SFX_H/H-08_hit_kick_common_02.wav",
		"res://assets/audio/SFX_H/H-08_hit_kick_common_03.wav",
		"res://assets/audio/SFX_H/H-08_hit_kick_common_04.wav",
	],
	"H-07a": [
		"res://assets/audio/SFX_H/H-07a_miss_anchor_whoosh_01.wav",
		"res://assets/audio/SFX_H/H-07a_miss_anchor_whoosh_02.wav",
	],
	"H-07b": [
		"res://assets/audio/SFX_H/H-07b_miss_coffin_whoosh_01.wav",
		"res://assets/audio/SFX_H/H-07b_miss_coffin_whoosh_02.wav",
	],
	"H-07c": [
		"res://assets/audio/SFX_H/H-07c_miss_book_whoosh_01.wav",
		"res://assets/audio/SFX_H/H-07c_miss_book_whoosh_02.wav",
	],
	"miss_anchor": [
		"res://assets/audio/SFX_H/H-07a_miss_anchor_whoosh_01.wav",
		"res://assets/audio/SFX_H/H-07a_miss_anchor_whoosh_02.wav",
	],
	"miss_coffin": [
		"res://assets/audio/SFX_H/H-07b_miss_coffin_whoosh_01.wav",
		"res://assets/audio/SFX_H/H-07b_miss_coffin_whoosh_02.wav",
	],
	"miss_book": [
		"res://assets/audio/SFX_H/H-07c_miss_book_whoosh_01.wav",
		"res://assets/audio/SFX_H/H-07c_miss_book_whoosh_02.wav",
	],
	"M-03a": [
		"res://assets/audio/SFX_M/M-03a_jump_generic_01.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_02.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_03.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_04.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_05.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_06.wav",
	],
	"footstep": "res://assets/audio/SFX_M/0019 - VFAFS Boots Concrete - Audio - miss.wav",
	"block": [
		"res://assets/audio/SFX_M/M-Gedang_1.wav",
		"res://assets/audio/SFX_M/M-Gedang_2.wav",
		"res://assets/audio/SFX_M/M-Gedang_3.wav",
		"res://assets/audio/SFX_M/M-Gedang_4.wav",
	],
	"block_success": [
		"res://assets/audio/SFX_M/M-Gedang_1.wav",
		"res://assets/audio/SFX_M/M-Gedang_2.wav",
		"res://assets/audio/SFX_M/M-Gedang_3.wav",
		"res://assets/audio/SFX_M/M-Gedang_4.wav",
	],
	"jump": [
		"res://assets/audio/SFX_M/M-03a_jump_generic_01.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_02.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_03.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_04.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_05.wav",
		"res://assets/audio/SFX_M/M-03a_jump_generic_06.wav",
	],
	"land": "res://assets/audio/kenney_impact/land.ogg",
	"knockdown": "res://assets/audio/kenney_impact/knockdown.ogg",
	"projectile_light": "res://assets/audio/kenney_combat/projectile_light.ogg",
	"projectile_heavy": "res://assets/audio/kenney_combat/projectile_heavy.ogg",
	"projectile_charge": "res://assets/audio/kenney_combat/projectile_charge.ogg",
	"projectile_impact": "res://assets/audio/kenney_combat/projectile_impact.ogg",
	"weila_projectile_fire": [
		"res://assets/audio/SFX_H/WeiLa_ZiDangFashe_1.wav",
		"res://assets/audio/SFX_H/WeiLa_ZiDangFashe_2.wav",
		"res://assets/audio/SFX_H/WeiLa_ZiDangFashe_3.wav",
		"res://assets/audio/SFX_H/WeiLa_ZiDangFashe_4.wav",
	],
	"weila_projectile_hit": [
		"res://assets/audio/SFX_H/WeiLa_ZiDanMingzhong_1.wav",
		"res://assets/audio/SFX_H/WeiLa_ZiDanMingzhong_2.wav",
		"res://assets/audio/SFX_H/WeiLa_ZiDanMingzhong_3.wav",
	],
	"ice": "res://assets/audio/kenney_combat/ice.ogg",
	"slash": "res://assets/audio/kenney_combat/slash.ogg",
	"throw": "res://assets/audio/kenney_combat/throw.ogg",
	"special_1": "res://assets/audio/kenney_combat/projectile_light.ogg",
	"special_2": "res://assets/audio/kenney_combat/projectile_heavy.ogg",
	"super": "res://assets/audio/kenney_combat/projectile_heavy.ogg",
	"U-01": [
		"res://assets/audio/SFX_U/U-01_ui_select_01.wav",
		"res://assets/audio/SFX_U/U-01_ui_select_02.wav",
		"res://assets/audio/SFX_U/U-01_ui_select_03.wav",
	],
	"U-02": [
		"res://assets/audio/SFX_U/U-02_ui_confirm_01.wav",
		"res://assets/audio/SFX_U/U-02_ui_confirm_02.wav",
	],
	"U-04": "res://assets/audio/SFX_U/U-04_ui_round_fight.wav",
	"U-05": "res://assets/audio/SFX_U/U-05_ui_ko_finish.wav",
	"U-07": "res://assets/audio/SFX_U/U-07_ui_fail.wav",
	"ui_select": [
		"res://assets/audio/SFX_U/U-01_ui_select_01.wav",
		"res://assets/audio/SFX_U/U-01_ui_select_02.wav",
		"res://assets/audio/SFX_U/U-01_ui_select_03.wav",
	],
	"ui_confirm": [
		"res://assets/audio/SFX_U/U-02_ui_confirm_01.wav",
		"res://assets/audio/SFX_U/U-02_ui_confirm_02.wav",
	],
	"ui_click": [
		"res://assets/audio/SFX_U/U-02_ui_confirm_01.wav",
		"res://assets/audio/SFX_U/U-02_ui_confirm_02.wav",
	],
	"ui_hover": [
		"res://assets/audio/SFX_U/U-01_ui_select_01.wav",
		"res://assets/audio/SFX_U/U-01_ui_select_02.wav",
		"res://assets/audio/SFX_U/U-01_ui_select_03.wav",
	],
	"ui_switch": [
		"res://assets/audio/SFX_U/U-01_ui_select_01.wav",
		"res://assets/audio/SFX_U/U-01_ui_select_02.wav",
		"res://assets/audio/SFX_U/U-01_ui_select_03.wav",
	],
	"ui_round_fight": "res://assets/audio/SFX_U/U-04_ui_round_fight.wav",
	"ui_ko_finish": "res://assets/audio/SFX_U/U-05_ui_ko_finish.wav",
	"ui_fail": "res://assets/audio/SFX_U/U-07_ui_fail.wav",
	"ui_start_game": "res://assets/audio/SFX_U/U_StartGame.wav",
}
const SFX_BASE_VOLUME_DB := -7.0
const SFX_VOLUME_OFFSETS_DB := {
	"H-01a": 2.0,
	"H-01b": 2.0,
	"H-01c": 2.0,
	"hit_light": 2.0,
	"hit_light_chain": 2.0,
	"hit_light_coffin": 2.0,
	"hit_light_book": 2.0,
	"hit_medium": 2.0,
	"hit_heavy": 2.0,
	"block": 3.0,
	"block_success": 3.0,
	"weila_projectile_fire": 2.0,
	"weila_projectile_hit": 3.0,
	"footstep": 3.0,
	"ui_select": 3.0,
	"ui_confirm": 3.0,
	"ui_click": 3.0,
	"ui_hover": 1.0,
	"ui_switch": 2.0,
	"ui_round_fight": 5.0,
	"U-05": 9.0,
	"U-07": 6.0,
	"ui_ko_finish": 9.0,
	"ui_start_game": 3.0,
	"ui_fail": 6.0,
}
const UI_FONT_PATH := "res://assets/fonts/simhei.ttf"
const FIGHTER_GROUND_Y := -0.42
const P1_SPAWN := Vector3(-1.35, FIGHTER_GROUND_Y, 0.0)
const P2_SPAWN := Vector3(1.35, FIGHTER_GROUND_Y, 0.0)
const DEFAULT_ROUND_TIME := 99
const DEFAULT_BEST_OF := 3
const ROUND_INTRO_FRAMES := 150
const ROUND_FIGHT_FRAMES := 55
const ROUND_RESULT_FRAMES := 150
const ROUND_FADE_FRAMES := 45
const ROUND_LOSER_KNOCKDOWN_FRAMES := 180
const ROUND_VICTORY_MIN_FRAMES := 180
const KO_SLOWMO_FRAMES := 78
const KO_SLOWMO_TICK_INTERVAL := 4
const AI_DEFAULT_ATTACK_COOLDOWN := 28
const AI_DEFAULT_JUMP_COOLDOWN := 120
const AI_STATE_KEYS := ["left", "right", "up", "down", "j", "k", "l", "u", "i", "o"]
const AI_CLOSE_RANGE := 0.78
const AI_THROW_RANGE := 1.22
const AI_MID_RANGE := 1.35
const AI_LONG_RANGE := 2.1
const CHARACTER_GRID_COLUMNS := 4
const STAGE_GRID_COLUMNS := 4
const METER_STOCK_VALUE := 100
const METER_MAX_STOCKS := 3
const METER_MAX_VALUE := METER_STOCK_VALUE * METER_MAX_STOCKS
const DEFAULT_MOVE_RESOURCE_FOLDER := "res://data/moves/prototype"
const DEFAULT_FIGHTER_STATS := {
	"walk_speed": 2.6,
	"dash_speed": 6.0,
	"jump_speed": 5.2,
	"gravity": 14.0,
	"air_control_speed": 2.35,
	"air_control_acceleration": 0.42,
}
const TUNABLE_FIGHTER_STATS := {
	"walk_speed": true,
	"dash_speed": true,
	"jump_speed": true,
	"gravity": true,
	"air_control_speed": true,
	"air_control_acceleration": true,
}
const DEFAULT_CHARACTER_VISUAL_PROFILE := {
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
}
const CHARACTER_MOVE_RESOURCE_FOLDERS := {
	0: "res://data/moves/prototype",
}
const KASHANDELLA_QISHI_ANIMATION_NAMES := {
	"idle": "Unreal Take",
	"walk": "Unreal Take",
	"punch": "Unreal Take",
	"kick": "Unreal Take",
	"jump": "Unreal Take",
	"run": "Unreal Take",
	"crouch": "Unreal Take",
	"crouch_enter": "Unreal Take",
	"crouch_exit": "Unreal Take",
	"crouch_kick": "Unreal Take",
	"crouch_punch": "Unreal Take",
	"hurricane_kick": "Unreal Take",
	"hit": "Unreal Take",
	"crouch_hit": "Unreal Take",
	"knockdown": "Unreal Take",
	"crouch_knockdown": "Unreal Take",
	"getup": "Unreal Take",
	"dash": "Unreal Take",
	"backstep": "Unreal Take",
	"dodge": "Unreal Take",
	"jump_alt": "Unreal Take",
	"turn": "Unreal Take",
	"h2h_kick_01": "Unreal Take",
	"h2h_kick_02": "Unreal Take",
	"h2h_kick_03": "Unreal Take",
	"h2h_kick_04": "Unreal Take",
	"h2h_punch_01": "Unreal Take",
	"h2h_punch_02": "Unreal Take",
	"aerial_swing": "Unreal Take",
	"anim_fireball": "Unreal Take",
	"rising_upper": "Unreal Take",
	"throw_att": "Unreal Take",
	"throw_vic": "Unreal Take",
	"throw_counter_att": "Unreal Take",
	"throw_counter_vic": "Unreal Take",
	"throw_groin_att": "Unreal Take",
	"throw_groin_vic": "Unreal Take",
	"throw_press_att": "Unreal Take",
	"throw_press_vic": "Unreal Take",
	"throw_push_att": "Unreal Take",
	"throw_push_vic": "Unreal Take",
	"throw_neck_att": "Unreal Take",
	"throw_neck_vic": "Unreal Take",
	"throw_knife_att": "Unreal Take",
	"throw_knife_vic": "Unreal Take",
	"victory_1": "Unreal Take",
	"victory_2": "Unreal Take",
	"victory_3": "Unreal Take",
}
const WELA_FASHI_ANIMATION_NAMES := {
	"idle": "Unreal Take",
	"walk": "Unreal Take",
	"punch": "Unreal Take",
	"kick": "Unreal Take",
	"jump": "Unreal Take",
	"run": "Unreal Take",
	"crouch": "Unreal Take",
	"crouch_enter": "Unreal Take",
	"crouch_exit": "Unreal Take",
	"crouch_kick": "Unreal Take",
	"crouch_punch": "Unreal Take",
	"hurricane_kick": "Unreal Take",
	"hit": "Unreal Take",
	"crouch_hit": "Unreal Take",
	"knockdown": "Unreal Take",
	"crouch_knockdown": "Unreal Take",
	"getup": "Unreal Take",
	"dash": "Unreal Take",
	"backstep": "Unreal Take",
	"dodge": "Unreal Take",
	"jump_alt": "Unreal Take",
	"turn": "Unreal Take",
	"h2h_kick_01": "Unreal Take",
	"h2h_kick_02": "Unreal Take",
	"h2h_kick_03": "Unreal Take",
	"h2h_kick_04": "Unreal Take",
	"h2h_punch_01": "Unreal Take",
	"h2h_punch_02": "Unreal Take",
	"aerial_swing": "Unreal Take",
	"rising_upper": "Unreal Take",
	"throw_att": "Unreal Take",
	"throw_vic": "Unreal Take",
	"throw_counter_att": "Unreal Take",
	"throw_counter_vic": "Unreal Take",
	"throw_groin_att": "Unreal Take",
	"throw_groin_vic": "Unreal Take",
	"throw_press_att": "Unreal Take",
	"throw_press_vic": "Unreal Take",
	"throw_push_att": "Unreal Take",
	"throw_push_vic": "Unreal Take",
	"throw_neck_att": "Unreal Take",
	"throw_neck_vic": "Unreal Take",
	"throw_knife_att": "Unreal Take",
	"throw_knife_vic": "Unreal Take",
	"victory_1": "Unreal Take",
	"victory_2": "Unreal Take",
	"victory_3": "Unreal Take",
}
const BUILD_ID := "20260527-common-action-retarget"
const MENU_PANEL_WIDTH := 760.0
const MENU_PANEL_HEIGHT := 560.0
const MENU_PANEL_EXPANDED_HEIGHT := 720.0
const MOVE_LIST_SCROLL_HEIGHT := 250.0
const BATTLE_VISUAL_TARGET_HEIGHT := 2.85
const STAGE_RANDOM_INDEX := -1
const STAGE_DEFINITIONS := [
	{
		"name": "Neon Street",
		"subtitle": "Cyberpunk city crosswalk",
		"preview": "res://assets/backgrounds/cyberpunk_street/preview.png",
		"root": "res://assets/backgrounds/cyberpunk_street/",
		"layers": [
			{"texture": "far-buildings.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.55), "parallax": 0.05, "alpha": 1.0},
			{"texture": "back-buildings.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.35), "parallax": 0.16, "alpha": 1.0},
			{"texture": "foreground.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.12), "parallax": 0.28, "alpha": 1.0},
		],
	},
	{
		"name": "Magical Road",
		"subtitle": "Moonlit forest road",
		"preview": "res://assets/backgrounds/magical_road/preview.png",
		"root": "res://assets/backgrounds/magical_road/",
		"layers": [
			{"texture": "preview.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.52), "parallax": 0.08, "alpha": 1.0},
			{"texture": "tree.png", "size": Vector2(1.55, 3.25), "position": Vector3(-4.85, 0.85, -2.08), "parallax": 0.34, "alpha": 0.92},
			{"texture": "tree.png", "size": Vector2(1.55, 3.25), "position": Vector3(4.85, 0.85, -2.08), "parallax": 0.34, "alpha": 0.92},
		],
	},
	{
		"name": "Sci-Fi Lab",
		"subtitle": "Cold metal laboratory",
		"preview": "res://assets/backgrounds/scifi_lab/preview.png",
		"root": "res://assets/backgrounds/scifi_lab/",
		"layers": [
			{"texture": "back.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.55), "parallax": 0.04, "alpha": 1.0},
			{"texture": "middle.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.34), "parallax": 0.15, "alpha": 1.0},
			{"texture": "front.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.1), "parallax": 0.26, "alpha": 1.0},
		],
	},
	{
		"name": "Super Grotto",
		"subtitle": "Tropical cave ruins",
		"preview": "res://assets/backgrounds/super_grotto/preview.png",
		"root": "res://assets/backgrounds/super_grotto/",
		"layers": [
			{"texture": "far.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.55), "parallax": 0.04, "alpha": 1.0},
			{"texture": "back.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.34), "parallax": 0.14, "alpha": 1.0},
			{"texture": "middle.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.12), "parallax": 0.26, "alpha": 1.0},
		],
	},
	{
		"name": "Royal Castle",
		"subtitle": "Bright castle garden",
		"preview": "res://assets/backgrounds/kenney_stage_samples/colored_castle.png",
		"root": "res://assets/backgrounds/kenney_stage_samples/",
		"layers": [
			{"texture": "colored_castle.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.5), "parallax": 0.08, "alpha": 1.0},
		],
	},
	{
		"name": "Desert Ruins",
		"subtitle": "Pyramids under clear sky",
		"preview": "res://assets/backgrounds/kenney_stage_samples/colored_desert.png",
		"root": "res://assets/backgrounds/kenney_stage_samples/",
		"layers": [
			{"texture": "colored_desert.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.5), "parallax": 0.08, "alpha": 1.0},
		],
	},
	{
		"name": "Forest Path",
		"subtitle": "Quiet green forest",
		"preview": "res://assets/backgrounds/kenney_stage_samples/colored_forest.png",
		"root": "res://assets/backgrounds/kenney_stage_samples/",
		"layers": [
			{"texture": "colored_forest.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.5), "parallax": 0.08, "alpha": 1.0},
		],
	},
	{
		"name": "Tall Trees",
		"subtitle": "Vertical forest arena",
		"preview": "res://assets/backgrounds/kenney_stage_samples/colored_talltrees.png",
		"root": "res://assets/backgrounds/kenney_stage_samples/",
		"layers": [
			{"texture": "colored_talltrees.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.5), "parallax": 0.08, "alpha": 1.0},
		],
	},
	{
		"name": "Ink Peaks",
		"subtitle": "Monochrome mountain peaks",
		"preview": "res://assets/backgrounds/kenney_stage_samples/uncolored_peaks.png",
		"root": "res://assets/backgrounds/kenney_stage_samples/",
		"layers": [
			{"texture": "uncolored_peaks.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.5), "parallax": 0.08, "alpha": 1.0},
		],
	},
	{
		"name": "Rolling Hills",
		"subtitle": "Clean training countryside",
		"preview": "res://assets/backgrounds/kenney_stage_samples/uncolored_hills.png",
		"root": "res://assets/backgrounds/kenney_stage_samples/",
		"layers": [
			{"texture": "uncolored_hills.png", "size": Vector2(12.8, 5.75), "position": Vector3(0.0, 2.03, -2.5), "parallax": 0.08, "alpha": 1.0},
		],
	},
]
const CHARACTER_ROSTER := [
	{
		"name": "卡珊德拉骑士",
		"style": "Action library fighter bound in Unreal",
		"portrait": "res://assets/characters/kashandella_qishi/portraits/portrait.jpg",
		"color": Color(0.93, 0.74, 0.45),
		"move_folder": "res://data/moves/prototype",
		"move_overrides": {
			"5K": {"animation_key": "kick"},
			"5I": {"animation_key": "kick"},
			"236K": {"animation_key": "h2h_kick_02"},
			"236236J": {"cinematic_video_path": "res://assets/cinematics/kashandella_qishi_236236J.ogv", "cinematic_duration_frames": 620},
			"632146K": {"cinematic_video_path": "res://assets/cinematics/kashandella_qishi_632146K.ogv", "cinematic_duration_frames": 620},
			"236236O": {"cinematic_video_path": "res://assets/cinematics/kashandella_qishi_236236O.ogv", "cinematic_duration_frames": 620},
		},
		"stats": {"walk_speed": 2.5, "dash_speed": 5.85, "jump_speed": 5.05, "air_control_speed": 2.35},
		"visual": {
			"base": "res://assets/characters/kashandella_qishi/kashandella_qishi.glb",
			"animations": {
				"idle": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_idle.glb",
				"walk": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_walk.glb",
				"punch": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_punch.glb",
				"kick": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_kick.glb",
				"jump": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_jump.glb",
				"run": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_run.glb",
				"crouch": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_crouch.glb",
				"crouch_enter": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_crouch_enter.glb",
				"crouch_exit": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_crouch_exit.glb",
				"crouch_kick": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_crouch_kick.glb",
				"crouch_punch": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_crouch_punch.glb",
				"hurricane_kick": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_hurricane_kick.glb",
				"hit": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_hit.glb",
				"crouch_hit": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_crouch_hit.glb",
				"knockdown": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_knockdown.glb",
				"crouch_knockdown": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_crouch_knockdown.glb",
				"getup": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_getup.glb",
				"dash": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_dash.glb",
				"backstep": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_backstep.glb",
				"dodge": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_dodge.glb",
				"jump_alt": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_jump_alt.glb",
				"turn": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_turn.glb",
				"h2h_kick_01": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_h2h_kick_01.glb",
				"h2h_kick_02": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_h2h_kick_02.glb",
				"h2h_kick_03": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_h2h_kick_03.glb",
				"h2h_kick_04": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_h2h_kick_04.glb",
				"h2h_punch_01": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_h2h_punch_01.glb",
				"h2h_punch_02": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_h2h_punch_02.glb",
				"aerial_swing": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_aerial_swing.glb",
				"rising_upper": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_rising_upper.glb",
				"throw_att": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_att.glb",
				"throw_vic": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_vic.glb",
				"throw_counter_att": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_counter_att.glb",
				"throw_counter_vic": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_counter_vic.glb",
				"throw_groin_att": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_groin_att.glb",
				"throw_groin_vic": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_groin_vic.glb",
				"throw_press_att": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_press_att.glb",
				"throw_press_vic": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_press_vic.glb",
				"throw_push_att": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_push_att.glb",
				"throw_push_vic": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_push_vic.glb",
				"throw_neck_att": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_neck_att.glb",
				"throw_neck_vic": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_neck_vic.glb",
				"throw_knife_att": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_knife_att.glb",
				"throw_knife_vic": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_throw_knife_vic.glb",
				"victory_1": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_victory_1.glb",
				"victory_2": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_victory_2.glb",
				"victory_3": "res://assets/characters/kashandella_qishi/animations/kashandella_qishi_victory_3.glb",
			},
			"animation_names": KASHANDELLA_QISHI_ANIMATION_NAMES,
			"textures": {
				"default": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_D.jpg",
				"albedo": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_D.jpg",
				"normal": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_N.jpg",
				"metallic": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_M.png",
				"roughness": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_Roughness.png",
				"orm": "res://assets/characters/kashandella_qishi/textures/AI_Fight_qishi_ORM.jpg",
			},
			"face_right_degrees": 140.0,
			"face_left_degrees": 40.0,
		},
	},
	{
		"name": "薇拉法师",
		"style": "Action library fighter bound in Unreal",
		"portrait": "res://assets/characters/wela_fashi/portraits/portrait.jpg",
		"color": Color(0.62, 0.76, 1.0),
		"move_folder": "res://data/moves/prototype",
		"move_overrides": {
			"5K": {"animation_key": "kick"},
			"5I": {"animation_key": "kick"},
			"236K": {"animation_key": "hurricane_kick"},
			"236236J": {"cinematic_video_path": "res://assets/cinematics/wela_fashi_236236J.ogv", "cinematic_duration_frames": 620},
			"632146K": {"cinematic_video_path": "res://assets/cinematics/wela_fashi_632146K.ogv", "cinematic_duration_frames": 620},
			"236236O": {"cinematic_video_path": "res://assets/cinematics/wela_fashi_236236O.ogv", "cinematic_duration_frames": 620},
		},
		"stats": {"walk_speed": 2.72, "dash_speed": 6.18, "jump_speed": 5.2, "air_control_speed": 2.58},
		"visual": {
			"base": "res://assets/characters/wela_fashi/wela_fashi.glb",
			"animations": {
				"idle": "res://assets/characters/wela_fashi/animations/wela_fashi_idle.glb",
				"walk": "res://assets/characters/wela_fashi/animations/wela_fashi_walk.glb",
				"punch": "res://assets/characters/wela_fashi/animations/wela_fashi_punch.glb",
				"kick": "res://assets/characters/wela_fashi/animations/wela_fashi_kick.glb",
				"jump": "res://assets/characters/wela_fashi/animations/wela_fashi_jump.glb",
				"run": "res://assets/characters/wela_fashi/animations/wela_fashi_run.glb",
				"crouch": "res://assets/characters/wela_fashi/animations/wela_fashi_crouch.glb",
				"crouch_enter": "res://assets/characters/wela_fashi/animations/wela_fashi_crouch_enter.glb",
				"crouch_exit": "res://assets/characters/wela_fashi/animations/wela_fashi_crouch_exit.glb",
				"crouch_kick": "res://assets/characters/wela_fashi/animations/wela_fashi_crouch_kick.glb",
				"crouch_punch": "res://assets/characters/wela_fashi/animations/wela_fashi_crouch_punch.glb",
				"hurricane_kick": "res://assets/characters/wela_fashi/animations/wela_fashi_hurricane_kick.glb",
				"hit": "res://assets/characters/wela_fashi/animations/wela_fashi_hit.glb",
				"crouch_hit": "res://assets/characters/wela_fashi/animations/wela_fashi_crouch_hit.glb",
				"knockdown": "res://assets/characters/wela_fashi/animations/wela_fashi_knockdown.glb",
				"crouch_knockdown": "res://assets/characters/wela_fashi/animations/wela_fashi_crouch_knockdown.glb",
				"getup": "res://assets/characters/wela_fashi/animations/wela_fashi_getup.glb",
				"dash": "res://assets/characters/wela_fashi/animations/wela_fashi_dash.glb",
				"backstep": "res://assets/characters/wela_fashi/animations/wela_fashi_backstep.glb",
				"dodge": "res://assets/characters/wela_fashi/animations/wela_fashi_dodge.glb",
				"jump_alt": "res://assets/characters/wela_fashi/animations/wela_fashi_jump_alt.glb",
				"turn": "res://assets/characters/wela_fashi/animations/wela_fashi_turn.glb",
				"h2h_kick_01": "res://assets/characters/wela_fashi/animations/wela_fashi_h2h_kick_01.glb",
				"h2h_kick_02": "res://assets/characters/wela_fashi/animations/wela_fashi_h2h_kick_02.glb",
				"h2h_kick_03": "res://assets/characters/wela_fashi/animations/wela_fashi_h2h_kick_03.glb",
				"h2h_kick_04": "res://assets/characters/wela_fashi/animations/wela_fashi_h2h_kick_04.glb",
				"h2h_punch_01": "res://assets/characters/wela_fashi/animations/wela_fashi_h2h_punch_01.glb",
				"h2h_punch_02": "res://assets/characters/wela_fashi/animations/wela_fashi_h2h_punch_02.glb",
				"aerial_swing": "res://assets/characters/wela_fashi/animations/wela_fashi_aerial_swing.glb",
				"anim_fireball": "res://assets/characters/wela_fashi/animations/wela_fashi_spell_attack.glb",
				"rising_upper": "res://assets/characters/wela_fashi/animations/wela_fashi_rising_upper.glb",
				"throw_att": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_att.glb",
				"throw_vic": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_vic.glb",
				"throw_counter_att": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_counter_att.glb",
				"throw_counter_vic": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_counter_vic.glb",
				"throw_groin_att": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_groin_att.glb",
				"throw_groin_vic": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_groin_vic.glb",
				"throw_press_att": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_press_att.glb",
				"throw_press_vic": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_press_vic.glb",
				"throw_push_att": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_push_att.glb",
				"throw_push_vic": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_push_vic.glb",
				"throw_neck_att": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_neck_att.glb",
				"throw_neck_vic": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_neck_vic.glb",
				"throw_knife_att": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_knife_att.glb",
				"throw_knife_vic": "res://assets/characters/wela_fashi/animations/wela_fashi_throw_knife_vic.glb",
				"victory_1": "res://assets/characters/wela_fashi/animations/wela_fashi_victory_1.glb",
				"victory_2": "res://assets/characters/wela_fashi/animations/wela_fashi_victory_2.glb",
				"victory_3": "res://assets/characters/wela_fashi/animations/wela_fashi_victory_3.glb",
			},
			"animation_names": WELA_FASHI_ANIMATION_NAMES,
			"textures": {
				"default": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_D.png",
				"albedo": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_D.png",
				"normal": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_N.png",
				"metallic": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_M.png",
				"roughness": "res://assets/characters/wela_fashi/textures/AI_Fight_Fashi_roughness.png",
			},
			"face_right_degrees": 140.0,
			"face_left_degrees": 40.0,
		},
	},
]
const MOVE_LIST_ROWS := [
	{"directions": [2, 1, 4], "button": "L", "name": "Shadow Step - cross behind"},
	{"directions": [2], "button": "K", "name": "下段轻踢"},
	{"directions": [2], "button": "I", "name": "下段重踢，命中倒地"},
	{"directions": [2, 3, 6], "button": "J", "name": "轻波动拳，伤害低，速度快"},
	{"directions": [2, 3, 6], "button": "U", "name": "重波动拳，伤害高，速度慢"},
	{"directions": [6, 2, 3], "button": "J", "name": "斜上波动拳，对空牵制"},
	{"directions": [2, 3, 6], "button": "I", "name": "斜下波动拳，下段对策"},
	{"directions": [2, 1, 4], "button": "J", "name": "空中下波动拳，跳起后可用"},
	{"directions": [2, 3, 6], "button": "O", "name": "地波，贴地前进，下段"},
	{"directions": [2, 3, 6, 2, 3, 6], "button": "J", "name": "普通必杀，消耗 1 格怒气"},
	{"directions": [2, 3, 6], "button": "K", "name": "旋风腿，小技能，不消耗怒气"},
	{"directions": [2, 1, 4], "button": "U", "name": "后拳反击，小技能，命中倒地，不消耗怒气"},
	{"directions": [6, 2, 3], "button": "I", "name": "升龙拳，小技能，对空击飞，不消耗怒气"},
	{"directions": [], "button": "J+K", "name": "投技"},
	{"directions": [6, 2, 4, 6], "button": "K", "name": "超必杀，消耗 2 格怒气"},
	{"directions": [2, 3, 6, 2, 3, 6], "button": "O", "name": "备用超必杀，消耗 2 格怒气"},
]
const INPUT_BINDINGS := [
	{"action": "p1_up", "keys": [KEY_W]},
	{"action": "p1_down", "keys": [KEY_S]},
	{"action": "p1_left", "keys": [KEY_A]},
	{"action": "p1_right", "keys": [KEY_D]},
	{"action": "p1_j", "keys": [KEY_J]},
	{"action": "p1_k", "keys": [KEY_K]},
	{"action": "p1_u", "keys": [KEY_U]},
	{"action": "p1_i", "keys": [KEY_I]},
	{"action": "p1_o", "keys": [KEY_O]},
	{"action": "p1_l", "keys": [KEY_L]},
	{"action": "p2_up", "keys": [KEY_UP]},
	{"action": "p2_down", "keys": [KEY_DOWN]},
	{"action": "p2_left", "keys": [KEY_LEFT]},
	{"action": "p2_right", "keys": [KEY_RIGHT]},
	{"action": "p2_j", "keys": [KEY_KP_1, KEY_1]},
	{"action": "p2_k", "keys": [KEY_KP_2, KEY_2]},
	{"action": "p2_l", "keys": [KEY_KP_3, KEY_3]},
	{"action": "p2_u", "keys": [KEY_KP_4, KEY_4]},
	{"action": "p2_i", "keys": [KEY_KP_5, KEY_5]},
	{"action": "p2_o", "keys": [KEY_KP_6, KEY_6]},
]

enum FlowState {
	MAIN_MENU,
	MODE_SELECT,
	CHARACTER_SELECT,
	STAGE_SELECT,
	LOADING_BATTLE,
	ROUND_INTRO,
	FIGHTING,
	CINEMATIC,
	PAUSED,
	ROUND_OVER,
	MATCH_OVER,
}

enum BattleMode {
	PVE,
	PVP,
}


class DirectionIcon:
	extends Control

	var direction := 5

	func _init(value: int = 5) -> void:
		direction = value
		custom_minimum_size = Vector2(22.0, 22.0)

	func _draw() -> void:
		var vector := _direction_vector()
		var center := size * 0.5
		var start := center - vector * 5.5
		var end := center + vector * 6.8
		var color := Color(1.0, 0.88, 0.32)
		draw_line(start, end, color, 2.2)
		var side := Vector2(-vector.y, vector.x)
		draw_colored_polygon(
			PackedVector2Array([
				end + vector * 4.2,
				end - vector * 3.0 + side * 3.4,
				end - vector * 3.0 - side * 3.4,
			]),
			color
		)

	func _direction_vector() -> Vector2:
		match direction:
			1:
				return Vector2(-1.0, 1.0).normalized()
			2:
				return Vector2(0.0, 1.0)
			3:
				return Vector2(1.0, 1.0).normalized()
			4:
				return Vector2(-1.0, 0.0)
			6:
				return Vector2(1.0, 0.0)
			7:
				return Vector2(-1.0, -1.0).normalized()
			8:
				return Vector2(0.0, -1.0)
			9:
				return Vector2(1.0, -1.0).normalized()
		return Vector2.ZERO


class MenuAmbientFx:
	extends Control

	var elapsed := 0.0
	var sparkle_points: Array[Vector2] = []

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in range(38):
			sparkle_points.append(Vector2(randf(), randf()))
		set_process(true)

	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		if w <= 1.0 or h <= 1.0:
			return
		var scan_y := fposmod(elapsed * 46.0, h + 90.0) - 45.0
		draw_rect(Rect2(0.0, scan_y - 18.0, w, 36.0), Color(0.12, 0.5, 0.95, 0.08), true)
		for i in range(9):
			var y := fposmod(float(i) * h / 9.0 + elapsed * 18.0, h)
			draw_line(Vector2(0.0, y), Vector2(w, y), Color(0.25, 0.72, 1.0, 0.045), 1.0)
		for i in range(7):
			var x := fposmod(float(i) * w / 7.0 - elapsed * 10.0, w)
			draw_line(Vector2(x, 0.0), Vector2(x, h), Color(0.25, 0.72, 1.0, 0.03), 1.0)
		for i in range(sparkle_points.size()):
			var p := sparkle_points[i]
			var x := fposmod(p.x * w + elapsed * (10.0 + float(i % 5) * 3.0), w)
			var y := fposmod(p.y * h + sin(elapsed * 0.7 + float(i)) * 12.0, h)
			var alpha := 0.12 + 0.12 * sin(elapsed * 2.2 + float(i) * 0.71)
			draw_circle(Vector2(x, y), 1.2 + float(i % 3) * 0.45, Color(0.48, 0.86, 1.0, alpha))


class LoadingSpinner:
	extends Control

	var elapsed := 0.0

	func _init() -> void:
		custom_minimum_size = Vector2(86.0, 86.0)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _ready() -> void:
		set_process(true)

	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.36
		for i in range(14):
			var t := float(i) / 14.0
			var angle := t * TAU + elapsed * 4.2
			var alpha := 0.12 + t * 0.72
			var p := center + Vector2(cos(angle), sin(angle)) * radius
			draw_circle(p, 2.2 + t * 2.6, Color(0.35, 0.84, 1.0, alpha))
		draw_arc(center, radius * 0.58, elapsed * -3.0, elapsed * -3.0 + PI * 1.35, 32, Color(1.0, 0.82, 0.24, 0.82), 3.0)


class LoadingProgressBar:
	extends Control

	var elapsed := 0.0

	func _init() -> void:
		custom_minimum_size = Vector2(420.0, 18.0)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _ready() -> void:
		set_process(true)

	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		draw_rect(rect, Color(0.02, 0.05, 0.09, 0.92), true)
		draw_rect(rect, Color(0.2, 0.55, 0.95, 0.78), false, 2.0)
		var segment_width := maxf(size.x * 0.26, 96.0)
		var x := fposmod(elapsed * 220.0, size.x + segment_width) - segment_width
		var fill_rect := Rect2(Vector2(x, 3.0), Vector2(segment_width, maxf(1.0, size.y - 6.0)))
		draw_rect(fill_rect, Color(0.15, 0.74, 1.0, 0.38), true)
		draw_rect(Rect2(Vector2(x + segment_width * 0.28, 3.0), Vector2(segment_width * 0.42, maxf(1.0, size.y - 6.0))), Color(1.0, 0.84, 0.25, 0.82), true)
		for i in range(5):
			var tick_x := float(i + 1) * size.x / 6.0
			draw_line(Vector2(tick_x, 3.0), Vector2(tick_x, size.y - 3.0), Color(0.7, 0.9, 1.0, 0.18), 1.0)


class CharacterSelectFireFx:
	extends Control

	const FIRE_TEXTURES := [
		"res://assets/vfx/kenney_particle_full/fire_01.png",
		"res://assets/vfx/kenney_particle_full/fire_02.png",
		"res://assets/vfx/kenney_particle_full/flame_06.png",
	]

	var elapsed := 0.0
	var fire_textures: Array[Texture2D] = []
	var flame_columns: Array[Dictionary] = []
	var ember_points: Array[Dictionary] = []

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for path in FIRE_TEXTURES:
			var texture := ResourceLoader.load(path) as Texture2D
			if texture != null:
				fire_textures.append(texture)
		for i in range(30):
			flame_columns.append({
				"x": randf(),
				"height": randf_range(0.36, 0.86),
				"width": randf_range(0.075, 0.16),
				"speed": randf_range(0.7, 1.45),
				"phase": randf() * TAU,
				"texture": randi() % maxi(fire_textures.size(), 1),
			})
		for i in range(70):
			ember_points.append({
				"x": randf(),
				"y": randf(),
				"speed": randf_range(0.035, 0.13),
				"drift": randf_range(-0.045, 0.045),
				"phase": randf() * TAU,
				"size": randf_range(1.2, 3.8),
			})
		set_process(true)

	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		if w <= 1.0 or h <= 1.0:
			return
		_draw_heat_haze(w, h)
		_draw_flame_wall(w, h)
		_draw_embers(w, h)

	func _draw_heat_haze(w: float, h: float) -> void:
		var base_y := h * 0.54
		for i in range(12):
			var t := float(i) / 11.0
			var y := lerpf(base_y, h, t)
			var alpha := 0.05 + (1.0 - t) * 0.09
			var offset := sin(elapsed * 1.6 + float(i) * 0.77) * 34.0
			draw_rect(Rect2(offset - 48.0, y, w + 96.0, h * 0.07), Color(1.0, 0.22 + t * 0.18, 0.04, alpha), true)

	func _draw_flame_wall(w: float, h: float) -> void:
		var bottom := h + 36.0
		for i in range(flame_columns.size()):
			var data := flame_columns[i]
			var wave := sin(elapsed * float(data["speed"]) * 2.0 + float(data["phase"]))
			var x := float(data["x"]) * w + wave * 22.0
			var flame_h := h * float(data["height"]) * (0.88 + wave * 0.08)
			var flame_w := w * float(data["width"])
			var y := bottom - flame_h
			var color := Color(1.0, 0.43 + 0.22 * sin(elapsed + float(i)), 0.08, 0.18)
			if fire_textures.is_empty():
				draw_colored_polygon(
					PackedVector2Array([
						Vector2(x - flame_w * 0.45, bottom),
						Vector2(x + flame_w * 0.45, bottom),
						Vector2(x + wave * 18.0, y),
					]),
					color
				)
			else:
				var texture := fire_textures[int(data["texture"]) % fire_textures.size()]
				draw_texture_rect(texture, Rect2(x - flame_w * 0.5, y, flame_w, flame_h), false, Color(1.0, 0.78, 0.46, 0.34))
		var glow_height := h * 0.34
		draw_rect(Rect2(0.0, h - glow_height, w, glow_height), Color(1.0, 0.18, 0.02, 0.16), true)

	func _draw_embers(w: float, h: float) -> void:
		for i in range(ember_points.size()):
			var data := ember_points[i]
			var y := fposmod(float(data["y"]) * h - elapsed * float(data["speed"]) * h, h)
			var x := fposmod(float(data["x"]) * w + sin(elapsed * 1.8 + float(data["phase"])) * float(data["drift"]) * w, w)
			var twinkle := 0.5 + 0.5 * sin(elapsed * 5.0 + float(data["phase"]))
			var radius := float(data["size"]) * (0.7 + twinkle * 0.65)
			draw_circle(Vector2(x, y), radius, Color(1.0, 0.58 + twinkle * 0.28, 0.14, 0.22 + twinkle * 0.32))


var p1: FighterController
var p2: FighterController
var battle_root: Node3D
var battle_hud_root: Control
var hud_layer: CanvasLayer
var menu_root: Control
var build_debug_label: Label
var hud_label: Label
var log_label: Label
var p1_health_bar: ProgressBar
var p2_health_bar: ProgressBar
var p1_meter_bar: ProgressBar
var p2_meter_bar: ProgressBar
var p1_meter_label: Label
var p2_meter_label: Label
var p1_health_label: Label
var p2_health_label: Label
var p1_round_label: Label
var p2_round_label: Label
var p1_combo_label: Label
var p2_combo_label: Label
var timer_label: Label
var center_message_label: Label
var screen_fade: ColorRect
var camera: Camera3D
var parallax_layers: Array[Dictionary] = []
var p1_shadow: MeshInstance3D
var p2_shadow: MeshInstance3D
var fighter_shadow_texture: Texture2D
var projectiles: Array = []
var ui_font: FontFile
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_player_index := 0
var footstep_players := {}
var music_manager
var ui_style_cache := {}
var ui_texture_cache := {}
var sound_stream_cache := {}

var flow_state := FlowState.MAIN_MENU
var previous_flow_state := FlowState.MAIN_MENU
var battle_mode := BattleMode.PVE
var move_list_player := 1
var round_time_setting := 99
var round_seconds := 99
var best_of := 3
var wins_needed := 2
var p1_round_wins := 0
var p2_round_wins := 0
var round_winner := 0
var round_number := 0
var round_pause_frames := 0
var round_intro_frames := 0
var round_fight_sfx_played := false
var ko_slowmo_frames := 0
var ko_slowmo_tick_counter := 0
var game_frame := 0
var round_frame := 0
var last_log := "准备"
var max_health := 1000
var hud_text_update_interval := 6
var p1_character_index := 0
var p2_character_index := 1
var p1_character_locked := false
var p2_character_locked := false
var character_select_tiles: Array[PanelContainer] = []
var stage_select_tiles: Array[PanelContainer] = []
var p1_select_name_label: Label
var p2_select_name_label: Label
var p1_select_style_label: Label
var p2_select_style_label: Label
var p1_select_status_label: Label
var p2_select_status_label: Label
var p1_select_preview_fighter: FighterController
var p2_select_preview_fighter: FighterController
var character_preview_viewports: Array[SubViewport] = []
var stage_cursor_index := 0
var selected_stage_index := 0
var selected_stage_name := "Neon Street"
var match_load_in_progress := false
var cinematic_layer: CanvasLayer
var cinematic_root: Control
var cinematic_video_player: VideoStreamPlayer
var cinematic_frames_left := 0
var cinematic_damage_settled := false
var pending_cinematic := {}
var debug_face_right_degrees := 140.0
var debug_face_left_degrees := 40.0
var ai_attack_cooldown := 0
var ai_jump_cooldown := 0
var ai_command_steps: Array = []
var ai_command_frame := 0
var last_p1_health_value := -1
var last_p2_health_value := -1
var last_p1_meter_value := -1
var last_p2_meter_value := -1


func _ready() -> void:
	randomize()
	DisplayServer.window_set_title("3D 格斗状态机网页测试")
	Engine.physics_ticks_per_second = 60
	_load_ui_font()
	_configure_input_map()
	_setup_ui_layer()
	_setup_audio()
	_show_main_menu()


func _physics_process(_delta: float) -> void:
	game_frame += 1

	if flow_state == FlowState.FIGHTING:
		round_frame += 1
		if battle_mode == BattleMode.PVE:
			_update_ai_input()
		else:
			p2.input_buffer.clear_scripted_state()
		p1.tick()
		p2.tick()
		_resolve_fighter_push()
		_update_projectiles()
		_update_camera()
		_check_round_end()
	elif flow_state == FlowState.CINEMATIC:
		_update_cinematic()
		_update_camera()
	elif flow_state == FlowState.ROUND_INTRO:
		round_intro_frames -= 1
		_update_round_intro_overlay()
		_update_camera()
		if round_intro_frames <= 0:
			_start_fighting()
	elif flow_state == FlowState.ROUND_OVER:
		round_pause_frames -= 1
		_update_ko_slowmo()
		_update_round_over_overlay()
		if round_pause_frames <= 0:
			_hide_center_overlay()
			if _is_match_over():
				_show_match_over()
			else:
				_start_round()
	else:
		if p2 != null:
			p2.input_buffer.clear_scripted_state()
		_update_camera()


	_sync_footstep_players()
	_update_hud()


func _setup_ui_layer() -> void:
	if hud_layer != null:
		return
	hud_layer = CanvasLayer.new()
	hud_layer.name = "HUD"
	hud_layer.layer = 20
	add_child(hud_layer)
	if SHOW_DEBUG_HUD:
		build_debug_label = Label.new()
		build_debug_label.name = "BuildDebugLabel"
		build_debug_label.position = Vector2(12.0, 4.0)
		build_debug_label.add_theme_font_size_override("font_size", 14)
		build_debug_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.72))
		hud_layer.add_child(build_debug_label)
		_apply_ui_font(build_debug_label)
		_update_build_debug_label()


func _setup_audio() -> void:
	if not sfx_players.is_empty():
		return
	for index in range(8):
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % index
		player.bus = "Master"
		player.volume_db = SFX_BASE_VOLUME_DB
		add_child(player)
		sfx_players.append(player)
	music_manager = MusicManagerScript.new()
	music_manager.name = "MusicManager"
	add_child(music_manager)


func _load_battle_scene() -> void:
	if battle_root != null:
		return
	battle_root = Node3D.new()
	battle_root.name = "BattleRoot"
	add_child(battle_root)
	_setup_world()
	_setup_fighters()
	_setup_hud()
	_play_battle_music()


func _unload_battle_scene() -> void:
	_hide_center_overlay()
	_set_battle_music_pause_effect(false)
	var had_battle := battle_root != null or battle_hud_root != null
	if had_battle:
		_stop_battle_music()
	if battle_hud_root != null:
		battle_hud_root.queue_free()
		battle_hud_root = null
	if battle_root != null:
		battle_root.queue_free()
		battle_root = null
	projectiles.clear()
	p1 = null
	p2 = null
	camera = null
	_hide_cinematic_overlay()
	pending_cinematic.clear()
	cinematic_frames_left = 0
	cinematic_damage_settled = false
	p1_health_bar = null
	p2_health_bar = null
	p1_meter_bar = null
	p2_meter_bar = null
	p1_meter_label = null
	p2_meter_label = null
	p1_health_label = null
	p2_health_label = null
	p1_round_label = null
	p2_round_label = null
	p1_combo_label = null
	p2_combo_label = null
	timer_label = null
	center_message_label = null
	screen_fade = null
	parallax_layers.clear()
	p1_shadow = null
	p2_shadow = null
	hud_label = null
	log_label = null


func _setup_world() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.045, 0.052, 0.06)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75, 0.78, 0.82)
	env.ambient_light_energy = 0.8
	environment.environment = env
	battle_root.add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42.0, 35.0, 0.0)
	sun.light_energy = 1.35
	battle_root.add_child(sun)

	camera = Camera3D.new()
	camera.position = Vector3(0.0, 2.05, 7.4)
	camera.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 5.4
	camera.current = true
	battle_root.add_child(camera)

	_setup_stage_background()

	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(10.5, 0.06, 0.56)
	var floor := MeshInstance3D.new()
	floor.name = "TrainingFloor"
	floor.mesh = floor_mesh
	floor.position = Vector3(0.0, -0.34, 0.0)
	floor.visible = false
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.22, 0.28, 0.22)
	floor_material.roughness = 0.8
	floor.material_override = floor_material
	battle_root.add_child(floor)

	var floor_body := StaticBody3D.new()
	floor_body.name = "TrainingFloorCollision"
	floor_body.position = floor.position
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = floor_mesh.size
	floor_collision.shape = floor_shape
	floor_body.add_child(floor_collision)
	battle_root.add_child(floor_body)


func _setup_fighters() -> void:
	p1 = FighterControllerScript.new()
	p1.name = "Player"
	p1.character_name = "P1"
	p1.action_prefix = "p1"
	p1.position = P1_SPAWN
	p1.stage_min_x = -4.6
	p1.stage_max_x = 4.6
	p1.show_debug_proxy = false
	p1.visual_target_height = BATTLE_VISUAL_TARGET_HEIGHT
	_apply_character_resources_to_fighter(p1, p1_character_index)
	_apply_character_visual_facing(p1, p1_character_index)
	battle_root.add_child(p1)

	p2 = FighterControllerScript.new()
	p2.name = "Player2"
	p2.character_name = "电脑"
	p2.action_prefix = "p2"
	p2.position = P2_SPAWN
	p2.stage_min_x = -4.6
	p2.stage_max_x = 4.6
	p2.show_debug_proxy = false
	p2.visual_target_height = BATTLE_VISUAL_TARGET_HEIGHT
	p2.allow_throw_tech = false
	_apply_character_resources_to_fighter(p2, p2_character_index)
	_apply_character_visual_facing(p2, p2_character_index)
	battle_root.add_child(p2)

	p1.set_opponent(p2)
	p2.set_opponent(p1)
	p1.move_started.connect(_on_move_started.bind("P1"))
	p2.move_started.connect(_on_move_started.bind("P2"))
	p1.hit_confirmed.connect(_on_hit_confirmed.bind("P1"))
	p2.hit_confirmed.connect(_on_hit_confirmed.bind("P2"))
	p1.cinematic_requested.connect(_on_cinematic_requested)
	p2.cinematic_requested.connect(_on_cinematic_requested)
	p1.combat_event.connect(_on_combat_event)
	p2.combat_event.connect(_on_combat_event)
	p1.sound_requested.connect(_play_sfx.bind(p1))
	p2.sound_requested.connect(_play_sfx.bind(p2))
	p1.projectile_requested.connect(_on_projectile_requested)
	p2.projectile_requested.connect(_on_projectile_requested)
	_setup_fighter_shadows()


func _setup_stage_background() -> void:
	parallax_layers.clear()
	var stage := _get_selected_stage()
	var root := String(stage.get("root", ""))
	for layer_data in stage.get("layers", []):
		var layer := layer_data as Dictionary
		_add_stage_layer(
			root + String(layer.get("texture", "")),
			layer.get("size", Vector2(12.8, 5.75)),
			layer.get("position", Vector3(0.0, 2.03, -2.3)),
			float(layer.get("parallax", 0.0)),
			float(layer.get("alpha", 1.0))
		)


func _add_stage_layer(texture_path: String, size: Vector2, position: Vector3, parallax: float, alpha: float) -> void:
	var layer := _make_textured_quad(texture_path, size, alpha)
	if layer == null:
		return
	layer.name = "StageLayer_%s" % texture_path.get_file().get_basename()
	layer.position = position
	battle_root.add_child(layer)
	parallax_layers.append({
		"node": layer,
		"base_x": position.x,
		"parallax": parallax,
	})


func _make_textured_quad(texture_path: String, size: Vector2, alpha: float = 1.0) -> MeshInstance3D:
	var texture := ResourceLoader.load(texture_path) as Texture2D
	if texture == null:
		push_warning("Missing stage texture: %s" % texture_path)
		return null

	var mesh := QuadMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.albedo_color = Color(1.0, 1.0, 1.0, alpha)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	instance.material_override = material
	return instance


func _setup_fighter_shadows() -> void:
	p1_shadow = _make_fighter_shadow()
	p2_shadow = _make_fighter_shadow()
	battle_root.add_child(p1_shadow)
	battle_root.add_child(p2_shadow)
	_update_fighter_shadows()


func _make_fighter_shadow() -> MeshInstance3D:
	var mesh := QuadMesh.new()
	mesh.size = Vector2(1.42, 0.34)
	var shadow := MeshInstance3D.new()
	shadow.name = "FakeGroundShadow"
	shadow.mesh = mesh
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shadow.position = Vector3(0.0, -0.36, 0.06)

	var material := StandardMaterial3D.new()
	material.albedo_texture = _get_fighter_shadow_texture()
	material.albedo_color = Color(0.0, 0.0, 0.0, 0.42)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	shadow.material_override = material
	return shadow


func _get_fighter_shadow_texture() -> Texture2D:
	if fighter_shadow_texture != null:
		return fighter_shadow_texture

	var width := 128
	var height := 32
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var center := Vector2(float(width - 1) * 0.5, float(height - 1) * 0.5)
	for y in range(height):
		for x in range(width):
			var offset := Vector2(float(x), float(y)) - center
			var normalized := Vector2(offset.x / (float(width) * 0.48), offset.y / (float(height) * 0.42))
			var distance := normalized.length()
			var alpha := clampf(1.0 - smoothstep(0.45, 1.0, distance), 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	fighter_shadow_texture = ImageTexture.create_from_image(image)
	return fighter_shadow_texture


func _setup_hud() -> void:
	battle_hud_root = Control.new()
	battle_hud_root.name = "BattleHUD"
	battle_hud_root.anchor_right = 1.0
	battle_hud_root.anchor_bottom = 1.0
	hud_layer.add_child(battle_hud_root)

	p1_health_label = _make_health_label("P1 1000")
	p1_health_label.position = Vector2(88.0, 12.0)
	battle_hud_root.add_child(p1_health_label)

	var p1_portrait := _make_portrait(p1_character_index)
	p1_portrait.position = Vector2(14.0, 10.0)
	battle_hud_root.add_child(p1_portrait)

	p1_health_bar = _make_health_bar()
	p1_health_bar.position = Vector2(88.0, 34.0)
	battle_hud_root.add_child(p1_health_bar)
	last_p1_health_value = max_health

	p1_round_label = _make_round_label()
	p1_round_label.position = Vector2(88.0, 63.0)
	battle_hud_root.add_child(p1_round_label)

	p1_combo_label = _make_combo_label(false)
	p1_combo_label.position = Vector2(100.0, 138.0)
	battle_hud_root.add_child(p1_combo_label)

	p2_health_label = _make_health_label("P2 1000")
	p2_health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p2_health_label.anchor_left = 1.0
	p2_health_label.anchor_right = 1.0
	p2_health_label.offset_left = -448.0
	p2_health_label.offset_right = -88.0
	p2_health_label.offset_top = 12.0
	p2_health_label.offset_bottom = 34.0
	battle_hud_root.add_child(p2_health_label)

	var p2_portrait := _make_portrait(p2_character_index)
	p2_portrait.anchor_left = 1.0
	p2_portrait.anchor_right = 1.0
	p2_portrait.offset_left = -78.0
	p2_portrait.offset_right = -14.0
	p2_portrait.offset_top = 10.0
	p2_portrait.offset_bottom = 74.0
	p2_portrait.flip_h = true
	battle_hud_root.add_child(p2_portrait)

	p2_health_bar = _make_health_bar()
	p2_health_bar.anchor_left = 1.0
	p2_health_bar.anchor_right = 1.0
	p2_health_bar.offset_left = -448.0
	p2_health_bar.offset_right = -88.0
	p2_health_bar.offset_top = 36.0
	p2_health_bar.offset_bottom = 62.0
	p2_health_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	battle_hud_root.add_child(p2_health_bar)
	last_p2_health_value = max_health

	p2_round_label = _make_round_label()
	p2_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p2_round_label.anchor_left = 1.0
	p2_round_label.anchor_right = 1.0
	p2_round_label.offset_left = -448.0
	p2_round_label.offset_right = -88.0
	p2_round_label.offset_top = 63.0
	p2_round_label.offset_bottom = 82.0
	battle_hud_root.add_child(p2_round_label)

	p2_combo_label = _make_combo_label(true)
	p2_combo_label.anchor_left = 1.0
	p2_combo_label.anchor_right = 1.0
	p2_combo_label.offset_left = -380.0
	p2_combo_label.offset_right = -100.0
	p2_combo_label.offset_top = 138.0
	p2_combo_label.offset_bottom = 216.0
	battle_hud_root.add_child(p2_combo_label)

	timer_label = Label.new()
	timer_label.anchor_left = 0.5
	timer_label.anchor_right = 0.5
	timer_label.offset_left = -64.0
	timer_label.offset_right = 64.0
	timer_label.offset_top = 8.0
	timer_label.offset_bottom = 58.0
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 40)
	battle_hud_root.add_child(timer_label)

	p1_meter_bar = _make_meter_bar()
	p1_meter_bar.anchor_top = 1.0
	p1_meter_bar.anchor_bottom = 1.0
	p1_meter_bar.offset_left = 96.0
	p1_meter_bar.offset_right = 456.0
	p1_meter_bar.offset_top = -46.0
	p1_meter_bar.offset_bottom = -22.0
	battle_hud_root.add_child(p1_meter_bar)
	last_p1_meter_value = 0

	p1_meter_label = _make_meter_label()
	p1_meter_label.anchor_top = 1.0
	p1_meter_label.anchor_bottom = 1.0
	p1_meter_label.offset_left = 100.0
	p1_meter_label.offset_right = 452.0
	p1_meter_label.offset_top = -45.0
	p1_meter_label.offset_bottom = -22.0
	battle_hud_root.add_child(p1_meter_label)

	p2_meter_bar = _make_meter_bar()
	p2_meter_bar.anchor_left = 1.0
	p2_meter_bar.anchor_right = 1.0
	p2_meter_bar.anchor_top = 1.0
	p2_meter_bar.anchor_bottom = 1.0
	p2_meter_bar.offset_left = -456.0
	p2_meter_bar.offset_right = -96.0
	p2_meter_bar.offset_top = -46.0
	p2_meter_bar.offset_bottom = -22.0
	p2_meter_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	battle_hud_root.add_child(p2_meter_bar)
	last_p2_meter_value = 0

	p2_meter_label = _make_meter_label()
	p2_meter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p2_meter_label.anchor_left = 1.0
	p2_meter_label.anchor_right = 1.0
	p2_meter_label.anchor_top = 1.0
	p2_meter_label.anchor_bottom = 1.0
	p2_meter_label.offset_left = -452.0
	p2_meter_label.offset_right = -100.0
	p2_meter_label.offset_top = -45.0
	p2_meter_label.offset_bottom = -22.0
	battle_hud_root.add_child(p2_meter_label)

	if SHOW_DEBUG_HUD:
		var panel := PanelContainer.new()
		panel.position = Vector2(16.0, 96.0)
		panel.modulate = Color(1.0, 1.0, 1.0, 0.72)
		panel.custom_minimum_size = Vector2(720.0, 132.0)
		panel.add_theme_stylebox_override("panel", _ui_panel_style(Color(0.04, 0.055, 0.075, 0.82), Color(0.24, 0.58, 0.82, 0.62), 2))
		battle_hud_root.add_child(panel)

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

	screen_fade = ColorRect.new()
	screen_fade.color = Color(0.0, 0.0, 0.0, 0.0)
	screen_fade.anchor_right = 1.0
	screen_fade.anchor_bottom = 1.0
	screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_fade.visible = false
	battle_hud_root.add_child(screen_fade)

	center_message_label = Label.new()
	center_message_label.anchor_left = 0.5
	center_message_label.anchor_right = 0.5
	center_message_label.anchor_top = 0.5
	center_message_label.anchor_bottom = 0.5
	center_message_label.offset_left = -260.0
	center_message_label.offset_right = 260.0
	center_message_label.offset_top = -80.0
	center_message_label.offset_bottom = 80.0
	center_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center_message_label.add_theme_font_size_override("font_size", 58)
	center_message_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.25))
	center_message_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	center_message_label.add_theme_constant_override("shadow_offset_x", 4)
	center_message_label.add_theme_constant_override("shadow_offset_y", 4)
	center_message_label.visible = false
	battle_hud_root.add_child(center_message_label)

	_apply_ui_font(battle_hud_root)


func _update_hud() -> void:
	if SHOW_DEBUG_HUD:
		_update_build_debug_label()
	if p1 == null or p2 == null or p1_health_bar == null or p2_health_bar == null:
		return
	_update_hud_feedback()
	p1_health_bar.value = p1.health
	p2_health_bar.value = p2.health
	p1_meter_bar.value = p1.meter
	p2_meter_bar.value = p2.meter
	p1_health_label.text = "1P  体力 %d" % p1.health
	p2_health_label.text = "%s  体力 %d" % [p2.character_name, p2.health]
	p1_meter_label.text = "怒气 %s" % _meter_stock_text(p1.meter)
	p2_meter_label.text = "%s 怒气" % _meter_stock_text(p2.meter)
	p1_round_label.text = _round_pips(p1_round_wins)
	p2_round_label.text = _round_pips(p2_round_wins)
	timer_label.text = _timer_text()
	_update_combo_hud()

	if game_frame % hud_text_update_interval != 0:
		return
	if not SHOW_DEBUG_HUD or hud_label == null or log_label == null:
		return

	var fps := Performance.get_monitor(Performance.TIME_FPS)
	var draw_calls := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	hud_label.text = "帧率 %.1f | 绘制调用 %d | Enter 暂停 | R 重开 | T 加满怒气\n1P：WASD 移动 + J/K/L/U/I/O 出招 | 2P：方向键移动 + 小键盘/数字 1/2/3/4/5/6 出招\n模式：%s | 1P：%s 第 %d 帧 招式 %s | 2P：%s 第 %d 帧 招式 %s" % [
		fps,
		int(draw_calls),
		"人机对战" if battle_mode == BattleMode.PVE else "本地双人",
		p1.state_name(),
		p1.state_frame,
		p1.current_move_text(),
		p2.state_name(),
		p2.state_frame,
		p2.current_move_text(),
	]
	log_label.text = "后退 = 防御 | 下后 = 下段防御 | 236J 轻波动 | 236U 重波动 | 623J 斜上波 | 236I 斜下波 | 空中214J 下波 | 236O 地波\nJ 拳 | K 踢 | J+K 投 | U 重拳 | I 重踢 | O Dust\n最近：%s" % last_log


func _update_combo_hud() -> void:
	_update_combo_label(p1_combo_label, p2)
	_update_combo_label(p2_combo_label, p1)


func _update_hud_feedback() -> void:
	if last_p1_health_value >= 0 and p1.health < last_p1_health_value:
		_pulse_hud_control(p1_health_bar, Color(1.0, 0.28, 0.18, 1.0), 1.035)
	if last_p2_health_value >= 0 and p2.health < last_p2_health_value:
		_pulse_hud_control(p2_health_bar, Color(1.0, 0.28, 0.18, 1.0), 1.035)
	if last_p1_meter_value >= 0 and p1.meter > last_p1_meter_value:
		_pulse_hud_control(p1_meter_bar, Color(1.0, 0.9, 0.22, 1.0), 1.025)
	if last_p2_meter_value >= 0 and p2.meter > last_p2_meter_value:
		_pulse_hud_control(p2_meter_bar, Color(1.0, 0.9, 0.22, 1.0), 1.025)
	last_p1_health_value = p1.health
	last_p2_health_value = p2.health
	last_p1_meter_value = p1.meter
	last_p2_meter_value = p2.meter
	if timer_label != null and round_seconds > 0:
		var remaining := maxi(0, round_seconds - int(round_frame / 60))
		if remaining <= 10 and flow_state == FlowState.FIGHTING:
			var pulse := 1.0 + sin(float(game_frame) * 0.32) * 0.06
			timer_label.scale = Vector2(pulse, pulse)
			timer_label.add_theme_color_override("font_color", Color(1.0, 0.24, 0.18))
		else:
			timer_label.scale = Vector2.ONE
			timer_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))


func _pulse_hud_control(control: Control, color: Color, scale_target: float) -> void:
	if control == null or not is_instance_valid(control):
		return
	control.pivot_offset = control.size * 0.5
	var original := control.modulate
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "scale", Vector2(scale_target, scale_target), 0.07)
	tween.parallel().tween_property(control, "modulate", color, 0.07)
	tween.tween_property(control, "scale", Vector2.ONE, 0.16)
	tween.parallel().tween_property(control, "modulate", original, 0.16)


func _update_combo_label(label: Label, defender: FighterController) -> void:
	if label == null or defender == null:
		return
	if defender.combo_count <= 1:
		label.visible = false
		return
	label.visible = true
	label.text = "%d HIT\n伤害 %d" % [defender.combo_count, defender.combo_damage_total]
	var pulse := 1.0 + sin(float(game_frame) * 0.28) * 0.035
	label.scale = Vector2(pulse, pulse)


func _timer_text() -> String:
	if round_seconds <= 0:
		return "无限"
	return "%02d" % maxi(0, round_seconds - int(round_frame / 60))


func _round_pips(wins: int) -> String:
	var text := ""
	for index in range(wins_needed):
		text += "胜" if index < wins else "-"
	return text


func _meter_stock_text(value: int) -> String:
	var clamped := clampi(value, 0, METER_MAX_VALUE)
	var full_stocks := int(floor(float(clamped) / float(METER_STOCK_VALUE)))
	var partial := clamped % METER_STOCK_VALUE
	if full_stocks >= METER_MAX_STOCKS:
		return "%d/%d 格" % [METER_MAX_STOCKS, METER_MAX_STOCKS]
	return "%d/%d 格 + %02d" % [full_stocks, METER_MAX_STOCKS, partial]


func _show_main_menu() -> void:
	flow_state = FlowState.MAIN_MENU
	_unload_battle_scene()
	_hide_center_overlay()
	_play_menu_music()
	_set_menu(
		"3D 格斗原型",
		"网页端 1V1 格斗测试",
		[
			{"text": "开始游戏", "callable": Callable(self, "_on_start_game_pressed"), "sfx": "ui_start_game"},
		],
		[]
	)


func _on_start_game_pressed() -> void:
	if music_manager != null:
		music_manager.restore_intro_effect()
	_show_mode_select()


func _show_mode_select() -> void:
	flow_state = FlowState.MODE_SELECT
	_unload_battle_scene()
	_play_menu_music()
	_set_menu(
		"选择模式",
		"选择 2P 由电脑控制，还是本地玩家控制。",
		[
			{"text": "对战电脑", "callable": Callable(self, "_select_pve")},
			{"text": "本地双人", "callable": Callable(self, "_select_pvp")},
			{"text": "返回", "callable": Callable(self, "_show_main_menu")},
		],
		[]
	)


func _select_pve() -> void:
	battle_mode = BattleMode.PVE
	_apply_default_match_rules()
	_open_character_select()


func _select_pvp() -> void:
	battle_mode = BattleMode.PVP
	_apply_default_match_rules()
	_open_character_select()


func _open_character_select() -> void:
	flow_state = FlowState.LOADING_BATTLE
	_show_character_select_loading_screen()
	await _let_loading_feedback_breathe()
	_show_character_select()


func _apply_default_match_rules() -> void:
	round_time_setting = DEFAULT_ROUND_TIME
	best_of = DEFAULT_BEST_OF
	wins_needed = _wins_needed_for_best_of(best_of)


func _wins_needed_for_best_of(round_count: int) -> int:
	return int(floor(float(round_count) * 0.5)) + 1


func _reset_character_select_state() -> void:
	p1_character_index = 0
	p2_character_index = 1
	p1_character_locked = false
	p2_character_locked = battle_mode == BattleMode.PVE
	character_select_tiles.clear()
	p1_select_name_label = null
	p2_select_name_label = null
	p1_select_style_label = null
	p2_select_style_label = null
	p1_select_status_label = null
	p2_select_status_label = null
	p1_select_preview_fighter = null
	p2_select_preview_fighter = null


func _show_character_select() -> void:
	flow_state = FlowState.CHARACTER_SELECT
	_play_character_select_music()
	_reset_character_select_state()
	_hide_menu()

	menu_root = Control.new()
	menu_root.name = "CharacterSelect"
	menu_root.anchor_right = 1.0
	menu_root.anchor_bottom = 1.0
	hud_layer.add_child(menu_root)

	var background := ColorRect.new()
	background.color = UI_OD_BG
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	menu_root.add_child(background)
	_add_character_select_fire_fx(menu_root)
	_add_menu_ambient_fx(menu_root, 0.78)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	menu_root.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)

	var title := Label.new()
	title.text = "角色选择"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", UI_OD_CREAM)
	title.add_theme_color_override("font_shadow_color", UI_OD_RED)
	title.add_theme_constant_override("shadow_offset_x", 5)
	title.add_theme_constant_override("shadow_offset_y", 0)
	root.add_child(title)

	var main_row := HBoxContainer.new()
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", 20)
	root.add_child(main_row)

	main_row.add_child(_make_character_preview_panel(1))
	main_row.add_child(_make_character_grid_panel())
	main_row.add_child(_make_character_preview_panel(2))

	var option_row := HBoxContainer.new()
	option_row.alignment = BoxContainer.ALIGNMENT_CENTER
	option_row.add_theme_constant_override("separation", 16)
	if battle_mode == BattleMode.PVP:
		option_row.add_child(_make_time_option_row())
		option_row.add_child(_make_match_option_row())
	else:
		var rules := Label.new()
		rules.text = "人机规则：99 秒，三局两胜。电脑会自动选择角色。"
		rules.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		option_row.add_child(rules)
	root.add_child(option_row)

	var hint := Label.new()
	hint.text = "1P：WASD 移动光标，J 确认    2P：方向键移动光标，数字 1 / 小键盘 1 确认    Esc 返回"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(hint)

	_apply_ui_font(menu_root)
	_update_character_select_view()


func _make_time_option_row() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = "回合时间"
	label.custom_minimum_size = Vector2(120.0, 24.0)
	row.add_child(label)
	var options := OptionButton.new()
	options.add_item("99 秒", 99)
	options.add_item("180 秒", 180)
	options.add_item("无限时间", 0)
	options.selected = 0
	options.item_selected.connect(_on_time_option_selected.bind(options))
	row.add_child(options)
	return row


func _make_match_option_row() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = "胜负规则"
	label.custom_minimum_size = Vector2(120.0, 24.0)
	row.add_child(label)
	var options := OptionButton.new()
	options.add_item("一局定胜负", 1)
	options.add_item("三局两胜", 3)
	options.add_item("五局三胜", 5)
	options.selected = 1
	options.item_selected.connect(_on_match_option_selected.bind(options))
	row.add_child(options)
	return row


func _make_character_preview_panel(player: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(260.0, 560.0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var border := UI_OD_CYAN if player == 1 else UI_OD_RED
	panel.add_theme_stylebox_override("panel", _ui_panel_style(UI_OD_PANEL, border, 2))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var player_label := Label.new()
	player_label.text = "1P" if player == 1 else ("电脑" if battle_mode == BattleMode.PVE else "2P")
	player_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_label.add_theme_font_size_override("font_size", 24)
	player_label.add_theme_color_override("font_color", border)
	box.add_child(player_label)

	var model_preview := _make_character_model_preview(player)
	box.add_child(model_preview)

	var name_label := Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	box.add_child(name_label)

	var style_label := Label.new()
	style_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	style_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(style_label)

	var model_label := Label.new()
	model_label.text = "模型预览：当前共用导入角色模型"
	model_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	model_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(model_label)
	model_label.visible = false

	var status_label := Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	box.add_child(status_label)

	if player == 1:
		p1_select_name_label = name_label
		p1_select_style_label = style_label
		p1_select_status_label = status_label
	else:
		p2_select_name_label = name_label
		p2_select_style_label = style_label
		p2_select_status_label = status_label

	return panel


func _make_character_model_preview(player: int) -> Control:
	var container := SubViewportContainer.new()
	container.custom_minimum_size = Vector2(260.0, 420.0)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.stretch = true

	var viewport := SubViewport.new()
	viewport.size = Vector2i(300, 450)
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_PARENT_VISIBLE
	container.add_child(viewport)
	character_preview_viewports.append(viewport)

	var world := Node3D.new()
	world.name = "CharacterPreviewWorld"
	viewport.add_child(world)

	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.19, 0.21, 0.23, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.92, 0.9, 0.86)
	env.ambient_light_energy = 0.95
	environment.environment = env
	world.add_child(environment)

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-35.0, -28.0 if player == 1 else 28.0, 0.0)
	key_light.light_energy = 0.85
	world.add_child(key_light)

	var fill_light := DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(-8.0, 145.0 if player == 1 else -145.0, 0.0)
	fill_light.light_energy = 0.28
	world.add_child(fill_light)

	var preview_camera := Camera3D.new()
	preview_camera.position = Vector3(0.0, 0.58, 5.2)
	preview_camera.rotation_degrees = Vector3.ZERO
	preview_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	preview_camera.size = 3.15
	preview_camera.current = true
	world.add_child(preview_camera)

	var fighter := FighterControllerScript.new() as FighterController
	fighter.name = "PreviewFighter"
	fighter.action_prefix = "preview%d" % player
	fighter.character_name = "Preview"
	fighter.show_debug_proxy = false
	fighter.use_fbx_visual = true
	fighter.visual_target_height = 2.05
	fighter.facing_right = player == 1
	_apply_character_resources_to_fighter(fighter, p1_character_index if player == 1 else p2_character_index)
	_apply_character_visual_facing(fighter, p1_character_index if player == 1 else p2_character_index)
	fighter.position = Vector3(0.0, -0.68, 0.0)
	world.add_child(fighter)
	call_deferred("_prepare_character_preview_model", fighter, viewport)

	if player == 1:
		p1_select_preview_fighter = fighter
	else:
		p2_select_preview_fighter = fighter

	return container


func _prepare_character_preview_model(fighter: FighterController, viewport: SubViewport) -> void:
	if fighter.visual_model != null:
		_apply_character_visual_facing(fighter, int(fighter.get_meta("character_index", 0)))
		fighter._apply_visual_facing()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS


func _set_character_preview_rendering(enabled: bool) -> void:
	for viewport in character_preview_viewports:
		if is_instance_valid(viewport):
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if enabled else SubViewport.UPDATE_ONCE


func _make_character_grid_panel() -> Control:
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 10)

	var grid_title := Label.new()
	grid_title.text = "角色列表"
	grid_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grid_title.add_theme_font_size_override("font_size", 20)
	box.add_child(grid_title)

	var grid := GridContainer.new()
	grid.columns = CHARACTER_GRID_COLUMNS
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)

	for index in range(CHARACTER_ROSTER.size()):
		var tile := _make_character_tile(index)
		character_select_tiles.append(tile)
		grid.add_child(tile)

	var note := Label.new()
	note.text = "蓝框：1P 光标    红框：2P 光标    锁定后会显示已确认"
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)
	return box


func _make_character_tile(index: int) -> PanelContainer:
	var tile := PanelContainer.new()
	tile.custom_minimum_size = Vector2(86.0, 106.0)
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.gui_input.connect(_on_character_tile_gui_input.bind(index))
	_apply_selectable_tile_fx(tile)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 5)
	margin.add_theme_constant_override("margin_right", 5)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	tile.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	margin.add_child(box)

	var portrait := TextureRect.new()
	portrait.texture = _portrait_texture_for_character(index)
	portrait.custom_minimum_size = Vector2(64.0, 64.0)
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	box.add_child(portrait)

	var name := Label.new()
	name.text = String(CHARACTER_ROSTER[index]["name"])
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", 13)
	box.add_child(name)

	return tile


func _on_character_tile_gui_input(event: InputEvent, index: int) -> void:
	if flow_state != FlowState.CHARACTER_SELECT:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
			return
		_play_sfx("ui_select")
		p1_character_index = index
		_update_character_select_view()
		if mouse_event.double_click:
			_lock_character(1)


func _on_time_option_selected(index: int, options: OptionButton) -> void:
	round_time_setting = int(options.get_item_id(index))


func _on_match_option_selected(index: int, options: OptionButton) -> void:
	best_of = int(options.get_item_id(index))
	wins_needed = _wins_needed_for_best_of(best_of)


func _move_character_cursor(player: int, x_delta: int, y_delta: int) -> void:
	if player == 1 and p1_character_locked:
		return
	if player == 2 and p2_character_locked:
		return

	var index := p1_character_index if player == 1 else p2_character_index
	var row := int(index / CHARACTER_GRID_COLUMNS)
	var column := index % CHARACTER_GRID_COLUMNS
	var row_count := int(ceil(float(CHARACTER_ROSTER.size()) / float(CHARACTER_GRID_COLUMNS)))

	column = wrapi(column + x_delta, 0, CHARACTER_GRID_COLUMNS)
	row = wrapi(row + y_delta, 0, row_count)
	index = mini(row * CHARACTER_GRID_COLUMNS + column, CHARACTER_ROSTER.size() - 1)

	if player == 1:
		p1_character_index = index
	else:
		p2_character_index = index
	_play_sfx("ui_select")
	_update_character_select_view()


func _lock_character(player: int) -> void:
	if match_load_in_progress:
		return
	if player == 1:
		p1_character_locked = true
	else:
		p2_character_locked = true
	_play_sfx("ui_confirm")
	_update_character_select_view()
	if _character_select_ready():
		_show_stage_select()


func _character_select_ready() -> bool:
	if battle_mode == BattleMode.PVE:
		return p1_character_locked
	return p1_character_locked and p2_character_locked


func _show_stage_select() -> void:
	flow_state = FlowState.STAGE_SELECT
	_play_stage_select_music()
	stage_cursor_index = 0
	_hide_menu()

	menu_root = Control.new()
	menu_root.name = "StageSelect"
	menu_root.anchor_right = 1.0
	menu_root.anchor_bottom = 1.0
	hud_layer.add_child(menu_root)

	var background := ColorRect.new()
	background.color = Color(0.018, 0.02, 0.026, 1.0)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	menu_root.add_child(background)
	_add_menu_ambient_fx(menu_root, 0.74)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	menu_root.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	var title := Label.new()
	title.text = "选择地图"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	root.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0.0, 520.0)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var grid_center := CenterContainer.new()
	grid_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid_center)

	var grid := GridContainer.new()
	grid.columns = STAGE_GRID_COLUMNS
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid_center.add_child(grid)

	stage_select_tiles.clear()
	for index in range(_stage_option_count()):
		var tile := _make_stage_tile(index)
		_apply_selectable_tile_fx(tile)
		stage_select_tiles.append(tile)
		grid.add_child(tile)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_theme_constant_override("separation", 14)
	root.add_child(button_row)

	var confirm_button := Button.new()
	confirm_button.text = "确认地图"
	confirm_button.custom_minimum_size = Vector2(180.0, 38.0)
	confirm_button.pressed.connect(_confirm_stage_selection)
	button_row.add_child(confirm_button)

	var random_button := Button.new()
	random_button.text = "随机"
	random_button.custom_minimum_size = Vector2(140.0, 38.0)
	random_button.pressed.connect(_choose_random_stage_and_begin)
	button_row.add_child(random_button)

	var back_button := Button.new()
	back_button.text = "返回"
	back_button.custom_minimum_size = Vector2(120.0, 38.0)
	back_button.pressed.connect(_show_character_select)
	button_row.add_child(back_button)

	var hint := Label.new()
	hint.text = "共 10 张地图 + 随机。1P 用 WASD / J 选择，2P 用方向键 / 小键盘1 选择。"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(hint)

	_apply_ui_font(menu_root)
	_update_stage_select_view()


func _stage_option_count() -> int:
	return STAGE_DEFINITIONS.size() + 1


func _stage_index_for_option(option_index: int) -> int:
	if option_index >= STAGE_DEFINITIONS.size():
		return STAGE_RANDOM_INDEX
	return option_index


func _make_stage_tile(option_index: int) -> PanelContainer:
	var tile := PanelContainer.new()
	tile.custom_minimum_size = Vector2(232.0, 156.0)
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.gui_input.connect(_on_stage_tile_gui_input.bind(option_index))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	tile.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	margin.add_child(box)

	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(218.0, 92.0)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if _stage_index_for_option(option_index) == STAGE_RANDOM_INDEX:
		preview.texture = _make_random_stage_preview_texture()
	else:
		preview.texture = ResourceLoader.load(String(STAGE_DEFINITIONS[option_index]["preview"])) as Texture2D
	box.add_child(preview)

	var name := Label.new()
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", 17)
	if _stage_index_for_option(option_index) == STAGE_RANDOM_INDEX:
		name.text = "随机"
	else:
		name.text = String(STAGE_DEFINITIONS[option_index]["name"])
	box.add_child(name)

	var subtitle := Label.new()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.modulate = Color(0.76, 0.8, 0.86)
	if _stage_index_for_option(option_index) == STAGE_RANDOM_INDEX:
		subtitle.text = "开局随机抽一张"
	else:
		subtitle.text = String(STAGE_DEFINITIONS[option_index]["subtitle"])
	box.add_child(subtitle)
	return tile


func _make_random_stage_preview_texture() -> Texture2D:
	var width := 256
	var height := 112
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		for x in range(width):
			var t := float(y) / float(height - 1)
			var pulse := 0.5 + 0.5 * sin(float(x) * 0.09 + float(y) * 0.05)
			image.set_pixel(x, y, Color(0.08 + 0.16 * pulse, 0.09 + 0.1 * t, 0.16 + 0.28 * (1.0 - t), 1.0))
	return ImageTexture.create_from_image(image)


func _on_stage_tile_gui_input(event: InputEvent, option_index: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_play_sfx("ui_select")
			stage_cursor_index = option_index
			_update_stage_select_view()
			if mouse_event.double_click:
				_confirm_stage_selection()


func _move_stage_cursor(x_delta: int, y_delta: int) -> void:
	var row := int(stage_cursor_index / STAGE_GRID_COLUMNS)
	var column := stage_cursor_index % STAGE_GRID_COLUMNS
	var row_count := int(ceil(float(_stage_option_count()) / float(STAGE_GRID_COLUMNS)))
	column = wrapi(column + x_delta, 0, STAGE_GRID_COLUMNS)
	row = wrapi(row + y_delta, 0, row_count)
	stage_cursor_index = mini(row * STAGE_GRID_COLUMNS + column, _stage_option_count() - 1)
	_play_sfx("ui_select")
	_update_stage_select_view()


func _update_stage_select_view() -> void:
	for index in range(stage_select_tiles.size()):
		var tile := stage_select_tiles[index]
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.07, 0.075, 0.09, 0.96)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.22, 0.24, 0.3)
		if index == stage_cursor_index:
			style.bg_color = Color(0.13, 0.14, 0.18, 1.0)
			style.border_width_left = 5
			style.border_width_top = 5
			style.border_width_right = 5
			style.border_width_bottom = 5
			style.border_color = Color(0.35, 0.7, 1.0)
			style.shadow_color = Color(0.18, 0.7, 1.0, 0.62)
			style.shadow_size = 12
		tile.add_theme_stylebox_override("panel", style)
		_set_tile_selected_fx(tile, index == stage_cursor_index, style.border_color)


func _confirm_stage_selection() -> void:
	var stage_index := _stage_index_for_option(stage_cursor_index)
	if stage_index == STAGE_RANDOM_INDEX:
		_choose_random_stage_and_begin()
		return
	selected_stage_index = stage_index
	selected_stage_name = String(STAGE_DEFINITIONS[selected_stage_index]["name"])
	_begin_match()


func _choose_random_stage_and_begin() -> void:
	selected_stage_index = randi() % STAGE_DEFINITIONS.size()
	selected_stage_name = String(STAGE_DEFINITIONS[selected_stage_index]["name"])
	_begin_match()


func _get_selected_stage() -> Dictionary:
	if selected_stage_index < 0 or selected_stage_index >= STAGE_DEFINITIONS.size():
		selected_stage_index = 0
	return STAGE_DEFINITIONS[selected_stage_index] as Dictionary


func _apply_selected_characters() -> void:
	p1.character_name = "1P·%s" % String(CHARACTER_ROSTER[p1_character_index]["name"])
	if battle_mode == BattleMode.PVE:
		p2.character_name = "电脑·%s" % String(CHARACTER_ROSTER[p2_character_index]["name"])
	else:
		p2.character_name = "2P·%s" % String(CHARACTER_ROSTER[p2_character_index]["name"])


func _move_resource_folder_for_character(character_index: int) -> String:
	var data := _character_data(character_index)
	return String(data.get("move_folder", CHARACTER_MOVE_RESOURCE_FOLDERS.get(character_index, DEFAULT_MOVE_RESOURCE_FOLDER)))


func _character_data(character_index: int) -> Dictionary:
	if character_index < 0 or character_index >= CHARACTER_ROSTER.size():
		return CHARACTER_ROSTER[0] as Dictionary
	return CHARACTER_ROSTER[character_index] as Dictionary


func _character_visual_profile(character_index: int) -> Dictionary:
	var data := _character_data(character_index)
	if data.has("visual"):
		return data["visual"] as Dictionary
	return DEFAULT_CHARACTER_VISUAL_PROFILE


func _apply_character_resources_to_fighter(fighter: FighterController, character_index: int) -> void:
	if fighter == null:
		return
	var data := _character_data(character_index)
	var visual := _character_visual_profile(character_index)
	var move_folder := String(data.get("move_folder", _move_resource_folder_for_character(character_index)))
	var base_scene := String(visual.get("base", DEFAULT_CHARACTER_VISUAL_PROFILE["base"]))
	var animations := (visual.get("animations", DEFAULT_CHARACTER_VISUAL_PROFILE["animations"]) as Dictionary).duplicate(true)
	if visual.has("animation_scene"):
		for key in DEFAULT_CHARACTER_VISUAL_PROFILE["animations"].keys():
			animations[key] = String(visual["animation_scene"])
	var textures := (visual.get("textures", DEFAULT_CHARACTER_VISUAL_PROFILE["textures"]) as Dictionary).duplicate(true)
	var move_overrides := (data.get("move_overrides", {}) as Dictionary).duplicate(true)
	var animation_names := (visual.get("animation_names", {}) as Dictionary).duplicate(true)
	fighter.apply_character_resources(move_folder, base_scene, animations, textures, move_overrides, animation_names)
	_apply_fighter_stat_overrides(fighter, data.get("stats", {}) as Dictionary)
	fighter.set_meta("character_index", character_index)


func _apply_character_visual_facing(fighter: FighterController, character_index: int) -> void:
	if fighter == null:
		return
	var visual := _character_visual_profile(character_index)
	var face_right := float(visual.get("face_right_degrees", debug_face_right_degrees))
	var face_left := float(visual.get("face_left_degrees", debug_face_left_degrees))
	fighter.set_visual_facing_angles(face_right, face_left)


func _apply_fighter_stat_overrides(fighter: FighterController, stats: Dictionary) -> void:
	for property_name in DEFAULT_FIGHTER_STATS.keys():
		fighter.set(String(property_name), DEFAULT_FIGHTER_STATS[property_name])
	for property_name in stats.keys():
		var property_text := String(property_name)
		if TUNABLE_FIGHTER_STATS.has(property_text):
			fighter.set(property_text, stats[property_name])


func _portrait_texture_for_character(character_index: int) -> Texture2D:
	var data := _character_data(character_index)
	var portrait_path := String(data.get("portrait", ""))
	if portrait_path.is_empty():
		return PORTRAIT_TEXTURE
	var texture := ResourceLoader.load(portrait_path) as Texture2D
	return texture if texture != null else PORTRAIT_TEXTURE


func _update_character_select_view() -> void:
	_update_character_preview(1)
	_update_character_preview(2)
	for index in range(character_select_tiles.size()):
		_apply_character_tile_style(character_select_tiles[index], index)


func _update_character_preview(player: int) -> void:
	var index := p1_character_index if player == 1 else p2_character_index
	var data: Dictionary = CHARACTER_ROSTER[index] as Dictionary
	var locked: bool = p1_character_locked if player == 1 else p2_character_locked
	var name_label: Label = p1_select_name_label if player == 1 else p2_select_name_label
	var style_label: Label = p1_select_style_label if player == 1 else p2_select_style_label
	var status_label: Label = p1_select_status_label if player == 1 else p2_select_status_label
	var preview_fighter: FighterController = p1_select_preview_fighter if player == 1 else p2_select_preview_fighter

	if name_label != null:
		name_label.text = String(data["name"])
	if style_label != null:
		style_label.text = "定位：%s" % String(data["style"])
	if status_label != null:
		status_label.text = "已确认" if locked else "选择中"
		status_label.modulate = Color(0.35, 1.0, 0.48) if locked else Color(1.0, 0.86, 0.25)
	if preview_fighter != null:
		preview_fighter.facing_right = player == 1
	if preview_fighter != null and int(preview_fighter.get_meta("character_index", -1)) != index:
		_apply_character_resources_to_fighter(preview_fighter, index)
		_apply_character_visual_facing(preview_fighter, index)
	elif preview_fighter != null:
		preview_fighter._apply_visual_facing()


func _apply_character_tile_style(tile: PanelContainer, index: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.043, 0.064, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = UI_OD_LINE
	style.corner_detail = 1

	if index == p1_character_index and index == p2_character_index and battle_mode == BattleMode.PVP:
		style.border_width_left = 5
		style.border_width_top = 5
		style.border_width_right = 5
		style.border_width_bottom = 5
		style.border_color = Color(0.95, 0.26, 1.0)
	elif index == p1_character_index:
		style.border_width_left = 5
		style.border_width_top = 5
		style.border_width_right = 5
		style.border_width_bottom = 5
		style.border_color = UI_OD_CYAN
	elif index == p2_character_index and battle_mode == BattleMode.PVP:
		style.border_width_left = 5
		style.border_width_top = 5
		style.border_width_right = 5
		style.border_width_bottom = 5
		style.border_color = UI_OD_RED

	if (index == p1_character_index and p1_character_locked) or (index == p2_character_index and p2_character_locked and battle_mode == BattleMode.PVP):
		style.bg_color = Color(0.08, 0.12, 0.08, 0.96)

	var selected := index == p1_character_index or (battle_mode == BattleMode.PVP and index == p2_character_index)
	if selected:
		style.shadow_color = Color(style.border_color.r, style.border_color.g, style.border_color.b, 0.62)
		style.shadow_size = 10
	tile.add_theme_stylebox_override("panel", style)
	_set_tile_selected_fx(tile, selected, style.border_color)


func _begin_match() -> void:
	if match_load_in_progress:
		return
	_set_battle_music_pause_effect(false)
	_unlock_music_from_input()
	match_load_in_progress = true
	flow_state = FlowState.LOADING_BATTLE
	_show_battle_loading_screen()
	p1_select_preview_fighter = null
	p2_select_preview_fighter = null
	await _let_loading_feedback_breathe()
	_load_battle_scene()
	_apply_selected_characters()
	p1_round_wins = 0
	p2_round_wins = 0
	round_winner = 0
	round_number = 0
	match_load_in_progress = false
	_hide_menu()
	_start_round()


func _let_loading_feedback_breathe() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.18).timeout


func _show_character_select_loading_screen() -> void:
	_play_menu_music()
	_set_menu(
		"加载选人界面",
		"正在准备角色预览、立绘与选择框。",
		[],
		[_make_loading_hint("首次打开选人界面时会加载角色模型，请稍等。")],
		1.0
	)
	_play_sfx("ui_switch")


func _show_battle_loading_screen() -> void:
	_play_stage_select_music()
	_set_menu(
		"加载战斗中",
		"正在创建战斗场景、角色模型和对战界面，请稍等。",
		[],
		[_make_loading_hint("首次进入可能需要几秒加载 FBX 模型和贴图。")],
		1.0
	)
	_play_sfx("ui_switch")


func _make_loading_hint(message: String) -> Control:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	var center := CenterContainer.new()
	center.add_child(LoadingSpinner.new())
	box.add_child(center)
	var progress_center := CenterContainer.new()
	progress_center.add_child(LoadingProgressBar.new())
	box.add_child(progress_center)
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	box.add_child(label)
	return box


func _start_round() -> void:
	_set_battle_music_pause_effect(false)
	_set_battle_music_lowpass(false)
	round_seconds = round_time_setting
	round_frame = 0
	round_winner = 0
	round_pause_frames = 0
	ko_slowmo_frames = 0
	ko_slowmo_tick_counter = 0
	_clear_projectiles()
	_reset_ai_control()
	_reset_fighters()
	round_number += 1
	round_intro_frames = ROUND_INTRO_FRAMES
	round_fight_sfx_played = false
	last_log = "第 %d 回合准备" % round_number
	flow_state = FlowState.ROUND_INTRO
	_hide_menu()
	_show_center_message("第 %d 回合" % round_number, Color(1.0, 0.9, 0.25))
	_set_fade_alpha(0.0)


func _start_fighting() -> void:
	_set_battle_music_lowpass(false)
	flow_state = FlowState.FIGHTING
	round_frame = 0
	last_log = "开战"
	_hide_center_overlay()


func _pause_game() -> void:
	if flow_state != FlowState.FIGHTING:
		return
	previous_flow_state = flow_state
	flow_state = FlowState.PAUSED
	_set_battle_music_pause_effect(true)
	_show_pause_menu(false)


func _resume_game() -> void:
	if flow_state != FlowState.PAUSED:
		return
	flow_state = previous_flow_state
	_set_battle_music_pause_effect(false)
	_hide_menu()


func _show_pause_menu(show_moves: bool) -> void:
	var extras: Array[Control] = []
	if show_moves:
		extras.append(_make_move_list_view())
	_set_menu(
		"暂停",
		"战斗已暂停。再次按 Enter 可以回到战斗。",
		[
			{"text": "查看 1P 出招表", "callable": Callable(self, "_show_pause_moves_for_player").bind(1)},
			{"text": "查看 2P 出招表", "callable": Callable(self, "_show_pause_moves_for_player").bind(2)},
			{"text": "回到战斗", "callable": Callable(self, "_resume_game")},
			{"text": "退出战斗", "callable": Callable(self, "_exit_battle")},
		],
		extras,
		0.42
	)


func _show_pause_moves() -> void:
	_show_pause_moves_for_player(move_list_player)


func _show_pause_moves_for_player(player: int) -> void:
	move_list_player = clampi(player, 1, 2)
	_show_pause_menu(true)


func _reset_fighters() -> void:
	var reset_meter := round_number <= 0
	p1.reset_for_round(P1_SPAWN, max_health, reset_meter)
	p2.reset_for_round(P2_SPAWN, max_health, reset_meter)
	p1.refresh_facing_from_opponent()
	p2.refresh_facing_from_opponent()
	_clear_battle_input()


func _reset_ai_control() -> void:
	ai_attack_cooldown = AI_DEFAULT_ATTACK_COOLDOWN
	ai_jump_cooldown = AI_DEFAULT_JUMP_COOLDOWN
	ai_command_steps.clear()
	ai_command_frame = 0


func _make_move_list_view() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	box.custom_minimum_size = Vector2(0.0, 350.0)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "出招表 - %dP" % move_list_player
	title.add_theme_font_size_override("font_size", 18)
	box.add_child(title)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	var p1_button := Button.new()
	p1_button.text = "看 1P 键位"
	p1_button.disabled = move_list_player == 1
	p1_button.pressed.connect(Callable(self, "_show_pause_moves_for_player").bind(1))
	tabs.add_child(p1_button)
	var p2_button := Button.new()
	p2_button.text = "看 2P 键位"
	p2_button.disabled = move_list_player == 2
	p2_button.pressed.connect(Callable(self, "_show_pause_moves_for_player").bind(2))
	tabs.add_child(p2_button)
	box.add_child(tabs)

	var normals := Label.new()
	normals.text = _normal_button_help_for_player(move_list_player)
	normals.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(normals)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0.0, MOVE_LIST_SCROLL_HEIGHT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 4)
	scroll.add_child(rows)

	for row_data in MOVE_LIST_ROWS:
		rows.add_child(_make_move_row(
			row_data["directions"] as Array,
			_button_label_for_player(String(row_data["button"]), move_list_player),
			String(row_data["name"])
		))

	return box


func _normal_button_help_for_player(player: int) -> String:
	if player == 2:
		return "方向键移动 | 小键盘1 拳 | 小键盘2 腿 | 小键盘1+2 投技 | 小键盘4 重拳 | 小键盘5 重腿 | 小键盘6 Dust"
	return "WASD 移动 | J 拳 | K 腿 | J+K 投技 | U 重拳 | I 重腿 | O Dust"


func _button_label_for_player(button_text: String, player: int) -> String:
	var parts := button_text.split("+", false)
	var labels: Array[String] = []
	for raw_part in parts:
		var part := String(raw_part).strip_edges()
		if not part.is_empty():
			labels.append(_single_button_label_for_player(part, player))
	return " + ".join(labels)


func _single_button_label_for_player(button_text: String, player: int) -> String:
	if player == 2:
		match button_text:
			"J":
				return "小键盘1"
			"K":
				return "小键盘2"
			"L":
				return "小键盘3"
			"U":
				return "小键盘4"
			"I":
				return "小键盘5"
			"O":
				return "小键盘6"
	return button_text


func _make_move_row(directions: Array, button_text: String, move_name: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.custom_minimum_size = Vector2(0.0, 24.0)

	var command_box := HBoxContainer.new()
	command_box.custom_minimum_size = Vector2(150.0, 22.0)
	command_box.add_theme_constant_override("separation", 1)
	for direction in directions:
		command_box.add_child(DirectionIcon.new(int(direction)))
	row.add_child(command_box)

	var button := Label.new()
	button.text = "+ %s" % button_text
	button.custom_minimum_size = Vector2(94.0, 22.0)
	row.add_child(button)

	var name := Label.new()
	name.text = move_name
	name.custom_minimum_size = Vector2(220.0, 22.0)
	row.add_child(name)

	return row



func _exit_battle() -> void:
	_reset_ai_control()
	if p2 != null:
		p2.input_buffer.clear_scripted_state()
	_unload_battle_scene()
	last_log = "已退出战斗"
	_show_main_menu()


func _update_round_intro_overlay() -> void:
	if round_intro_frames > ROUND_FIGHT_FRAMES:
		_show_center_message("第 %d 回合" % round_number, Color(1.0, 0.9, 0.25))
	else:
		if not round_fight_sfx_played:
			_play_sfx("ui_round_fight")
			round_fight_sfx_played = true
		_show_center_message("开战！", Color(0.35, 1.0, 0.42))
	_set_fade_alpha(0.0)


func _update_round_over_overlay() -> void:
	var fade_start := ROUND_FADE_FRAMES
	if round_pause_frames <= fade_start:
		_set_fade_alpha(1.0 - float(round_pause_frames) / float(fade_start))
	else:
		_set_fade_alpha(0.0)


func _apply_round_end_poses(winner: int, is_ko: bool) -> int:
	var pose_frames := 0
	if winner == 1:
		pose_frames = maxi(pose_frames, _play_round_victory(p1))
		pose_frames = maxi(pose_frames, p2.force_round_end_knockdown(ROUND_LOSER_KNOCKDOWN_FRAMES))
	elif winner == 2:
		pose_frames = maxi(pose_frames, _play_round_victory(p2))
		pose_frames = maxi(pose_frames, p1.force_round_end_knockdown(ROUND_LOSER_KNOCKDOWN_FRAMES))
	elif is_ko:
		pose_frames = maxi(pose_frames, p1.force_round_end_knockdown(ROUND_LOSER_KNOCKDOWN_FRAMES))
		pose_frames = maxi(pose_frames, p2.force_round_end_knockdown(ROUND_LOSER_KNOCKDOWN_FRAMES))
	return maxi(pose_frames, ROUND_VICTORY_MIN_FRAMES)


func _play_round_victory(fighter: FighterController) -> int:
	if fighter == null:
		return 0
	var victory_keys: Array[String] = []
	for key in ["victory_1", "victory_2", "victory_3"]:
		if fighter.has_visual_scene_key(key):
			victory_keys.append(key)
	if victory_keys.is_empty():
		return fighter.play_round_victory("idle")
	return fighter.play_round_victory(victory_keys[randi() % victory_keys.size()])


func _show_center_message(text: String, color: Color) -> void:
	if center_message_label == null:
		return
	center_message_label.text = text
	center_message_label.add_theme_color_override("font_color", color)
	center_message_label.visible = true


func _hide_center_overlay() -> void:
	if center_message_label != null:
		center_message_label.visible = false
	_set_fade_alpha(0.0)


func _set_fade_alpha(alpha: float) -> void:
	if screen_fade == null:
		return
	screen_fade.visible = alpha > 0.0
	screen_fade.color = Color(0.0, 0.0, 0.0, clampf(alpha, 0.0, 1.0))


func _show_match_over() -> void:
	_set_battle_music_pause_effect(false)
	_set_battle_music_lowpass(false)
	flow_state = FlowState.MATCH_OVER
	var message := "平局"
	if p1_round_wins >= wins_needed:
		message = "1P 赢得比赛"
	elif p2_round_wins >= wins_needed:
		message = "%s 赢得比赛" % p2.character_name
	_set_menu(
		"比赛结束",
		message,
		[
			{"text": "再战一场", "callable": Callable(self, "_begin_match")},
			{"text": "选择模式", "callable": Callable(self, "_show_mode_select")},
			{"text": "返回主菜单", "callable": Callable(self, "_show_main_menu")},
		],
		[]
	)


func _set_menu(title: String, subtitle: String, buttons: Array, extras: Array[Control], dim_alpha: float = 1.0) -> void:
	_hide_menu()
	menu_root = Control.new()
	menu_root.name = "MenuOverlay"
	menu_root.anchor_right = 1.0
	menu_root.anchor_bottom = 1.0
	hud_layer.add_child(menu_root)

	var dim := ColorRect.new()
	dim.color = Color(0.035, 0.04, 0.05, dim_alpha)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	menu_root.add_child(dim)
	_add_menu_ambient_fx(menu_root, clampf(0.45 + dim_alpha * 0.35, 0.45, 0.82))

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	var panel_width := MENU_PANEL_WIDTH
	var panel_height := MENU_PANEL_EXPANDED_HEIGHT if not extras.is_empty() else MENU_PANEL_HEIGHT
	panel.offset_left = -panel_width * 0.5
	panel.offset_right = panel_width * 0.5
	panel.offset_top = -panel_height * 0.5
	panel.offset_bottom = panel_height * 0.5
	panel.add_theme_stylebox_override("panel", _ui_panel_style(Color(0.045, 0.055, 0.075, 0.88), Color(0.56, 0.76, 1.0, 0.72), 2))
	menu_root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.88, 0.96, 1.0))
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.45, 1.0, 0.78))
	title_label.add_theme_constant_override("shadow_offset_x", 0)
	title_label.add_theme_constant_override("shadow_offset_y", 0)
	box.add_child(title_label)
	_pulse_menu_title(title_label)

	var subtitle_label := Label.new()
	subtitle_label.text = subtitle
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 16)
	box.add_child(subtitle_label)

	for extra in extras:
		box.add_child(extra)

	var button_parent: Control = box
	if not extras.is_empty() and buttons.size() > 2:
		var button_grid := GridContainer.new()
		button_grid.columns = 2
		button_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button_grid.add_theme_constant_override("h_separation", 12)
		button_grid.add_theme_constant_override("v_separation", 10)
		box.add_child(button_grid)
		button_parent = button_grid

	for button_data in buttons:
		var button := Button.new()
		button.text = String(button_data["text"])
		button.custom_minimum_size = Vector2(0.0, 42.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if button_data.has("sfx"):
			button.set_meta("click_sfx", String(button_data["sfx"]))
		_apply_kenney_button_style(button)
		button.pressed.connect(button_data["callable"])
		button_parent.add_child(button)

	_apply_ui_font(menu_root)


func _hide_menu() -> void:
	if menu_root != null:
		menu_root.queue_free()
		menu_root = null
	_clear_character_select_refs()


func _clear_character_select_refs() -> void:
	character_select_tiles.clear()
	stage_select_tiles.clear()
	_set_character_preview_rendering(false)
	character_preview_viewports.clear()
	p1_select_name_label = null
	p2_select_name_label = null
	p1_select_style_label = null
	p2_select_style_label = null
	p1_select_status_label = null
	p2_select_status_label = null
	p1_select_preview_fighter = null
	p2_select_preview_fighter = null


func _adjust_visual_facing_angles(delta: float) -> void:
	debug_face_right_degrees = fposmod(debug_face_right_degrees + delta, 360.0)
	debug_face_left_degrees = fposmod(debug_face_left_degrees - delta, 360.0)
	_apply_visual_facing_angles_to_active_fighters()
	_update_build_debug_label()


func _apply_visual_facing_angles_to_active_fighters() -> void:
	for fighter in [p1, p2, p1_select_preview_fighter, p2_select_preview_fighter]:
		if fighter != null and is_instance_valid(fighter):
			_apply_character_visual_facing(fighter, int(fighter.get_meta("character_index", 0)))
			fighter.refresh_facing_from_opponent()
			if fighter.opponent == null:
				fighter._apply_visual_facing()


func _update_build_debug_label() -> void:
	if not SHOW_DEBUG_HUD or build_debug_label == null:
		return
	var music_status := "Music n/a"
	if music_manager != null and music_manager.player != null:
		var stream_name := "null"
		if music_manager.player.stream != null:
			stream_name = music_manager.player.stream.resource_path
			if stream_name.is_empty():
				stream_name = music_manager.player.stream.get_class()
		var trace_text := " > ".join(music_manager.debug_log)
		music_status = "Music %s\nplay=%s active=%s pos=%.2f vol=%.1f key=%s unlocked=%s desired=%s retry=%d attempts=%d\nevt=%s\ntrace=%s" % [
			stream_name,
			str(music_manager.player.playing),
			str(music_manager.player.has_stream_playback()),
			music_manager.player.get_playback_position(),
			music_manager.player.volume_db,
			music_manager.current_track,
			str(music_manager.audio_unlocked),
			str(music_manager.desired_playing),
			music_manager.retry_frames_left,
			music_manager.start_attempts,
			music_manager.debug_last_event,
			trace_text,
		]
	build_debug_label.text = "BUILD %s | 朝向 R %.0f / L %.0f | F9/F10 调整\n%s" % [
		BUILD_ID,
		debug_face_right_degrees,
		debug_face_left_degrees,
		music_status,
	]
	build_debug_label.size = Vector2(860, 160)
	build_debug_label.custom_minimum_size = Vector2(860, 160)
	build_debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	build_debug_label.clip_text = false
	build_debug_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	build_debug_label.position = Vector2(12, 12)
	build_debug_label.z_index = 100
	build_debug_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	build_debug_label.add_theme_font_size_override("font_size", 12)
	build_debug_label.top_level = true
	build_debug_label.move_to_front()


func _apply_ui_font(root: Node) -> void:
	if ui_font == null:
		return
	if root is Control:
		var control := root as Control
		control.add_theme_font_override("font", ui_font)
	for child in root.get_children():
		_apply_ui_font(child)


func _load_ui_font() -> void:
	if ResourceLoader.exists(UI_FONT_PATH, "FontFile"):
		ui_font = ResourceLoader.load(UI_FONT_PATH, "FontFile") as FontFile
	if ui_font == null:
		ui_font = FontFile.new()
		var error := ui_font.load_dynamic_font(UI_FONT_PATH)
		if error != OK:
			ui_font = null
	if ui_font == null:
		push_warning("Failed to load UI font: %s" % UI_FONT_PATH)


func _check_round_end() -> void:
	if p1.health <= 0 and p2.health <= 0:
		_finish_round(0, "双 K.O.", true)
		return
	if p1.health <= 0:
		_finish_round(2, "%s 拿下本回合" % p2.character_name, true)
		return
	if p2.health <= 0:
		_finish_round(1, "1P 拿下本回合", true)
		return
	if round_seconds > 0 and round_frame >= round_seconds * 60:
		if p1.health > p2.health:
			_finish_round(1, "时间到：1P 体力更多", false)
		elif p2.health > p1.health:
			_finish_round(2, "时间到：%s 体力更多" % p2.character_name, false)
		else:
			_finish_round(0, "时间到：平局", false)


func _finish_round(winner: int, message: String, is_ko: bool) -> void:
	if flow_state != FlowState.FIGHTING:
		return
	round_winner = winner
	if winner == 1:
		p1_round_wins += 1
	elif winner == 2:
		p2_round_wins += 1
	last_log = message
	flow_state = FlowState.ROUND_OVER
	_set_battle_music_lowpass(is_ko)
	round_pause_frames = ROUND_RESULT_FRAMES
	if is_ko:
		round_pause_frames += KO_SLOWMO_FRAMES
		ko_slowmo_frames = KO_SLOWMO_FRAMES
		ko_slowmo_tick_counter = 0
		_play_sfx("ui_ko_finish" if winner == 1 else "ui_fail")
	else:
		ko_slowmo_frames = 0
		ko_slowmo_tick_counter = 0
	p2.input_buffer.clear_scripted_state()
	_reset_ai_control()
	_clear_projectiles()
	var pose_frames := _apply_round_end_poses(winner, is_ko)
	round_pause_frames = maxi(round_pause_frames, pose_frames + ROUND_FADE_FRAMES)
	_show_center_message("K.O." if is_ko else "时间到", Color(1.0, 0.24, 0.16))
	_set_fade_alpha(0.0)


func _update_ko_slowmo() -> void:
	if p1 == null or p2 == null:
		return
	var should_tick := true
	if ko_slowmo_frames > 0:
		ko_slowmo_frames -= 1
		ko_slowmo_tick_counter += 1
		should_tick = ko_slowmo_tick_counter >= KO_SLOWMO_TICK_INTERVAL
		if should_tick:
			ko_slowmo_tick_counter = 0
	if not should_tick:
		return
	p1.tick_round_over_visual()
	p2.tick_round_over_visual()
	_update_fighter_shadows()
	_update_camera()


func _resolve_fighter_push() -> void:
	if p1 == null or p2 == null:
		return
	if p1.state_name() == "knockdown" or p2.state_name() == "knockdown":
		return
	var dx := p2.global_position.x - p1.global_position.x
	var distance := absf(dx)
	var min_spacing := FighterController.MIN_BODY_SPACING
	if distance >= min_spacing:
		return
	var sign := 1.0 if dx >= 0.0 else -1.0
	if sign == 0.0:
		sign = 1.0
	var correction := (min_spacing - distance) * 0.5
	if p1.is_in_control():
		p1.global_position.x = clampf(p1.global_position.x - correction * sign, p1.stage_min_x, p1.stage_max_x)
	if p2.is_in_control():
		p2.global_position.x = clampf(p2.global_position.x + correction * sign, p2.stage_min_x, p2.stage_max_x)
	p1.refresh_facing_from_opponent()
	p2.refresh_facing_from_opponent()


func _on_projectile_requested(move: MoveDefinition, owner: FighterController, spawn_position: Vector3, direction: float) -> void:
	if battle_root == null or move == null or owner == null:
		return
	var target := p2 if owner == p1 else p1
	if target == null:
		return
	var projectile := FightingProjectileScript.new()
	projectile.setup(move, owner, target, spawn_position, direction)
	battle_root.add_child(projectile)
	projectiles.append(projectile)
	last_log = "%s 发出 %s" % [owner.character_name, move.display_name]


func _on_cinematic_requested(move: MoveDefinition, attacker: FighterController, defender: FighterController) -> void:
	if flow_state != FlowState.FIGHTING or move == null or attacker == null or defender == null:
		return
	if not pending_cinematic.is_empty():
		return
	pending_cinematic = {
		"move": move,
		"attacker": attacker,
		"defender": defender,
	}
	cinematic_damage_settled = false
	cinematic_frames_left = maxi(1, move.cinematic_duration_frames)
	flow_state = FlowState.CINEMATIC
	_reset_ai_control()
	_clear_battle_input()
	_set_music_volume(-24.0)
	_show_cinematic_overlay(move, attacker, defender)


func _show_cinematic_overlay(move: MoveDefinition, attacker: FighterController, defender: FighterController) -> void:
	_hide_cinematic_overlay()
	cinematic_layer = CanvasLayer.new()
	cinematic_layer.name = "CinematicLayer"
	cinematic_layer.layer = hud_layer.layer - 1 if hud_layer != null else 19
	add_child(cinematic_layer)
	cinematic_root = Control.new()
	cinematic_root.name = "CinematicOverlay"
	cinematic_root.anchor_right = 1.0
	cinematic_root.anchor_bottom = 1.0
	cinematic_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cinematic_layer.add_child(cinematic_root)

	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.92)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	cinematic_root.add_child(background)

	var loaded_video := false
	if not move.cinematic_video_path.is_empty() and ResourceLoader.exists(move.cinematic_video_path):
		var video_stream := ResourceLoader.load(move.cinematic_video_path) as VideoStream
		if video_stream != null:
			cinematic_video_player = VideoStreamPlayer.new()
			cinematic_video_player.name = "CinematicVideo"
			cinematic_video_player.stream = video_stream
			cinematic_video_player.anchor_right = 1.0
			cinematic_video_player.anchor_bottom = 1.0
			cinematic_video_player.finished.connect(_finish_cinematic)
			cinematic_root.add_child(cinematic_video_player)
			cinematic_video_player.play()
			loaded_video = true

	if not loaded_video:
		var center := CenterContainer.new()
		center.anchor_right = 1.0
		center.anchor_bottom = 1.0
		cinematic_root.add_child(center)
		var title := Label.new()
		title.text = "%s\n%s" % [attacker.character_name, move.display_name]
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 46)
		title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.24))
		center.add_child(title)
		_apply_ui_font(title)

	var info := Label.new()
	info.text = "演出命中：%s -> %s" % [attacker.character_name, defender.character_name]
	info.anchor_right = 1.0
	info.anchor_top = 1.0
	info.anchor_bottom = 1.0
	info.offset_left = 32.0
	info.offset_right = -32.0
	info.offset_top = -58.0
	info.offset_bottom = -24.0
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 20)
	info.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0, 0.9))
	cinematic_root.add_child(info)
	_apply_ui_font(info)
	last_log = "%s 命中 %s，进入演出" % [attacker.character_name, move.display_name]


func _update_cinematic() -> void:
	if pending_cinematic.is_empty():
		_finish_cinematic()
		return
	cinematic_frames_left -= 1
	if cinematic_frames_left <= 0:
		_finish_cinematic()


func _finish_cinematic() -> void:
	if pending_cinematic.is_empty():
		return
	var move := pending_cinematic.get("move") as MoveDefinition
	var attacker := pending_cinematic.get("attacker") as FighterController
	var defender := pending_cinematic.get("defender") as FighterController
	if not cinematic_damage_settled:
		cinematic_damage_settled = true
		if move != null and attacker != null and defender != null and is_instance_valid(defender):
			var dealt := defender.receive_cinematic_damage(move, attacker, move.cinematic_damage)
			last_log = "%s 演出结算：%s 伤害 %d" % [attacker.character_name, move.display_name, dealt]
			_update_hud()
			if defender.health <= 0 and cinematic_root != null:
				cinematic_frames_left = 42
				_show_cinematic_ko_hold()
				return
	pending_cinematic.clear()
	cinematic_frames_left = 0
	cinematic_damage_settled = false
	_hide_cinematic_overlay()
	_set_music_volume(-6.0)
	flow_state = FlowState.FIGHTING
	_clear_battle_input()
	_update_hud()
	_check_round_end()


func _show_cinematic_ko_hold() -> void:
	if cinematic_root == null:
		return
	if cinematic_video_player != null:
		cinematic_video_player.paused = true
	if cinematic_root.get_node_or_null("CinematicKO") != null:
		return
	var ko_label := Label.new()
	ko_label.name = "CinematicKO"
	ko_label.text = "K.O."
	ko_label.anchor_left = 0.5
	ko_label.anchor_right = 0.5
	ko_label.anchor_top = 0.5
	ko_label.anchor_bottom = 0.5
	ko_label.offset_left = -220.0
	ko_label.offset_right = 220.0
	ko_label.offset_top = -86.0
	ko_label.offset_bottom = 86.0
	ko_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ko_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ko_label.add_theme_font_size_override("font_size", 76)
	ko_label.add_theme_color_override("font_color", Color(1.0, 0.18, 0.08))
	ko_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	ko_label.add_theme_constant_override("shadow_offset_x", 5)
	ko_label.add_theme_constant_override("shadow_offset_y", 5)
	cinematic_root.add_child(ko_label)
	_apply_ui_font(ko_label)


func _hide_cinematic_overlay() -> void:
	if cinematic_video_player != null:
		if cinematic_video_player.finished.is_connected(_finish_cinematic):
			cinematic_video_player.finished.disconnect(_finish_cinematic)
		cinematic_video_player.stop()
		cinematic_video_player = null
	if cinematic_root != null:
		cinematic_root.queue_free()
		cinematic_root = null
	if cinematic_layer != null:
		cinematic_layer.queue_free()
		cinematic_layer = null


func _clear_battle_input(clear_scripted: bool = true) -> void:
	if p1 != null:
		p1.input_buffer.clear()
	if p2 != null:
		p2.input_buffer.clear()
		if clear_scripted:
			p2.input_buffer.clear_scripted_state()


func _update_projectiles() -> void:
	if projectiles.is_empty():
		return
	for i in range(projectiles.size() - 1, -1, -1):
		var projectile = projectiles[i]
		if projectile == null or not is_instance_valid(projectile):
			projectiles.remove_at(i)
			continue
		if not projectile.tick():
			projectile.expire()
			projectiles.remove_at(i)

	for i in range(projectiles.size()):
		var a = projectiles[i]
		if a == null or not is_instance_valid(a) or not a.active:
			continue
		for j in range(i + 1, projectiles.size()):
			var b = projectiles[j]
			if b == null or not is_instance_valid(b) or not b.active:
				continue
			if a.collides_with_projectile(b):
				a.expire()
				b.expire()
				last_log = "双方飞行道具互相抵消"
				break

	_prune_inactive_projectiles()


func _prune_inactive_projectiles() -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var projectile = projectiles[i]
		if projectile == null or not is_instance_valid(projectile) or not projectile.active:
			projectiles.remove_at(i)


func _clear_projectiles() -> void:
	for projectile in projectiles:
		if projectile != null and is_instance_valid(projectile):
			projectile.expire()
	projectiles.clear()


func _is_match_over() -> bool:
	return p1_round_wins >= wins_needed or p2_round_wins >= wins_needed


func _update_ai_input() -> void:
	var state := _empty_ai_state()
	if p2.health <= 0 or p2.state_name() in ["hitstun", "knockdown", "block", "attack"]:
		ai_command_steps.clear()
		p2.input_buffer.set_scripted_state(state)
		return

	if not ai_command_steps.is_empty():
		p2.input_buffer.set_scripted_state(_tick_ai_command())
		return

	var distance := absf(p1.global_position.x - p2.global_position.x)
	var p1_is_attacking := p1.state_name() == "attack"
	var p1_is_defending := p1.state_name() in ["block", "crouch"] or _is_fighter_holding_back(p1)
	var p1_is_retreating := _is_fighter_holding_back(p1) and distance > AI_MID_RANGE
	ai_attack_cooldown = maxi(0, ai_attack_cooldown - 1)
	ai_jump_cooldown = maxi(0, ai_jump_cooldown - 1)

	if _try_ai_reaction(distance, p1_is_attacking):
		p2.input_buffer.set_scripted_state(_tick_ai_command() if not ai_command_steps.is_empty() else _ai_defense_state())
		return

	if ai_attack_cooldown <= 0:
		_choose_ai_attack(distance, p1_is_defending, p1_is_retreating)
		if not ai_command_steps.is_empty():
			p2.input_buffer.set_scripted_state(_tick_ai_command())
			return

	state = _ai_neutral_state(distance, p1_is_retreating)
	p2.input_buffer.set_scripted_state(state)


func _try_ai_reaction(distance: float, p1_is_attacking: bool) -> bool:
	if p1.is_charging_projectile() and ai_attack_cooldown <= 0:
		if distance <= AI_MID_RANGE:
			_queue_ai_command([6, 2, 3], "k", 54)
			last_log = "电脑看见蓄力，突进打断"
		else:
			var counter_projectile := _ai_pick_projectile("zoning")
			if counter_projectile != null:
				_queue_ai_move(counter_projectile, 56)
				last_log = "电脑看见蓄力，用飞行道具抢节奏"
			else:
				_queue_ai_command([6, 2, 3], "i", 62)
				last_log = "电脑看见蓄力，用对空突进抢节奏"
		return true

	if p1.state_name() == "jump" and distance < 1.65 and ai_attack_cooldown <= 0:
		var anti_air_projectile := _ai_pick_projectile("anti_air")
		if anti_air_projectile != null and randi() % 2 == 0:
			_queue_ai_move(anti_air_projectile, 52)
			last_log = "电脑看跳跃，用对空飞行道具"
		else:
			_queue_ai_command([6, 2, 3], "i", 52)
			last_log = "电脑看跳跃，用升龙对空"
		return true

	if distance > AI_MID_RANGE and ai_jump_cooldown <= 0 and ai_attack_cooldown <= 0 and randi() % 140 == 0:
		var air_pressure := _ai_pick_projectile("air_down", true)
		if air_pressure != null:
			_queue_ai_air_projectile(air_pressure, 68, true)
			last_log = "电脑跳退后用空中飞行道具压制"
			return true

	if not p1_is_attacking:
		return false

	if p1.current_move != null and distance <= p1.current_move.hit_range + 0.35:
		if ai_attack_cooldown <= 0 and p2.meter >= METER_STOCK_VALUE and randi() % 5 == 0:
			_queue_ai_command([6, 2, 3], "i", 62)
			last_log = "电脑防守反击"
			return true
		return true

	if distance < 1.55 and ai_attack_cooldown <= 0 and randi() % 2 == 0:
		_queue_ai_command([5], "u", 46)
		last_log = "电脑差合重拳反击"
		return true

	return false


func _ai_neutral_state(distance: float, p1_is_retreating: bool) -> Dictionary:
	var state := _empty_ai_state()
	if distance > AI_MID_RANGE:
		if p1_is_retreating and _ai_has_projectile("any_ground") and randi() % 3 != 0:
			_ai_hold_back(state)
		else:
			_ai_hold_toward(state)
		if distance > AI_LONG_RANGE and ai_jump_cooldown <= 0 and randi() % 90 == 0:
			state["up"] = true
			ai_jump_cooldown = 150
	elif distance < AI_CLOSE_RANGE * 0.72:
		_ai_hold_back(state)
	else:
		if randi() % 75 == 0:
			state["down"] = true
	return state


func _ai_defense_state() -> Dictionary:
	var state := _empty_ai_state()
	_ai_hold_back(state)
	if p1.current_move != null and p1.current_move.attack_level == MoveDefinition.AttackLevel.LOW:
		state["down"] = true
	return state


func _ai_hold_toward(state: Dictionary) -> void:
	if p1.global_position.x < p2.global_position.x:
		state["left"] = true
	else:
		state["right"] = true


func _ai_hold_back(state: Dictionary) -> void:
	if p1.global_position.x < p2.global_position.x:
		state["right"] = true
	else:
		state["left"] = true


func _choose_ai_attack(distance: float, p1_is_defending: bool, p1_is_retreating: bool) -> void:
	if p2.meter >= METER_STOCK_VALUE * 2 and distance < 1.55 and randi() % 4 == 0:
		_queue_ai_command([6, 3, 2, 1, 4, 6], "k", 92)
		last_log = "电脑抓近身机会放超必杀"
		return

	if distance < AI_THROW_RANGE and p1.is_on_floor() and randi() % (2 if p1_is_defending else 4) == 0:
		_queue_ai_command([5], "j+k", 58)
		last_log = "电脑主动近身投技"
		return

	if p1.state_name() == "jump" and distance > 1.05:
		var anti_air_projectile := _ai_pick_projectile("anti_air")
		if anti_air_projectile != null:
			_queue_ai_move(anti_air_projectile, 58)
			last_log = "电脑用对空飞行道具限制跳跃"
			return

	if p1_is_retreating:
		var zoning_projectile := _ai_pick_projectile("zoning")
		if zoning_projectile != null:
			_queue_ai_move(zoning_projectile, 58, true)
			last_log = "电脑看玩家拉开距离，发波牵制"
			return

	if distance > AI_MID_RANGE and ai_jump_cooldown <= 0 and randi() % 4 == 0:
		var air_pressure := _ai_pick_projectile("air_down", true)
		if air_pressure != null:
			_queue_ai_air_projectile(air_pressure, 72, p1_is_retreating)
			last_log = "电脑主动跳起用空中波压制落点"
			return

	if distance > AI_LONG_RANGE:
		var long_projectile := _ai_pick_projectile("zoning")
		if long_projectile != null and randi() % 3 != 0:
			_queue_ai_move(long_projectile, 54)
			last_log = "电脑远距离发波动拳牵制"
		elif p2.meter >= METER_STOCK_VALUE:
			_queue_ai_command([2, 3, 6, 2, 3, 6], "j", 70)
			last_log = "电脑远距离用普通必杀牵制"
		else:
			_queue_ai_command([6], "u", 34)
			last_log = "电脑前进重拳试探"
		return

	if distance > AI_MID_RANGE:
		var mid_projectile := _ai_pick_projectile("mid")
		if mid_projectile != null and randi() % 3 == 0:
			_queue_ai_move(mid_projectile, 48)
			last_log = "电脑中距离轻波动压制"
		elif p2.meter >= METER_STOCK_VALUE and randi() % 2 == 0:
			_queue_ai_command([2, 3, 6], "k", 58)
			last_log = "电脑用突进踢抢距离"
		else:
			_queue_ai_command([6], "u", 42)
			last_log = "电脑中距离重拳压制"
		return

	if p1_is_defending and distance < AI_CLOSE_RANGE and randi() % 2 == 0:
		_queue_ai_command([5], "j+k", 58)
		last_log = "电脑用投技破防"
		return

	if p1_is_defending and distance < 1.05:
		var low_projectile := _ai_pick_projectile("low")
		if low_projectile != null and randi() % 2 == 0:
			_queue_ai_move(low_projectile, 56)
			last_log = "电脑用下段飞行道具破站防"
		else:
			_queue_ai_command([2], "i", 52)
			last_log = "电脑用下段重踢破站防"
		return

	if distance < AI_CLOSE_RANGE:
		var close_roll := randi() % 4
		if close_roll == 0:
			_queue_ai_command([5], "j+k", 54)
		elif close_roll == 1:
			_queue_ai_command([2], "k", 34)
		elif close_roll == 2:
			_queue_ai_command([5], "k", 30)
		else:
			_queue_ai_command([5], "j", 28)
		return

	var roll := randi() % 5
	if roll == 0:
		_queue_ai_command([2], "i", 48)
	elif roll == 1:
		_queue_ai_command([5], "u", 48)
	elif roll == 2:
		_queue_ai_command([5], "i", 52)
	elif roll == 3 and p2.meter >= METER_STOCK_VALUE:
		_queue_ai_command([2, 3, 6], "k", 58)
	else:
		_queue_ai_command([5], "k", 32)


func _ai_pick_projectile(role: String, allow_air_setup: bool = false) -> MoveDefinition:
	var candidates: Array[MoveDefinition] = []
	for move in p2.moves:
		if not _ai_can_use_move(move, allow_air_setup):
			continue
		if not move.projectile_enabled:
			continue
		if _ai_projectile_matches_role(move, role):
			candidates.append(move)
	if candidates.is_empty():
		return null
	candidates.sort_custom(_sort_ai_projectiles_by_speed)
	if role in ["anti_air", "low"]:
		return candidates.back()
	return candidates[randi() % candidates.size()]


func _ai_has_projectile(role: String) -> bool:
	return _ai_pick_projectile(role) != null


func _ai_projectile_matches_role(move: MoveDefinition, role: String) -> bool:
	match role:
		"air_down":
			return move.air_only and move.projectile_vertical_speed < -0.1
		"anti_air":
			return move.projectile_vertical_speed > 0.1 or move.attack_level == MoveDefinition.AttackLevel.HIGH
		"low":
			return move.attack_level == MoveDefinition.AttackLevel.LOW
		"mid":
			return not move.air_only and not move.projectile_ground_hug
		"zoning":
			return not move.air_only
		"any_ground":
			return not move.air_only
	return true


func _ai_can_use_move(move: MoveDefinition, allow_air_setup: bool = false) -> bool:
	if move == null:
		return false
	if move.meter_cost > 0 and p2.meter < move.meter_cost:
		return false
	if move.air_only and p2.is_on_floor() and not allow_air_setup:
		return false
	if move.ground_only and not p2.is_on_floor():
		return false
	return true


func _sort_ai_projectiles_by_speed(a: MoveDefinition, b: MoveDefinition) -> bool:
	return a.projectile_speed < b.projectile_speed


func _queue_ai_move(move: MoveDefinition, cooldown: int, retreat_first: bool = false) -> void:
	ai_command_steps.clear()
	if retreat_first:
		ai_command_steps.append({"direction": 4, "button": "", "frames": 10})
	var directions := _append_ai_motion_steps(move.motion)
	_finish_ai_command(int(directions.back()), move.button.to_lower(), 2, cooldown)


func _queue_ai_air_projectile(move: MoveDefinition, cooldown: int, jump_back: bool = false) -> void:
	ai_command_steps.clear()
	var jump_direction := 7 if jump_back else 9
	ai_command_steps.append({"direction": jump_direction, "button": "", "frames": 14})
	ai_command_steps.append({"direction": 8, "button": "", "frames": 4})
	var directions := _append_ai_motion_steps(move.motion)
	_finish_ai_command(int(directions.back()), move.button.to_lower(), 3, cooldown)
	ai_jump_cooldown = 145


func _motion_to_direction_array(motion: String) -> Array:
	if motion.is_empty():
		return [5]
	var directions := []
	for index in range(motion.length()):
		directions.append(int(motion[index]))
	return directions


func _queue_ai_command(directions: Array, button: String, cooldown: int) -> void:
	ai_command_steps.clear()
	for direction in directions:
		ai_command_steps.append({"direction": int(direction), "button": "", "frames": 3})
	_finish_ai_command(int(directions.back()), button, 2, cooldown)


func _append_ai_motion_steps(motion: String) -> Array:
	var directions := _motion_to_direction_array(motion)
	for direction in directions:
		ai_command_steps.append({"direction": int(direction), "button": "", "frames": 3})
	return directions


func _finish_ai_command(direction: int, button: String, frames: int, cooldown: int) -> void:
	ai_command_steps.append({"direction": direction, "button": button, "frames": frames})
	ai_command_frame = 0
	ai_attack_cooldown = cooldown


func _tick_ai_command() -> Dictionary:
	var state := _empty_ai_state()
	if ai_command_steps.is_empty():
		return state

	var step := ai_command_steps.front() as Dictionary
	state = _ai_state_for_relative_direction(int(step.get("direction", 5)))
	var button := String(step.get("button", ""))
	if not button.is_empty():
		for button_name in button.split("+", false):
			state[String(button_name).strip_edges()] = true

	ai_command_frame += 1
	if ai_command_frame >= int(step.get("frames", 1)):
		ai_command_steps.pop_front()
		ai_command_frame = 0
	return state


func _ai_state_for_relative_direction(direction: int) -> Dictionary:
	var state := _empty_ai_state()
	var horizontal := 0
	if direction in [1, 4, 7]:
		horizontal = -1
	elif direction in [3, 6, 9]:
		horizontal = 1

	if horizontal < 0:
		state["left" if p2.facing_right else "right"] = true
	elif horizontal > 0:
		state["right" if p2.facing_right else "left"] = true

	if direction in [7, 8, 9]:
		state["up"] = true
	elif direction in [1, 2, 3]:
		state["down"] = true
	return state


func _is_fighter_holding_back(fighter: FighterController) -> bool:
	return fighter.last_direction in [1, 4, 7]


func _empty_ai_state() -> Dictionary:
	var state := {}
	for key in AI_STATE_KEYS:
		state[key] = false
	return state


func _on_move_started(move: MoveDefinition, player_name: String) -> void:
	last_log = "%s 出招 %s：发生 %d 主动 %d 收招 %d" % [
		player_name,
		move.command_text(),
		move.startup_frames,
		move.active_frames,
		move.recovery_frames,
	]


func _on_hit_confirmed(move: MoveDefinition, player_name: String) -> void:
	var defender := p2 if player_name == "P1" else p1
	var combo_suffix := ""
	if defender != null and defender.combo_count > 1:
		combo_suffix = " | 连段 %s" % defender.combo_text()
	last_log = "%s 命中：%s 基础伤害=%d%s" % [player_name, move.display_name, move.damage, combo_suffix]


func _on_combat_event(message: String) -> void:
	last_log = message


func _play_sfx(sound_key: String, source_fighter: FighterController = null) -> void:
	if sound_key == "footstep":
		_play_footstep_sfx(source_fighter)
		return
	if sfx_players.is_empty():
		return
	var stream := _sfx_stream(sound_key)
	if stream == null:
		return
	var player := sfx_players[sfx_player_index] as AudioStreamPlayer
	sfx_player_index = (sfx_player_index + 1) % sfx_players.size()
	player.stop()
	player.stream = stream
	player.volume_db = SFX_BASE_VOLUME_DB + float(SFX_VOLUME_OFFSETS_DB.get(sound_key, 0.0))
	player.pitch_scale = randf_range(0.96, 1.04)
	player.play()


func _play_footstep_sfx(source_fighter: FighterController) -> void:
	if source_fighter == null:
		return
	var fighter_key := source_fighter.action_prefix
	var player := footstep_players.get(fighter_key) as AudioStreamPlayer
	if player == null:
		var stream := _sfx_stream("footstep")
		if stream == null:
			return
		if stream is AudioStreamWAV:
			var wav_stream := stream as AudioStreamWAV
			wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			wav_stream.loop_begin = 0
			wav_stream.loop_end = int(round(wav_stream.get_length() * float(wav_stream.mix_rate)))
		player = AudioStreamPlayer.new()
		player.name = "Footstep_%s" % fighter_key
		player.bus = "Master"
		player.stream = stream
		player.autoplay = false
		player.pitch_scale = 1.0
		add_child(player)
		footstep_players[fighter_key] = player
	player.volume_db = SFX_BASE_VOLUME_DB + float(SFX_VOLUME_OFFSETS_DB.get("footstep", 0.0))
	var should_play := flow_state == FlowState.FIGHTING and source_fighter.is_in_control() and source_fighter.is_on_floor() and absf(source_fighter.velocity.x) >= 0.08
	if should_play:
		if not player.playing:
			player.play(0.0)
	else:
		if player.playing:
			player.stop()


func _sync_footstep_players() -> void:
	for fighter_key in footstep_players.keys():
		var player := footstep_players[fighter_key] as AudioStreamPlayer
		if player == null:
			continue
		var fighter := p1 if fighter_key == "p1" else p2 if fighter_key == "p2" else null
		var should_play := flow_state == FlowState.FIGHTING and fighter != null and fighter.is_in_control() and fighter.is_on_floor() and absf(fighter.velocity.x) >= 0.08
		player.volume_db = SFX_BASE_VOLUME_DB + float(SFX_VOLUME_OFFSETS_DB.get("footstep", 0.0))
		if should_play:
			if not player.playing:
				player.play(0.0)
		else:
			if player.playing:
				player.stop()


func _sfx_stream(sound_key: String) -> AudioStream:
	var cache_key := sound_key
	if SOUND_PATHS.has(sound_key):
		var sound_path_data = SOUND_PATHS[sound_key]
		if sound_path_data is Array:
			var paths := sound_path_data as Array
			if paths.is_empty():
				return null
			cache_key = String(paths[randi() % paths.size()])
		else:
			cache_key = String(sound_path_data)
	if sound_stream_cache.has(cache_key):
		return sound_stream_cache[cache_key] as AudioStream
	var stream: AudioStream = null
	if SOUND_PATHS.has(sound_key):
		stream = ResourceLoader.load(cache_key) as AudioStream
	sound_stream_cache[cache_key] = stream
	return stream


func _play_menu_music() -> void:
	if music_manager != null:
		music_manager.play_menu()


func _play_character_select_music() -> void:
	if music_manager != null:
		music_manager.play_character_select()


func _play_stage_select_music() -> void:
	if music_manager != null:
		music_manager.play_stage_select()


func _play_battle_music() -> void:
	if music_manager != null:
		music_manager.play_battle(-6.0, selected_stage_name)


func _set_battle_music_lowpass(enabled: bool) -> void:
	if music_manager != null:
		music_manager.set_battle_lowpass(enabled)


func _set_battle_music_pause_effect(enabled: bool) -> void:
	if music_manager != null:
		music_manager.set_pause_effect(enabled)


func _stop_battle_music() -> void:
	if music_manager != null:
		music_manager.stop_music()


func _set_music_volume(volume_db: float) -> void:
	if music_manager != null:
		music_manager.set_music_volume(volume_db)


func _unlock_music_from_input() -> void:
	if music_manager != null:
		music_manager.unlock_audio_from_input()


func _input(event: InputEvent) -> void:
	if (event is InputEventKey and event.pressed and not event.echo) or (event is InputEventMouseButton and event.pressed):
		_unlock_music_from_input()
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if SHOW_DEBUG_HUD and key_event.keycode == KEY_F9:
			_adjust_visual_facing_angles(-10.0)
			get_viewport().set_input_as_handled()
		elif SHOW_DEBUG_HUD and key_event.keycode == KEY_F10:
			_adjust_visual_facing_angles(10.0)
			get_viewport().set_input_as_handled()
		elif flow_state == FlowState.CHARACTER_SELECT:
			_handle_character_select_input(key_event)
			get_viewport().set_input_as_handled()
		elif flow_state == FlowState.STAGE_SELECT:
			_handle_stage_select_input(key_event)
			get_viewport().set_input_as_handled()
		elif key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER:
			if flow_state == FlowState.FIGHTING:
				_pause_game()
				get_viewport().set_input_as_handled()
			elif flow_state == FlowState.CINEMATIC:
				get_viewport().set_input_as_handled()
			elif flow_state == FlowState.PAUSED:
				_resume_game()
				get_viewport().set_input_as_handled()
		elif key_event.keycode == KEY_R and flow_state in [FlowState.FIGHTING, FlowState.ROUND_OVER, FlowState.MATCH_OVER]:
			_begin_match()
		elif key_event.keycode == KEY_T and flow_state == FlowState.FIGHTING:
			_fill_tension()


func _handle_character_select_input(key_event: InputEventKey) -> void:
	match key_event.keycode:
		KEY_A:
			_move_character_cursor(1, -1, 0)
		KEY_D:
			_move_character_cursor(1, 1, 0)
		KEY_W:
			_move_character_cursor(1, 0, -1)
		KEY_S:
			_move_character_cursor(1, 0, 1)
		KEY_J:
			_lock_character(1)
		KEY_LEFT:
			if battle_mode == BattleMode.PVP:
				_move_character_cursor(2, -1, 0)
		KEY_RIGHT:
			if battle_mode == BattleMode.PVP:
				_move_character_cursor(2, 1, 0)
		KEY_UP:
			if battle_mode == BattleMode.PVP:
				_move_character_cursor(2, 0, -1)
		KEY_DOWN:
			if battle_mode == BattleMode.PVP:
				_move_character_cursor(2, 0, 1)
		KEY_1, KEY_KP_1:
			if battle_mode == BattleMode.PVP:
				_lock_character(2)
		KEY_ESCAPE:
			_show_mode_select()


func _handle_stage_select_input(key_event: InputEventKey) -> void:
	match key_event.keycode:
		KEY_A, KEY_LEFT:
			_move_stage_cursor(-1, 0)
		KEY_D, KEY_RIGHT:
			_move_stage_cursor(1, 0)
		KEY_W, KEY_UP:
			_move_stage_cursor(0, -1)
		KEY_S, KEY_DOWN:
			_move_stage_cursor(0, 1)
		KEY_J, KEY_ENTER, KEY_KP_ENTER, KEY_1, KEY_KP_1:
			_confirm_stage_selection()
		KEY_R:
			_choose_random_stage_and_begin()
		KEY_ESCAPE:
			_show_character_select()


func _fill_tension() -> void:
	p1.meter = METER_MAX_VALUE
	p2.meter = METER_MAX_VALUE
	last_log = "双方怒气已加满"


func _update_camera() -> void:
	if camera == null or p1 == null or p2 == null:
		return
	var center_x := (p1.global_position.x + p2.global_position.x) * 0.5
	camera.position.x = lerpf(camera.position.x, center_x, 0.08)
	_update_stage_parallax()
	_update_fighter_shadows()


func _update_stage_parallax() -> void:
	for layer_data in parallax_layers:
		var layer := layer_data.get("node") as Node3D
		if layer == null or not is_instance_valid(layer):
			continue
		var base_x := float(layer_data.get("base_x", 0.0))
		var parallax := float(layer_data.get("parallax", 0.0))
		layer.position.x = base_x + camera.position.x * parallax


func _update_fighter_shadows() -> void:
	_update_fighter_shadow(p1_shadow, p1)
	_update_fighter_shadow(p2_shadow, p2)


func _update_fighter_shadow(shadow: MeshInstance3D, fighter: FighterController) -> void:
	if shadow == null or fighter == null or not is_instance_valid(shadow) or not is_instance_valid(fighter):
		return
	var jump_height := maxf(0.0, fighter.global_position.y - FIGHTER_GROUND_Y)
	var shadow_scale := clampf(1.0 - jump_height * 0.18, 0.48, 1.0)
	var shadow_alpha := clampf(0.42 - jump_height * 0.09, 0.12, 0.42)
	shadow.global_position = Vector3(fighter.global_position.x, -0.36, 0.06)
	shadow.scale = Vector3(shadow_scale, 1.0, shadow_scale)
	var material := shadow.material_override as StandardMaterial3D
	if material != null:
		material.albedo_color = Color(0.0, 0.0, 0.0, shadow_alpha)


func _make_health_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = max_health
	bar.value = max_health
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(360.0, 26.0)
	_apply_bar_style(bar, UI_OD_CREAM, Color(0.02, 0.025, 0.035), "")
	return bar


func _make_meter_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = METER_MAX_VALUE
	bar.value = 0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(360.0, 18.0)
	_apply_bar_style(bar, UI_OD_GOLD, Color(0.04, 0.025, 0.01), "")
	_add_meter_stock_ticks(bar)
	return bar


func _add_meter_stock_ticks(bar: ProgressBar) -> void:
	for stock_index in range(1, METER_MAX_STOCKS):
		var tick := ColorRect.new()
		tick.color = Color(0.05, 0.04, 0.02, 0.72)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var anchor := float(stock_index) / float(METER_MAX_STOCKS)
		tick.anchor_left = anchor
		tick.anchor_right = anchor
		tick.anchor_top = 0.0
		tick.anchor_bottom = 1.0
		tick.offset_left = -1.0
		tick.offset_right = 1.0
		tick.offset_top = 2.0
		tick.offset_bottom = -2.0
		bar.add_child(tick)


func _apply_bar_style(bar: ProgressBar, fill_color: Color, background_color: Color, fill_texture_path: String = "") -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = background_color
	background.border_color = UI_OD_LINE
	background.set_border_width_all(2)
	background.set_corner_radius_all(0)
	background.shadow_color = Color(0.0, 0.0, 0.0, 0.62)
	background.shadow_size = 6
	bar.add_theme_stylebox_override("background", background)
	if not fill_texture_path.is_empty():
		var fill := _ui_texture_style(fill_texture_path, "bar:%s" % fill_texture_path)
		bar.add_theme_stylebox_override("fill", fill)
	else:
		var fill := StyleBoxFlat.new()
		fill.bg_color = fill_color
		fill.border_color = Color(1.0, 1.0, 1.0, 0.18)
		fill.set_border_width_all(1)
		fill.set_corner_radius_all(0)
		bar.add_theme_stylebox_override("fill", fill)


func _ui_texture_style(texture_path: String, key: String) -> StyleBoxTexture:
	if ui_style_cache.has(key):
		return ui_style_cache[key] as StyleBoxTexture
	var style := StyleBoxTexture.new()
	style.texture = _ui_texture(texture_path)
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	ui_style_cache[key] = style
	return style


func _ui_texture(texture_path: String) -> Texture2D:
	if ui_texture_cache.has(texture_path):
		return ui_texture_cache[texture_path] as Texture2D
	var texture := ResourceLoader.load(texture_path) as Texture2D
	ui_texture_cache[texture_path] = texture
	return texture


func _ui_panel_style(fill: Color, border: Color, border_width: int = 1) -> StyleBoxFlat:
	var key := "panel:%s:%s:%d" % [fill.to_html(), border.to_html(), border_width]
	if ui_style_cache.has(key):
		return ui_style_cache[key] as StyleBoxFlat
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(0)
	style.corner_detail = 1
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.58)
	style.shadow_size = 14
	ui_style_cache[key] = style
	return style


func _apply_kenney_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _ui_button_style(Color(1.0, 1.0, 1.0, 0.045), UI_OD_LINE))
	button.add_theme_stylebox_override("hover", _ui_button_style(Color(UI_OD_RED.r, UI_OD_RED.g, UI_OD_RED.b, 0.42), UI_OD_RED))
	button.add_theme_stylebox_override("pressed", _ui_button_style(Color(UI_OD_CYAN.r, UI_OD_CYAN.g, UI_OD_CYAN.b, 0.18), UI_OD_CYAN))
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", UI_OD_CREAM)
	button.add_theme_color_override("font_pressed_color", UI_OD_CYAN)
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.65))
	if not bool(button.get_meta("ui_sfx_connected", false)):
		button.mouse_entered.connect(_play_sfx.bind("ui_hover"))
		button.mouse_entered.connect(_on_button_hover_fx.bind(button, true))
		button.mouse_exited.connect(_on_button_hover_fx.bind(button, false))
		button.button_down.connect(_on_button_pressed_fx.bind(button))
		button.pressed.connect(_unlock_music_from_input)
		var click_sfx := String(button.get_meta("click_sfx", "ui_click"))
		button.pressed.connect(_play_sfx.bind(click_sfx))
		button.set_meta("ui_sfx_connected", true)


func _ui_button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var key := "od_button:%s:%s" % [fill.to_html(), border.to_html()]
	if ui_style_cache.has(key):
		return ui_style_cache[key] as StyleBoxFlat
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(0)
	style.corner_detail = 1
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 8
	ui_style_cache[key] = style
	return style


func _add_menu_ambient_fx(root: Control, alpha: float) -> void:
	var fx := MenuAmbientFx.new()
	fx.name = "MenuAmbientFx"
	fx.anchor_right = 1.0
	fx.anchor_bottom = 1.0
	fx.modulate = Color(1.0, 1.0, 1.0, alpha)
	root.add_child(fx)


func _add_character_select_fire_fx(root: Control) -> void:
	var fx := CharacterSelectFireFx.new()
	fx.name = "CharacterSelectFireFx"
	fx.anchor_right = 1.0
	fx.anchor_bottom = 1.0
	fx.modulate = Color(1.0, 1.0, 1.0, 0.88)
	root.add_child(fx)


func _pulse_menu_title(label: Label) -> void:
	if label == null or not is_instance_valid(label):
		return
	label.modulate = Color(0.72, 0.88, 1.0, 1.0)
	var tween := label.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.22)
	tween.tween_property(label, "modulate", Color(0.78, 0.9, 1.0, 1.0), 0.28)
	tween.tween_property(label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.28)


func _on_button_hover_fx(button: Button, entered: bool) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.pivot_offset = button.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.035, 1.035) if entered else Vector2.ONE, 0.12)
	tween.parallel().tween_property(button, "modulate", Color(1.0, 1.0, 1.0, 1.0) if entered else Color(0.92, 0.96, 1.0, 1.0), 0.12)


func _on_button_pressed_fx(button: Button) -> void:
	if button == null or not is_instance_valid(button):
		return
	button.pivot_offset = button.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(0.965, 0.965), 0.045)
	tween.tween_property(button, "scale", Vector2(1.035, 1.035), 0.12)


func _apply_selectable_tile_fx(tile: Control) -> void:
	if tile == null or bool(tile.get_meta("tile_fx_connected", false)):
		return
	tile.mouse_entered.connect(_on_tile_hover_fx.bind(tile, true))
	tile.mouse_exited.connect(_on_tile_hover_fx.bind(tile, false))
	tile.set_meta("tile_fx_connected", true)
	tile.set_meta("tile_selected_fx", false)


func _on_tile_hover_fx(tile: Control, entered: bool) -> void:
	if tile == null or not is_instance_valid(tile):
		return
	_play_sfx("ui_hover")
	if bool(tile.get_meta("tile_selected_fx", false)):
		return
	tile.pivot_offset = tile.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(tile, "scale", Vector2(1.025, 1.025) if entered else Vector2.ONE, 0.1)


func _set_tile_selected_fx(tile: Control, selected: bool, color: Color) -> void:
	if tile == null or not is_instance_valid(tile):
		return
	if bool(tile.get_meta("tile_selected_fx", false)) == selected:
		return
	tile.set_meta("tile_selected_fx", selected)
	tile.pivot_offset = tile.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	if selected:
		tile.modulate = Color(1.0, 1.0, 1.0, 1.0)
		tween.tween_property(tile, "scale", Vector2(1.08, 1.08), 0.13)
		tween.tween_property(tile, "scale", Vector2(1.045, 1.045), 0.12)
		_flash_control(tile, Color(color.r, color.g, color.b, 1.0), 0.18)
	else:
		tween.tween_property(tile, "scale", Vector2.ONE, 0.12)


func _flash_control(control: CanvasItem, color: Color, duration: float = 0.2) -> void:
	if control == null or not is_instance_valid(control):
		return
	var original := control.modulate
	control.modulate = color
	var tween := create_tween()
	tween.tween_property(control, "modulate", original, duration)


func _make_meter_label() -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(350.0, 18.0)
	label.add_theme_font_size_override("font_size", 11)
	label.modulate = Color(1.0, 0.9, 0.28)
	return label


func _make_round_label() -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(360.0, 18.0)
	label.add_theme_font_size_override("font_size", 13)
	label.modulate = Color(1.0, 0.86, 0.2)
	return label


func _make_combo_label(right_align: bool) -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(280.0, 78.0)
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.22))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.86))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if right_align else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.visible = false
	return label


func _make_portrait() -> TextureRect:
	var portrait := TextureRect.new()
	portrait.texture = PORTRAIT_TEXTURE
	portrait.custom_minimum_size = Vector2(64.0, 64.0)
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	return portrait


func _make_health_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(360.0, 22.0)
	return label


func _configure_input_map() -> void:
	for binding in INPUT_BINDINGS:
		for keycode in binding["keys"]:
			_add_key_action(String(binding["action"]), keycode)


func _add_key_action(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and (event.keycode == keycode or event.physical_keycode == keycode):
			return
	var input_event := InputEventKey.new()
	input_event.keycode = keycode
	input_event.physical_keycode = keycode
	InputMap.action_add_event(action, input_event)
