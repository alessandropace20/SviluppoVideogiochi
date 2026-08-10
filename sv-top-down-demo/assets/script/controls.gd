extends Control

@onready var play_button: TextureButton = $VBoxContainer/PlayButton
@onready var quit_button: TextureButton = $VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	EventBus.reset_run()
	get_tree().change_scene_to_file("res://scene/main.tscn")  # aggiorna il path alla tua scena principale

func _on_quit_pressed() -> void:
	get_tree().quit()
