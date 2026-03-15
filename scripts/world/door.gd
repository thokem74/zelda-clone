extends Area2D

@export_file("*.tscn") var target_scene: String
@export var target_spawn: String = "player_start"
@export var requires_flag: String = ""
@export var consume_input: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not requires_flag.is_empty() and not QuestManager.get_flag(requires_flag):
		return
	if consume_input and not Input.is_action_pressed("interact"):
		return
	SceneRouter.go_to(target_scene, target_spawn)
