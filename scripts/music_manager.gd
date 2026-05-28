extends Node
class_name MusicManager

const MENU_MUSIC := "menu"
const CHARACTER_SELECT_MUSIC := "character_select"
const STAGE_SELECT_MUSIC := "stage_select"
const BATTLE_MUSIC := "battle"
const MAGICAL_ROAD_MUSIC := "battle_magical_road"
const SCIFI_LAB_MUSIC := "battle_scifi_lab"

const MUSIC_PATHS := {
	MENU_MUSIC: "res://assets/audio/BGM/BGM_Main.wav",
	CHARACTER_SELECT_MUSIC: "res://assets/audio/BGM/BGM_Main.wav",
	STAGE_SELECT_MUSIC: "res://assets/audio/BGM/BGM_Main.wav",
	BATTLE_MUSIC: "res://assets/audio/BGM/BGM_Neon Street.wav",
	MAGICAL_ROAD_MUSIC: "res://assets/audio/BGM/BGM_Magical Road.wav",
	SCIFI_LAB_MUSIC: "res://assets/audio/BGM/BGM_Sci-Fi Lab.wav",
}

const DEFAULT_VOLUME_DB := -8.0
const CROSSFADE_SECONDS := 2.0
const CROSSFADE_SILENCE_DB := -80.0
const MUSIC_BUS_NAME := "Music"
const INTRO_RESTORE_SECONDS := 1.0
const INTRO_VOLUME_OFFSET_DB := -8.0
const INTRO_LOWPASS_CUTOFF_HZ := 900.0
const KO_LOWPASS_CUTOFF_HZ := 1100.0
const KO_LOWPASS_FADE_SECONDS := 0.35
const PAUSE_VOLUME_OFFSET_DB := -3.0
const FULL_RANGE_CUTOFF_HZ := 20500.0

var player: AudioStreamPlayer
var fade_out_player: AudioStreamPlayer
var current_track := ""
var current_path := ""
var audio_unlocked := false
var target_volume_db := DEFAULT_VOLUME_DB
var retry_frames_left := 0
var retry_tick := 0
var start_attempts := 0
var desired_playing := false
var playback_confirmed := false
var crossfade_tween: Tween
var intro_restore_tween: Tween
var battle_lowpass_tween: Tween
var pause_effect_tween: Tween
var music_bus_index := -1
var music_lowpass_effect: AudioEffectLowPassFilter
var intro_effect_active := true
var battle_lowpass_active := false
var pause_effect_active := false
var debug_last_event := "init"
var debug_log: Array[String] = []


func _ready() -> void:
	_setup_music_bus()
	_setup_player()


func _physics_process(_delta: float) -> void:
	_retry_start_if_needed()


func play_menu() -> void:
	play_track(MENU_MUSIC, -8.0)


func play_character_select() -> void:
	play_track(CHARACTER_SELECT_MUSIC, -7.0)


func play_stage_select() -> void:
	play_track(STAGE_SELECT_MUSIC, -7.0)


func play_battle(volume_db: float = -6.0, stage_name: String = "") -> void:
	play_track(_battle_track_for_stage(stage_name), volume_db)


func stop_music() -> void:
	desired_playing = false
	playback_confirmed = false
	retry_frames_left = 0
	_cancel_crossfade()
	_cancel_intro_restore()
	_cancel_battle_lowpass_tween()
	_cancel_pause_effect_tween()
	battle_lowpass_active = false
	pause_effect_active = false
	if fade_out_player != null:
		fade_out_player.stop()
	if player == null:
		return
	player.stop()
	current_track = ""
	current_path = ""
	_mark_debug("stop")


func set_music_volume(volume_db: float) -> void:
	target_volume_db = volume_db
	if player != null and crossfade_tween == null:
		player.volume_db = _effective_player_volume(volume_db)


func unlock_audio_from_input() -> void:
	if audio_unlocked:
		if desired_playing and not playback_confirmed and player != null and player.stream != null and not _is_playback_active():
			_start_playback(false)
		return
	audio_unlocked = true
	_mark_debug("unlock")
	if desired_playing and not playback_confirmed and player != null and player.stream != null and not _is_playback_active():
		_start_playback(false)


