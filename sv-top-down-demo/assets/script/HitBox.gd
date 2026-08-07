extends Area2D
@export var damage: int = 10

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	print(name, " ha rilevato area: ", area.name, " | ha receive_hit: ", area.has_method("receive_hit"))
	if area.has_method("receive_hit"):
		area.receive_hit(damage)
