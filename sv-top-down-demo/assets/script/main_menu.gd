extends CanvasLayer

@onready var main_panel: Control = $Control/MainMenu
@onready var level_select_panel: Control = $Control/LevelSelectPanel
@onready var options_panel: Control = $Control/OptionsPanel

@onready var play_button: TextureButton = $Control/MainMenu/VBoxContainer/PlayButton
@onready var load_button: TextureButton = $Control/MainMenu/VBoxContainer/LoadButton
@onready var options_button: TextureButton = $Control/MainMenu/VBoxContainer/OptionsButton
@onready var quit_button: TextureButton = $Control/MainMenu/VBoxContainer/QuitButton

@onready var level1_button: TextureButton = $Control/LevelSelectPanel/VBoxContainer/LevelDemoButton
@onready var level_back_button: TextureButton = $Control/LevelSelectPanel/VBoxContainer/BackButton

@onready var options_back_button = $Control/OptionsPanel/BackButton
@onready var music_slider: HSlider = $Control/OptionsPanel/VBoxContainer/MusicSlider

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("--- READY --- main:", main_panel, " level_select:", level_select_panel, " options:", options_panel)
	show_panel(main_panel)

	play_button.pressed.connect(_on_play_pressed)
	load_button.pressed.connect(_on_load_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	level1_button.pressed.connect(_on_level1_pressed)
	level_back_button.pressed.connect(_on_back_pressed)
	
	options_back_button.pressed.connect(_on_back_pressed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	music_slider.value = AudioManager.music_volume_linear  

func show_panel(panel: Control) -> void:
	main_panel.visible = false
	level_select_panel.visible = false
	options_panel.visible = false
	panel.visible = true
	print("Stato dopo show_panel -> main:", main_panel.visible, " level_select:", level_select_panel.visible, " options:", options_panel.visible)

func _on_play_pressed() -> void:
	print("Play premuto!")
	show_panel(level_select_panel)

func _on_load_pressed() -> void:
	if SaveManager.has_save():
		SaveManager.load_game()
		EventBus.start_level_requested.emit("saved")
	else:
		print("Nessun salvataggio trovato")
		# qui puoi mostrare una piccola Label/tooltip invece del print

func _on_options_pressed() -> void:
	show_panel(options_panel)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_level1_pressed() -> void:
	EventBus.start_level_requested.emit("demo")

func _on_back_pressed() -> void:
	show_panel(main_panel)

func _on_music_slider_changed(value: float) -> void:
	AudioManager.set_music_volume(value)