func play_track(track_key: String, volume_db: float = DEFAULT_VOLUME_DB) -> void:
	_setup_player()
	target_volume_db = volume_db
	desired_playing = true
	if player == null:
		_mark_debug("play_no_player")
		return
	var next_path := _music_path(track_key)
	if next_path.is_empty():
		_mark_debug("missing:%s" % track_key)
		push_warning("Music track missing: %s" % track_key)
		return
	var should_switch_stream := current_path != next_path or (_is_battle_track(track_key) and not _is_battle_track(current_track))
	var should_crossfade := should_switch_stream and _is_battle_track(track_key) and _is_playback_active()
	if should_switch_stream:
		var stream := _load_music_stream(track_key)
		if stream == null:
			_mark_debug("missing:%s" % track_key)
			push_warning("Music track missing: %s" % track_key)
			return
		if should_crossfade:
			_begin_crossfade(stream, volume_db)
		else:
			_cancel_crossfade()
			player.stop()
			player.stream = stream
			player.volume_db = _effective_player_volume(volume_db)
			playback_confirmed = false
		current_path = next_path
		_mark_debug("track:%s" % track_key)
	current_track = track_key
	if not should_crossfade:
		if intro_restore_tween != null:
			_retarget_intro_restore()
		else:
			player.volume_db = _effective_player_volume(volume_db)
	if audio_unlocked or OS.get_name() != "Web":
		if not should_crossfade and (should_switch_stream or not playback_confirmed):
			_start_playback(false)
	else:
		_mark_debug("wait_unlock:%s" % track_key)


func _setup_music_bus() -> void:
	if music_bus_index >= 0:
		return
	music_bus_index = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	if music_bus_index < 0:
		AudioServer.add_bus(AudioServer.get_bus_count())
		music_bus_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(music_bus_index, MUSIC_BUS_NAME)
		AudioServer.set_bus_send(music_bus_index, "Master")
	music_lowpass_effect = AudioEffectLowPassFilter.new()
	music_lowpass_effect.cutoff_hz = INTRO_LOWPASS_CUTOFF_HZ if intro_effect_active else FULL_RANGE_CUTOFF_HZ
	music_lowpass_effect.resonance = 0.5
	AudioServer.add_bus_effect(music_bus_index, music_lowpass_effect)
	_mark_debug("setup_music_bus")


func _effective_player_volume(volume_db: float) -> float:
	var effective_volume := volume_db
	if intro_effect_active:
		effective_volume += INTRO_VOLUME_OFFSET_DB
	if pause_effect_active:
		effective_volume += PAUSE_VOLUME_OFFSET_DB
	return effective_volume


func _setup_player() -> void:
	if player != null:
		return
	_setup_music_bus()
	player = AudioStreamPlayer.new()
	player.name = "MusicPlayer"
	player.bus = MUSIC_BUS_NAME
	player.volume_db = _effective_player_volume(target_volume_db)
	add_child(player)
	fade_out_player = AudioStreamPlayer.new()
	fade_out_player.name = "MusicFadeOutPlayer"
	fade_out_player.bus = MUSIC_BUS_NAME
	fade_out_player.volume_db = CROSSFADE_SILENCE_DB
	add_child(fade_out_player)
	set_physics_process(true)
	_mark_debug("setup_player")


func _begin_crossfade(new_stream: AudioStream, volume_db: float) -> void:
	_cancel_crossfade()
	if fade_out_player == null or player == null:
		return
	fade_out_player.stop()
	fade_out_player.stream = player.stream
	fade_out_player.volume_db = player.volume_db
	if fade_out_player.stream != null:
		fade_out_player.play(player.get_playback_position())
	player.stop()
	player.stream = new_stream
	player.volume_db = CROSSFADE_SILENCE_DB
	player.play(0.0)
	playback_confirmed = true
	retry_frames_left = 0
	crossfade_tween = create_tween()
	crossfade_tween.set_parallel(true)
	crossfade_tween.tween_property(player, "volume_db", _effective_player_volume(volume_db), CROSSFADE_SECONDS)
	crossfade_tween.tween_property(fade_out_player, "volume_db", CROSSFADE_SILENCE_DB, CROSSFADE_SECONDS)
	crossfade_tween.finished.connect(_finish_crossfade)
	_mark_debug("crossfade")


func _finish_crossfade() -> void:
	if fade_out_player != null:
		fade_out_player.stop()
	if player != null:
		player.volume_db = _effective_player_volume(target_volume_db)
	crossfade_tween = null
	_mark_debug("crossfade_done")


func _cancel_crossfade() -> void:
	if crossfade_tween != null:
		crossfade_tween.kill()
		crossfade_tween = null


func restore_intro_effect() -> void:
	_start_intro_restore()


