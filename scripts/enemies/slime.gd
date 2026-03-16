extends CharacterBody2D

@export var move_speed: float = 45.0
@export var max_hp: int = 2
@export var aggro_range: float = 120.0
@export var contact_damage: int = 1
@export var contact_cooldown: float = 0.8
@export var knockback_resistance: float = 0.8

var hp: int
var _player: Node2D
var _last_hit_time: float = -99.0
var _knockback_velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $ContactHitbox

var _frame_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp
	hitbox.area_entered.connect(_on_contact_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	_frame_timer += delta
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Node2D
	var chase_vector := Vector2.ZERO
	if _player != null:
		var dist := global_position.distance_to(_player.global_position)
		if dist <= aggro_range:
			chase_vector = global_position.direction_to(_player.global_position)

	velocity = chase_vector * move_speed + _knockback_velocity
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 250.0 * delta)
	move_and_slide()
	_update_sprite(chase_vector != Vector2.ZERO)

func receive_damage(amount: int, from_position: Vector2) -> void:
	hp -= amount
	_knockback_velocity = (global_position - from_position).normalized() * 120.0 * (1.0 - knockback_resistance)
	modulate = Color(1.0, 0.7, 0.7)
	await get_tree().create_timer(0.08).timeout
	modulate = Color.WHITE
	if hp <= 0:
		queue_free()

func get_contact_damage() -> int:
	return contact_damage

func _on_contact_hitbox_area_entered(area: Area2D) -> void:
	if not area.get_parent().is_in_group("player"):
		return
	if Time.get_ticks_msec() / 1000.0 - _last_hit_time < contact_cooldown:
		return
	_last_hit_time = Time.get_ticks_msec() / 1000.0
	var player := area.get_parent()
	if player.has_method("receive_damage"):
		player.call("receive_damage", contact_damage, global_position)

func _update_sprite(is_moving: bool) -> void:
	if not is_moving:
		sprite.frame = 1
		return
	sprite.frame = 1 + (int(floor(_frame_timer * 6.0)) % 2)
