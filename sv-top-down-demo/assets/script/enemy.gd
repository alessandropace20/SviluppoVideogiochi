extends CharacterBody2D
@export var speed := 30.0
@export var attack_distance := 30.0
@export var attack_damage := 10
@export var attack_cooldown := 1.0
@export var max_health := 50

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var health_bar: TextureProgressBar = $UI/TextureProgressBar
@onready var attack_area: Area2D = $AttackArea
@onready var hitboxes := {
	"right": $AttackArea/HitBox_right,
	"left": $AttackArea/HitBox_left,
	"up": $AttackArea/HitBox_up,
	"down": $AttackArea/HitBox_down
}

const ACTIVE_FRAME := 1
const END_FRAME := 3
const HEALTH_BAR_VISIBLE_TIME := 3.0

var player: CharacterBody2D = null
var facing := "down"
var can_attack := true
var is_attacking := false
var is_dead := false
var health: int

var health_bar_timer: Timer

func _ready():
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false

	# Timer per nascondere la barra dopo 3 secondi dall'ultimo colpo
	health_bar_timer = Timer.new()
	health_bar_timer.one_shot = true
	health_bar_timer.wait_time = HEALTH_BAR_VISIBLE_TIME
	add_child(health_bar_timer)
	health_bar_timer.timeout.connect(_on_health_bar_timer_timeout)

	for hb in hitboxes.values():
		hb.disabled = true
	sprite.play("idle_down")
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _physics_process(delta):
	if is_dead:
		return

	if player == null:
		velocity = Vector2.ZERO
		if not is_attacking:
			sprite.play("idle_" + facing)
		move_and_slide()
		return

	var direction = (player.global_position - global_position).normalized()

	if not is_attacking:
		update_facing(direction)

	var distance = global_position.distance_to(player.global_position)

	if is_attacking:
		velocity = Vector2.ZERO
	elif distance > attack_distance:
		velocity = direction * speed
		sprite.play("idle_" + facing)
	else:
		velocity = Vector2.ZERO
		if can_attack:
			attack()

	move_and_slide()

func enable_hitbox(direction: String) -> void:
	for dir in hitboxes.keys():
		hitboxes[dir].disabled = (dir != direction)

func disable_all_hitboxes() -> void:
	for hb in hitboxes.values():
		hb.disabled = true

func attack():
	is_attacking = true
	can_attack = false
	attack_area.damage = attack_damage
	sprite.play("attack_" + facing)
	await sprite.animation_finished
	is_attacking = false
	disable_all_hitboxes()
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_frame_changed() -> void:
	if not is_attacking or not sprite.animation.begins_with("attack"):
		return
	if sprite.frame == ACTIVE_FRAME:
		enable_hitbox(facing)
	elif sprite.frame == END_FRAME:
		disable_all_hitboxes()

func take_damage(damage: int) -> void:
	if is_dead:
		return

	health -= damage
	if health < 0:
		health = 0
	update_health_bar()

	show_health_bar()

	print("Il nemico ha subito ", damage, " danni. HP: ", health)
	if health == 0:
		die()

func show_health_bar() -> void:
	health_bar.visible = true
	health_bar_timer.start(HEALTH_BAR_VISIBLE_TIME)  # riparte da 3s ad ogni colpo

func _on_health_bar_timer_timeout() -> void:
	health_bar.visible = false

func update_health_bar() -> void:
	health_bar.value = health

func die() -> void:
	is_dead = true
	is_attacking = false
	can_attack = false
	velocity = Vector2.ZERO
	disable_all_hitboxes()
	health_bar.visible = false
	sprite.play("die")

func _on_animation_finished() -> void:
	if is_dead and sprite.animation.begins_with("die"):
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
