extends Node

signal quest_state_changed(quest_id: String, new_state: String)
signal objective_changed(text: String)
signal flag_changed(flag_name: String, value: bool)

const QUEST_NOT_STARTED: String = "not_started"
const QUEST_STARTED: String = "started"
const QUEST_ITEM_ACQUIRED: String = "item_acquired"
const QUEST_COMPLETED: String = "completed"

var quests: Dictionary[String, Dictionary] = {}
var flags: Dictionary[String, bool] = {}

func _ready() -> void:
	load_quest_definitions()
	_refresh_objective_text()

func load_quest_definitions() -> void:
	quests.clear()
	var file_path := "res://data/quests/lost_key.json"
	if not FileAccess.file_exists(file_path):
		return
	var raw: String = FileAccess.get_file_as_string(file_path)
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for quest_id: String in parsed.keys():
		var quest_data: Dictionary = parsed[quest_id]
		quest_data["state"] = QUEST_NOT_STARTED
		quests[quest_id] = quest_data

func get_state(quest_id: String) -> String:
	if not quests.has(quest_id):
		return QUEST_NOT_STARTED
	return quests[quest_id].get("state", QUEST_NOT_STARTED)

func set_state(quest_id: String, state: String) -> void:
	if not quests.has(quest_id):
		return
	if quests[quest_id].get("state") == state:
		return
	quests[quest_id]["state"] = state
	quest_state_changed.emit(quest_id, state)
	_refresh_objective_text()

func start_quest(quest_id: String) -> void:
	set_state(quest_id, QUEST_STARTED)

func complete_quest(quest_id: String) -> void:
	set_state(quest_id, QUEST_COMPLETED)

func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value
	flag_changed.emit(flag_name, value)

func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func _refresh_objective_text() -> void:
	var text: String = "Explore the village."
	if quests.has("lost_key"):
		match get_state("lost_key"):
			QUEST_NOT_STARTED:
				text = "Talk to the village elder."
			QUEST_STARTED:
				text = "Find the key in the cave chest."
			QUEST_ITEM_ACQUIRED:
				text = "Return the key to the elder."
			QUEST_COMPLETED:
				text = "Gate unlocked. Continue onward!"
	objective_changed.emit(text)
