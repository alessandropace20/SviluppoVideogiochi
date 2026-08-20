extends Node

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

var music_volume_linear: float = 1.0
var sfx_volume_linear: float = 1.0

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	music_player.bus = MUSIC_BUS
	add_child(music_player)

	set_music_volume(music_volume_linear)
	set_sfx_volume(sfx_volume_linear)

func set_music_volume(linear_value: float) -> void:
	music_volume_linear = clamp(linear_value, 0.001, 1.0)
	_set_bus_volume(MUSIC_BUS, music_volume_linear)

func set_sfx_volume(linear_value: float) -> void:
	sfx_volume_linear = clamp(linear_value, 0.001, 1.0)
	_set_bus_volume(SFX_BUS, sfx_volume_linear)

func _set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Bus audio '" + bus_name + "' non trovato.")
		return
	var db_value := linear_to_db(linear_value)
	AudioServer.set_bus_volume_db(bus_index, db_value)

func play_music(stream: AudioStream, from_start: bool = true) -> void:
	if music_player.stream == stream and music_player.playing and not from_start:
		return
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()
