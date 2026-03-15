extends CanvasLayer

@export var hearts_label_path: NodePath
@export var objective_label_path: NodePath

@onready var hearts_label: Label = get_node(hearts_label_path)
@onready var objective_label: Label = get_node(objective_label_path)

func _ready() -> void:
	Game.hp_changed.connect(_on_hp_changed)
	QuestManager.objective_changed.connect(_on_objective_changed)
	_on_hp_changed(Game.hp, Game.max_hp)
	_on_objective_changed("Talk to the village elder.")

func _on_hp_changed(current: int, max_hp: int) -> void:
	var full_hearts := int(ceil(float(current) / 2.0))
	var total_hearts := int(ceil(float(max_hp) / 2.0))
	hearts_label.text = "HP: " + "♥".repeat(full_hearts) + "♡".repeat(max(0, total_hearts - full_hearts))

func _on_objective_changed(text: String) -> void:
	objective_label.text = "Objective: %s" % text
