extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("rotate")


func _on_body_entered(body: Node) -> void:
	if body.name != "character_body_2d":
		return

	# TODO: Incrementare il contatore delle monete
	# coins += 1

	queue_free()
