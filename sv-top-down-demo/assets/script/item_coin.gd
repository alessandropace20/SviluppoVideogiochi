extends Area2D
@onready var sprite: AnimatedSprite2D = $Coin
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var coin_value: int = 20
@export var coin_id: String = ""

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
	print("Coin raccolta, valore: ", coin_value, " | total_coins prima: ", EventBus.total_coins)
	EventBus.add_coins(coin_value)
	print("total_coins dopo: ", EventBus.total_coins)
	EventBus.coin_collected.emit(coin_id)

func _on_animation_finished() -> void:
	if sprite.animation == "plus":
		queue_free()
