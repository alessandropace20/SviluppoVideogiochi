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

	AudioManager.play_music(menu_music)

	menu_layer.play_requested.connect(_on_play_requested)
	menu_layer.load_requested.connect(_on_load_requested)


func _on_play_requested() -> void:
	SaveManager.reset_progress()
	EventBus.reset_run()

	_start_cutscene()


func _on_load_requested() -> void:
	if not SaveManager.has_save():
		print("Nessun salvataggio trovato")
		return

	SaveManager.load_game()

	# Load salta completamente la cutscene
	_start_level()

	SaveManager.apply_to_level()
	

func _start_cutscene() -> void:
	if cutscene_scene == null:
		push_error("cutscene_scene non assegnata!")

		_start_level()
		return

	unload_current_level()
	unload_current_cutscene()

	ui.visible = false
	menu_layer.visible = false

	get_tree().paused = true

	current_cutscene = cutscene_scene.instantiate()

	add_child(current_cutscene)

	current_cutscene.process_mode = Node.PROCESS_MODE_ALWAYS

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
	unload_current_cutscene()

	_start_level()


func unload_current_cutscene() -> void:
	if current_cutscene != null:
		current_cutscene.queue_free()
		current_cutscene = null

func _start_level() -> void:
	if level_scene == null:
		push_error("level_scene non assegnata!")
		return

	unload_current_level()

	current_level = level_scene.instantiate()
	level_container.add_child(current_level)

	AudioManager.play_music(levelDemo_music)

	ui.visible = true
	menu_layer.visible = false

	get_tree().paused = false


func unload_current_level() -> void:
	if current_level != null:
		current_level.queue_free()
		current_level = null


func return_to_menu() -> void:
	unload_current_level()

	unload_current_cutscene()

	ui.visible = false

	menu_layer.visible = true

	AudioManager.play_music(menu_music)

	get_tree().paused = true
