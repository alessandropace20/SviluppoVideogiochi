extends Node2D

signal cutscene_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: CharacterBody2D = $Entities/Player
@onready var cutscene_camera: Camera2D = $CutsceneCamera


func _ready() -> void:

	process_mode = Node.PROCESS_MODE_ALWAYS
	animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
	cutscene_camera.process_mode = Node.PROCESS_MODE_ALWAYS
	cutscene_camera.enabled = true
	cutscene_camera.make_current()
	player.enter_cutscene()
	animation_player.animation_finished.connect(
		_on_animation_finished
	)
	animation_player.play("intro")

func _on_animation_finished(animation_name: StringName) -> void:

	if animation_name != "intro":
		return
	cutscene_finished.emit()
