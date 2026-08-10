extends Node2D

@export var enemy_scene: PackedScene  # trascina qui Orc.tscn dall'Inspector

var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	# Raccoglie automaticamente tutti i Marker2D figli, in qualunque ordine li aggiungi
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	for point in spawn_points:
		spawn_enemy(point.global_position)

func spawn_enemy(pos: Vector2) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	get_tree().current_scene.add_child.call_deferred(enemy)
