extends CharacterBody2D

@export var speed: float = 150.0
@export var max_health: int = 100
@export var attack_damage := 15

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var facing: String = "down"
var health: int

func _ready() -> void:
	health = max_health

func _physics_process(delta):
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = input_vector * speed

	update_animation(input_vector)

	move_and_slide()


func update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		sprite.play("idle_" + facing)
		return

	# Determina la direzione principale
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			facing = "right"
		else:
			facing = "left"
	else:
		if direction.y > 0:
			facing = "down"
		else:
			facing = "up"

	sprite.play("run_" + facing)


func take_damage(attack_damage: int) -> void:
	health -= attack_damage

	if health < 0:
		health = 0

	print(name, " ha subito ", attack_damage, " danni. HP: ", health)

	if health == 0:
		print("Il giocatore è morto")
		

func attack() -> void:

	var bodies = $AttackArea.get_overlapping_bodies()

	for body in bodies:

		if body.is_in_group("enemies"):

			body.take_damage(attack_damage)
