extends Area2D
@onready var sprite: AnimatedSprite2D = $Coin
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var coin_value: int = 1

func _ready() -> void:
	sprite.play("rotate")
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	collision.set_deferred("disabled", true)
	sprite.play("plus")
	EventBus.add_coins(coin_value)

func _on_animation_finished() -> void:
	if sprite.animation == "plus":
		queue_free()
