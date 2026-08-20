extends StaticBody2D

@onready var blocking_shape: CollisionShape2D = $DoorShape

func _ready() -> void:
	EventBus.boss_defeated.connect(_on_boss_defeated)

func _on_boss_defeated() -> void:
	blocking_shape.set_deferred("disabled", true)
