extends Area2D

var level_completed := false
@onready var sfx: AudioStreamPlayer2D = $SFX

@export var trophy_sound: AudioStream

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if level_completed:
		return

	if not body.is_in_group("player"):
		return
		
	play_sfx(trophy_sound)
	level_completed = true
	
	EventBus.level_completed.emit()

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	sfx.stream = stream
	sfx.play()
