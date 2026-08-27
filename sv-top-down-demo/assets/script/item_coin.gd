extends Area2D
@onready var sprite: AnimatedSprite2D = $Coin
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sfx: AudioStreamPlayer2D = $SFX

@export var coin_value: int = 10
@export var coin_id: String = ""
@export var coin_collect: AudioStream

func _ready() -> void:
	if coin_id == "":
		coin_id = name
	add_to_group("coins")
	sprite.play("rotate")
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	collision.set_deferred("disabled", true)
	sprite.play("plus")
	play_sfx(coin_collect)
	EventBus.add_coins(coin_value)
	EventBus.coin_collected.emit(coin_id)

func _on_animation_finished() -> void:
	if sprite.animation == "plus":
		queue_free()

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	sfx.stream = stream
	sfx.play()
