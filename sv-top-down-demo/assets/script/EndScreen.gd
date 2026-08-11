extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var retry_button: Button = $VBoxContainer/RetryButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

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
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	visible = false
	EventBus.return_to_menu_requested.emit()
