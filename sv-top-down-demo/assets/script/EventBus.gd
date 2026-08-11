extends Node

signal player_health_changed(current_health: int, max_health: int)
signal player_died
signal coins_changed(total_coins: int)
signal level_completed
signal game_over
signal start_level_requested(level_id: String)
signal return_to_menu_requested

var total_coins: int = 0

func add_coins(amount: int) -> void:
	total_coins += amount
	coins_changed.emit(total_coins)

func reset_run() -> void:
	total_coins = 0
