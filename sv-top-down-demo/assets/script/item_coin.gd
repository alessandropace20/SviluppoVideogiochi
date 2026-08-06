extends Area2D

@onready var sprite: AnimatedSprite2D = $coin
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	sprite.play("rotate")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name, " | gruppi: ", body.get_groups())
	collision.set_deferred("disabled", true)
	sprite.play("plus")
