class_name WaveManager
extends Node

signal wave_started(wave_number: int, wave: WaveDefinition)
signal wave_completed(wave_number: int)
signal all_waves_completed
signal game_over
signal base_health_changed(current_health: int, maximum_health: int)
signal enemy_count_changed(active_count: int)

@export var enemy_scene: PackedScene
@export var path_manager: PathManager
@export var units_container: Node3D
@export var base_core: BaseCore

@export var waves: Array[WaveDefinition] = []

@export_range(0.0, 60.0, 0.1)
var time_between_waves: float = 3.0

var active_enemies: Array[EnemyUnit] = []
var is_running: bool = false
var is_game_over: bool = false


func start_waves() -> void:
	if is_running:
		return

	if enemy_scene == null:
		push_error("WaveManager: configure a cena do inimigo.")
		return

	if path_manager == null:
		push_error("WaveManager: configure o PathManager.")
		return

	if units_container == null:
		push_error("WaveManager: configure o container de unidades.")
		return

	if waves.is_empty():
		push_error("WaveManager: nenhuma onda foi configurada.")
		return

	var waypoints: Array[Vector3] = path_manager.get_waypoints()

	if waypoints.size() < 2:
		push_error("WaveManager: o percurso precisa de pelo menos dois pontos.")
		return

	if base_core == null:
		push_error("WaveManager: configure o BaseCore.")
		return

	if base_core.is_destroyed:
		push_error("WaveManager: a base já foi destruída.")
		return

	base_core.health_changed.connect(_on_base_health_changed)
	base_core.destroyed.connect(_on_base_destroyed)

	is_running = true

	for index in range(waves.size()):
		if is_game_over:
			break

		var wave: WaveDefinition = waves[index]

		if not _is_valid_wave(wave):
			continue

		var wave_number: int = index + 1

		wave_started.emit(wave_number, wave)

		print("Iniciando %s" % wave.display_name)

		for enemy_index in range(wave.enemy_count):
			if is_game_over:
				break

			_spawn_enemy(wave, waypoints)

			if enemy_index < wave.enemy_count - 1:
				await get_tree().create_timer(
					wave.spawn_interval,
					false
				).timeout

		if is_game_over:
			break

		# Aguarda até todos os inimigos desta onda serem derrotados ou chegarem à saída.
		while _has_active_enemies():
			await get_tree().process_frame

		if is_game_over:
			break

		wave_completed.emit(wave_number)

		print("Onda %d concluída!" % wave_number)

		if index < waves.size() - 1:
			await get_tree().create_timer(
				time_between_waves,
				false
			).timeout

	is_running = false

	if is_game_over:
		return

	all_waves_completed.emit()

	print("Todas as ondas foram concluídas!")


func _is_valid_wave(wave: WaveDefinition) -> bool:
	if wave == null:
		push_error("WaveManager: existe uma onda sem recurso configurado.")
		return false

	if wave.enemy_species == null:
		push_error("WaveManager: a onda não possui uma espécie configurada.")
		return false

	if wave.enemy_species.base_stats == null:
		push_error("WaveManager: a espécie não possui atributos-base.")
		return false

	if wave.enemy_count <= 0:
		push_error("WaveManager: a quantidade de inimigos é inválida.")
		return false

	return true


func _spawn_enemy(
	wave: WaveDefinition,
	waypoints: Array[Vector3]
) -> void:
	var instance: Node = enemy_scene.instantiate()
	var enemy := instance as EnemyUnit

	if enemy == null:
		instance.queue_free()
		push_error("WaveManager: a cena não possui EnemyUnit.")
		return

	# Configura a espécie antes de adicionar à árvore.
	enemy.species = wave.enemy_species
	enemy.move_speed = wave.enemy_move_speed

	enemy.reached_goal.connect(_on_enemy_reached_goal)
	enemy.defeated.connect(_on_enemy_defeated)

	units_container.add_child(enemy)

	enemy.set_path(waypoints)

	active_enemies.append(enemy)
	enemy_count_changed.emit(active_enemies.size())



func _on_enemy_reached_goal(enemy: EnemyUnit) -> void:
	active_enemies.erase(enemy)
	enemy_count_changed.emit(active_enemies.size())

	if is_game_over:
		return

	if is_instance_valid(base_core):
		base_core.take_damage(enemy.leak_damage)


func _on_enemy_defeated(enemy: EnemyUnit) -> void:
	active_enemies.erase(enemy)
	enemy_count_changed.emit(active_enemies.size())


func _on_base_health_changed(
	current_health: int,
	maximum_health: int
) -> void:
	base_health_changed.emit(current_health, maximum_health)


func _on_base_destroyed() -> void:
	if is_game_over:
		return

	is_game_over = true

	print("GAME OVER!")

	# Remove os inimigos restantes quando a partida termina.
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.is_finished = true
			enemy.queue_free()

	active_enemies.clear()

	game_over.emit()



func _has_active_enemies() -> bool:
	# Remove referências inválidas ou unidades finalizadas.
	for index in range(active_enemies.size() - 1, -1, -1):
		var enemy: EnemyUnit = active_enemies[index]

		if not is_instance_valid(enemy) or enemy.is_finished:
			active_enemies.remove_at(index)

	return not active_enemies.is_empty()
