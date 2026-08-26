extends Node2D

@export var level_scene: PackedScene
@export var cutscene_scene: PackedScene

@onready var level_container: Node2D = $Game/Level
@onready var ui: CanvasLayer = $Game/UI
@onready var menu_layer: CanvasLayer = $MenuLayer

@export var menu_music: AudioStream
@export var levelDemo_music: AudioStream

var current_level: Node = null
var current_cutscene: Node = null


func _ready() -> void:
	get_tree().paused = true

	ui.visible = false
	menu_layer.visible = true

	# Avvia la musica del menu
	AudioManager.play_music(menu_music)

	menu_layer.play_requested.connect(_on_play_requested)
	menu_layer.load_requested.connect(_on_load_requested)


# ============================================================
# NUOVA PARTITA
# ============================================================

func _on_play_requested() -> void:
	SaveManager.reset_progress()
	EventBus.reset_run()

	# Prima della partita parte la cutscene
	_start_cutscene()


# ============================================================
# CARICAMENTO PARTITA
# ============================================================

func _on_load_requested() -> void:
	if not SaveManager.has_save():
		print("Nessun salvataggio trovato")
		return

	SaveManager.load_game()

	# IMPORTANTE:
	# Load salta completamente la cutscene.
	_start_level()

	SaveManager.apply_to_level()


# ============================================================
# CUTSCENE
# ============================================================

func _start_cutscene() -> void:
	if cutscene_scene == null:
		push_error("cutscene_scene non assegnata!")

		# Se per qualche motivo non hai assegnato
		# la cutscene, avvia comunque il livello.
		_start_level()
		return

	# Sicurezza: non devono esserci altre istanze attive
	unload_current_level()
	unload_current_cutscene()

	# Nasconde il gameplay/UI e il menu
	ui.visible = false
	menu_layer.visible = false

	# Manteniamo il gioco in pausa.
	# La cutscene verrà eseguita con PROCESS_MODE_ALWAYS.
	get_tree().paused = true

	# Istanzia la scena della cutscene
	current_cutscene = cutscene_scene.instantiate()

	# La aggiungiamo direttamente a Main.
	add_child(current_cutscene)

	# La cutscene deve funzionare anche con il gioco in pausa.
	current_cutscene.process_mode = Node.PROCESS_MODE_ALWAYS

	# Quando la cutscene termina, passiamo al livello.
	if current_cutscene.has_signal("cutscene_finished"):
		current_cutscene.cutscene_finished.connect(
			_on_cutscene_finished,
			CONNECT_ONE_SHOT
		)
	else:
		push_error(
			"Cutscene: il nodo root non possiede il signal 'cutscene_finished'."
		)


func _on_cutscene_finished() -> void:
	# Elimina la cutscene terminata
	unload_current_cutscene()

	# Ora avvia il livello vero e proprio
	_start_level()


func unload_current_cutscene() -> void:
	if current_cutscene != null:
		current_cutscene.queue_free()
		current_cutscene = null


# ============================================================
# LIVELLO
# ============================================================

func _start_level() -> void:
	if level_scene == null:
		push_error("level_scene non assegnata!")
		return

	# Sicurezza: elimina eventuali istanze precedenti
	unload_current_level()

	# Istanzia il livello
	current_level = level_scene.instantiate()
	level_container.add_child(current_level)

	# Cambia musica
	AudioManager.play_music(levelDemo_music)

	# Mostra UI e gameplay
	ui.visible = true
	menu_layer.visible = false

	# Riattiva il gioco
	get_tree().paused = false


func unload_current_level() -> void:
	if current_level != null:
		current_level.queue_free()
		current_level = null


# ============================================================
# RITORNO AL MENU
# ============================================================

func return_to_menu() -> void:
	# Elimina il livello
	unload_current_level()

	# Elimina anche un'eventuale cutscene
	unload_current_cutscene()

	# Nasconde UI gameplay
	ui.visible = false

	# Mostra il menu
	menu_layer.visible = true

	# Torna alla musica del menu
	AudioManager.play_music(menu_music)

	# Mette nuovamente in pausa il gioco
	get_tree().paused = true
