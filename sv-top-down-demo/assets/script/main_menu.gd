extends CanvasLayer

@onready var main_panel: Control = $MainMenu
@onready var level_select_panel: Control = $LevelSelectPanel
@onready var options_panel: Control = $OptionsPanel

@onready var play_button: TextureButton = $MainMenu/VBoxContainer/PlayButton
@onready var load_button: TextureButton = $MainMenu/VBoxContainer/LoadButton
@onready var options_button: TextureButton = $MainMenu/VBoxContainer/OptionsButton
@onready var quit_button: TextureButton = $MainMenu/VBoxContainer/QuitButton

@onready var level1_button: TextureButton = $LevelSelectPanel/VBoxContainer/LevelDemoButton
@onready var level_back_button: TextureButton = $LevelSelectPanel/VBoxContainer/BackButton

@onready var music_slider: HSlider = $OptionsPanel/VBoxContainer/MusicSlider

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	show_panel(main_panel)

	play_button.pressed.connect(_on_play_pressed)
	load_button.pressed.connect(_on_load_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	level1_button.pressed.connect(_on_level1_pressed)
	level_back_button.pressed.connect(_on_back_pressed)

	music_slider.value_changed.connect(_on_music_slider_changed)
	music_slider.value = AudioManager.music_volume_linear  

func show_panel(panel: Control) -> void:
	main_panel.visible = false
	level_select_panel.visible = false
	options_panel.visible = false
	panel.visible = true

func _on_play_pressed() -> void:
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
