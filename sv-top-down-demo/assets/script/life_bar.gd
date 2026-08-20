extends TextureProgressBar

@onready var health_label: Label = $Label

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)

func update_health_display(current_health: int, max_health: int) -> void:
	value = current_health
	max_value = max_health
	health_label.text = str(current_health)

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	max_value = max_health
	value = current_health
	update_health_display(value, max_value)