func set_battle_lowpass(enabled: bool) -> void:
	battle_lowpass_active = enabled
	_update_music_filter(KO_LOWPASS_FADE_SECONDS, "battle_lowpass:%s" % str(enabled), true)


func set_pause_effect(enabled: bool) -> void:
	pause_effect_active = enabled
	_update_music_filter(KO_LOWPASS_FADE_SECONDS, "pause_effect:%s" % str(enabled), false)


func _update_music_filter(duration: float, debug_event: String, use_battle_tween_slot: bool) -> void:
	_setup_music_bus()
	if music_lowpass_effect == null:
		return
	_cancel_battle_lowpass_tween()
	_cancel_pause_effect_tween()
	var target_cutoff := _target_lowpass_cutoff()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(music_lowpass_effect, "cutoff_hz", target_cutoff, duration)
	if player != null and crossfade_tween == null:
		tween.tween_property(player, "volume_db", _effective_player_volume(target_volume_db), duration)
	if fade_out_player != null and fade_out_player.playing:
		tween.tween_property(fade_out_player, "volume_db", CROSSFADE_SILENCE_DB, duration)
	if use_battle_tween_slot:
		battle_lowpass_tween = tween
		battle_lowpass_tween.finished.connect(_finish_battle_lowpass_tween)
	else:
		pause_effect_tween = tween
		pause_effect_tween.finished.connect(_finish_pause_effect_tween)
	_mark_debug(debug_event)


func _target_lowpass_cutoff() -> float:
	if intro_effect_active:
		return INTRO_LOWPASS_CUTOFF_HZ
	if battle_lowpass_active or pause_effect_active:
		return KO_LOWPASS_CUTOFF_HZ
	return FULL_RANGE_CUTOFF_HZ


func _finish_battle_lowpass_tween() -> void:
	battle_lowpass_tween = null


func _finish_pause_effect_tween() -> void:
	pause_effect_tween = null


func _cancel_battle_lowpass_tween() -> void:
	if battle_lowpass_tween != null:
		battle_lowpass_tween.kill()
		battle_lowpass_tween = null


func _cancel_pause_effect_tween() -> void:
	if pause_effect_tween != null:
		pause_effect_tween.kill()
		pause_effect_tween = null


func _start_intro_restore() -> void:
	if not intro_effect_active:
		return
	_setup_music_bus()
	_cancel_intro_restore()
	intro_effect_active = false
	_retarget_intro_restore()
	_mark_debug("intro_restore")


func _retarget_intro_restore() -> void:
	_cancel_intro_restore()
	intro_restore_tween = create_tween()
	intro_restore_tween.set_parallel(true)
	if player != null:
		intro_restore_tween.tween_property(player, "volume_db", _effective_player_volume(target_volume_db), INTRO_RESTORE_SECONDS)
	if fade_out_player != null and fade_out_player.playing:
		intro_restore_tween.tween_property(fade_out_player, "volume_db", CROSSFADE_SILENCE_DB, INTRO_RESTORE_SECONDS)
	if music_lowpass_effect != null:
		intro_restore_tween.tween_property(music_lowpass_effect, "cutoff_hz", _target_lowpass_cutoff(), INTRO_RESTORE_SECONDS)
	intro_restore_tween.finished.connect(_finish_intro_restore)


func _finish_intro_restore() -> void:
	if music_lowpass_effect != null:
		music_lowpass_effect.cutoff_hz = _target_lowpass_cutoff()
	if player != null and crossfade_tween == null:
		player.volume_db = _effective_player_volume(target_volume_db)
	intro_restore_tween = null
	_mark_debug("intro_full")


func _cancel_intro_restore() -> void:
	if intro_restore_tween != null:
		intro_restore_tween.kill()
		intro_restore_tween = null


func _battle_track_for_stage(stage_name: String) -> String:
	match stage_name:
		"Magical Road":
			return MAGICAL_ROAD_MUSIC
		"Sci-Fi Lab":
			return SCIFI_LAB_MUSIC
		_:
			return BATTLE_MUSIC


func _is_battle_track(track_key: String) -> bool:
	return track_key == BATTLE_MUSIC or track_key == MAGICAL_ROAD_MUSIC or track_key == SCIFI_LAB_MUSIC


func _music_path(track_key: String) -> String:
	if not MUSIC_PATHS.has(track_key):
		return ""
	return String(MUSIC_PATHS[track_key])


