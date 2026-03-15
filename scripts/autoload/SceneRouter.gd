extends Node

var _queued_scene_path: String = ""
var _queued_spawn_name: String = ""

func go_to(scene_path: String, spawn_name: String = "player_start") -> void:
	_queued_scene_path = scene_path
	_queued_spawn_name = spawn_name
	Game.current_spawn = spawn_name
	call_deferred("_swap_scene")

func _swap_scene() -> void:
	if _queued_scene_path.is_empty():
		return
	var tree := get_tree()
	var err: int = tree.change_scene_to_file(_queued_scene_path)
	if err != OK:
		push_error("Failed to change scene to %s" % _queued_scene_path)
		return
	await tree.process_frame
	_place_player(_queued_spawn_name)
	_queued_scene_path = ""
	_queued_spawn_name = ""

func _place_player(spawn_name: String) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var root := get_tree().current_scene
	if root == null:
		return
	var marker: Marker2D = root.find_child(spawn_name, true, false) as Marker2D
	if marker == null:
		return
	player.global_position = marker.global_position
