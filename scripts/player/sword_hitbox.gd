extends Area2D

@export var damage: int = 1
@export var offset_distance: float = 16.0

var _owner_player: Node2D
var _facing: Vector2 = Vector2.DOWN
var _already_hit: Array[Node] = []

func _ready() -> void:
	monitoring = false
	area_entered.connect(_on_area_entered)

func set_owner_player(player: Node2D) -> void:
	_owner_player = player

func set_facing(facing: Vector2) -> void:
	_facing = facing
	position = _facing * offset_distance

func begin_swing() -> void:
	_already_hit.clear()
	position = _facing * offset_distance
	monitoring = true

func end_swing() -> void:
	monitoring = false

func _on_area_entered(area: Area2D) -> void:
	var target := area.get_parent()
	if target == null or _already_hit.has(target):
		return
	if target.is_in_group("enemies") and target.has_method("receive_damage"):
		target.call("receive_damage", damage, global_position)
		_already_hit.append(target)
