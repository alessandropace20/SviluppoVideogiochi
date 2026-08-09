extends CharacterBody2D
@export var speed: float = 150.0
@export var max_health: int = 100
@export var attack_damage := 15
@export var attack2_damage := 25
@export var attack_cooldown := 0.0
@export var attack2_cooldown := 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var hitboxes := {
	"right": $AttackArea/HitBox_right,
	"left": $AttackArea/HitBox_left,
	"up": $AttackArea/HitBox_up,
	"down": $AttackArea/HitBox_down
}

const ACTIVE_FRAME := 1
const END_FRAME := 3

var facing: String = "down"
var health: int
var is_attacking := false
var can_attack := true
var is_dead := false
var current_attack_damage := 0

func _ready() -> void:
	health = max_health
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	
	for hb in hitboxes.values():
		hb.set_deferred("disabled", true)

func _physics_process(delta):
	if is_dead:
		return

	handle_attack_input()
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * speed
	if !is_attacking:
		update_animation(input_vector)
	move_and_slide()

func handle_attack_input() -> void:
	if not can_attack or is_attacking:
		return
	if Input.is_action_just_pressed("attack"):
		start_attack("attack", attack_damage)
	elif Input.is_action_just_pressed("attack2"):
		start_attack("attack2", attack2_damage)

func start_attack(attack_name: String, damage: int) -> void:
	is_attacking = true
	can_attack = false
	current_attack_damage = damage
	attack_area.damage = damage
	sprite.play(attack_name + "_" + facing)

func _on_frame_changed() -> void:
	if not is_attacking or not sprite.animation.begins_with("attack"):
		return
	if sprite.frame == ACTIVE_FRAME:
		enable_hitbox(facing)
	elif sprite.frame == END_FRAME:
		disable_all_hitboxes()

func enable_hitbox(direction: String) -> void:
	for dir in hitboxes.keys():
		hitboxes[dir].set_deferred("disabled", dir != direction)

func disable_all_hitboxes() -> void:
	for hb in hitboxes.values():
		hb.set_deferred("disabled", true)

func _on_animation_finished():
	if is_dead and sprite.animation.begins_with("die"):
		queue_free()  # o gestisci qui game over/respawn invece di rimuovere il player
		return

	if sprite.animation.begins_with("attack"):
		is_attacking = false
		disable_all_hitboxes()
		var cooldown = attack2_cooldown if sprite.animation.begins_with("attack2") else attack_cooldown
		await get_tree().create_timer(cooldown).timeout
		can_attack = true

func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		sprite.play("idle_" + facing)
		return
	if abs(direction.x) > abs(direction.y):
		facing = "right" if direction.x > 0 else "left"
	else:
		facing = "down" if direction.y > 0 else "up"
	sprite.play("run_" + facing)

func take_damage(damage: int, source_position: Vector2 = global_position) -> void:
	if is_dead:
		return

	health -= damage
	if health < 0:
		health = 0
	print("Il giocatore ha subito ", damage, " danni. HP: ", health)
	if health == 0:
		die()

func die() -> void:
	is_dead = true
	is_attacking = false
	can_attack = false
	velocity = Vector2.ZERO
	disable_all_hitboxes()
	sprite.play("die")
