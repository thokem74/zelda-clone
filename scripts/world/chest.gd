extends Node2D

const CLOSED_REGION := Rect2(306, 0, 16, 16)
const OPEN_REGION := Rect2(323, 0, 16, 16)

@export var item_id: String = "village_key"
@export var amount: int = 1
@export var quest_to_update: String = "lost_key"
@export var opened_flag_name: String = "chest_opened_cave_key"
@export var spawn_pickup_scene: PackedScene

var _player_in_range: bool = false

@onready var interact_area: Area2D = $InteractArea
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("interactables")
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	sprite.region_rect = CLOSED_REGION
	if QuestManager.get_flag(opened_flag_name):
		_apply_open_visual()

func _process(_delta: float) -> void:
	if not _player_in_range or DialogueManager.is_open():
		return
	if Input.is_action_just_pressed("interact") and not QuestManager.get_flag(opened_flag_name):
		open_chest()

func open_chest() -> void:
	QuestManager.set_flag(opened_flag_name, true)
	if spawn_pickup_scene == null:
		Game.add_item(item_id, amount)
	if QuestManager.get_state(quest_to_update) == QuestManager.QUEST_STARTED:
		QuestManager.set_state(quest_to_update, QuestManager.QUEST_ITEM_ACQUIRED)
	if spawn_pickup_scene != null:
		var pickup := spawn_pickup_scene.instantiate() as Area2D
		pickup.set("item_id", item_id)
		pickup.set("amount", amount)
		pickup.global_position = global_position + Vector2(0, -10)
		get_tree().current_scene.add_child(pickup)
	_apply_open_visual()

func _apply_open_visual() -> void:
	sprite.region_rect = OPEN_REGION

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
