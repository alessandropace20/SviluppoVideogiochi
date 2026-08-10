extends TextureProgressBar

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	max_value = max_health
	value = current_health
