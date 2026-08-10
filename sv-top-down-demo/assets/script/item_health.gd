extends Area2D
@onready var sprite: AnimatedSprite2D = $Health  # rinomina secondo il nome reale del nodo
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var heal_amount: int = 20

func _ready() -> void:
	sprite.play("default")  # o il nome dell'animazione di partenza che hai per questo item
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	collision.set_deferred("disabled", true)
	sprite.play("plus")

	if body.has_method("heal"):
		body.heal(heal_amount)

func _on_animation_finished() -> void:
	if sprite.animation == "plus":
		queue_free()
