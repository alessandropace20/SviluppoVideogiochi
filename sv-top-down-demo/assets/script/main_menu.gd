extends CanvasLayer

signal play_requested
signal load_requested

@onready var panels := {
	"main": $MainMenu,
	"options": $OptionsPanel
}

@onready var play_button: TextureButton = $MainMenu/VBoxContainer/PlayButton
@onready var load_button: TextureButton = $MainMenu/VBoxContainer/LoadButton
@onready var options_button: TextureButton = $MainMenu/VBoxContainer/OptionsButton
@onready var quit_button: TextureButton =  $MainMenu/VBoxContainer/QuitButton

@onready var easy_button: TextureButton = $OptionsPanel/HBoxContainer/Easy
@onready var normal_button: TextureButton = $OptionsPanel/HBoxContainer/Normal
@onready var hard_button: TextureButton = $OptionsPanel/HBoxContainer/Hard
@onready var options_back_button: TextureButton = $OptionsPanel/BackButton


func _ready() -> void:
	# Il menu deve continuare a funzionare anche quando
	# il gioco è in pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# I pannelli occupano tutta l'area del CanvasLayer.
	for panel: Control in panels.values():
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Mostra il menu principale all'avvio.
	show_panel("main")

	# Collegamento pulsanti.
	play_button.pressed.connect(_request_play)
	load_button.pressed.connect(_request_load)
	options_button.pressed.connect(_open_options)
	quit_button.pressed.connect(_quit_game)

	options_back_button.pressed.connect(_open_main_menu)
	
	easy_button.pressed.connect(_on_easy_pressed)
	normal_button.pressed.connect(_on_normal_pressed)
	hard_button.pressed.connect(_on_hard_pressed)


func _request_play() -> void:
	play_requested.emit()


func _request_load() -> void:
	load_requested.emit()


func _open_options() -> void:
	show_panel("options")


func _open_main_menu() -> void:
	show_panel("main")


func _quit_game() -> void:
	get_tree().quit()

func show_panel(panel_name: String) -> void:
	for key in panels:
		panels[key].visible = (key == panel_name)
		
func _on_easy_pressed() -> void:
	DifficultyManager.set_difficulty(
		DifficultyManager.Difficulty.EASY
	)


func _on_normal_pressed() -> void:
	DifficultyManager.set_difficulty(
		DifficultyManager.Difficulty.NORMAL
	)


func _on_hard_pressed() -> void:
	DifficultyManager.set_difficulty(
		DifficultyManager.Difficulty.HARD
	)
