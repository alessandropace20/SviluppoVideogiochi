extends Node

enum Difficulty {
	EASY,
	NORMAL,
	HARD
}

var current_difficulty: Difficulty = Difficulty.EASY

signal difficulty_changed(difficulty: Difficulty)


var modifiers := {
	Difficulty.EASY: {
		"health_recovery": 1.25,
		"enemy_speed": 0.80,
		"attack2_cooldown": 0.3
	},

	Difficulty.NORMAL: {
		"health_recovery": 1.0,
		"enemy_speed": 1.0,
		"attack2_cooldown": 0.5
	},

	Difficulty.HARD: {
		"health_recovery": 0.75,
		"enemy_speed": 1.25,
		"attack2_cooldown": 1.0
	}
}


func set_difficulty(difficulty: Difficulty) -> void:
	current_difficulty = difficulty
	difficulty_changed.emit(current_difficulty)


func get_health_recovery_multiplier() -> float:
	return modifiers[current_difficulty]["health_recovery"]


func get_enemy_speed_multiplier() -> float:
	return modifiers[current_difficulty]["enemy_speed"]


func get_attack2_cooldown() -> float:
	return modifiers[current_difficulty]["attack2_cooldown"]
