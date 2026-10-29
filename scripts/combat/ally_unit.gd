class_name AllyUnit
extends Node3D

signal enemy_attacked(enemy: EnemyUnit, damage: int)

@export var species: PokemonSpecies
@export var move: MoveDefinition
@export var attack_interval: float = 1.0

var attack_timer: float = 0.0
var current_target: EnemyUnit

func _process(delta: float) -> void:
	if move == null:
		return

	if not is_instance_valid(current_target):
		current_target = null
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		attack_timer = maxf(attack_interval, move.cooldown)
		attack_target()

func set_target(enemy: EnemyUnit) -> void:
	current_target = enemy

func attack_target() -> void:
	if not is_instance_valid(current_target):
		return

	if current_target.is_finished:
		current_target = null
		return

	var distance := global_position.distance_to(
		current_target.global_position
	)

	if distance > move.range:
		return

	var damage := maxi(1, move.power)

	current_target.take_damage(damage)
	enemy_attacked.emit(current_target, damage)
