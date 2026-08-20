extends Node

signal player_health_changed(current_health: int, max_health: int)
signal player_died
signal coins_changed(total_coins: int)

signal door_message_requested(message: String)
signal door_message_cleared

signal enemy_defeated(enemy_id: String)
signal coin_collected(coin_id: String)

signal boss_defeated
signal level_completed
signal game_over
signal start_level_requested(level_id: String)
signal return_to_menu_requested

var total_coins: int = 0

func add_coins(amount: int) -> void:
	total_coins += amount
	coins_changed.emit(total_coins)
	print("Ho aumentato i coins, sono a: " + str(total_coins))

func reset_run() -> void:
	total_coins = 0
	coins_changed.emit(total_coins)
