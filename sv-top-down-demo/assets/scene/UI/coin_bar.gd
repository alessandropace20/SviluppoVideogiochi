extends TextureProgressBar

@export var max_coins: int = 100  # valore massimo della barra (es. monete per completare il livello)

func _ready() -> void:
	max_value = max_coins
	value = EventBus.total_coins  # sincronizza subito col valore attuale
	EventBus.coins_changed.connect(_on_coins_changed)

func _on_coins_changed(total_coins: int) -> void:
	value = total_coins
