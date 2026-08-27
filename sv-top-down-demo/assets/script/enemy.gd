extends CharacterBody2D

@export var speed := 60.0
@export var attack_range := 30.0
@export var attack_damage := 10
@export var attack_cooldown := 1.0
@export var max_health := 50
@export var reaction_time := 0.3

@export var enemy_id: String = ""  
@export var hurt_duration := 0.3
@export var knockback_strength := 80.0
@export var knockback_friction := 600.0  

@export var attack_sound: AudioStream
@export var hurt_sound: AudioStream
@export var death_sound: AudioStream

@export_group("Patrol")
@export var patrol_distance := 20.0          
@export var patrol_wait_time_min := 0.5      
@export var patrol_wait_time_max := 1.5      
@export var patrol_arrival_distance := 4.0   
@export var patrol_stuck_time := 1.0         
@export var patrol_stuck_min_progress := 3.0 

const PATROL_SPEED_FACTOR := 0.6  

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

@onready var sfx: AudioStreamPlayer2D = $SFX

const ACTIVE_FRAME := 1
const END_FRAME := 3
const HEALTH_BAR_VISIBLE_TIME := 3.0

enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEAD }
var state: State = State.IDLE

var player: CharacterBody2D = null
var facing := "down"
var health: int
var knockback_velocity := Vector2.ZERO

var health_bar_timer: Timer
var reaction_timer: Timer
var attack_cooldown_timer: Timer
var hurt_timer: Timer

var patrol_wait_timer: Timer
var spawn_position: Vector2
var patrol_points: Array[Vector2] = []   
var patrol_index := 0
var patrol_target: Vector2
var is_patrol_waiting := false
var patrol_stuck_elapsed := 0.0
var patrol_last_check_position: Vector2
var rng := RandomNumberGenerator.new()

var _patrol_initialized := false


func _ready():
	if enemy_id == "":
		enemy_id = name

	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false

	rng.randomize()

	health_bar_timer = _make_timer(_on_health_bar_timer_timeout)
	reaction_timer = _make_timer(_on_reaction_timeout)
	attack_cooldown_timer = _make_timer(func(): pass)
	hurt_timer = _make_timer(_on_hurt_timeout)
	patrol_wait_timer = _make_timer(_on_patrol_wait_timeout)

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
	_exit_state(state)
	state = new_state
	_enter_state(new_state)


func _exit_state(old_state: State) -> void:
	match old_state:
		State.PATROL:
			is_patrol_waiting = false


func _enter_state(new_state: State) -> void:
	match new_state:
		State.PATROL:
			_enter_patrol()

func _physics_process(delta):

	if not _patrol_initialized:
		_patrol_initialized = true
		spawn_position = global_position
		change_state(State.PATROL)

	match state:
		State.DEAD:
			return
		State.IDLE:
			velocity = Vector2.ZERO
			sprite.play("idle_" + facing)
			move_and_slide()
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase()
		State.ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()
		State.HURT:
			_process_hurt(delta)


func _enter_patrol() -> void:
	is_patrol_waiting = false

	if patrol_points.is_empty():
		patrol_points = [
			spawn_position + Vector2(-patrol_distance, 0.0),  
			spawn_position + Vector2(patrol_distance, 0.0)    
		]

		var dist_left := global_position.distance_to(patrol_points[0])
		var dist_right := global_position.distance_to(patrol_points[1])
		patrol_index = 0 if dist_left <= dist_right else 1

	patrol_target = patrol_points[patrol_index]
	patrol_stuck_elapsed = 0.0
	patrol_last_check_position = global_position

func _process_patrol(delta: float) -> void:
	if is_patrol_waiting:
		velocity = Vector2.ZERO
		sprite.play("idle_" + facing)
		move_and_slide()
		return

	var to_target := patrol_target - global_position
	var distance := to_target.length()

	if distance <= patrol_arrival_distance:
		_start_patrol_wait()
		return

	var direction := to_target.normalized()
	update_facing(direction)
	velocity = direction * speed * PATROL_SPEED_FACTOR
	sprite.play("run_" + facing)
	move_and_slide()


	patrol_stuck_elapsed += delta
	if patrol_stuck_elapsed >= patrol_stuck_time:
		var progressed := global_position.distance_to(patrol_last_check_position)
		if progressed < patrol_stuck_min_progress:
			patrol_index = 1 - patrol_index
			patrol_target = patrol_points[patrol_index]
		patrol_stuck_elapsed = 0.0
		patrol_last_check_position = global_position

func _start_patrol_wait() -> void:
	is_patrol_waiting = true
	velocity = Vector2.ZERO
	sprite.play("idle_" + facing)
	var wait_time := rng.randf_range(patrol_wait_time_min, patrol_wait_time_max)
	patrol_wait_timer.start(wait_time)

func _on_patrol_wait_timeout() -> void:
	if state != State.PATROL:
		return
	is_patrol_waiting = false
	patrol_index = 1 - patrol_index
	patrol_target = patrol_points[patrol_index]
	patrol_stuck_elapsed = 0.0
	patrol_last_check_position = global_position


func _process_chase() -> void:
	if player == null:
		change_state(State.PATROL)
		return

	var direction := (player.global_position - global_position).normalized()
	update_facing(direction)

	var distance := global_position.distance_to(player.global_position)


	if distance <= attack_range:
		velocity = Vector2.ZERO
		move_and_slide()


		if attack_cooldown_timer.is_stopped():
			start_attack()

		return


	var difficulty_speed = speed * DifficultyManager.get_enemy_speed_multiplier()
	velocity = direction * difficulty_speed

	sprite.play("run_" + facing)
	move_and_slide()

func start_attack() -> void:
	change_state(State.ATTACK)
	attack_area.damage = attack_damage
	play_sfx(attack_sound)
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
		change_state(State.PATROL)

func enable_hitbox(direction: String) -> void:
	for dir in hitboxes.keys():
		hitboxes[dir].set_deferred("disabled", dir != direction)

func disable_all_hitboxes() -> void:
	for hb in hitboxes.values():
		hb.set_deferred("disabled", true)


func _process_hurt(delta) -> void:

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
	play_sfx(hurt_sound)
	hurt_timer.start(hurt_duration)

func _on_hurt_timeout() -> void:
	if state == State.DEAD:
		return
	knockback_velocity = Vector2.ZERO
	if player != null:
		change_state(State.CHASE)
	else:
		change_state(State.PATROL)


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
	play_sfx(death_sound)
	change_state(State.DEAD)
	velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO
	disable_all_hitboxes()
	health_bar.visible = false
	sprite.play("die_" + facing)
	EventBus.enemy_defeated.emit(enemy_id)

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

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	sfx.stream = stream
	sfx.play()
