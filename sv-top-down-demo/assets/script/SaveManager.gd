extends Node

const SAVE_PATH := "user://savegame.save"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var save_data := {
		"total_coins": EventBus.total_coins,
		"current_level": get_tree().current_scene.name if get_tree().current_scene else "demo"
		# aggiungi qui altri dati man mano che ti servono, es:
		# "player_health": ...,
		# "player_position": {"x": ..., "y": ...},
		# "unlocked_levels": [...]
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

	print("Partita caricata. Monete: ", EventBus.total_coins)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
