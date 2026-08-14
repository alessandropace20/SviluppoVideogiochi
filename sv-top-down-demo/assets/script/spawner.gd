extends Node2D

@export var enemy_scene: PackedScene

var spawn_points: Array[Marker2D] = []


func _ready() -> void:
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	for point in spawn_points:
		spawn_enemy(point.global_position)


func spawn_enemy(pos: Vector2) -> void:
	if enemy_scene == null:
		push_error("HostileMobs: enemy_scene non assegnata!")
		return

	var enemy = enemy_scene.instantiate()

	# Il nemico diventa figlio di HostileMobs
	add_child(enemy)

	enemy.global_position = pos
