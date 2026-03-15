extends Node2D

@export var quest_id: String = "lost_key"
@export_file("*.json") var dialogue_file: String = "res://data/dialogue/elder.json"
@export var intro_key: String = "intro"
@export var reminder_key: String = "reminder"
@export var completion_key: String = "completion"
@export var required_item_id: String = "village_key"
@export var complete_flag_name: String = "gate_unlocked"

var _player_in_range: bool = false

@onready var interact_area: Area2D = $InteractArea

func _ready() -> void:
	add_to_group("interactables")
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if not _player_in_range:
		return
	if DialogueManager.is_open():
		return
	if Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	var state := QuestManager.get_state(quest_id)
	if state == QuestManager.QUEST_NOT_STARTED:
		QuestManager.start_quest(quest_id)
		DialogueManager.start_dialogue(dialogue_file, intro_key)
		return

	if state in [QuestManager.QUEST_STARTED, QuestManager.QUEST_ITEM_ACQUIRED] and Game.has_item(required_item_id):
		QuestManager.set_state(quest_id, QuestManager.QUEST_COMPLETED)
		QuestManager.set_flag(complete_flag_name, true)
		DialogueManager.start_dialogue(dialogue_file, completion_key)
		return

	if state == QuestManager.QUEST_COMPLETED:
		DialogueManager.start_dialogue(dialogue_file, "post")
		return

	DialogueManager.start_dialogue(dialogue_file, reminder_key)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
