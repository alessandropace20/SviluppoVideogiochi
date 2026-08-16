extends Node

const SAVE_PATH := "user://savegame.save"

var defeated_enemies: Array[String] = []
var collected_coins: Array[String] = []

var _pending_health: int = -1

func _ready() -> void:
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.coin_collected.connect(_on_coin_collected)

func _on_enemy_defeated(enemy_id: String) -> void:
	if not defeated_enemies.has(enemy_id):
		defeated_enemies.append(enemy_id)

func _on_coin_collected(coin_id: String) -> void:
	if not collected_coins.has(coin_id):
		collected_coins.append(coin_id)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var player = get_tree().get_first_node_in_group("player")

	var save_data := {
		"total_coins": EventBus.total_coins,
		"current_level": get_tree().current_scene.name if get_tree().current_scene else "demo",
		"player_health": player.health if player else -1,
		"defeated_enemies": defeated_enemies,
		"collected_coins": collected_coins
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: impossibile aprire il file di salvataggio in scrittura. Errore: " + str(FileAccess.get_open_error()))
		return

	file.store_var(save_data)
	file.close()
	print("Partita salvata in: ", ProjectSettings.globalize_path(SAVE_PATH))

func load_game() -> void:
	if not has_save():
		push_warning("SaveManager: nessun salvataggio trovato.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: impossibile aprire il file di salvataggio in lettura. Errore: " + str(FileAccess.get_open_error()))
		return

	var save_data = file.get_var()
	file.close()

	if typeof(save_data) != TYPE_DICTIONARY:
		push_error("SaveManager: file di salvataggio corrotto o in formato inatteso.")
		return

	EventBus.total_coins = save_data.get("total_coins", 0)
	EventBus.coins_changed.emit(EventBus.total_coins)

	defeated_enemies = save_data.get("defeated_enemies", [])
	collected_coins = save_data.get("collected_coins", [])
	_pending_health = save_data.get("player_health", -1)

	print("Partita caricata. Monete: ", EventBus.total_coins,
		" | Nemici sconfitti: ", defeated_enemies.size(),
		" | Coin raccolte: ", collected_coins.size())

func apply_to_level() -> void:
	if _pending_health >= 0:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.health = _pending_health
			EventBus.player_health_changed.emit(player.health, player.max_health)
		_pending_health = -1

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var id = enemy.enemy_id if "enemy_id" in enemy else enemy.name
		if defeated_enemies.has(id):
			enemy.queue_free()

	for coin in get_tree().get_nodes_in_group("coins"):
		if not is_instance_valid(coin):
			continue
		var id = coin.coin_id if "coin_id" in coin else coin.name
		if collected_coins.has(id):
			coin.queue_free()

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	defeated_enemies.clear()
	collected_coins.clear()
	
func reset_progress() -> void:
	defeated_enemies.clear()
	collected_coins.clear()
	_pending_health = -1