func _load_music_stream(track_key: String) -> AudioStream:
	var path := _music_path(track_key)
	if path.is_empty():
		return null
	var stream := ResourceLoader.load(path) as AudioStream
	if stream == null:
		return null
	if stream is AudioStreamWAV:
		var wav_stream := stream as AudioStreamWAV
		var frame_count := int(round(wav_stream.get_length() * float(wav_stream.mix_rate)))
		var file_frame_count := _wav_file_frame_count(path)
		if file_frame_count > frame_count:
			frame_count = file_frame_count
		var data_frame_count := _wav_frame_count(wav_stream)
		if data_frame_count > frame_count:
			frame_count = data_frame_count
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav_stream.loop_begin = 0
		if frame_count > 0:
			wav_stream.loop_end = frame_count
	return stream


func _wav_file_frame_count(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	var bytes := file.get_buffer(file.get_length())
	if bytes.size() < 44:
		return 0
	if bytes.slice(0, 4).get_string_from_ascii() != "RIFF" or bytes.slice(8, 12).get_string_from_ascii() != "WAVE":
		return 0
	var channels := 0
	var bits_per_sample := 0
	var data_size := 0
	var offset := 12
	while offset + 8 <= bytes.size():
		var chunk_id := bytes.slice(offset, offset + 4).get_string_from_ascii()
		var chunk_size := _u32_le(bytes, offset + 4)
		var chunk_data_offset := offset + 8
		if chunk_id == "fmt ":
			channels = _u16_le(bytes, chunk_data_offset + 2)
			bits_per_sample = _u16_le(bytes, chunk_data_offset + 14)
		elif chunk_id == "data":
			data_size = mini(chunk_size, bytes.size() - chunk_data_offset)
			break
		offset = chunk_data_offset + chunk_size + int(chunk_size % 2)
	var frame_size := channels * int(bits_per_sample / 8)
	if data_size <= 0 or frame_size <= 0:
		return 0
	return int(data_size / frame_size)


func _u16_le(bytes: PackedByteArray, offset: int) -> int:
	if offset + 1 >= bytes.size():
		return 0
	return int(bytes[offset]) | (int(bytes[offset + 1]) << 8)


func _u32_le(bytes: PackedByteArray, offset: int) -> int:
	if offset + 3 >= bytes.size():
		return 0
	return int(bytes[offset]) | (int(bytes[offset + 1]) << 8) | (int(bytes[offset + 2]) << 16) | (int(bytes[offset + 3]) << 24)


func _wav_frame_count(wav_stream: AudioStreamWAV) -> int:
	if wav_stream.data.is_empty():
		return 0
	var bytes_per_sample := 2
	match wav_stream.format:
		AudioStreamWAV.FORMAT_8_BITS:
			bytes_per_sample = 1
		AudioStreamWAV.FORMAT_16_BITS:
			bytes_per_sample = 2
		AudioStreamWAV.FORMAT_IMA_ADPCM:
			return 0
		_:
			bytes_per_sample = 2
	var channels := 2 if wav_stream.stereo else 1
	return int(wav_stream.data.size() / maxi(1, bytes_per_sample * channels))


func _is_playback_active() -> bool:
	return player != null and player.stream != null and (player.playing or player.has_stream_playback())


func _start_playback(force_restart: bool) -> void:
	if player == null or player.stream == null:
		_mark_debug("start_skip")
		return
	if force_restart:
		player.stop()
	if force_restart or not _is_playback_active():
		start_attempts += 1
		player.play(0.0)
		if not playback_confirmed:
			retry_frames_left = 120
			retry_tick = 0
		_mark_debug("play_call#%d" % start_attempts)


func _retry_start_if_needed() -> void:
	if not desired_playing:
		return
	if player == null or player.stream == null:
		retry_frames_left = 0
		return
	if _is_playback_active():
		if retry_frames_left > 0:
			retry_frames_left = 0
			playback_confirmed = true
			_mark_debug("playback_active")
		return
	if playback_confirmed:
		return
	if retry_frames_left <= 0:
		retry_frames_left = 120
		retry_tick = 10
	retry_frames_left -= 1
	retry_tick += 1
	if retry_tick >= 10:
		retry_tick = 0
		start_attempts += 1
		player.play(0.0)
		_mark_debug("retry#%d" % start_attempts)


func _mark_debug(event_name: String) -> void:
	debug_last_event = event_name
	debug_log.append(event_name)
	if debug_log.size() > 6:
		debug_log.remove_at(0)
