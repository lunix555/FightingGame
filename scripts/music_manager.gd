extends Node
class_name MusicManager

const MENU_MUSIC := "menu"
const CHARACTER_SELECT_MUSIC := "character_select"
const STAGE_SELECT_MUSIC := "stage_select"
const BATTLE_MUSIC := "battle"

const MUSIC_PATHS := {
	MENU_MUSIC: "res://assets/audio/BGM/BGM_Main.wav",
	CHARACTER_SELECT_MUSIC: "res://assets/audio/BGM/BGM_Main.wav",
	STAGE_SELECT_MUSIC: "res://assets/audio/BGM/BGM_Main.wav",
	BATTLE_MUSIC: "res://assets/audio/BGM/BGM_Neon Street.wav",
}

const DEFAULT_VOLUME_DB := -8.0

var player: AudioStreamPlayer
var current_track := ""
var current_path := ""
var audio_unlocked := false
var target_volume_db := DEFAULT_VOLUME_DB
var retry_frames_left := 0
var retry_tick := 0
var start_attempts := 0
var desired_playing := false
var playback_confirmed := false
var debug_last_event := "init"
var debug_log: Array[String] = []


func _ready() -> void:
	_setup_player()


func _physics_process(_delta: float) -> void:
	_retry_start_if_needed()


func play_menu() -> void:
	play_track(MENU_MUSIC, -8.0)


func play_character_select() -> void:
	play_track(CHARACTER_SELECT_MUSIC, -7.0)


func play_stage_select() -> void:
	play_track(STAGE_SELECT_MUSIC, -7.0)


func play_battle(volume_db: float = -6.0) -> void:
	play_track(BATTLE_MUSIC, volume_db)


func stop_music() -> void:
	desired_playing = false
	playback_confirmed = false
	retry_frames_left = 0
	if player == null:
		return
	player.stop()
	current_track = ""
	current_path = ""
	_mark_debug("stop")


func set_music_volume(volume_db: float) -> void:
	target_volume_db = volume_db
	if player != null:
		player.volume_db = volume_db


func unlock_audio_from_input() -> void:
	if audio_unlocked:
		if desired_playing and player != null and player.stream != null and not _is_playback_active():
			_start_playback(false)
		return
	audio_unlocked = true
	_mark_debug("unlock")
	if desired_playing and player != null and player.stream != null and not _is_playback_active():
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
	var should_switch_stream := current_path != next_path or (track_key == BATTLE_MUSIC and current_track != BATTLE_MUSIC)
	if should_switch_stream:
		var stream := _load_music_stream(track_key)
		if stream == null:
			_mark_debug("missing:%s" % track_key)
			push_warning("Music track missing: %s" % track_key)
			return
		player.stop()
		player.stream = stream
		current_path = next_path
		playback_confirmed = false
		_mark_debug("track:%s" % track_key)
	current_track = track_key
	player.volume_db = volume_db
	if audio_unlocked or OS.get_name() != "Web":
		_start_playback(false)
	else:
		_mark_debug("wait_unlock:%s" % track_key)


func _setup_player() -> void:
	if player != null:
		return
	player = AudioStreamPlayer.new()
	player.name = "MusicPlayer"
	player.bus = "Master"
	player.volume_db = target_volume_db
	add_child(player)
	set_physics_process(true)
	_mark_debug("setup_player")


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
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav_stream.loop_begin = 0
		wav_stream.loop_end = _wav_frame_count(wav_stream)
	return stream


func _wav_frame_count(wav_stream: AudioStreamWAV) -> int:
	var bytes_per_sample := 2
	match wav_stream.format:
		AudioStreamWAV.FORMAT_8_BITS:
			bytes_per_sample = 1
		AudioStreamWAV.FORMAT_16_BITS:
			bytes_per_sample = 2
		_:
			bytes_per_sample = 2
	var channels := 2 if wav_stream.stereo else 1
	return maxi(1, int(wav_stream.data.size() / maxi(1, bytes_per_sample * channels)))


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
