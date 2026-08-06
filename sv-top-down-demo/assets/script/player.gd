extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 100
@export var attack_damage := 15
@export var attack2_damage := 25
@export var attack_cooldown := 0.0
@export var attack2_cooldown := 0.

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

# Riferimenti alle hitbox direzionali (CollisionShape2D dentro AttackArea)
@onready var hitboxes := {
	"right": $AttackArea/HitBox_right,
	"left": $AttackArea/HitBox_left,
	"up": $AttackArea/HitBox_up,
	"down": $AttackArea/HitBox_down
}

var facing: String = "down"
var health: int

var is_attacking := false
var can_attack := true
var current_attack_damage := 0

func _ready() -> void:
	health = max_health
	sprite.animation_finished.connect(_on_animation_finished)

	# Disattiva tutte le hitbox all'avvio
	for hb in hitboxes.values():
		hb.disabled = true

func _physics_process(delta):
	handle_attack_input()

	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	
	velocity = input_vector * speed
	
	# Durante l'attacco il player non si muove (rimuovi questo blocco se vuoi permettere il movimento in attacco)
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

	sprite.play(attack_name + "_" + facing)
	enable_hitbox(facing)

func enable_hitbox(direction: String) -> void:
	for dir in hitboxes.keys():
		hitboxes[dir].disabled = (dir != direction)

func disable_all_hitboxes() -> void:
	for hb in hitboxes.values():
		hb.disabled = true

func _on_animation_finished() -> void:
	# Si attiva alla fine di QUALSIASI animazione, quindi filtriamo solo quelle di attacco
	if sprite.animation.begins_with("attack"):
		is_attacking = false
		disable_all_hitboxes()
		deal_attack_damage()

		# Cooldown differenziato in base al tipo di attacco
		var cooldown = attack2_cooldown if sprite.animation.begins_with("attack2") else attack_cooldown
		await get_tree().create_timer(cooldown).timeout
		can_attack = true

func deal_attack_damage() -> void:
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(current_attack_damage)

func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		sprite.play("idle_" + facing)
		return

	if abs(direction.x) > abs(direction.y):
		facing = "right" if direction.x > 0 else "left"
	else:
		facing = "down" if direction.y > 0 else "up"

	sprite.play("run_" + facing)

func take_damage(damage: int) -> void:
	health -= damage
	if health < 0:
		health = 0
	print("Il giocatore ha subito ", damage, " danni. HP: ", health)
	if health == 0:
		print("Il giocatore è morto")
