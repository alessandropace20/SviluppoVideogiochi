extends Node2D

@export var level_scenes: Dictionary[String, PackedScene] = {}
# Nell'Inspector: aggiungi chiave "demo" -> trascina LevelDemo.tscn come valore.
# Aggiungerai altre coppie man mano che crei nuovi livelli.

@onready var level_container: Node2D = $Game/Level
@onready var ui: CanvasLayer = $Game/UI
@onready var menu_layer: CanvasLayer = $MenuLayer

var current_level: Node = null

func _ready() -> void:
	get_tree().paused = true
	ui.visible = false
	menu_layer.visible = true

	EventBus.start_level_requested.connect(_on_start_level_requested)
	EventBus.return_to_menu_requested.connect(_on_return_to_menu_requested)

func _on_start_level_requested(level_id: String) -> void:
	load_level(level_id)
	ui.visible = true
	menu_layer.visible = false
	get_tree().paused = false

func _on_return_to_menu_requested() -> void:
	unload_current_level()
	ui.visible = false
	menu_layer.visible = true
	get_tree().paused = true

func load_level(level_id: String) -> void:
	unload_current_level()

	if not level_scenes.has(level_id):
		push_error("Main: nessun livello registrato con id '" + level_id + "'")
		return

	var scene: PackedScene = level_scenes[level_id]
	current_level = scene.instantiate()
	level_container.add_child(current_level)

func unload_current_level() -> void:
	if current_level != null:
		current_level.queue_free()
		current_level = null
