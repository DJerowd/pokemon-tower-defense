extends Node3D

@export var wave_manager: WaveManager
@export var unit_selection_manager: UnitSelectionManager

signal pause_changed(is_paused: bool)
signal speed_changed(speed: float)

var is_paused: bool = false
var current_speed: float = 1.0

const GAME_SPEEDS: Array[float] = [1.0, 2.0]
var current_speed_index: int = 0

func _ready() -> void:
	if wave_manager == null:
		push_error("GameController: configure o WaveManager.")
		return

	reset_game_settings()

	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	wave_manager.base_health_changed.connect(_on_base_health_changed)
	wave_manager.game_over.connect(_on_game_over)
	
	var battle_hud := get_node_or_null("BattleHUD")

	if battle_hud != null:
		battle_hud.pause_requested.connect(toggle_pause)
		battle_hud.speed_change_requested.connect(cycle_game_speed)

		pause_changed.connect(battle_hud.update_pause_button)
		speed_changed.connect(battle_hud.update_speed_button)
	else:
		push_warning("GameController: BattleHUD não encontrado.")

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

func toggle_pause() -> void:
	if wave_manager != null and wave_manager.is_game_over:
		return

	is_paused = not is_paused

	get_tree().paused = is_paused

	pause_changed.emit(is_paused)

	print("Partida pausada." if is_paused else "Partida retomada.")


func set_game_speed(speed: float) -> void:
	if speed <= 0.0:
		return

	if is_paused:
		return

	current_speed = speed
	Engine.time_scale = current_speed

	speed_changed.emit(current_speed)

	print("Velocidade da partida: %.1fx" % current_speed)


func cycle_game_speed() -> void:
	if is_paused:
		return

	current_speed_index = (
		current_speed_index + 1
	) % GAME_SPEEDS.size()

	set_game_speed(GAME_SPEEDS[current_speed_index])


func reset_game_settings() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0

	is_paused = false
	current_speed = 1.0
	current_speed_index = 0
