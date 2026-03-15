extends Node

signal hp_changed(current: int, max_hp: int)
signal inventory_changed(item_id: String, new_count: int)
signal movement_lock_changed(locked: bool)

@export var max_hp: int = 6
var hp: int = 6
var current_spawn: String = "player_start"
var _movement_locked: bool = false
var inventory: Dictionary[String, int] = {}

func _ready() -> void:
	hp = clamp(hp, 0, max_hp)
	hp_changed.emit(hp, max_hp)

func set_movement_locked(value: bool) -> void:
	if _movement_locked == value:
		return
	_movement_locked = value
	movement_lock_changed.emit(_movement_locked)

func is_movement_locked() -> bool:
	return _movement_locked

func reset_player_state() -> void:
	hp = max_hp
	inventory.clear()
	hp_changed.emit(hp, max_hp)

func heal(amount: int) -> void:
	hp = clamp(hp + amount, 0, max_hp)
	hp_changed.emit(hp, max_hp)

func damage(amount: int) -> void:
	hp = clamp(hp - amount, 0, max_hp)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		# Version 1: simple respawn behavior.
		hp = max_hp
		hp_changed.emit(hp, max_hp)
		SceneRouter.go_to("res://scenes/maps/Overworld.tscn", "player_start")

func add_item(item_id: String, amount: int = 1) -> void:
	var previous: int = inventory.get(item_id, 0)
	inventory[item_id] = previous + amount
	inventory_changed.emit(item_id, inventory[item_id])

func remove_item(item_id: String, amount: int = 1) -> void:
	if not inventory.has(item_id):
		return
	inventory[item_id] = max(0, inventory[item_id] - amount)
	inventory_changed.emit(item_id, inventory[item_id])

func item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

func has_item(item_id: String, amount: int = 1) -> bool:
	return item_count(item_id) >= amount
