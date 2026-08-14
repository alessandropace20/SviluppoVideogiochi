extends Area2D

func receive_hit(damage: int, from_position: Vector2 = Vector2.ZERO, knockback_force: float = -1.0) -> void:
	var owner_node = get_parent()
	if owner_node.has_method("take_damage"):
		owner_node.take_damage(damage, from_position, knockback_force)
