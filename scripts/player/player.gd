extends CharacterBody2D

signal facing_changed(facing: Vector2)

@export var move_speed: float = 110.0
@export var invuln_time: float = 0.6
@export var attack_duration: float = 0.2
@export var sword_hitbox_path: NodePath

var facing: Vector2 = Vector2.DOWN
var can_move: bool = true
var can_attack: bool = true
var is_invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var sword_hitbox: Area2D = get_node_or_null(sword_hitbox_path)
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $Hurtbox

const PLAYER_FRAME_MAP := {
	"idle_down": 0,
	"walk_down": [0, 1],
	"attack_down": 2,
	"idle_up": 3,
	"walk_up": [3, 4],
	"attack_up": 5,
	"idle_side": 6,
	"walk_side": [6, 7],
	"attack_side": 8,
}

var _current_animation: StringName = &"idle_down"
var _frame_timer: float = 0.0

func _ready() -> void:
	add_to_group("player")
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	if sword_hitbox != null:
		sword_hitbox.call("set_owner_player", self)
	Game.movement_lock_changed.connect(_on_movement_lock_changed)

func _process(_delta: float) -> void:
	if DialogueManager.is_open() and Input.is_action_just_pressed("interact"):
		DialogueManager.advance()

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)
		move_and_slide()
		return

	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		_update_facing(input_vector)

	if can_move and not Game.is_movement_locked():
		velocity = input_vector * move_speed + knockback_velocity
	else:
		velocity = knockback_velocity

	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)
	move_and_slide()
	_update_animation(input_vector, delta)

	if Input.is_action_just_pressed("attack") and can_attack and not Game.is_movement_locked():
		start_attack()

func _update_facing(input_vector: Vector2) -> void:
	if abs(input_vector.x) > abs(input_vector.y):
		facing = Vector2.RIGHT if input_vector.x > 0.0 else Vector2.LEFT
	else:
		facing = Vector2.DOWN if input_vector.y > 0.0 else Vector2.UP
	facing_changed.emit(facing)
	if sword_hitbox != null:
		sword_hitbox.call("set_facing", facing)

func _update_animation(input_vector: Vector2, delta: float) -> void:
	_frame_timer += delta
	if not can_attack:
		if facing == Vector2.UP:
			_set_animation(&"attack_up")
		elif facing == Vector2.DOWN:
			_set_animation(&"attack_down")
		else:
			_set_animation(&"attack_side")
			sprite.flip_h = facing == Vector2.LEFT
		return

	if input_vector == Vector2.ZERO:
		if facing == Vector2.UP:
			_set_animation(&"idle_up")
		elif facing == Vector2.DOWN:
			_set_animation(&"idle_down")
		else:
			_set_animation(&"idle_side")
			sprite.flip_h = facing == Vector2.LEFT
	else:
		if facing == Vector2.UP:
			_set_animation(&"walk_up")
		elif facing == Vector2.DOWN:
			_set_animation(&"walk_down")
		else:
			_set_animation(&"walk_side")
			sprite.flip_h = facing == Vector2.LEFT

func _set_animation(animation_name: StringName) -> void:
	if not PLAYER_FRAME_MAP.has(animation_name):
		return
	if _current_animation != animation_name:
		_current_animation = animation_name
		_frame_timer = 0.0

	var frame_data: Variant = PLAYER_FRAME_MAP[animation_name]
	if frame_data is Array:
		var frames: Array = frame_data
		var frame_index := int(floor(_frame_timer * 8.0)) % frames.size()
		sprite.frame = frames[frame_index]
		return

	sprite.frame = int(frame_data)

func start_attack() -> void:
	can_attack = false
	can_move = false
	velocity = Vector2.ZERO
	if sword_hitbox != null:
		sword_hitbox.call("begin_swing")
	await get_tree().create_timer(attack_duration).timeout
	if sword_hitbox != null:
		sword_hitbox.call("end_swing")
	can_move = true
	can_attack = true

func receive_damage(amount: int, from_position: Vector2, knockback_force: float = 160.0) -> void:
	if is_invulnerable:
		return
	is_invulnerable = true
	Game.damage(amount)
	knockback_velocity = (global_position - from_position).normalized() * knockback_force
	modulate = Color(1.0, 0.6, 0.6)
	await get_tree().create_timer(invuln_time).timeout
	modulate = Color.WHITE
	is_invulnerable = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.has_method("get_contact_damage"):
		var dmg: int = area.call("get_contact_damage")
		receive_damage(dmg, area.global_position)

func _on_movement_lock_changed(locked: bool) -> void:
	if locked:
		velocity = Vector2.ZERO
