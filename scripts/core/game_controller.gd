extends Node3D

@export var wave_manager: WaveManager


func _ready() -> void:
	if wave_manager == null:
		push_error("GameController: configure o WaveManager.")
		return

	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	wave_manager.base_health_changed.connect(_on_base_health_changed)
	wave_manager.game_over.connect(_on_game_over)

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

func _on_base_health_changed(
	current_health: int,
	maximum_health: int
) -> void:
	print("Base: %d/%d HP" % [
		current_health,
		maximum_health
	])


func _on_game_over() -> void:
	print("A partida terminou. Você perdeu!")
