extends Node2D

signal cutscene_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: CharacterBody2D = $Entities/Player
@onready var cutscene_camera: Camera2D = $CutsceneCamera


func _ready() -> void:

	# La cutscene deve funzionare anche quando il gioco è in pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Anche i figli devono poter essere animati durante la pausa
	animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
	cutscene_camera.process_mode = Node.PROCESS_MODE_ALWAYS
	# Attiva la camera della cutscene
	cutscene_camera.enabled = true
	cutscene_camera.make_current()
	# Blocca il controllo del Player
	player.enter_cutscene()
	# Quando termina l'animazione, termina la cutscene
	animation_player.animation_finished.connect(
		_on_animation_finished
	)
	animation_player.play("intro")

func _on_animation_finished(animation_name: StringName) -> void:

	if animation_name != "intro":
		return
	cutscene_finished.emit()
