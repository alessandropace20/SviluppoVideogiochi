extends Area2D

var level_completed := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if level_completed:
		return

	if not body.is_in_group("player"):
		return

	level_completed = true

	# Comunica che il livello è stato completato
	EventBus.level_completed.emit()
