extends Node2D

@export var level_scene: PackedScene

@onready var level_container: Node2D = $Game/Level
@onready var ui: CanvasLayer = $Game/UI
@onready var menu_layer: CanvasLayer = $MenuLayer

var current_level: Node = null


func _ready() -> void:
	get_tree().paused = true
	
	ui.visible = false
	menu_layer.visible = true

	menu_layer.play_requested.connect(_on_play_requested)
	menu_layer.load_requested.connect(_on_load_requested)


func _on_play_requested() -> void:
	SaveManager.reset_progress()
	EventBus.reset_run()
	_start_level()


func _on_load_requested() -> void:
	if not SaveManager.has_save():
		print("Nessun salvataggio trovato")
		return

	SaveManager.load_game()
	_start_level()
	SaveManager.apply_to_level()


func _start_level() -> void:
	print("========== START LEVEL ==========")
	print("1 - Main inside tree: ", is_inside_tree())
	print("1 - Tree: ", get_tree())

	if level_scene == null:
		push_error("level_scene non assegnata!")
		return

	unload_current_level()

	current_level = level_scene.instantiate()

	level_container.add_child(current_level)

	ui.visible = true
	menu_layer.visible = false

	get_tree().paused = false


func return_to_menu() -> void:
	unload_current_level()

	ui.visible = false
	menu_layer.visible = true

	get_tree().paused = true


func unload_current_level() -> void:
	if current_level != null:
		current_level.queue_free()
		current_level = null
