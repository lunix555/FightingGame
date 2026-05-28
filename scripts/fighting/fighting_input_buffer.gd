extends RefCounted
class_name FightingInputBuffer

const BUFFER_FRAMES := 28
const BUTTON_BUFFER_FRAMES := 5
const CHORD_GRACE_FRAMES := 4
const BUTTONS := ["J", "K", "U", "I", "O", "L"]
const COMBO_JOINER := "+"

var history: Array[Dictionary] = []
var previous_buttons := {}
var scripted_state := {}


func set_scripted_state(state: Dictionary) -> void:
	scripted_state = state.duplicate()


func clear_scripted_state() -> void:
	scripted_state.clear()


func sample(action_prefix: String, frame: int, facing_right: bool) -> Dictionary:
	var direction := _read_direction(action_prefix, facing_right)
	var pressed := {}

	for button in BUTTONS:
		var down := _is_button_pressed(action_prefix, button)
		var was_down := bool(previous_buttons.get(button, false))
		if down and not was_down:
			pressed[button] = true
		previous_buttons[button] = down

	var entry := {
		"frame": frame,
		"direction": direction,
		"pressed": pressed,
	}
	history.append(entry)

	while history.size() > BUFFER_FRAMES:
		history.pop_front()

	return entry


func find_move(moves: Array[MoveDefinition]) -> MoveDefinition:
	var pressed_buttons := _latest_pressed_buttons()
	if pressed_buttons.is_empty():
		return null

	var sorted_moves := moves.duplicate()
	sorted_moves.sort_custom(_sort_by_command_priority)

	for move in sorted_moves:
		if not _button_command_pressed(move.button, pressed_buttons):
			continue
		if move.motion.is_empty() or _motion_exists(move.motion):
			if _should_wait_for_chord(move, sorted_moves):
				return null
			return move

	return null


func current_direction() -> int:
	if history.is_empty():
		return 5
	return int(history.back()["direction"])


func is_button_down(button_command: String) -> bool:
	if button_command.is_empty():
		return false
	for raw_button in button_command.split(COMBO_JOINER, false):
		var button := String(raw_button).strip_edges().to_upper()
		if button.is_empty():
			continue
		if not bool(previous_buttons.get(button, false)):
			return false
	return true


func was_button_pressed_recently(button_command: String, frame_window: int = BUTTON_BUFFER_FRAMES) -> bool:
	if button_command.is_empty():
		return false
	var recent_pressed := _pressed_buttons_since(frame_window)
	for raw_button in button_command.split(COMBO_JOINER, false):
		var button := String(raw_button).strip_edges().to_upper()
		if button.is_empty():
			continue
		if not recent_pressed.has(button):
			return false
	return true


func clear() -> void:
	history.clear()
	previous_buttons.clear()


func _latest_pressed_buttons() -> Dictionary:
	if history.is_empty():
		return {}

	var latest_frame := int(history.back()["frame"])
	for index in range(history.size() - 1, -1, -1):
		var entry := history[index]
		if latest_frame - int(entry["frame"]) > BUTTON_BUFFER_FRAMES:
			break
		var pressed := entry["pressed"] as Dictionary
		if not pressed.is_empty():
			return pressed
	return {}


func _button_command_pressed(button_command: String, latest_pressed_buttons: Dictionary) -> bool:
	if not button_command.contains(COMBO_JOINER):
		return latest_pressed_buttons.has(button_command)

	var recent_pressed := _pressed_buttons_since(BUTTON_BUFFER_FRAMES)
	var command_pressed_this_window := false
	for raw_button in button_command.split(COMBO_JOINER, false):
		var button := String(raw_button).strip_edges().to_upper()
		if button.is_empty():
			continue
		if latest_pressed_buttons.has(button) or recent_pressed.has(button):
			command_pressed_this_window = true
		if not bool(previous_buttons.get(button, false)) and not recent_pressed.has(button):
			return false
	return command_pressed_this_window


func _should_wait_for_chord(move: MoveDefinition, sorted_moves: Array) -> bool:
	if move == null or move.button.is_empty() or move.button.contains(COMBO_JOINER):
		return false
	if history.is_empty() or not bool(previous_buttons.get(move.button, false)):
		return false

	var latest_frame := int(history.back()["frame"])
	var move_button_pressed_frame := _last_button_press_frame(move.button)
	if move_button_pressed_frame < 0 or latest_frame - move_button_pressed_frame > CHORD_GRACE_FRAMES:
		return false

	for candidate in sorted_moves:
		var combo := candidate as MoveDefinition
		if combo == null or combo == move or not combo.button.contains(COMBO_JOINER):
			continue
		if not combo.motion.is_empty():
			continue
		if _combo_contains_button(combo.button, move.button) and not _button_command_pressed(combo.button, _latest_pressed_buttons()):
			return true
	return false


func _last_button_press_frame(button: String) -> int:
	for index in range(history.size() - 1, -1, -1):
		var entry := history[index]
		var pressed := entry["pressed"] as Dictionary
		if pressed.has(button):
			return int(entry["frame"])
	return -1


func _combo_contains_button(button_command: String, wanted_button: String) -> bool:
	for raw_button in button_command.split(COMBO_JOINER, false):
		if String(raw_button).strip_edges().to_upper() == wanted_button:
			return true
	return false


func _pressed_buttons_since(frame_window: int) -> Dictionary:
	if history.is_empty():
		return {}

	var result := {}
	var latest_frame := int(history.back()["frame"])
	for index in range(history.size() - 1, -1, -1):
		var entry := history[index]
		if latest_frame - int(entry["frame"]) > frame_window:
			break
		var pressed := entry["pressed"] as Dictionary
		for button in pressed.keys():
			result[String(button)] = true
	return result


func _motion_exists(motion: String) -> bool:
	if motion.is_empty():
		return true

	var target_index := motion.length() - 1
	var last_direction := -1

	for index in range(history.size() - 1, -1, -1):
		var direction := int(history[index]["direction"])
		if direction == last_direction:
			continue
		last_direction = direction

		var wanted := int(motion[target_index])
		if direction == wanted:
			target_index -= 1
			if target_index < 0:
				return true

	return false


func _read_direction(action_prefix: String, facing_right: bool) -> int:
	var left := _is_control_pressed(action_prefix, "left")
	var right := _is_control_pressed(action_prefix, "right")
	var up := _is_control_pressed(action_prefix, "up")
	var down := _is_control_pressed(action_prefix, "down")

	var horizontal := 0
	if left and not right:
		horizontal = -1
	elif right and not left:
		horizontal = 1

	if not facing_right:
		horizontal *= -1

	if up and not down:
		if horizontal < 0:
			return 7
		if horizontal > 0:
			return 9
		return 8

	if down and not up:
		if horizontal < 0:
			return 1
		if horizontal > 0:
			return 3
		return 2

	if horizontal < 0:
		return 4
	if horizontal > 0:
		return 6
	return 5


func _is_button_pressed(action_prefix: String, button: String) -> bool:
	return _is_control_pressed(action_prefix, button.to_lower())


func _is_control_pressed(action_prefix: String, control: String) -> bool:
	if not scripted_state.is_empty():
		return bool(scripted_state.get(control, false))
	return Input.is_action_pressed("%s_%s" % [action_prefix, control])


static func _sort_by_command_priority(a: MoveDefinition, b: MoveDefinition) -> bool:
	if a.motion.length() == b.motion.length():
		return a.move_type > b.move_type
	return a.motion.length() > b.motion.length()
