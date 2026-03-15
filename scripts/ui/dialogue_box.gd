extends CanvasLayer

@export var panel_path: NodePath
@export var speaker_label_path: NodePath
@export var line_label_path: NodePath

@onready var panel: Control = get_node(panel_path)
@onready var speaker_label: Label = get_node(speaker_label_path)
@onready var line_label: Label = get_node(line_label_path)

func _ready() -> void:
	DialogueManager.register_dialogue_box(self)
	visible = false

func open_dialogue(speaker: String, line: String) -> void:
	visible = true
	panel.visible = true
	set_line(speaker, line)

func set_line(speaker: String, line: String) -> void:
	speaker_label.text = speaker
	line_label.text = line

func close_dialogue() -> void:
	visible = false
	panel.visible = false
