extends Area2D

@export var item_id: String = "village_key"
@export var amount: int = 1
@export var auto_collect: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not auto_collect:
		return
	if not body.is_in_group("player"):
		return
	collect()

func collect() -> void:
	Game.add_item(item_id, amount)
	queue_free()
