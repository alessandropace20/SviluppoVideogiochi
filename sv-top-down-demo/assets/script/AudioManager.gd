extends Node

var music_volume_linear: float = 1.0  # 0.0 - 1.0, comodo per gli slider

const BUS_NAME := "Music"  # crea questo bus in Audio → Bus Layout, se non esiste già

func _ready() -> void:
	set_music_volume(music_volume_linear)

func set_music_volume(linear_value: float) -> void:
	music_volume_linear = linear_value
	var bus_index = AudioServer.get_bus_index(BUS_NAME)
	if bus_index == -1:
		push_warning("Bus audio '" + BUS_NAME + "' non trovato. Crealo in Audio → Bus Layout.")
		return
	# I bus audio lavorano in decibel, non in scala lineare: conversione necessaria
	var db_value = linear_to_db(clamp(linear_value, 0.001, 1.0))
	AudioServer.set_bus_volume_db(bus_index, db_value)
