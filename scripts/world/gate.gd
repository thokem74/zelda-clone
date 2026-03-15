extends StaticBody2D

@export var unlock_flag: String = "gate_unlocked"

func _ready() -> void:
	QuestManager.flag_changed.connect(_on_flag_changed)
	_update_state()

func _on_flag_changed(flag_name: String, _value: bool) -> void:
	if flag_name == unlock_flag:
		_update_state()

func _update_state() -> void:
	var unlocked := QuestManager.get_flag(unlock_flag)
	visible = not unlocked
	set_deferred("collision_layer", 1 if not unlocked else 0)
	set_deferred("collision_mask", 1 if not unlocked else 0)
