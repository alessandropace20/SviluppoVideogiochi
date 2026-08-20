extends Node2D

@onready var play_button: TextureButton = $Control/VBoxContainer/Play
@onready var quit_button: TextureButton = $Control/VBoxContainer/Quit
@onready var menu_button: TextureButton = $Control/VBoxContainer/Menu
@onready var save_button: TextureButton = $Control/VBoxContainer/Save

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	save_button.pressed.connect(_on_save_pressed)
	# options_button.pressed.connect(_on_options_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	visible = true
	get_tree().paused = true

func _resume() -> void:
	visible = false
	get_tree().paused = false

func _on_play_pressed() -> void:
	_resume()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_menu_pressed() -> void:
	visible = false
	get_tree().paused = false

	var main = get_tree().current_scene
	if main.has_method("return_to_menu"):
		main.return_to_menu()

func _on_save_pressed() -> void:
	SaveManager.save_game()
