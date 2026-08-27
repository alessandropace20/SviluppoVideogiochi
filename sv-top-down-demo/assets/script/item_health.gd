extends Area2D
@onready var sprite: AnimatedSprite2D = $Health
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sfx: AudioStreamPlayer2D = $SFX

@export var heal_amount: float = 25.0
@export var heal_sound: AudioStream

func _ready() -> void:
	sprite.play("default") 
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	collision.set_deferred("disabled", true)
	sprite.play("plus")
	play_sfx(heal_sound)

	if body.has_method("heal"):
		body.heal(heal_amount)

func _on_animation_finished() -> void:
	if sprite.animation == "plus":
		queue_free()

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	sfx.stream = stream
	sfx.play()
