extends TextureProgressBar

@export var max_coins: int = 100

@onready var animated_sprite: AnimatedSprite2D = $MaxCoin_message

func _ready() -> void:
	animated_sprite.visible = false
	max_value = max_coins
	value = EventBus.total_coins
	
	EventBus.coins_changed.connect(_on_coins_changed)

	# Controlla anche il caso in cui il giocatore abbia già 100 monete
	if EventBus.total_coins >= max_coins:
		animated_sprite.visible = true
		animated_sprite.play("default")


func _on_coins_changed(total_coins: int) -> void:
	value = total_coins

	if total_coins >= max_coins:
		animated_sprite.visible = true
		animated_sprite.play("default")
