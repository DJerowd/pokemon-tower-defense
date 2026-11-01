class_name AllyUnit
extends Node3D

signal enemy_attacked(enemy: EnemyUnit, damage: int)

@export var species: PokemonSpecies
@export var move: MoveDefinition
@export var attack_interval: float = 1.0
@export var detection_range: float = 5.0

var attack_timer: float = 0.0
var current_target: EnemyUnit


func _ready() -> void:
	if species == null:
		push_error("AllyUnit: nenhuma espécie foi configurada.")
	elif species.base_stats == null:
		push_error("AllyUnit: a espécie não possui atributos-base.")

	if move == null:
		push_error("AllyUnit: nenhum movimento foi configurado.")


func _process(delta: float) -> void:
	if species == null or species.base_stats == null or move == null:
		return

	if not is_instance_valid(current_target):
		current_target = find_nearest_enemy()

	if not is_instance_valid(current_target):
		return

	if current_target.is_finished:
		current_target = null
		return

	var distance := global_position.distance_to(
		current_target.global_position
	)

	if distance > detection_range:
		current_target = null
		return

	if distance > move.attack_range:
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_target()
		attack_timer = maxf(attack_interval, move.cooldown)


func find_nearest_enemy() -> EnemyUnit:
	var enemies := get_tree().get_nodes_in_group("enemies")

	var nearest: EnemyUnit = null
	var nearest_distance: float = detection_range

	for node in enemies:
		var enemy := node as EnemyUnit

		if enemy == null or enemy.is_finished:
			continue

		var distance := global_position.distance_to(
			enemy.global_position
		)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy

	return nearest


func set_target(enemy: EnemyUnit) -> void:
	current_target = enemy


func attack_target() -> void:
	if not is_instance_valid(current_target):
		return

	if current_target.is_finished:
		current_target = null
		return

	if species == null or species.base_stats == null:
		push_warning("O aliado não possui atributos configurados.")
		return

	if move == null:
		push_warning("O aliado não possui um movimento configurado.")
		return

	if current_target.species == null:
		push_warning("O inimigo não possui uma espécie configurada.")
		current_target = null
		return

	if current_target.species.base_stats == null:
		push_warning("A espécie inimiga não possui atributos-base.")
		current_target = null
		return

	# Verifica a precisão do movimento.
	if randf() > clampf(move.accuracy, 0.0, 1.0):
		print("%s errou o ataque!" % species.display_name)
		return

	var attack_stat: int
	var defense_stat: int

	# Seleciona os atributos conforme a categoria do movimento.
	match move.category:
		MoveDefinition.DamageCategory.PHYSICAL:
			attack_stat = species.base_stats.attack
			defense_stat = current_target.species.base_stats.defense

		MoveDefinition.DamageCategory.SPECIAL:
			attack_stat = species.base_stats.special_attack
			defense_stat = current_target.species.base_stats.special_defense

		MoveDefinition.DamageCategory.STATUS:
			# Movimentos de status terão uma lógica própria posteriormente.
			return

	var damage := calculate_damage(
		attack_stat,
		defense_stat,
		move.power
	)

	current_target.take_damage(damage)
	enemy_attacked.emit(current_target, damage)


func calculate_damage(
	attack_stat: int,
	defense_stat: int,
	power: int
) -> int:
	var safe_defense := maxi(1, defense_stat)

	var damage := (
		(float(power) * float(attack_stat) / float(safe_defense))
		/ 2.0
	)

	return maxi(1, int(round(damage)))
