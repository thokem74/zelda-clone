extends Node

signal dialogue_started(speaker: String)
signal dialogue_ended

var _dialogue_box: CanvasLayer
var _active_lines: Array[String] = []
var _line_index: int = -1
var _speaker: String = ""
var _last_closed_frame: int = -1

func register_dialogue_box(dialogue_box: CanvasLayer) -> void:
	_dialogue_box = dialogue_box

func is_open() -> bool:
	return _line_index >= 0

func was_closed_this_frame() -> bool:
	return _last_closed_frame == Engine.get_process_frames()

func start_dialogue(dialogue_file: String, key: String) -> void:
	if _dialogue_box == null:
		push_warning("DialogueBox not registered.")
		return
	var payload: Dictionary = _load_dialogue(dialogue_file)
	if payload.is_empty() or not payload.has(key):
		return
	var entry: Dictionary = payload[key]
	_speaker = entry.get("speaker", "")
	_active_lines.clear()
	for line: String in entry.get("lines", []):
		_active_lines.append(line)
	if _active_lines.is_empty():
		return
	_line_index = 0
	Game.set_movement_locked(true)
	dialogue_started.emit(_speaker)
	_dialogue_box.call("open_dialogue", _speaker, _active_lines[_line_index])

func advance() -> void:
	if _line_index < 0:
		return
	_line_index += 1
	if _line_index >= _active_lines.size():
		close_dialogue()
		return
	_dialogue_box.call("set_line", _speaker, _active_lines[_line_index])

func close_dialogue() -> void:
	_line_index = -1
	_active_lines.clear()
	_speaker = ""
	_last_closed_frame = Engine.get_process_frames()
	if _dialogue_box != null:
		_dialogue_box.call("close_dialogue")
	Game.set_movement_locked(false)
	dialogue_ended.emit()

func _load_dialogue(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var raw: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed
