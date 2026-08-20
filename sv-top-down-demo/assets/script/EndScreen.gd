extends Node2D
@onready var title_label: Label = $Control/TitleLabel
@onready var retry_button: TextureButton = $Control/VBoxContainer/Retry
@onready var main_menu_button: TextureButton = $Control/VBoxContainer/Menu
@onready var quit_button: TextureButton = $Control/VBoxContainer/Quit

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	EventBus.game_over.connect(_on_game_over)
	EventBus.level_completed.connect(_on_level_completed)

func _on_game_over() -> void:
	title_label.text = "Game Over"
	_show_screen()

func _on_level_completed() -> void:
	title_label.text = "Livello completato!"
	_show_screen()

func _show_screen() -> void:
	visible = true
	get_tree().paused = true

func _on_retry_pressed() -> void:
	EventBus.reset_run()
	get_tree().paused = false
	visible = false
	var main = get_tree().current_scene
	if main.has_method("_start_level"):
		main._start_level()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	visible = false
	var main = get_tree().current_scene
	if main.has_method("return_to_menu"):
		main.return_to_menu()
		
func _on_quit_pressed() -> void:
	get_tree().quit()
