class_name AllyUnit
extends Node3D

signal enemy_attacked(enemy: EnemyUnit, damage: int)
signal selected
signal deselected

@export var species: PokemonSpecies
@export var move: MoveDefinition
@export var attack_interval: float = 1.0
@export var detection_range: float = 5.0

var attack_timer: float = 0.0
var current_target: EnemyUnit
var is_selected: bool = false
var pokemon_instance: PokemonInstance

func configure_from_instance(instance: PokemonInstance) -> bool:
	if instance == null:
		push_error("Não foi possível configurar o aliado: instância inválida.")
		return false

	if instance.species == null:
		push_error("Não foi possível configurar o aliado: espécie inválida.")
		return false

	pokemon_instance = instance
	species = instance.species

	return true
	
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

	# Atualiza o alvo, priorizando inimigos que podem ser atacados.
	current_target = find_best_target()

	if not is_instance_valid(current_target):
		return

	if current_target.is_finished:
		current_target = null
		return

	var distance := global_position.distance_to(
		current_target.global_position
	)

	# O inimigo ainda não está no alcance de ataque.
	if distance > move.attack_range:
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_target()

		attack_timer = maxf(attack_interval, move.cooldown)

func find_best_target() -> EnemyUnit:
	var enemies := get_tree().get_nodes_in_group("enemies")

	var nearest_attackable: EnemyUnit = null
	var nearest_detected: EnemyUnit = null

	var nearest_attack_distance: float = INF
	var nearest_detection_distance: float = INF

	for node in enemies:
		var enemy := node as EnemyUnit

		if enemy == null or not is_instance_valid(enemy):
			continue

		if enemy.is_finished:
			continue

		var distance := global_position.distance_to(
			enemy.global_position
		)

		if distance <= move.attack_range:
			if distance < nearest_attack_distance:
				nearest_attack_distance = distance
				nearest_attackable = enemy

		elif distance <= detection_range:
			if distance < nearest_detection_distance:
				nearest_detection_distance = distance
				nearest_detected = enemy

	if nearest_attackable != null:
		return nearest_attackable

	return nearest_detected

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

	print(
		"%s atacou %s causando %d de dano."
		% [
			species.display_name,
			current_target.species.display_name,
			damage
		]
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

func set_selected(value: bool) -> void:
	if is_selected == value:
		return

	is_selected = value

	if is_selected:
		selected.emit()
	else:
		deselected.emit()

func _on_selection_area_input_event(
	camera: Node,
	event: InputEvent,
	event_position: Vector3,
	normal: Vector3,
	shape_idx: int
) -> void:

	# Ignora movimentos do mouse e outros eventos.
	if not event is InputEventMouseButton:
		return

	# Aceita somente o clique esquerdo pressionado.
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if not event.pressed:
		return

	print("Clique esquerdo detectado no Pokémon!")

	get_viewport().set_input_as_handled()

	var manager := get_tree().get_first_node_in_group(
        "unit_selection_manager"
	) as UnitSelectionManager

	if manager != null:
		print("UnitSelectionManager encontrado. Selecionando Pokémon.")
		manager.select_unit(self)
	else:
		push_warning("UnitSelectionManager não encontrado!")
