extends CharacterBody2D

@export var speed := 100.0
@export var attack_range := 30.0
@export var attack_damage := 30
@export var attack_cooldown := 2.0
@export var max_health := 200
@export var reaction_time := 0.5

@export var hurt_duration := 0.3
@export var knockback_strength := 130.0
@export var knockback_friction := 600.0  # quanto velocemente il knockback rallenta

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

enum State { IDLE, CHASE, ATTACK, HURT, DEAD }
var state: State = State.IDLE

var player: CharacterBody2D = null
var facing := "down"
var health: int
var knockback_velocity := Vector2.ZERO

var health_bar_timer: Timer
var reaction_timer: Timer
var attack_cooldown_timer: Timer
var hurt_timer: Timer

func _ready():
	print("ENEMY SPAWNED: ", name)

	print("POSITION: ", global_position)
	print("SPRITE: ", sprite)
	print("SPRITE VISIBLE: ", sprite.visible)
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false 

	health_bar_timer = _make_timer(_on_health_bar_timer_timeout)
	reaction_timer = _make_timer(_on_reaction_timeout)
	attack_cooldown_timer = _make_timer(func(): pass)
	hurt_timer = _make_timer(_on_hurt_timeout)

	for hb in hitboxes.values():
		hb.set_deferred("disabled", true)

	sprite.play("idle_down")
	sprite.frame_changed.connect(_on_frame_changed)

	if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
		detection_area.body_exited.connect(_on_detection_area_body_exited)

func _make_timer(callback: Callable) -> Timer:
	var t := Timer.new()
	t.one_shot = true
	add_child(t)
	t.timeout.connect(callback)
	return t

func change_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state

func _physics_process(delta):
	match state:
		State.DEAD:
			return
		State.IDLE:
			velocity = Vector2.ZERO
			sprite.play("idle_" + facing)
			move_and_slide()
		State.CHASE:
			_process_chase()
		State.ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()
		State.HURT:
			_process_hurt(delta)

func _process_chase() -> void:
	if player == null:
		change_state(State.IDLE)
		return

	var direction = (player.global_position - global_position).normalized()
	update_facing(direction)
	var distance = global_position.distance_to(player.global_position)

	if distance <= attack_range and attack_cooldown_timer.is_stopped():
		start_attack()
		return

	var difficulty_speed = speed * DifficultyManager.get_enemy_speed_multiplier()
	velocity = direction * difficulty_speed
	sprite.play("run_" + facing) # o "run_" + facing se disponibile
	move_and_slide()

func start_attack() -> void:
	change_state(State.ATTACK)
	attack_area.damage = attack_damage
	sprite.play("attack_" + facing)

func _on_frame_changed() -> void:
	if state != State.ATTACK or not sprite.animation.begins_with("attack"):
		return
	if sprite.frame == ACTIVE_FRAME:
		enable_hitbox(facing)
	elif sprite.frame == END_FRAME:
		disable_all_hitboxes()
	elif sprite.frame == sprite.sprite_frames.get_frame_count(sprite.animation) - 1:
		_finish_attack()

func _finish_attack() -> void:
	disable_all_hitboxes()
	attack_cooldown_timer.start(attack_cooldown)

	if state == State.DEAD or state == State.HURT:
		return

	if player != null:
		change_state(State.CHASE)
	else:
		change_state(State.IDLE)

func enable_hitbox(direction: String) -> void:
	for dir in hitboxes.keys():
		hitboxes[dir].set_deferred("disabled", dir != direction)

func disable_all_hitboxes() -> void:
	for hb in hitboxes.values():
		hb.set_deferred("disabled", true)

# --- HURT ---

func _process_hurt(delta) -> void:
	# Il knockback si smorza gradualmente con un attrito, invece di sparire di colpo
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	velocity = knockback_velocity
	move_and_slide()

func enter_hurt(source_position: Vector2, knockback_force: float = -1.0) -> void:
	if state == State.DEAD:
		return

	disable_all_hitboxes()

	var force = knockback_force if knockback_force >= 0.0 else knockback_strength
	var knockback_dir = (global_position - source_position).normalized()
	knockback_velocity = knockback_dir * force

	change_state(State.HURT)
	sprite.play("hurt_" + facing)
	hurt_timer.start(hurt_duration)

func _on_hurt_timeout() -> void:
	if state == State.DEAD:
		return
	knockback_velocity = Vector2.ZERO
	if player != null:
		change_state(State.CHASE)
	else:
		change_state(State.IDLE)

# --- Danno / vita ---

func take_damage(damage: int, source_position: Vector2 = global_position, knockback_force: float = -1.0) -> void:
	if state == State.DEAD:
		return
	health -= damage
	if health < 0:
		health = 0
	update_health_bar()
	show_health_bar()
	print(name, " ha subito ", damage, " danni. HP: ", health)

	if health == 0:
		die()
	else:
		enter_hurt(source_position, knockback_force)

func show_health_bar() -> void:
	health_bar.visible = true
	health_bar_timer.start(HEALTH_BAR_VISIBLE_TIME)

func _on_health_bar_timer_timeout() -> void:
	health_bar.visible = false

func update_health_bar() -> void:
	health_bar.value = health

func die() -> void:
	change_state(State.DEAD)
	velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO
	disable_all_hitboxes()
	health_bar.visible = false
	sprite.play("die") # o sprite.stop() se preferisci il freeze silenzioso

func update_facing(dir):
	if abs(dir.x) > abs(dir.y):
		facing = "right" if dir.x > 0 else "left"
	else:
		facing = "down" if dir.y > 0 else "up"

func _on_detection_area_body_entered(body):
	if not body.is_in_group("player"):
		return
	player = body
	if state == State.DEAD or state == State.ATTACK or state == State.HURT:
		return
	reaction_timer.start(reaction_time)

func _on_reaction_timeout() -> void:
	if player != null and state != State.DEAD and state != State.ATTACK and state != State.HURT:
		change_state(State.CHASE)

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
