extends Node3D

@export var wave_manager: WaveManager


func _ready() -> void:
	if wave_manager == null:
		push_error("GameController: configure o WaveManager.")
		return

	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	wave_manager.start_waves()


func _on_wave_started(
	wave_number: int,
	wave: WaveDefinition
) -> void:
	print("Onda %d iniciada: %s" % [
		wave_number,
		wave.display_name
	])


func _on_wave_completed(wave_number: int) -> void:
	print("Onda %d finalizada." % wave_number)


func _on_all_waves_completed() -> void:
	print("Parabéns! Você concluiu todas as ondas.")
