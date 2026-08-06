extends CharacterBody2D

@export var speed := 30.0
@export var attack_distance := 30.0
@export var attack_damage := 10
@export var attack_cooldown := 1.0
@export var max_health := 50

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var health_bar: TextureProgressBar = $UI/TextureProgressBar

var player: CharacterBody2D = null
var facing := "down"
var can_attack := true
var health: int

func _ready():
	health = max_health

	health_bar.max_value = max_health
	health_bar.value = health

	sprite.play("idle_down")

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _physics_process(delta):
	if player == null:
		velocity = Vector2.ZERO
		sprite.play("idle_" + facing)
		move_and_slide()
		return

	var direction = (player.global_position - global_position).normalized()
	update_facing(direction)

	var distance = global_position.distance_to(player.global_position)

	if distance > attack_distance:
		velocity = direction * speed
		sprite.play("idle_" + facing) # oppure "run_" + facing
	else:
		velocity = Vector2.ZERO
		if can_attack:
			attack()

	move_and_slide()

func attack():
	can_attack = false

	sprite.play("attack_" + facing)

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)

	await get_tree().create_timer(attack_cooldown).timeout

	can_attack = true

func take_damage(damage: int) -> void:
	health -= damage

	if health < 0:
		health = 0

	update_health_bar()

	print("Il nemico ha subito ", damage, " danni. HP: ", health)

	if health == 0:
		die()

func update_health_bar() -> void:
	health_bar.value = health

func die() -> void:
	queue_free()

func update_facing(dir):
	if abs(dir.x) > abs(dir.y):
		facing = "right" if dir.x > 0 else "left"
	else:
		facing = "down" if dir.y > 0 else "up"

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
