extends Node2D
@export var enemy_scene: PackedScene
var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)
	for point in spawn_points:
		spawn_enemy(point)

func spawn_enemy(point: Marker2D) -> void:
	if enemy_scene == null:
		push_error("HostileMobs: enemy_scene non assegnata!")
		return
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = point.global_position

	if "enemy_id" in enemy:
		enemy.enemy_id = point.name
